# https://stackoverflow.com/a/30142139


# basename for binary
BASEFN = celeste
# Final binary
BIN = $(BASEFN).nex
# Put all auto generated stuff to this build dir.
BLDIR = ./build
# Path to CSPECT emulator
CSPECT = $(HOME)/z88dk/cspect/CSpect.exe

CXX = clang++
CXX_FLAGS = -Wfatal-errors -Wall -Wextra -Wpedantic -Wconversion -Wshadow


USE_SDCC := 1

# compile options
ifeq ($(USE_SDCC), 1)
	C_OPTS := +zxn -O3 -compiler=sdcc -clib=sdcc_iy --list
else
	C_OPTS := +zxn -O3 -clib=new --list
endif

# link options
ifeq ($(USE_SDCC), 1)
	L_OPTS := +zxn -subtype=nex -v -O3 -m -s -clib=sdcc_iy -startup=31 -create-app -pragma-include:zpragma.inc
else
	L_OPTS := +zxn -subtype=nex -v -O3 -m -s -clib=new -startup=31 -create-app -pragma-include:zpragma.inc
endif

# List of all .c source files.
C_SRCS := $(wildcard *.c)
# List of all .cpp source files.
ASM_SRCS := $(wildcard *.asm)

# All .c.o files go to build dir.
C_OBJS := $(C_SRCS:%.c=$(BLDIR)/%.c.o)
# All .c.o files go to build dir.
ASM_OBJS := $(ASM_SRCS:%.asm=$(BLDIR)/%.asm.o)

# Build target for every single object file.
$(BLDIR)/%.c.o : %.c
	zcc $(C_OPTS) -c $< -o $@

$(BLDIR)/%.asm.o : %.asm
	zcc $(C_OPTS) -c $< -o $@

# Actual target of the binary - depends on all .o files.
$(BLDIR)/$(BIN) : $(C_OBJS) $(ASM_OBJS)
	zcc $(L_OPTS) $(C_OBJS) $(ASM_OBJS) -o $(BLDIR)/$(BASEFN)

all : $(BLDIR)/$(BIN)
	@du -b $(BLDIR)/*.bin $(BLDIR)/*.nex

re : clean all

run : all
	$(CSPECT) -w3 -vsync -zxnext -mmc=./assets/ $(BLDIR)/$(BIN)

rerun : clean run

.PHONY : clean
clean :
#	rm -f $(BLDIR)/$(BIN) $(BLDIR)/$(BASEFN).* $(C_OBJS) $(ASM_OBJS)
	rm -f $(BLDIR)/*.o $(BLDIR)/$(BASEFN)*

cleanasm :
	rm -f $(BLDIR)/*.asm.o

cleanres :
	rm -f $(BLDIR)/palette_data.asm.o $(BLDIR)/sprite_defs.asm.o
	rm -f $(BLDIR)/tilemap_manager.asm.o $(BLDIR)/tileset.asm.o

