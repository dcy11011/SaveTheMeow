.386
.model flat, stdcall
option casemap:none

include util.inc

.data
szdPrintFormat      byte    "%d", 0dh, 0ah, 0
szdPrint2Format     byte    "%d %d", 0dh, 0ah, 0
szdPrint3Format     byte    "%d %d %d", 0dh, 0ah, 0
PI                  REAL4   3.1415926

szdPrintReal4Format byte    "%f", 0dh, 0ah, 0

.code
dPrint      proc  data:DWORD
    pushad
    invoke  printf, offset szdPrintFormat, data
    popad
    ret
dPrint      ENDP

dPrint2     proc  data0:DWORD, data1:DWORD
    pushad
    invoke  printf, offset szdPrint2Format, data0, data1
    popad
    ret
dPrint2     ENDP

dPrint3     proc  data0:DWORD, data1:DWORD, data2:DWORD
    pushad
    invoke  printf, offset szdPrint3Format, data0, data1, data2
    popad
    ret
dPrint3     ENDP

dword2real4    PROC intValue: DWORD
    local   @result:DWORD
    fild    DWORD ptr intValue
    fstp    DWORD ptr @result
    mov     eax, @result
    ret
dword2real4    ENDP

real42dword    PROC realValue: REAL4
    local   @result:DWORD
    fld     DWORD ptr realValue
    fistp   DWORD ptr @result
    mov     eax, @result
    ret
real42dword    ENDP


end
