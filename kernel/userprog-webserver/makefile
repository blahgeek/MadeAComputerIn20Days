SOURCES = $(shell find . -name "*.c")
OBJS = $(SOURCES:.c=.o)
TARGET = main


all: $(TARGET).hex


include ../userprog.makefile


%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $(CFLAGS) $< -c -o $@
	

$(TARGET).out: $(OBJS)
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $^ -o $@


dump: $(TARGET).out
	$(BIN_DIR)/objdump -D $<


.PHONY: all dump

