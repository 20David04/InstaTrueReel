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
.field public static A0D:Z                          # modal root fitsSystemWindows changed flag
.field public static A0E:Z                          # main container margin saved flag


# direct methods

# A00(Landroidx/fragment/app/Fragment;)V == APPLY TikTok-style edge-to-edge to the activity window.
# v0.5: also de-blocks the bottom layout (viewpager + main container margins) and, when the
# reels viewer is hosted inside ModalActivity (Watch History / Liked paths), removes the
# fitsSystemWindows top/bottom padding of the modal root so the video draws under the bars.
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

    # ---- v0.5: de-block bottom layout (viewpager + main container margins) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A08(Landroid/app/Activity;)V

    # ---- v0.5: modal-host de-padding (fitsSystemWindows off on modal root) ----
    invoke-static {v4}, LX/TTrueReelHelper;->A09(Landroid/app/Activity;)V

    # ---- confirmation toast on every fresh reels entry ----
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getActivity()Landroidx/fragment/app/FragmentActivity;
    move-result-object v0
    if-eqz v0, :cond_no_toast
    const-string v1, "InstaTrueReel v0.5: full-bleed Reels ON"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v0
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :cond_no_toast

    const-string v1, "InstaTrueReel"
    const-string v2, "v0.5 apply: edge-to-edge engaged (fresh entry)"
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
    const-string v2, "v0.5 apply: exception (recovered)"
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void
.end method


# A01(Landroidx/fragment/app/Fragment;)V == RESTORE original window state + layout
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

    # ---- v0.5: restore deblocked layout (margins + modal fits) ----
    sget-object v3, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v3, :cond_no_layout_restore
    invoke-static {v3}, LX/TTrueReelHelper;->A10(Landroid/app/Activity;)V
    :cond_no_layout_restore

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
    const-string v3, "v0.5 restore: window chrome + layout restored"
    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_reset
    const/4 v2, 0x0
    sput-object v2, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    const/4 v2, 0x0
    sput-object v2, LX/TTrueReelHelper;->A09:Landroid/app/Activity;

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    const/4 v1, 0x0
    sput-object v1, LX/TTrueReelHelper;->A00:Landroid/view/Window;
    return-void
.end method


# A02(Landroidx/fragment/app/Fragment;Z)V == onHiddenChanged bridge
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


# A05()V == schedule delayed re-applies on the main thread (100/400/1000/2500/5000 ms)
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
    return-void
.end method


# A08(Landroid/app/Activity;)V == v0.5 DE-BLOCK BOTTOM LAYOUT.
# Zeroes the bottomMargin of swipeable_tab_view_pager (0x7f0b3f45) and
# layout_container_main (0x7f0b2246) while reels is active so the video can
# extend behind the (now transparent) tab bar / comment row. Saves the original
# values once; A10 restores them. Idempotent; safe in ModalActivity (ids absent).
.method public static A08(Landroid/app/Activity;)V
    .locals 4

    :try_start_0
    if-eqz p0, :cond_done

    # ---- swipeable_tab_view_pager ----
    const v0, 0x7f0b3f45
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_main
    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :cond_main
    instance-of v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v0, :cond_main
    check-cast v2, Landroid/view/ViewGroup$MarginLayoutParams;

    sget-boolean v0, LX/TTrueReelHelper;->A0C:Z
    if-nez v0, :cond_pager_saved
    iget v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    sput v0, LX/TTrueReelHelper;->A0A:I
    const/4 v0, 0x1
    sput-boolean v0, LX/TTrueReelHelper;->A0C:Z
    :cond_pager_saved

    iget v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    if-eqz v0, :cond_main
    const/4 v0, 0x0
    iput v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V
    const-string v0, "InstaTrueReel"
    const-string v3, "v0.5 deblock: viewpager bottomMargin -> 0"
    invoke-static {v0, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :cond_main

    # ---- layout_container_main ----
    const v0, 0x7f0b2246
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done
    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :cond_done
    instance-of v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v0, :cond_done
    check-cast v2, Landroid/view/ViewGroup$MarginLayoutParams;

    sget-boolean v0, LX/TTrueReelHelper;->A0E:Z
    if-nez v0, :cond_main_saved
    iget v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    sput v0, LX/TTrueReelHelper;->A0B:I
    const/4 v0, 0x1
    sput-boolean v0, LX/TTrueReelHelper;->A0E:Z
    :cond_main_saved

    iget v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    if-eqz v0, :cond_done
    const/4 v0, 0x0
    iput v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V
    const-string v0, "InstaTrueReel"
    const-string v3, "v0.5 deblock: main container bottomMargin -> 0"
    invoke-static {v0, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method


# A09(Landroid/app/Activity;)V == v0.5 MODAL-HOST DE-PADDING.
# When the reels viewer is hosted in ModalActivity (Watch History / Liked),
# its root layout_container_parent (0x7f0b224a) has fitsSystemWindows=true and
# insets padding => video starts below the status bar (black strip). While reels
# is active we turn fitsSystemWindows off and zero the top/bottom padding.
# Only acts when the root actually consumed insets (padding > 0).
.method public static A09(Landroid/app/Activity;)V
    .locals 4

    :try_start_0
    if-eqz p0, :cond_done

    const v0, 0x7f0b224a
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_done

    # has top or bottom padding? (proxy: root consumed window insets)
    invoke-virtual {v1}, Landroid/view/View;->getPaddingTop()I
    move-result v0
    if-lez v0, :itr_check_bottom
    goto :itr_pad_found

    :itr_check_bottom
    invoke-virtual {v1}, Landroid/view/View;->getPaddingBottom()I
    move-result v0
    if-lez v0, :cond_done

    :itr_pad_found
    const/4 v0, 0x1
    sput-boolean v0, LX/TTrueReelHelper;->A0D:Z
    const/4 v0, 0x0
    invoke-virtual {v1, v0}, Landroid/view/View;->setFitsSystemWindows(Z)V
    invoke-virtual {v1}, Landroid/view/View;->getPaddingLeft()I
    move-result v2
    invoke-virtual {v1}, Landroid/view/View;->getPaddingRight()I
    move-result v3
    const/4 v0, 0x0
    invoke-virtual {v1, v2, v0, v3, v0}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V
    const-string v0, "InstaTrueReel"
    const-string v2, "v0.5 modal: root de-padded (fitsSystemWindows off)"
    invoke-static {v0, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method


# A10(Landroid/app/Activity;)V == v0.5 RESTORE LAYOUT (called from A01).
.method public static A10(Landroid/app/Activity;)V
    .locals 4

    :try_start_0
    if-eqz p0, :cond_done

    # ---- restore modal root fitsSystemWindows ----
    sget-boolean v0, LX/TTrueReelHelper;->A0D:Z
    if-eqz v0, :cond_no_fits
    const v0, 0x7f0b224a
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_fits_reset
    const/4 v0, 0x1
    invoke-virtual {v1, v0}, Landroid/view/View;->setFitsSystemWindows(Z)V
    invoke-virtual {v1}, Landroid/view/View;->requestApplyInsets()V
    :cond_fits_reset
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A0D:Z
    :cond_no_fits

    # ---- restore viewpager bottomMargin ----
    sget-boolean v0, LX/TTrueReelHelper;->A0C:Z
    if-eqz v0, :cond_no_pager
    const v0, 0x7f0b3f45
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_pager_reset
    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :cond_pager_reset
    instance-of v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v0, :cond_pager_reset
    check-cast v2, Landroid/view/ViewGroup$MarginLayoutParams;
    sget v0, LX/TTrueReelHelper;->A0A:I
    iput v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V
    :cond_pager_reset
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A0C:Z
    :cond_no_pager

    # ---- restore main container bottomMargin ----
    sget-boolean v0, LX/TTrueReelHelper;->A0E:Z
    if-eqz v0, :cond_no_main
    const v0, 0x7f0b2246
    invoke-virtual {p0, v0}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :cond_main_reset
    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    if-eqz v2, :cond_main_reset
    instance-of v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;
    if-eqz v0, :cond_main_reset
    check-cast v2, Landroid/view/ViewGroup$MarginLayoutParams;
    sget v0, LX/TTrueReelHelper;->A0B:I
    iput v0, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V
    :cond_main_reset
    const/4 v0, 0x0
    sput-boolean v0, LX/TTrueReelHelper;->A0E:Z
    :cond_no_main

    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method
