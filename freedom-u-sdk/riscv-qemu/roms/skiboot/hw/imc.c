/* Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define pr_fmt(fmt)  "IMC: " fmt
#include <skiboot.h>
#include <xscom.h>
#include <imc.h>
#include <chip.h>
#include <libxz/xz.h>
#include <device.h>

/*
 * Nest IMC PMU names along with their bit values as represented in the
 * imc_chip_avl_vector(in struct imc_chip_cb, look at include/imc.h).
 * nest_pmus[] is an array containing all the possible nest IMC PMU node names.
 */
char const *nest_pmus[] = {
	"powerbus0",
	"mcs0",
	"mcs1",
	"mcs2",
	"mcs3",
	"mcs4",
	"mcs5",
	"mcs6",
	"mcs7",
	"mba0",
	"mba1",
	"mba2",
	"mba3",
	"mba4",
	"mba5",
	"mba6",
	"mba7",
	"cen0",
	"cen1",
	"cen2",
	"cen3",
	"cen4",
	"cen5",
	"cen6",
	"cen7",
	"xlink0",
	"xlink1",
	"xlink2",
	"mcd0",
	"mcd1",
	"phb0",
	"phb1",
	"phb2",
	"phb3",
	"phb4",
	"phb5",
	"nx",
	"capp0",
	"capp1",
	"vas",
	"int",
	"alink0",
	"alink1",
	"alink2",
	"alink3",
	"nvlink0",
	"nvlink1",
	"nvlink2",
	"nvlink3",
	"nvlink4",
	"nvlink5",
	/* reserved bits : 51 - 63 */
};

/*
 * Due to Nest HW/OCC restriction, microcode will not support individual unit
 * events for these nest units mcs0, mcs1 ... mcs7 in the accumulation mode.
 * And events to monitor each mcs units individually will be supported only
 * in the debug mode (which will be supported by microcode in the future).
 * These will be advertised only when OPAL provides interface for the it.
 */
char const *debug_mode_units[] = {
	"mcs0",
	"mcs1",
	"mcs2",
	"mcs3",
	"mcs4",
	"mcs5",
	"mcs6",
	"mcs7",
};

/*
 * Combined unit node events are counted when any of the individual
 * unit is enabled in the availability vector. That is,
 * ex, mcs01 unit node should be enabled only when mcs0 or mcs1 enabled.
 * mcs23 unit node should be enabled only when mcs2 or mcs3 is enabled
 */
static struct combined_units_node cu_node[] = {
	{ .name = "mcs01", .unit1 = PPC_BIT(1), .unit2 = PPC_BIT(2) },
	{ .name = "mcs23", .unit1 = PPC_BIT(3), .unit2 = PPC_BIT(4) },
	{ .name = "mcs45", .unit1 = PPC_BIT(5), .unit2 = PPC_BIT(6) },
	{ .name = "mcs67", .unit1 = PPC_BIT(7), .unit2 = PPC_BIT(8) },
};

static char *compress_buf;
static size_t compress_buf_size;
const char **prop_to_fix(struct dt_node *node);
const char *props_to_fix[] = {"events", NULL};

static bool is_nest_mem_initialized(struct imc_chip_cb *ptr)
{
	/*
	 * Non zero value in "Status" field indicate memory initialized.
	 */
	if (!ptr->imc_chip_run_status)
		return false;

	return true;
}

/*
 * A Quad contains 4 cores in Power 9, and there are 4 addresses for
 * the Core Hardware Trace Macro (CHTM) attached to each core.
 * So, for core index 0 to core index 3, we have a sequential range of
 * SCOM port addresses in the arrays below, each for Hardware Trace Macro (HTM)
 * mode and PDBAR.
 */
unsigned int pdbar_scom_index[] = {
	0x1001220B,
	0x1001230B,
	0x1001260B,
	0x1001270B
};
unsigned int htm_scom_index[] = {
	0x10012200,
	0x10012300,
	0x10012600,
	0x10012700
};

static struct imc_chip_cb *get_imc_cb(uint32_t chip_id)
{
	struct proc_chip *chip = get_chip(chip_id);
	struct imc_chip_cb *cb;

	cb = (struct imc_chip_cb *)(chip->homer_base + P9_CB_STRUCT_OFFSET);
	if (!is_nest_mem_initialized(cb))
		return NULL;

	return cb;
}

static void pause_microcode_at_boot(void)
{
	struct proc_chip *chip;
	struct imc_chip_cb *cb;

	for_each_chip(chip) {
		cb = get_imc_cb(chip->id);
		if (cb)
			cb->imc_chip_command =  cpu_to_be64(NEST_IMC_DISABLE);
	}
}

/*
 * Decompresses the blob obtained from the IMC pnor sub-partition
 * in "src" of size "src_size", assigns the uncompressed device tree
 * binary to "dst" and returns.
 *
 * Returns 0 on success and -1 on error.
 *
 * TODO: Ideally this should be part of generic subpartition load
 * infrastructure. And decompression can be queued as another CPU job
 */
static int decompress(void *dst, size_t dst_size, void *src, size_t src_size)
{
	struct xz_dec *s;
	struct xz_buf b;
	int ret = 0;

	/* Initialize the xz library first */
	xz_crc32_init();
	s = xz_dec_init(XZ_SINGLE, 0);
	if (s == NULL) {
		prerror("initialization error for xz\n");
		return -1;
	}

	/*
	 * Source address : src
	 * Source size : src_size
	 * Destination address : dst
	 * Destination size : dst_src
	 */
	b.in = src;
	b.in_pos = 0;
	b.in_size = src_size;
	b.out = dst;
	b.out_pos = 0;
	b.out_size = dst_size;

	/* Start decompressing */
	ret = xz_dec_run(s, &b);
	if (ret != XZ_STREAM_END) {
		prerror("failed to decompress subpartition\n");
		ret = -1;
		goto err;
	}

	return 0;
err:
	/* Clean up memory */
	xz_dec_end(s);
	return ret;
}

/*
 * Function return list of properties names for the fixup
 */
const char **prop_to_fix(struct dt_node *node)
{
	if (dt_node_is_compatible(node, "ibm,imc-counters"))
		return props_to_fix;

	return NULL;
}

/* Helper to get the IMC device type for a device node */
static int get_imc_device_type(struct dt_node *node)
{
	const struct dt_property *type;
	u32 val=0;

	if (!node)
		return -1;

	type = dt_find_property(node, "type");
	if (!type)
		return -1;

	val = dt_prop_get_u32(node, "type");
	switch (val){
	case IMC_COUNTER_CHIP:
		return IMC_COUNTER_CHIP;
	case IMC_COUNTER_CORE:
		return IMC_COUNTER_CORE;
	case IMC_COUNTER_THREAD:
		return IMC_COUNTER_THREAD;
	default:
		break;
	}

	/* Unknown/Unsupported IMC device type */
	return -1;
}

static bool is_nest_node(struct dt_node *node)
{
	if (get_imc_device_type(node) == IMC_COUNTER_CHIP)
		return true;

	return false;
}

static bool is_imc_device_type_supported(struct dt_node *node)
{
	u32 val = get_imc_device_type(node);

	if ((val == IMC_COUNTER_CHIP) || (val == IMC_COUNTER_CORE) ||
						(val == IMC_COUNTER_THREAD))
		return true;

	return false;
}

/*
 * Helper to check for the imc device type in the incoming device tree.
 * Remove unsupported device node.
 */
static void check_imc_device_type(struct dt_node *dev)
{
	struct dt_node *node;

	dt_for_each_compatible(dev, node, "ibm,imc-counters") {
		if (!is_imc_device_type_supported(node)) {
			/*
			 * ah nice, found a device type which I didnt know.
			 * Remove it and also mark node as NULL, since dt_next
			 * will try to fetch info for "prev" which is removed
			 * by dt_free.
			 */
			dt_free(node);
			node = NULL;
		}
	}

	return;
}

/*
 * Remove the PMU device nodes from the incoming new subtree, if they are not
 * available in the hardware. The availability is described by the
 * control block's imc_chip_avl_vector.
 * Each bit represents a device unit. If the device is available, then
 * the bit is set else its unset.
 */
static void disable_unavailable_units(struct dt_node *dev)
{
	uint64_t avl_vec;
	struct imc_chip_cb *cb;
	struct dt_node *target;
	int i;

	/* Fetch the IMC control block structure */
	cb = get_imc_cb(this_cpu()->chip_id);
	if (cb)
		avl_vec = be64_to_cpu(cb->imc_chip_avl_vector);
	else {
		avl_vec = 0; /* Remove only nest imc device nodes */

		/* Incase of mambo, just fake it */
		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			avl_vec = (0xffULL) << 56;
	}

	for (i = 0; i < ARRAY_SIZE(nest_pmus); i++) {
		if (!(PPC_BITMASK(i, i) & avl_vec)) {
			/* Check if the device node exists */
			target = dt_find_by_name(dev, nest_pmus[i]);
			if (!target)
				continue;
			/* Remove the device node */
			dt_free(target);
		}
	}

	/*
	 * Loop to detect debug mode units and remove them
	 * since the microcode does not support debug mode function yet.
	 */
	for (i = 0; i < ARRAY_SIZE(debug_mode_units); i++) {
		target = dt_find_by_name(dev, debug_mode_units[i]);
		if (!target)
			continue;
		/* Remove the device node */
		dt_free(target);
	}

	/*
	 * Based on availability unit vector from control block,
	 * check and enable combined unit nodes in the device tree.
	 */
	for (i = 0; i < MAX_NEST_COMBINED_UNITS ; i++ ) {
		if (!(cu_node[i].unit1 & avl_vec) &&
				!(cu_node[i].unit2 & avl_vec)) {
			target = dt_find_by_name(dev, cu_node[i].name);
			if (!target)
				continue;

			/* Remove the device node */
			dt_free(target);
		}
	}

	return;
}

/*
 * Function to queue the loading of imc catalog data
 * from the IMC pnor partition.
 */
void imc_catalog_preload(void)
{
	uint32_t pvr = (mfspr(SPR_PVR) & ~(0xf0ff));
	int ret = OPAL_SUCCESS;
	compress_buf_size = MAX_COMPRESSED_IMC_DTB_SIZE;

	if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
		return;

	/* Enable only for power 9 */
	if (proc_gen != proc_gen_p9)
		return;

	compress_buf = malloc(MAX_COMPRESSED_IMC_DTB_SIZE);
	if (!compress_buf) {
		prerror("Memory allocation for catalog failed\n");
		return;
	}

	ret = start_preload_resource(RESOURCE_ID_IMA_CATALOG,
					pvr, compress_buf, &compress_buf_size);
	if (ret != OPAL_SUCCESS) {
		prerror("Failed to load IMA_CATALOG: %d\n", ret);
		free(compress_buf);
		compress_buf = NULL;
	}

	return;
}

static void imc_dt_update_nest_node(struct dt_node *dev)
{
	struct proc_chip *chip;
	uint64_t *base_addr = NULL;
	uint32_t *chipids = NULL;
	int i=0, nr_chip = nr_chips();
	struct dt_node *node;
	const struct dt_property *type;
	uint32_t offset = 0, size = 0;
	uint64_t baddr;
	char namebuf[32];

	/* Add the base_addr and chip-id properties for the nest node */
	base_addr = malloc(sizeof(uint64_t) * nr_chip);
	chipids = malloc(sizeof(uint32_t) * nr_chip);
	for_each_chip(chip) {
		base_addr[i] = chip->homer_base;
		chipids[i] = chip->id;
		i++;
	}

	dt_for_each_compatible(dev, node, "ibm,imc-counters") {
		type = dt_find_property(node, "type");
		if (type && is_nest_node(node)) {
			dt_add_property(node, "base-addr", base_addr, (i * sizeof(u64)));
			dt_add_property(node, "chip-id", chipids, (i * sizeof(u32)));
			offset = dt_prop_get_u32(node, "offset");
			size = dt_prop_get_u32(node, "size");
		}
	}

	/*
	 * Enable only if we have active nest pmus.
	 */
	if (!size)
		return;

	node = dt_find_by_name(opal_node, "exports");
	if (!node)
		return;

	for_each_chip(chip) {
		snprintf(namebuf, sizeof(namebuf), "imc_nest_chip_%x", chip->id);
		baddr = chip->homer_base;
		baddr += offset;
		dt_add_property_u64s(node, namebuf, baddr, size);
	}
}

/*
 * Load the IMC pnor partition and find the appropriate sub-partition
 * based on the platform's PVR.
 * Decompress the sub-partition and link the imc device tree to the
 * existing device tree.
 */
void imc_init(void)
{
	void *decompress_buf = NULL;
	uint32_t pvr = (mfspr(SPR_PVR) & ~(0xf0ff));
	struct dt_node *dev;
	int ret;

	if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS) {
		dev = dt_find_compatible_node(dt_root, NULL,
					"ibm,opal-in-memory-counters");
		if (!dev)
			return;

		goto imc_mambo;
	}

	/* Enable only for power 9 */
	if (proc_gen != proc_gen_p9)
		return;

	/* Check we succeeded in starting the preload */
	if (compress_buf == NULL)
		return;

	ret = wait_for_resource_loaded(RESOURCE_ID_IMA_CATALOG, pvr);
	if (ret != OPAL_SUCCESS) {
		prerror("IMC Catalog load failed\n");
		return;
	}

	/*
	 * Flow of the data from PNOR to main device tree:
	 *
	 * PNOR -> compressed local buffer (compress_buf)
	 * compressed local buffer -> decompressed local buf (decompress_buf)
	 * decompress local buffer -> main device tree
	 * free compressed local buffer
	 */

	/*
	 * Memory for decompression.
	 */
	decompress_buf = malloc(MAX_DECOMPRESSED_IMC_DTB_SIZE);
	if (!decompress_buf) {
		prerror("No memory for decompress_buf \n");
		goto err;
	}

	/*
	 * Decompress the compressed buffer
	 */
	ret = decompress(decompress_buf, MAX_DECOMPRESSED_IMC_DTB_SIZE,
				compress_buf, compress_buf_size);
	if (ret < 0)
		goto err;

	/* Create a device tree entry for imc counters */
	dev = dt_new_root("imc-counters");
	if (!dev)
		goto err;

	/*
	 * Attach the new decompress_buf to the imc-counters node.
	 * dt_expand_node() does sanity checks for fdt_header, piggyback
	 */
	ret = dt_expand_node(dev, decompress_buf, 0);
	if (ret < 0) {
		dt_free(dev);
		goto err;
	}

imc_mambo:
	/* Check and remove unsupported imc device types */
	check_imc_device_type(dev);

	/*
	 * Check and remove unsupported nest unit nodes by the microcode,
	 * from the incoming device tree.
	 */
	disable_unavailable_units(dev);

	/* Fix the phandle in the incoming device tree */
	dt_adjust_subtree_phandle(dev, prop_to_fix);

	/* Update the base_addr and chip-id for nest nodes */
	imc_dt_update_nest_node(dev);

	if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
		return;

	/*
	 * IMC nest counters has both in-band (ucode access) and out of band
	 * access to it. Since not all nest counter configurations are supported
	 * by ucode, out of band tools are used to characterize other
	 * configuration.
	 *
	 * If the ucode not paused and OS does not have IMC driver support,
	 * then out to band tools will race with ucode and end up getting
	 * undesirable values. Hence pause the ucode if it is already running.
	 */
	pause_microcode_at_boot();

	/*
	 * If the dt_attach_root() fails, "imc-counters" node will not be
	 * seen in the device-tree and hence OS should not make any
	 * OPAL_IMC_* calls.
	 */
	if (!dt_attach_root(dt_root, dev)) {
		dt_free(dev);
		goto err;
	}

	free(compress_buf);
	return;
err:
	prerror("IMC Devices not added\n");
	free(decompress_buf);
	free(compress_buf);
}

/*
 * opal_imc_counters_init : This call initialize the IMC engine.
 *
 * For Nest IMC, this is no-op and returns OPAL_SUCCESS at this point.
 * For Core IMC, this initializes core IMC Engine, by initializing
 * these scoms "PDBAR", "HTM_MODE" and the "EVENT_MASK" in a given cpu.
 */
static int64_t opal_imc_counters_init(uint32_t type, uint64_t addr, uint64_t cpu_pir)
{
	struct cpu_thread *c = find_cpu_by_pir(cpu_pir);
	int port_id, phys_core_id;

	switch (type) {
	case OPAL_IMC_COUNTERS_NEST:
		return OPAL_SUCCESS;
	case OPAL_IMC_COUNTERS_CORE:
		if (!c)
			return OPAL_PARAMETER;

		/*
		 * Core IMC hardware mandates setting of htm_mode and
		 * pdbar in specific scom ports. port_id are in
		 * pdbar_scom_index[] and htm_scom_index[].
		 */
		phys_core_id = cpu_get_core_index(c);
		port_id = phys_core_id % 4;

		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			return OPAL_SUCCESS;

		/*
		 * Core IMC hardware mandate initing of three scoms
		 * to enbale or disable of the Core IMC engine.
		 *
		 * PDBAR: Scom contains the real address to store per-core
		 *        counter data in memory along with other bits.
		 *
		 * EventMask: Scom contain bits to denote event to multiplex
		 *            at different MSR[HV PR] values, along with bits for
		 *            sampling duration.
		 *
		 * HTM Scom: scom to enable counter data movement to memory.
		 */
		 if (xscom_write(c->chip_id,
				XSCOM_ADDR_P9_EP(phys_core_id,
						pdbar_scom_index[port_id]),
				(u64)(CORE_IMC_PDBAR_MASK & addr))) {
			prerror("error in xscom_write for pdbar\n");
			return OPAL_HARDWARE;
		}

		if (xscom_write(c->chip_id,
				XSCOM_ADDR_P9_EC(phys_core_id,
					 CORE_IMC_EVENT_MASK_ADDR),
				(u64)CORE_IMC_EVENT_MASK)) {
			prerror("error in xscom_write for event mask\n");
			return OPAL_HARDWARE;
		}

		if (xscom_write(c->chip_id,
				XSCOM_ADDR_P9_EP(phys_core_id,
						htm_scom_index[port_id]),
				(u64)CORE_IMC_HTM_MODE_DISABLE)) {
			prerror("error in xscom_write for htm mode\n");
			return OPAL_HARDWARE;
		}
		return OPAL_SUCCESS;
	}

	return OPAL_SUCCESS;
}
opal_call(OPAL_IMC_COUNTERS_INIT, opal_imc_counters_init, 3);

/* opal_imc_counters_control_start: This call starts the nest/core imc engine. */
static int64_t opal_imc_counters_start(uint32_t type, uint64_t cpu_pir)
{
	u64 op;
	struct cpu_thread *c = find_cpu_by_pir(cpu_pir);
	struct imc_chip_cb *cb;
	int port_id, phys_core_id;

	if (!c)
		return OPAL_PARAMETER;

	switch (type) {
	case OPAL_IMC_COUNTERS_NEST:
		/* Fetch the IMC control block structure */
		cb = get_imc_cb(c->chip_id);
		if (!cb)
			return OPAL_HARDWARE;

		/* Set the run command */
		op = NEST_IMC_ENABLE;

		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			return OPAL_SUCCESS;

		/* Write the command to the control block now */
		cb->imc_chip_command = cpu_to_be64(op);

		return OPAL_SUCCESS;
	case OPAL_IMC_COUNTERS_CORE:
		/*
		 * Core IMC hardware mandates setting of htm_mode in specific
		 * scom ports (port_id are in htm_scom_index[])
		 */
		phys_core_id = cpu_get_core_index(c);
		port_id = phys_core_id % 4;

		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			return OPAL_SUCCESS;

		/*
		 * Enables the core imc engine by appropriately setting
		 * bits 4-9 of the HTM_MODE scom port. No initialization
		 * is done in this call. This just enables the the counters
		 * to count with the previous initialization.
		 */
		if (xscom_write(c->chip_id,
				XSCOM_ADDR_P9_EP(phys_core_id,
						htm_scom_index[port_id]),
				(u64)CORE_IMC_HTM_MODE_ENABLE)) {
			prerror("IMC OPAL_start: error in xscom_write for htm_mode\n");
			return OPAL_HARDWARE;
		}

		return OPAL_SUCCESS;
	}

	return OPAL_SUCCESS;
}
opal_call(OPAL_IMC_COUNTERS_START, opal_imc_counters_start, 2);

/* opal_imc_counters_control_stop: This call stops the nest imc engine. */
static int64_t opal_imc_counters_stop(uint32_t type, uint64_t cpu_pir)
{
	u64 op;
	struct imc_chip_cb *cb;
	struct cpu_thread *c = find_cpu_by_pir(cpu_pir);
	int port_id, phys_core_id;

	if (!c)
		return OPAL_PARAMETER;

	switch (type) {
	case OPAL_IMC_COUNTERS_NEST:
		/* Fetch the IMC control block structure */
		cb = get_imc_cb(c->chip_id);
		if (!cb)
			return OPAL_HARDWARE;

		/* Set the run command */
		op = NEST_IMC_DISABLE;

		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			return OPAL_SUCCESS;

		/* Write the command to the control block */
		cb->imc_chip_command = cpu_to_be64(op);

		return OPAL_SUCCESS;

	case OPAL_IMC_COUNTERS_CORE:
		/*
		 * Core IMC hardware mandates setting of htm_mode in specific
		 * scom ports (port_id are in htm_scom_index[])
		 */
		phys_core_id = cpu_get_core_index(c);
		port_id = phys_core_id % 4;

		if (proc_chip_quirks & QUIRK_MAMBO_CALLOUTS)
			return OPAL_SUCCESS;

		/*
		 * Disables the core imc engine by clearing
		 * bits 4-9 of the HTM_MODE scom port.
		 */
		if (xscom_write(c->chip_id,
				XSCOM_ADDR_P9_EP(phys_core_id,
						htm_scom_index[port_id]),
				(u64) CORE_IMC_HTM_MODE_DISABLE)) {
			prerror("error in xscom_write for htm_mode\n");
			return OPAL_HARDWARE;
		}

		return OPAL_SUCCESS;
	}

	return OPAL_SUCCESS;
}
opal_call(OPAL_IMC_COUNTERS_STOP, opal_imc_counters_stop, 2);
