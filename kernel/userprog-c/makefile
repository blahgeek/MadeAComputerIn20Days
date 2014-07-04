ASMSOURCE = $(shell find . -name "*.c")
TARGETS = $(ASMSOURCE:.c=.hex)

all: $(TARGETS)

include ../userprog.makefile


%.out: %.o
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $< -o $@


%.o: %.c
	$(BIN_DIR)/gcc $(FLAGS) $(CFLAGS) $< -c -o $@



.PHONY: all

