.386
.model flat, stdcall
option casemap:none

include button.inc

include windows.inc
include gdi32.inc
include util.inc 
include paint.inc

.data
nButtonListCnt          DWORD    0
bIfInitButtonData       DWORD    0
szDefaultButtonText     BYTE     "button",0    
szDefaultButtonClick    BYTE     "Button Clicked: %d", 0dh, 0ah, 0
szDefaultButtonHover    BYTE     "Button Hovered: %d", 0dh, 0ah, 0
szDefaultButtonUpdate   BYTE     "Button Update : %d", 0dh, 0ah, 0

.data?
arrayButtonList BUTTONDATA MAXBTNCNT DUP(<?>) ; 存储BUTTONDATA内存池

.code

; 初始化
InitButtonData     PROC uses  ebx ecx edi
    lea     edi, arrayButtonList
    mov     ebx, MAXBTNCNT
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr BUTTONDATA
        mov     eax, BTNS_UNUSED
        mov     [edi].status, ax
        mov     eax, sizeof BUTTONDATA
        add     edi, eax
        inc     ecx
    .ENDW
    xor     eax, eax
    ret
InitButtonData ENDP


; 获取一个可以存贮数据的空位
GetAvilaibleButtonData PROC uses ebx ecx edx edi
    .IF ! bIfInitButtonData
        invoke InitButtonData
        mov eax, 1
        mov bIfInitButtonData, eax
    .ENDIF
    lea     edi, arrayButtonList
    mov     ebx, nButtonListCnt
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr BUTTONDATA
        .IF     [edi].status == BTNS_UNUSED
            .break
        .ENDIF
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    .IF ecx == ebx
        inc     ebx
        mov     nButtonListCnt, ebx
    .ENDIF
    mov eax, edi
    ret
GetAvilaibleButtonData ENDP

; 注册BUTTON。相当于创建BUTTON，会自动寻找内存位置存储数据，并被PaintAllButton管理
RegisterButton      PROC    uses ebx edi esi pRect: ptr RECT, pPaint:DWORD, pClickEvent:DWORD, pHoverEvent:DWORD, pUpdateEvent:DWORD
    invoke  GetAvilaibleButtonData
    mov     esi, eax
    mov     edi, pRect
    assume  edi: ptr RECT
    assume  esi: ptr BUTTONDATA

    mov     eax, 0
    mov     [esi].depth, eax
    mov     eax, [edi].left
    mov     [esi].left, eax
    mov     eax, [edi].right
    mov     [esi].right, eax
    mov     eax, [edi].top
    mov     [esi].top, eax
    mov     eax, [edi].bottom
    mov     [esi].bottom, eax
    mov     eax, pPaint
    mov     [esi].pPaint, eax
    mov     eax, pClickEvent
    mov     [esi].pClickEvent, eax
    mov     eax, pHoverEvent
    mov     [esi].pHoverEvent, eax
    mov     eax, pUpdateEvent
    mov     [esi].pUpdateEvent, eax
    mov     [esi].status, BTNS_WAIT
    mov     [esi].isActive, BTNI_RUNNING

    .IF     [esi].pPaint == NULL
        mov     eax, ButtonDefaultPaint
        mov     [esi].pPaint, eax
    .ENDIF
    .IF     [esi].pClickEvent == NULL
        mov     eax, ButtonDefaultClick
        mov     [esi].pClickEvent, eax
    .ENDIF
    .IF     [esi].pHoverEvent == NULL
        mov     eax, ButtonDefaultHover
        mov     [esi].pHoverEvent, eax
    .ENDIF
    .IF     [esi].pUpdateEvent == NULL
        mov     eax, ButtonDefaultUpdate
        mov     [esi].pUpdateEvent, eax
    .ENDIF
    mov     eax, esi
    push    eax
    invoke  SortButtons
    pop     eax
    ret 
RegisterButton ENDP

; 绘制单个按钮
PaintButton     PROC    hDc:DWORD, pButton: ptr BUTTONDATA
    push    pButton
    push    hDc
    mov     eax, pButton
    assume  eax: ptr BUTTONDATA
    mov     eax, [eax].pPaint
    call    eax
    xor     eax, eax
    ret
PaintButton     ENDP

; 绘制所有注册过的按钮
PaintAllButton  PROC    uses ebx ecx edi hDc:DWORD
    mov     ecx, 0
    mov     ebx, nButtonListCnt
    lea     edi, arrayButtonList
    .WHILE ecx < ebx
        assume  edi: ptr BUTTONDATA
        push    ecx
        .IF [edi].status != BTNS_UNUSED 
            .IF [edi].isActive != BTNI_DISABLE
                invoke  PaintButton, hDc, edi
            .ENDIF
        .ENDIF
        ;invoke  dPrint2,2,ecx
        pop     ecx
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    xor     eax, eax
    ret
PaintAllButton  ENDP

ButtonDefaultPaint  PROC  uses ebx edi hDc: DWORD, pButton: ptr BUTTONDATA
    local   @oldPen, @oldBrush, @stRect:RECT
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    invoke  GetStockObject, BLACK_PEN
    invoke  SelectObject, hDc, eax
    mov     @oldPen, eax

    invoke  GetStockObject, GRAY_BRUSH
    mov     bx, [edi].status
    and     bx, BTNS_HOVER
    .IF     bx
        invoke  GetStockObject, LTGRAY_BRUSH
    .ENDIF
    mov     bx, [edi].status
    and     bx, BTNS_CLICK
    .IF     bx
        invoke  GetStockObject, DKGRAY_BRUSH
    .ENDIF
    invoke  SelectObject, hDc, eax
    mov     @oldBrush, eax

    
    invoke  GetButtonRect, pButton, addr @stRect
    invoke  PaintRect, hDc, addr @stRect
    invoke  TextOut, hDc, addr szDefaultButtonText, -1, pButton, \
            DT_SINGLELINE or DT_CENTER or DT_VCENTER

    invoke  SelectObject, hDc, @oldPen
    invoke  SelectObject, hDc, @oldBrush
    xor     eax, eax
    ret
ButtonDefaultPaint  ENDP

ButtonDefaultClick PROC uses ebx edi esi pButton: ptr BUTTONDATA
    invoke  printf, offset szDefaultButtonClick, pButton
    ret
ButtonDefaultClick ENDP

ButtonDefaultHover PROC uses ebx edi esi pButton: ptr BUTTONDATA
    invoke  printf, offset szDefaultButtonHover, pButton
    ret
ButtonDefaultHover ENDP

ButtonDefaultUpdate PROC uses ebx edi esi cnt:DWORD, pButton: ptr BUTTONDATA
    ;invoke  printf, offset szDefaultButtonUpdate, cnt
    ret
ButtonDefaultUpdate ENDP


GetButtonDefuatPainter proc
    mov     eax, ButtonDefaultPaint
    ret
GetButtonDefuatPainter ENDP

GetButtonRect   proc  uses ebx ecx  pButton: ptr BUTTONDATA, pRect: ptr RECT
    mov     ecx, pButton
    assume  ecx: ptr BUTTONDATA
    mov     ebx, pRect
    assume  ebx: ptr RECT
    mov     eax, [ecx].left
    mov     [ebx].left, eax
    mov     eax, [ecx].right
    mov     [ebx].right, eax
    mov     eax, [ecx].top
    mov     [ebx].top, eax
    mov     eax, [ecx].bottom
    mov     [ebx].bottom, eax
    xor     eax, eax
    assume  ebx: DWORD
    ret
GetButtonRect ENDP

DeleteButton    proc uses esi  pButton:ptr BUTTONDATA
    mov     esi, pButton
    assume  esi: ptr BUTTONDATA
    mov     [esi].status, BTNS_UNUSED
    xor     eax, eax
    ret     
DeleteButton    ENDP

InButtonRange   proc uses ebx edi pButton:ptr BUTTONDATA, x:DWORD, y:DWORD
    xor     eax, eax
    mov     ebx, x
    mov     edi, pButton
    assume  edi:ptr BUTTONDATA
    .IF (ebx > [edi].left) && (ebx <= [edi].right)
        add eax,1
    .ENDIF
    mov     ebx, y 
    .IF (ebx > [edi].top) && (ebx <= [edi].bottom)
        add eax,2
    .ENDIF
    push eax
    pop  eax
    .IF (eax == 3)
        shr eax, 1 
    .ELSE
        xor eax, eax
    .ENDIF
    ret     
InButtonRange ENDP

SendClickInfo proc uses  ebx edi esi x:DWORD, y:DWORD
    local   @cnt

    xor     ecx, ecx
    mov     ebx, nButtonListCnt
    mov     edi, offset arrayButtonList
    assume  edi: ptr BUTTONDATA
    xor     eax, eax
    mov     @cnt, eax
    
    .WHILE ecx < ebx
        push    ecx
        push    ebx
        invoke  InButtonRange, edi, x, y
        mov     dx, [edi].isActive
        and     dx, BTNI_DISABLE
        .IF !dx
            .IF eax
                push    edi
                call    [edi].pClickEvent
                mov     dx, [edi].status
                or      dx, BTNS_CLICK
                mov     [edi].status, dx
                mov     eax, @cnt
                inc     eax
                mov     @cnt, eax
            .ELSE
                mov     dx, BTNS_CLICK
                not     dx
                and     dx, [edi].status
                mov     [edi].status, dx
            .ENDIF
        .ENDIF
        xor     ebx, ebx
        mov     bx, [edi].status
        pop     ebx
        pop     ecx
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    mov     eax, @cnt
    ret
SendClickInfo ENDP

SendHoverInfo proc x:DWORD, y:DWORD
    local   @cnt

    xor     ecx, ecx
    mov     ebx, nButtonListCnt
    mov     edi, offset arrayButtonList
    assume  edi: ptr BUTTONDATA
    xor     eax, eax
    mov     @cnt, eax
    
    .WHILE ecx < ebx
        push    ecx
        push    ebx
        invoke  InButtonRange, edi, x, y
        mov     dx, [edi].isActive
        and     dx, BTNI_DISABLE
        .IF !dx
            .IF eax
                push    edi
                call    [edi].pHoverEvent
                mov     dx, [edi].status
                or      dx, BTNS_HOVER
                mov     [edi].status, dx
                mov     eax, @cnt
                inc     eax
                mov     @cnt, eax
            .ELSE
                mov     dx, BTNS_HOVER
                not     dx
                and     dx, [edi].status
                mov     [edi].status, dx
            .ENDIF
        .ENDIF
        pop     ebx
        pop     ecx
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    mov     eax, @cnt
    ret
SendHoverInfo ENDP

SendUpdateInfo proc cnt:DWORD
    local   @cnt

    xor     ecx, ecx
    mov     ebx, nButtonListCnt
    mov     edi, offset arrayButtonList
    assume  edi: ptr BUTTONDATA
    xor     eax, eax
    mov     @cnt, eax
    
    .WHILE ecx < ebx
        push    ecx
        push    ebx
        mov     dx, [edi].isActive
        and     dx, BTNI_DISABLE
        .IF !dx
            push    edi
            push    cnt
            call    [edi].pUpdateEvent
        .ENDIF
        pop     ebx
        pop     ecx
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    mov     eax, @cnt
    ret
SendUpdateInfo ENDP

ClearClick proc 
    xor     ecx, ecx
    mov     ebx, nButtonListCnt
    mov     edi, offset arrayButtonList
    assume  edi: ptr BUTTONDATA
    .WHILE ecx < ebx
        mov     dx, BTNS_CLICK
        not     dx
        and     dx, [edi].status
        mov     [edi].status, dx
        add     edi, sizeof BUTTONDATA
        inc     ecx
    .ENDW
    mov     eax, 0
    ret
ClearClick ENDP

CompareByDepth  PROC    uses ebx esi edi buttonA: PTR BUTTONDATA, buttonB: PTR BUTTONDATA
    mov     esi, buttonA
    mov     edi, buttonB
    assume  esi: PTR BUTTONDATA
    assume  edi: PTR BUTTONDATA

    mov     esi, [esi].depth
    mov     edi, [edi].depth

    xor     eax, eax
    .IF     esi < edi
            mov     eax, -1
    .ENDIF
    .IF     esi > edi
            mov     eax, 1
    .ENDIF
    ret
CompareByDepth  ENDP


SetButtonDepth  PROC  uses edi pButton: ptr BUTTONDATA, depth:DWORD
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     eax, depth
    mov     [edi].depth, eax
    ret
SetButtonDepth  ENDP 


GetButtonDepth  PROC  pButton: ptr BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     eax, [edi].depth
    ret
GetButtonDepth  ENDP


SortButtons     PROC    uses ebx esi edi
    mov     edi, offset arrayButtonList
    mov     ecx, nButtonListCnt
    invoke  qsort, edi, ecx, sizeof BUTTONDATA, CompareByDepth
    ret
SortButtons     ENDP 

end
