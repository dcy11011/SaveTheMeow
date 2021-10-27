.386
.model flat, stdcall
option casemap:none

printf          PROTO C :ptr sbyte, :VARARG

TESTSTRUCT struct
    a   dd  ?
    b   dd  5
TESTSTRUCT ends

.data?
    arrayStruct TESTSTRUCT 30000 DUP(<?>)

.data
    
    stTest      TESTSTRUCT <1,2>
    printFormat     db      "a=%d b=%d", 0ah, 0dh, 0
    printFormat1    db      "%d",0dh, 0ah, 0

.code
    testFunc    proc    stParam:ptr TESTSTRUCT, Param2:DWORD
        mov     eax, stParam
        assume  eax: ptr TESTSTRUCT
        invoke  printf, offset printFormat, [eax].a, Param2
        ret
    testFunc    ENDP

    MAIN:
        invoke  printf, offset printFormat1, esp 
        mov     ebx, testFunc
        push    10
        push    offset stTest
        call    ebx
        invoke  printf, offset printFormat1, esp 
        
        lea     edi, arrayStruct
        invoke  printf, offset printFormat1, edi
        mov     eax, sizeof TESTSTRUCT
        mov     ebx, 0
        mul     ebx
        add     edi, eax
        invoke  printf, offset printFormat1, eax
        invoke  printf, offset printFormat1, edi
        assume  edi: ptr TESTSTRUCT
        mov     ebx, [edi].b
        invoke  printf, offset printFormat1, ebx


        xor eax, eax
        ret

    end MAIN
        
