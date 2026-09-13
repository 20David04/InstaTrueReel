.class public LX/TTrueReelViewSave;
.super Ljava/lang/Object;
.source "TTrueReelViewSave"


# instance fields
.field public A00:Landroid/view/View;      # the liberated view
.field public A01:I                        # original paddingTop
.field public A02:I                        # original paddingBottom
.field public A03:I                        # original bottomMargin (-1 = had no MarginLayoutParams)
.field public A04:Z                        # original fitsSystemWindows


# direct methods
.method public constructor <init>(Landroid/view/View;IIIZ)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, LX/TTrueReelViewSave;->A00:Landroid/view/View;
    iput p2, p0, LX/TTrueReelViewSave;->A01:I
    iput p3, p0, LX/TTrueReelViewSave;->A02:I
    iput p4, p0, LX/TTrueReelViewSave;->A03:I
    iput-boolean p5, p0, LX/TTrueReelViewSave;->A04:Z

    return-void
.end method
