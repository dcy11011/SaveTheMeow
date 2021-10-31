.386
.model flat, stdcall
option casemap:none

include enemy.inc
include collision.inc
include statusbar.inc

include windows.inc
include gdi32.inc
include util.inc 
include paint.inc
include prefab.inc

.data
nEnemyListCnt           DWORD    0
bIfInitEnemyData        DWORD    0
nRoadmapCnt             DWORD    0
arrayEnemyListHead      DWORD    0
arrayRoadmapListHead    DWORD    0
nWaveNumber             DWORD    0
nWaveEnemiesRemain      DWORD    0
nWaveEnemiesTotal       DWORD    0
nWaveEnemyCD            DWORD    0

.data?
arrayEnemyList ENEMYDATA MAXENYCNT DUP(<?>) ; 内存池
arrayRoadmapList F_POINT MAXROADMAPCNT DUP(<?>) 

.code

InitEnemyData proc uses  ebx edi
    lea     eax, arrayEnemyList
    mov     arrayEnemyListHead, eax
    lea     eax, arrayRoadmapList
    mov     arrayRoadmapListHead, eax

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


RegisterEnemy proc hp: DWORD, speed: REAL4, atk: DWORD
    invoke  GetAvilaibleEnemyData
    mov     edx, eax
    assume  edx: ptr ENEMYDATA
    ;
    pushad
    invoke  dPrint, hp
    popad
    ;
    mov     eax, hp
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
    mov     eax, real0
    mov     [edx].progress, eax

    mov     eax, real1
    mov     [edx].radius, eax

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
        add     esi, sizeof ENEMYDATA
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
    invoke  EnemyUpdateRadius, self
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

EnemyUpdateRadius proc    self: ptr ENEMYDATA
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    push    edx
    invoke  GetRadiusButton, [edx].pAsButton
    pop     edx
    mov     [edx].radius, eax
    ret
EnemyUpdateRadius endp

;
;   Events
;

EnemyStepForward proc uses edi self: ptr ENEMYDATA
    local   tx:REAL4, ty:REAL4
    mov     edi, self
    assume  edi: ptr ENEMYDATA
    fld     DWORD ptr [edi].progress
    fld     DWORD ptr [edi].speed
    fadd
    fstp    DWORD ptr [edi].progress
    invoke  RoadmapCalcCurrent, [edi].progress
    mov     tx, eax
    mov     ty, edx

    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    fld     DWORD ptr tx
    fild    DWORD ptr [edx].right
    fild    DWORD ptr [edx].left
    fsub
    fld     DWORD ptr real2
    fdiv
    fsub
    fstp    DWORD ptr tx
    ;
    fld     DWORD ptr ty
    fild    DWORD ptr [edx].bottom
    fild    DWORD ptr [edx].top
    fsub
    fsub
    fstp    DWORD ptr ty
    invoke  EnemySetPositionf, self, tx, ty
    ret
EnemyStepForward endp

EnemySetDeath proc uses edi self: ptr ENEMYDATA
    mov     edi, self
    assume  edi: ptr ENEMYDATA
    mov     [edi].isActive, 0
    invoke  DeleteButton, [edi].pAsButton
    invoke  PopAddCoinf, 10, [edi].xf, [edi].yf
    ret
EnemySetDeath endp




EnemyDefaultUpdate PROC uses ebx edi esi cnt:DWORD, pEnemy: ptr ENEMYDATA
    local   tmpf: DWORD
    mov     edi, pEnemy
    assume  edi: ptr ENEMYDATA
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    invoke  EnemyStepForward, pEnemy
    ret
EnemyDefaultUpdate endp

EnemyMouseUpdate PROC uses ebx edi esi cnt:DWORD, pEnemy: ptr ENEMYDATA
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
EnemyMouseUpdate endp

;
;   Waves and Roadmap
; 

WaveReset proc
    mov     nWaveNumber, 0
    mov     nWaveEnemiesRemain, -1
    mov     nWaveEnemiesTotal, 0
    mov     nWaveEnemyCD, -1
    ret
WaveReset endp

WaveStart proc     waven:DWORD, ecnt:DWORD
    mov     eax, waven
    mov     nWaveNumber, eax
    mov     eax, ecnt
    mov     nWaveEnemiesRemain, eax
    mov     eax, ecnt
    mov     nWaveEnemiesTotal, eax
    mov     eax, DEFAULTENEMYCD
    mov     nWaveEnemyCD, eax
    ret
WaveStart endp

WaveStepForward proc
    local   lvl:DWORD
    mov     eax, nWaveEnemyCD
    and     eax, eax
    je      @f
    sub     eax, 1
    mov     nWaveEnemyCD, eax
    ret
    @@:
    mov     eax, DEFAULTENEMYCD
    mov     nWaveEnemyCD, eax
    mov     eax, nWaveEnemiesRemain
    and     eax, eax
    je      @f
    sub     eax, 1
    mov     nWaveEnemiesRemain, eax
    ; spawn enemy
    mov     eax, nWaveNumber
    mov     ecx, 2
    mul     ecx
    mov     lvl, eax ; set lvl
    xor     edx, edx
    invoke  rand
    mov     ecx, 32
    div     ecx
    pushad
    invoke  dPrint2, nWaveNumber, lvl
    popad
    .IF     edx <= 16
        invoke  PrefabEnemy1, lvl
    .ELSEIF edx <= 25
        invoke  PrefabEnemy2, lvl
    .ELSEIF edx <= 28
        invoke  PrefabEnemy3, lvl
    .ELSE
        invoke  PrefabEnemy4, lvl
    .ENDIF
    ;
    ret
    @@:
    ; next wave
    invoke  dPrint2, nWaveNumber, nWaveEnemiesTotal
    mov     eax, DEFAULTWAVECD
    mov     nWaveEnemyCD, eax
    mov     eax, nWaveNumber
    add     eax, 1
    mov     nWaveNumber, eax
    mov     eax, nWaveEnemiesTotal
    mov     edx, DELTAECNT
    add     eax, edx
    mov     nWaveEnemiesTotal, eax
    mov     nWaveEnemiesRemain, eax
    ret
WaveStepForward endp


RoadmapClear proc
    mov     nRoadmapCnt, 0
    ret
RoadmapClear endp

RoadmapAddi proc    x:DWORD, y:DWORD
    invoke  dword2real4, x
    mov     x, eax
    invoke  dword2real4, y
    mov     y, eax
    invoke  RoadmapAddf, x, y
    ret
RoadmapAddi endp

RoadmapAddf proc    x:REAL4, y:REAL4
    mov     edx, sizeof F_POINT
    mov     eax, nRoadmapCnt
    mul     edx
    lea     edx, arrayRoadmapList
    add     edx, eax
    assume  edx: ptr F_POINT
    mov     eax, x
    mov     [edx].x, eax
    mov     eax, y
    mov     [edx].y, eax
    add     nRoadmapCnt, 1
    ret
RoadmapAddf endp

RoadmapTotalDist proc
    local   t:REAL4
    lea     edx, arrayRoadmapList
    mov     ecx, 1
    fldz
    .WHILE  ecx < nRoadmapCnt
        assume  edx: ptr F_POINT
        push    ecx
        push    edx
        invoke  CalcDist, [edx].x, [edx].y, [edx + sizeof F_POINT].x, [edx + sizeof F_POINT].y
        mov     t, eax
        fld     DWORD ptr t
        fadd
        pop     edx
        pop     ecx
        add     edx, sizeof F_POINT
        add     ecx, 1
    .ENDW
    fstp    DWORD ptr t
    mov     eax, t
    ret
RoadmapTotalDist endp

RoadmapCalcCurrent proc uses esi    s:REAL4 ; 依据一维距离计算当前位置 返回-> eax, edx
    local   t:REAL4
    lea     esi, arrayRoadmapList
    mov     ecx, 1
    fld     DWORD ptr s
    fldz
    .WHILE  ecx < nRoadmapCnt
        assume  esi: ptr F_POINT
        push    ecx
        invoke  CalcDist, [esi].x, [esi].y, [esi + sizeof F_POINT].x, [esi + sizeof F_POINT].y
        pop     ecx
        mov     t, eax
        fld     DWORD ptr t
        fadd
        ;
        fcom    
        fstsw   ax
        sahf
        jb      @f
        fld     DWORD ptr t
        fsub
        fsub
        fstp    DWORD ptr t                   ; t <- dist to next 
        ; pushad invoke  dPrintFloat, t popad
        invoke  DirectionTo, [esi].x, [esi].y, [esi + sizeof F_POINT].x, [esi + sizeof F_POINT].y
        ; pushad invoke  dPrintFloat, eax popad
        invoke  GetDirVector, eax, t
        ; pushad invoke  dPrint2Float, eax, edx popad
        fld     DWORD ptr [esi].x
        mov     t, eax
        fld     DWORD ptr t
        fadd
        fld     DWORD ptr [esi].y
        mov     t, edx
        fld     DWORD ptr t
        fadd
        fstp    DWORD ptr t                   ; y
        mov     edx, t
        fstp    DWORD ptr t                   ; x
        mov     eax, t
        ; pushad
        ; invoke  dPrint2Float, [esi].x, [esi].y
        ; invoke  dPrint2Float, [esi + sizeof F_POINT].x, [esi + sizeof F_POINT].y
        ; invoke  dPrint2Float, eax, edx
        ; popad
        ret
        @@:
        ;
        add     esi, sizeof F_POINT
        add     ecx, 1
    .ENDW
    fstp    DWORD ptr t
    fstp    DWORD ptr t
    assume  esi: ptr F_POINT
    mov     eax, [esi].x
    mov     edx, [esi].y
    ret
RoadmapCalcCurrent endp


FindInrangeEnemyf proc uses esi edi xi:REAL4, yi:REAL4, radius:REAL4
    local   maxdist:REAL4, x1:REAL4, y1:REAL4, result:DWORD
    mov     ecx, 0
    mov     esi, arrayEnemyListHead
    mov     eax, real0
    mov     maxdist, eax
    mov     result, 0
    .WHILE  ecx < nEnemyListCnt
        assume  esi: ptr ENEMYDATA
        mov     ax, [esi].isActive
        .IF ax
            push    ecx
            invoke  GetCenterButton, [esi].pAsButton
            mov     x1, eax
            mov     y1, edx
            invoke  CircleCollision, x1, y1, [esi].radius, \
                                     xi, yi, radius
            .IF eax
                fld     DWORD ptr maxdist
                fld     DWORD ptr [esi].progress
                fcompp
                fstsw   ax
                sahf
                jb      @f
                mov     result, esi
                mov     eax, [esi].progress
                mov     maxdist, eax
                @@:
            .ENDIF
            pop     ecx
        .ENDIF
        add     esi, sizeof ENEMYDATA
        add     ecx, 1
    .ENDW
    mov     eax, result
    ret
FindInrangeEnemyf endp

FindInrangeEnemyi proc uses esi edi xi:DWORD, yi:DWORD, radius:DWORD
    invoke  dword2real4, xi
    mov     xi, eax
    invoke  dword2real4, yi
    mov     yi, eax
    invoke  dword2real4, radius
    mov     radius, eax
    invoke  FindInrangeEnemyf, xi, yi, radius
    ret
FindInrangeEnemyi endp


end
