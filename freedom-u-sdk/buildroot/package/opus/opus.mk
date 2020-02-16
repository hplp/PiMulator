################################################################################
#
# opus
#
################################################################################

OPUS_VERSION = 1.1.2
OPUS_SITE = http://downloads.xiph.org/releases/opus
OPUS_LICENSE = BSD-3c
OPUS_LICENSE_FILES = COPYING
OPUS_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_OPUS_FIXED_POINT),y)
OPUS_CONF_OPTS += --enable-fixed-point
endif

$(eval $(autotools-package))
