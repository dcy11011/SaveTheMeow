BTNS_UNUSED      EQU     0000h
BTNS_WAIT        EQU     0001h
BTNS_HOVER       EQU     0002h
BTNS_CLICK       EQU     0004h
BTNI_DISABLE     EQU     0001h
BTNI_RUNNING     EQU     0002h
MAXBTNCNT        EQU     250

BUTTONDATA struct
    right           DWORD   ?
    top             DWORD   ?
    left            DWORD   ?
    bottom          DWORD   ?
    isActive        WORD    ?
    status          WORD    ?
    pPaint          DWORD   ?
    aParam          DWORD   ? ; use for restore some data
    bParam          DWORD   ? ; use for restore some data
    pClickEvent     DWORD   ?
    pHoverEvent     DWORD   ?
    pUpdateEvent    DWORD   ?
BUTTONDATA ends

RegisterButton          PROTO    pRect: ptr RECT, pPaint:DWORD, pClickEvent:DWORD, pHoverEvent:DWORD, pUpdateEvent:DWORD
PaintButton             PROTO    hDc:DWORD, pButton: ptr BUTTONDATA
PaintAllButton          PROTO    hDc:DWORD
GetButtonRect           PROTO    pButton: ptr BUTTONDATA, pRect: ptr RECT
DeleteButton            PROTO    pButton: ptr BUTTONDATA

SendClickInfo           PROTO    x:DWORD, y:DWORD
SendHoverInfo           PROTO    x:DWORD, y:DWORD
SendUpdateInfo          PROTO    cnt:DWORD
ClearClick              PROTO

