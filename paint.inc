STRETCH_MASK    EQU     0000000fh
STRETCH_NONE    EQU     00000000h
STRETCH_X       EQU     00000001h
STRETCH_Y       EQU     00000002h
STRETCH_XY      EQU     00000003h

CENTER_MASK     EQU     000000f0h
CENTER_NONE     EQU     00000000h
CENTER_XY       EQU     00000030h

MAXBITMAP       EQU     1000h

EXTERNDEF  stageWidth:DWORD
EXTERNDEF  stageHeight:DWORD


CIRCLEDATA struct
    centerX        DWORD   ? 
    centerY        DWORD   ?
    r              DWORD   ?
CIRCLEDATA ends

BITMAPDATA struct
    w              DWORD   ?
    h              DWORD   ?
    hDcBitmap      DWORD   ?
    hBitmap        DWORD   ?
BITMAPDATA ends

InitPaint       PROTO   

LoadAllBitmap       PROTO
ReleaseAllBitmap    PROTO

GetCircleRect   PROTO   lpCircle: ptr CIRCLEDATA, lpRect: ptr RECT
PaintCircleCR   PROTO   hDc:DWORD, centerX:DWORD, centerY:DWORD, r:DWORD
PaintRect       PROTO   hDc:DWORD, lpRect:ptr RECT
PaintRoundRect  PROTO   hDc:DWORD, lpRect:ptr RECT, r:DWORD
SetPen          PROTO   hdc:DWORD, fnPenStyle:DWORD, nWidth:DWORD, crColor:DWORD

GetBitmapSize   PROTO   bitmapID:DWORD, pPoint:ptr D_POINT
PaintBitmap     PROTO   hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
PaintBitmapEx   PROTO   hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
PaintBitmapTrans     PROTO   hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
PaintBitmapTransEx   PROTO   hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
RotateDCi       PROTO   hdc:DWORD, iAngle:DWORD, x:DWORD, y:DWORD
RotateDC        PROTO   hdc:DWORD, fAngle:DWORD, x:DWORD, y:DWORD
ClearDCRotate   PROTO   hdc:DWORD


