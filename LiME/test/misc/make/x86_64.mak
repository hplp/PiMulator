LABEL = V$(subst .,_,$(VERSION))

#DEFS += -DVERSION=$(VERSION)
ifeq ($(findstring SYSTEMC,$(DEFS)),)
  DEFS += -DTIMEOFDAY
endif

ifneq ($(findstring USE_MARGS,$(DEFS)),)
  DEFS += -DMARGS='"$(RUN_ARGS)"'
endif

ifneq ($(findstring M5,$(DEFS)),)
  SRC += ../../m5
  MODULES += m5op_x86
endif

ifneq ($(findstring CLOCKS,$(DEFS)),)
  MODULES += clocks_ln
endif

ifneq ($(filter %STATS %TRACE,$(DEFS)),)
  MODULES += monitor_ln
endif

ifneq ($(findstring SYSTEMC,$(DEFS)),)
  ifneq ($(findstring HMCSIM,$(DEFS)),)
    SRC += $(HOME)/work/hmcsim-2.3
    LDFLAGS += -L$(HOME)/work/hmcsim-2.3
    LDLIBS += -lhmcsim
    SCDIR = src/systemc-2.3.0a
    LDFLAGS += -L$(HOME)/$(SCDIR)/objdir/src/sysc/.libs
  else
    SCDIR = src/systemc-2.3.2
    LDFLAGS += -L$(HOME)/$(SCDIR)/objdir/src/.libs
    ifeq ($(findstring c++11,$(CXXFLAGS)),)
      CXXFLAGS += -std=c++11
    endif
  endif
  SRC += $(HOME)/$(SCDIR)/src
  # squelch warning from SystemC sc_bit_proxies.h
  CFLAGS += -Wno-strict-overflow
  # application build -std=option must match SystemC library build
  LDLIBS += -lsystemc -lpthread
endif


OBJECTS = $(addsuffix .o,$(MODULES))
VPATH = $(subst ' ',:,$(SRC))

OPT ?= -O3
#OPT += -ftree-vectorize -ffast-math
ifdef OMP
  OPT += -fopenmp
endif
#MACH = -march=core2 -mfpmath=sse
CPPFLAGS += -MMD $(DEFS)
CPPFLAGS += $(patsubst %,-I%,$(SRC))
CFLAGS += $(MACH) $(OPT) -Wall
CXXFLAGS += $(CFLAGS)
#LDFLAGS += -static
#LDLIBS += -lrt

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:
# Define suffixes of interest
.SUFFIXES: .o .c .cc .cpp .h .hpp .d .mak

.PHONY: all
all: $(TARGET)

.PHONY: run
run: $(TARGET)
ifdef OMP
	OMP_NUM_THREADS=$(OMP) ./$(TARGET) $(RUN_ARGS)
else
	./$(TARGET) $(RUN_ARGS)
endif

.PHONY: clean
clean:
	$(RM) $(wildcard *.o) $(wildcard *.d) $(TARGET) makeflags

.PHONY: vars
vars:
	@echo TARGET: $(TARGET)
	@echo VERSION: $(VERSION)
	@echo DEFS: $(DEFS)
	@echo SRC: $(SRC)
	@echo OBJECTS: $(OBJECTS)
	@echo MAKEFILE_LIST: $(MAKEFILE_LIST)

$(TARGET): $(OBJECTS)
	$(LINK.cpp) $^ $(LOADLIBES) $(LDLIBS) -o $@

$(OBJECTS): $(MAKEFILE_LIST) # rebuild if MAKEFILEs change

$(OBJECTS): makeflags # rebuild if MAKEFLAGS change
# Select only command line variables
cvars = _$(strip $(foreach flag,$(MAKEFLAGS),$(if $(findstring =,$(flag)),$(flag),)))_
makeflags: FORCE
	@[ "$(if $(wildcard $@),$(shell cat $@),)" = "$(cvars)" ] || echo $(cvars)> $@
FORCE: ;

# Establish module specific dependencies
-include $(OBJECTS:.o=.d)
