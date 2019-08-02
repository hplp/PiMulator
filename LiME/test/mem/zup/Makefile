ifdef D
  SEP := ,
  DEFS += $(patsubst %,-D%,$(subst $(SEP), ,$(D)))
endif
include ../src/sources.mak
include ../../misc/make/$(notdir $(CURDIR)).mak
