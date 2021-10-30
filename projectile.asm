.386
.model flat, stdcall
option casemap:none

include projectile.inc
include enemy.inc
include collision.inc

include windows.inc
include gdi32.inc
include util.inc 
include paint.inc

include prefab.inc

.data
nProjtListCnt           DWORD    0
bIfInitProjtData        DWORD    0

.data?
arrayProjtList PROJTDATA MAXPJTCNT DUP(<?>) ; 内存池

.code

InitProjtData proc uses  ebx edi
    lea     edi, arrayProjtList
    mov     ebx, MAXPJTCNT
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr PROJTDATA
        mov     [edi].isActive, 0
        add     edi, sizeof PROJTDATA
        inc     ecx
    .ENDW
    xor     eax, eax
    ret
InitProjtData endp


GetAvilaibleProjtData proc uses ebx edx edi
    .IF ! bIfInitProjtData
        invoke InitProjtData
        mov bIfInitProjtData, 1
    .ENDIF
    lea     edi, arrayProjtList
    mov     ebx, nProjtListCnt
    mov     ecx, 0
    .WHILE ecx < ebx
        assume  edi: ptr PROJTDATA
        .IF     [edi].isActive == 0
            .break
        .ENDIF
        add     edi, sizeof PROJTDATA
        inc     ecx
    .ENDW
    .IF ecx == ebx
        inc     ebx
        mov     nProjtListCnt, ebx
    .ENDIF
    mov eax, edi
    ret
GetAvilaibleProjtData endp


RegisterProjectile proc atk: DWORD, speed: REAL4, dir:REAL4
    invoke  GetAvilaibleProjtData
    mov     edx, eax
    assume  edx: ptr PROJTDATA
    mov     eax, speed
    mov     [edx].speed, eax
    mov     eax, atk
    mov     [edx].attack, eax

    mov     eax, real0
    mov     [edx].xf, eax
    mov     eax, real0
    mov     [edx].yf, eax
    mov     eax, real0
    mov     eax, dir
    mov     [edx].direction, eax
    mov     eax, real1
    mov     [edx].radius, eax

    mov     [edx].isActive, 1
    mov     [edx].penetrate, 1
    mov     [edx].lifetime, 100
    mov     [edx].pUpdateEvent, 0
    mov     [edx].pHitEvent, 0
    mov     eax, edx
    ret
RegisterProjectile endp


ProjtUpdateAll proc uses esi cnt: DWORD
    ; pushad
    ; invoke  dPrint, nProjtListCnt
    ; popad
    mov     ecx, nProjtListCnt
    and     ecx, ecx
    jnz     @f
    ret
    @@:
    lea     esi, arrayProjtList
    @@:
        assume  esi: ptr PROJTDATA
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
        add     esi, sizeof PROJTDATA
    loop @b
    ret
ProjtUpdateAll endp


ProjtBindButton proc self: ptr PROJTDATA, btn: ptr BUTTONDATA
    mov     eax, btn
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     [edx].pAsButton, eax
    assume  eax: ptr BUTTONDATA
    invoke  ProjtSetPositioni, self, [eax].left, [eax].top
    invoke  ProjtUpdateRadius, self
    ret
ProjtBindButton endp


ProjtBindUpdate proc self: ptr PROJTDATA, upd: DWORD
    mov     eax, upd
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     [edx].pUpdateEvent, eax
    ; invoke  dPrint, self
    ret
ProjtBindUpdate endp

;
;   Geometry
;

ProjtUpdatePosition proc uses edi self: ptr PROJTDATA        ; update button pos to enemy pos
    local   tx:DWORD, ty:DWORD
    mov     edi, self
    assume  edi: ptr PROJTDATA
    invoke  real42dword, [edi].xf
    mov     tx, eax
    invoke  real42dword, [edi].yf
    mov     ty, eax
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    invoke  MoveButtonTo, edx, tx, ty
    ret
ProjtUpdatePosition endp

ProjtSetPositioni proc    self: ptr PROJTDATA, x:DWORD, y:DWORD
    invoke  dword2real4, x
    mov     x, eax
    invoke  dword2real4, y
    mov     y, eax
    invoke  ProjtSetPositionf, self, x, y
    ret
ProjtSetPositioni endp

ProjtSetPositionf proc    self: ptr PROJTDATA, x:REAL4, y:REAL4
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     eax, x
    mov     [edx].xf, eax
    mov     eax, y
    mov     [edx].yf, eax
    invoke  ProjtUpdatePosition, self
    ret
ProjtSetPositionf endp

ProjtMovePositioni proc    self: ptr PROJTDATA, x:DWORD, y:DWORD
    invoke  dword2real4, x
    mov     x, eax
    invoke  dword2real4, y
    mov     y, eax
    invoke  ProjtMovePositionf, self, x, y
    ret
ProjtMovePositioni endp

ProjtMovePositionf proc    self: ptr PROJTDATA, x:REAL4, y:REAL4
    mov     edx, self
    assume  edx: ptr PROJTDATA
    fld     DWORD ptr [edx].xf
    fld     DWORD ptr x
    fadd
    fstp    DWORD ptr [edx].xf
    fld     DWORD ptr [edx].yf
    fld     DWORD ptr y
    fadd
    fstp    DWORD ptr [edx].yf
    invoke  ProjtUpdatePosition, self
    ret
ProjtMovePositionf endp

ProjtSetSpeed proc    self: ptr PROJTDATA, speed:REAL4
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     eax, speed
    mov     [edx].speed, eax
    ret
ProjtSetSpeed endp

ProjtSetDirection proc   self: ptr PROJTDATA, direction:REAL4
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     eax, direction
    mov     [edx].direction, eax
    ret
ProjtSetDirection endp

ProjtUpdateRadius proc    self: ptr PROJTDATA
    mov     edx, self
    assume  edx: ptr PROJTDATA
    push    edx
    invoke  GetRadiusButton, [edx].pAsButton
    pop     edx
    mov     [edx].radius, eax
    ret
ProjtUpdateRadius endp

;
;   Events
;

ProjtStepForward proc uses edi self: ptr PROJTDATA
    mov     edi, self
    assume  edi: ptr PROJTDATA
    invoke  GetDirVector, [edi].direction, [edi].speed
    invoke  ProjtMovePositionf, edi, eax, edx
    sub     [edi].lifetime, 1
    invoke  ProjtCheckDeath, self
    ret
ProjtStepForward endp


ProjtSetDeath proc uses edi self: ptr PROJTDATA
    mov     edi, self
    assume  edi: ptr PROJTDATA
    mov     [edi].isActive, 0
    invoke  DeleteButton, [edi].pAsButton
    ret
ProjtSetDeath endp

ProjtCheckDeath proc uses edi self: ptr PROJTDATA
    mov     edi, self
    assume  edi: ptr PROJTDATA
    .IF     [edi].penetrate == 0
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    .IF     [edi].lifetime == 0
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    .IF     [edx].right < 0
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    mov     eax, stageWidth
    .IF     [edx].left > eax
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    .IF     [edx].bottom < 0
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    mov     eax, stageHeight
    .IF     [edx].top > eax
        invoke  ProjtSetDeath, self
        ret
    .ENDIF
    ret
ProjtCheckDeath endp

ProjtHitEnemies proc uses esi edi self: ptr PROJTDATA, cnt:DWORD
    local   x1:REAL4, x2:REAL4, y1:REAL4, y2:REAL4
    mov     edi, self
    assume  edi: ptr PROJTDATA
    mov     ecx, 0
    mov     esi, arrayEnemyListHead
    .WHILE  ecx < nEnemyListCnt
        assume  esi: ptr ENEMYDATA
        mov     ax, [esi].isActive
        .IF ax
            push    ecx
            invoke  GetCenterButton, [esi].pAsButton
            mov     x1, eax
            mov     y1, edx
            invoke  GetCenterButton, [edi].pAsButton
            mov     x2, eax
            mov     y2, edx
            invoke  CircleCollision, x1, y1, [esi].radius, \
                                     x2, y2, [edi].radius
            .IF eax
                mov     eax, [esi].pHurtEvent
                .IF eax
                    push    esi
                    push    cnt
                    call    eax
                .ENDIF
                ; invoke hurt event
                mov     eax, [edi].pHitEvent
                .IF eax
                    push    edi
                    push    cnt
                    call    eax
                .ENDIF
                ; invoke projectile hit event
                sub     [edi].penetrate, 1
                .IF     [edi].penetrate == 0
                    invoke  PrefabHurtEffectProjf, [edi].xf, [edi].yf
                    invoke  ProjtCheckDeath, self
                    pop     ecx
                    ret
                .ENDIF
                ; check penetrate
            .ENDIF
            pop     ecx
        .ENDIF
        add     esi, sizeof ENEMYDATA
        add     ecx, 1
    .ENDW
    ret
ProjtHitEnemies endp

;
;   Update Events
;

ProjtDefaultUpdate PROC uses esi edi cnt:DWORD, pProjt: ptr PROJTDATA
    local   tmpf: DWORD
    push    edi
    ; invoke  dPrint2, cnt, pProjt
    mov     edi, pProjt
    assume  edi: ptr PROJTDATA
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA

    ; invoke  DirectionTo, [edi].xf, [edi].yf, MouseXf, MouseYf
    ; invoke  ProjtSetDirection, pProjt, eax
    ; change dir

    invoke  ProjtHitEnemies, pProjt, cnt
    invoke  ProjtStepForward, pProjt

    pop     edi
    ret
ProjtDefaultUpdate endp


ProjtHurtEffectUpdate PROC uses esi edi cnt:DWORD, pProjt: ptr PROJTDATA
    local   tmpf: DWORD
    push    edi 
    ; invoke  dPrint2, cnt, pProjt
    mov     edi, pProjt
    assume  edi: ptr PROJTDATA
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA
    add     [edx].top, 1
    sub     [edx].bottom, 1
    sub     [edx].left, 2
    add     [edx].right, 2
    invoke  ProjtBindButton, pProjt, edx

    ; invoke  DirectionTo, [edi].xf, [edi].yf, MouseXf, MouseYf
    ; invoke  ProjtSetDirection, pProjt, eax
    ; change dir

    invoke  ProjtStepForward, pProjt

    pop     edi
    ret
ProjtHurtEffectUpdate endp

end
