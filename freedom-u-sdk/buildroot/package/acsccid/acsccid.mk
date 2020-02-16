################################################################################
#
# acsccid
#
################################################################################

ACSCCID_VERSION = 1.1.1
ACSCCID_SOURCE = acsccid-$(ACSCCID_VERSION).tar.bz2
ACSCCID_SITE = http://downloads.sourceforge.net/acsccid
ACSCCID_LICENSE = LGPLv2.1+
ACSCCID_LICENSE_FILES = COPYING
ACSCCID_INSTALL_STAGING = YES
ACSCCID_DEPENDENCIES = pcsc-lite host-flex host-pkgconf libusb

$(eval $(autotools-package))
