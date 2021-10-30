

MAXMAPBLOCKCNT      EQU     350

MAPB_UNUSED         EQU     00000000h
MAPB_WAITING        EQU     00000001h
MAPB_POPPING        EQU     00000002h
MAPB_POPPED         EQU     00000004h
MAPB_CONTRACTING    EQU     00000008h
MAPB_DISABLED       EQU     00000010h

MAPB_BLOCKWIDTH     EQU     50
MAPB_BLOCKHEIGHT    EQU     50
MAPB_BLOCKMARGINY   EQU     50
MAPB_BLOCKMARGINX   EQu     50


MAPB_BTNDISTANCE    EQU     60  ; distance of pop

MAPB_BTNTOTAL       EQU     6

MAPB_BTNWIDTH       EQU     30
MAPB_BTNHEIGHT      EQU     30

MAP_HEIGHT          EQU     10
MAP_WIDTH           EQU     15

MAX_ROUTEPOINT      EQU     20


MAPBLOCKDATA    struct
    centerX         DWORD   ?
    centerY         DWORD   ?
    pAsButton       DWORD   ?   ; pointer to the main button
    status          DWORD   ?   ; either MAPB_POPPING nor MAPB_CONTRACTING
    pButton         DWORD   MAPB_BTNTOTAL DUP(?) ; pointer to popup buttons
    angButton       DWORD   MAPB_BTNTOTAL DUP(?) ; angle of poping
    action_step     REAL4   ?   ; for animation
    diaplaySet      DWORD   ?   ; which set of pop buttons to diaplay; set the setID by 'defualtButtonGroupID' in .asm
MAPBLOCKDATA    ends

RegisterMapBlock                PROTO    posX:DWORD, posY:DWORD     ; 注册地图块，传入左上角坐标
BindMapBlockPopButtonsClick     PROTO    pMapBlock: ptr MAPBLOCKDATA, id:DWORD, pClickEvent:DWORD ; 根据按键编号绑定点击事件
BindMapBlockPopButtonsBitmap    PROTO    pMapBlock: ptr MAPBLOCKDATA, id:DWORD, IDBitmap:DWORD ; 根据按键编号绑定图片
SetMapBlockDisplaySet           PROTO    pMapBlock: ptr MAPBLOCKDATA, id:DWORD  ; 切换按键组。在defualtButtonGroupID中设置按键组

LoadMapFromFile                 PROTO    offsetX:DWORD, offsetY:DWORD ; 读取地图，创建图格。读取的路径列表指针在eax，路径点数量在edx