LABEL = V$(subst .,_,$(VERSION))
EXE = .elf

WORKSPACE_LOC ?= ../../../standalone/sdk
BSP = $(WORKSPACE_LOC)/standalone_bsp_mb

#DEFS += -DVERSION=$(VERSION)

OBJECTS = $(addsuffix .o,$(MODULES))
VPATH = $(subst ' ',:,$(SRC))

# Xilinx MicroBlaze Soft Processor
CC = mb-gcc
CXX = mb-g++
SIZE = mb-size

OPTM = -O2
MACH = -mcpu=v9.6 -mlittle-endian -mno-xl-reorder -mxl-barrel-shift -mno-xl-soft-div -mno-xl-soft-mul
CPPFLAGS += -MMD $(DEFS)
CPPFLAGS += $(patsubst %,-I%,$(SRC))
CPPFLAGS += -I$(BSP)/engine_0_mcu_0_microblaze_0/include
CFLAGS += $(MACH) $(OPTM) -Wall -fno-strict-aliasing -ffunction-sections -fdata-sections
CXXFLAGS += $(CFLAGS)
LDFLAGS += -Wl,-T -Wl,mcu_lscript.ld -L$(BSP)/engine_0_mcu_0_microblaze_0/lib -Wl,--no-relax -Wl,--gc-sections
LDLIBS += -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

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

.PHONY: clean
clean:
	$(RM) $(wildcard *.o) $(wildcard *.d) $(TARGET)$(EXE) $(TARGET)$(EXE).size makeflags

.PHONY: vars
vars:
	@echo TARGET: $(TARGET)
	@echo VERSION: $(VERSION)
	@echo DEFS: $(DEFS)
	@echo SRC: $(SRC)
	@echo OBJECTS: $(OBJECTS)
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)

$(TARGET)$(EXE): $(OBJECTS) mcu_lscript.ld
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
