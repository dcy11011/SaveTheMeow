include button.inc

MAXENYCNT        EQU     250   ; 最大的敌人数量
MAXROADMAPCNT    EQU     50   ; 最大的路径点数量


ENEMYDATA struct
    isActive        WORD    ?
    health          DWORD   ?
    healthMax       DWORD   ?

    xf              REAL4   ?
    yf              REAL4   ?
    speed           REAL4   ?
    radius          REAL4   ?
    attack          DWORD   ?
    progress        REAL4   ? ; total dist (1D)

    aParam          DWORD   ? ; use for restore some data
    bParam          DWORD   ? ; use for restore some data
    pAsButton       DWORD   ?
    pHurtEvent      DWORD   ?
    pDeathEvent     DWORD   ?
    pUpdateEvent    DWORD   ?
ENEMYDATA ends


RegisterEnemy           PROTO    hp: DWORD, speed: REAL4, atk: DWORD
EnemyBindButton         PROTO    self: ptr ENEMYDATA, btn: ptr BUTTONDATA
EnemyBindUpdate         PROTO    self: ptr ENEMYDATA, upd: DWORD

EnemyUpdatePosition     PROTO    self: ptr ENEMYDATA        ; update buttom pos to enemy pos
EnemySetPositioni       PROTO    self: ptr ENEMYDATA, x:DWORD, y:DWORD
EnemySetPositionf       PROTO    self: ptr ENEMYDATA, x:REAL4, y:REAL4
EnemyMovePositioni      PROTO    self: ptr ENEMYDATA, x:DWORD, y:DWORD
EnemyMovePositionf      PROTO    self: ptr ENEMYDATA, x:REAL4, y:REAL4

EnemyStepForward        PROTO    self: ptr ENEMYDATA

EnemyDefaultUpdate      PROTO    cnt:DWORD, pEnemy: ptr ENEMYDATA
EnemyMouseUpdate        PROTO    cnt:DWORD, pEnemy: ptr ENEMYDATA
EnemyUpdateAll          PROTO    cnt:DWORD                                  ; 发送更新消息


RoadmapClear            PROTO  
RoadmapAddi             PROTO    x:DWORD, y:DWORD
RoadmapAddf             PROTO    x:REAL4, y:REAL4
RoadmapTotalDist        PROTO   
RoadmapCalcCurrent      PROTO    s:REAL4 ; 依据一维距离计算当前位置 返回-> eax, edx