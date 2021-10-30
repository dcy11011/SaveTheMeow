.386
.model flat, stdcall
option casemap:none

include util.inc
include button.inc

.data

.code

CalcDist    proc  x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4
    fld     DWORD ptr x1
    fld     DWORD ptr x2
    fsub
    fstp    DWORD ptr x1
    fld     DWORD ptr y1
    fld     DWORD ptr y2
    fsub
    fstp    DWORD ptr y1
    ; delta x, delta y
    fld     DWORD ptr x1
    fld     DWORD ptr x1
    fmul
    fld     DWORD ptr y1
    fld     DWORD ptr y1
    fmul
    fadd
    fsqrt
    fstp    DWORD ptr x1
    mov     eax, x1
    ret
CalcDist    endp

CalcDisti   proc  x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
    invoke  dword2real4, x1
    mov     x1, eax
    invoke  dword2real4, y1
    mov     y1, eax
    invoke  dword2real4, x2
    mov     x2, eax
    invoke  dword2real4, y2
    mov     y2, eax
    invoke  CalcDist, x1, y1, x2, y2
    ret
CalcDisti   endp

CircleCollision proc  x1:REAL4, y1:REAL4, r1:REAL4, x2:REAL4, y2:REAL4, r2:REAL4
    local   dist: REAL4
    invoke  CalcDist, x1, y1, x2, y2
    mov     dist, eax
    fld     DWORD ptr dist
    fld     DWORD ptr r1
    fld     DWORD ptr r2
    fadd
    fcompp  ; if r1+r2 > dist return 0
    fstsw   ax
    sahf
    jb      @f
    mov     eax, 1
    ret
    @@:
    xor     eax, eax
    ret
CircleCollision endp

GetAtan2 proc  x:REAL4, y:REAL4
    local   tmp:REAL4
    fld     DWORD ptr y
    fld     DWORD ptr x
    fpatan  
    fstp    DWORD ptr tmp
    mov     eax, tmp
    ret
GetAtan2 endp

DirectionTo proc  x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4
    fld     DWORD ptr x2
    fld     DWORD ptr x1
    fsub
    fstp    DWORD ptr x1
    fld     DWORD ptr y2
    fld     DWORD ptr y1
    fsub
    fstp    DWORD ptr y1
    ; delta x, delta y
    invoke  GetAtan2, x1, y1
    ret
DirectionTo endp

GetDirVector proc dir:REAL4, len:REAL4 ; x, y -> eax, edx
    local   tmp:REAL4
    ; x
    fld     DWORD ptr dir
    fcos
    fld     DWORD ptr len
    fmul
    fstp    DWORD ptr tmp
    mov     eax, tmp
    ; y
    fld     DWORD ptr dir
    fsin
    fld     DWORD ptr len
    fmul
    fstp    DWORD ptr tmp
    mov     edx, tmp
    ret
GetDirVector endp


Lerp proc   x1:REAL4, x2:REAL4, a:REAL4
    fld     DWORD ptr x1
    fld     DWORD ptr a
    fmul
    fld     DWORD ptr x2
    fld1
    fld     DWORD ptr a
    fsub
    fmul
    fadd
    fstp    DWORD ptr a
    mov     eax, a
    ret
Lerp endp

LerpXY proc   x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4, a:REAL4
    invoke  Lerp, y1, y2, a
    mov     edx, eax
    push    edx
    invoke  Lerp, x1, x2, a
    pop     edx
    ret
LerpXY endp

GetCenterButton proc btn: DWORD
    local   t:DWORD
    mov     edx, btn
    assume  edx: ptr BUTTONDATA
    fild    DWORD ptr [edx].left
    fild    DWORD ptr [edx].right
    fadd
    fld     DWORD ptr real2
    fdiv
    ;
    fild    DWORD ptr [edx].top
    fild    DWORD ptr [edx].bottom
    fadd
    fld     DWORD ptr real2
    fdiv
    ;
    fstp    DWORD ptr t
    mov     edx, t
    fstp    DWORD ptr t
    mov     eax, t
    ret
GetCenterButton endp

GetRadiusButton proc btn: DWORD
    local   t:DWORD
    mov     edx, btn
    assume  edx: ptr BUTTONDATA
    mov     eax, 2
    mov     t, eax
    fild    DWORD ptr [edx].right
    fild    DWORD ptr [edx].left
    fsub
    fild    DWORD ptr t
    fdiv
    ;
    fild    DWORD ptr [edx].bottom
    fild    DWORD ptr [edx].top
    fsub
    fild    DWORD ptr t
    fdiv
    ;
    fadd
    fild    DWORD ptr t
    fdiv
    fstp    DWORD ptr t
    mov     eax, t
    ret
GetRadiusButton endp

end
