################################################################################
#
# spidev_test
#
################################################################################

# v3.15+ requires SPI_TX_QUAD/SPI_RX_QUAD to build
# Normally kernel headers can't be newer than kernel so switch based on that.
# If you need quad-pumped spi support you need to upgrade your toolchain.
ifeq ($(BR2_TOOLCHAIN_HEADERS_AT_LEAST_3_15),y)
SPIDEV_TEST_VERSION = v3.15
else
SPIDEV_TEST_VERSION = v3.0
endif
SPIDEV_TEST_SITE = http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/plain/Documentation/spi
SPIDEV_TEST_SOURCE = spidev_test.c?id=$(SPIDEV_TEST_VERSION)
SPIDEV_TEST_LICENSE = GPLv2

define SPIDEV_TEST_EXTRACT_CMDS
	cp $(BR2_DL_DIR)/$(SPIDEV_TEST_SOURCE) $(@D)/spidev_test.c
endef

define SPIDEV_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CC) $(TARGET_CFLAGS) \
		-o $(@D)/spidev_test $(@D)/spidev_test.c
endef

define SPIDEV_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/spidev_test \
		$(TARGET_DIR)/usr/sbin/spidev_test
endef

$(eval $(generic-package))
