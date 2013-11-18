SOURCES = FetcherAndRegisterTestbench.vhdl FetcherAndRegister.vhdl
TARGET = FetcherAndRegisterTestbench

VCDFILE = out.vcd

all: analyze
	@ghdl -e $(TARGET)
	@ghdl -r $(TARGET) --vcd=$(VCDFILE)
	@echo "Output file:" $(VCDFILE)

analyze:
	@ghdl -a $(SOURCES)
	@echo Analyze done.

clean:
	@rm $(VCDFILE) work-obj93.cf
	@echo Cleaned.