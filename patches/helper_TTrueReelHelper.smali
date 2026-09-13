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
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    sput-object v0, LX/TTrueReelHelper;->A0G:Ljava/util/ArrayList;
    sput-object p0, LX/TTrueReelHelper;->A0F:Landroidx/fragment/app/Fragment;

    # ---- de-block bottom layout (specific known containers, with diagnostics) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A08(Landroid/app/Activity;)V

    # ---- v0.6: chain liberation (modal root + every container bounding the video) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A09(Landroid/app/Activity;)V

    # ---- confirmation toast on every fresh reels entry ----
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getActivity()Landroidx/fragment/app/FragmentActivity;
    move-result-object v0
    if-eqz v0, :cond_no_toast
    const-string v1, "InstaTrueReel v0.6: full-bleed everywhere ON"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :cond_no_toast

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.6 apply: edge-to-edge engaged (fresh entry)"
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
    const-string v2, "v0.6 apply: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void
.end method


# A01(Landroidx/fragment/app/Fragment;)V == RESTORE original window state + layout.
.method public static A01(Landroidx/fragment/app/Fragment;)V
    .locals 4

    :try_start_0
    # ---- deactivate interceptors FIRST ----
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A05:Z

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
    const-string v3, "v0.6 restore: window chrome + layout restored"
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
    const-string v2, "v0.6 restore: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void
.end method


# A02(Landroidx/fragment/app/Fragment;Z)V == onHiddenChanged bridge.
.method public static A02(Landroidx/fragment/app/Fragment;Z)V
    .locals 0

    if-eqz p1, :cond_show
    invoke-static {p0}, LX/TTrueReelHelper;->A01(Landroidx/fragment/app/Fragment;)V
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
    const-string v2, "v0.6 schedule: exception (recovered)"
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
    const-string v2, "v0.6 chrome: exception (recovered)"
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
    const-string v4, "v0.6 liberate: chain freed (n="
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
    goto :cond_done

    :cond_no_frag
    const-string v2, "InstaTrueReel"
    const-string v4, "v0.6 liberate: no fragment view (skip)"
    invoke-static {v2, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const-string v1, "InstaTrueReel"
    const-string v2, "v0.6 liberate: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method


# A11(Landroid/view/View;Ljava/util/ArrayList;)Z == liberate ONE ancestor view.
# If the view already has a saved entry: re-assert the zeros (Instagram may have
# re-blocked it since) and return false. Otherwise: capture original state, store a
# TTrueReelViewSave, zero it, log the detail line, return true.
.method public static A11(Landroid/view/View;Ljava/util/ArrayList;)Z
    .locals 8

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

    # ---- log the detail ----
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "v0.6 liberate: "
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
.method public static A10(Landroid/app/Activity;)V
    .locals 10

    :try_start_0
    if-eqz p0, :cond_done

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
