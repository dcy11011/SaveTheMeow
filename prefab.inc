

; Prefab factory 
PrefabTestProjectile    PROTO   x:DWORD, y:DWORD
PrefabTestEnemy         PROTO   x:DWORD, y:DWORD
PrefabHurtEffectProj    PROTO   x:DWORD, y:DWORD
PrefabHurtEffectProjf   PROTO   x:REAL4, y:REAL4
PrefabDeathEffectProj   PROTO   x:DWORD, y:DWORD
PrefabDeathEffectProjf  PROTO   x:REAL4, y:REAL4
PrefabReachEffectProj   PROTO   x:DWORD, y:DWORD  ; 到达终点的特效
PrefabReachEffectProjf  PROTO   x:REAL4, y:REAL4  ; 到达终点的特效
PrefabReplayBtn         PROTO   x:DWORD, y:DWORD

PrefabProjA             PROTO   x:DWORD, y:DWORD, dir:REAL4
PrefabProjB             PROTO   x:DWORD, y:DWORD, dir:REAL4
PrefabProjC             PROTO   x:DWORD, y:DWORD, dir:REAL4
PrefabProjD             PROTO   pMapBlock:DWORD, pEnemy:DWORD
PrefabEnemy1            PROTO   lvl:DWORD
PrefabEnemy2            PROTO   lvl:DWORD
PrefabEnemy3            PROTO   lvl:DWORD
PrefabEnemy4            PROTO   lvl:DWORD