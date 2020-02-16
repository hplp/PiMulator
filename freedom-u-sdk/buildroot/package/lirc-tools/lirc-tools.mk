################################################################################
#
# lirc-tools
#
################################################################################

LIRC_TOOLS_VERSION = 0.9.3a
LIRC_TOOLS_SOURCE = lirc-$(LIRC_TOOLS_VERSION).tar.bz2
LIRC_TOOLS_SITE = http://downloads.sourceforge.net/project/lirc/LIRC/$(LIRC_TOOLS_VERSION)
LIRC_TOOLS_LICENSE = GPLv2+
LIRC_TOOLS_LICENSE_FILES = COPYING
LIRC_TOOLS_DEPENDENCIES = host-libxslt host-pkgconf host-python3
LIRC_TOOLS_INSTALL_STAGING = YES
# 0001-lib-use-proper-linking-method-to-avoid-parallel-buil.patch
LIRC_TOOLS_AUTORECONF = YES

LIRC_TOOLS_CONF_ENV = XSLTPROC=yes
LIRC_TOOLS_CONF_OPTS = --without-x

define LIRC_TOOLS_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/lirc-tools/S25lircd \
		$(TARGET_DIR)/etc/init.d/S25lircd
endef

$(eval $(autotools-package))
