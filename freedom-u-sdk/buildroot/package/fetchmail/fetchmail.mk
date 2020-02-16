################################################################################
#
# fetchmail
#
################################################################################

FETCHMAIL_VERSION_MAJOR = 6.3
FETCHMAIL_VERSION = $(FETCHMAIL_VERSION_MAJOR).26
FETCHMAIL_SOURCE = fetchmail-$(FETCHMAIL_VERSION).tar.xz
FETCHMAIL_SITE = http://downloads.sourceforge.net/project/fetchmail/branch_$(FETCHMAIL_VERSION_MAJOR)
FETCHMAIL_LICENSE = GPLv2; some exceptions are mentioned in COPYING
FETCHMAIL_LICENSE_FILES = COPYING
FETCHMAIL_AUTORECONF = YES
FETCHMAIL_GETTEXTIZE = YES

FETCHMAIL_CONF_ENV += LIBS="-lz"

FETCHMAIL_CONF_OPTS = \
	--with-ssl=$(STAGING_DIR)/usr

FETCHMAIL_DEPENDENCIES = \
	ca-certificates \
	openssl \
	$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext)

# fetchmailconf.py script is not (yet) python3-compliant.
# Prevent the pyc-compilation with python-3 from failing by removing this
# non-critical script.
ifeq ($(BR2_PACKAGE_PYTHON3),y)
define FETCHMAIL_REMOVE_FETCHMAILCONF_PY
	$(RM) -f $(TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/fetchmailconf.py
endef
FETCHMAIL_POST_INSTALL_TARGET_HOOKS += FETCHMAIL_REMOVE_FETCHMAILCONF_PY
endif

$(eval $(autotools-package))
