D_POINT     struct
    x   DWORD   ?
    y   DWORD   ?
D_POINT     ends

F_POINT     struct
    x   REAL4   ?
    y   REAL4   ?
F_POINT     ends

printf          PROTO C :ptr sbyte, :VARARG
qsort           PROTO C :DWORD, :DWORD, :DWORD, :DWORD
memset          PROTO C :DWORD, :DWORD, :DWORD
memcpy          PROTO C :DWORD, :DWORD, :DWORD
fopen           PROTO C :ptr sbyte, :ptr sbyte
fscanf          PROTO C :DWORD, :ptr sbyte, :VARARG
fclose          PROTO C :DWORD
rand            PROTO C 

dPrint          PROTO  data:DWORD
dPrint2         PROTO  data0:DWORD, data1:DWORD
dPrint3         PROTO  data0:DWORD, data1:DWORD, data2:DWORD
dPrintFloat     PROTO  data:DWORD
dPrint2Float    PROTO  data0:DWORD, data1:DWORD

dword2real4     PROTO  intValue: DWORD
real42dword     PROTO  realValue: REAL4

UpdateMousePos  PROTO  x:DWORD, y:DWORD

OpenTextFile    PROTO  szFileName:DWORD
GetFileLine     PROTO  pFile:DWORD
CloseFile       PROTO  pFile:DWORD

Random          PROTO  

SetRect         PROTO  pRect:DWORD, left:DWORD, top:DWORD, right:DWORD, bottom:DWORD

DwordToStr      PROTO  sxStr:PTR BYTE , val:DWORD

EXTERNDEF PI:REAL4
EXTERNDEF PIby2:REAL4
EXTERNDEF PIm2:REAL4
EXTERNDEF real0:REAL4
EXTERNDEF real1:REAL4
EXTERNDEF real2:REAL4
EXTERNDEF real1n:REAL4
EXTERNDEF real1of2:REAL4
EXTERNDEF real1of3:REAL4
EXTERNDEF real2of3:REAL4
EXTERNDEF real9of10:REAL4
EXTERNDEF real99of100:REAL4
EXTERNDEF real5:REAL4
EXTERNDEF real11:REAL4
EXTERNDEF real20:REAL4
EXTERNDEF real100:REAL4

EXTERNDEF MouseXi:DWORD
EXTERNDEF MouseYi:DWORD

EXTERNDEF MouseXf:REAL4
EXTERNDEF MouseYf:REAL4
