BIN_DIR = ../../mips-gcc-4.7.2/mips-elf/bin/
CFLAGS = -std=gnu99 -O0 -fno-builtin
FLAGS = -mips1 -G0
LDFLAGS = -Ttext 0x80400000
OBJCOPY_FLAGS = --change-addresses -0xffffffff80000000
COPY_SECS = -j .text -j .data -j .bss -j .rodata 


%.hex: %.out
	$(BIN_DIR)/objcopy $(OBJCOPY_FLAGS) $(COPY_SECS) -O ihex $< $@


clean:
	rm -rf *.bin *.out *.o *.hex


.PHONY: clean
