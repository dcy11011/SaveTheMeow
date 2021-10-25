.386
.model flat, stdcall

include testobj.inc
option casemap:none

include windows.inc
include gdi32.inc
include kernel32.inc
include user32.inc

include util.inc
include paint.inc


.code

    PaintObj    proc    uses ebx edi esi hDc:dword, lpObj: ptr OBJDATA
        mov     eax, lpObj
        assume  eax: ptr OBJDATA
        invoke  PaintCircleCR, hDc, [eax].posX, [eax].posY, [eax].r
        ret
    PaintObj    endp

    SetObjData proc uses ebx edi lpObj: ptr OBJDATA, posX:DWORD, posY:DWORD
        mov     edi, lpObj
        assume  edi: ptr OBJDATA
        mov     ebx, posX
        mov     [edi].posX, ebx
        mov     ebx, posY
        mov     [edi].posY, ebx
        ret 
    SetObjData endp

    SetObjRadius proc uses ebx edi lpObj:ptr OBJDATA, r:DWORD
        mov     edi, lpObj
        assume  edi: ptr OBJDATA
        mov     ebx, r
        mov     [edi].r, ebx
        ret     
    SetObjRadius endp

    MoveObj     proc uses edi ebx ecx lpObj: ptr OBJDATA, lpRect: ptr RECT
        local   @stRect:RECT

        invoke  GetCircleRect, lpObj, addr @stRect
        mov     edi, lpObj
        assume  edi: ptr OBJDATA
        mov     ebx, lpRect
        assume  ebx: ptr RECT


        assume  ecx:SDWORD        
        mov     ecx, @stRect.top
        .IF     ecx < [ebx].top
            mov ecx, 2
            mov [edi].velY,ecx
        .ENDIF
        mov     ecx, @stRect.bottom
        .IF     ecx > [ebx].bottom
            mov ecx, -2
            mov [edi].velY, ecx
        .ENDIF
        mov     ecx, @stRect.left
        .IF     ecx  < [ebx].left
            mov ecx, 2
            mov [edi].velX, ecx
        .ENDIF
        mov     ecx, @stRect.right
        .IF     ecx  > [ebx].right 
            mov ecx, -2
            mov [edi].velX, ecx
        .ENDIF

        mov     ebx, [edi].posX
        add     ebx, [edi].velX
        mov     [edi].posX, ebx
        mov     ebx, [edi].posY
        add     ebx, [edi].velY
        mov     [edi].posY, ebx
        
        xor     edi, edi
        ret
    MoveObj endp
end

