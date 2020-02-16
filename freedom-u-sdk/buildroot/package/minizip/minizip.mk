################################################################################
#
# minizip
#
################################################################################

MINIZIP_VERSION = 5f56dd81d94bd7028f7dc05d7d14112697c30241
MINIZIP_SITE = $(call github,nmoinvaz,minizip,$(MINIZIP_VERSION))
MINIZIP_DEPENDENCIES = zlib
MINIZIP_AUTORECONF = YES
MINIZIP_INSTALL_STAGING = YES
MINIZIP_CONF_OPTS = $(if $(BR2_PACKAGE_MINIZIP_DEMOS),--enable-demos)
MINIZIP_LICENSE = zlib license
MINIZIP_LICENSE_FILES = LICENSE

$(eval $(autotools-package))
