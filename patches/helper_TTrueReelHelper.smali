.class public final LX/TTrueReelHelper;
.super Ljava/lang/Object;
.source "TTrueReelHelper"


# static fields
.field public static A00:Landroid/view/Window;      # saved window while reels active
.field public static A01:I                          # saved statusBarColor
.field public static A02:I                          # saved navigationBarColor
.field public static A03:I                          # saved decor systemUiVisibility
.field public static A04:I                          # saved layoutInDisplayCutoutMode (API>=28)
.field public static A05:Z                          # ACTIVE flag (reels showing)
.field public static A07:Landroid/os/Handler;       # re-apply scheduler
.field public static A08:Ljava/lang/Runnable;       # re-apply runnable
.field public static A09:Landroid/app/Activity;     # saved activity (scope for interceptors)
.field public static A0A:I                          # saved bottomMargin: swipeable_tab_view_pager
.field public static A0B:I                          # saved bottomMargin: layout_container_main
.field public static A0C:Z                          # pager margin saved flag
.field public static A0E:Z                          # main container margin saved flag
.field public static A0F:Landroidx/fragment/app/Fragment;   # v0.6: current reels fragment (chain anchor)
.field public static A0G:Ljava/util/ArrayList;              # v0.6: saved chain states (LX/TTrueReelViewSave;)
.field public static A0H:Ljava/util/ArrayList;              # v0.7: gap-closed views (Landroid/view/View;)
.field public static A0I:Ljava/util/ArrayList;              # v0.7: saved heights (Ljava/lang/Integer;), parallel to A0H
.field public static A0J:I                                    # v0.7: A15 invocation counter (tree dump on 2nd call)
.field public static A0K:I                                    # v0.7: tree-dump line counter
.field public static A0L:Landroid/view/View;                   # v0.8: video container (extended to full height)
.field public static A0M:I                                     # v0.8: saved video LayoutParams.height
.field public static A0N:F                                     # v0.8: saved video weight (valid iff A0V)
.field public static A0O:Landroid/view/View;                   # v0.8: comment strip (overlaid)
.field public static A0P:F                                     # v0.8: saved strip translationY
.field public static A0Q:Ljava/util/ArrayList;                 # v0.8: strip direct-child views (cleared bgs)
.field public static A0R:Ljava/util/ArrayList;                 # v0.8: saved strip direct-child backgrounds
.field public static A0S:Landroid/graphics/drawable/Drawable;  # v0.8: saved strip background
.field public static A0T:Z                                     # v0.8: overlay applied flag
.field public static A0U:I                                     # v0.8: strip height (px)
.field public static A0V:Z                                     # v0.8: video weight saved flag
.field public static fsPill:Landroid/view/View;                # v0.9: "Full screen" pill (decor overlay)
.field public static fsExit:Landroid/view/View;                # v0.9: landscape exit button (decor overlay)
.field public static fsForced:Z                                # v0.9: landscape orientation currently forced
.field public static fsListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;  # v0.9: re-check listener
.field public static fsBest:Landroid/view/View;                # v0.9: DFS best (largest) video surface
.field public static fsBestArea:I                              # v0.9: DFS best area (px^2)
.field public static fsEngageAt:J                              # v0.9.1: uptimeMillis when landscape was engaged
.field public static fsNonLand:I                               # v0.9.1: consecutive non-landscape detections (auto-exit debounce)


# direct methods

# A00(Landroidx/fragment/app/Fragment;)V == APPLY TikTok-style edge-to-edge to the activity window.
# v0.6: additionally anchors the fragment (for the chain-liberation walk in A09) and re-inits the
# chain-save list on every fresh entry. All failures are logged, never silent.
.method public static A00(Landroidx/fragment/app/Fragment;)V
    .locals 6

    :try_start_0
    sget-object v0, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    if-nez v0, :cond_active

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getActivity()Landroidx/fragment/app/FragmentActivity;
    move-result-object v4
    if-eqz v4, :cond_skip

    invoke-virtual {v4}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    if-eqz v0, :cond_skip

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_skip

    # ---- save original window state ----
    invoke-virtual {v0}, Landroid/view/Window;->getStatusBarColor()I
    move-result v2
    sput v2, LX/TTrueReelHelper;->A01:I

    invoke-virtual {v0}, Landroid/view/Window;->getNavigationBarColor()I
    move-result v2
    sput v2, LX/TTrueReelHelper;->A02:I

    invoke-virtual {v1}, Landroid/view/View;->getSystemUiVisibility()I
    move-result v2
    sput v2, LX/TTrueReelHelper;->A03:I

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1c
    if-lt v2, v3, :cond_skip_save_cutout
    invoke-virtual {v0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    iget v2, v2, Landroid/view/WindowManager$LayoutParams;->layoutInDisplayCutoutMode:I
    sput v2, LX/TTrueReelHelper;->A04:I
    :cond_skip_save_cutout

    sput-object v0, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    sput-object v4, LX/TTrueReelHelper;->A09:Landroid/app/Activity;

    # ---- apply edge-to-edge core (flags + transparent bars) ----
    invoke-static {v0}, LX/TTrueReelHelper;->A06(Landroid/view/Window;)V

    # ---- v0.6: fresh chain-save list + fragment anchor ----
    # ---- v0.7: fresh gap-closure save lists + counter reset ----
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0G:Ljava/util/ArrayList;
    sput-object p0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0H:Ljava/util/ArrayList;
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0I:Ljava/util/ArrayList;
    const/4 v0, 0x0
    sput v0, LX/TTrueReelHelper;->A0J:I

    # ---- v0.8: clean slate for the strip overlay ----
    invoke-static {}, LX/TTrueReelHelper;->A1B()V

    # ---- de-block bottom layout (specific known containers, with diagnostics) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A08(Landroid/app/Activity;)V

    # ---- v0.6: chain liberation (modal root + every container bounding the video) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A09(Landroid/app/Activity;)V

    # ---- confirmation toast on every fresh reels entry ----
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getActivity()Landroidx/fragment/app/FragmentActivity;
    move-result-object v0
    if-eqz v0, :cond_no_toast
    const-string v1, "InstaTrueReel v0.9.1: fullscreen ON"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :cond_no_toast

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 apply: edge-to-edge + fullscreen armed"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_active
    # ---- mark ACTIVE (enables 1fC/1fI + tab-bar interceptors) ----
    const/4 v0, 0x1
    sput-boolean v0, LX/TTrueReelHelper;->A05:Z

    # ---- schedule delayed re-applies ----
    invoke-static {}, LX/TTrueReelHelper;->A05()V

    :cond_skip
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 apply: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void
.end method


# A01(Landroidx/fragment/app/Fragment;)V == RESTORE original window state + layout.
# v0.9.1: TRANSIENT-ROTATION GUARD - while landscape fullscreen is active the forced
# rotation makes Instagram deliver onConfigurationChanged + a fragment pause/resume
# flap (its FixedOrientationCompat re-asserts portrait on every config delivery and
# the pager re-runs lifecycle). That pause is NOT a reels exit: if it is the SAME
# activity, the activity is not finishing, and we engaged landscape less than 1500ms
# ago, the restore is SKIPPED so the fullscreen state survives the rotation.
.method public static A01(Landroidx/fragment/app/Fragment;)V
    .locals 5

    :try_start_0
    # ---- v0.9.1: transient-rotation guard ----
    sget-boolean v0, LX/TTrueReelHelper;->fsForced:Z
    if-eqz v0, :itr_full_restore
    sget-object v1, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v1, :itr_full_restore
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getActivity()Landroidx/fragment/app/FragmentActivity;
    move-result-object v2
    if-ne v2, v1, :itr_full_restore
    invoke-virtual {v1}, Landroid/app/Activity;->isFinishing()Z
    move-result v2
    if-nez v2, :itr_full_restore
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    sget-wide v0, LX/TTrueReelHelper;->fsEngageAt:J
    sub-long/2addr v2, v0
    const-wide/16 v0, 0x5dc
    cmp-long v4, v2, v0
    if-ltz v4, :itr_transient_skip

    :itr_full_restore
    # ---- deactivate interceptors FIRST ----
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A05:Z

    # ---- v0.9: fullscreen cleanup (orientation + buttons + listener) ----
    invoke-static {}, LX/TTrueReelHelper;->A27()V

    # ---- cancel pending re-applies ----
    sget-object v0, LX/TTrueReelHelper;->A07:Landroid/os/Handler;
    if-eqz v0, :cond_no_cancel
    sget-object v1, LX/TTrueReelHelper;->A08:Ljava/lang/Runnable;
    if-eqz v1, :cond_no_cancel
    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    :cond_no_cancel

    # ---- drop runnable window/activity refs ----
    sget-object v1, LX/TTrueReelHelper;->A08:Ljava/lang/Runnable;
    if-eqz v1, :cond_no_clear
    check-cast v1, LX/TTrueReelReapply;
    const/4 v2, 0x0
    iput-object v2, v1, LX/TTrueReelReapply;->A00:Landroid/view/Window;
    iput-object v2, v1, LX/TTrueReelReapply;->A01:Landroid/app/Activity;
    :cond_no_clear

    # ---- v0.6: restore layout (liberated chain + deblocked margins) ----
    sget-object v3, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v3, :cond_no_layout_restore
    invoke-static {v3}, LX/TTrueReelHelper;->A10(Landroid/app/Activity;)V
    :cond_no_layout_restore

    # ---- v0.6: drop the fragment anchor ----
    const/4 v3, 0x0
    sput-object v3, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;

    sget-object v0, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    if-eqz v0, :cond_done

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_reset

    sget v2, LX/TTrueReelHelper;->A03:I
    invoke-virtual {v1, v2}, Landroid/view/View;->setSystemUiVisibility(I)V

    sget v2, LX/TTrueReelHelper;->A01:I
    invoke-virtual {v0, v2}, Landroid/view/Window;->setStatusBarColor(I)V

    sget v2, LX/TTrueReelHelper;->A02:I
    invoke-virtual {v0, v2}, Landroid/view/Window;->setNavigationBarColor(I)V

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1c
    if-lt v2, v3, :cond_skip_cutout
    invoke-virtual {v0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    sget v3, LX/TTrueReelHelper;->A04:I
    iput v3, v2, Landroid/view/WindowManager$LayoutParams;->layoutInDisplayCutoutMode:I
    invoke-virtual {v0, v2}, Landroid/view/Window;->setAttributes(Landroid/view/WindowManager$LayoutParams;)V
    :cond_skip_cutout

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1d
    if-lt v2, v3, :cond_skip_contrast
    const/4 v2, 0x1
    invoke-virtual {v0, v2}, Landroid/view/Window;->setStatusBarContrastEnforced(Z)V
    invoke-virtual {v0, v2}, Landroid/view/Window;->setNavigationBarContrastEnforced(Z)V
    :cond_skip_contrast

    invoke-virtual {v1}, Landroid/view/View;->requestApplyInsets()V

    const-string v2, "InstaTrueReel"
    const-string v3, "v0.9 restore: window chrome + layout restored"
    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_reset
    const/4 v2, 0x0
    sput-object v2, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    sput-object v2, LX/TTrueReelHelper;->A09:Landroid/app/Activity;

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 restore: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void

    :itr_transient_skip
    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 restore skipped (fs transient)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method


# A02(Landroidx/fragment/app/Fragment;Z)V == onHiddenChanged bridge.
.method public static A02(Landroidx/fragment/app/Fragment;Z)V
    .locals 0

    if-eqz p1, :cond_show
    invoke-static {p0}, LX/TTrueReelHelper;->A2F(Landroidx/fragment/app/Fragment;)V
    return-void

    :cond_show
    invoke-static {p0}, LX/TTrueReelHelper;->A00(Landroidx/fragment/app/Fragment;)V
    return-void
.end method


# A03(Landroid/app/Activity;I)I == status-bar-color interceptor for X/1fC.A04.
.method public static A03(Landroid/app/Activity;I)I
    .locals 1

    sget-boolean v0, LX/TTrueReelHelper;->A05:Z
    if-eqz v0, :cond_pass

    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :cond_pass
    if-ne v0, p0, :cond_pass

    const/4 v0, 0x0
    return v0

    :cond_pass
    return p1
.end method


# A07(Landroid/app/Activity;I)I == navigation-bar-color interceptor for X/1fI.A04.
.method public static A07(Landroid/app/Activity;I)I
    .locals 1

    sget-boolean v0, LX/TTrueReelHelper;->A05:Z
    if-eqz v0, :cond_pass

    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :cond_pass
    if-ne v0, p0, :cond_pass

    const/4 v0, 0x0
    return v0

    :cond_pass
    return p1
.end method


# A05()V == schedule delayed re-applies on the main thread (100/400/1000/2500/5000 ms).
.method public static A05()V
    .locals 4

    :try_start_0
    # ---- v0.9: attach the fullscreen re-check listener (idempotent) ----
    sget-object v0, LX/TTrueReelHelper;->fsListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;
    if-nez v0, :cond_no_attach
    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :cond_no_attach
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_no_attach
    invoke-virtual {v1}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v2
    if-eqz v2, :cond_no_attach
    new-instance v0, LX/TTrueReelRecheck;
    invoke-direct {v0}, LX/TTrueReelRecheck;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->fsListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;
    invoke-virtual {v2, v0}, Landroid/view/ViewTreeObserver;->addOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V
    :cond_no_attach
    sget-object v0, LX/TTrueReelHelper;->A07:Landroid/os/Handler;
    if-nez v0, :cond_have_handler
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v0
    new-instance v1, Landroid/os/Handler;
    invoke-direct {v1, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    sput-object v1, LX/TTrueReelHelper;->A07:Landroid/os/Handler;
    sget-object v0, LX/TTrueReelHelper;->A07:Landroid/os/Handler;
    :cond_have_handler

    sget-object v1, LX/TTrueReelHelper;->A08:Ljava/lang/Runnable;
    if-nez v1, :cond_have_runnable
    new-instance v1, LX/TTrueReelReapply;
    invoke-direct {v1}, LX/TTrueReelReapply;-><init>()V
    sput-object v1, LX/TTrueReelHelper;->A08:Ljava/lang/Runnable;
    :cond_have_runnable

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    check-cast v1, LX/TTrueReelReapply;
    sget-object v2, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    iput-object v2, v1, LX/TTrueReelReapply;->A00:Landroid/view/Window;
    sget-object v2, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    iput-object v2, v1, LX/TTrueReelReapply;->A01:Landroid/app/Activity;

    const-wide/16 v2, 0x64
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    const-wide/16 v2, 0x190
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    const-wide/16 v2, 0x3e8
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    const-wide/16 v2, 0x9c4
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    const-wide/16 v2, 0x1388
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 schedule: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A06(Landroid/view/Window;)V == REAPPLY core (idempotent, no state save).
.method public static A06(Landroid/view/Window;)V
    .locals 4

    :try_start_0
    if-eqz p0, :cond_done

    invoke-virtual {p0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done

    # vis = vis | 0x700 & ~LIGHT_STATUS_BAR(0x2000) & ~LIGHT_NAVIGATION_BAR(0x10)
    invoke-virtual {v1}, Landroid/view/View;->getSystemUiVisibility()I
    move-result v2
    or-int/lit16 v2, v2, 0x700
    const v3, -0x2001
    and-int/2addr v2, v3
    and-int/lit8 v2, v2, -0x11
    invoke-virtual {v1, v2}, Landroid/view/View;->setSystemUiVisibility(I)V

    # fully transparent status + nav bar
    const/4 v2, 0x0
    invoke-virtual {p0, v2}, Landroid/view/Window;->setStatusBarColor(I)V
    invoke-virtual {p0, v2}, Landroid/view/Window;->setNavigationBarColor(I)V

    # clear legacy translucent bar flags, add DRAWS_SYSTEM_BAR_BACKGROUNDS
    const v2, 0xc000000
    invoke-virtual {p0, v2}, Landroid/view/Window;->clearFlags(I)V
    const/high16 v2, -0x80000000
    invoke-virtual {p0, v2}, Landroid/view/Window;->addFlags(I)V

    # cutout mode SHORT_EDGES (=1) on API >= 28
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1c
    if-lt v2, v3, :cond_skip_cutout
    invoke-virtual {p0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    const/4 v3, 0x1
    iput v3, v2, Landroid/view/WindowManager$LayoutParams;->layoutInDisplayCutoutMode:I
    invoke-virtual {p0, v2}, Landroid/view/Window;->setAttributes(Landroid/view/WindowManager$LayoutParams;)V
    :cond_skip_cutout

    # disable contrast scrims on API >= 29
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x1d
    if-lt v2, v3, :cond_skip_contrast
    const/4 v2, 0x0
    invoke-virtual {p0, v2}, Landroid/view/Window;->setStatusBarContrastEnforced(Z)V
    invoke-virtual {p0, v2}, Landroid/view/Window;->setNavigationBarContrastEnforced(Z)V
    :cond_skip_contrast

    invoke-virtual {v1}, Landroid/view/View;->requestApplyInsets()V

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 chrome: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A08(Landroid/app/Activity;)V == DE-BLOCK BOTTOM LAYOUT (specific known containers).
# v0.6: logs an eval line on EVERY call (pager/main margin or null) so field logs prove
# whether these ids resolve at all in the running view tree. Zeroes bottomMargin of
# swipeable_tab_view_pager (0x7f0b3f45) and layout_container_main (0x7f0b2246) while
# reels is active. Saves originals once; A10 restores.
.method public static A08(Landroid/app/Activity;)V
    .locals 6

    :try_start_0
    if-eqz p0, :cond_done

    # ---- eval diagnostics ----
    const v0, 0x7f0b3f45
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    invoke-static {v0}, LX/TTrueReelHelper;->A14(Landroid/view/View;)Ljava/lang/String;
    move-result-object v1

    const v2, 0x7f0b2246
    invoke-virtual {p0, v2}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v2
    invoke-static {v2}, LX/TTrueReelHelper;->A14(Landroid/view/View;)Ljava/lang/String;
    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "v0.6 deblock eval: pager="
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    const-string v4, " main="
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    const-string v4, "InstaTrueReel"
    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    # ---- swipeable_tab_view_pager ----
    const v0, 0x7f0b3f45
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_main
    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v1
    if-eqz v1, :cond_main
    instance-of v5, v1, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v5, :cond_main
    check-cast v1, Landroid/view/ViewGroup$MarginLayoutParams;

    sget-boolean v5, LX/TTrueReelHelper;->A0C:Z
    if-nez v5, :cond_pager_saved
    iget v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    sput v2, LX/TTrueReelHelper;->A0A:I
    const/4 v5, 0x1
    sput-boolean v5, LX/TTrueReelHelper;->A0C:Z
    :cond_pager_saved

    iget v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    if-eqz v2, :cond_main
    const/4 v2, 0x0
    iput v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V
    const-string v3, "InstaTrueReel"
    const-string v4, "v0.6 deblock: viewpager bottomMargin -> 0"
    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :cond_main

    # ---- layout_container_main ----
    const v0, 0x7f0b2246
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v1
    if-eqz v1, :cond_done
    instance-of v5, v1, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v5, :cond_done
    check-cast v1, Landroid/view/ViewGroup$MarginLayoutParams;

    sget-boolean v5, LX/TTrueReelHelper;->A0E:Z
    if-nez v5, :cond_main_saved
    iget v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    sput v2, LX/TTrueReelHelper;->A0B:I
    const/4 v5, 0x1
    sput-boolean v5, LX/TTrueReelHelper;->A0E:Z
    :cond_main_saved

    iget v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    if-eqz v2, :cond_done
    const/4 v2, 0x0
    iput v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V
    const-string v3, "InstaTrueReel"
    const-string v4, "v0.6 deblock: main container bottomMargin -> 0"
    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.6 deblock: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A09(Landroid/app/Activity;)V == v0.6 CHAIN LIBERATION.
# Walks from the reels fragment's own view UP the parent chain to the decor view.
# For every ancestor ViewGroup: save its state (padding, bottomMargin, fitsSystemWindows)
# into A0G (once), then zero top/bottom padding + bottomMargin and turn fitsSystemWindows
# off while reels is active. This single mechanism covers:
#   * ModalActivity's layout_container_parent (fitsSystemWindows=true root padding ->
#     the Watch History / Likes black strip),
#   * the MainTabActivity feed-overlay bounding containers (bottom margins),
#   * the reels-tab chain.
# A10 restores everything on exit. Every action is logged with full detail; the walk
# re-runs on every re-apply tick (100/400/1000/2500/5000 ms) so late re-blocks by
# Instagram are re-liberated.
.method public static A09(Landroid/app/Activity;)V
    .locals 7

    :try_start_0
    if-eqz p0, :cond_done

    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :cond_no_frag
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_no_frag

    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v1
    if-eqz v1, :cond_done
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1

    sget-object v3, LX/TTrueReelHelper;->A0G:Ljava/util/ArrayList;
    if-eqz v3, :cond_done

    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v2

    const/4 v5, 0x0

    :itr_loop_head
    if-eqz v2, :itr_loop_end
    if-ne v2, v1, :itr_chk_group
    goto :itr_loop_end

    :itr_chk_group
    instance-of v4, v2, Landroid/view/ViewGroup;
    if-eqz v4, :itr_loop_end
    check-cast v2, Landroid/view/ViewGroup;

    invoke-static {v2, v3}, LX/TTrueReelHelper;->A11(Landroid/view/View;Ljava/util/ArrayList;)Z
    move-result v4
    if-eqz v4, :itr_not_new
    add-int/lit8 v5, v5, 0x1
    :itr_not_new

    invoke-virtual {v2}, Landroid/view/ViewGroup;->getParent()Landroid/view/ViewParent;
    move-result-object v2
    goto :itr_loop_head

    :itr_loop_end
    if-lez v5, :cond_no_change
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V

    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "v0.7 liberate: chain freed (n="
    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v2
    const-string v4, ")"
    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v4, "InstaTrueReel"
    invoke-static {v4, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_no_change
    # ---- v0.7: bottom-gap closure (height surgery, top-down) ----
    invoke-static {p0}, LX/TTrueReelHelper;->A15(Landroid/app/Activity;)V
    goto :cond_done

    :cond_no_frag
    const-string v2, "InstaTrueReel"
    const-string v4, "v0.7 liberate: no fragment view (skip)"
    invoke-static {v2, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 liberate: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A15(Landroid/app/Activity;)V == v0.7 BOTTOM-GAP CLOSURE.
# v0.6 proved every ancestor's bottom padding/margin is already zero - the remaining
# bound on the video is structural: some container in the chain is simply SHORTER
# than its parent (LayoutParams.height or measurement). This walk collects the same
# ancestor chain (fragment view -> decor), then iterates it TOP-DOWN (decor-most
# first) and for every view whose bottom edge falls short of its parent's content
# bottom, sets LayoutParams.height to exactly reach it (FrameLayout-family parents
# only; RecyclerView parents control child bounds and ConstraintLayout parents use
# constraint anchors - both skipped but logged). Original heights are saved once
# (A0H views / A0I boxed Integers) and restored by A10. Because height changes
# settle on the NEXT layout pass, the re-apply ticks (100/400/1000/2500/5000 ms)
# cascade the closure down the chain level by level. On the 2nd invocation (the
# +100 ms re-apply tick, when the overlay is laid out) a one-shot bottom-strip tree
# dump (A17) logs every view in the bottom 35% of the screen - so if anything is
# still bounded, the culprit view is NAMED in the log for a surgical v0.8.
.method public static A15(Landroid/app/Activity;)V
    .locals 8

    :try_start_0
    if-eqz p0, :cond_done

    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_done

    sget-object v1, LX/TTrueReelHelper;->A0H:Ljava/util/ArrayList;
    if-eqz v1, :cond_done
    sget-object v2, LX/TTrueReelHelper;->A0I:Ljava/util/ArrayList;
    if-eqz v2, :cond_done

    # ---- one-shot tree dump on the 2nd invocation (+100 ms re-apply tick) ----
    sget v3, LX/TTrueReelHelper;->A0J:I
    add-int/lit8 v3, v3, 0x1
    sput v3, LX/TTrueReelHelper;->A0J:I
    const/4 v4, 0x2
    if-ne v3, v4, :cond_no_dump
    invoke-static {p0}, LX/TTrueReelHelper;->A17(Landroid/app/Activity;)V
    :cond_no_dump

    # ---- collect the ancestor chain (fragment view -> decor) ----
    new-instance v3, Ljava/util/ArrayList;
    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v5

    :walk_head
    if-eqz v5, :walk_end
    instance-of v6, v5, Landroid/view/ViewGroup;
    if-eqz v6, :walk_end
    check-cast v5, Landroid/view/ViewGroup;
    invoke-virtual {v3, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    invoke-virtual {v5}, Landroid/view/ViewGroup;->getParent()Landroid/view/ViewParent;
    move-result-object v5
    goto :walk_head
    :walk_end

    # ---- iterate top-down (decor-most first) and close bottom gaps ----
    const/4 v5, 0x0
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I
    move-result v6

    :close_head
    if-lez v6, :close_end
    add-int/lit8 v6, v6, -0x1
    invoke-virtual {v3, v6}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/view/View;
    invoke-static {v0, v1, v2}, LX/TTrueReelHelper;->A16(Landroid/view/View;Ljava/util/ArrayList;Ljava/util/ArrayList;)Z
    move-result v7
    if-eqz v7, :close_next
    add-int/lit8 v5, v5, 0x1
    :close_next
    goto :close_head
    :close_end

    if-lez v5, :cond_no_log

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "v0.7 gaps closed (n="
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v4, ")"
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v4, "InstaTrueReel"
    invoke-static {v4, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_no_log

    # ---- v0.8: comment-strip overlay (bottom bar -> floating overlay) ----
    invoke-static {p0}, LX/TTrueReelHelper;->A19(Landroid/app/Activity;)V

    # ---- v0.9: TikTok-style fullscreen orchestrator (pill / landscape state) ----
    invoke-static {p0}, LX/TTrueReelHelper;->A20(Landroid/app/Activity;)V

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 gaps: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A16(Landroid/view/View;Ljava/util/ArrayList;Ljava/util/ArrayList;)Z == close ONE view's bottom gap.
# p0 = view, p1 = saved-views list, p2 = saved-heights list. Returns true when a gap
# was (re-)closed. Skips (with a log) RecyclerView parents (they control child bounds)
# and ConstraintLayout parents (constraint-anchored children need v0.8 surgery).
.method public static A16(Landroid/view/View;Ljava/util/ArrayList;Ljava/util/ArrayList;)Z
    .locals 9

    :try_start_0
    if-eqz p0, :ret_false

    # ---- parent must be a ViewGroup ----
    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    if-eqz v0, :ret_false
    instance-of v1, v0, Landroid/view/ViewGroup;
    if-eqz v1, :ret_false
    check-cast v0, Landroid/view/ViewGroup;

    # ---- skip RecyclerView parents ----
    instance-of v1, v0, Landroidx/recyclerview/widget/RecyclerView;
    if-eqz v1, :not_rv
    const-string v1, "InstaTrueReel"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "v0.7 close: skip-rv "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    goto :ret_false
    :not_rv

    # ---- skip ConstraintLayout parents ----
    instance-of v1, v0, Landroidx/constraintlayout/widget/ConstraintLayout;
    if-eqz v1, :not_cl
    const-string v1, "InstaTrueReel"
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "v0.7 close: cl-skip "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    goto :ret_false
    :not_cl

    # ---- gap = parent content bottom - view bottom edge ----
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getHeight()I
    move-result v1
    if-lez v1, :ret_false
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getPaddingBottom()I
    move-result v2
    sub-int/2addr v1, v2

    invoke-virtual {p0}, Landroid/view/View;->getTop()I
    move-result v2
    invoke-virtual {p0}, Landroid/view/View;->getHeight()I
    move-result v3
    add-int v4, v2, v3
    sub-int v5, v1, v4

    const/4 v6, 0x2
    if-le v5, v6, :ret_false

    # ---- layout params ----
    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v6
    if-eqz v6, :ret_false

    # ---- save original height once (identity scan) ----
    const/4 v7, 0x0
    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I
    move-result v8
    :scan_head
    if-ge v7, v8, :scan_end
    invoke-virtual {p1, v7}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v2
    if-ne v2, p0, :scan_next
    goto :have_saved
    :scan_next
    add-int/lit8 v7, v7, 0x1
    goto :scan_head
    :scan_end
    iget v2, v6, Landroid/view/ViewGroup$LayoutParams;->height:I
    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-virtual {p1, p0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    invoke-virtual {p2, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :have_saved

    # ---- set exact height reaching the parent's content bottom ----
    invoke-virtual {p0}, Landroid/view/View;->getTop()I
    move-result v2
    sub-int v3, v1, v2
    iget v4, v6, Landroid/view/ViewGroup$LayoutParams;->height:I
    iput v3, v6, Landroid/view/ViewGroup$LayoutParams;->height:I
    invoke-virtual {p0}, Landroid/view/View;->requestLayout()V

    # ---- log ----
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "v0.7 close: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " h="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, "->"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " gap="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "InstaTrueReel"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v0, 0x1
    return v0

    :ret_false
    const/4 v0, 0x0
    return v0
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 close: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v0, 0x0
    return v0
.end method


# A11(Landroid/view/View;Ljava/util/ArrayList;)Z == liberate ONE ancestor view.
# v0.7: the detail line now carries h=<height> ph=<parentHeight> so a single field
# log names every SHORT container in the chain (the v0.6 line proved paddings are
# zero everywhere - heights are what matter now).
# If the view already has a saved entry: re-assert the zeros (Instagram may have
# re-blocked it since) and return false. Otherwise: capture original state, store a
# TTrueReelViewSave, zero it, log the detail line, return true.
.method public static A11(Landroid/view/View;Ljava/util/ArrayList;)Z
    .locals 10

    # ---- scan for an existing save (identity) ----
    const/4 v0, 0x0
    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I
    move-result v1
    :itr_scan
    if-ge v0, v1, :itr_scan_end
    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, LX/TTrueReelViewSave;
    iget-object v3, v2, LX/TTrueReelViewSave;->A00:Landroid/view/View;
    if-ne v3, p0, :itr_scan_next

    invoke-static {p0}, LX/TTrueReelHelper;->A12(Landroid/view/View;)V
    const/4 v0, 0x0
    return v0

    :itr_scan_next
    add-int/lit8 v0, v0, 0x1
    goto :itr_scan

    :itr_scan_end
    # ---- capture originals ----
    move-object v3, p0
    invoke-virtual {v3}, Landroid/view/View;->getPaddingTop()I
    move-result v4
    invoke-virtual {v3}, Landroid/view/View;->getPaddingBottom()I
    move-result v5
    invoke-static {v3}, LX/TTrueReelHelper;->A13(Landroid/view/View;)I
    move-result v6

    const/4 v7, 0x0
    :try_start_fits
    invoke-virtual {v3}, Landroid/view/View;->getFitsSystemWindows()Z
    move-result v7
    :try_end_fits
    .catch Ljava/lang/Throwable; {:try_start_fits .. :try_end_fits} :catch_fits
    goto :itr_fits_ok

    :catch_fits
    # hidden-API fallback heuristic: insets-derived padding present => was fits=true
    if-lez v4, :itr_fits_chk_bottom
    const/4 v7, 0x1
    goto :itr_fits_ok
    :itr_fits_chk_bottom
    if-lez v5, :itr_fits_ok
    const/4 v7, 0x1

    :itr_fits_ok
    # ---- store the save entry ----
    new-instance v2, LX/TTrueReelViewSave;
    invoke-direct/range {v2 .. v7}, LX/TTrueReelViewSave;-><init>(Landroid/view/View;IIIZ)V
    invoke-virtual {p1, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    # ---- zero it ----
    invoke-static {v3}, LX/TTrueReelHelper;->A12(Landroid/view/View;)V

    # ---- v0.7: height telemetry (h + parent height) ----
    invoke-virtual {v3}, Landroid/view/View;->getHeight()I
    move-result v8

    const/4 v9, -0x1
    invoke-virtual {v3}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    instance-of v1, v0, Landroid/view/ViewGroup;
    if-eqz v1, :ph_done
    check-cast v0, Landroid/view/ViewGroup;
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getHeight()I
    move-result v9
    :ph_done

    # ---- log the detail ----
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "v0.7 liberate: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " t="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " b="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " mb="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " fits="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " h="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " ph="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "InstaTrueReel"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v0, 0x1
    return v0
.end method


# A12(Landroid/view/View;)V == zero ONE view for full-bleed:
# fitsSystemWindows(false), top/bottom padding -> 0 (left/right kept), bottomMargin -> 0.
.method public static A12(Landroid/view/View;)V
    .locals 4

    const/4 v2, 0x0
    invoke-virtual {p0, v2}, Landroid/view/View;->setFitsSystemWindows(Z)V

    invoke-virtual {p0}, Landroid/view/View;->getPaddingLeft()I
    move-result v0
    invoke-virtual {p0}, Landroid/view/View;->getPaddingRight()I
    move-result v1
    invoke-virtual {p0, v0, v2, v1, v2}, Landroid/view/View;->setPadding(IIII)V

    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v3
    if-eqz v3, :cond_done
    instance-of v2, v3, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v2, :cond_done
    check-cast v3, Landroid/view/ViewGroup$MarginLayoutParams;
    const/4 v2, 0x0
    iput v2, v3, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {p0}, Landroid/view/View;->requestLayout()V

    :cond_done
    return-void
.end method


# A13(Landroid/view/View;)I == read bottomMargin (or -1 when absent).
.method public static A13(Landroid/view/View;)I
    .locals 2

    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v0
    if-eqz v0, :itr_none
    instance-of v1, v0, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v1, :itr_none
    check-cast v0, Landroid/view/ViewGroup$MarginLayoutParams;
    iget v0, v0, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    return v0

    :itr_none
    const/4 v0, -0x1
    return v0
.end method


# A14(Landroid/view/View;)Ljava/lang/String; == "m=<bottomMargin>" or "null" (eval logging).
.method public static A14(Landroid/view/View;)Ljava/lang/String;
    .locals 3

    if-eqz p0, :itr_null

    invoke-static {p0}, LX/TTrueReelHelper;->A13(Landroid/view/View;)I
    move-result v0

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "m="
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    return-object v1

    :itr_null
    const-string v1, "null"
    return-object v1
.end method


# A10(Landroid/app/Activity;)V == RESTORE LAYOUT (called from A01).
# v0.6: restores every liberated chain view from A0G (padding, bottomMargin,
# fitsSystemWindows), re-dispatches insets, then restores the two deblocked
# bottom margins from v0.5.
# v0.7: FIRST restores every gap-closed height from A0H/A0I (parallel lists).
.method public static A10(Landroid/app/Activity;)V
    .locals 10

    :try_start_0
    if-eqz p0, :cond_done

    # ---- v0.8: restore the comment-strip overlay FIRST ----
    invoke-static {}, LX/TTrueReelHelper;->A1B()V

    # ---- v0.7: restore the gap-closed heights ----
    sget-object v0, LX/TTrueReelHelper;->A0H:Ljava/util/ArrayList;
    if-eqz v0, :cond_no_heights
    sget-object v1, LX/TTrueReelHelper;->A0I:Ljava/util/ArrayList;
    if-eqz v1, :cond_no_heights
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I
    move-result v2
    if-lez v2, :cond_heights_clear

    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "v0.7 restore-layout: heights restored (n="
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v3
    const-string v4, ")"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    const-string v4, "InstaTrueReel"
    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v3, 0x0
    :heights_loop
    if-ge v3, v2, :heights_end
    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/view/View;
    if-eqz v4, :heights_next
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Ljava/lang/Integer;
    if-eqz v5, :heights_next
    invoke-virtual {v5}, Ljava/lang/Integer;->intValue()I
    move-result v6
    invoke-virtual {v4}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v7
    if-eqz v7, :heights_next
    iput v6, v7, Landroid/view/ViewGroup$LayoutParams;->height:I
    invoke-virtual {v4}, Landroid/view/View;->requestLayout()V
    :heights_next
    add-int/lit8 v3, v3, 0x1
    goto :heights_loop
    :heights_end

    :cond_heights_clear
    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V
    if-eqz v1, :cond_no_heights
    invoke-virtual {v1}, Ljava/util/ArrayList;->clear()V
    :cond_no_heights

    # ---- v0.6: restore the liberated chain ----
    sget-object v0, LX/TTrueReelHelper;->A0G:Ljava/util/ArrayList;
    if-eqz v0, :cond_no_chain
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I
    move-result v1
    if-lez v1, :cond_no_chain

    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "v0.6 restore-layout: chain restored (n="
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v2
    const-string v3, ")"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "InstaTrueReel"
    invoke-static {v3, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v2, 0x0
    :itr_chain_loop
    if-ge v2, v1, :itr_chain_end
    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, LX/TTrueReelViewSave;
    iget-object v4, v3, LX/TTrueReelViewSave;->A00:Landroid/view/View;
    if-eqz v4, :itr_chain_next

    iget-boolean v9, v3, LX/TTrueReelViewSave;->A04:Z
    invoke-virtual {v4, v9}, Landroid/view/View;->setFitsSystemWindows(Z)V

    invoke-virtual {v4}, Landroid/view/View;->getPaddingLeft()I
    move-result v5
    invoke-virtual {v4}, Landroid/view/View;->getPaddingRight()I
    move-result v6
    iget v7, v3, LX/TTrueReelViewSave;->A01:I
    iget v8, v3, LX/TTrueReelViewSave;->A02:I
    invoke-virtual {v4, v5, v7, v6, v8}, Landroid/view/View;->setPadding(IIII)V

    iget v9, v3, LX/TTrueReelViewSave;->A03:I
    if-gez v9, :itr_chk_lp
    goto :itr_margin_done

    :itr_chk_lp
    invoke-virtual {v4}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v5
    if-eqz v5, :itr_margin_done
    instance-of v6, v5, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v6, :itr_margin_done
    check-cast v5, Landroid/view/ViewGroup$MarginLayoutParams;
    iput v9, v5, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I

    :itr_margin_done
    invoke-virtual {v4}, Landroid/view/View;->requestLayout()V

    :itr_chain_next
    add-int/lit8 v2, v2, 0x1
    goto :itr_chain_loop

    :itr_chain_end
    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v2
    if-eqz v2, :cond_no_chain
    invoke-virtual {v2}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v2
    if-eqz v2, :cond_no_chain
    invoke-virtual {v2}, Landroid/view/View;->requestApplyInsets()V
    :cond_no_chain

    # ---- restore viewpager bottomMargin ----
    sget-boolean v2, LX/TTrueReelHelper;->A0C:Z
    if-eqz v2, :cond_no_pager
    const v2, 0x7f0b3f45
    invoke-virtual {p0, v2}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_pager_reset
    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v1
    if-eqz v1, :cond_pager_reset
    instance-of v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v2, :cond_pager_reset
    check-cast v1, Landroid/view/ViewGroup$MarginLayoutParams;
    sget v2, LX/TTrueReelHelper;->A0A:I
    iput v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V
    :cond_pager_reset
    const/4 v2, 0x0
    sput-boolean v2, LX/TTrueReelHelper;->A0C:Z
    :cond_no_pager

    # ---- restore main container bottomMargin ----
    sget-boolean v2, LX/TTrueReelHelper;->A0E:Z
    if-eqz v2, :cond_no_main
    const v2, 0x7f0b2246
    invoke-virtual {p0, v2}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_main_reset
    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v1
    if-eqz v1, :cond_main_reset
    instance-of v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v2, :cond_main_reset
    check-cast v1, Landroid/view/ViewGroup$MarginLayoutParams;
    sget v2, LX/TTrueReelHelper;->A0B:I
    iput v2, v1, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V
    :cond_main_reset
    const/4 v2, 0x0
    sput-boolean v2, LX/TTrueReelHelper;->A0E:Z
    :cond_no_main

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.6 restore-layout: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A17(Landroid/app/Activity;)V == v0.7 ONE-SHOT BOTTOM-STRIP TREE DUMP (entry).
# Dumps every view whose absolute bottom edge lies in the bottom 35% of the screen:
# class, resource id, absolute y-range, width, height. This names the comment-bar
# pill container, every wrapper around it and every bounded container in one shot -
# if the gap closure misses anything, the next field log pins the culprit for v0.8.
# Line-capped at 260 entries (A0K) so the log stays small.
.method public static A17(Landroid/app/Activity;)V
    .locals 5

    :try_start_0
    if-eqz p0, :cond_done

    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v0
    if-eqz v0, :cond_done
    instance-of v1, v0, Landroid/view/ViewGroup;
    if-eqz v1, :cond_done
    check-cast v0, Landroid/view/ViewGroup;

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I
    move-result v1
    if-lez v1, :cond_done

    # threshold = 65% of the screen height (keep the bottom 35%)
    mul-int/lit8 v1, v1, 0x41
    div-int/lit8 v1, v1, 0x64

    const/4 v2, 0x0
    sput v2, LX/TTrueReelHelper;->A0K:I

    const-string v3, "InstaTrueReel"
    const-string v4, "v0.7 tree: bottom-strip dump begin"
    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {v0, v2, v1}, LX/TTrueReelHelper;->A18(Landroid/view/ViewGroup;II)V

    sget v2, LX/TTrueReelHelper;->A0K:I
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "v0.7 tree: dump complete (n="
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v3
    const-string v4, ")"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    const-string v4, "InstaTrueReel"
    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 tree: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A18(Landroid/view/ViewGroup;II)V == v0.7 recursive tree dumper.
# p0 = group, p1 = the group's absolute top on screen, p2 = threshold (abs bottom
# must be >= threshold to be logged). Logs class/id/y-range/width/height for views
# in the bottom strip; recurses into every ViewGroup child. GONE views are skipped.
.method public static A18(Landroid/view/ViewGroup;II)V
    .locals 7

    :try_start_0
    # ---- line cap ----
    sget v0, LX/TTrueReelHelper;->A0K:I
    const/16 v1, 0x104
    if-ge v0, v1, :cap_done

    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1

    const/4 v2, 0x0
    :loop_head
    if-ge v2, v1, :loop_end

    invoke-virtual {p0, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v3
    if-eqz v3, :loop_next

    # ---- absolute bounds ----
    invoke-virtual {v3}, Landroid/view/View;->getTop()I
    move-result v4
    add-int/2addr v4, p1
    invoke-virtual {v3}, Landroid/view/View;->getBottom()I
    move-result v5
    add-int/2addr v5, p1

    # ---- log when in the bottom strip and not GONE ----
    if-ge v5, p2, :maybe_log
    goto :no_log
    :maybe_log
    invoke-virtual {v3}, Landroid/view/View;->getVisibility()I
    move-result v6
    const/16 v0, 0x8
    if-ne v6, v0, :do_log
    goto :no_log

    :do_log
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "v0.7 tree: "
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v3}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v6
    invoke-virtual {v6}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v6, " id=0x"
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v3}, Landroid/view/View;->getId()I
    move-result v6
    invoke-static {v6}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v6, " y=["
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v6, ".."
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v6, "] w="
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v3}, Landroid/view/View;->getWidth()I
    move-result v6
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v6, " h="
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v3}, Landroid/view/View;->getHeight()I
    move-result v6
    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v6, "InstaTrueReel"
    invoke-static {v6, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    sget v0, LX/TTrueReelHelper;->A0K:I
    add-int/lit8 v0, v0, 0x1
    sput v0, LX/TTrueReelHelper;->A0K:I

    :no_log
    # ---- recurse ----
    instance-of v0, v3, Landroid/view/ViewGroup;
    if-eqz v0, :loop_next
    check-cast v3, Landroid/view/ViewGroup;
    invoke-static {v3, v4, p2}, LX/TTrueReelHelper;->A18(Landroid/view/ViewGroup;II)V

    :loop_next
    add-int/lit8 v2, v2, 0x1
    goto :loop_head
    :loop_end
    :cap_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.7 tree: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A19(Landroid/app/Activity;)V == v0.8 strip-overlay orchestrator.
# Called at the end of A15 (fresh apply + every re-apply tick). Finds the reels
# video container inside the fragment, extends it to the full parent height
# (zeroing its LinearLayout weight so the change sticks), then turns the opaque
# comment strip below it into a floating overlay: translationY = -stripH keeps
# it at the same on-screen position (drawn ON TOP of the now-fullscreen video,
# touch dispatch follows translation so the pill stays tappable) and its
# background + direct-child backgrounds are cleared (the pill two levels down
# keeps its rounded background). Inert when there is no strip (reels tab).
.method public static A19(Landroid/app/Activity;)V
    .locals 10

    :try_start_0
    # ---- idempotent re-assert while already applied ----
    sget-boolean v0, LX/TTrueReelHelper;->A0T:Z
    if-eqz v0, :fresh

    sget-object v2, LX/TTrueReelHelper;->A0L:Landroid/view/View;
    if-eqz v2, :reassert_done

    invoke-virtual {v2}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    if-eqz v0, :reassert_done
    instance-of v1, v0, Landroid/view/View;
    if-eqz v1, :reassert_done
    check-cast v0, Landroid/view/View;
    invoke-virtual {v0}, Landroid/view/View;->getHeight()I
    move-result v1

    invoke-virtual {v2}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v3
    if-eqz v3, :reassert_strip
    iput v1, v3, Landroid/view/ViewGroup$LayoutParams;->height:I
    invoke-virtual {v2}, Landroid/view/View;->requestLayout()V

    :reassert_strip
    sget-object v4, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    if-eqz v4, :reassert_done
    sget v5, LX/TTrueReelHelper;->A0U:I
    neg-int v5, v5
    int-to-float v5, v5
    invoke-virtual {v4, v5}, Landroid/view/View;->setTranslationY(F)V
    const/4 v6, 0x0
    invoke-virtual {v4, v6}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    sget-object v7, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    if-eqz v7, :reassert_done
    invoke-virtual {v7}, Ljava/util/ArrayList;->size()I
    move-result v8
    const/4 v9, 0x0
    :reassert_loop
    if-ge v9, v8, :reassert_done
    invoke-virtual {v7, v9}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v3
    if-eqz v3, :reassert_next
    check-cast v3, Landroid/view/View;
    invoke-virtual {v3, v6}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    :reassert_next
    add-int/lit8 v9, v9, 0x1
    goto :reassert_loop

    :reassert_done
    return-void

    :fresh
    # ---- locate the fragment view ----
    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done

    # ---- DFS for the video container (GestureManagerFrameLayout) ----
    const/4 v2, 0x0
    invoke-static {v1, v2}, LX/TTrueReelHelper;->A1A(Landroid/view/View;I)Landroid/view/View;
    move-result-object v2
    if-nez v2, :have_video

    # ---- fallback: ClipsSwipeRefreshLayout, climb to the LinearLayout child ----
    const/4 v2, 0x0
    invoke-static {v1, v2}, LX/TTrueReelHelper;->A1C(Landroid/view/View;I)Landroid/view/View;
    move-result-object v2
    if-eqz v2, :not_found

    :climb_head
    invoke-virtual {v2}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v3
    if-eqz v3, :not_found
    instance-of v4, v3, Landroid/widget/LinearLayout;
    if-nez v4, :have_video
    instance-of v4, v3, Landroid/view/View;
    if-eqz v4, :not_found
    check-cast v3, Landroid/view/View;
    move-object v2, v3
    goto :climb_head

    :have_video
    # ---- the video container's parent must be a LinearLayout ----
    invoke-virtual {v2}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v3
    if-eqz v3, :not_found
    instance-of v4, v3, Landroid/widget/LinearLayout;
    if-eqz v4, :bad_parent
    check-cast v3, Landroid/view/ViewGroup;

    # ---- strip geometry ----
    invoke-virtual {v3}, Landroid/view/ViewGroup;->getHeight()I
    move-result v5
    invoke-virtual {v2}, Landroid/view/View;->getBottom()I
    move-result v6
    sub-int v7, v5, v6

    if-lez v7, :no_gap
    const/16 v8, 0x190
    if-ge v7, v8, :gap_too_big

    # ---- find the strip: the child that starts exactly at the video bottom ----
    const/4 v4, 0x0
    invoke-virtual {v3}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v8
    const/4 v9, 0x0
    :strip_loop
    if-ge v9, v8, :strip_loop_end
    invoke-virtual {v3, v9}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :strip_next
    invoke-virtual {v0}, Landroid/view/View;->getTop()I
    move-result v1
    if-ne v1, v6, :strip_next
    invoke-virtual {v0}, Landroid/view/View;->getHeight()I
    move-result v1
    if-ne v1, v7, :strip_next
    if-eqz v4, :strip_take
    instance-of v1, v0, Landroid/widget/LinearLayout;
    if-eqz v1, :strip_next
    move-object v4, v0
    goto :strip_loop_end
    :strip_take
    move-object v4, v0
    :strip_next
    add-int/lit8 v9, v9, 0x1
    goto :strip_loop
    :strip_loop_end
    if-nez v4, :strip_found

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: strip not found below video"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :strip_found
    # ---- save original state once, then transform ----
    invoke-static {v2, v4, v7}, LX/TTrueReelHelper;->A1D(Landroid/view/View;Landroid/view/View;I)V
    invoke-static {v2, v4, v7}, LX/TTrueReelHelper;->A1E(Landroid/view/View;Landroid/view/View;I)V
    return-void

    :no_gap
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: video already full-bleed (no strip)"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :gap_too_big
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: strip gap too big (skipped)"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :bad_parent
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: video parent not a LinearLayout"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    return-void

    :not_found
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: video container not found (DFS)"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A1A(Landroid/view/View;I)Landroid/view/View; == v0.8 bounded DFS for the
# reels video container (com.instagram.ui.gesture.GestureManagerFrameLayout).
# Depth-capped at 8 levels; returns the first match or null.
.method public static A1A(Landroid/view/View;I)Landroid/view/View;
    .locals 5

    :try_start_0
    if-eqz p0, :ret_null
    const/16 v0, 0x8
    if-gt p1, v0, :ret_null

    instance-of v0, p0, Lcom/instagram/ui/gesture/GestureManagerFrameLayout;
    if-eqz v0, :not_match
    return-object p0

    :not_match
    instance-of v0, p0, Landroid/view/ViewGroup;
    if-eqz v0, :ret_null
    check-cast p0, Landroid/view/ViewGroup;
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/4 v2, 0x0
    :loop_head
    if-ge v2, v1, :loop_end
    invoke-virtual {p0, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v3
    if-eqz v3, :loop_next
    add-int/lit8 v4, p1, 0x1
    invoke-static {v3, v4}, LX/TTrueReelHelper;->A1A(Landroid/view/View;I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :loop_next
    return-object v0
    :loop_next
    add-int/lit8 v2, v2, 0x1
    goto :loop_head

    :loop_end
    :ret_null
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    const/4 v0, 0x0
    return-object v0

    :catch_0
    move-exception v0
    const/4 v1, 0x0
    return-object v1
.end method


# A1C(Landroid/view/View;I)Landroid/view/View; == v0.8 bounded DFS fallback:
# instagram.features.clips.viewer.ui.ClipsSwipeRefreshLayout (the reels pager's
# swipe-refresh host). A19 climbs from it to the direct LinearLayout child.
.method public static A1C(Landroid/view/View;I)Landroid/view/View;
    .locals 5

    :try_start_0
    if-eqz p0, :ret_null
    const/16 v0, 0x8
    if-gt p1, v0, :ret_null

    instance-of v0, p0, Linstagram/features/clips/viewer/ui/ClipsSwipeRefreshLayout;
    if-eqz v0, :not_match
    return-object p0

    :not_match
    instance-of v0, p0, Landroid/view/ViewGroup;
    if-eqz v0, :ret_null
    check-cast p0, Landroid/view/ViewGroup;
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/4 v2, 0x0
    :loop_head
    if-ge v2, v1, :loop_end
    invoke-virtual {p0, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v3
    if-eqz v3, :loop_next
    add-int/lit8 v4, p1, 0x1
    invoke-static {v3, v4}, LX/TTrueReelHelper;->A1C(Landroid/view/View;I)Landroid/view/View;
    move-result-object v0
    if-eqz v0, :loop_next
    return-object v0
    :loop_next
    add-int/lit8 v2, v2, 0x1
    goto :loop_head

    :loop_end
    :ret_null
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    const/4 v0, 0x0
    return-object v0

    :catch_0
    move-exception v0
    const/4 v1, 0x0
    return-object v1
.end method


# A1B()V == v0.8 restore the strip overlay (video height/weight, strip
# translationY + backgrounds). Wired into A10 (exit restore) and A00
# (fresh-entry clean slate). No-op unless the overlay is applied.
.method public static A1B()V
    .locals 7

    :try_start_0
    sget-boolean v0, LX/TTrueReelHelper;->A0T:Z
    if-eqz v0, :cond_done

    # ---- restore the video container ----
    sget-object v1, LX/TTrueReelHelper;->A0L:Landroid/view/View;
    if-eqz v1, :restore_strip

    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :rlayout
    sget v3, LX/TTrueReelHelper;->A0M:I
    iput v3, v2, Landroid/view/ViewGroup$LayoutParams;->height:I
    sget-boolean v3, LX/TTrueReelHelper;->A0V:Z
    if-eqz v3, :rweight_done
    instance-of v3, v2, Landroid/widget/LinearLayout$LayoutParams;
    if-eqz v3, :rweight_done
    check-cast v2, Landroid/widget/LinearLayout$LayoutParams;
    sget v3, LX/TTrueReelHelper;->A0N:F
    iput v3, v2, Landroid/widget/LinearLayout$LayoutParams;->weight:F
    :rweight_done
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V

    :rlayout
    :restore_strip
    # ---- restore the strip ----
    sget-object v1, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    if-eqz v1, :rreset
    sget v2, LX/TTrueReelHelper;->A0P:F
    invoke-virtual {v1, v2}, Landroid/view/View;->setTranslationY(F)V
    sget-object v2, LX/TTrueReelHelper;->A0S:Landroid/graphics/drawable/Drawable;
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    sget-object v3, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    if-eqz v3, :rstrip_done
    sget-object v4, LX/TTrueReelHelper;->A0R:Ljava/util/ArrayList;
    if-eqz v4, :rstrip_done
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I
    move-result v5
    const/4 v2, 0x0
    :rkids_loop
    if-ge v2, v5, :rkids_end
    invoke-virtual {v3, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v0
    if-eqz v0, :rkids_next
    check-cast v0, Landroid/view/View;
    invoke-virtual {v4, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Landroid/graphics/drawable/Drawable;
    invoke-virtual {v0, v6}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    :rkids_next
    add-int/lit8 v2, v2, 0x1
    goto :rkids_loop
    :rkids_end

    :rstrip_done
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V

    :rreset
    const/4 v0, 0x0
    sput-object v0, LX/TTrueReelHelper;->A0L:Landroid/view/View;
    sput-object v0, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    sput-object v0, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    sput-object v0, LX/TTrueReelHelper;->A0R:Ljava/util/ArrayList;
    sput-object v0, LX/TTrueReelHelper;->A0S:Landroid/graphics/drawable/Drawable;
    const/4 v1, 0x0
    sput v1, LX/TTrueReelHelper;->A0M:I
    sput v1, LX/TTrueReelHelper;->A0U:I
    const/4 v2, 0x0
    int-to-float v2, v2
    sput v2, LX/TTrueReelHelper;->A0N:F
    sput-boolean v1, LX/TTrueReelHelper;->A0T:Z
    sput-boolean v1, LX/TTrueReelHelper;->A0V:Z

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 restore: strip overlay reverted"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 restore: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A1D(Landroid/view/View;Landroid/view/View;I)V == v0.8 save the original
# overlay state ONCE (video LayoutParams.height + weight, strip translationY +
# background + up to 4 direct-child backgrounds). p0 = video, p1 = strip,
# p2 = strip height.
.method public static A1D(Landroid/view/View;Landroid/view/View;I)V
    .locals 7

    :try_start_0
    # ---- video: remember LayoutParams.height (+ weight when present) ----
    sput-object p0, LX/TTrueReelHelper;->A0L:Landroid/view/View;
    const/4 v0, -0x2
    sput v0, LX/TTrueReelHelper;->A0M:I
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A0V:Z

    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v1
    if-eqz v1, :lp_done
    iget v0, v1, Landroid/view/ViewGroup$LayoutParams;->height:I
    sput v0, LX/TTrueReelHelper;->A0M:I
    instance-of v2, v1, Landroid/widget/LinearLayout$LayoutParams;
    if-eqz v2, :lp_done
    check-cast v1, Landroid/widget/LinearLayout$LayoutParams;
    iget v2, v1, Landroid/widget/LinearLayout$LayoutParams;->weight:F
    sput v2, LX/TTrueReelHelper;->A0N:F
    const/4 v2, 0x1
    sput-boolean v2, LX/TTrueReelHelper;->A0V:Z
    :lp_done

    # ---- strip: remember translationY + background + child backgrounds ----
    sput-object p1, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    invoke-virtual {p1}, Landroid/view/View;->getTranslationY()F
    move-result v0
    sput v0, LX/TTrueReelHelper;->A0P:F
    invoke-virtual {p1}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v0
    sput-object v0, LX/TTrueReelHelper;->A0S:Landroid/graphics/drawable/Drawable;

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0R:Ljava/util/ArrayList;

    instance-of v0, p1, Landroid/view/ViewGroup;
    if-eqz v0, :kids_done
    check-cast p1, Landroid/view/ViewGroup;
    invoke-virtual {p1}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/4 v2, 0x4
    if-le v1, v2, :cnt_ok
    move v1, v2
    :cnt_ok
    const/4 v3, 0x0
    :kids_loop
    if-ge v3, v1, :kids_done
    invoke-virtual {p1, v3}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v4
    if-eqz v4, :kids_next
    sget-object v5, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    invoke-virtual {v5, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    sget-object v6, LX/TTrueReelHelper;->A0R:Ljava/util/ArrayList;
    invoke-virtual {v4}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v0
    invoke-virtual {v6, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :kids_next
    add-int/lit8 v3, v3, 0x1
    goto :kids_loop
    :kids_done

    sput p2, LX/TTrueReelHelper;->A0U:I
    const/4 v0, 0x1
    sput-boolean v0, LX/TTrueReelHelper;->A0T:Z
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 save: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A1E(Landroid/view/View;Landroid/view/View;I)V == v0.8 apply the overlay:
# video LayoutParams.height = parent height with weight = 0, strip
# translationY = -stripH + transparent backgrounds (strip + direct children,
# pill two levels down keeps its rounded background). p0 = video, p1 = strip,
# p2 = strip height.
.method public static A1E(Landroid/view/View;Landroid/view/View;I)V
    .locals 8

    :try_start_0
    # ---- video: height = parent height, weight = 0 ----
    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    if-eqz v0, :apply_strip
    instance-of v1, v0, Landroid/view/View;
    if-eqz v1, :apply_strip
    check-cast v0, Landroid/view/View;
    invoke-virtual {v0}, Landroid/view/View;->getHeight()I
    move-result v1

    invoke-virtual {p0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :apply_strip
    iput v1, v2, Landroid/view/ViewGroup$LayoutParams;->height:I
    instance-of v3, v2, Landroid/widget/LinearLayout$LayoutParams;
    if-eqz v3, :weight_done
    check-cast v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, 0x0
    int-to-float v4, v4
    iput v4, v2, Landroid/widget/LinearLayout$LayoutParams;->weight:F
    :weight_done
    invoke-virtual {p0}, Landroid/view/View;->requestLayout()V

    :apply_strip
    # ---- strip: float over the video bottom, background transparent ----
    neg-int v4, p2
    int-to-float v4, v4
    invoke-virtual {p1, v4}, Landroid/view/View;->setTranslationY(F)V
    const/4 v5, 0x0
    invoke-virtual {p1, v5}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    sget-object v6, LX/TTrueReelHelper;->A0Q:Ljava/util/ArrayList;
    if-eqz v6, :kids_done
    invoke-virtual {v6}, Ljava/util/ArrayList;->size()I
    move-result v7
    const/4 v3, 0x0
    :kids_loop
    if-ge v3, v7, :kids_done
    invoke-virtual {v6, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v2
    if-eqz v2, :kids_next
    check-cast v2, Landroid/view/View;
    invoke-virtual {v2, v5}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    :kids_next
    add-int/lit8 v3, v3, 0x1
    goto :kids_loop
    :kids_done
    invoke-virtual {p1}, Landroid/view/View;->invalidate()V

    # ---- telemetry ----
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "v0.8 overlay: "
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {p1}, Landroid/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " ty="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    neg-int v1, p2
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    move-result-object v0
    const-string v1, " (bg cleared, video full-height)"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "InstaTrueReel"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.8 overlay: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method

# ============================================================================
# v0.9 (phase 8) — TIKTOK-STYLE HORIZONTAL FULLSCREEN
#
# Research (base APK v435.0.0.37.76, all 21 dexes disassembled in sandbox):
#   * InstagramMainActivity (MainTabActivity alias target) declares
#     android:screenOrientation="14" (LOCKED) but configChanges=0xDA0 which
#     INCLUDES orientation|screenSize|screenLayout|smallestScreenSize — a
#     runtime setRequestedOrientation() relayouts WITHOUT recreating it.
#   * ModalActivity (Watch History / Likes host): screenOrientation="3" (BEHIND),
#     configChanges=0xDB0 — same no-recreation guarantee.
#   * Full-app sweep: only 11 classes ever call setRequestedOrientation and
#     NONE of them live in the clips dexes (classes16/classes17) or in the two
#     host activities — nothing fights our rotation.
#   * 9Wz (ClipsViewerFragment) has a real onConfigurationChanged that re-reads
#     screen dimensions (tablet-ready) — safe under rotation.
#
# UX (mirrors TikTok, per reference screenshots):
#   * portrait + landscape video: "⛶ Full screen" pill (60% black rounded,
#     bold white) floats in the letterbox bar UNDER the video frame.
#   * tap pill: whole app rotates (SENSOR_LANDSCAPE=6), comment strip hides,
#     video fills the screen edge-to-edge, "×" exit circle floats top-left.
#   * tap × (or leaving reels): PORTRAIT(1), strip visible again, cleanup.
# ============================================================================

# A20(Landroid/app/Activity;)V == v0.9 fullscreen ORCHESTRATOR. Called at the
# end of every A15 pass (re-apply ticks + fresh entry) and from the
# TTrueReelRecheck layout listener. Portrait: find the video surface (largest
# TextureView under the fragment view); if it is LANDSCAPE (w > 1.25 * h),
# ensure + position the "Full screen" pill; otherwise hide it. Landscape
# (fsForced): keep the exit button alive, keep the pill hidden.
.method public static A20(Landroid/app/Activity;)V
    .locals 6

    :try_start_0
    sget-boolean v0, LX/TTrueReelHelper;->A05:Z
    if-eqz v0, :cond_done

    sget-boolean v0, LX/TTrueReelHelper;->fsForced:Z
    if-eqz v0, :portrait_check

    # ---- landscape mode: keep the exit button, hide the pill ----
    invoke-static {p0}, LX/TTrueReelHelper;->A25(Landroid/app/Activity;)V
    sget-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-eqz v0, :auto_check
    const/16 v1, 0x8
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V
    :auto_check

    # ---- v0.9.1 AUTO-EXIT: if the CURRENT video is no longer landscape ----
    # ---- (user swiped to a portrait reel), return to portrait (TikTok ----
    # ---- behavior). Debounced: needs 2 consecutive non-landscape ----
    # ---- detections, disabled for the first 1500ms after the engage ----
    # ---- (the rotation transition itself re-measures the video). ----
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    sget-wide v2, LX/TTrueReelHelper;->fsEngageAt:J
    sub-long/2addr v0, v2
    const-wide/16 v2, 0x5dc
    cmp-long v4, v0, v2
    if-ltz v4, :keep_early

    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :count_nonland
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v0
    if-eqz v0, :count_nonland
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    const/4 v1, -0x1
    sput v1, LX/TTrueReelHelper;->fsBestArea:I
    const/4 v1, 0x0
    invoke-static {v0, v1}, LX/TTrueReelHelper;->A21(Landroid/view/View;I)V
    sget-object v2, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    if-eqz v2, :count_nonland
    invoke-virtual {v2}, Landroid/view/View;->getHeight()I
    move-result v3
    const/16 v0, 0x28
    if-lt v3, v0, :count_nonland
    invoke-virtual {v2}, Landroid/view/View;->getWidth()I
    move-result v0
    int-to-float v0, v0
    int-to-float v1, v3
    const/high16 v4, 0x3fa00000    # 1.25f
    mul-float/2addr v1, v4
    cmpl-float v0, v0, v1
    if-lez v0, :count_nonland
    const/4 v0, 0x0
    sput v0, LX/TTrueReelHelper;->fsNonLand:I
    return-void

    :count_nonland
    sget v0, LX/TTrueReelHelper;->fsNonLand:I
    add-int/lit8 v0, v0, 0x1
    sput v0, LX/TTrueReelHelper;->fsNonLand:I
    const/4 v1, 0x2
    if-ge v0, v1, :exit_now
    :keep_early
    return-void

    :exit_now
    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 fs: auto-exit (video no longer landscape)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {}, LX/TTrueReelHelper;->A26()V
    return-void

    :portrait_check
    # ---- locate the fragment view ----
    sget-object v0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v0, :hide_pill
    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v0
    if-eqz v0, :hide_pill

    # ---- find the largest video surface (TextureView) ----
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    const/4 v1, -0x1
    sput v1, LX/TTrueReelHelper;->fsBestArea:I
    const/4 v1, 0x0
    invoke-static {v0, v1}, LX/TTrueReelHelper;->A21(Landroid/view/View;I)V
    sget-object v2, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    if-eqz v2, :hide_pill

    # ---- needs a laid-out surface ----
    invoke-virtual {v2}, Landroid/view/View;->getHeight()I
    move-result v3
    const/16 v0, 0x28
    if-lt v3, v0, :hide_pill

    # ---- landscape video iff width > height * 1.25 ----
    invoke-virtual {v2}, Landroid/view/View;->getWidth()I
    move-result v0
    int-to-float v0, v0
    int-to-float v1, v3
    const/high16 v4, 0x3fa00000    # 1.25f
    mul-float/2addr v1, v4
    cmpl-float v0, v0, v1
    if-lez v0, :hide_pill

    # ---- show + position the pill in the letterbox bar ----
    invoke-static {p0, v2}, LX/TTrueReelHelper;->A23(Landroid/app/Activity;Landroid/view/View;)V
    return-void

    :hide_pill
    sget-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-eqz v0, :cond_done
    const/16 v1, 0x8
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A21(Landroid/view/View;I)V == v0.9 bounded DFS: track the LARGEST TextureView
# (the reels video surface) under p0 into fsBest/fsBestArea. Depth cap 20.
.method public static A21(Landroid/view/View;I)V
    .locals 5

    :try_start_0
    if-eqz p0, :ret
    const/16 v0, 0x14
    if-gt p1, v0, :ret

    instance-of v0, p0, Landroid/view/TextureView;
    if-eqz v0, :not_surface

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I
    move-result v1
    invoke-virtual {p0}, Landroid/view/View;->getHeight()I
    move-result v2
    mul-int v3, v1, v2
    sget v0, LX/TTrueReelHelper;->fsBestArea:I
    if-le v3, v0, :ret
    sput v3, LX/TTrueReelHelper;->fsBestArea:I
    sput-object p0, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    return-void

    :not_surface
    instance-of v0, p0, Landroid/view/ViewGroup;
    if-eqz v0, :ret
    check-cast p0, Landroid/view/ViewGroup;
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/4 v2, 0x0
    :loop_head
    if-ge v2, v1, :loop_end
    invoke-virtual {p0, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v3
    if-eqz v3, :loop_next
    add-int/lit8 v4, p1, 0x1
    invoke-static {v3, v4}, LX/TTrueReelHelper;->A21(Landroid/view/View;I)V
    :loop_next
    add-int/lit8 v2, v2, 0x1
    goto :loop_head

    :loop_end
    :ret
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method


# A22(Landroid/app/Activity;)V == v0.9 create the TikTok-style "Full screen"
# pill (semi-transparent dark rounded pill, bold white "⛶ Full screen"), owned
# by the window decor. Positioning happens in A23; this only builds + adds it.
.method public static A22(Landroid/app/Activity;)V
    .locals 6

    :try_start_0
    sget-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-nez v0, :cond_done

    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done
    check-cast v1, Landroid/view/ViewGroup;

    # ---- density (kept in v5 while building) ----
    invoke-virtual {p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v2
    invoke-virtual {v2}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v2
    iget v5, v2, Landroid/util/DisplayMetrics;->density:F

    # ---- the pill text ----
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "⛶  Full screen"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v3, -0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v3, 0x41600000
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    sget-object v3, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    # ---- padding: 16dp horizontal, 8dp vertical ----
    const/high16 v3, 0x41800000
    mul-float/2addr v3, v5
    float-to-int v3, v3
    const/high16 v4, 0x41000000
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v3, v4, v3, v4}, Landroid/view/View;->setPadding(IIII)V

    # ---- pill background: rounded rect, 60% black ----
    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const/4 v4, 0x0
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setShape(I)V
    const/high16 v4, 0x447a0000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    const v4, -0x67000000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # ---- click -> enter landscape ----
    new-instance v3, LX/TTrueReelClick;
    const/4 v4, 0x0
    invoke-direct {v3, v4}, LX/TTrueReelClick;-><init>(I)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    # ---- decor attach: bottom-center, lifted by bottomMargin (A23 sets it) ----
    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v4, -0x2
    const/4 v5, -0x2
    const/16 v0, 0x51
    invoke-direct {v3, v4, v5, v0}, Landroid/widget/FrameLayout$LayoutParams;-><init>(III)V
    const/16 v0, 0x30
    iput v0, v3, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v1, v2, v3}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    sput-object v2, LX/TTrueReelHelper;->fsPill:Landroid/view/View;

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 fs: pill created (landscape video detected)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs pill: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A23(Landroid/app/Activity;Landroid/view/View;)V == v0.9 ensure + position the
# pill in the letterbox bar under the landscape video (TikTok placement).
# p1 = video surface. bottomMargin = max(letterboxBar/2, stripH + 16dp).
.method public static A23(Landroid/app/Activity;Landroid/view/View;)V
    .locals 8

    :try_start_0
    invoke-static {p0}, LX/TTrueReelHelper;->A22(Landroid/app/Activity;)V
    sget-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-eqz v0, :cond_done

    # ---- decor height ----
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v2
    if-eqz v2, :show_only
    invoke-virtual {v2}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v2
    if-eqz v2, :show_only
    invoke-virtual {v2}, Landroid/view/View;->getHeight()I
    move-result v3

    # ---- video bottom in screen coords ----
    const/4 v4, 0x2
    new-array v4, v4, [I
    invoke-virtual {p1, v4}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v5, 0x1
    aget v5, v4, v5
    invoke-virtual {p1}, Landroid/view/View;->getHeight()I
    move-result v6
    add-int/2addr v5, v6
    sub-int v5, v3, v5          # letterbox bar height under the video
    if-gez v5, :bar_ok
    const/4 v5, 0x0
    :bar_ok
    div-int/lit8 v5, v5, 0x2

    # ---- guard: strip height + 16dp (or plain 16dp on the reels tab) ----
    invoke-virtual {p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v7
    invoke-virtual {v7}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v7
    iget v7, v7, Landroid/util/DisplayMetrics;->density:F
    const/high16 v4, 0x41800000
    mul-float/2addr v4, v7
    float-to-int v4, v4
    sget v6, LX/TTrueReelHelper;->A0U:I
    if-lez v6, :no_strip_guard
    add-int/2addr v6, v4
    goto :guard_done
    :no_strip_guard
    move v6, v4
    :guard_done
    if-ge v5, v6, :set_margin
    move v5, v6
    :set_margin
    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v4
    if-eqz v4, :show_only
    check-cast v4, Landroid/widget/FrameLayout$LayoutParams;
    iput v5, v4, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0}, Landroid/view/View;->requestLayout()V

    :show_only
    const/4 v4, 0x0
    invoke-virtual {v0, v4}, Landroid/view/View;->setVisibility(I)V

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs pos: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A24()V == v0.9 ENTER TikTok-style landscape fullscreen: force SENSOR_LANDSCAPE
# (6), hide the pill + the comment strip (video claims the full height via the
# v0.8 reassert engine), show the exit button, re-run the layout engine.
.method public static A24()V
    .locals 3

    :try_start_0
    sget-boolean v0, LX/TTrueReelHelper;->A05:Z
    if-eqz v0, :cond_done
    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :cond_done

    const/4 v1, 0x1
    sput-boolean v1, LX/TTrueReelHelper;->fsForced:Z

    # ---- v0.9.1: record the engage time + reset the auto-exit debounce ----
    const/4 v1, 0x0
    sput v1, LX/TTrueReelHelper;->fsNonLand:I
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v1
    sput-wide v1, LX/TTrueReelHelper;->fsEngageAt:J

    # ---- rotate: SCREEN_ORIENTATION_SENSOR_LANDSCAPE ----
    const/4 v1, 0x6
    invoke-virtual {v0, v1}, Landroid/app/Activity;->setRequestedOrientation(I)V

    # ---- hide the pill ----
    sget-object v1, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-eqz v1, :no_pill
    const/16 v2, 0x8
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    :no_pill

    # ---- show the exit button ----
    invoke-static {v0}, LX/TTrueReelHelper;->A25(Landroid/app/Activity;)V

    # ---- hide the comment strip ----
    sget-object v1, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    if-eqz v1, :no_strip
    const/16 v2, 0x8
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    :no_strip

    # ---- re-run the layout engine for the new configuration ----
    invoke-static {}, LX/TTrueReelHelper;->A05()V

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs: landscape engaged"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs enter: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A25(Landroid/app/Activity;)V == v0.9 create the landscape EXIT button
# (semi-transparent dark circle, white "×", top-left of the decor).
.method public static A25(Landroid/app/Activity;)V
    .locals 7

    :try_start_0
    sget-object v0, LX/TTrueReelHelper;->fsExit:Landroid/view/View;
    if-nez v0, :cond_done

    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    if-eqz v0, :cond_done
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done
    check-cast v1, Landroid/view/ViewGroup;

    # ---- density ----
    invoke-virtual {p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v2
    invoke-virtual {v2}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v2
    iget v2, v2, Landroid/util/DisplayMetrics;->density:F

    # ---- build the round "×" button ----
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "×"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v4, 0x41900000
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V

    # ---- padding: 10dp horizontal, 6dp vertical ----
    const/high16 v4, 0x41200000
    mul-float/2addr v4, v2
    float-to-int v4, v4
    const/high16 v5, 0x40c00000
    mul-float/2addr v5, v2
    float-to-int v5, v5
    invoke-virtual {v3, v4, v5, v4, v5}, Landroid/view/View;->setPadding(IIII)V

    # ---- circle background: 60% black ----
    new-instance v4, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v4}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const/4 v5, 0x1
    invoke-virtual {v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setShape(I)V
    const v5, -0x67000000
    invoke-virtual {v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # ---- click -> exit landscape ----
    new-instance v4, LX/TTrueReelClick;
    const/4 v5, 0x1
    invoke-direct {v4, v5}, LX/TTrueReelClick;-><init>(I)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    # ---- decor attach: top-left (24dp top / 16dp left) ----
    new-instance v4, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v5, -0x2
    const/4 v6, -0x2
    const/16 v0, 0x33
    invoke-direct {v4, v5, v6, v0}, Landroid/widget/FrameLayout$LayoutParams;-><init>(III)V
    const/high16 v5, 0x41c00000
    mul-float/2addr v5, v2
    float-to-int v5, v5
    iput v5, v4, Landroid/view/ViewGroup$MarginLayoutParams;->topMargin:I
    const/high16 v5, 0x41800000
    mul-float/2addr v5, v2
    float-to-int v5, v5
    iput v5, v4, Landroid/view/ViewGroup$MarginLayoutParams;->leftMargin:I
    invoke-virtual {v1, v3, v4}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    sput-object v3, LX/TTrueReelHelper;->fsExit:Landroid/view/View;

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 fs: exit button created"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs exit-btn: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A26()V == v0.9 EXIT landscape fullscreen: back to portrait (1), remove the
# exit button, strip visible again, re-run the layout engine.
.method public static A26()V
    .locals 3

    :try_start_0
    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :cond_done

    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/app/Activity;->setRequestedOrientation(I)V

    const/4 v1, 0x0
    sput-boolean v1, LX/TTrueReelHelper;->fsForced:Z
    sput v1, LX/TTrueReelHelper;->fsNonLand:I

    # ---- remove the exit button ----
    sget-object v1, LX/TTrueReelHelper;->fsExit:Landroid/view/View;
    if-eqz v1, :no_exit
    invoke-virtual {v1}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v2
    if-eqz v2, :no_exit
    check-cast v2, Landroid/view/ViewGroup;
    invoke-virtual {v2, v1}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V
    :no_exit
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->fsExit:Landroid/view/View;

    # ---- strip back ----
    sget-object v1, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    if-eqz v1, :no_strip
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    :no_strip

    # ---- re-run the engine (portrait relayout) ----
    invoke-static {}, LX/TTrueReelHelper;->A05()V

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs: back to portrait"
    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs exit: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A27()V == v0.9 cleanup on reels exit: remove the layout listener + both
# buttons, restore portrait orientation if we forced landscape, strip visible.
.method public static A27()V
    .locals 3

    :try_start_0
    # ---- listener off ----
    sget-object v0, LX/TTrueReelHelper;->fsListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;
    if-eqz v0, :no_listener
    sget-object v1, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;
    if-eqz v1, :drop_listener
    invoke-virtual {v1}, Landroidx/fragment/app/Fragment;->getView()Landroid/view/View;
    move-result-object v1
    if-eqz v1, :drop_listener
    invoke-virtual {v1}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v2
    if-eqz v2, :drop_listener
    invoke-virtual {v2, v0}, Landroid/view/ViewTreeObserver;->removeOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V
    :drop_listener
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->fsListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;
    :no_listener

    # ---- portrait back if we forced it ----
    sget-boolean v0, LX/TTrueReelHelper;->fsForced:Z
    if-eqz v0, :no_orientation
    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :no_orientation
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/app/Activity;->setRequestedOrientation(I)V
    const/4 v1, 0x0
    sput-boolean v1, LX/TTrueReelHelper;->fsForced:Z
    sput v1, LX/TTrueReelHelper;->fsNonLand:I
    sget-object v1, LX/TTrueReelHelper;->A0O:Landroid/view/View;
    if-eqz v1, :no_orientation
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setVisibility(I)V
    :no_orientation

    # ---- remove the pill ----
    sget-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;
    if-eqz v0, :no_pill
    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v1
    if-eqz v1, :no_pill
    check-cast v1, Landroid/view/ViewGroup;
    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V
    :no_pill
    const/4 v0, 0x0
    sput-object v0, LX/TTrueReelHelper;->fsPill:Landroid/view/View;

    # ---- remove the exit button ----
    sget-object v0, LX/TTrueReelHelper;->fsExit:Landroid/view/View;
    if-eqz v0, :no_exit
    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v1
    if-eqz v1, :no_exit
    check-cast v1, Landroid/view/ViewGroup;
    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V
    :no_exit
    const/4 v0, 0x0
    sput-object v0, LX/TTrueReelHelper;->fsExit:Landroid/view/View;
    const/4 v0, 0x0
    sput-object v0, LX/TTrueReelHelper;->fsBest:Landroid/view/View;
    const/4 v0, -0x1
    sput v0, LX/TTrueReelHelper;->fsBestArea:I

    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.9 fs cleanup: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A28(Landroid/app/Activity;)Z == v0.9.1 ORIENTATION-LOCK GATE, injected at the top
# of X/6mW.A00 (FixedOrientationCompat.setRequestedOrientation wrapper). While
# landscape fullscreen is engaged on OUR activity, EVERY app-side orientation set
# (the launch lock, the onConfigurationChanged re-assert via 0XU/0XX, camera/react
# paths...) is swallowed so nothing can rotate the reels back to portrait. Our own
# A26/A27 exit paths call Activity.setRequestedOrientation DIRECTLY (not through
# 6mW), so they are unaffected. Returns true = block the caller's orientation set.
.method public static A28(Landroid/app/Activity;)Z
    .locals 2

    sget-boolean v0, LX/TTrueReelHelper;->fsForced:Z
    if-eqz v0, :ret_false
    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :ret_false
    if-ne v0, p0, :ret_false

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 fs: portrait-lock blocked"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v0, 0x1
    return v0

    :ret_false
    const/4 v0, 0x0
    return v0
.end method


# A2B(Landroidx/fragment/app/Fragment;)V == v0.9.1 restore bridge, source tag 1
# (ClipsViewerFragment onPause). Logs WHICH hook fired, then runs the restore.
.method public static A2B(Landroidx/fragment/app/Fragment;)V
    .locals 2

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 hook: restore src=1 (viewer onPause)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
    return-void
.end method


# A2C(Landroidx/fragment/app/Fragment;)V == v0.9.1 restore bridge, source tag 2
# (ClipsViewerFragment onDestroyView).
.method public static A2C(Landroidx/fragment/app/Fragment;)V
    .locals 2

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 hook: restore src=2 (viewer onDestroyView)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
    return-void
.end method


# A2D(Landroidx/fragment/app/Fragment;)V == v0.9.1 restore bridge, source tag 3
# (ClipsTabFragment onPause override).
.method public static A2D(Landroidx/fragment/app/Fragment;)V
    .locals 2

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 hook: restore src=3 (tab onPause)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
    return-void
.end method


# A2E(Landroidx/fragment/app/Fragment;)V == v0.9.1 restore bridge, source tag 4
# (ClipsTabFragment onDestroyView).
.method public static A2E(Landroidx/fragment/app/Fragment;)V
    .locals 2

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 hook: restore src=4 (tab onDestroyView)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
    return-void
.end method


# A2F(Landroidx/fragment/app/Fragment;)V == v0.9.1 restore bridge, source tag 5
# (onHiddenChanged(true) via the A02 bridge - either fragment).
.method public static A2F(Landroidx/fragment/app/Fragment;)V
    .locals 2

    const-string v0, "InstaTrueReel"
    const-string v1, "v0.9 hook: restore src=5 (hidden)"
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
    return-void
.end method
