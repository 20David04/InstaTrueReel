# InstaTrueReel

**Immersive True 9:16 Reel Experience** — makes Instagram Reels play TikTok-style:
full-bleed edge-to-edge video under a transparent status bar, transparent nav bar,
floating UI. Built entirely with GitHub Actions (decompile → smali patch → rebuild → sign).

## 📦 Downloads

| Release | APK | What |
|---|---|---|
| [v0.6.0-phase5](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.6.0-phase5) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | **Chain liberation — every entry point full-bleed**: fixes home-feed comment-bar strip + Watch History/Liked (ModalActivity) black bars; full logcat diagnostics |
| [v0.5.0-phase4](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.5.0-phase4) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | **Full-bleed bottom + modal path attempt**: transparent main tab bar (2ZS/0bQ/0bI) + runtime view-id de-block (turned out to be a silent no-op — fixed in v0.6) |
| [v0.4.0-phase3](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.4.0-phase3) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | **TikTok-style overlays**: v0.3 + top-bar scrim 0.6 → 0.2 alpha + fully transparent bottom comment bar |
| [v0.3.0-phase2](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.3.0-phase2) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | **Native edge-to-edge**: forces Instagram's own immersive Reels mode on (`9Wz.EEr → true`) + status/nav-bar interceptors |
| [v0.2.0-phase1.1](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.2.0-phase1.1) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | Window-chrome interceptors only (superseded) |
| [v0.1.0-phase1](https://github.com/Skyro7777777/InstaTrueReel/releases/tag/v0.1.0-phase1) | `Instagram-v435.0.0.37.76-InstaTrueReel-signed.apk` | Initial attempt (superseded) |

> **Always grab the newest release (v0.6.0).** The 16 MB logcat from the v0.5 field test
> proved the v0.5 runtime fixes never executed (silent no-ops: hardcoded view ids never
> resolved, and the failures were swallowed without logging). v0.6 replaces them with one
> generic mechanism — the **chain liberation walk**: while Reels is active it walks from
> the reels fragment's own view up to the window decor and zeroes the top/bottom padding,
> bottom margins and `fitsSystemWindows` of **every bounding container** (restored on
> exit). No view ids involved — so it works on all entry points:
>
> - **Reels tab** — already perfect in v0.5 (both bars transparent over full-bleed video).
> - **Home-feed entry (Context-Preserving Overlay)** — the opaque comment-bar strip is
>   gone: the containers that cut the video off above the "Add comment…" row are
>   liberated, video draws edge-to-edge behind it.
> - **Watch History / Liked (ModalActivity)** — the black status-bar strip is gone: the
>   modal root's `fitsSystemWindows` insets padding is removed, video runs under the
>   (already color-won) transparent status + nav bars.
>
> v0.6 also **logs everything**: `adb logcat -s InstaTrueReel` now prints per-view detail
> lines (`v0.6 liberate: <class> t=… b=… mb=… fits=…`) and every exception — if anything
> is still off on your device, the log will name the exact culprit view for v0.7.

### Install (IMPORTANT — read fully)

1. **Fully uninstall** your current Instagram first. This includes:
   - any InstaTrueReel build (v0.1/v0.2),
   - the base Piko APK (`Instagram-v435.0.0.37.76-patches-v3.8.0.apk`),
   - any other modded Instagram.
   Android **silently refuses** to install an APK over an app signed with a different key —
   the installer says "App not installed" and the OLD app keeps running. This is the #1
   reason people see "no change": the old APK was still the one running.
2. Download the APK from the newest release **on your phone** and install it
   (allow "install unknown apps" for your browser/file manager).
3. Log in → open **Reels** (either the Reels tab or any reel post from the feed).

### Do I need to enable anything in Piko settings / developer options?

**No — and this is important:**

- The **gear icon** on the feed's top bar opens *Piko* settings (download patches, ad removal,
  etc.). It has **no** fullscreen/edge-to-edge option — Piko does not contain such a patch.
- **Long-pressing the home icon** opens Instagram's *native* Developer Options / Quick
  Experiments menu (unlocked by Piko). It has hundreds of QE flags but none of them are
  InstaTrueReel — do not hunt there.

InstaTrueReel is **raw smali patching, always-on, zero settings**. It activates automatically
the moment you enter Reels and deactivates when you leave.

**How to confirm you're really running v0.6:** every time you enter Reels, a small popup
message (a "toast") appears at the bottom of the screen:

```
InstaTrueReel v0.6: full-bleed everywhere ON
```

- **Toast shows + no black strip** → working.
- **Toast shows + still a black strip behind the status bar** → open an issue (a path we
  haven't covered yet).
- **No toast at all** → you are NOT running this build. The install failed or the old APK is
  still installed. Uninstall Instagram completely (check the app drawer — long-press →
  uninstall), reboot if in doubt, then install the v0.6 APK again.

Optional (advanced): run `adb logcat -s InstaTrueReel` while entering Reels — v0.6 logs
`apply: edge-to-edge engaged (fresh entry)`, `restore: ...`, and NEW per-view detail lines:

```
v0.6 deblock eval: pager=m=248 main=m=248
v0.6 liberate: android.widget.FrameLayout t=0 b=0 mb=0 fits=false
v0.6 liberate: X.1zY t=72 b=63 mb=0 fits=false     ← the containers it freed
v0.6 liberate: chain freed (n=5)
v0.6 restore-layout: chain restored (n=5)
```

If anything still looks off on your device, capture that log (it's small — no need for a
full 16 MB capture; `adb logcat -s InstaTrueReel` only logs our tag) and open an issue:
the `v0.6 liberate:` lines name the exact views involved, so v0.7 can patch the precise
culprit.

### What v0.3 changes

- **The core fix:** Instagram v435 already contains a complete, engineered edge-to-edge Reels
  mode, gated by a server-side experiment (`9Wz.EEr()` = `!A2g && (A3H || QE flag)`). When the
  flag is off, the Reels action-bar theme feeds `bds_black` into the window-chrome writer —
  that opaque status-bar scrim is the black strip you see (the media container itself is
  already full-screen: `layout_clips_viewer_fragment`'s ViewPager2 is `match_parent ×
  match_parent`). v0.3 forces `EEr() → true`, which turns on Instagram's own native mode:
  transparent status bar, overlays self-padded by status-bar height via window insets
  (exactly the TikTok model).
- Both entry points covered: the Reels tab delegates `AFt.EEr()` to the same `9Wz` fragment.
- Status-bar color interceptor (`X/1fC.A04`) kept — while Reels is showing, *every* status-bar
  repaint (including Instagram's Choreographer-deferred writes) is forced fully transparent.
- **New:** navigation-bar color interceptor (`X/1fI.A04`) — the bottom strip goes transparent
  too (was still black in v0.2).
- Delayed re-apply engine (100/400/1000/2500 ms) re-asserts the state against late writes.
- Toast + logcat verification markers on every Reels entry.
- Leaving Reels: interceptors deactivate, original window chrome is restored — feed, stories,
  DMs keep their normal look.

### Reporting issues

Open an issue on this repo with:
- Phone model + Android version + nav mode (gesture / 3-button)
- Whether the **toast** appeared when entering Reels
- What looks off: e.g. "top bar overlaps the clock", "feed also went edge-to-edge",
  "comment box sits too low/high", "video letterboxed instead of filling"
- Screenshot if possible

## 🔧 How it works (technical)

- Base APK: `Instagram-v435.0.0.37.76-patches-v3.8.0.apk` (251 MB, Git LFS) — Instagram
  435.0.0.37.76 patched with [crimera/piko](https://github.com/crimera/piko) v3.8.0 via the
  Morphe patcher (static smali patching, ReVanced-style — no runtime hooking, so our dex edits
  are live code).
- Reels viewer identified as `X/9Wz` (`ClipsViewerFragment`) and reels tab as `X/AFt`
  (`ClipsTabFragment`) via Redex `__redex_internal_original_name` metadata.
- **`9Wz.EEr()Z` method body replaced** with `const/4 v0, 0x1; return v0` — the native
  edge-to-edge master switch.
- New smali classes `X/TTrueReelHelper` (window state machine + interceptors + toast/log) and
  `X/TTrueReelReapply` (scheduled re-apply Runnable); hooks injected into
  `onResume` / `onPause` / `onDestroyView` / `onHiddenChanged` of both fragments.
- `X/1fC.A04` = the single choke point for ALL status-bar color writes (direct +
  Choreographer-deferred via `3mE`/`ktp`); `X/1fI.A04` = the navigation-bar twin. Both are
  intercepted at method entry with activity-scoped guards, active only while Reels is showing.
- v0.2's `X/1fC.A06` interceptor was dropped — full-tree scan shows A06 has zero callers in
  v435 (dead code).
- All injections are register-safe (`{p0, p1}` non-range where indices < 16,
  `invoke-static/range {p0 .. p0}` elsewhere) and idempotent (marker comments).
- Instagram's layout resources in this build are in compressed-blob format
  (`L|offset|len|hash`), so patches are **pure smali** — resources and manifest pass through
  untouched.

### Workflows

| Workflow | Purpose |
|---|---|
| `AnalyzeSmali.yml` | apktool decode (-r) + grep battery + full smali artifact for offline analysis |
| `BuildPatchedApk.yml` | decode → `patches/apply_patches.py` → apktool build → zipalign → apksigner → **final-APK verification** |

Run them from the **Actions** tab (workflow_dispatch).

### Repo layout

```
patches/
  apply_patches.py             # idempotent smali patcher v3 (19 verification checks)
  helper_TTrueReelHelper.smali # window edge-to-edge helper + interceptors + toast/log (smali)
  helper_TTrueReelReapply.smali# scheduled re-apply Runnable (smali)
signing/
  instatruereel.jks            # dedicated mod signing key (RSA-4096, PKCS12)
scripts/
  analyze.sh                   # grep battery used by AnalyzeSmali.yml
docs/
  ROADMAP.md                   # living plan + verified findings
```
