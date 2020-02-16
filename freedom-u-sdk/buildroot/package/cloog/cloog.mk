################################################################################
#
# cloog
#
################################################################################

CLOOG_VERSION = 0.18.4
CLOOG_SITE = http://www.bastoul.net/cloog/pages/download
CLOOG_LICENSE = LGPLv2.1+
CLOOG_DEPENDENCIES = gmp isl
# Our libtool patch doesn't apply, and since this package is only
# built for the host, we don't really care about it.
CLOOG_LIBTOOL_PATCH = NO

HOST_CLOOG_CONF_OPTS = --with-isl=system --with-polylib=no

$(eval $(host-autotools-package))
