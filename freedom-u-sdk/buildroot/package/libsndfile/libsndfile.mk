################################################################################
#
# libsndfile
#
################################################################################

LIBSNDFILE_VERSION = 1.0.26
LIBSNDFILE_SITE = http://www.mega-nerd.com/libsndfile/files
LIBSNDFILE_INSTALL_STAGING = YES
LIBSNDFILE_LICENSE = LGPLv2.1+
LIBSNDFILE_LICENSE_FILES = COPYING

$(eval $(autotools-package))
