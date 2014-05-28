BIN_DIR = ../mips-gcc-4.7.2/mips-elf/bin/
CFLAGS = -std=gnu99 -O0
FLAGS = -mips1 -G0
LDFLAGS = -Ttext 0x80400000
OBJCOPY_FLAGS = --change-addresses -0xffffffff80000000

SOURCES = $(shell find . -name "*.c")
OBJS = $(SOURCES:.c=.o)
TARGET = main

$(TARGET).hex: $(TARGET).out
	$(BIN_DIR)/objcopy $(OBJCOPY_FLAGS) -j .text -j .data -O ihex $< $@

%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $(CFLAGS) $< -c -o $@
	

$(TARGET).out: $(OBJS)
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $^ -o $@


clean:
	rm -rf *.bin *.out *.o *.hex

dump: $(TARGET).out
	$(BIN_DIR)/objdump -D $<

.PHONY: clean dump

