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
    lea     esi, arrayEnemyList
    assume  esi: ptr ENEMYDATA
    @@:
        mov     ax, [esi].isActive
        .IF ax
            mov     eax, [esi].pUpdateEvent
            .IF eax
                push    esi
                push    cnt
                call    eax
            .ENDIF
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
    ret
EnemyBindButton endp


EnemyBindUpdate proc self: ptr ENEMYDATA, upd: DWORD
    mov     eax, upd
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     [edx].pUpdateEvent, eax
    ret
EnemyBindUpdate endp


EnemyDefaultUpdate PROC uses ebx edi esi cnt:DWORD, pEnemy: ptr ENEMYDATA
    local   tmpf: DWORD
    mov     edi, pEnemy
    assume  edi: ptr ENEMYDATA
    mov     edx, [edi].pAsButton
    assume  edx: ptr BUTTONDATA

    push    edx
    invoke  CalcDist, [edx].top, [edx].left, 0, 0
    mov     tmpf, eax
    fld     DWORD ptr tmpf
    invoke  dPrintFloat, eax
    mov     tmpf, 300
    fild    DWORD ptr tmpf
    fcompp
    fstsw   ax
    sahf
    ja      @f
    pop     edx
    push    edx
    invoke  MoveButton, edx, -100, -10
    @@:
    invoke  MoveButton, edx, 2, 1
    pop     edx

    ret
EnemyDefaultUpdate endp

end
