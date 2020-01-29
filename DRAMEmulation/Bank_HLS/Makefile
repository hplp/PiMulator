## Makefile to generate Bank HLS IP
# requires vivado_hls

# for Pynq-Z1 board
#TARGET=xc7z020clg400-1

# for UltraZed-EG board (requires ES1 and Vivado 2017.4)
TARGET=xczu3eg-sfva625-1-i-es1

#
Bank_HLS:
	vivado_hls -f Bank_HLS.tcl $(TARGET)
	@echo Finished Bank_HLS IP for $(TARGET)

.PHONY: clean
clean:
	rm -rf Bank_HLS