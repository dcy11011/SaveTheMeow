.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
include msimg32.inc

include paint.inc
include util.inc
include main.inc

.data
stageWidth      DWORD 0
stageHeight     DWORD 0

.data?
blendFunction   BLENDFUNCTION   <?>


.code

InitPaint   PROC    uses ebx edi esi 
    mov     al, AC_SRC_OVER
    mov     blendFunction.BlendOp, al
    mov     al, 0
    mov     blendFunction.BlendFlags, al
    mov     al, 255
    mov     blendFunction.BlendFlags, al
    mov     al, AC_SRC_ALPHA
    mov     blendFunction.BlendFlags, al
    ret
InitPaint   ENDP

GetCircleRect  PROC  uses ebx ecx edx lpCircle: ptr CIRCLEDATA, lpRect: ptr RECT
    mov     edx, lpRect
    assume  edx: ptr RECT
    mov     ebx, lpCircle
    assume  ebx: ptr CIRCLEDATA

    mov     eax, [ebx].r
    mov     ecx, [ebx].centerX
    sub     ecx, eax
    mov     [edx].left, ecx
    shl     eax, 1
    add     ecx, eax
    mov     [edx].right, ecx
    mov     ecx, [ebx].centerY
    shr     eax, 1
    sub     ecx, eax
    mov     [edx].top, ecx
    shl     eax, 1
    add     ecx, eax
    mov     [edx].bottom, ecx

    xor     eax, eax
    ret
GetCircleRect ENDP

PaintCircle    PROC     hDc:DWORD, lpCircle: ptr CIRCLEDATA
    local   @stRect:RECT
    
    invoke  GetCircleRect, lpCircle, addr @stRect
    invoke  Ellipse, hDc, @stRect.left, @stRect.top, @stRect.right, @stRect.bottom

    ret
PaintCircle ENDP

PaintCircleCR  PROC    hDc:DWORD, centerX:DWORD, centerY:DWORD, r:DWORD
    local   @stCircle:CIRCLEDATA

    mov     eax, centerX
    mov     @stCircle.centerX, eax
    mov     eax, centerY
    mov     @stCircle.centerY, eax
    mov     eax, r
    mov     @stCircle.r, eax

    invoke  PaintCircle, hDc, addr @stCircle
    ret
PaintCircleCR ENDP

PrepareBitmapPaint  PROC  uses edi ebx  hDc:DWORD, bitmapID:DWORD, lpBitmapData:ptr BITMAPDATA
    local   @hDcBitmap
    local   @hBitmap, @bitmap[32]:byte
    local   @w, @h

    mov     edi, lpBitmapData
    assume  edi: ptr BITMAPDATA

    invoke  CreateCompatibleDC, hDc
    mov     @hDcBitmap, eax
    mov     [edi].hDcBitmap, eax
    invoke  LoadBitmap, hInstance, bitmapID
    mov     @hBitmap, eax
    mov     [edi].hBitmap, eax
    invoke  SelectObject, @hDcBitmap, @hBitmap
    invoke  GetObject, @hBitmap, 32, addr @bitmap
    lea     eax, @bitmap
    mov     ebx, [eax+4]
    mov     [edi].w, ebx
    mov     ebx, [eax+8]
    mov     [edi].h, ebx
    xor     eax, eax
    ret
PrepareBitmapPaint ENDP

GetBitmapSize       PROC uses edi ebx bitmapID:DWORD, pPoint:ptr D_POINT
    local   @hBitmap:DWORD, @bitmap[32]:byte
    invoke  LoadBitmap, hInstance, bitmapID
    mov     @hBitmap, eax
    invoke  GetObject, @hBitmap, 32, addr @bitmap
    lea     eax, @bitmap
    mov     edi, pPoint
    assume  edi: ptr D_POINT
    mov     ebx, [eax+4]
    mov     [edi].x, ebx
    mov     ebx, [eax+8]
    mov     [edi].y, ebx
    xor     eax, eax
    ret
GetBitmapSize       ENDP 

ReleaseBitmapData  PROC uses edi lpBitmapData: ptr BITMAPDATA
    mov     edi, lpBitmapData
    assume  edi: ptr BITMAPDATA

    invoke  DeleteDC, [edi].hDcBitmap
    invoke  DeleteObject, [edi].hBitmap

    xor     eax, eax
    ret
ReleaseBitmapData  ENDP

PaintBitmap     PROC  uses edi  hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
    local   @stBitmapData:BITMAPDATA

    invoke  PrepareBitmapPaint, hDc, bitmapID, addr @stBitmapData
    invoke  BitBlt, hDc, posX, posY, @stBitmapData.w, @stBitmapData.h, @stBitmapData.hDcBitmap, 0, 0, SRCCOPY
    invoke  ReleaseBitmapData, addr @stBitmapData

    ret
PaintBitmap ENDP

PaintBitmapTrans     PROC  uses edi  hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
    local   @stBitmapData:BITMAPDATA

    invoke  PrepareBitmapPaint, hDc, bitmapID, addr @stBitmapData
    invoke  TransparentBlt, hDc, posX, posY, @stBitmapData.w, @stBitmapData.h, @stBitmapData.hDcBitmap, 0, 0, @stBitmapData.w, @stBitmapData.h, 0
    invoke  ReleaseBitmapData, addr @stBitmapData

    ret
PaintBitmapTrans ENDP

PaintBitmapTransEx     PROC  uses edi ebx hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
    local   @stBitmapData:BITMAPDATA
    local   @areaW, @areaH
    local   @srcW, @srcH, @tarW, @tarH; source width&height and target width&height
    local   @posX, @posY; target left-top corner

    mov     edi,lpRect
    assume  edi: ptr RECT

    mov     eax, [edi].right
    mov     ebx, [edi].left
    mov     @posX, ebx
    sub     eax, ebx
    mov     @areaW, eax
    mov     @tarW, eax
    mov     eax, [edi].bottom
    mov     ebx, [edi].top
    mov     @posY, ebx
    sub     eax, ebx
    mov     @areaH, eax
    mov     @tarH, eax

    invoke  PrepareBitmapPaint, hDc, bitmapID, addr @stBitmapData
    mov     eax, @stBitmapData.w
    mov     ebx, @stBitmapData.h
    mov     @srcW, eax
    mov     @srcH, ebx

    mov     eax, optionCode
    and     eax, STRETCH_X
    .IF     eax == 0
        mov     eax, @srcW
        mov     @tarW, eax
    .ENDIF
    mov     eax, optionCode
    and     eax, STRETCH_Y
    .IF     eax == 0
        mov     eax, @srcH
        mov     @tarH, eax
    .ENDIF
    mov     eax, optionCode
    and     eax, CENTER_MASK
    .IF     eax == CENTER_XY
        mov     eax, @tarW
        mov     ebx, @areaW
        sub     ebx, eax
        sar     ebx, 1
        mov     eax, @posX
        add     eax, ebx
        mov     @posX, eax

        mov     eax, @tarH
        mov     ebx, @areaH
        sub     ebx, eax
        sar     ebx, 1
        mov     eax, @posY
        add     eax, ebx
        mov     @posY, eax
    .ENDIF

    invoke  SetStretchBltMode, hDc, HALFTONE
    invoke  TransparentBlt, hDc, @posX, @posY, @tarW, @tarH, \
            @stBitmapData.hDcBitmap, 0, 0, @srcW, @srcH, \
            0
    invoke  ReleaseBitmapData, addr @stBitmapData
    ret
PaintBitmapTransEx ENDP

PaintBitmapEx PROC uses edi ebx hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
    local   @stBitmapData:BITMAPDATA
    local   @areaW, @areaH
    local   @srcW, @srcH, @tarW, @tarH; source width&height and target width&height
    local   @posX, @posY; target left-top corner

    mov     edi,lpRect
    assume  edi: ptr RECT

    mov     eax, [edi].right
    mov     ebx, [edi].left
    mov     @posX, ebx
    sub     eax, ebx
    mov     @areaW, eax
    mov     @tarW, eax
    mov     eax, [edi].bottom
    mov     ebx, [edi].top
    mov     @posY, ebx
    sub     eax, ebx
    mov     @areaH, eax
    mov     @tarH, eax

    invoke  PrepareBitmapPaint, hDc, bitmapID, addr @stBitmapData
    mov     eax, @stBitmapData.w
    mov     ebx, @stBitmapData.h
    mov     @srcW, eax
    mov     @srcH, ebx

    mov     eax, optionCode
    and     eax, STRETCH_X
    .IF     eax == 0
        mov     eax, @srcW
        mov     @tarW, eax
    .ENDIF
    mov     eax, optionCode
    and     eax, STRETCH_Y
    .IF     eax == 0
        mov     eax, @srcH
        mov     @tarH, eax
    .ENDIF
    mov     eax, optionCode
    and     eax, CENTER_MASK
    .IF     eax == CENTER_XY
        mov     eax, @tarW
        mov     ebx, @areaW
        sub     ebx, eax
        sar     ebx, 1
        mov     eax, @posX
        add     eax, ebx
        mov     @posX, eax

        mov     eax, @tarH
        mov     ebx, @areaH
        sub     ebx, eax
        sar     ebx, 1
        mov     eax, @posY
        add     eax, ebx
        mov     @posY, eax
    .ENDIF

    invoke  SetStretchBltMode, hDc, HALFTONE
    invoke  StretchBlt, hDc, @posX, @posY, @tarW, @tarH, \
            @stBitmapData.hDcBitmap, 0, 0, @srcW, @srcH, \
            SRCCOPY
    invoke  ReleaseBitmapData, addr @stBitmapData
    ret
PaintBitmapEx ENDP

PaintRect  proc   uses edi hDc:DWORD, lpRect:ptr RECT
    mov     edi, lpRect
    assume  edi: ptr RECT
    invoke  Rectangle, hDc, [edi].left, [edi].top, [edi].right, [edi].bottom
    ret
PaintRect ENDP

PaintRoundRect  proc   hDc:DWORD, lpRect:ptr RECT, r:DWORD
    mov     edi, lpRect
    assume  edi: ptr RECT
    invoke  RoundRect, hDc, [edi].left, [edi].top, [edi].right, [edi].bottom, r, r
    ret
PaintRoundRect ENDP

RotateDC    PROC uses ebx esi edi hdc:DWORD, iAngle:DWORD, x:DWORD, y:DWORD
    local   @nGraphicsMode:DWORD, @fangle:REAL4, @ftmp:REAL4
    local   @xform:XFORM
    local   @f180: DWORD
    lea     edi, @xform
    assume  edi: PTR XFORM
    invoke  SetGraphicsMode, hdc, GM_ADVANCED
    .IF     iAngle != 0
        fild    DWORD ptr iAngle
        mov     @f180, 180
        fidiv   @f180
        fmul    PI
        fstp    DWORD ptr @fangle
        fld     DWORD ptr @fangle
        fcos    
        fstp    DWORD ptr @ftmp
        mov     eax, @ftmp
        mov     [edi].eM11, eax
        mov     [edi].eM22, eax
        fld     DWORD ptr @fangle
        fsin    
        fstp    DWORD ptr @ftmp
        mov     eax, @ftmp
        mov     [edi].eM12, eax
        xor     eax, 80000000h
        mov     [edi].eM21, eax
        fild    DWORD ptr x
        fld     DWORD ptr @fangle
        fcos
        fild    DWORD ptr x
        fmul
        fsub
        fld     DWORD ptr @fangle
        fsin
        fild    DWORD ptr y
        fmul
        fadd
        fstp    DWORD ptr @ftmp
        mov     eax, @ftmp
        mov     [edi].ex, eax
        
        fild    DWORD ptr y
        fld     DWORD ptr @fangle
        fcos
        fild    DWORD ptr y
        fmul
        fsub
        fld     DWORD ptr @fangle
        fsin
        fild    DWORD ptr x
        fmul
        fsub
        fstp    DWORD ptr @ftmp
        mov     eax, @ftmp
        mov     [edi].ey, eax
        invoke  SetWorldTransform, hdc, edi
    .ENDIF
    mov     eax, @nGraphicsMode
    ret
RotateDC    ENDP

ClearDCRotate  PROC uses ebx esi edi hdc:DWORD
    local   @xform:XFORM, @tmp:DWORD
    lea     edi, @xform
    assume  edi: PTR XFORM
    invoke  SetGraphicsMode, hdc, GM_ADVANCED
    mov     eax, 0
    mov     [edi].ey, eax
    mov     [edi].ex, eax
    mov     [edi].eM12, eax
    mov     [edi].eM21, eax
    mov     eax, 1
    mov     @tmp, eax
    fild    DWORD ptr @tmp
    fstp    DWORD ptr @tmp
    mov     eax, @tmp
    mov     [edi].eM11, eax
    mov     [edi].eM22, eax
    invoke  SetWorldTransform, hdc, edi
    ret
ClearDCRotate    ENDP

SetPen  PROC  uses ebx edi esi  hdc:DWORD, fnPenStyle:DWORD, nWidth:DWORD, crColor:DWORD
    local   @hpen:HPEN
    invoke  CreatePen, fnPenStyle, nWidth, crColor
    invoke  SelectObject, hdc, eax
    ret
SetPen  ENDP

end
