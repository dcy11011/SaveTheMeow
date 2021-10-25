
OBJDATA struct
    posX        DWORD   ?
    posY        DWORD   ?
    r           DWORD   ?
    velX        DWORD   2
    velY        DWORD   2
OBJDATA ends

printf              PROTO C :ptr sbyte, :VARARG

PaintObj         PROTO  hDc:dword, lpObj: ptr OBJDATA
SetObjPos        PROTO  lpObj: ptr OBJDATA, posX:dword, posY:dword
SetObjRadius     PROTO  lpObj: ptr OBJDATA, r:dword
SetObjVelocity   PROTO  lpObj: ptr OBJDATA, velX:dword, velY:dword
MoveObj          PROTO  lpObj: ptr OBJDATA, lpRect: ptr RECT