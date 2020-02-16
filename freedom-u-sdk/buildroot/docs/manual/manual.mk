################################################################################
#
# The Buildroot manual
#
################################################################################

MANUAL_SOURCES = $(sort $(wildcard docs/manual/*.txt) $(wildcard docs/images/*))
MANUAL_RESOURCES = $(TOPDIR)/docs/images

# Our manual needs to generate lists
define MANUAL_GEN_LISTS
	$(Q)$(call MESSAGE,"Updating the manual lists...")
	$(Q)$(COMMON_CONFIG_ENV) \
		BR2_DEFCONFIG="" \
		TOPDIR=$(TOPDIR) \
		O=$(@D) \
		python -B $(TOPDIR)/support/scripts/gen-manual-lists.py
endef
MANUAL_POST_RSYNC_HOOKS += MANUAL_GEN_LISTS

# Our list-generating script requires argparse
define MANUAL_CHECK_LISTS_DEPS
	$(Q)if ! python -c "import argparse" >/dev/null 2>&1 ; then \
		echo "You need python with argparse on your host to generate" \
			"the list of packages in the manual"; \
		exit 1; \
	fi
endef
MANUAL_CHECK_DEPENDENCIES_HOOKS += MANUAL_CHECK_LISTS_DEPS

$(eval $(call asciidoc-document))
