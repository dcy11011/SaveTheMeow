.386
.model flat, stdcall
option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Defines
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

TIMER_TICK      EQU     1
TICK_INTERVAL   EQU     16

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include in project
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

include util.inc
include paint.inc
include rclist.inc
Include button.inc            
include enemy.inc
include projectile.inc
include mapblock.inc
include statusbar.inc

include prefab.inc

include main.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Data
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data
cnt             dd  0
hDc             DWORD 0
hMemDc          DWORD 0
hBitmap         DWORD 0

.data?
tmp             QWORD  ?
hInstance       DWORD  ?
hWinMain        DWORD  ?
pButton1        DWORD  ?
pEnemy1         DWORD  ?
pProjt1         DWORD  ?


.const
    szClassName     db      'MyClass', 0
    szCaptionMain   db      'Window Caption', 0
    szText          db      'Win32 Assembly Test Text', 0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    _SetupDevice    proc    uses ebx edi esi hWnd
            local   @stRect:RECT
            .IF hMemDc != 0
                invoke  DeleteDC, hMemDc
            .ENDIF
            .IF hBitmap != 0
                invoke  DeleteObject, hBitmap
            .ENDIF
            ;
            invoke  CreateCompatibleDC, hDc
            mov     hMemDc, eax
            invoke  GetClientRect, hWnd, addr @stRect
            invoke  CreateCompatibleBitmap, hDc, @stRect.right, @stRect.bottom
            mov     hBitmap, eax
            mov     eax, @stRect.right
            mov     stageWidth, eax
            mov     eax, @stRect.bottom
            mov     stageHeight, eax
            ret
    _SetupDevice    endp 
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    _DoPaint        proc    uses ebx edi esi hWnd
            local   @stPs:PAINTSTRUCT
            local   @stRect:RECT
            local   @tPen

            invoke  GetClientRect, hWnd, addr @stRect
            invoke  SelectObject, hMemDc, hBitmap

            invoke  CreatePen, PS_SOLID, 5, 00000000h
            mov     @tPen, eax

            invoke  SelectObject, hMemDc, eax

            invoke  PaintBitmapEx, hMemDc, MAIN_BACKGROUND,\
                    addr @stRect, STRETCH_XY or CENTER_XY
            
            invoke  DrawText, hMemDc, addr szText, -1, addr @stRect, \
                    DT_SINGLELINE or DT_CENTER or DT_VCENTER
            invoke  PaintAllButton, hMemDc

            invoke  BitBlt, hDc, 0, 0, @stRect.right, @stRect.bottom, \
                    hMemDc, 0, 0, SRCCOPY
            
            invoke  DeleteObject, @tPen 
            invoke  ValidateRect, hWnd, 0
            ret
    _DoPaint        endp
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    _ProcWinMain    proc    uses ebx edi esi hWnd, uMsg, wParam, lParam
            local   @stPs:PAINTSTRUCT
            local   @stRect:RECT

            mov eax, uMsg
            .IF eax ==  WM_PAINT
                invoke  _DoPaint, hWnd
            .ELSEIF eax == WM_ERASEBKGND
            .ELSEIF eax == WM_SIZE
                invoke  _SetupDevice, hWnd
            .ELSEIF eax == WM_TIMER
                .IF     wParam == TIMER_TICK
                        invoke  SortButtons
                        mov     eax, cnt
                        inc     eax
                        mov     cnt, eax
                        
                        invoke  SendUpdateInfo, cnt
                        mov     eax, health
                        and     eax, eax
                        jng     @f
                        invoke  WaveStepForward
                        invoke  ProjtUpdateAll, cnt
                        invoke  EnemyUpdateAll, cnt
                        @@:
                        invoke  GetClientRect, hWnd, addr @stRect
                        
                        invoke  InvalidateRect, hWnd, addr @stRect, 0
                        invoke  SortButtons ; IMPORTANT!
                .ENDIF
            .ELSEIF eax == WM_MOUSEMOVE
                mov     eax, lParam
                mov     ebx, eax
                and     ebx, 0000FFFFh
                shr     eax, 16
                push    eax ; save eax
                invoke  SendHoverInfo, ebx, eax
                pop     eax ; save eax
                invoke  UpdateMousePos, ebx, eax
                ; ------- test enemy
                ; invoke  PrefabTestEnemy, 200, 200
                ; invoke  PrefabHurtEffectProj, 200, 200
                ; invoke  PrefabTestProjectile, 200, 200
                invoke  SortButtons ; IMPORTANT!
                ; ------------------
                invoke DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
            .ELSEIF eax == WM_LBUTTONDOWN
                mov     eax, lParam
                mov     ebx, eax
                and     ebx, 0000FFFFh
                shr     eax, 16
                pushad
                invoke  SendClickInfo, ebx, eax
                popad
                ; ------- test pop
                ; invoke  PopNoCoin
                ; ------- test enemy
                invoke  PrefabEnemy3, 1000
                ; invoke  PrefabHurtEffectProj, 200, 200
                ; invoke  PrefabTestProjectile, 200, 200
                invoke  SortButtons ; IMPORTANT!
                ; ------------------
            .ELSEIF eax == WM_LBUTTONUP
                invoke  ClearClick
            .ELSEIF eax == WM_CLOSE
                invoke  DestroyWindow, hWinMain
                invoke  PostQuitMessage, NULL
                invoke  KillTimer, hInstance, TIMER_TICK
                invoke  DeleteDC, hMemDc
                invoke  DeleteObject, hBitmap
                invoke  ReleaseAllBitmap ; IMPORTANT!
            .ELSEIF eax == WM_CREATE
    
                invoke  GetDC, hWnd
                mov     hDc, eax
                invoke  _SetupDevice, hWnd

                invoke  LoadAllBitmap ; IMPORTANT!

                invoke  SetTimer, hWnd, TIMER_TICK, TICK_INTERVAL, NULL   

                invoke  WaveReset
                invoke  WaveStart, 0, 3
                invoke  LoadMapFromFile, 50, 90

                invoke  GetClientRect, hWnd, addr @stRect
                invoke  RegisterStatusBar, addr @stRect

                invoke  RegisterTopPainter

                invoke  SortButtons
            .ELSE
                invoke DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
            .ENDIF
            xor eax, eax
            ret
    _ProcWinMain ENDP
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    _WinMain        proc
            ;*******************************************
            ; Create window
            local   @stWndClass:WNDCLASSEX
            local   @stMsg:MSG

            invoke  GetModuleHandle, NULL
            mov     hInstance, eax
            invoke  RtlZeroMemory, addr @stWndClass, sizeof @stWndClass

            invoke  LoadCursor, 0, IDC_ARROW
            mov     @stWndClass.hCursor, eax
            push    hInstance
            invoke  LoadIcon, hInstance, MAIN_ICON
	        mov     @stWndClass.hIcon, eax
            pop     @stWndClass.hInstance
            mov     @stWndClass.cbSize, sizeof WNDCLASSEX
            mov     @stWndClass.style, CS_HREDRAW or CS_VREDRAW
            mov     @stWndClass.lpfnWndProc, offset _ProcWinMain
            mov     @stWndClass.hbrBackground, COLOR_WINDOW +1
            mov     @stWndClass.lpszClassName, offset szClassName
            invoke  RegisterClassEx, addr @stWndClass

            invoke  CreateWindowEx, WS_EX_CLIENTEDGE, offset szClassName, \
                    offset szCaptionMain, WS_OVERLAPPEDWINDOW, \
                    100, 100, 870, 690, \
                    NULL, NULL, hInstance, NULL
            mov     hWinMain, eax
            invoke  ShowWindow, hWinMain, SW_SHOWNORMAL
            invoke  UpdateWindow, hWinMain
            ;*********************************************
            ; Message Loop
            .WHILE TRUE
                invoke  GetMessage, addr @stMsg, NULL, 0,0
                .break .if eax == 0
                invoke  TranslateMessage, addr @stMsg
                invoke  DispatchMessage, addr @stMsg
            .ENDW
            ret
    _WinMain    ENDP
    QuitCallback PROC pButton: DWORD
        invoke  DestroyWindow, hWinMain
        invoke  PostQuitMessage, NULL
        invoke  KillTimer, hInstance, TIMER_TICK
        invoke  DeleteDC, hMemDc
        invoke  DeleteObject, hBitmap
        invoke  ReleaseAllBitmap ; IMPORTANT!
        ret
    QuitCallback ENDP
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    start:
            call _WinMain
            invoke ExitProcess, NULL
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    end start


