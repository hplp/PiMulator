## Makefile to generate Bank HLS IP
# requires vivado_hls (version might matter)

.PHONY: help
help:
	@echo "Makefile Usage:"
	@echo "-  make Bank_HLS TARGET=<xc7z020clg400-1/xczu3eg-sfva625-1-i-es1/other?>"
	@echo "      Command to generate the Bank_HLS IP for specified FPGA Target."
	@echo "      default TARGET=xc7z020clg400-1 (Pynq-Z1 board)"
	@echo "-  make clean"
	@echo "      Command to remove the generated files."

# for Pynq-Z1 board
#TARGET=xc7z020clg400-1

# for UltraZed-EG board (requires ES1 and Vivado 2017.4)
TARGET=xczu3eg-sfva625-1-i-es1

# Generating Bank_HLS Vivado HLS project with Bank IP
Bank_HLS:
	@echo Starting Bank_HLS IP for $(TARGET)
	vivado_hls -f Bank_HLS.tcl $(TARGET)
	@echo Finished Bank_HLS IP for $(TARGET)

.PHONY: clean
clean:
	rm -rf Bank_HLS
	rm -f *.log