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
    add     eax, coin
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
    add     eax, health
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
    add     eax, waves
    mov     waves, eax
    ret
addWave     ENDP

PaintPopAddcoin PROC    uses ebx edi esi  hdc:DWORD, pButton:PTR BUTTONDATA
    local   @oldPen:DWORD, @oldBrush:DWORD, @rect:RECT
    mov     esi, pButton
    assume  esi:PTR BUTTONDATA
    invoke  GetButtonRect, esi, addr @rect

    invoke  PaintBitmapTransEx, hdc, ADDCOIN_HEAD, addr @rect, CENTER_XY
    invoke  SetBkMode, hdc, TRANSPARENT

    invoke  SetTextColor, hdc, 0011ddddh
    invoke  DwordToStr, offset textbuffer, [esi].bParam
    invoke  DrawText, hdc, offset textbuffer, -1, addr @rect, \
            DT_SINGLELINE or DT_VCENTER

    ret
PaintPopAddcoin ENDP


end