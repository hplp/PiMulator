################################################################################
#
# perl-datetime-tiny
#
################################################################################

PERL_DATETIME_TINY_VERSION = 1.04
PERL_DATETIME_TINY_SOURCE = DateTime-Tiny-$(PERL_DATETIME_TINY_VERSION).tar.gz
PERL_DATETIME_TINY_SITE = $(BR2_CPAN_MIRROR)/authors/id/A/AD/ADAMK
PERL_DATETIME_TINY_LICENSE = Artistic or GPLv1+
PERL_DATETIME_TINY_LICENSE_FILES = LICENSE

$(eval $(perl-package))
