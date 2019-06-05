# Input: system_wrapper.hdf, .tcl scripts
# Output: bootfiles.tar.xz

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

HDF = ../system/system_wrapper.hdf
BOARD = $(firstword $(subst /, ,$(shell readlink -n $(HDF))))

.PHONY: all
all: boot/bootfiles.tar.xz
	@echo "BOARD: $(BOARD)"

device-tree-xlnx:
	git clone https://github.com/Xilinx/device-tree-xlnx.git

dtc/Makefile:
	git clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git

arm-trusted-firmware/Makefile:
	git clone https://github.com/Xilinx/arm-trusted-firmware.git

u-boot-xlnx/Makefile:
	git clone https://github.com/Xilinx/u-boot-xlnx.git

linux-xlnx/Makefile:
	git clone https://github.com/Xilinx/linux-xlnx.git

# Build SDK Projects (hw_platform_0, BSPs, FSBL, PMUFW)
# These are all built together because the SDK leaves a history in .metadata
sdk/pmufw/Release/pmufw.elf: $(HDF)
	mkdir -p sdk
	-$(RM) -r sdk/* sdk/.metadata
	xsct sdk.tcl $(HDF)

# Build DTS
# Dependent on sdk/hw_platform_0 but using pmufw.elf instead
dts/system-top.dts: sdk/pmufw/Release/pmufw.elf device-tree-xlnx
	cd device-tree-xlnx &&\
	git checkout xilinx-v2018.2
	$(RM) -r dts
	xsct dts.tcl
ifeq "$(BOARD)" "sidewinder"
	sed -i.bak '/memory {/,/};/c\memory {\n\tdevice_type = "memory";\n\tlinux,usable-memory = <0x10 0x00000000 0x4 0x00000000>;\n};' dts/system-top.dts
	sed -i.bak '/&sdhci1 {/ a\\tno-1-8-v;\n\tdisable-wp;' dts/pcw.dtsi
else
	sed -i.bak '/memory {/,/};/c\memory {\n\tdevice_type = "memory";\n\tlinux,usable-memory = <0x10 0x00000000 0x1 0x00000000>;\n};' dts/system-top.dts
	sed -i.bak '/fclk0: fclk0 {/,/status = "disabled";/c\\tfclk0: fclk0 {\n\t\tstatus = "okay";' dts/zynqmp-clk-ccf.dtsi
	sed -i.bak '/fclk1: fclk1 {/,/status = "disabled";/c\\tfclk1: fclk1 {\n\t\tstatus = "okay";' dts/zynqmp-clk-ccf.dtsi
	sed -i.bak '/&xlnx_dpdma {/,/};/c\&xlnx_dpdma {\n\tstatus = "disabled";\n};' dts/pcw.dtsi
	sed -i.bak '/&zynqmp_dp_snd_pcm0 {/,/};/c\&zynqmp_dp_snd_pcm0 {\n\tstatus = "disabled";\n};' dts/pcw.dtsi
	sed -i.bak '/&zynqmp_dp_snd_pcm1 {/,/};/c\&zynqmp_dp_snd_pcm1 {\n\tstatus = "disabled";\n};' dts/pcw.dtsi
	sed -i.bak '/&zynqmp_dp_snd_card0 {/,/};/c\&zynqmp_dp_snd_card0 {\n\tstatus = "disabled";\n};' dts/pcw.dtsi
	sed -i.bak '/&zynqmp_dp_snd_codec0 {/,/};/c\&zynqmp_dp_snd_codec0 {\n\tstatus = "disabled";\n};' dts/pcw.dtsi
endif

# Build Device Tree Compiler (dtc)
dtc/dtc: dtc/Makefile
	cd dtc && $(MAKE)

# Build DTB
dts/system.dtb: dtc/dtc dts/system-top.dts
	cd dts && ../dtc/dtc -I dts -O dtb -o system.dtb system-top.dts

# Build Arm Trusted Firmware (ATF)
arm-trusted-firmware/build/zynqmp/release/bl31/bl31.elf: arm-trusted-firmware/Makefile
	cd arm-trusted-firmware &&\
	git checkout xilinx-v2018.2 &&\
	export CROSS_COMPILE=aarch64-linux-gnu- &&\
	export ARCH=arm64 &&\
	$(MAKE) PLAT=zynqmp RESET_TO_BL31=1

# Build U-Boot
u-boot-xlnx/u-boot.elf: u-boot-xlnx/Makefile
	cd u-boot-xlnx &&\
	git checkout xilinx-v2018.2 &&\
	export CROSS_COMPILE=aarch64-linux-gnu- &&\
	export ARCH=aarch64 &&\
	$(MAKE) distclean &&\
	$(MAKE) xilinx_zynqmp_zcu102_rev1_0_defconfig &&\
	$(MAKE)

# Build Linux Kernel
linux-xlnx/arch/arm64/boot/Image: linux-xlnx/Makefile
	cd linux-xlnx &&\
	git checkout xlnx_rebase_v4.14_2018.2 &&\
	export CROSS_COMPILE=aarch64-linux-gnu- &&\
	export ARCH=arm64 &&\
	$(MAKE) xilinx_zynqmp_defconfig &&\
	echo $(MAKE) menuconfig &&\
	$(MAKE)

# Build Boot Files
# FSBL and .bit file are built with PMUFW
# sdk/fsbl/Release/fsbl.elf
# sdk/hw_platform_0/system_wrapper.bit
boot/bootfiles.tar.xz: \
sdk/pmufw/Release/pmufw.elf \
arm-trusted-firmware/build/zynqmp/release/bl31/bl31.elf \
u-boot-xlnx/u-boot.elf \
boot/uEnv.txt \
dts/system.dtb \
linux-xlnx/arch/arm64/boot/Image
	cd boot && $(MAKE) clean
	cd boot && $(MAKE)

.PHONY: clean
clean:
	$(RM) -r .Xil
	$(RM) -r sdk
	$(RM) -r device-tree-xlnx
	$(RM) -r dts
	$(RM) -r dtc
	$(RM) -r arm-trusted-firmware
	$(RM) -r u-boot-xlnx
	$(RM) -r linux-xlnx
	cd boot && $(MAKE) clean
