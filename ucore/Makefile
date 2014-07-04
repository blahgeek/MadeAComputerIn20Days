TARGET = ucore

GCCPREFIX = mips-elf-

GDB		:= $(GCCPREFIX)gdb

CC 		:=$(GCCPREFIX)gcc
CFLAGS	= -std=gnu99 -fno-builtin -nostdlib -nostdinc
CFLAGS += -g -G0 -Wall -O0 -mips32

LD      := $(GCCPREFIX)ld
AS      := $(GCCPREFIX)as -g -mips32
AR      := $(GCCPREFIX)ar
LDFLAGS	= -nostdlib -n -G0 -static 

OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

OBJDIR	= build/obj
BINDIR	= build/bin
DEPDIR  = build/dep
SRCDIR  = kern libs

SRC = $(shell find $(SRCDIR) -name "*.c")
OBJS = $(patsubst %.c,$(OBJDIR)/%.o,$(SRC))
ASMSRC = $(shell find $(SRCDIR) -name "*.S")
OBJS += $(patsubst %.S,$(OBJDIR)/%.o,$(ASMSRC))

INCLUDES = -Ilibs -Ikern/debug -Ikern/driver -Ikern/trap -Ikern/mm

DEPS = $(patsubst %.c,$(DEPDIR)/%.d,$(SRC))


all: $(TARGET).out


$(OBJDIR)/%.o: %.c
	@echo CC $<
	@mkdir -pv $(dir $@)
	@$(CC) -c $(INCLUDES) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.S
	@echo AS $<
	@mkdir -pv $(dir $@)
	@$(CC) $(CFLAGS) -c -D__ASSEMBLY__ $(INCLUDES) $< -o $@

$(DEPDIR)/%.d: %.c
	@echo DEP $<
	@mkdir -pv $(dir $@)
	@$(CC) $(INCLUDES) -MM -MT $(CFLAGS) $< > $@; 


sinclude $(DEPS)


$(TARGET).out: $(OBJS) tools/kernel.ld
	@echo LINK $@
	$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(OBJS)


.PHONU: all
