################################################################################
#
# devmem2
#
################################################################################

DEVMEM2_SITE = http://free-electrons.com/pub/mirror
DEVMEM2_SOURCE = devmem2.c
DEVMEM2_VERSION = 1
DEVMEM2_LICENSE = GPLv2+
DEVMEM2_LICENSE_FILES = devmem2.c

define DEVMEM2_EXTRACT_CMDS
	cp $(DL_DIR)/$($(PKG)_SOURCE) $(@D)/
endef

define DEVMEM2_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) devmem2
endef

define DEVMEM2_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/devmem2 $(TARGET_DIR)/sbin/devmem2
endef

$(eval $(generic-package))
