include button.inc

MAXENYCNT        EQU     250   ; 最大的敌人数量


ENEMYDATA struct
    isActive        WORD    ?
    health          DWORD   ?
    healthMax       DWORD   ?

    xf              REAL4   ?
    yf              REAL4   ?
    speed           DWORD   ?
    attack          DWORD   ?
    progress        DWORD   ? ; Precentage 0 -> start 1 -> end

    aParam          DWORD   ? ; use for restore some data
    bParam          DWORD   ? ; use for restore some data
    pAsButton       DWORD   ?
    pHurtEvent      DWORD   ?
    pDeathEvent     DWORD   ?
    pUpdateEvent    DWORD   ?
ENEMYDATA ends


RegisterEnemy           PROTO    hp: DWORD, speed: DWORD, atk: DWORD
EnemyBindButton         PROTO    self: ptr ENEMYDATA, btn: ptr BUTTONDATA
EnemyBindUpdate         PROTO    self: ptr ENEMYDATA, upd: DWORD

EnemyUpdatePosition     PROTO    self: ptr ENEMYDATA        ; update buttom pos to enemy pos
EnemySetPositioni       PROTO    self: ptr ENEMYDATA, x:DWORD, y:DWORD
EnemySetPositionf       PROTO    self: ptr ENEMYDATA, x:REAL4, y:REAL4
EnemyMovePositioni      PROTO    self: ptr ENEMYDATA, x:DWORD, y:DWORD
EnemyMovePositionf      PROTO    self: ptr ENEMYDATA, x:REAL4, y:REAL4

<<<<<<< HEAD
=======

>>>>>>> 7af19402107ba63452b5a99703da51c31b3c12a4
EnemyDefaultUpdate      PROTO    cnt:DWORD, pEnemy: ptr ENEMYDATA
EnemyUpdateAll          PROTO    cnt:DWORD                                  ; 发送更新消息

