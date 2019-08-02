# Input: IP library, .tcl scripts
# Output: .sysdef

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

PROJ = psu_lime
IMPL = $(PROJ).runs/impl_1
SYSTEM = system_wrapper

.PHONY: all
all: $(IMPL)/$(SYSTEM).sysdef
	@tput setaf 2; echo "Build complete!"; tput sgr0;

.PHONY: design
$(PROJ).xpr design:
	vivado -mode batch -source design.tcl -notrace
#	touch $(PROJ).xpr

.PHONY: compile
$(IMPL)/$(SYSTEM).sysdef compile: $(PROJ).xpr
	vivado -mode batch -source compile.tcl -notrace
#	mkdir -p $(IMPL)
#	touch $(IMPL)/$(SYSTEM).sysdef

.PHONY: clean
clean:
	$(RM) -r $(PROJ).* .Xil
	$(RM) *.jou *.log
