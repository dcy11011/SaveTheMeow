ASM = main.asm util.asm paint.asm button.asm enemy.asm collision.asm mapblock.asm projectile.asm prefab.asm statusbar.asm
OBJ = main.obj util.obj paint.obj button.obj enemy.obj collision.obj mapblock.obj projectile.obj prefab.obj statusbar.obj
RCM = rclist.rcm 
RCINC = rclist.inc
RC  = rclist.rc
RES = rclist.res
EXE = StartGame.exe

EX_LIB = kernel32.lib gdi32.lib user32.lib msvcrt.lib msimg32.lib

ML = $(MASM)\bin\ml.exe
LINK = $(MASM)\bin\link.exe
RC_E = $(MASM)\bin\rc.exe

LINK_FLAG = /subsystem:console /LIBPATH:$(IRVINE) /LIBPATH:$(MASM)\lib
ML_FLAG = /c /coff /I$(MASM)/include /Zi


$(EXE): $(OBJ) $(RES)
	$(LINK) $(LINK_FLAG) $(OBJ) $(RES) $(EX_LIB) /out:$(EXE)
	del $(OBJ)
	del $(RES)
	@echo [SUCCESS]

$(OBJ): $(ASM) $(RCINC)
	$(ML) $(ML_FLAG) $(ASM) 

$(RC) $(RCINC): $(RCM)
	rcmake.exe $(RCM)

$(RES): $(RC)
	$(RC_E) $(RC)
	del $(RC)


clean:
	del $(EXE)
	del $(RCINC)