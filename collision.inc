
CalcDist        PROTO   x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4
CalcDisti       PROTO   x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
CircleCollision PROTO   x1:REAL4, y1:REAL4, r1:REAL4, x2:REAL4, y2:REAL4, r2:REAL4

GetAtan2        PROTO   x:REAL4, y:REAL4
DirectionTo     PROTO   x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4
GetDirVector    PROTO   dir:REAL4, len:REAL4           ; returns (x, y) -> eax, edx

Lerp            PROTO   x1:REAL4, x2:REAL4, a:REAL4
LerpAngle       PROTO   x1:REAL4, x2:REAL4, a:REAL4
LerpXY          PROTO   x1:REAL4, y1:REAL4, x2:REAL4, y2:REAL4, a:REAL4 ; -> eax, edx

GetCenterButton PROTO   btn: DWORD                  ; return (x, y) -> eax, edx
GetRadiusButton PROTO   btn: DWORD                 