## Makefile to generate Bank_Hardware Vivado project
# requires vivado (might fail if a version other than 2018.3.1 is used)

# for Pynq-Z1 board
#TARGET=xc7z020clg400-1

# for UltraZed-EG board (requires ES1)
TARGET=xczu3eg-sfva625-1-i-es1

#
UZEG_Bank_Hardware:
	@echo Starting Bank_Hardware for $(TARGET)
	vivado -mode batch -source UZEG_Bank_Hardware.tcl
	@echo Finished Bank_Hardware for $(TARGET)

.PHONY: clean
clean:
	rm -rf Bank_Hardware
	rm -rf UZEG_Bank_Hardware
	rm -rf NA
	rm -f vivado.*