# Input: HLS source
# Output: generated HDL libraries

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

SUBDIR := $(patsubst %/,%,$(shell ls -d */))
TCLSH := $(if $(findstring Linux,$(shell uname -s)),tclsh,xtclsh)

# TODO: Warning: this Makefile is not sensitive to source code changes

.PHONY: all
all:
	$(TCLSH) build_ip.tcl

.PHONY: clean
clean:
	@for i in $(SUBDIR); do \
		$(RM) -r $$i/solution1; \
		$(RM) $$i/*.app; \
	done
	$(RM) *.log
