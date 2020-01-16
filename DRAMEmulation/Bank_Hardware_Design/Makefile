## Makefile to generate Bank_Hardware Vivado project
# requires vivado (might fail if a version other than 2018.3.1 is used)

# for Pynq-Z1 board
TARGET=xc7z020clg400-1

# for UltraZed-EG board (requires ES1)
#TARGET=xczu3eg-sfva625-1-i-es1

#
Bank_Hardware:
	vivado -mode batch -source Bank_Hardware.tcl
	@echo Finished Bank_Hardware 
# $(TARGET)
#@echo Finished for $(TARGET)

.PHONY: clean
clean:
	rm -rf Bank_Hardware