
PACKAGE = lime-2.1.0

# Cancel version control implicit rules
%:: %,v
%:: RCS/%
%:: RCS/%,v
%:: s.%
%:: SCCS/s.%
# Delete default suffixes
.SUFFIXES:

.PHONY: all
all:
	@echo "Specify a board target (sidewinder or zcu102)"
	@echo "and optionally an OS target (standalone or linux)."
	@echo "Use target 'sdcard' to format and copy linux to an SD card."
	@echo "Use the make variable 'DEV' to specify the SD device"
	@echo "(e.g. make sdcard DEV=/dev/mmcblk0)."
	@echo "Preconditions:"
	@echo "1) Xilinx tools in path (e.g. source /opt/Xilinx/Vivado/<version>/settings64.sh)"
	@echo "2) Path to Internet through firewall (e.g lynx www.google.com)"

.PHONY: ip
ip:
	cd ip && $(MAKE)

.PHONY: sidewinder
sidewinder: ip
	cd system && $(MAKE) sidewinder

.PHONY: zcu102
zcu102: ip
	cd system && $(MAKE) zcu102

.PHONY: standalone
standalone:
	cd standalone && $(MAKE)

.PHONY: linux
linux:
	cd linux && $(MAKE)

.PHONY: test
test: standalone
	cd test && $(MAKE) run

.PHONY: sdcard
sdcard: linux
	cd linux/boot && ./mksd.sh $(DEV)

.PHONY: clean
clean:
	cd ip && $(MAKE) clean
	cd system && $(MAKE) clean
	cd standalone && $(MAKE) clean
	cd linux && $(MAKE) clean
	cd test && $(MAKE) clean

.PHONY: dist
dist: clean
	tar --transform 's,^,$(PACKAGE)/,' -czf ../$(PACKAGE).tgz --exclude-vcs *
