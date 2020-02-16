/* Copyright 2013-2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <skiboot.h>
#include <opal-api.h>

struct flash_hostboot_toc {
	be32 ec;
	be32 offset; /* From start of header.  4K aligned */
	be32 size;
};
#define FLASH_HOSTBOOT_TOC_MAX_ENTRIES ((FLASH_SUBPART_HEADER_SIZE - 8) \
		/sizeof(struct flash_hostboot_toc))

struct flash_hostboot_header {
	char eyecatcher[4];
	be32 version;
	struct flash_hostboot_toc toc[FLASH_HOSTBOOT_TOC_MAX_ENTRIES];
};

int flash_subpart_info(void *part_header, uint32_t header_len,
		       uint32_t part_size, uint32_t *part_actual,
		       uint32_t subid, uint32_t *offset, uint32_t *size)
{
	struct flash_hostboot_header *header;
	char eyecatcher[5];
	uint32_t i, ec, o, s;
	bool subpart_found;

	if (!part_header || ( !offset && !size && !part_actual)) {
		prlog(PR_ERR, "FLASH: invalid parameters: ph %p of %p sz %p "
		      "tsz %p\n", part_header, offset, size, part_actual);
		return OPAL_PARAMETER;
	}

	if (header_len < FLASH_SUBPART_HEADER_SIZE) {
		prlog(PR_ERR, "FLASH: subpartition header too small 0x%x\n",
		      header_len);
		return OPAL_PARAMETER;
	}

	header = (struct flash_hostboot_header*) part_header;

	/* Perform sanity */
	i = be32_to_cpu(header->version);
	if (i != 1) {
		prerror("FLASH: flash subpartition TOC version unknown %i\n", i);
		return OPAL_RESOURCE;
	}

	/* NULL terminate eyecatcher */
	strncpy(eyecatcher, header->eyecatcher, 4);
	eyecatcher[4] = '\0';
	prlog(PR_DEBUG, "FLASH: flash subpartition eyecatcher %s\n",
	      eyecatcher);

	subpart_found = false;
	*part_actual = 0;
	for (i = 0; i < FLASH_HOSTBOOT_TOC_MAX_ENTRIES; i++) {

		ec = be32_to_cpu(header->toc[i].ec);
		o = be32_to_cpu(header->toc[i].offset);
		s = be32_to_cpu(header->toc[i].size);

		/* Check for null terminating entry */
		if (!ec && !o && !s)
			break;

		/* Sanity check the offset and size. */
		if (o + s > part_size) {
			prerror("FLASH: flash subpartition too big: %i\n", i);
			return OPAL_RESOURCE;
		}
		if (!s) {
			prerror("FLASH: flash subpartition zero size: %i\n", i);
			return OPAL_RESOURCE;
		}
		if (o < FLASH_SUBPART_HEADER_SIZE) {
			prerror("FLASH: flash subpartition offset too small: "
			        "%i\n", i);
			return OPAL_RESOURCE;
		}
		/*
		 * Subpartitions content are different, but multiple toc entries
		 * may point to the same subpartition.
		 */
		if (ALIGN_UP(o + s, FLASH_SUBPART_HEADER_SIZE) > *part_actual)
			*part_actual = ALIGN_UP(o + s, FLASH_SUBPART_HEADER_SIZE);

		if (ec == subid) {
			if (offset)
				*offset += o;
			if (size)
				*size = s;
			subpart_found = true;
		}
	}
	if (!subpart_found && (offset || size)) {
		prerror("FLASH: flash subpartition not found.\n");
		return OPAL_RESOURCE;
	}
	return OPAL_SUCCESS;
}
