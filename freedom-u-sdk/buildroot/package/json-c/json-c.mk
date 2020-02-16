################################################################################
#
# json-c
#
################################################################################

JSON_C_VERSION = json-c-0.12-20140410
JSON_C_SITE = $(call github,json-c,json-c,$(JSON_C_VERSION))
JSON_C_INSTALL_STAGING = YES
JSON_C_MAKE = $(MAKE1)
JSON_C_CONF_OPTS = --disable-oldname-compat
# AUTORECONF is needed because of Makefile.am.inc patch.
JSON_C_AUTORECONF = YES
JSON_C_LICENSE = MIT
JSON_C_LICENSE_FILES = COPYING

$(eval $(autotools-package))
