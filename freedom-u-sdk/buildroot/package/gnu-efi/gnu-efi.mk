################################################################################
#
# gnu-efi
#
################################################################################

GNU_EFI_VERSION = 3.0.1
GNU_EFI_SOURCE = gnu-efi-$(GNU_EFI_VERSION).tar.bz2
GNU_EFI_SITE = http://downloads.sourceforge.net/project/gnu-efi
GNU_EFI_INSTALL_STAGING = YES
GNU_EFI_LICENSE = BSD-3c and/or GPLv2+ (gnuefi), BSD-3c (efilib)
GNU_EFI_LICENSE_FILES = README.efilib

# gnu-efi is a set of library and header files used to build
# standalone EFI applications such as bootloaders. There is no point
# in installing these libraries to the target.
GNU_EFI_INSTALL_TARGET = NO

ifeq ($(BR2_i386),y)
GNU_EFI_PLATFORM = ia32
else ifeq ($(BR2_x86_64),y)
GNU_EFI_PLATFORM = x86_64
endif

define GNU_EFI_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		ARCH=$(GNU_EFI_PLATFORM)
endef

define GNU_EFI_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		INSTALLROOT=$(STAGING_DIR) \
		PREFIX=/usr ARCH=$(GNU_EFI_PLATFORM) install
endef

$(eval $(generic-package))
