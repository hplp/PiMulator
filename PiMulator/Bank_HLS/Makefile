## Makefile to generate Bank HLS IP
# requires vivado_hls (version might matter)

# for Pynq-Z1 board
#TARGET=xc7z020clg400-1

# for UltraZed-EG board (requires ES1 and Vivado 2017.4)
#TARGET=xczu3eg-sfva625-1-i-es1

# for Alveo U280 ES1 Accelerator Card (requires ES1 and Vivado 2019+)
TARGET=xcu280-fsvh2892-2L-e

.PHONY: help
help:
	@echo "Makefile Usage:"
	@echo "-  make Bank_HLS TARGET=<xc7z020clg400-1/xczu3eg-sfva625-1-i-es1/xcu280-fsvh2892-2L-e/other?>"
	@echo "      Command to generate the Bank_HLS IP for specified FPGA Target."
	@echo "      default TARGET=$(TARGET)"
	@echo "-  make clean"
	@echo "      Command to remove the generated files."

# Generating Bank_HLS Vivado HLS project with Bank IP
Bank_HLS:
	@echo Starting Bank_HLS IP for $(TARGET)
	vivado_hls -f Bank_HLS.tcl $(TARGET)
	@echo Finished Bank_HLS IP for $(TARGET)

.PHONY: clean
clean:
	rm -rf Bank_HLS
	rm -f *.log