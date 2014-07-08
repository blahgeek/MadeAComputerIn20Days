SOURCES = $(shell find . -name "*.c")
OBJS = $(SOURCES:.c=.o)
TARGET = bios

BIN_DIR = ../mips-gcc-4.7.2/mips-elf/bin/
CFLAGS = -std=gnu99 -O2 -fno-builtin
FLAGS = -mips1 -G0
LDFLAGS = -Ttext 0xBFC00000
COPY_SECS = -j .text -j .data -j .bss -j .rodata 


all: $(TARGET).mif


%.mif: %.bin
	python2 convert.py $< $@
	cp $@ ../$@


%.bin: %.out
	$(BIN_DIR)/objcopy $(COPY_SECS) -O binary $< $@


clean:
	rm -rf *.bin *.out *.o *.mif


.PHONY: clean


%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $(CFLAGS) $< -c -o $@
	

$(TARGET).out: $(OBJS)
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $^ -o $@


dump: $(TARGET).out
	$(BIN_DIR)/objdump -D $<


.PHONY: all dump

