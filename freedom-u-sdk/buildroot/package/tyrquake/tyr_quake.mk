################################################################################
#
# lbreakout2
#
################################################################################

TYRQUAKE_VERSION = 20171127
TYRQUAKE_SOURCE = v$(TYRQUAKE_VERSION).tar.gz
TYRQUAKE_SITE = https://github.com/palmer-dabbelt/tyrquake/archive
TYRQUAKE_LICENSE = GPLv2+
TYRQUAKE_LICENSE_FILES = COPYING
TYRQUAKE_DEPENDENCIES = mesa3d xlib_libXxf86vm xlib_libXxf86dga

TYRQUAKE_MAKE_OPTS += LOCALBASE=$(STAGING_DIR)/usr
TYRQUAKE_MAKE_OPTS += $(TARGET_CONFIGURE_OPTS)

define TYRQUAKE_BUILD_CMDS
	$(MAKE) $(TYRQUAKE_MAKE_OPTS) -C $(@D)
endef

define TYRQUAKE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/games
	cp $(@D)/bin/* $(TARGET_DIR)/usr/games
endef

$(eval $(generic-package))
