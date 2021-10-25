.386
.model flat,stdcall
option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Defines
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

TIMER_TICK      EQU     1
TICK_INTERVAL   EQU     35

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include ds.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

include util.inc
include paint.inc
include rclist.inc
include testobj.inc
Include button.inc            
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Data
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data
testObj         OBJDATA  <100,100,20>
cnt             dd  0

.data?
hInstance       dd  ?
hWinMain        dd  ?
pButton1        dd  ?


.const
    szClassName     db      'MyClass', 0
    szCaptionMain   db      'Window Caption', 0
    szText          db      'Win32 Assembly Test Text', 0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    _ProcWinMain    proc    uses ebx edi esi hWnd, uMsg, wParam, lParam
            local   @stPs:PAINTSTRUCT
            local   @stRect:RECT
            local   @hDc, @hMemDc, @tPen
            local   @hBitmap: HBITMAP

            mov eax, uMsg

            .IF eax ==  WM_PAINT
                invoke  BeginPaint, hWnd,addr @stPs
                mov     @hDc, eax
                invoke  CreateCompatibleDC, @hDc
                mov     @hMemDc, eax
                invoke  GetClientRect, hWnd, addr @stRect
                invoke  CreateCompatibleBitmap, @hDc, @stRect.right, @stRect.bottom
                mov     @hBitmap, eax
                invoke  SelectObject, @hMemDc, @hBitmap

                invoke  CreatePen, PS_SOLID, 5, 00000000h
                mov     @tPen, eax
                invoke  SelectObject, @hMemDc, eax

                invoke  PaintBitmapEx, hInstance, @hMemDc, MAIN_BACKGROUND,\
                        addr @stRect, STRETCH_XY or CENTER_XY
                invoke  PaintBitmapEx, hInstance, @hMemDc, BOTTON_START,\
                        addr @stRect, CENTER_XY 
                invoke  DrawText, @hMemDc, addr szText, -1, addr @stRect, \
                        DT_SINGLELINE or DT_CENTER or DT_VCENTER
                invoke  PaintObj, @hMemDc, addr testObj

                invoke  PaintAllButton, @hMemDc
                
                invoke  BitBlt, @hDc, 0, 0, @stRect.right, @stRect.bottom, \
                        @hMemDc, 0, 0, SRCCOPY
                
                invoke  DeleteDC, @hMemDc
                invoke  DeleteObject, @hBitmap
                invoke  DeleteObject, @tPen 
                invoke  EndPaint, hWnd, addr @stPs
            .ELSEIF eax == WM_TIMER
                .IF     wParam == TIMER_TICK
                        mov     eax, cnt
                        inc     eax
                        mov     cnt, eax
                        invoke  SendUpdateInfo, cnt
                        invoke  GetClientRect, hWnd, addr @stRect
                        invoke  MoveObj, offset testObj, addr @stRect
                        invoke  InvalidateRect, hWnd, addr @stRect, 0
                .ENDIF
            .ELSEIF eax == WM_MOUSEMOVE
                mov     eax, lParam
                mov     ebx, eax
                and     ebx, 0000FFFFh
                shr     eax, 16
                invoke  SendHoverInfo, ebx, eax
                invoke DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
            .ELSEIF eax == WM_LBUTTONDOWN
                mov     eax, lParam
                mov     ebx, eax
                and     ebx, 0000FFFFh
                shr     eax, 16
                invoke  SendClickInfo, ebx, eax
            .ELSEIF eax == WM_LBUTTONUP
                invoke  ClearClick
            .ELSEIF eax == WM_CLOSE
                invoke  DestroyWindow, hWinMain
                invoke  PostQuitMessage, NULL
                invoke  KillTimer, hInstance, TIMER_TICK
            .ELSEIF eax == WM_CREATE
                invoke  SetTimer, hWnd, TIMER_TICK, TICK_INTERVAL, NULL   
                mov     eax, 100
                mov     @stRect.left, eax
                mov     @stRect.top,  eax
                mov     eax, 120
                mov     @stRect.right, eax
                mov     @stRect.bottom,eax
                invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
                mov     pButton1, eax
                mov     eax, 200
                mov     @stRect.left, eax
                mov     @stRect.top,  eax
                mov     eax, 220
                mov     @stRect.right, eax
                mov     @stRect.bottom,eax
                invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
                mov     pButton1, eax
                mov     eax, 300
                mov     @stRect.left, eax
                mov     @stRect.top,  eax
                mov     eax, 320
                mov     @stRect.right, eax
                mov     @stRect.bottom,eax
                invoke  RegisterButton, addr @stRect, 0, 0, 0, 0
            .ELSE
                invoke DefWindowProc, hWnd, uMsg, wParam, lParam
                ret
            .ENDIF
            xor eax, eax
            ret
    _ProcWinMain endp
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
                    100, 100, 600, 400, \
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
    _WinMain    endp
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    start:
            call _WinMain
            invoke ExitProcess, NULL
    ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    end start


