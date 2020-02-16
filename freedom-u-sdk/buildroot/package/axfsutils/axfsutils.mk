################################################################################
#
# axfsutils
#
################################################################################

AXFSUTILS_VERSION = 64886703fdff6cfc64eb20fbe7d7295bbeec867b
AXFSUTILS_SITE = $(call github,jaredeh,axfs,$(AXFSUTILS_VERSION))
AXFSUTILS_LICENSE = GPLv2
AXFSUTILS_LICENSE_FILES = mkfs.axfs-legacy/COPYING
AXFSUTILS_DEPENDENCIES = host-zlib

# The 'new' mkfs.axfs version requires GNUstep which is not a buildroot
# prerequisite. The 'legacy' one works just as well without that requirement.
define HOST_AXFSUTILS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D)/mkfs.axfs-legacy
endef

define HOST_AXFSUTILS_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mkfs.axfs-legacy/mkfs.axfs \
		$(HOST_DIR)/usr/bin/mkfs.axfs
endef

$(eval $(host-generic-package))
