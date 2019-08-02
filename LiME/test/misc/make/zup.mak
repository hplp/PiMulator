LABEL = V$(subst .,_,$(VERSION))
EXE = .elf

WORKSPACE_LOC ?= ../../../standalone/sdk
BSP = $(WORKSPACE_LOC)/standalone_bsp_a53
HWP = $(WORKSPACE_LOC)/hw_platform_0
#XSDB = xmd$(if $(findstring Linux,$(shell uname -s)),,.bat) -tcl
XSDB = xsdb$(if $(findstring Linux,$(shell uname -s)),,.bat)

#DEFS += -DVERSION=$(VERSION)
DEFS += -DZYNQ=_ZU_ -DXILTIME -DUSE_MARGS -DMARGS='"$(RUN_ARGS)"'

ifneq ($(findstring M5,$(DEFS)),)
  SRC += ../../m5
  MODULES += m5op_arm_A64
endif

ifneq ($(findstring CLOCKS,$(DEFS)),)
  MODULES += clocks_sa
endif

ifneq ($(filter %STATS %TRACE,$(DEFS)),)
  MODULES += monitor_sa
endif

OBJECTS = $(addsuffix .o,$(MODULES))
VPATH = $(subst ' ',:,$(SRC))

# ARM Processor
CC = aarch64-none-elf-gcc
CXX = aarch64-none-elf-g++
SIZE = aarch64-none-elf-size

OPT = -O3
# -funsafe-math-optimizations -ffast-math
# Zynq UltraScale+ MPSoC: ARMv8-A architecture, Cortex-A53 processor, VFPv4 floating point, NEON co-processor, Crypto
# MACH = -march=armv8-a+simd+crypto -mcpu=cortex-a53 -mfpu=crypto-neon-fp-armv8 -mvectorize-with-neon-quad -mfloat-abi=hard
# -mneon-for-64bits (enable scalar 64-bit operations, gcc v4.9.x)
CPPFLAGS += -MMD $(DEFS)
CPPFLAGS += $(patsubst %,-I%,$(SRC))
CPPFLAGS += -I$(BSP)/psu_cortexa53_0/include
CFLAGS += $(MACH) $(OPT) -Wall
CXXFLAGS += $(CFLAGS)
LDFLAGS += -Wl,-T -Wl,cpu_lscript.ld -L$(BSP)/psu_cortexa53_0/lib
LDLIBS += -Wl,--start-group,-lxilffs,-lxil,-lgcc,-lc,--end-group

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:
# Define suffixes of interest
.SUFFIXES: .o .c .cc .cpp .h .hpp .d .mak .ld

.PHONY: all
all: $(TARGET)$(EXE)
ifneq ($(and $(filter %CLIENT,$(DEFS)),$(wildcard ../mcu)),)
	cd ../mcu && $(MAKE) build=mcu D=SERVER all
endif

.PHONY: fpga
fpga:
	$(XSDB) ../../misc/sdk/fpga_config_zu.tcl $(HWP)

.PHONY: run
run: all
ifneq ($(and $(filter %CLIENT,$(DEFS)),$(wildcard ../mcu)),)
	$(XSDB) ../../misc/sdk/mb_start.tcl ../mcu/$(TARGET)$(EXE)
endif
	$(XSDB) ../../misc/sdk/a53_run.tcl $(TARGET)$(EXE)

.PHONY: clean
clean:
	$(RM) $(wildcard *.o) $(wildcard *.d) $(TARGET)$(EXE) $(TARGET)$(EXE).size makeflags
ifneq ($(wildcard ../mcu),)
	cd ../mcu && $(MAKE) build=mcu D=SERVER clean
endif

.PHONY: vars
vars:
	@echo TARGET: $(TARGET)
	@echo VERSION: $(VERSION)
	@echo DEFS: $(DEFS)
	@echo SRC: $(SRC)
	@echo OBJECTS: $(OBJECTS)
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)
ifneq ($(and $(filter %CLIENT,$(DEFS)),$(wildcard ../mcu)),)
	cd ../mcu && $(MAKE) build=mcu D=SERVER vars
endif

$(TARGET)$(EXE): $(OBJECTS) cpu_lscript.ld
	$(LINK.cpp) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@
	$(SIZE) $@  |tee $@.size

$(OBJECTS): $(MAKEFILE_LIST) # rebuild if MAKEFILEs change

$(OBJECTS): makeflags # rebuild if MAKEFLAGS change
# Select only command line variables
cvars = _$(strip $(foreach flag,$(MAKEFLAGS),$(if $(findstring =,$(flag)),$(flag),)))_
makeflags: FORCE
	@[ "$(if $(wildcard $@),$(shell cat $@),)" = "$(cvars)" ] || echo $(cvars)> $@
FORCE: ;

# Establish module specific dependencies
-include $(OBJECTS:.o=.d)
