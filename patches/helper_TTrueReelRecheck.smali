.class public LX/TTrueReelRecheck;
.super Ljava/lang/Object;
.source "TTrueReelRecheck"

# interfaces
.implements Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;


# direct methods
.method public constructor <init>()V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


# virtual methods
.method public final onGlobalLayout()V
    .locals 1

    :try_start_0
    sget-boolean v0, LX/TTrueReelHelper;->A05:Z
    if-eqz v0, :cond_done

    sget-object v0, LX/TTrueReelHelper;->A09:Landroid/app/Activity;
    if-eqz v0, :cond_done

    invoke-static {v0}, LX/TTrueReelHelper;->A20(Landroid/app/Activity;)V
    :cond_done
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method
