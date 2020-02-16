################################################################################
#
# upmpdcli
#
################################################################################

UPMPDCLI_VERSION = 1.1.3
UPMPDCLI_SITE = http://www.lesbonscomptes.com/upmpdcli/downloads
UPMPDCLI_LICENSE = GPLv2+
UPMPDCLI_LICENSE_FILES = COPYING
UPMPDCLI_DEPENDENCIES = libmpdclient libupnpp

ifeq ($(BR2_STATIC_LIBS),y)
# Upmpdcli forgets to take the dependencies of libupnpp into
# consideration, breaking static linking, so help it.
# Libupnpp unfortunately doesn't provide a .pc file, so manually
# handle the dependencies here.
# The build system doesn't expand LIBS from the configure step, so
# manually pass it to make.
UPMPDCLI_DEPENDENCIES += host-pkgconf
UPMPDCLI_MAKE_OPTS = \
	LIBS="`$(PKG_CONFIG_HOST_BINARY) --libs expat libcurl libupnp`"
endif

# Upmpdcli only runs if user upmpdcli exists
define UPMPDCLI_USERS
	upmpdcli -1 upmpdcli -1 * - - - Upmpdcli MPD UPnP Renderer Front-End
endef

define UPMPDCLI_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/upmpdcli/S99upmpdcli $(TARGET_DIR)/etc/init.d/S99upmpdcli
endef

define UPMPDCLI_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(@D)/systemd/upmpdcli.service \
		$(TARGET_DIR)/usr/lib/systemd/system/upmpdcli.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf ../../../../usr/lib/systemd/system/upmpdcli.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/upmpdcli.service
endef

define UPMPDCLI_INSTALL_CONF_FILE
	$(INSTALL) -D -m 0755 $(@D)/src/upmpdcli.conf-dist $(TARGET_DIR)/etc/upmpdcli.conf
endef

UPMPDCLI_POST_INSTALL_TARGET_HOOKS += UPMPDCLI_INSTALL_CONF_FILE

$(eval $(autotools-package))
