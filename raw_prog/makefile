BIN_DIR = ../mips-gcc-4.7.2/mips-elf/bin/
CFLAGS = -std=c99
FLAGS = -mips1
LDFLAGS = -Ttext 0x80000000

ASMSOURCE = $(shell find . -name "*.c")
TARGETS = $(ASMSOURCE:.c=.bin)

all: $(TARGETS)


%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $(CFLAGS) $< -c -o $@
	

%.out: %.o
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $< -o $@


%.bin: %.out
	$(BIN_DIR)/objcopy -O binary $< $@


clean:
	rm -rf *.bin

.PHONY: clean all

