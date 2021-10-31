; BUTTONDATA.status 的可能值
BTNS_UNUSED      EQU     0000h ; 未使用，标记未使用的内存。该标记会使得所有按钮处理函数忽略之
BTNS_WAIT        EQU     0001h ; 等待状态，表示按钮未被触发。
BTNS_HOVER       EQU     0002h 
BTNS_CLICK       EQU     0004h

BTNI_DISABLE     EQU     0007h ; 禁用按钮，将不会收到鼠标事件
BTNI_HIDE        EQU     000Eh ; 隐藏按钮，但仍然接受更新事件
BTNI_DISABLE_UPDATE         EQU     0001h
BTNI_DISABLE_HOVER          EQU     0002h
BTNI_DISABLE_CLICK          EQU     0004h
BTNI_DISABLE_PAINT          EQU     0008h
BTNI_RUNNING     EQU     0000h

MAXBTNCNT        EQU     7000   ; 最大的按钮数量； Note：没有溢出保护


BUTTONDATA struct
    right           DWORD   ?
    top             DWORD   ?
    left            DWORD   ?
    bottom          DWORD   ?
    depth           DWORD   ?
    isActive        WORD    ?
    status          WORD    ?
    pPaint          DWORD   ?
    aParam          DWORD   ? ; use for restore some data
    bParam          DWORD   ? ; use for restore some data
    cParam          REAL4   ?
    pClickEvent     DWORD   ?
    pHoverEvent     DWORD   ?
    pUpdateEvent    DWORD   ?
BUTTONDATA ends


; 创建按钮。需要指定按钮的矩形区域、绘图函数、处理按下、滑过的函数和每帧处理的函数。如函数指针为NULL（0），会设置为默认的处理函数
RegisterButton          PROTO    pRect: ptr RECT, pPaint:DWORD, pClickEvent:DWORD, pHoverEvent:DWORD, pUpdateEvent:DWORD


PaintButton             PROTO    hDc:DWORD, pButton: ptr BUTTONDATA
PaintAllButton          PROTO    hDc:DWORD                                  ; 绘制所有按钮
GetButtonRect           PROTO    pButton: ptr BUTTONDATA, pRect: ptr RECT   ; 获取按钮的矩形区域。填充到pRect中
DeleteButton            PROTO    pButton: ptr BUTTONDATA                    ; 删除按钮

MoveButton              PROTO    pButton: ptr BUTTONDATA, detx:DWORD, dety:DWORD; 移动按钮
MoveButtonTo            PROTO    pButton: ptr BUTTONDATA, x:DWORD, y:DWORD  ; 移动按钮到指定位置
MoveButtonCenterTo      PROTO    pButton: ptr BUTTONDATA, x:DWORD, y:DWORD
SetButtonSize           PROTO    pButton: ptr BUTTONDATA, w:DWORD, h:DWORD  ; 设置按钮大小，以左上角为基准调整
GetButtonSize           PROTO    pButton: ptr BUTTONDATA, pPoint: ptr D_POINT; 获取按钮的宽高

SendClickInfo           PROTO    x:DWORD, y:DWORD                           ; 发送鼠标点击消息，会自动检测是否在按钮区域，触发按钮的PressEvent
SendHoverInfo           PROTO    x:DWORD, y:DWORD                           ; 发送鼠标滑过消息，会自动检测是否在按钮区域，触发按钮的HoverEvent
SendUpdateInfo          PROTO    cnt:DWORD                                  ; 发送更新消息，触发所有按钮格子的UpdateEvent
ClearClick              PROTO                                               ; 清除所有按钮的按下状态。请在LBUTTONUP消息处理中加入这个函数 
SortButtons             PROTO
SetButtonDepth          PROTO    pButton: ptr BUTTONDATA, depth:DWORD       ; 设置按钮的深度。深度越小越上层
GetButtonDepth          PROTO    pButton: ptr BUTTONDATA                    ; 获取按钮的深度

BindButtonToBitmap      PROTO    pButton:ptr BUTTONDATA, BitmapID:DWORD
