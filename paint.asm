.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc

include paint.inc
include util.inc

.code
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
GetCircleRect endp

PaintCircle    PROC     hDc:DWORD, lpCircle: ptr CIRCLEDATA
    local   @stRect:RECT
    
    invoke  GetCircleRect, lpCircle, addr @stRect
    invoke  Ellipse, hDc, @stRect.left, @stRect.top, @stRect.right, @stRect.bottom

    ret
PaintCircle endp

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
PaintCircleCR endp

PrepareBitmapPaint  PROC  uses edi ebx  hInstance:DWORD, hDc:DWORD, bitmapID:DWORD, lpBitmapData:ptr BITMAPDATA
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
PrepareBitmapPaint endp

ReleaseBitmapData  PROC uses edi lpBitmapData: ptr BITMAPDATA
    mov     edi, lpBitmapData
    assume  edi: ptr BITMAPDATA

    invoke  DeleteDC, [edi].hDcBitmap
    invoke  DeleteObject, [edi].hBitmap

    xor     eax, eax
    ret
ReleaseBitmapData  endp

PaintBitmap     PROC  uses edi  hInstance:DWORD, hDc:DWORD, bitmapID:DWORD, posX:DWORD, posY:DWORD
    local   @stBitmapData:BITMAPDATA

    invoke  PrepareBitmapPaint, hInstance, hDc, bitmapID, addr @stBitmapData
    invoke  BitBlt, hDc, posX, posY, @stBitmapData.w, @stBitmapData.h, @stBitmapData.hDcBitmap, 0, 0, SRCCOPY
    invoke  ReleaseBitmapData, addr @stBitmapData

    ret
PaintBitmap endp

PaintBitmapEx PROC uses edi ebx hInstance:DWORD, hDc:DWORD, bitmapID:DWORD, lpRect:ptr RECT, optionCode:DWORD
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

    invoke  PrepareBitmapPaint, hInstance, hDc, bitmapID, addr @stBitmapData
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
PaintBitmapEx endp

PaintRect  proc   hDc:DWORD, lpRect:ptr RECT
    mov     eax, lpRect
    assume  eax: ptr RECT
    invoke  Rectangle, hDc, [eax].left, [eax].top, [eax].right, [eax].bottom
    ret
PaintRect endp

end
