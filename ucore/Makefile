TARGET = ucore

GCCPREFIX = mips-elf-

FOR_QEMU := y
V := @

GDB		:= $(GCCPREFIX)gdb

CC 		:=$(GCCPREFIX)gcc
CFLAGS	= -std=gnu99 -fno-builtin -nostdlib -nostdinc
CFLAGS += -g -G0 -Wall -O0 -mips32

ifeq ($(FOR_QEMU), y)
CFLAGS += -D__QEMU
endif

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
	$(V)mkdir -pv $(dir $@)
	$(V)$(CC) -c $(INCLUDES) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.S
	@echo AS $<
	$(V)mkdir -pv $(dir $@)
	$(V)$(CC) $(CFLAGS) -c -D__ASSEMBLY__ $(INCLUDES) $< -o $@

$(DEPDIR)/%.d: %.c
	@echo DEP $<
	$(V)mkdir -pv $(dir $@)
	$(V)$(CC) $(INCLUDES) $(CFLAGS) -MM -MT "$(OBJDIR)/$(<:.c=.o) $(DEPDIR)/$(<:.c=.d)" $< > $@


sinclude $(DEPS)


$(TARGET).out: $(OBJS) tools/kernel.ld
	@echo LINK $@
	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(OBJS)


clean:
	rm -rf build $(TARGET).out


.PHONU: all clean
