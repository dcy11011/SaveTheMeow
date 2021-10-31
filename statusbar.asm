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
include prefab.inc
include projectile.inc

include rclist.inc

include statusbar.inc

.data   
coin        DWORD   15
health      DWORD   100
waves       DWORD   0
actionRatio REAL4   0.80

.data?
textbuffer  BYTE    20 DUP(?)


.code

PaintStatusBar      PROC    uses ebx edi esi   hdc:DWORD, pButton:PTR BUTTONDATA
    local   @oldPen:DWORD, @oldBrush:DWORD, @rect:RECT
    mov     esi, pButton
    assume  esi:PTR BUTTONDATA
    invoke  GetButtonRect, esi, addr @rect

    invoke  PaintBitmapTransEx, hdc, STATUS_BAR, addr @rect, STRETCH_XY

    invoke  SetBkMode, hdc, TRANSPARENT

    invoke  SetTextColor, hdc, 0011ddddh
    invoke  SetRect, addr @rect, 60, 20, 120, 40
    invoke  DwordToStr, offset textbuffer, coin
    invoke  DrawText, hdc, offset textbuffer, -1, addr @rect, \
            DT_SINGLELINE or DT_VCENTER

    invoke  SetTextColor, hdc, 00dd4444h
    invoke  SetRect, addr @rect, 360, 20, 420, 40
    invoke  DwordToStr, offset textbuffer, waves
    invoke  DrawText, hdc, offset textbuffer, -1, addr @rect, \
            DT_SINGLELINE or DT_VCENTER
    
    invoke  SetTextColor, hdc, 004444ddh
    invoke  SetRect, addr @rect, 660, 20, 720, 40
    invoke  DwordToStr, offset textbuffer, health
    invoke  DrawText, hdc, offset textbuffer, -1, addr @rect, \
            DT_SINGLELINE or DT_VCENTER


    ret
PaintStatusBar      ENDP

RegisterStatusBar   PROC    uses ebx edi esi  pClientRect:ptr RECT
    local   @rect:RECT 
    mov     edx, pClientRect
    assume  edx: PTR RECT
    mov     eax, [edx].left
    mov     @rect.left, eax
    mov     eax, [edx].right
    mov     @rect.right, eax
    mov     eax, [edx].top
    mov     @rect.top, eax
    add     eax, 60
    mov     @rect.bottom, eax

    invoke  RegisterButton, addr @rect, PaintStatusBar, 0, 0, 0
    mov     esi, eax
    assume  esi:PTR BUTTONDATA
    mov     ax, BTNI_DISABLE_CLICK or BTNI_DISABLE_HOVER
    mov     [esi].isActive, ax

    ret
RegisterStatusBar   ENDP

AddCoin     PROC    val:DWORD
    mov     eax, coin
    add     eax, val
    .IF     eax >= 0
        mov     coin, eax
        mov     eax, 0
    .ELSE
        mov     eax, 1
    .ENDIF
    ret
AddCoin     ENDP

AddHealth     PROC    val:DWORD
    mov     eax, health
    add     eax, val
    .IF     eax >= 0
        mov     health, eax
        mov     eax, 0
    .ELSE
        mov     eax, 1
    .ENDIF
    ret
AddHealth     ENDP

addWave     PROC    val:DWORD
    mov     eax, waves
    add     eax, val
    mov     waves, eax
    ret
addWave     ENDP

PaintPopAddCoin PROC    uses ebx edi esi  hdc:DWORD, pButton:PTR BUTTONDATA
    local   @oldPen:DWORD, @oldBrush:DWORD, @rect:RECT
    mov     esi, pButton
    assume  esi:PTR BUTTONDATA
    invoke  GetButtonRect, esi, addr @rect

    invoke  PaintBitmapTransEx, hdc, ADDCOIN_HEAD, addr @rect, CENTER_XY
    invoke  SetBkMode, hdc, TRANSPARENT

    invoke  SetTextColor, hdc, 0011ddddh
    mov     eax, @rect.left
    add     eax, 40
    mov     @rect.left, eax
    add     eax, 40
    mov     @rect.right, eax
    invoke  DwordToStr, offset textbuffer, [esi].bParam
    invoke  DrawText, hdc, offset textbuffer, -1, addr @rect, \
            DT_SINGLELINE or DT_VCENTER

    ret
PaintPopAddCoin ENDP

UpdatePopAddCoin  PROC uses ebx edi esi  cnt:DWORD, pButton:PTR BUTTONDATA
    local   @val:DWORD, @x1:REAL4, @x2:REAL4
    mov     esi, pButton
    assume  esi: PTR BUTTONDATA
    
    .IF     [esi].cParam > 20
        invoke  DeleteButton, esi
    .ENDIF
    mov     eax, [esi].cParam
    add     eax, 1
    mov     [esi].cParam, eax
    fild    [esi].aParam
    fstp    @x1
    fild    [esi].top
    fstp    @x2
    invoke  Lerp, @x1, @x2, actionRatio
    mov     @val, eax
    fld     @val
    fistp   @val
    invoke  MoveButtonTo, esi, [esi].left, @val
    ret
UpdatePopAddCoin  ENDP

PopAddCoin      PROC    uses ebx esi edi valCoin:DWORD, posX:DWORD, posY:DWORD
    local   @rect:RECT
    invoke  SetRect, addr @rect, 0, 0, 0, 0
    invoke  RegisterButton, addr @rect, PaintPopAddCoin, 0, 0,UpdatePopAddCoin
    invoke  SetButtonDepth, eax, -7510
    mov     esi, eax
    assume  esi: PTR BUTTONDATA
    invoke  SetButtonSize, esi, 40, 20
    invoke  MoveButtonCenterTo, esi, posX, posY
    mov     [esi].cParam, 0
    mov     eax, valCoin
    mov     [esi].bParam, eax
    mov     eax, [esi].top
    sub     eax, 30
    mov     [esi].aParam, eax
    invoke  AddCoin, valCoin
    ret
PopAddCoin      ENDP

PopAddCoinf     PROC    uses ebx esi edi valCoin:DWORD, posX:REAL4, posY:REAL4
    local   @x:REAL4, @y:REAL4
    fld     posX
    fistp   @x
    fld     posY
    fistp   @y
    invoke  PopAddCoin, valCoin, @x, @y
    ret
PopAddCoinf     ENDP

end