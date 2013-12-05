
BIN_DIR = ../mips-gcc-4.7.2/mips-elf/bin/
FLAGS = -mips32
LDFLAGS = -Ttext 0x80400000

ASMSOURCE = $(shell find . -name "*.c")
TARGETS = $(ASMSOURCE:.c=.bin)

all: $(TARGETS)


%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $< -c -o $@
	

%.out: %.o
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $< -o $@


%.bin: %.out
	$(BIN_DIR)/objcopy -O binary $< $@


clean:
	rm -rf *.o *.out