.386
.model flat, stdcall
option casemap:none

include enemy.inc

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
    mov     ecx, MAXENYCNT
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

RegisterEnemyAt proc self: ptr ENEMYDATA, hp: DWORD, speed: DWORD, atk: DWORD
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     eax, btn
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
    ret
RegisterEnemyAt endp


BindButton proc self: ENEMYDATA, btn: ptr BUTTONDATA
    mov     eax, btn
    mov     edx, self
    assume  edx: ptr ENEMYDATA
    mov     [edx].pAsButton, eax
    ret
BindButton endp

end
