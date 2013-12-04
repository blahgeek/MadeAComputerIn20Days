
BIN_DIR=/Users/BlahGeek/Desktop/mips-gcc-4.7.2/mips-elf/bin/
FLAGS=-mips32

all: kernel.bin kernel-int.bin
	

kernel.bin: kernel.s
	@$(BIN_DIR)/as $(FLAGS) $< -o kernel.o
	@$(BIN_DIR)/ld $(FLAGS) -Ttext 0x80000000 kernel.o -o kernel.out
	@$(BIN_DIR)/objcopy -O binary kernel.out $@

kernel-int.bin: kernel-int.s
	@$(BIN_DIR)/as $(FLAGS) $< -o kernel-int.o
	@$(BIN_DIR)/ld $(FLAGS) -Ttext 0x80008000 kernel-int.o -o kernel-int.out
	@$(BIN_DIR)/objcopy -O binary kernel-int.out $@
