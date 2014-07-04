ASMSOURCE = $(shell find . -name "*.s")
TARGETS = $(ASMSOURCE:.s=.hex)

all: $(TARGETS)

include ../userprog.makefile

%.o: %.s
	$(BIN_DIR)/as $(FLAGS) $< -o $@
	

%.out: %.o
	$(BIN_DIR)/ld $(FLAGS) $(LDFLAGS) $< -o $@


.PHONY: all
