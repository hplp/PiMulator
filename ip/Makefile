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

# hls/compress/solution1/impl/ip/component.xml
# hls/eth_fifo_interface/solution1/impl/ip/component.xml

.PHONY: all
all: hls/eth_fifo_interface/solution1/impl/ip/component.xml

hls/eth_fifo_interface/solution1/impl/ip/component.xml:
	cd hls && $(MAKE)

.PHONY: clean
clean:
	cd hls && $(MAKE) clean
