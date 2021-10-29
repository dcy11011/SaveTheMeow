.386
.model flat, stdcall
option casemap:none

include windows.inc

include enemy.inc
include projectile.inc
include button.inc
include util.inc

.data

.code
PrefabTestProjectile proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    mov     eax, x
    mov     @stRect.left, eax
    add     eax, 50
    mov     @stRect.right, eax

    mov     eax, y
    mov     @stRect.top, eax
    add     eax, 50
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    
    mov     pButton1, eax
    invoke  SetButtonDepth, eax, 1
    
    invoke  RegisterProjectile, 10, real1
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtDefaultUpdate
    mov     eax, pProjt1
    ret
PrefabTestProjectile endp


end
