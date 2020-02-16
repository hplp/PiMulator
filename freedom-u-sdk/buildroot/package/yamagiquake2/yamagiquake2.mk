################################################################################
#
# lbreakout2
#
################################################################################

YAMAGIQUAKE2_VERSION = 7.10
YAMAGIQUAKE2_SOURCE = quake2-$(YAMAGIQUAKE2_VERSION).tar.xz
YAMAGIQUAKE2_SITE = https://deponie.yamagi.org/quake2
YAMAGIQUAKE2_LICENSE = GPLv2+
YAMAGIQUAKE2_LICENSE_FILES = COPYING
YAMAGIQUAKE2_DEPENDENCIES = mesa3d sdl2 openal libvorbis zlib xlib_libXxf86vm

YAMAGIQUAKE2_MAKE_OPTS += LOCALBASE=$(STAGING_DIR)/usr
YAMAGIQUAKE2_MAKE_OPTS += $(TARGET_CONFIGURE_OPTS)

define YAMAGIQUAKE2_BUILD_CMDS
	test -x $(HOST_DIR)/usr/bin/sdl2-config || ln -s $(HOST_DIR)/usr/*/sysroot/usr/bin/sdl2-config $(HOST_DIR)/usr/bin
	$(MAKE) $(YAMAGIQUAKE2_MAKE_OPTS) YQ2_ARCH=riscv YQ2_OSTYPE=Linux VERBOSE=1 -C $(@D)
endef

define YAMAGIQUAKE2_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/games
	cp -a $(@D)/release/* $(TARGET_DIR)/usr/games
endef

$(eval $(generic-package))
