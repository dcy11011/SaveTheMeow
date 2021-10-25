ASM = test.asm
OBJ = test.obj
EXE = app.exe

EX_LIB = Irvine32.lib user32.lib kernel32.lib msvcrt.lib

LINK_FLAG = /subsystem:console
ML_FLAG = /c /coff

$(EXE):$(OBJ)
	link $(LINK_FLAG) $(OBJ) $(EX_LIB)
$(OBJ):$(ASM)
	ml $(ML_FLAG) $(ASM)

clean:
	del $(EXE)