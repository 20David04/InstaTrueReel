.class public LX/TTrueReelClick;
.super Ljava/lang/Object;
.source "TTrueReelClick"

# interfaces
.implements Landroid/view/View$OnClickListener;


# instance fields
.field public final A00:I


# direct methods
.method public constructor <init>(I)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput p1, p0, LX/TTrueReelClick;->A00:I

    return-void
.end method


# virtual methods
.method public final onClick(Landroid/view/View;)V
    .locals 2

    :try_start_0
    iget v0, p0, LX/TTrueReelClick;->A00:I
    if-eqz v0, :cond_enter

    # mode 1: exit landscape fullscreen
    invoke-static {}, LX/TTrueReelHelper;->A26()V
    return-void

    :cond_enter
    # mode 0: enter landscape fullscreen
    invoke-static {}, LX/TTrueReelHelper;->A24()V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0
    return-void
.end method
