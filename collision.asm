.386
.model flat, stdcall
option casemap:none

include util.inc

.data

.code

CalcDist    proc  x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
    mov     eax, x1
    sub     eax, x2
    mov     x1, eax
    mov     eax, y1
    sub     eax, y2
    mov     y1, eax
    fild    DWORD ptr x1
    fild    DWORD ptr x1
    fmul
    fild    DWORD ptr y1
    fild    DWORD ptr y1
    fmul
    fadd
    fsqrt
    fstp    DWORD ptr x1
    mov     eax, x1
    ret
CalcDist    endp

end
