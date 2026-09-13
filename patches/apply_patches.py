#!/usr/bin/env python3
"""
InstaTrueReel — smali patcher (v6, Phase 5 — CHAIN LIBERATION + FULL DIAGNOSTICS).

Field state (v0.5 tested on Android 10, 9:16, user log android_live_log.txt, 16 MB):
  * v0.5 hooks fire on ALL entry points (Reels tab, home-feed overlay, Watch History
    modal, Likes modal) — 5 clean apply/restore markers, zero exceptions.
  * The re-apply engine provably wins the nav-bar color war on every path
    (setNavigationBarColor: 0 at +100/400/1000/2500/5000 ms).
  * BUT the two v0.5 runtime fixes were SILENT NO-OPS: "v0.5 deblock:" and
    "v0.5 modal:" log lines appear ZERO times in the whole 111k-line log —
    findViewById(0x7f0b224a/0x7f0b2246/0x7f0b3f45) returned null (or preconditions
    failed) on every one of the 6 evaluations per entry, and the null-guards
    skipped silently. Consequences:
      1. FEED path (Context-Preserving Overlay): comment-bar area stays opaque
         (the containers bounding the video keep their margins; window decor
         shows below the video).
      2. WATCH HISTORY / LIKES path (ModalActivity): ModalActivity.A2T() sets
         fitsSystemWindows=true on the modal root -> content is inset away from
         the bars -> transparent bars reveal the black window background ->
         "nothing is transparent".
  * Watch History / Likes reels run in com.instagram.modal.ModalActivity
    (separate window; toast + hooks confirmed there by the log).

v0.6 fix — one generic mechanism replaces the fragile hardcoded-ID surgery:

  CHAIN LIBERATION (helper A09/A11/A12): walk from the reels fragment's own
  view UP the parent chain to the decor. For every ancestor ViewGroup, save
  (paddingTop, paddingBottom, bottomMargin, fitsSystemWindows) ONCE into a
  TTrueReelViewSave list, then zero them all while reels is active. Restore
  everything on exit (A10). This covers the ModalActivity root padding AND
  the MainTabActivity feed-overlay bounding containers in one pass, without
  relying on any view id. The walk re-runs on every re-apply tick so late
  re-blocks by Instagram are re-liberated.

  FULL DIAGNOSTICS: every action logs ("v0.6 liberate: <class> t=.. b=.. mb=..
  fits=..", "v0.6 deblock eval: pager=.. main=..", "v0.6 liberate: chain freed
  (n=..)", "v0.6 restore-layout: chain restored (n=..)"), and every catch block
  logs its exception — v0.5's silent failure mode can never happen again.

Patches (all idempotent, fail loudly, marked with `instatruereel:` comments):

  kept from v0.3/v0.4/v0.5:
    1. X/9Wz.EEr()Z -> forced true (native edge-to-edge reels master switch).
    2. TTrueReelHelper + TTrueReelReapply + TTrueReelViewSave installed (window
       apply/restore, activity-scoped interceptors, per-entry toast + logcat,
       re-apply engine, v0.6 chain liberation).
    3. ClipsViewerFragment (9Wz) + ClipsTabFragment (AFt) lifecycle hooks.
    4. X/1fC.A04 status-bar color interceptor; X/1fI.A04 nav-bar interceptor.
    5. X/2Iv.A03() top scrim alpha 0.6 -> 0.2 (TikTok-style legibility).
    6. ClipsViewerNavigationBar.A00 :cond_e -> null background.
    7. X/2ZS.A0A lerped tab-bar color -> 0x00000000 while reels active.
    8. X/0bQ.A04 config/theme re-apply path -> bds_transparent while active.
    9. X/0bI.A0B tab icon colors -> white active / 70% white normal while active.

  NEW in v0.6:
   10. Helper A08 rewritten: logs an eval line on EVERY call ("v0.6 deblock
       eval: pager=m=N|null main=..") before the (kept) margin zeroing, so the
       next field log proves whether those ids resolve in the running tree.
   11. Helper A09 rewritten: generic chain-liberation walk (see above).
   12. Helper A10 extended: restores the liberated chain + re-dispatches
       insets, then the v0.5 margin restores.
   13. New class X/TTrueReelViewSave (the per-view saved state holder).
   14. All catch blocks log; all version strings bumped to v0.6
       (toast: "InstaTrueReel v0.6: full-bleed everywhere ON").
"""
import os
import re
import shutil
import sys

DECODED = sys.argv[1] if len(sys.argv) > 1 else "decoded"
HERE = os.path.dirname(os.path.abspath(__file__))

HELPER_SRC = os.path.join(HERE, "helper_TTrueReelHelper.smali")
HELPER_DST = os.path.join(DECODED, "smali_classes16", "X", "TTrueReelHelper.smali")
REAPPLY_SRC = os.path.join(HERE, "helper_TTrueReelReapply.smali")
REAPPLY_DST = os.path.join(DECODED, "smali_classes16", "X", "TTrueReelReapply.smali")
VIEWSAVE_SRC = os.path.join(HERE, "helper_TTrueReelViewSave.smali")
VIEWSAVE_DST = os.path.join(DECODED, "smali_classes16", "X", "TTrueReelViewSave.smali")

CLIPS_VIEWER = os.path.join(DECODED, "smali_classes16", "X", "9Wz.smali")
CLIPS_TAB = os.path.join(DECODED, "smali_classes16", "X", "AFt.smali")
WINDOW_CHROME = os.path.join(DECODED, "smali_classes13", "X", "1fC.smali")
NAV_CHROME = os.path.join(DECODED, "smali_classes13", "X", "1fI.smali")
REELS_DELEGATE = os.path.join(DECODED, "smali_classes17", "X", "2Iv.smali")
NAVBAR_CLASS = os.path.join(
    DECODED, "smali_classes10", "instagram", "features", "clips", "viewer",
    "navigationbar", "ClipsViewerNavigationBar.smali",
)
TABBAR_THEMER = os.path.join(DECODED, "smali_classes17", "X", "2ZS.smali")
TABBAR_SETTER = os.path.join(DECODED, "smali_classes13", "X", "0bQ.smali")
TABBAR_ICON = os.path.join(DECODED, "smali_classes13", "X", "0bI.smali")

APPLY = "invoke-static/range {p0 .. p0}, LX/TTrueReelHelper;->A00(Landroidx/fragment/app/Fragment;)V"
RESTORE = "invoke-static/range {p0 .. p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V"
HIDDEN = "invoke-static {p0, p1}, LX/TTrueReelHelper;->A02(Landroidx/fragment/app/Fragment;Z)V"

INTERCEPT_STATUS_COLOR = (
    "invoke-static {p0, p1}, LX/TTrueReelHelper;->A03(Landroid/app/Activity;I)I\n"
    "    move-result p1"
)
INTERCEPT_NAV_COLOR = (
    "invoke-static {p0, p1}, LX/TTrueReelHelper;->A07(Landroid/app/Activity;I)I\n"
    "    move-result p1"
)

# ---- patch 7: 2ZS.A0A lerped tab-bar color -> transparent while reels active ----
TTAB_LERP_OLD_RE = re.compile(
    r"invoke-static \{p4, p5, p6\}, LX/4u9;->A02\(FII\)I\n\s*\n\s*"
    r"move-result v2\n\s*\n\s*"
    r"invoke-static \{p4, p6, p5\}, LX/4u9;->A02\(FII\)I\n\s*\n\s*"
    r"move-result v5\n"
)
TTAB_LERP_NEW = (
    "invoke-static {p4, p5, p6}, LX/4u9;->A02(FII)I\n\n"
    "    move-result v2\n\n"
    "    invoke-static {p4, p6, p5}, LX/4u9;->A02(FII)I\n\n"
    "    move-result v5\n\n"
    "    # instatruereel: transparent tab bar + decor while reels active\n"
    "    sget-boolean v0, LX/TTrueReelHelper;->A05:Z\n"
    "    if-eqz v0, :itr_ttab_skip\n"
    "    const/4 v2, 0x0\n"
    "    const/4 v5, 0x0\n"
    "    :itr_ttab_skip\n"
)
TTAB_MARKER = "instatruereel: transparent tab bar + decor"

# ---- patch 8: 0bQ.A04 config re-apply -> bds_transparent while reels active ----
TABBAR_CFG_GATE = (
    "sget-boolean v0, LX/TTrueReelHelper;->A05:Z\n"
    "    if-eqz v0, :itr_cfg_skip\n"
    "    # instatruereel: transparent tab bar (config re-apply path)\n"
    "    const p2, 0x7f0600a9\n"
    "    const p3, 0x7f0600a9\n"
    "    :itr_cfg_skip"
)

# ---- patch 9: 0bI.A0B tab icon colors -> white while reels active ----
TABBAR_ICON_GATE = (
    "sget-boolean v0, LX/TTrueReelHelper;->A05:Z\n"
    "    if-eqz v0, :itr_icon_skip\n"
    "    # instatruereel: white tab icons over video while reels active\n"
    "    const/4 p1, -0x1\n"
    "    const v0, -0x4c000001\n"
    "    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;\n"
    "    move-result-object p2\n"
    "    :itr_icon_skip"
)

EER_METHOD_OLD = re.compile(
    r"\.method public final EEr\(\)Z\n"
    r"(?:[^\n]*\n)*?"
    r"\.end method\n",
    re.MULTILINE,
)
EER_METHOD_NEW = (
    ".method public final EEr()Z\n"
    "    .locals 1\n"
    "\n"
    "    # instatruereel: EEr forced true -> native edge-to-edge reels mode ON\n"
    "    # (transparent status bar + inset-padded overlays; overrides A2g/A3H/QE)\n"
    "    const/4 v0, 0x1\n"
    "\n"
    "    return v0\n"
    ".end method\n"
)
EER_MARKER = "instatruereel: EEr forced true"

SCRIM_OLD_RE = re.compile(r"const-wide v4, 0x3fe3333333333333L[^\n]*\n")
SCRIM_NEW = (
    "const-wide v4, 0x3fc999999999999aL    "
    "# instatruereel: 0.2 TikTok-style scrim (was 0.6)\n"
)
SCRIM_MARKER = "instatruereel: 0.2 TikTok-style scrim"

NAVBAR_OLD_RE = re.compile(
    r"    :cond_e\n"
    r"    const v0, 0x7f08042b\n"
    r"\n"
    r"    invoke-virtual \{v7, v0\}, Landroid/content/Context;->getDrawable\(I\)Landroid/graphics/drawable/Drawable;\n"
    r"\n"
    r"    move-result-object v0\n"
    r"\n"
    r"    goto/16 :goto_0\n"
)
NAVBAR_NEW = (
    "    :cond_e\n"
    "    # instatruereel: viewer navigation row always transparent\n"
    "    const/4 v0, 0x0\n"
    "\n"
    "    goto/16 :goto_0\n"
)
NAVBAR_MARKER = "instatruereel: viewer navigation row always transparent"

ON_HIDDEN_OVERRIDE_2YN = (
    "\n.method public onHiddenChanged(Z)V\n"
    "    .locals 0\n"
    "\n"
    "    invoke-super {p0, p1}, LX/2yN;->onHiddenChanged(Z)V\n"
    "\n"
    "    " + HIDDEN + "\n"
    "\n"
    "    return-void\n"
    ".end method\n"
)

ON_PAUSE_OVERRIDE_ANDROIDX = (
    "\n.method public onPause()V\n"
    "    .locals 0\n"
    "\n"
    "    invoke-super {p0}, Landroidx/fragment/app/Fragment;->onPause()V\n"
    "\n"
    "    " + RESTORE + "\n"
    "\n"
    "    return-void\n"
    ".end method\n"
)

errors = []
report = []


def read(path):
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def write(path, content):
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(content)


def inject_after_locals(content, method_pattern, inject_text, label):
    marker = "# instatruereel:" + label
    if marker in content:
        report.append(f"  [skip] {label}: already patched")
        return content, True
    m = re.search(
        r"(?m)^\.method[^\n]*" + re.escape(method_pattern) + r"[^\n]*\n(?:[ \t]*\n|[ \t]*#[^\n]*\n)*[ \t]*\.locals \d+\n",
        content,
    )
    if not m:
        errors.append(f"{label}: method/method-header not found: {method_pattern}")
        return content, False
    insert_at = m.end()
    block = "    " + marker + "\n    " + inject_text + "\n"
    new = content[:insert_at] + block + content[insert_at:]
    report.append(f"  [ ok ] {label}: injected")
    return new, True


def append_method(content, method_text, marker, label):
    if marker in content:
        report.append(f"  [skip] {label}: already present")
        return content
    if not content.endswith("\n"):
        content += "\n"
    report.append(f"  [ ok ] {label}: appended")
    return content + method_text


def replace_method(content, regex, replacement, marker, label, expect=1):
    if marker in content:
        report.append(f"  [skip] {label}: already patched")
        return content
    new, n = regex.subn(replacement, content, count=expect)
    if n != expect:
        errors.append(f"{label}: expected {expect} match(es), found {n}")
        return content
    report.append(f"  [ ok ] {label}: replaced ({n})")
    return new


def replace_unique(content, regex, replacement, marker, label):
    if marker in content:
        report.append(f"  [skip] {label}: already patched")
        return content
    matches = regex.findall(content)
    if len(matches) != 1:
        errors.append(f"{label}: expected exactly 1 match, found {len(matches)}")
        return content
    new, n = regex.subn(replacement, content, count=1)
    if n != 1:
        errors.append(f"{label}: substitution failed")
        return content
    report.append(f"  [ ok ] {label}: patched")
    return new


def main():
    targets = (
        CLIPS_VIEWER, CLIPS_TAB, WINDOW_CHROME, NAV_CHROME, REELS_DELEGATE,
        NAVBAR_CLASS, TABBAR_THEMER, TABBAR_SETTER, TABBAR_ICON,
    )
    for path in targets:
        if not os.path.isfile(path):
            errors.append(f"missing target file: {path}")

    if errors:
        finish()

    # ---------- 1. install helpers (v0.6) ----------
    os.makedirs(os.path.dirname(HELPER_DST), exist_ok=True)
    if os.path.isfile(HELPER_DST):
        report.append("  [skip] helper TTrueReelHelper already installed")
    else:
        shutil.copyfile(HELPER_SRC, HELPER_DST)
        report.append("  [ ok ] helper TTrueReelHelper v0.6 installed -> smali_classes16/X/")

    if os.path.isfile(REAPPLY_DST):
        report.append("  [skip] helper TTrueReelReapply already installed")
    else:
        shutil.copyfile(REAPPLY_SRC, REAPPLY_DST)
        report.append("  [ ok ] helper TTrueReelReapply v0.6 installed -> smali_classes16/X/")

    if os.path.isfile(VIEWSAVE_DST):
        report.append("  [skip] helper TTrueReelViewSave already installed")
    else:
        shutil.copyfile(VIEWSAVE_SRC, VIEWSAVE_DST)
        report.append("  [ ok ] helper TTrueReelViewSave v0.6 installed -> smali_classes16/X/")

    # ---------- 2. THE CORE PATCH: force 9Wz.EEr() = true ----------
    report.append("ClipsViewerFragment native edge-to-edge switch (X/9Wz.EEr):")
    src = read(CLIPS_VIEWER)
    if ".super LX/2yN;" not in src:
        errors.append("9Wz: unexpected superclass (expected LX/2yN;)")
    if '__redex_internal_original_name:Ljava/lang/String; = "ClipsViewerFragment"' not in src:
        errors.append("9Wz: expected ClipsViewerFragment redex name not found (version drift?)")
    if ".method public final EEr()Z" not in src:
        errors.append("9Wz: EEr()Z method not found (version drift?)")
    src = replace_method(src, EER_METHOD_OLD, EER_METHOD_NEW, EER_MARKER, "9Wz.EEr -> forced true")
    write(CLIPS_VIEWER, src)

    # ---------- 3. fragment lifecycle hooks ----------
    report.append("ClipsViewerFragment lifecycle (X/9Wz):")
    src = read(CLIPS_VIEWER)
    src, _ = inject_after_locals(src, "onResume()V", APPLY, "9Wz.onResume -> apply")
    src, _ = inject_after_locals(src, "onPause()V", RESTORE, "9Wz.onPause -> restore")
    src, _ = inject_after_locals(src, "onDestroyView()V", RESTORE, "9Wz.onDestroyView -> restore")
    src = append_method(src, ON_HIDDEN_OVERRIDE_2YN, "onHiddenChanged(Z)V", "9Wz.onHiddenChanged override")
    write(CLIPS_VIEWER, src)

    # ---------- 4. ClipsTabFragment (X/AFt) ----------
    report.append("ClipsTabFragment (X/AFt):")
    src = read(CLIPS_TAB)
    if ".super LX/2yN;" not in src:
        errors.append("AFt: unexpected superclass (expected LX/2yN;)")
    if '__redex_internal_original_name:Ljava/lang/String; = "ClipsTabFragment"' not in src:
        errors.append("AFt: expected ClipsTabFragment redex name not found (version drift?)")
    src, _ = inject_after_locals(src, "onResume()V", APPLY, "AFt.onResume -> apply")
    src, _ = inject_after_locals(src, "onDestroyView()V", RESTORE, "AFt.onDestroyView -> restore")
    src = append_method(src, ON_HIDDEN_OVERRIDE_2YN, "onHiddenChanged(Z)V", "AFt.onHiddenChanged override")
    src = append_method(src, ON_PAUSE_OVERRIDE_ANDROIDX, "onPause()V", "AFt.onPause override")
    write(CLIPS_TAB, src)

    # ---------- 5. status-bar color interceptor (X/1fC.A04) ----------
    report.append("WindowChromeController status bar (X/1fC.A04):")
    src = read(WINDOW_CHROME)
    if ".super Ljava/lang/Object;" not in src:
        errors.append("1fC: unexpected superclass (expected Ljava/lang/Object;)")
    src, _ = inject_after_locals(
        src, "A04(Landroid/app/Activity;I)V", INTERCEPT_STATUS_COLOR,
        "1fC.A04 -> transparent-while-reels",
    )
    write(WINDOW_CHROME, src)

    # ---------- 6. navigation-bar color interceptor (X/1fI.A04) ----------
    report.append("WindowChromeController navigation bar (X/1fI.A04):")
    src = read(NAV_CHROME)
    if ".super Ljava/lang/Object;" not in src:
        errors.append("1fI: unexpected superclass (expected Ljava/lang/Object;)")
    src, _ = inject_after_locals(
        src, "A04(Landroid/app/Activity;I)V", INTERCEPT_NAV_COLOR,
        "1fI.A04 -> transparent-while-reels",
    )
    write(NAV_CHROME, src)

    # ---------- 7. top scrim alpha 0.6 -> 0.2 (X/2Iv.A03) ----------
    report.append("Reels delegate top scrim (X/2Iv.A03):")
    src = read(REELS_DELEGATE)
    if ".method private final A03()Landroid/graphics/drawable/Drawable;" not in src:
        errors.append("2Iv: A03() method not found (version drift?)")
    if "EEr()Z" not in src:
        errors.append("2Iv: EEr() call not found (version drift?)")
    src = replace_unique(src, SCRIM_OLD_RE, SCRIM_NEW, SCRIM_MARKER, "2Iv.A03 scrim 0.6 -> 0.2")
    write(REELS_DELEGATE, src)

    # ---------- 8. viewer navigation row transparent ----------
    report.append("Viewer navigation row (ClipsViewerNavigationBar.A00):")
    src = read(NAVBAR_CLASS)
    if ".super Landroid/widget/LinearLayout;" not in src:
        errors.append("ClipsViewerNavigationBar: unexpected superclass (expected LinearLayout)")
    if ".method public static final A00(Linstagram/features/clips/viewer/navigationbar/ClipsViewerNavigationBar;LX/A8e;)V" not in src:
        errors.append("ClipsViewerNavigationBar: A00 method not found (version drift?)")
    src = replace_unique(src, NAVBAR_OLD_RE, NAVBAR_NEW, NAVBAR_MARKER, "navbar cond_e -> null background")
    write(NAVBAR_CLASS, src)

    # ---------- 9. v0.5: lerped tab-bar color -> transparent (X/2ZS.A0A) ----------
    report.append("Main tab bar themer (X/2ZS.A0A lerp gate):")
    src = read(TABBAR_THEMER)
    if "A0A(Landroid/app/Activity;Landroidx/fragment/app/Fragment;" not in src:
        errors.append("2ZS: A0A method signature not found (version drift?)")
    if "0x7f0b3f67" not in src:
        errors.append("2ZS: tab_bar id 0x7f0b3f67 not found (version drift?)")
    src = replace_unique(
        src, TTAB_LERP_OLD_RE, TTAB_LERP_NEW, TTAB_MARKER,
        "2ZS.A0A lerp -> transparent while reels",
    )
    write(TABBAR_THEMER, src)

    # ---------- 10. v0.5: config re-apply path -> bds_transparent (X/0bQ.A04) ----------
    report.append("Main tab bar setter (X/0bQ.A04 config gate):")
    src = read(TABBAR_SETTER)
    if "A04(Landroid/app/Activity;Lcom/instagram/common/session/UserSession;II)V" not in src:
        errors.append("0bQ: A04 method signature not found (version drift?)")
    src, _ = inject_after_locals(
        src, "A04(Landroid/app/Activity;Lcom/instagram/common/session/UserSession;II)V",
        TABBAR_CFG_GATE, "0bQ.A04 -> transparent-while-reels",
    )
    write(TABBAR_SETTER, src)

    # ---------- 11. v0.5: white tab icons over video (X/0bI.A0B) ----------
    report.append("Main tab bar icons (X/0bI.A0B icon gate):")
    src = read(TABBAR_ICON)
    if "A0B(ILjava/lang/Integer;)V" not in src:
        errors.append("0bI: A0B method signature not found (version drift?)")
    if "setActiveColor" not in src:
        errors.append("0bI: setActiveColor not found (version drift?)")
    src, _ = inject_after_locals(
        src, "A0B(ILjava/lang/Integer;)V", TABBAR_ICON_GATE,
        "0bI.A0B -> white-icons-while-reels",
    )
    write(TABBAR_ICON, src)

    # ---------- verify ----------
    report.append("Verification:")
    checks = [
        (CLIPS_VIEWER, EER_MARKER, "9Wz.EEr forced-true present"),
        (CLIPS_VIEWER, "const/4 v0, 0x1", "9Wz.EEr returns true"),
        (CLIPS_VIEWER, APPLY, "9Wz apply present"),
        (CLIPS_VIEWER, RESTORE, "9Wz restore present"),
        (CLIPS_VIEWER, HIDDEN, "9Wz hidden bridge present"),
        (CLIPS_TAB, APPLY, "AFt apply present"),
        (CLIPS_TAB, RESTORE, "AFt restore present"),
        (CLIPS_TAB, HIDDEN, "AFt hidden bridge present"),
        (WINDOW_CHROME, "LX/TTrueReelHelper;->A03(Landroid/app/Activity;I)I", "1fC color interceptor present"),
        (NAV_CHROME, "LX/TTrueReelHelper;->A07(Landroid/app/Activity;I)I", "1fI nav interceptor present"),
        (HELPER_DST, ".method public static A00(", "helper apply method present"),
        (HELPER_DST, ".method public static A01(", "helper restore method present"),
        (HELPER_DST, ".method public static A02(", "helper hidden bridge present"),
        (HELPER_DST, ".method public static A03(", "helper color interceptor present"),
        (HELPER_DST, ".method public static A07(", "helper nav interceptor present"),
        (HELPER_DST, ".method public static A05()V", "helper scheduler present"),
        (HELPER_DST, ".method public static A06(", "helper reapply core present"),
        (HELPER_DST, ".method public static A08(", "helper deblock margins present"),
        (HELPER_DST, ".method public static A09(", "helper v0.6 chain liberation present"),
        (HELPER_DST, ".method public static A10(", "helper layout restore present"),
        (HELPER_DST, ".method public static A11(", "helper v0.6 liberate-single-view present"),
        (HELPER_DST, ".method public static A12(", "helper v0.6 zero-view present"),
        (HELPER_DST, ".method public static A13(", "helper v0.6 margin reader present"),
        (HELPER_DST, ".method public static A14(", "helper v0.6 view descriptor present"),
        (HELPER_DST, "A0F:Landroidx/fragment/app/Fragment;", "helper v0.6 fragment anchor field present"),
        (HELPER_DST, "A0G:Ljava/util/ArrayList;", "helper v0.6 chain-save list field present"),
        (HELPER_DST, "LX/TTrueReelViewSave;-><init>(Landroid/view/View;IIIZ)V", "helper v0.6 creates view saves"),
        (HELPER_DST, "invoke-direct/range {v2 .. v7}", "helper v0.6 range-invoke arity correct"),
        (HELPER_DST, "0x7f0b3f45", "helper targets swipeable_tab_view_pager"),
        (HELPER_DST, "0x7f0b2246", "helper targets layout_container_main"),
        (HELPER_DST, 'const-string v1, "InstaTrueReel v0.6: full-bleed everywhere ON"', "toast marker v0.6 present"),
        (HELPER_DST, 'v0.6 deblock eval: pager=', "v0.6 deblock eval diagnostics present"),
        (HELPER_DST, 'v0.6 liberate: chain freed (n=', "v0.6 liberation summary log present"),
        (HELPER_DST, 'v0.6 restore-layout: chain restored (n=', "v0.6 chain-restore log present"),
        (HELPER_DST, 'v0.6 liberate: exception (recovered)', "v0.6 exceptions are logged, never silent"),
        (HELPER_DST, "WindowManager$LayoutParams", "helper uses correct WindowManager type"),
        (VIEWSAVE_DST, ".class public LX/TTrueReelViewSave;", "viewsave class present"),
        (VIEWSAVE_DST, "A00:Landroid/view/View;", "viewsave holds view ref"),
        (VIEWSAVE_DST, "A01:I", "viewsave holds paddingTop"),
        (VIEWSAVE_DST, "A02:I", "viewsave holds paddingBottom"),
        (VIEWSAVE_DST, "A03:I", "viewsave holds bottomMargin"),
        (VIEWSAVE_DST, "A04:Z", "viewsave holds fitsSystemWindows"),
        (VIEWSAVE_DST, ".method public constructor <init>(Landroid/view/View;IIIZ)V", "viewsave ctor present"),
        (REAPPLY_DST, ".implements Ljava/lang/Runnable;", "reapply runnable present"),
        (REAPPLY_DST, "A01:Landroid/app/Activity;", "reapply carries activity ref"),
        (REAPPLY_DST, "TTrueReelHelper;->A08(Landroid/app/Activity;)V", "reapply calls deblock"),
        (REAPPLY_DST, "TTrueReelHelper;->A09(Landroid/app/Activity;)V", "reapply calls chain liberation (v0.6)"),
        (REELS_DELEGATE, SCRIM_MARKER, "2Iv top scrim 0.2 marker present"),
        (REELS_DELEGATE, "0x3fc999999999999aL", "2Iv top scrim 0.2 literal present"),
        (NAVBAR_CLASS, NAVBAR_MARKER, "navbar transparent marker present"),
        (TABBAR_THEMER, TTAB_MARKER, "2ZS.A0A tab-bar transparent gate present"),
        (TABBAR_THEMER, ":itr_ttab_skip", "2ZS.A0A gate label present"),
        (TABBAR_THEMER, "LX/TTrueReelHelper;->A05:Z", "2ZS references helper flag"),
        (TABBAR_SETTER, "0bQ.A04 -> transparent-while-reels", "0bQ.A04 gate present"),
        (TABBAR_SETTER, "0x7f0600a9", "0bQ.A04 uses bds_transparent resource"),
        (TABBAR_ICON, "0bI.A0B -> white-icons-while-reels", "0bI.A0B gate present"),
        (TABBAR_ICON, "Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;", "0bI.A0B boxes normal color"),
    ]
    for path, needle, label in checks:
        if needle in read(path):
            report.append(f"  [ ok ] {label}")
        else:
            report.append(f"  [FAIL] {label}")
            errors.append(f"verification failed: {label}")

    # negative check: opaque gradient const must be GONE from the navbar
    if "0x7f08042b" in read(NAVBAR_CLASS):
        report.append("  [FAIL] navbar opaque gradient const still present")
        errors.append("verification failed: navbar 0x7f08042b still present")
    else:
        report.append("  [ ok ] navbar opaque gradient const removed")

    # negative check: the Window$LayoutParams crash-bug signature must be absent
    for path in (HELPER_DST, REAPPLY_DST, VIEWSAVE_DST):
        if "Landroid/view/Window$LayoutParams;" in read(path):
            report.append(f"  [FAIL] {os.path.basename(path)} still references Window$LayoutParams (v0.3 crash bug)")
            errors.append(f"verification failed: Window$LayoutParams present in {os.path.basename(path)}")
        else:
            report.append(f"  [ ok ] {os.path.basename(path)} free of Window$LayoutParams crash signature")

    finish()


def finish():
    print("InstaTrueReel patch report (v6)")
    print("===============================")
    for line in report:
        print(line)
    if errors:
        print()
        print("ERRORS:")
        for e in errors:
            print("  !! " + e)
        sys.exit(1)
    print()
    print("All patches applied cleanly.")
    print()
    print("v0.6 = v0.5 (EEr=true + helper + interceptors + scrim 0.2 + navbar null")
    print("        + transparent main tab bar 2ZS/0bQ + white icons 0bI)")
    print("        + CHAIN LIBERATION: generic ancestor walk from the reels fragment")
    print("          view to the decor — saves + zeroes paddingTop/Bottom, bottomMargin")
    print("          and fitsSystemWindows of every bounding container while reels is")
    print("          active (fixes ModalActivity black strip + feed-path opaque bottom")
    print("          without relying on hardcoded view ids) — restored on exit.")
    print("        + NEW class X/TTrueReelViewSave (per-view saved state).")
    print("        + FULL DIAGNOSTICS: 'v0.6 deblock eval', 'v0.6 liberate:' detail")
    print("          lines, chain freed/restored summaries, and every exception logged.")
    print("        + re-apply ticks re-run the walk at 100/400/1000/2500/5000 ms.")


if __name__ == "__main__":
    main()
