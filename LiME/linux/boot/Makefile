# Input: TODO
# Output: bootfiles.tar.xz

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

.PHONY: all
all: bootfiles.tar.xz

# External Dependencies:
# FSBL and .bit file built with PMUFW
# ../sdk/fsbl/Release/fsbl.elf
# ../sdk/hw_platform_0/system_wrapper.bit
# ../sdk/pmufw/Release/pmufw.elf
# ../arm-trusted-firmware/build/zynqmp/release/bl31/bl31.elf
# ../u-boot-xlnx/u-boot.elf
# ../dts/system.dtb
# ../linux-xlnx/arch/arm64/boot/Image

BOOT.BIN:
	bootgen -arch zynqmp -image bootgen.bif -o i BOOT.BIN -w on

bootfiles.tar.xz: BOOT.BIN uEnv.txt
	tar -cJf bootfiles.tar.xz BOOT.BIN uEnv.txt -C ../dts system.dtb -C ../linux-xlnx/arch/arm64/boot Image

.PHONY: clean
clean:
	$(RM) BOOT.BIN bootfiles.tar.xz
