.386
.model flat, stdcall
option casemap:none

include windows.inc

include enemy.inc
include projectile.inc
include button.inc
include util.inc
include collision.inc
include rclist.inc

.data

.code

;
;   Projectile Prefabs
;

PrefabHurtEffectProj proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 3
    mov     @stRect.left, eax
    add     eax, 6
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 10
    mov     @stRect.top, eax
    add     eax, 20
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, EFFECT_SPRITE
    invoke  SetButtonSize, pButton1, 6, 20
    ; ---- Proj
    invoke  RegisterProjectile, 0, real0, real0
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtHurtEffectUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, -1
    mov     [edx].lifetime, 10
    ;
    mov     eax, pProjt1
    ret
PrefabHurtEffectProj endp

PrefabHurtEffectProjf proc   x:REAL4, y:REAL4
    invoke  real42dword, x
    push    eax
    invoke  real42dword, y
    mov     edx, eax
    pop     eax
    invoke  PrefabHurtEffectProj, eax, edx
    ret
PrefabHurtEffectProjf endp

PrefabDeathEffectProj proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 10
    mov     @stRect.left, eax
    add     eax, 6
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 3
    mov     @stRect.top, eax
    add     eax, 20
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, EFFECT2_SPRITE
    invoke  SetButtonSize, pButton1, 20, 6
    ; ---- Proj
    invoke  RegisterProjectile, 0, real0, real0
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtDeathEffectUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, -1
    mov     [edx].lifetime, 10
    ;
    mov     eax, pProjt1
    ret
PrefabDeathEffectProj endp

PrefabDeathEffectProjf proc   x:REAL4, y:REAL4
    invoke  real42dword, x
    push    eax
    invoke  real42dword, y
    mov     edx, eax
    pop     eax
    invoke  PrefabDeathEffectProj, eax, edx
    ret
PrefabDeathEffectProjf endp



PrefabTestProjectile proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    mov     eax, x
    mov     @stRect.left, eax
    add     eax, 11
    mov     @stRect.right, eax

    mov     eax, y
    mov     @stRect.top, eax
    add     eax, 11
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -100
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, BULLET_C

    invoke  RegisterProjectile, 5, real11, real0
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtDefaultUpdate

    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, 1
    invoke  DirectionTo, [edx].xf, [edx].yf, MouseXf, MouseYf
    invoke  ProjtSetDirection, edx, eax

    mov     eax, pProjt1
    ret
PrefabTestProjectile endp

;
;   Enemy Prefabs
;

PrefabTestEnemy proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pEnemy1:DWORD
    mov     eax, x
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax

    mov     eax, y
    mov     @stRect.top, eax
    add     eax, 30
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -10
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, ENEMY_SPRITE_2
    
    invoke  RegisterEnemy, 100, real1, 10
    mov     pEnemy1, eax
    invoke  EnemyBindButton, pEnemy1, pButton1
    invoke  EnemyBindUpdate, pEnemy1, EnemyDefaultUpdate
    mov     eax, pEnemy1
    ret
PrefabTestEnemy endp

end
