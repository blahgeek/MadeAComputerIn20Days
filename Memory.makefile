# Makefile automatically generated by ghdl
# Version: GHDL 0.29 (20100109) [Sokcho edition] - mcode code generator
# Command used to generate this makefile:
# ghdl --gen-makefile MemoryTestbench

GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS= --vcd=Memory.vcd

# Default target : elaborate
all : elab

# Elaborate target.  Almost useless
elab : force
	$(GHDL) -c $(GHDLFLAGS) -e memorytestbench

# Run target
run : force
	$(GHDL) -c $(GHDLFLAGS) -r memorytestbench $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: force
	# /usr/local/ghdl/translate/lib//v93/ieee/../../../../libraries/ieee/std_logic_1164.v93
	# /usr/local/ghdl/translate/lib//v93/ieee/../../../../libraries/ieee/std_logic_1164_body.v93
	# /usr/local/ghdl/translate/lib//v93/ieee/../../../../libraries/ieee/numeric_std.v93
	# /usr/local/ghdl/translate/lib//v93/ieee/../../../../libraries/ieee/numeric_std-body.v93
	$(GHDL) -a $(GHDLFLAGS) MemoryTestbench.vhdl
	$(GHDL) -a $(GHDLFLAGS) Memory.vhdl
	$(GHDL) -a $(GHDLFLAGS) DigitalNumber.vhdl

force:
