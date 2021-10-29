.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc

include button.inc
include paint.inc
include util.inc

include rclist.inc

include mapblock.inc


.data
nMapBlockListCnt           DWORD    0
bIfInitMapBlockData        DWORD    0

.data?
arrayMapBlockList MAPBLOCKDATA MAXMAPBLOCKCNT DUP(<?>)

.code

InitMapBlockData proc uses  ebx edi
    lea     edi, arrayMapBlockList
    mov     ebx, MAXMAPBLOCKCNT
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr MAPBLOCKDATA
        mov     [edi].status, MAPB_UNUSED
        add     edi, sizeof MAPBLOCKDATA
        inc     ecx
    .ENDW
    xor     eax, eax
    ret
InitMapBlockData endp


GetAvilaibleMapBlockData proc uses ebx edx edi
    .IF ! bIfInitMapBlockData
        invoke InitMapBlockData
        mov bIfInitMapBlockData, 1
    .ENDIF
    lea     edi, arrayMapBlockList
    mov     ebx, nMapBlockListCnt
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr MAPBLOCKDATA
        .IF     [edi].status == MAPB_UNUSED
            .break
        .ENDIF
        add     edi, sizeof MAPBLOCKDATA
        inc     ecx
    .ENDW
    .IF ecx == ebx
        inc     ebx
        mov     nMapBlockListCnt, ebx
    .ENDIF
    mov eax, edi
    ret
GetAvilaibleMapBlockData endp

MapBlockBasePaint   PROC uses ebx esi edi  hdc:DWORD, pButton:PTR BUTTONDATA
    local   @rect:RECT, @oldPen:HPEN, @oldBrush:HBRUSH
    invoke  GetButtonRect, pButton, addr @rect
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    xor     ebx, ebx
    mov     bx, [edi].status
    and     bx, BTNS_HOVER
    mov     esi, 0055AAh
    .IF bx
        mov     esi, 0066FFFFh
    .ENDIF
    mov     bx, [edi].status
    and     bx, BTNS_CLICK
    .IF bx
        mov     esi, 00339999h
    .ENDIF
    invoke  SetPen, hdc, PS_SOLID, 2, esi
    mov     @oldPen, eax
    invoke  GetStockObject, NULL_BRUSH
    invoke  SelectObject, hdc, eax
    mov     @oldBrush, eax
    invoke  PaintRoundRect, hdc, addr @rect, 5
    invoke  SelectObject, hdc, @oldBrush
    invoke  SelectObject, hdc, @oldPen
    invoke  DeleteObject, eax
    ret
MapBlockBasePaint   ENDP


MapBlockClicked PROC uses ebx esi edi   pButton: ptr BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    mov     eax, [edi].status
    .IF     eax == MAPB_DISABLED
        ret
    .ENDIF
    .IF     eax == MAPB_WAITING || eax == MAPB_CONTRACTING
        mov     eax, MAPB_POPPING
        mov     [edi].status, eax
    .ELSEIF eax == MAPB_POPPING  || eax == MAPB_POPPED
        mov     eax, MAPB_CONTRACTING
        mov     [edi].status, eax
    .ENDIF
    ret
MapBlockClicked ENDP

MapBlockUpdate  PROC uses ebx esi edi   cnt:DWORD, pButton: ptr BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    mov     eax, [edi].status
    
    .IF     eax == MAPB_POPPING
        mov     eax, [edi].action_step
        ;invoke  dPrint, eax
        .IF     eax <= 0
            invoke  MoveButtonTo, [edi].pButton1, [edi].centerX, [edi].centerY
            invoke  MoveButtonTo, [edi].pButton2, [edi].centerX, [edi].centerY
            invoke  MoveButtonTo, [edi].pButton3, [edi].centerX, [edi].centerY
            invoke  dPrint3, 0, 3, [edi].pButton1
            invoke  dPrint3, 0, 3, [edi].pButton2
            invoke  dPrint3, 0, 3, [edi].pButton3
        .ENDIF
        mov     eax, [edi].action_step
        inc     eax
        mov     [edi].action_step, eax
        .IF     eax >= MAPB_MAXSTEP
            mov     ebx, MAPB_POPPED
            mov     [edi].status, ebx
        .ENDIF 
    .ELSEIF eax == MAPB_CONTRACTING
        mov     eax, [edi].action_step
        sub     eax, 1
        mov     [edi].action_step, eax
        .IF     eax <= 0
            mov     ebx, MAPB_WAITING
            mov     [edi].status, ebx
        .ENDIF 
        .IF     eax <= 0
            invoke  MoveButtonTo, [edi].pButton1, -100, -100
            invoke  MoveButtonTo, [edi].pButton2, -100, -100
            invoke  MoveButtonTo, [edi].pButton3, -100, -100
        .ENDIF
        
    .ENDIF
    ret
MapBlockUpdate  ENDP

RegisterMapBlock    PROC uses ebx esi edi    posX:DWORD, posY:DWORD
    local   @rect:RECT
    lea     esi, @rect
    assume  esi: ptr RECT
    mov     ebx, posX
    mov     [esi].left, ebx
    add     ebx, MAPB_BLOCKWIDTH
    mov     [esi].right, ebx
    mov     ebx, posY
    mov     [esi].top , ebx
    add     ebx, MAPB_BLOCKHEIGHT
    mov     [esi].bottom, ebx

    invoke  GetAvilaibleMapBlockData
    mov     edi, eax
    assume  edi: ptr MAPBLOCKDATA
    invoke  RegisterButton, addr @rect, MapBlockBasePaint, MapBlockClicked,0,MapBlockUpdate
    mov     [edi].pAsButton, eax
    invoke  dPrint, eax
    mov     esi, eax
    assume  esi: ptr BUTTONDATA
    mov     [esi].bParam, edi

    lea     esi, @rect
    assume  esi: ptr RECT
    mov     ebx, 20
    mov     [esi].top, ebx
    mov     [esi].left, ebx
    mov     ebx, 30
    mov     [esi].bottom, ebx
    mov     [esi].right, ebx
    invoke  RegisterButton, addr @rect, 0,0,0,0
    ;invoke  SetButtonSize, eax, 30, 30
    ;invoke  BindButtonToBitmap, eax, MAP_BLOCK
    mov     [edi].pButton1, eax
    invoke  SetButtonDepth, eax, -1
    invoke  dPrint3, 0, 1, eax
    
    invoke  RegisterButton, addr @rect, 0,0,0,0
    invoke  BindButtonToBitmap, eax, MAP_BLOCK
    mov     [edi].pButton2, eax
    invoke  SetButtonDepth, eax, -2
    invoke  dPrint3, 0, 1, eax

    invoke  RegisterButton, addr @rect, 0,0,0,0
    invoke  BindButtonToBitmap, eax, MAP_BLOCK
    mov     [edi].pButton3, eax
    invoke  SetButtonDepth, eax, -3
    invoke  dPrint3, 0, 1, eax


    mov     ebx, MAPB_WAITING
    mov     [edi].status, ebx
    mov     ebx, 0
    mov     [edi].action_step, ebx
    mov     ebx, MAPB_BLOCKWIDTH
    shr     ebx, 1
    add     ebx, posX
    mov     [edi].centerX, ebx
    mov     ebx, MAPB_BLOCKHEIGHT
    shr     ebx, 1
    add     ebx, posY
    mov     [edi].centerY, ebx
    invoke  dPrint3, 0, 0 ,edi
    mov     eax, edi
    ret
RegisterMapBlock    ENDP

end