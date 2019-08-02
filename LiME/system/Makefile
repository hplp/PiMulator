# Input: IP library, .tcl scripts
# Output: .hdf

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
SUBDIR := $(patsubst %/,%,$(shell ls -d */))

.PHONY: all
all:
	@echo "Specify a board target:"
	@for i in $(SUBDIR); do echo $$i; done

.PHONY: $(SUBDIR)
$(SUBDIR):
	cd $@ && $(MAKE) all
	ln -sf $@/$(IMPL)/$(SYSTEM).sysdef $(SYSTEM).hdf
	touch $(SYSTEM).hdf

.PHONY: clean
clean:
	@for i in $(SUBDIR); do \
		$(MAKE) -C $$i clean; \
	done
	$(RM) $(SYSTEM).hdf
