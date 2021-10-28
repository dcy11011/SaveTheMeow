MAPBLOCKDATA    struct
    centerX         DWORD   ?
    centerY         DWORD   ?
    pAsButton       DWORD   ?
    status          DWORD   ?
    pButton1        DWORD   ?
    pButton2        DWORD   ?
    pButton3        DWORD   ?
    pBtn_Upgrade    DWORD   ?
    pBtn_Remove     DWORD   ?
    action_step     DWORD   ?
MAPBLOCKDATA    ends

MAXMAPBLOCKCNT      EQU     250

MAPB_UNUSED         EQU     00000000h
MAPB_WAITING        EQU     00000001h
MAPB_POPPING        EQU     00000002h
MAPB_POPPED         EQU     00000004h
MAPB_CONTRACTING    EQU     00000008h
MAPB_DISABLED       EQU     00000010h

MAPB_BLOCKWIDTH     EQU     80
MAPB_BLOCKHEIGHT    EQU     80

MAPB_STARTSIZE      EQU     0
MAPB_ENDSIZE        EQU     40
MAPB_MAXSTEP        EQU     100
MAPB_STEP           EQU     3
MAPB_BTNDISTANCE    EQU     50

RegisterMapBlock    PROTO    posX:DWORD, posY:DWORD     ; 注册地图块，传入左上角坐标
