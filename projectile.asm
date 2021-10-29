.386
.model flat, stdcall
option casemap:none

include projectile.inc
include collision.inc

include windows.inc
include gdi32.inc
include util.inc 
include paint.inc

.data
nProjtListCnt           DWORD    0
bIfInitProjtData        DWORD    0
real0                   REAL4    0.0
real1                   REAL4    1.0
real1n                  REAL4    -1.0
real1of2                REAL4    0.5
real1of3                REAL4    0.33333
real2of3                REAL4    0.66666
real9of10               REAL4    0.9

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


RegisterProjt proc atk: DWORD, speed: REAL4
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
    mov     [edx].direction, eax
    mov     [edx].isActive, 1
    mov     [edx].aParam, 0
    mov     [edx].bParam, 0
    mov     [edx].pUpdateEvent, 0
    mov     [edx].pHurtEvent, 0
    mov     [edx].pDeathEvent, 0
    mov     eax, edx
    ret
RegisterProjt endp


ProjtUpdateAll proc uses esi cnt: DWORD
    mov     ecx, nProjtListCnt
    and     ecx, ecx
    jnz     @f
    ret
    @@:
    lea     esi, arrayProjtList
    assume  esi: ptr PROJTDATA
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
        add     eax, sizeof PROJTDATA
        add     esi, eax
    loop @b
    ret
ProjtUpdateAll endp


ProjtBindButton proc self: ptr PROJTDATA, btn: ptr BUTTONDATA
    mov     eax, btn
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     [edx].pAsButton, eax
    ret
ProjtBindButton endp


ProjtBindUpdate proc self: ptr PROJTDATA, upd: DWORD
    mov     eax, upd
    mov     edx, self
    assume  edx: ptr PROJTDATA
    mov     [edx].pUpdateEvent, eax
    ret
ProjtBindUpdate endp

;
;   Geometry
;

ProjtUpdatePosition proc uses edi self: ptr PROJTDATA        ; update buttom pos to enemy pos
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

;
;   Events
;

ProjtDefaultUpdate PROC uses ebx edi esi cnt:DWORD, pProjt: ptr PROJTDATA
    local   tmpf: DWORD
    mov     edi, pProjt
    assume  edi: ptr PROJTDATA
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
    ; invoke  ProjtMovePositionf, edi, eax, edx
    invoke  LerpXY, [edi].xf, [edi].yf, MouseXf, MouseYf, real9of10
    invoke  ProjtSetPositionf, edi, eax, edx

    ret
ProjtDefaultUpdate endp

end
