# Input: system_wrapper.hdf, .tcl scripts
# Output: hw_platform_0, standalone_bsp_*

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
all: sdk/standalone_bsp_a53/psu_cortexa53_0/lib/libxil.a
	@echo "BOARD: $(BOARD)"

# Build SDK Projects (hw_platform_0, BSPs)
# These are all built together because the SDK leaves a history in .metadata
# Also built: sdk/standalone_bsp_mb/engine_0_microblaze_0/lib/libxil.a
sdk/standalone_bsp_a53/psu_cortexa53_0/lib/libxil.a: $(HDF)
	mkdir -p sdk
	-$(RM) -r sdk/* sdk/.metadata
	xsct sdk.tcl $(HDF)

.PHONY: clean
clean:
	$(RM) -r .Xil
	$(RM) -r sdk
