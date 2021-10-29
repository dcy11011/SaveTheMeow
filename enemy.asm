.386
.model flat, stdcall
option casemap:none

include enemy.inc
include collision.inc

include windows.inc
include gdi32.inc
include util.inc 
include paint.inc

.data
nEnemyListCnt           DWORD    0
bIfInitEnemyData        DWORD    0

.data?
arrayEnemyList ENEMYDATA MAXENYCNT DUP(<?>) ; 内存池

.code

InitEnemyData proc uses  ebx edi
    lea     edi, arrayEnemyList
    mov     ebx, MAXENYCNT
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr ENEMYDATA
        mov     [edi].isActive, 0
        add     edi, sizeof ENEMYDATA
        inc     ecx
    .ENDW
    xor     eax, eax
    ret
InitEnemyData endp


GetAvilaibleEnemyData proc uses ebx edx edi
    .IF ! bIfInitEnemyData
        invoke InitEnemyData
        mov bIfInitEnemyData, 1
    .ENDIF
    lea     edi, arrayEnemyList
    mov     ebx, nEnemyListCnt
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr ENEMYDATA
        .IF     [edi].isActive == 0
            .break
        .ENDIF
        add     edi, sizeof ENEMYDATA
        inc     ecx
    .ENDW
    .IF ecx == ebx
        inc     ebx
        mov     nEnemyListCnt, ebx
    .ENDIF
    mov eax, edi
    ret
GetAvilaibleEnemyData endp


RegisterEnemy proc hp: DWORD, speed: DWORD, atk: DWORD
    invoke  GetAvilaibleEnemyData
    mov     edx, eax
    assume  edx: ptr ENEMYDATA
    mov     [edx].health, eax
    mov     [edx].healthMax, eax
    mov     eax, speed
    mov     [edx].speed, eax
    mov     eax, atk
    mov     [edx].attack, eax

    mov     eax, real0
    mov     [edx].xf, eax
    mov     eax, real0
    mov     [edx].yf, eax
    mov     [edx].progress, 0
    mov     [edx].isActive, 1
    mov     [edx].aParam, 0
    mov     [edx].bParam, 0
    mov     [edx].pUpdateEvent, 0
    mov     [edx].pHurtEvent, 0
    mov     [edx].pDeathEvent, 0
    mov     eax, edx
    ret
RegisterEnemy endp


EnemyUpdateAll proc uses esi cnt: DWORD
    mov     ecx, nEnemyListCnt
    and     ecx, ecx
    jnz     @f
    ret
    @@:
    lea     esi, arrayEnemyList
    assume  esi: ptr ENEMYDATA
    @@:
        mov     ax, [esi].isActive
        .IF ax
            mov     eax, [esi].pUpdateEvent
            push    ecx
            .IF eax
                push    esi
                push    cnt
                call    eax
            .ENDIF
            pop     ecx
        .ENDIF
        add     eax, sizeof ENEMYDATA
        add     esi, eax
    loop @b
    ret
EnemyUpdateAll endp


EnemyBindButton proc self: ptr ENEMYDATA, btn: ptr BUTTONDATA
    mov     eax, btn
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     [edx].pAsButton, eax
    assume  eax: ptr BUTTONDATA
    invoke  EnemySetPositioni, self, [eax].left, [eax].top
    ret
EnemyBindButton endp


EnemyBindUpdate proc self: ptr ENEMYDATA, upd: DWORD
    mov     eax, upd
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     [edx].pUpdateEvent, eax
    ret
EnemyBindUpdate endp

;
;   Geometry
;

EnemyUpdatePosition proc uses edi self: ptr ENEMYDATA        ; update button pos to enemy pos
    local   tx:DWORD, ty:DWORD
    mov     edi, self
    assume  edi: ptr ENEMYDATA
    invoke  real42dword, [edi].xf
    mov     tx, eax
    invoke  real42dword, [edi].yf
    mov     ty, eax
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    invoke  MoveButtonTo, edx, tx, ty
    ret
EnemyUpdatePosition endp

EnemySetPositioni proc    self: ptr ENEMYDATA, x:DWORD, y:DWORD
    invoke  dword2real4, x
    mov     x, eax
    invoke  dword2real4, y
    mov     y, eax
    invoke  EnemySetPositionf, self, x, y
    ret
EnemySetPositioni endp

EnemySetPositionf proc    self: ptr ENEMYDATA, x:REAL4, y:REAL4
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     eax, x
    mov     [edx].xf, eax
    mov     eax, y
    mov     [edx].yf, eax
    invoke  EnemyUpdatePosition, self
    ret
EnemySetPositionf endp

EnemyMovePositioni proc    self: ptr ENEMYDATA, x:DWORD, y:DWORD
    invoke  dword2real4, x
    mov     x, eax
    invoke  dword2real4, y
    mov     y, eax
    invoke  EnemyMovePositionf, self, x, y
    ret
EnemyMovePositioni endp

EnemyMovePositionf proc    self: ptr ENEMYDATA, x:REAL4, y:REAL4
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    fld     DWORD ptr [edx].xf
    fld     DWORD ptr x
    fadd
    fstp    DWORD ptr [edx].xf
    fld     DWORD ptr [edx].yf
    fld     DWORD ptr y
    fadd
    fstp    DWORD ptr [edx].yf
    invoke  EnemyUpdatePosition, self
    ret
EnemyMovePositionf endp

;
;   Events
;

EnemyDefaultUpdate PROC uses ebx edi esi cnt:DWORD, pEnemy: ptr ENEMYDATA
    local   tmpf: DWORD
    mov     edi, pEnemy
    assume  edi: ptr ENEMYDATA
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA

    push    edx
    invoke  CalcDisti, [edx].top, [edx].left, 0, 0
    mov     tmpf, eax
    fld     DWORD ptr tmpf
    ; invoke  dPrintFloat, eax
    mov     tmpf, 300
    fild    DWORD ptr tmpf
    fcompp
    fstsw   ax
    sahf
    ja      @f
    pop     edx
    push    edx
    ; invoke  MoveButton, edx, -100, -10
    @@:
    ; invoke  MoveButton, edx, 2, 1
    ; invoke  dPrintFloat, wwww
    pop     edx
    ; invoke  GetAtan2, real1of3, real1

    ; invoke  DirectionTo, [edi].xf, [edi].yf, MouseXf, MouseYf
    ; push    eax
    ; invoke  dPrintFloat, eax
    ; pop     eax
    ; invoke  GetDirVector, eax, real1
    ; invoke  EnemyMovePositionf, edi, eax, edx
    invoke  LerpXY, [edi].xf, [edi].yf, MouseXf, MouseYf, real9of10
    invoke  EnemySetPositionf, edi, eax, edx

    ret
EnemyDefaultUpdate endp

end
