TARGET = strm
VERSION = 1.0
SRC = ../src ../../shared
MODULES = strm
ifeq ($(ARG),1)
  DEFS += -DSTREAM_ARRAY_SIZE=120000000
else
  DEFS += -DSTREAM_ARRAY_SIZE=20000000
endif
DEFS += -DNTIMES=2
RUN_ARGS = 
# CXXFLAGS += -std=c++11
# LDFLAGS += 
# LDLIBS += -lstdc++
