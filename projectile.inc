include button.inc

MAXPJTCNT        EQU     250   ; 最大的投射物数量


PROJTDATA struct
    isActive        WORD    ?

    xf              REAL4   ?
    yf              REAL4   ?
    speed           REAL4   ?
    direction       REAL4   ?
    attack          DWORD   ?

    aParam          DWORD   ? ; use for restore some data
    bParam          DWORD   ? ; use for restore some data
    pAsButton       DWORD   ?
    pHurtEvent      DWORD   ?
    pDeathEvent     DWORD   ?
    pUpdateEvent    DWORD   ?
PROJTDATA ends


RegisterProjectile        PROTO    atk: DWORD, speed: REAL4
ProjtBindButton         PROTO    self: ptr PROJTDATA, btn: ptr BUTTONDATA
ProjtBindUpdate         PROTO    self: ptr PROJTDATA, upd: DWORD

ProjtUpdatePosition     PROTO    self: ptr PROJTDATA        ; update buttom pos to enemy pos
ProjtSetPositioni       PROTO    self: ptr PROJTDATA, x:DWORD, y:DWORD
ProjtSetPositionf       PROTO    self: ptr PROJTDATA, x:REAL4, y:REAL4
ProjtMovePositioni      PROTO    self: ptr PROJTDATA, x:DWORD, y:DWORD
ProjtMovePositionf      PROTO    self: ptr PROJTDATA, x:REAL4, y:REAL4

ProjtSetSpeed           PROTO    self: ptr PROJTDATA, speed:REAL4
ProjtSetDirection       PROTO    self: ptr PROJTDATA, direction:REAL4
ProjtStepForward        PROTO    self: ptr PROJTDATA

ProjtDefaultUpdate      PROTO    cnt:DWORD, pProjt: ptr PROJTDATA
ProjtUpdateAll          PROTO    cnt:DWORD                                  ; 发送更新消息

