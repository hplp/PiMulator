################################################################################
#
# libxcb
#
################################################################################

LIBXCB_VERSION = 1.12
LIBXCB_SOURCE = libxcb-$(LIBXCB_VERSION).tar.bz2
LIBXCB_SITE = http://xcb.freedesktop.org/dist
LIBXCB_LICENSE = MIT
LIBXCB_LICENSE_FILES = COPYING

LIBXCB_INSTALL_STAGING = YES

LIBXCB_DEPENDENCIES = \
	host-libxslt libpthread-stubs xcb-proto xlib_libXdmcp xlib_libXau \
	host-xcb-proto host-python host-pkgconf

LIBXCB_CONF_OPTS = --with-doxygen=no
HOST_LIBXCB_CONF_OPTS = --with-doxygen=no

$(eval $(autotools-package))
$(eval $(host-autotools-package))
