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
include collision.inc
include enemy.inc

include rclist.inc

include mapblock.inc


.data
nMapBlockListCnt           DWORD    0
bIfInitMapBlockData        DWORD    0
defaultAngset              DWORD    210, 90, 330, 135, 45, 135, 45
defualtButtonGroupID       DWORD    1, 1, 1, 2, 2, 3, 3
popRatio                   REAL4    0.3
one                        REAL4    1.0
szMapFileName              BYTE     "map0.data", 0
pLastMapBlock              DWORD    0

.data?
ptRoutePoint               D_POINT  MAX_ROUTEPOINT DUP(<?>)
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
    mov     esi, pLastMapBlock
    assume  esi: ptr MAPBLOCKDATA
    .IF     esi != edi && esi !=0
        mov     eax, MAPB_CONTRACTING
        mov     [esi].status, eax
    .ENDIF
    mov     pLastMapBlock, edi
    .IF     eax == MAPB_DISABLED
        ret
    .ENDIF
    .IF     eax == MAPB_CONTRACTING 
        mov     eax, MAPB_POPPING
        mov     [edi].status, eax
    .ELSEIF eax == MAPB_POPPING  
        mov     eax, MAPB_CONTRACTING
        mov     [edi].status, eax
    .ENDIF
    ret
MapBlockClicked ENDP

MapBlockUpdate  PROC uses ebx esi edi   cnt:DWORD, pButton: ptr BUTTONDATA
    local   @float:REAL4, @ang:REAL4, @intager:DWORD, @x:DWORD, @y:DWORD, @currentDisplay:DWORD
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    
    mov     ebx, [edi].diaplaySet
    mov     @currentDisplay, ebx
    mov     ebx, [edi].action_step
    mov     @float, ebx

    push    edi
    push    esi
    mov     ecx, MAPB_BTNTOTAL
    lea     esi, [edi].pButton
    lea     edi, [edi].angButton
    lea     edx, defualtButtonGroupID
    s9:     
        push    edx
        mov     edx, DWORD PTR [edx]
        .IF     edx != @currentDisplay
            mov     eax, DWORD ptr [esi]
            invoke  MoveButtonCenterTo, eax, -100, -100
            jmp     s8
        .ENDIF
        mov     edx, DWORD ptr [edi]          ;  edx = angle ( in degree )
        mov     @intager,  edx
        fild    DWORD ptr @intager
        mov     eax, 180
        mov     @intager, eax
        fidiv   DWORD ptr @intager
        fldpi   
        fmul
        fstp    DWORD ptr @ang    ; @ang = angle (in rad )

        fld     @ang
        fcos    
        mov     @intager, MAPB_BTNDISTANCE
        fimul   DWORD ptr @intager
        mov     @float, ebx         ; @float   = action_step
        fmul    DWORD ptr @float
        fistp   DWORD ptr @x  ; @x = cos(ang)*d*action_step

        fld     @ang
        fsin    
        mov     @intager, MAPB_BTNDISTANCE
        fimul   DWORD ptr @intager
        mov     @float, ebx         ; @float   = action_step
        fmul    DWORD ptr @float
        fistp   DWORD ptr @y  ; @y = sin(ang)*d*action_step

        push    edi
        mov     edi, pButton
        assume  edi: ptr BUTTONDATA
        mov     edi, [edi].bParam
        assume  edi: ptr MAPBLOCKDATA
        mov     eax, [edi].centerX
        add     eax, @x
        mov     @x, eax
        mov     edx, [edi].centerY
        sub     edx, @y
        mov     @y, edx
        mov     eax, DWORD ptr [esi]
        invoke  MoveButtonCenterTo, eax, @x, @y

        pop     edi

        mov     edx, MAPB_BTNWIDTH
        mov     @intager, edx
        fild    @intager
        mov     @float, ebx
        fmul    @float
        fistp   @x

        mov     edx, MAPB_BTNHEIGHT
        mov     @intager, edx
        fild    @intager
        mov     @float, ebx
        fmul    @float
        fistp   @y
        invoke  SetButtonSize, eax, @x, @y
        
s8:     pop     edx
        add     edx, sizeof DWORD
        add     esi, sizeof DWORD
        add     edi, sizeof DWORD
        dec     ecx
        test    ecx, ecx
    jnz   s9

    pop     esi
    pop     edi

    assume  edi: ptr MAPBLOCKDATA
    mov     eax, [edi].status
    .IF     eax == MAPB_POPPING
        invoke  Lerp, one, ebx, popRatio
        mov     [edi].action_step, eax
    .ELSEIF eax == MAPB_CONTRACTING
        invoke  Lerp, 0, ebx, popRatio
        mov     [edi].action_step, eax
    .ENDIF
    ret
MapBlockUpdate  ENDP

TurrentUpdate   PROC uses ebx esi edi  cnt:DWORD, pButton: ptr BUTTONDATA
    local   @integer:DWORD, @siz:D_POINT
    mov     esi, pButton
    assume  esi: PTR BUTTONDATA
    mov     edi, [esi].bParam
    assume  edi: PTR MAPBLOCKDATA

    fild    cnt
    mov     eax, 180
    mov     @integer, eax
    fidiv   @integer
    fldpi   
    fmul
    fstp    [edi].turretAngle 


    ret
TurrentUpdate   ENDP

PaintTurret     PROC    uses ebx esi edi    hdc:DWORD, pButton: PTR BUTTONDATA
    local   @pos:D_POINT, @rect:RECT, @siz:D_POINT
    local   @integer:DWORD
    mov     esi, pButton
    assume  esi: PTR BUTTONDATA
    .IF     [esi].cParam == 0
        ret
    .ENDIF

    mov     edi, [esi].bParam
    assume  edi: PTR MAPBLOCKDATA

    invoke  GetButtonRect, esi, addr @rect

    invoke  RotateDC, hdc, [edi].turretAngle,[edi].centerX, [edi].centerY 
    invoke  PaintBitmapTransEx, hdc, [esi].aParam, addr @rect ,STRETCH_XY
    invoke  ClearDCRotate, hdc

    ret
PaintTurret     ENDP

CreateTurret        PROC uses ebx esi edi    pMapBlock: PTR MAPBLOCKDATA, turretID:DWORD
    mov     edi, pMapBlock
    assume  edi: PTR MAPBLOCKDATA
    mov     eax, turretID
    mov     [edi].turretID, eax
    invoke  SetMapBlockDisplaySet, edi, 2
    mov     esi, [edi].pTurret
    assume  esi: PTR BUTTONDATA
    mov     [esi].bParam, edi
    mov     eax, turretID
    .IF     eax == A_TURRET
        mov     eax, TURRENT_A
        mov     [esi].aParam, eax
    .ELSEIF eax == B_TURRET
        mov     eax, TURRENT_B
        mov     [esi].aParam, eax
    .ELSEIF eax == C_TURRET
        mov     eax, TURRENT_C
        mov     [esi].aParam, eax
    .ENDIF
    mov     [esi].pPaint, PaintTurret
    mov     [esi].pUpdateEvent, TurrentUpdate
    mov     ax, BTNI_DISABLE_HOVER or BTNI_DISABLE_CLICK
    mov     [esi].isActive, ax
    mov     eax, one
    mov     [esi].cParam, eax
    invoke  SetButtonSize, esi, MAPB_BLOCKWIDTH, MAPB_BLOCKHEIGHT
    invoke  MoveButtonCenterTo, esi, [edi].centerX, [edi].centerY
    ret
CreateTurret    ENDP

CreateTurretA       PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  CreateTurret, edi, A_TURRET
    ret
CreateTurretA       ENDP

CreateTurretB       PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  CreateTurret, edi, B_TURRET
    ret
CreateTurretB       ENDP

CreateTurretC       PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  CreateTurret, edi, C_TURRET
    ret
CreateTurretC       ENDP

DeleteTurret       PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  SetMapBlockDisplaySet, edi, 3
    mov     eax, MAPB_POPPING
    mov     [edi].status, eax
    ret
DeleteTurret       ENDP

ReallyDeleteTurret  PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  SetMapBlockDisplaySet, edi, 1
    invoke  MoveButtonCenterTo, [edi].pTurret, -100, -100
    ret
ReallyDeleteTurret   ENDP

CancelDeleteTurret  PROC uses ebx esi edi    pButton: PTR BUTTONDATA
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    mov     edi, [edi].bParam
    assume  edi: ptr MAPBLOCKDATA
    invoke  SetMapBlockDisplaySet, edi, 2
    ret
CancelDeleteTurret  ENDP

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
    invoke  RegisterButton, addr @rect, 0, MapBlockClicked,0,MapBlockUpdate
    invoke  BindButtonToBitmap, eax, BMP_BASE
    invoke  SetButtonSize, eax, MAPB_BLOCKWIDTH, MAPB_BLOCKHEIGHT
    mov     [edi].pAsButton, eax
    mov     esi, eax
    assume  esi: ptr BUTTONDATA
    mov     [esi].bParam, edi

    ; Create pop out buttons 
    mov     ecx, MAPB_BTNTOTAL
    lea     esi, [edi].pButton
    push    ebx
@@: 
    invoke  RegisterButton, addr @rect, 0, 0, 0, 0
    mov     DWORD ptr [esi], eax
    invoke  SetButtonSize, eax, MAPB_BTNWIDTH, MAPB_BTNHEIGHT
    invoke  MoveButtonTo, eax, -100, -100
    assume  eax: PTR BUTTONDATA
    mov     [eax].bParam, edi
    mov     ebx, -5000
    sub     ebx, ecx
    invoke  SetButtonDepth, eax, ebx
    add     esi, sizeof DWORD
    loop    @B

    ; set pop button angles
    mov     ecx, MAPB_BTNTOTAL
    lea     esi, [edi].angButton
    push    edi
    lea     edi, defaultAngset
@@: mov     eax, DWORD ptr [edi]
    mov     DWORD ptr [esi], eax
    add     esi, sizeof DWORD
    add     edi, sizeof DWORD
    loop    @B

    pop     edi
    pop     ebx

    mov     ebx, MAPB_CONTRACTING
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

    mov     eax, 1
    mov     [edi].diaplaySet, eax       ; set initial display set 

    assume  esi: PTR BUTTONDATA
    invoke  BindMapBlockPopButtonsBitmap, edi, 0, TURRENT_A_ICON
    mov     esi, eax
    mov     eax, CreateTurretA
    mov     [esi].pClickEvent, eax
    invoke  BindMapBlockPopButtonsBitmap, edi, 1, TURRENT_B
    mov     esi, eax
    mov     eax, CreateTurretB
    mov     [esi].pClickEvent, eax
    invoke  BindMapBlockPopButtonsBitmap, edi, 2, TURRENT_C
    mov     esi, eax
    mov     eax, CreateTurretC
    mov     [esi].pClickEvent, eax
    invoke  BindMapBlockPopButtonsBitmap, edi, 3, ICON_UP
    invoke  BindMapBlockPopButtonsBitmap, edi, 4, ICON_DELETE
    mov     esi, eax
    mov     eax, DeleteTurret
    mov     [esi].pClickEvent, eax
    invoke  BindMapBlockPopButtonsBitmap, edi, 5, ICON_OK
    mov     esi, eax
    mov     eax, ReallyDeleteTurret
    mov     [esi].pClickEvent, eax
    invoke  BindMapBlockPopButtonsBitmap, edi, 6, ICON_CANCEL
    mov     esi, eax
    mov     eax, CancelDeleteTurret
    mov     [esi].pClickEvent, eax

    invoke  RegisterButton, addr @rect, 0, 0 ,0, 0
    invoke  MoveButtonTo, eax, -100, -100
    mov     [edi].pTurret, eax

    mov     eax, 0
    mov     [edi].turretID, eax

    mov     eax, edi
    ret
RegisterMapBlock    ENDP

GetButtonptrByID    PROC uses ebx esi edi pMapBlock: ptr MAPBLOCKDATA, id:DWORD
    mov     edi, pMapBlock
    assume  edi: ptr MAPBLOCKDATA
    lea     edi, [edi].pButton
    mov     eax, id
    .IF     eax >= MAPB_BTNTOTAL
        ret
    .ENDIF
    shl     eax, 2
    add     edi, eax
    mov     eax, DWORD PTR [edi]
    ret 
GetButtonptrByID    ENDP

BindMapBlockPopButtonsClick PROC uses ebx esi edi pMapBlock: ptr MAPBLOCKDATA, id:DWORD, pClickEvent:DWORD
    invoke  GetButtonptrByID, pMapBlock, id
    mov     edi, eax
    assume  edi: ptr BUTTONDATA
    mov     eax, pClickEvent
    mov     [edi].pClickEvent, eax
    mov     eax, pMapBlock
    ret
BindMapBlockPopButtonsClick ENDP

BindMapBlockPopButtonsBitmap  PROC uses ebx esi edi pMapBlock: ptr MAPBLOCKDATA, id:DWORD, IDBitmap:DWORD
    invoke  GetButtonptrByID, pMapBlock, id
    mov     edi, eax
    assume  edi: ptr BUTTONDATA
    invoke  BindButtonToBitmap, edi, IDBitmap
    mov     eax, edi
    ret
BindMapBlockPopButtonsBitmap  ENDP

SetMapBlockDisplaySet   PROC  uses ebx edi esi pMapBlock: ptr MAPBLOCKDATA, id:DWORD
    mov     edi, pMapBlock
    assume  edi: PTR MAPBLOCKDATA
    mov     eax, id
    mov     [edi].diaplaySet, eax
    mov     eax, MAPB_CONTRACTING
    mov     [edi].status, eax
    mov     eax, 0
    mov     [edi].action_step, eax
    ret
SetMapBlockDisplaySet  ENDP

LoadMapFromFile     PROC uses ebx edi esi offsetX:DWORD, offsetY:DWORD
    local   @file:DWORD, @x:DWORD, @y:DWORD, @rect:RECT, @route_point_cnt:DWORD
    invoke  OpenTextFile, offset szMapFileName
    mov     @file, eax
    
    mov     ecx, 0
    mov     edx, 0

    mov     @route_point_cnt, ecx

    .WHILE ecx < MAP_HEIGHT
        push    ecx
        invoke  GetFileLine, @file
        pop     ecx
        push    ecx
        mov     esi, eax 
        mov     ebx, 0
        .WHILE ebx < MAP_WIDTH
            
            dec     edx
            push    ecx
            push    ebx

            mov     eax, ecx
            mov     ecx, MAPB_BLOCKMARGINY 
            mul     ecx
            mov     ecx, eax
            add     ecx, offsetY
            mov     @y, ecx ; y = offsetY + MAPB_BLOCKWIDTH  * ecx

            mov     eax, ebx
            mov     ebx, MAPB_BLOCKMARGINX
            mul     ebx
            mov     ebx, eax
            add     ebx, offsetX
            mov     @x, ebx ; X = offsetX + MAPB_BLOCKHEIGHT * ecx
            
            pop     ebx
            pop     ecx
            xor     eax, eax
            mov     al, BYTE PTR [esi]
            .IF     al == 43 || (al >=48 && al <= 64) 
                push    eax

                push    ecx
                push    edx
                mov     eax, @x
                mov     @rect.left, eax
                mov     eax, @y
                add     eax, 5
                mov     @rect.top, eax
                invoke  RegisterButton, addr @rect, 0, 0, 0, 0
                assume  eax: ptr BUTTONDATA
                mov     dx, BTNI_DISABLE
                mov     WORD PTR [eax].isActive, dx
                invoke  BindButtonToBitmap, eax, BMP_ROAD
                invoke  SetButtonSize, eax, MAPB_BLOCKWIDTH, MAPB_BLOCKHEIGHT
                pop     edx
                pop     ecx
                mov     [eax].isActive, BTNI_DISABLE

                pop     eax
                .IF   al >= 48 && al < 78
                    sub     eax, 48
                    inc     eax
                    .IF     eax > @route_point_cnt
                        mov     @route_point_cnt, eax
                    .ENDIF
                    dec     eax
                    push    ebx
                    mov     ebx, sizeof D_POINT
                    mul     ebx
                    add     eax, offset ptRoutePoint
                    assume  eax: ptr D_POINT
                    
                    mov     ebx, MAPB_BLOCKWIDTH
                    shr     ebx, 1
                    add     ebx, @x
                    mov     [eax].x, ebx
                    mov     ebx, MAPB_BLOCKHEIGHT
                    shr     ebx, 1
                    add     ebx, @y
                    mov     [eax].y, ebx
                    pop     ebx
                .ENDIF
            .ELSEIF al == 111
                push    ecx
                push    edx
                invoke  RegisterMapBlock, @x, @y

                mov     eax, @x
                mov     @rect.left, eax
                mov     eax, @y
                add     eax, MAPB_BLOCKHEIGHT
                mov     @rect.top, eax
                invoke  RegisterButton, addr @rect, 0, 0, 0, 0
                assume  eax: ptr BUTTONDATA
                mov     dx, BTNI_DISABLE
                mov     WORD PTR [eax].isActive, dx
                invoke  BindButtonToBitmap, eax, BMP_SIDE
                invoke  SetButtonSize, eax, MAPB_BLOCKWIDTH, 15
                pop     edx
                pop     ecx
            .ELSEIF al == 95
                push    ecx
                push    edx
                mov     eax, @x
                mov     @rect.left, eax
                mov     eax, @y
                sub     eax, 10
                mov     @rect.top, eax
                invoke  RegisterButton, addr @rect, 0, 0, 0, 0
                assume  eax: ptr BUTTONDATA
                mov     dx, BTNI_DISABLE
                mov     WORD PTR [eax].isActive, dx
                invoke  BindButtonToBitmap, eax, BMP_EMPTY
                invoke  SetButtonSize, eax, MAPB_BLOCKWIDTH, MAPB_BLOCKHEIGHT
                mov     eax, @x
                mov     @rect.left, eax
                mov     eax, @y
                sub     eax, 10
                add     eax, MAPB_BLOCKHEIGHT
                mov     @rect.top, eax
                invoke  RegisterButton, addr @rect, 0, 0, 0, 0
                assume  eax: ptr BUTTONDATA
                mov     dx, BTNI_DISABLE
                mov     WORD PTR [eax].isActive, dx
                invoke  BindButtonToBitmap, eax, BMP_SIDE2
                invoke  SetButtonSize, eax, MAPB_BLOCKWIDTH, 25
                pop     edx
                pop     ecx
                mov [eax].isActive, BTNI_DISABLE
            .ENDIF
            inc     esi
            inc     ebx
        .ENDW
        pop     ecx
        inc     ecx 
    .ENDW
    invoke CloseFile, @file
    ; roadmap 
    invoke  RoadmapClear
    mov     ecx, 0
    lea     edx, ptRoutePoint
    .WHILE      ecx < @route_point_cnt
        assume  edx: ptr D_POINT
        push    ecx
        push    edx
        pushad
        invoke  dPrint2, [edx].x, [edx].y
        popad
        invoke  RoadmapAddi, [edx].x, [edx].y
        pop     edx
        pop     ecx
        add     edx, sizeof D_POINT
        add     ecx, 1
    .ENDW
    mov     eax, offset ptRoutePoint
    mov     edx, @route_point_cnt
    ret
LoadMapFromFile     ENDP


end