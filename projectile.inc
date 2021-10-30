include button.inc

MAXPJTCNT        EQU     750   ; 最大的投射物数量


PROJTDATA struct
    isActive        WORD    ?

    xf              REAL4   ?
    yf              REAL4   ?
    speed           REAL4   ?
    direction       REAL4   ?
    radius          REAL4   ?
    attack          DWORD   ?

    penetrate       DWORD   ? 
    iframe          DWORD   ? 
    lifetime        DWORD   ? 
    pAsButton       DWORD   ?
    pHitEvent       DWORD   ?
    pUpdateEvent    DWORD   ?
PROJTDATA ends


RegisterProjectile      PROTO    atk: DWORD, speed: REAL4, dir:REAL4
ProjtBindButton         PROTO    self: ptr PROJTDATA, btn: ptr BUTTONDATA
ProjtBindUpdate         PROTO    self: ptr PROJTDATA, upd: DWORD

ProjtUpdatePosition     PROTO    self: ptr PROJTDATA        ; update buttom pos to enemy pos
ProjtSetPositioni       PROTO    self: ptr PROJTDATA, x:DWORD, y:DWORD
ProjtSetPositionf       PROTO    self: ptr PROJTDATA, x:REAL4, y:REAL4
ProjtMovePositioni      PROTO    self: ptr PROJTDATA, x:DWORD, y:DWORD
ProjtMovePositionf      PROTO    self: ptr PROJTDATA, x:REAL4, y:REAL4
ProjtUpdateRadius       PROTO    self: ptr PROJTDATA  ; use button size to set radius

ProjtSetSpeed           PROTO    self: ptr PROJTDATA, speed:REAL4
ProjtSetDirection       PROTO    self: ptr PROJTDATA, direction:REAL4
ProjtStepForward        PROTO    self: ptr PROJTDATA

ProjtSetDeath           PROTO    self: ptr PROJTDATA
ProjtCheckDeath         PROTO    self: ptr PROJTDATA
ProjtHitEnemies         PROTO    self: ptr PROJTDATA, cnt:DWORD

ProjtDefaultUpdate      PROTO    cnt:DWORD, pProjt: ptr PROJTDATA
ProjtHurtEffectUpdate   PROTO    cnt:DWORD, pProjt: ptr PROJTDATA
ProjtUpdateAll          PROTO    cnt:DWORD                                  ; 发送更新消息

