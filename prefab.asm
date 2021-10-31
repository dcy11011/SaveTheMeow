.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc

include enemy.inc
include projectile.inc
include button.inc
include util.inc
include collision.inc
include rclist.inc
include paint.inc
include main.inc

.data

.code

;
;   Projectile Prefabs
;


EnemyPaint   PROC uses ebx edi esi hdc:DWORD, pButton: ptr BUTTONDATA
    local   @oldPen, @oldBrush, @stRect:RECT, @val:DWORD, @ratio:REAL4
    ;ocal   @colorAdjustment:COLORADJUSTMENT, @oldColorAdjustment:COLORADJUSTMENT
    mov     edi, pButton
    assume  edi: ptr BUTTONDATA
    invoke  GetButtonRect, pButton, addr @stRect

    push    eax
    mov     eax, @stRect.top
    sub     eax, @stRect.bottom
    .IF     eax <= 1
        pop     eax
        ret
    .ENDIF
    pop     eax
    ;invoke  GetColorAdjustment, hdc, addr @colorAdjustment
    ;invoke  memcpy, addr @oldColorAdjustment, addr @colorAdjustment, sizeof COLORADJUSTMENT
    ;lea     esi, @colorAdjustment
    ;assume  esi: ptr COLORADJUSTMENT

    ;invoke  SetColorAdjustment, hdc, addr @colorAdjustment
    invoke  PaintBitmapTransEx, hdc, [edi].aParam, addr @stRect, STRETCH_XY
    ;invoke  SetColorAdjustment, hdc, addr @oldColorAdjustment
    
    push    edi
    mov     bx, [edi].status
    and     bx, BTNS_CLICK
    .IF     bx
        ;mov     ax, -50
        ;mov     [esi].caBrightness, ax
        invoke  SetPen, hdc, PS_SOLID, 2, 00111111h
        mov     @oldPen, eax
        invoke  GetStockObject, NULL_BRUSH
        invoke  SelectObject, hdc, eax
        mov     @oldBrush, eax
        invoke  PaintRoundRect, hdc, addr @stRect, 10
        invoke  SelectObject, hdc, @oldBrush
        invoke  SelectObject, hdc, @oldPen
        invoke  DeleteObject, eax
    .ELSE
        mov     bx, [edi].status
        and     bx, BTNS_HOVER
        .IF     bx
            mov     esi, [edi].cParam
            assume  esi: PTR ENEMYDATA
            mov     eax, @stRect.top
            sub     eax, 10
            mov     @stRect.top, eax
            add     eax, 5
            mov     @stRect.bottom, eax
            invoke  CreateSolidBrush, 00112222h
            invoke  SelectObject, hdc, eax
            mov     @oldBrush, eax
            invoke  GetStockObject, NULL_PEN
            invoke  SelectObject, hdc, eax
            mov     @oldPen, eax
            invoke  PaintRect, hdc, addr @stRect

            fild    @stRect.right
            fisub   @stRect.left
            fild    [esi].health
            fidiv   [esi].healthMax
            fstp    @ratio
            fld     @ratio
            fmul
            fistp   @val
            mov     eax, @stRect.left
            add     eax, @val
            mov     @stRect.right, eax
            fld     @ratio
            mov     @val, 200
            fimul   @val
            fistp   @val
            mov     eax, 00220000h
            mov     ah, BYTE PTR @val
            mov     ebx, 200
            sub     ebx, @val
            mov     al, bl

            invoke  CreateSolidBrush, eax
            invoke  SelectObject, hdc, eax
            invoke  DeleteObject, eax
            invoke  PaintRect, hdc, addr @stRect

            invoke  SelectObject, hdc, @oldBrush
            invoke  DeleteObject, eax
            invoke  SelectObject, hdc, @oldPen

        .ENDIF
    .ENDIF
    pop     edi

    xor     eax, eax
    ret
EnemyPaint   ENDP


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

PrefabReachEffectProj proc   x:DWORD, y:DWORD
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
    invoke  BindButtonToBitmap, pButton1, BULLET_B
    invoke  SetButtonSize, pButton1, 20, 20
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
PrefabReachEffectProj endp

PrefabReachEffectProjf proc   x:REAL4, y:REAL4
    invoke  real42dword, x
    push    eax
    invoke  real42dword, y
    mov     edx, eax
    pop     eax
    invoke  PrefabReachEffectProj, eax, edx
    ret
PrefabReachEffectProjf endp

PrefabReplayBtn proc   x:DWORD, y:DWORD
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 250
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 45
    mov     @stRect.top, eax
    add     eax, 20
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, QuitCallback, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    ; or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, GG_BUTTON
    invoke  SetButtonSize, pButton1, 500, 60
    ; ---- Proj
    invoke  RegisterProjectile, 0, real0, real0
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtDefaultUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, -1
    mov     [edx].lifetime, -1
    ;
    mov     eax, pProjt1
    ret
PrefabReplayBtn endp


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
    invoke  BindButtonToBitmap, pButton1, BULLET_B

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

PrefabProjA proc   x:DWORD, y:DWORD, dir:REAL4
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 5
    mov     @stRect.left, eax
    add     eax, 10
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 5
    mov     @stRect.top, eax
    add     eax, 10
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, BULLET_A
    invoke  SetButtonSize, pButton1, 15, 15
    ; ---- Proj
    invoke  RegisterProjectile, 5, real11, dir
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtDefaultUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, 1
    mov     [edx].lifetime, 1000
    ;
    mov     eax, pProjt1
    ret
PrefabProjA endp

PrefabProjB proc   x:DWORD, y:DWORD, dir:REAL4
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 5
    mov     @stRect.left, eax
    add     eax, 10
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 5
    mov     @stRect.top, eax
    add     eax, 10
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, BULLET_B
    invoke  SetButtonSize, pButton1, 5, 5
    ; ---- Proj
    invoke  RegisterProjectile, 2, real11 , dir
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtFireUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, 1
    mov     [edx].lifetime, 40
    ;
    mov     eax, pProjt1
    ret
PrefabProjB endp

PrefabProjC proc   x:DWORD, y:DWORD, dir:REAL4
    local   @stRect:RECT, pButton1:DWORD, pProjt1:DWORD
    ; ---- Button
    mov     eax, x
    sub     eax, 5
    mov     @stRect.left, eax
    add     eax, 10
    mov     @stRect.right, eax
    ;
    mov     eax, y
    sub     eax, 5
    mov     @stRect.top, eax
    add     eax, 10
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     pButton1, eax
    invoke  SetButtonDepth, pButton1, -1000
    mov     eax, pButton1
    assume  eax: ptr BUTTONDATA
    or      [eax].isActive, BTNI_DISABLE
    invoke  BindButtonToBitmap, pButton1, BULLET_C
    invoke  SetButtonSize, pButton1, 15, 15
    ; ---- Proj
    invoke  RegisterProjectile, 12, real11, dir
    mov     pProjt1, eax
    invoke  ProjtBindButton, pProjt1, pButton1
    invoke  ProjtBindUpdate, pProjt1, ProjtMissleUpdate
    ;
    mov     edx, pProjt1
    assume  edx: ptr PROJTDATA
    mov     [edx].penetrate, 1
    mov     [edx].lifetime, 1000
    ;
    mov     eax, pProjt1
    ret
PrefabProjC endp

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

PrefabEnemy1 proc lvl:DWORD
    local   @stRect:RECT, pButton1:DWORD, pEnemy1:DWORD
    mov     eax, -100
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax

    mov     eax, -100
    mov     @stRect.top, eax
    add     eax, 30
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     esi, eax
    invoke  SetButtonDepth, esi, -10
    assume  esi: ptr BUTTONDATA
    or      [esi].isActive, BTNI_DISABLE_CLICK or BTNI_DISABLE_UPDATE
    invoke  BindButtonToBitmap, esi, ENEMY_SPRITE_1
    mov     [esi].pPaint, EnemyPaint
    
    mov     eax, 30
    add     eax, lvl
    invoke  RegisterEnemy, eax, real1, 10
    mov     pEnemy1, eax
    assume  eax: PTR ENEMYDATA
    mov     [eax].bParam, 3
    mov     [esi].cParam, eax
    invoke  EnemyBindButton, pEnemy1, esi
    invoke  EnemyBindUpdate, pEnemy1, EnemyDefaultUpdate
    mov     eax, pEnemy1
    ret
PrefabEnemy1 endp

PrefabEnemy2 proc lvl:DWORD
    local   @stRect:RECT, pButton1:DWORD, pEnemy1:DWORD
    mov     eax, -100
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax

    mov     eax, -100
    mov     @stRect.top, eax
    add     eax, 30
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     esi, eax
    invoke  SetButtonDepth, esi, -10
    assume  esi: ptr BUTTONDATA
    or      [esi].isActive, BTNI_DISABLE_CLICK or BTNI_DISABLE_UPDATE
    invoke  BindButtonToBitmap, esi, ENEMY_SPRITE_2
    mov     [esi].pPaint, EnemyPaint
    
    mov     eax, 100
    add     eax, lvl
    invoke  RegisterEnemy, eax, real1, 10
    mov     pEnemy1, eax
    assume  eax: PTR ENEMYDATA
    mov     [eax].bParam, 17
    mov     [esi].cParam, eax
    invoke  EnemyBindButton, pEnemy1, esi
    invoke  EnemyBindUpdate, pEnemy1, EnemyDefaultUpdate
    mov     eax, pEnemy1
    ret
PrefabEnemy2 endp

PrefabEnemy3 proc uses esi lvl:DWORD 
    local   @stRect:RECT, pButton1:DWORD, pEnemy1:DWORD
    mov     eax, -100
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax

    mov     eax, -100
    mov     @stRect.top, eax
    add     eax, 30
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     esi, eax
    invoke  SetButtonDepth, esi, -10
    assume  esi: ptr BUTTONDATA
    or      [esi].isActive, BTNI_DISABLE_CLICK or BTNI_DISABLE_UPDATE
    invoke  BindButtonToBitmap, esi, ENEMY_SPRITE_3
    mov     [esi].pPaint, EnemyPaint
    
    mov     eax, 10
    add     eax, lvl
    invoke  RegisterEnemy, eax, PI, 10
    mov     pEnemy1, eax
    assume  eax: PTR ENEMYDATA
    mov     [eax].bParam, 2
    mov     [esi].cParam, eax
    invoke  EnemyBindButton, pEnemy1, esi
    invoke  EnemyBindUpdate, pEnemy1, EnemyDefaultUpdate
    mov     eax, pEnemy1
    ret
PrefabEnemy3 endp

PrefabEnemy4 proc lvl:DWORD
    local   @stRect:RECT, pButton1:DWORD, pEnemy1:DWORD
    mov     eax, -100
    mov     @stRect.left, eax
    add     eax, 30
    mov     @stRect.right, eax

    mov     eax, -100
    mov     @stRect.top, eax
    add     eax, 30
    mov     @stRect.bottom, eax
    invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
    mov     esi, eax
    invoke  SetButtonDepth, esi, -10
    assume  esi: ptr BUTTONDATA
    or      [esi].isActive, BTNI_DISABLE_CLICK or BTNI_DISABLE_UPDATE
    invoke  BindButtonToBitmap, esi, ENEMY_SPRITE_4
    mov     [esi].pPaint, EnemyPaint
    
    mov     ecx, 10
    mov     eax, lvl
    mul     ecx
    add     eax, 500
    invoke  RegisterEnemy, eax, real1of2, 10
    mov     pEnemy1, eax
    assume  eax: PTR ENEMYDATA
    mov     [eax].bParam, 87
    mov     [esi].cParam, eax
    invoke  EnemyBindButton, pEnemy1, esi
    invoke  EnemyBindUpdate, pEnemy1, EnemyDefaultUpdate
    mov     eax, pEnemy1
    ret
PrefabEnemy4 endp

end
