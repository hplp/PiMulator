################################################################################
#
# systemd
#
################################################################################

SYSTEMD_VERSION = 230
SYSTEMD_SITE = $(call github,systemd,systemd,v$(SYSTEMD_VERSION))
SYSTEMD_LICENSE = LGPLv2.1+, GPLv2+ (udev), Public Domain (few source files, see README)
SYSTEMD_LICENSE_FILES = LICENSE.GPL2 LICENSE.LGPL2.1 README
SYSTEMD_INSTALL_STAGING = YES
SYSTEMD_DEPENDENCIES = \
	host-intltool \
	libcap \
	util-linux \
	kmod \
	host-gperf

SYSTEMD_PROVIDES = udev
SYSTEMD_AUTORECONF = YES

# Make sure that systemd will always be built after busybox so that we have
# a consistent init setup between two builds
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
SYSTEMD_DEPENDENCIES += busybox
endif

SYSTEMD_CONF_OPTS += \
	--with-rootprefix= \
	--enable-static=no \
	--disable-manpages \
	--disable-selinux \
	--disable-pam \
	--disable-libcryptsetup \
	--disable-efi \
	--disable-gnuefi \
	--disable-ldconfig \
	--disable-tests \
	--with-default-dnssec=no \
	--without-python

SYSTEMD_CFLAGS = $(TARGET_CFLAGS) -fno-lto

# Override path to kmod, used in kmod-static-nodes.service
SYSTEMD_CONF_ENV = \
	CFLAGS="$(SYSTEMD_CFLAGS)" \
	ac_cv_path_KMOD=/usr/bin/kmod

define SYSTEMD_RUN_INTLTOOLIZE
	cd $(@D) && $(HOST_DIR)/usr/bin/intltoolize --force --automake
endef
SYSTEMD_PRE_CONFIGURE_HOOKS += SYSTEMD_RUN_INTLTOOLIZE

ifeq ($(BR2_PACKAGE_SYSTEMD_COMPAT),y)
SYSTEMD_CONF_OPTS += --enable-compat-libs
else
SYSTEMD_CONF_OPTS += --disable-compat-libs
endif

ifeq ($(BR2_PACKAGE_ACL),y)
SYSTEMD_CONF_OPTS += --enable-acl
SYSTEMD_DEPENDENCIES += acl
else
SYSTEMD_CONF_OPTS += --disable-acl
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
SYSTEMD_CONF_OPTS += --enable-seccomp
SYSTEMD_DEPENDENCIES += libseccomp
else
SYSTEMD_CONF_OPTS += --disable-seccomp
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_KDBUS),y)
SYSTEMD_CONF_OPTS += --enable-kdbus
else
SYSTEMD_CONF_OPTS += --disable-kdbus
endif

ifeq ($(BR2_PACKAGE_BZIP2),y)
SYSTEMD_DEPENDENCIES += bzip2
SYSTEMD_CONF_OPTS += --enable-bzip2
else
SYSTEMD_CONF_OPTS += --disable-bzip2
endif

ifeq ($(BR2_PACKAGE_LZ4),y)
SYSTEMD_DEPENDENCIES += lz4
SYSTEMD_CONF_OPTS += --enable-lz4
else
SYSTEMD_CONF_OPTS += --disable-lz4
endif

ifeq ($(BR2_PACKAGE_XZ),y)
SYSTEMD_DEPENDENCIES += xz
SYSTEMD_CONF_OPTS += --enable-xz
else
SYSTEMD_CONF_OPTS += --disable-xz
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
SYSTEMD_DEPENDENCIES += zlib
SYSTEMD_CONF_OPTS += --enable-zlib
else
SYSTEMD_CONF_OPTS += --disable-zlib
endif

ifeq ($(BR2_PACKAGE_LIBCURL),y)
SYSTEMD_DEPENDENCIES += libcurl
SYSTEMD_CONF_OPTS += --enable-libcurl
else
SYSTEMD_CONF_OPTS += --disable-libcurl
endif

ifeq ($(BR2_PACKAGE_LIBGCRYPT),y)
SYSTEMD_DEPENDENCIES += libgcrypt
SYSTEMD_CONF_OPTS += \
	--enable-gcrypt	\
	--with-libgcrypt-prefix=$(STAGING_DIR)/usr \
	--with-libgpg-error-prefix=$(STAGING_DIR)/usr
else
SYSTEMD_CONF_OPTS += --disable-gcrypt
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_JOURNAL_GATEWAY),y)
SYSTEMD_DEPENDENCIES += libmicrohttpd
SYSTEMD_CONF_OPTS += --enable-microhttpd
else
SYSTEMD_CONF_OPTS += --disable-microhttpd
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_HWDB),y)
SYSTEMD_CONF_OPTS += --enable-hwdb
else
SYSTEMD_CONF_OPTS += --disable-hwdb
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_BINFMT),y)
SYSTEMD_CONF_OPTS += --enable-binfmt
else
SYSTEMD_CONF_OPTS += --disable-binfmt
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_VCONSOLE),y)
SYSTEMD_CONF_OPTS += --enable-vconsole
else
SYSTEMD_CONF_OPTS += --disable-vconsole
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_BOOTCHART),y)
SYSTEMD_CONF_OPTS += --enable-bootchart
else
SYSTEMD_CONF_OPTS += --disable-bootchart
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_QUOTACHECK),y)
SYSTEMD_CONF_OPTS += --enable-quotacheck
else
SYSTEMD_CONF_OPTS += --disable-quotacheck
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_NETWORKD),y)
SYSTEMD_CONF_OPTS += --enable-networkd
define SYSTEMD_INSTALL_RESOLVCONF_HOOK
	ln -sf ../run/systemd/resolve/resolv.conf \
		$(TARGET_DIR)/etc/resolv.conf
endef
else
SYSTEMD_CONF_OPTS += --disable-networkd
define SYSTEMD_INSTALL_SERVICE_NETWORK
	$(INSTALL) -D -m 644 package/systemd/network.service \
		$(TARGET_DIR)/etc/systemd/system/network.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../network.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/network.service
endef
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_TIMESYNCD),y)
SYSTEMD_CONF_OPTS += --enable-timesyncd
define SYSTEMD_INSTALL_SERVICE_TIMESYNC
	mkdir -p $(TARGET_DIR)/etc/systemd/system/sysinit.target.wants
	ln -sf ../../../../lib/systemd/system/systemd-timesyncd.service \
		$(TARGET_DIR)/etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service
endef
else
SYSTEMD_CONF_OPTS += --disable-timesyncd
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SMACK_SUPPORT),y)
SYSTEMD_CONF_OPTS += --enable-smack
else
SYSTEMD_CONF_OPTS += --disable-smack
endif

# mq_getattr needs -lrt
SYSTEMD_MAKE_OPTS += LIBS=-lrt
SYSTEMD_MAKE_OPTS += LDFLAGS+=-ldl

define SYSTEMD_INSTALL_INIT_HOOK
	ln -fs ../lib/systemd/systemd $(TARGET_DIR)/sbin/init
	ln -fs ../bin/systemctl $(TARGET_DIR)/sbin/halt
	ln -fs ../bin/systemctl $(TARGET_DIR)/sbin/poweroff
	ln -fs ../bin/systemctl $(TARGET_DIR)/sbin/reboot

	ln -fs ../../../lib/systemd/system/multi-user.target \
		$(TARGET_DIR)/etc/systemd/system/default.target
endef

define SYSTEMD_INSTALL_MACHINEID_HOOK
	touch $(TARGET_DIR)/etc/machine-id
endef

SYSTEMD_POST_INSTALL_TARGET_HOOKS += \
	SYSTEMD_INSTALL_INIT_HOOK \
	SYSTEMD_INSTALL_MACHINEID_HOOK \
	SYSTEMD_INSTALL_RESOLVCONF_HOOK

define SYSTEMD_USERS
	systemd-journal -1 systemd-journal -1 * /var/log/journal - - Journal
	systemd-journal-gateway -1 systemd-journal-gateway -1 * /var/log/journal - - Journal Gateway
	systemd-journal-remote -1 systemd-journal-remote -1 * /var/log/journal/remote - - Journal Remote
	systemd-journal-upload -1 systemd-journal-upload -1 * - - - Journal Upload
	systemd-resolve -1 systemd-resolve -1 * - - - Network Name Resolution Manager
	systemd-bus-proxy -1 systemd-bus-proxy -1 * - - - Proxy D-Bus messages to/from a bus
	systemd-timesync -1 systemd-timesync -1 * - - - Network Time Synchronization
	systemd-network -1 systemd-network -1 * - - - Network Manager
	- - input -1 * - - - Input device group
endef

define SYSTEMD_DISABLE_SERVICE_TTY1
	rm -f $(TARGET_DIR)/etc/systemd/system/getty.target.wants/getty@tty1.service
endef

ifneq ($(call qstrip,$(BR2_TARGET_GENERIC_GETTY_PORT)),)
# systemd needs getty.service for VTs and serial-getty.service for serial ttys
# also patch the file to use the correct baud-rate, the default baudrate is 115200 so look for that
define SYSTEMD_INSTALL_SERVICE_TTY
	if echo $(BR2_TARGET_GENERIC_GETTY_PORT) | egrep -q 'tty[0-9]*$$'; \
	then \
		SERVICE="getty"; \
	else \
		SERVICE="serial-getty"; \
	fi; \
	ln -fs ../../../../lib/systemd/system/$${SERVICE}@.service \
		$(TARGET_DIR)/etc/systemd/system/getty.target.wants/$${SERVICE}@$(BR2_TARGET_GENERIC_GETTY_PORT).service; \
	if [ $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_BAUDRATE)) -gt 0 ] ; \
	then \
		$(SED) 's,115200,$(BR2_TARGET_GENERIC_GETTY_BAUDRATE),' $(TARGET_DIR)/lib/systemd/system/$${SERVICE}@.service; \
	fi
endef
endif

define SYSTEMD_INSTALL_INIT_SYSTEMD
	$(SYSTEMD_DISABLE_SERVICE_TTY1)
	$(SYSTEMD_INSTALL_SERVICE_TTY)
	$(SYSTEMD_INSTALL_SERVICE_NETWORK)
	$(SYSTEMD_INSTALL_SERVICE_TIMESYNC)
endef

$(eval $(autotools-package))
