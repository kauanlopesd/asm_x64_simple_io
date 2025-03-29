ASM = nasm
ASM_FLAGS = -felf64
SOURCES = lib.asm
OBJECTS = lib.o

LINKER = ld
LINKER_FLAGS =
TARGET = lib

all: link
clean:
	rm -f $(TARGET) *.o
link: build
	$(LINKER) $(LINKER_FLAGS) $(OBJECTS) -o $(TARGET)
build:
	$(ASM) $(ASM_FLAGS) -o $(OBJECTS) $(SOURCES)