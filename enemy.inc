include button.inc

MAXENYCNT        EQU     250   ; 最大的敌人数量


ENEMYDATA struct
    isActive        WORD    ?
    health          DWORD   ?
    healthMax       DWORD   ?

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


EnemyDefaultUpdate      PROTO    cnt:DWORD, pEnemy: ptr ENEMYDATA
EnemyUpdateAll          PROTO    cnt:DWORD                                  ; 发送更新消息

