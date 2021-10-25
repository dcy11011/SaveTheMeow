ASM = main.asm util.asm paint.asm testobj.asm button.asm
OBJ = main.obj util.obj paint.obj testobj.obj button.obj
RCM = rclist.rcm 
RCINC = rclist.inc
RC  = rclist.rc
RES = rclist.res
EXE = app.exe

EX_LIB = kernel32.lib gdi32.lib user32.lib msvcrt.lib

LINK_FLAG = /subsystem:console
ML_FLAG = /c /coff

$(EXE):$(OBJ) $(RES)
	link $(LINK_FLAG) $(OBJ) $(RES) $(EX_LIB) /out:$(EXE)
	del $(OBJ)
	del $(RES)
	@echo [SUCCESS]
$(OBJ):$(ASM) $(RCINC)
	ml $(ML_FLAG) $(ASM) 
$(RC) $(RCINC):$(RCM)
	rcmake.exe $(RCM)
$(RES):$(RC)
	rc $(RC)
	del $(RC)


clean:
	del $(EXE)
	del $(RCINC)