################################################################################
#
# gst1-imx
#
################################################################################

GST1_IMX_VERSION = 0.12.1
GST1_IMX_SITE = $(call github,Freescale,gstreamer-imx,$(GST1_IMX_VERSION))

GST1_IMX_LICENSE = LGPLv2+
GST1_IMX_LICENSE_FILES = LICENSE

GST1_IMX_INSTALL_STAGING = YES

GST1_IMX_DEPENDENCIES += \
	host-pkgconf \
	host-python \
	gstreamer1 \
	gst1-plugins-base

GST1_IMX_CONF_OPTS = --prefix="/usr"

ifeq ($(BR2_LINUX_KERNEL),y)
# IPU and PXP need access to imx-specific kernel headers
GST1_IMX_DEPENDENCIES += linux
GST1_IMX_CONF_OPTS += --kernel-headers="$(LINUX_DIR)/include"
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD),y)
GST1_IMX_DEPENDENCIES += gst1-plugins-bad
endif

ifeq ($(BR2_PACKAGE_IMX_CODEC),y)
GST1_IMX_DEPENDENCIES += imx-codec
endif

ifeq ($(BR2_PACKAGE_LIBIMXVPUAPI),y)
GST1_IMX_DEPENDENCIES += libimxvpuapi
endif

ifeq ($(BR2_PACKAGE_IMX_GPU_VIV),y)
GST1_IMX_DEPENDENCIES += imx-gpu-viv
ifeq ($(BR2_PACKAGE_XLIB_LIBX11),y)
GST1_IMX_DEPENDENCIES += xlib_libX11
GST1_IMX_CONF_OPTS += --egl-platform=x11
else
ifeq ($(BR2_PACKAGE_WAYLAND),y)
GST1_IMX_DEPENDENCIES += wayland
GST1_IMX_CONF_OPTS += --egl-platform=wayland
else
GST1_IMX_CONF_OPTS += --egl-platform=fb
endif
endif
endif

define GST1_IMX_CONFIGURE_CMDS
	cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		$(HOST_DIR)/usr/bin/python2 ./waf configure $(GST1_IMX_CONF_OPTS)
endef

define GST1_IMX_BUILD_CMDS
	cd $(@D); \
		$(HOST_DIR)/usr/bin/python2 ./waf build -j $(PARALLEL_JOBS)
endef

define GST1_IMX_INSTALL_TARGET_CMDS
	cd $(@D); \
		$(HOST_DIR)/usr/bin/python2 ./waf --destdir=$(TARGET_DIR) \
		install
endef

$(eval $(generic-package))
