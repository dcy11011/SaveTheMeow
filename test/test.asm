.386
.model flat, stdcall
option casemap:none

printf          PROTO C :ptr sbyte, :VARARG

.data 
szFloat     byte    "float:%lf", 0ah, 0dh, 0
intVal      DWORD   90
float5       REAL4   5.0
float4       REAL4   4.0
float3       REAL4   3.0
szBuffer    byte    10 DUP(0)
result      REAL8   2.0

.code

real42dword    PROC realValue: REAL4
    local   @result:DWORD
    fld     DWORD ptr realValue
    fistp   DWORD ptr @result
    mov     eax, @result
    ret
real42dword    ENDP

MAIN:
    fld     DWORD ptr float5
    fld     DWORD ptr float4
    fmul
    fld     DWORD ptr float3
    fsub
    fst     QWORD ptr result
    invoke  printf, offset szFloat, result
    ret
end MAIN