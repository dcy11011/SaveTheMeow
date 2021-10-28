STRETCH_MASK    EQU     0000000fh
STRETCH_NONE    EQU     00000000h
STRETCH_X       EQU     00000001h
STRETCH_Y       EQU     00000002h
STRETCH_XY      EQU     00000003h

CENTER_MASK     EQU     000000f0h
CENTER_NONE     EQU     00000000h
CENTER_XY       EQU     00000030h



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

GetCircleRect   PROTO   lpCircle: ptr CIRCLEDATA, lpRect: ptr RECT
PaintCircleCR   PROTO   hDc:DWORD, centerX:DWORD, centerY:DWORD, r:DWORD
PaintRect       PROTO   hDc:DWORD, lpRect:ptr RECT

GetBitmapSize   PROTO   bitmapID:DWORD, pPoint:ptr D_POINT
PaintBitmap     PROTO   hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
PaintBitmapEx   PROTO   hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
RotateDC        PROTO   hdc:DWORD, iAngle:DWORD, x:DWORD, y:DWORD
ClearDCRotate   PROTO   hdc:DWORD

