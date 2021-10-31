
RegisterStatusBar   PROTO   pClientRect:ptr RECT
AddHealth           PROTO   val:DWORD
DecHealth           PROTO   val:DWORD
AddCoin             PROTO   val:DWORD
GetCoin             PROTO

PopAddCoin          PROTO  valCoin:DWORD, posX:DWORD, posY:DWORD
PopAddCoinf         PROTO  valCoin:DWORD, posX:REAL4, posY:REAL4

PopNoCoin           PROTO
PopWave             PROTO  waveNumber:DWORD

EXTERNDEF           health:DWORD
