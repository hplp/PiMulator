# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

build = zup
WORKSPACE_LOC ?= ../standalone/sdk
HWP = $(WORKSPACE_LOC)/hw_platform_0
#XSDB = xmd$(if $(findstring Linux,$(shell uname -s)),,.bat) -tcl
XSDB = xsdb$(if $(findstring Linux,$(shell uname -s)),,.bat)

# External Dependencies:
# $(WORKSPACE_LOC)/hw_platform_0/system_wrapper.bit
# $(WORKSPACE_LOC)/standalone_bsp_a53

.PHONY: all run
.DEFAULT all run:
	cd mem/$(build) && $(MAKE) $@
	cd strm/$(build) && $(MAKE) $@

.PHONY: fpga
fpga:
ifeq ($(build),zynq)
	$(XSDB) misc/sdk/fpga_config_z7.tcl $(HWP)
else ifeq ($(build),zup)
	$(XSDB) misc/sdk/fpga_config_zu.tcl $(HWP)
endif

run: fpga

.PHONY: clean
clean:
	cd mem/zup && $(MAKE) clean
	cd strm/arm_64 && $(MAKE) clean
	cd strm/x86_64 && $(MAKE) clean
	cd strm/zup && $(MAKE) clean
	cd strm/zynq && $(MAKE) clean
