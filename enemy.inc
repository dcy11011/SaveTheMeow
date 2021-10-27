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


RegisterEnemyAt         PROTO    self: ptr ENEMYDATA, hp: DWORD, speed: DWORD, atk: DWORD
BindButton              PROTO    self: ptr ENEMYDATA, btn: ptr BUTTONDATA


ClearClick              PROTO                                               ; 清除所有按钮的按下状态。请在LBUTTONUP消息处理中加入这个函数 

