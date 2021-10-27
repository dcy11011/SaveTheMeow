D_POINT     struct
    x   DWORD   ?
    y   DWORD   ?
D_POINT     ends

printf          PROTO C :ptr sbyte, :VARARG
qsort           PROTO C :DWORD, :DWORD, :DWORD, :DWORD

dPrint          PROTO  data:DWORD
dPrint2         PROTO  data0:DWORD, data1:DWORD
dPrint3         PROTO  data0:DWORD, data1:DWORD, data2:DWORD

