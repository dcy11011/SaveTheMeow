D_POINT     struct
    x   DWORD   ?
    y   DWORD   ?
D_POINT     ends

printf          PROTO C :ptr sbyte, :VARARG
qsort           PROTO C :DWORD, :DWORD, :DWORD, :DWORD
memset          PROTO C :DWORD, :DWORD, :DWORD
memcpy          PROTO C :DWORD, :DWORD, :DWORD

dPrint          PROTO  data:DWORD
dPrint2         PROTO  data0:DWORD, data1:DWORD
dPrint3         PROTO  data0:DWORD, data1:DWORD, data2:DWORD
dPrintFloat     PROTO  data:DWORD
dPrint2Float    PROTO  data0:DWORD, data1:DWORD

dword2real4     PROTO  intValue: DWORD
real42dword     PROTO  realValue: REAL4

UpdateMousePos  PROTO  x:DWORD, y:DWORD

EXTERNDEF PI:REAL4
EXTERNDEF MouseXi:DWORD
EXTERNDEF MouseYi:DWORD

EXTERNDEF MouseXf:REAL4
EXTERNDEF MouseYf:REAL4
