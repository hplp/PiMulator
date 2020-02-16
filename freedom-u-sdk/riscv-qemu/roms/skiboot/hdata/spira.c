/* Copyright 2013-2017 IBM Corp.
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

#include <device.h>
#include "spira.h"
#include <cpu.h>
#include <vpd.h>
#include <interrupts.h>
#include <ccan/str/str.h>
#include <chip.h>
#include <fsp-mdst-table.h>
#include <fsp-attn.h>
#include <fsp-leds.h>

#include "hdata.h"
#include "hostservices.h"

/* Processor Initialization structure, contains
 * the initial NIA and MSR values for the entry
 * point
 *
 * Note: It appears to be ignoring the entry point
 *       and always going to 0x180
 */

static int cpu_type;

__section(".procin.data") struct proc_init_data proc_init_data = {
	.hdr = HDIF_SIMPLE_HDR("PROCIN", 1, struct proc_init_data),
	.regs_ptr = HDIF_IDATA_PTR(offsetof(struct proc_init_data, regs), 0x10),
	.regs = {
		.nia = CPU_TO_BE64(0x180),
		.msr = CPU_TO_BE64(0x9000000000000000ULL), /* SF | HV */
	},
};

__section(".cpuctrl.data") struct sp_addr_table cpu_ctl_spat_area;
__section(".cpuctrl.data") struct sp_attn_area cpu_ctl_sp_attn_area1;
__section(".cpuctrl.data") struct sp_attn_area cpu_ctl_sp_attn_area2;
__section(".cpuctrl.data") struct hsr_data_area cpu_ctl_hsr_area;

__section(".cpuctrl.data") struct cpu_ctl_init_data cpu_ctl_init_data = {
	.hdr = HDIF_SIMPLE_HDR(CPU_CTL_HDIF_SIG, 2, struct cpu_ctl_init_data),
	.cpu_ctl = HDIF_IDATA_PTR(offsetof(struct cpu_ctl_init_data, cpu_ctl_lt), sizeof(struct cpu_ctl_legacy_table)),
#if !defined(TEST)
	.cpu_ctl_lt = {
		.spat = {
			.addr = CPU_TO_BE64((unsigned long)&(cpu_ctl_spat_area) + SKIBOOT_BASE),
			.size = CPU_TO_BE64(sizeof(struct sp_addr_table)),
		},
		.sp_attn_area1 = {
			.addr = CPU_TO_BE64((unsigned long)&(cpu_ctl_sp_attn_area1) + SKIBOOT_BASE),
			.size = CPU_TO_BE64(sizeof(struct sp_attn_area)),
		},
		.sp_attn_area2 = {
			.addr = CPU_TO_BE64((unsigned long)&(cpu_ctl_sp_attn_area2) + SKIBOOT_BASE),
			.size = CPU_TO_BE64(sizeof(struct sp_attn_area)),
		},
		.hsr_area = {
			.addr = CPU_TO_BE64((unsigned long)&(cpu_ctl_hsr_area) + SKIBOOT_BASE),
			.size = CPU_TO_BE64(sizeof(struct hsr_data_area)),
		},
	},
#endif
};

/* Populate MDST table
 *
 * Note that we only pass sapphire console buffer here so that we can
 * capture early failure logs. Later dump component (fsp_dump_mdst_init)
 * creates new table with all the memory sections we are interested and
 * sends updated table to FSP via MBOX.
 *
 * To help the FSP distinguishing between TCE tokens and actual physical
 * addresses, we set the top bit to 1 on physical addresses
 */
#define ADDR_TOP_BIT	(1ul << 63)

__section(".mdst.data") struct dump_mdst_table init_mdst_table[2] = {
	{
		.addr = CPU_TO_BE64(INMEM_CON_START | ADDR_TOP_BIT),
		.type = CPU_TO_BE32(DUMP_REGION_CONSOLE),
		.size = CPU_TO_BE32(INMEM_CON_LEN),
	},
	{
		.addr = CPU_TO_BE64(HBRT_CON_START | ADDR_TOP_BIT),
		.type = CPU_TO_BE32(DUMP_REGION_HBRT_LOG),
		.size = CPU_TO_BE32(HBRT_CON_LEN),
	},
};

/* SP Interface Root Array, aka SPIRA */
__section(".spira.data") struct spira spira = {
	.hdr = HDIF_SIMPLE_HDR("SPIRA ", SPIRA_VERSION, struct spira),
	.ntuples_ptr = HDIF_IDATA_PTR(offsetof(struct spira, ntuples),
				      sizeof(struct spira_ntuples)),
	.ntuples = {
		.array_hdr = {
			.offset		= CPU_TO_BE32(HDIF_ARRAY_OFFSET),
			.ecnt		= CPU_TO_BE32(SPIRA_NTUPLES_COUNT),
			.esize
				= CPU_TO_BE32(sizeof(struct spira_ntuple)),
			.eactsz		= CPU_TO_BE32(0x18),
		},
		/* We only populate some n-tuples */
		.proc_init = {
			.addr  		= CPU_TO_BE64(PROCIN_OFF),
			.alloc_cnt	= CPU_TO_BE16(1),
			.act_cnt	= CPU_TO_BE16(1),
			.alloc_len
			= CPU_TO_BE32(sizeof(struct proc_init_data)),
		},
		.heap = {
			.addr		= CPU_TO_BE64(SPIRA_HEAP_BASE),
			.alloc_cnt	= CPU_TO_BE16(1),
			.alloc_len	= CPU_TO_BE32(SPIRA_HEAP_SIZE),
		},
		.mdump_src = {
			.addr		= CPU_TO_BE64(MDST_TABLE_OFF),
			.alloc_cnt	= CPU_TO_BE16(ARRAY_SIZE(init_mdst_table)),
			.act_cnt	= CPU_TO_BE16(ARRAY_SIZE(init_mdst_table)),
			.alloc_len	=
				CPU_TO_BE32(sizeof(init_mdst_table)),
		},
#if !defined(TEST)
		.cpu_ctrl = {
			.addr		= CPU_TO_BE64((unsigned long)&cpu_ctl_init_data),
			.alloc_cnt	= CPU_TO_BE16(1),
			.act_cnt	= CPU_TO_BE16(1),
			.alloc_len	=
					CPU_TO_BE32(sizeof(cpu_ctl_init_data)),
		},
#endif
	},
};

/* The Hypervisor SPIRA-H Structure */
__section(".spirah.data") struct spirah spirah = {
	.hdr = HDIF_SIMPLE_HDR(SPIRAH_HDIF_SIG, SPIRAH_VERSION, struct spirah),
	.ntuples_ptr = HDIF_IDATA_PTR(offsetof(struct spirah, ntuples),
				      sizeof(struct spirah_ntuples)),
	.ntuples = {
		.array_hdr = {
			.offset		= CPU_TO_BE32(HDIF_ARRAY_OFFSET),
			.ecnt		= CPU_TO_BE32(SPIRAH_NTUPLES_COUNT),
			.esize
				= CPU_TO_BE32(sizeof(struct spira_ntuple)),
			.eactsz		= CPU_TO_BE32(0x18),
		},
		/* Host Data Areas */
		.hs_data_area = {
			.addr		= CPU_TO_BE64(SPIRA_HEAP_BASE),
			.alloc_cnt	= CPU_TO_BE16(1),
			.alloc_len	= CPU_TO_BE32(SPIRA_HEAP_SIZE),
		},
		/* We only populate some n-tuples */
		.proc_init = {
			.addr		= CPU_TO_BE64(PROCIN_OFF),
			.alloc_cnt	= CPU_TO_BE16(1),
			.act_cnt	= CPU_TO_BE16(1),
			.alloc_len
			= CPU_TO_BE32(sizeof(struct proc_init_data)),
		},
#if !defined(TEST)
		.cpu_ctrl = {
			.addr		= CPU_TO_BE64((unsigned long)&cpu_ctl_init_data),
			.alloc_cnt	= CPU_TO_BE16(1),
			.act_cnt	= CPU_TO_BE16(1),
			.alloc_len	=
					CPU_TO_BE32(sizeof(cpu_ctl_init_data)),
		},
#endif
		.mdump_src = {
			.addr		= CPU_TO_BE64(MDST_TABLE_OFF),
			.alloc_cnt	= CPU_TO_BE16(ARRAY_SIZE(init_mdst_table)),
			.act_cnt	= CPU_TO_BE16(ARRAY_SIZE(init_mdst_table)),
			.alloc_len	=
				CPU_TO_BE32(sizeof(init_mdst_table)),
		},
	},
};

/* The service processor SPIRA-S structure */
struct spiras *spiras;

/* Overridden for testing. */
#ifndef spira_check_ptr
bool spira_check_ptr(const void *ptr, const char *file, unsigned int line)
{
	if (!ptr)
		return false;
	if (((unsigned long)ptr) >= SPIRA_HEAP_BASE &&
	    ((unsigned long)ptr) < (SPIRA_HEAP_BASE + SPIRA_HEAP_SIZE))
		return true;

	prerror("SPIRA: Bad pointer %p at %s line %d\n", ptr, file, line);
	return false;
}
#endif

struct HDIF_common_hdr *__get_hdif(struct spira_ntuple *n, const char id[],
				   const char *file, int line)
{
	struct HDIF_common_hdr *h = ntuple_addr(n);
	if (!spira_check_ptr(h, file, line))
		return NULL;

	if (!HDIF_check(h, id)) {
		prerror("SPIRA: bad tuple %p: expected %s at %s line %d\n",
			h, id, file, line);
		return NULL;
	}
	return h;
}

static struct dt_node *add_xscom_node(uint64_t base, uint32_t hw_id,
				      uint32_t proc_chip_id)
{
	struct dt_node *node;
	uint64_t addr, size;
	uint64_t freq;

	switch (proc_gen) {
	case proc_gen_p7:
	case proc_gen_p8:
		/* On P7 and P8 all the chip SCOMs share single region */
		addr = base | ((uint64_t)hw_id << PPC_BITLSHIFT(28));
		break;
	case proc_gen_p9:
	default:
		/* On P9 we need to put the chip ID in the natural powerbus
		 * position.
		 */
		addr = base | (((uint64_t)hw_id) << 42);
		break;
	};

	size = (u64)1 << PPC_BITLSHIFT(28);

	prlog(PR_INFO, "XSCOM: Found HW ID 0x%x (PCID 0x%x) @ 0x%llx\n",
	       hw_id, proc_chip_id, (long long)addr);

	node = dt_new_addr(dt_root, "xscom", addr);
	if (!node)
		return NULL;

	dt_add_property_cells(node, "ibm,chip-id", hw_id);
	dt_add_property_cells(node, "ibm,proc-chip-id", proc_chip_id);
	dt_add_property_cells(node, "#address-cells", 1);
	dt_add_property_cells(node, "#size-cells", 1);
	dt_add_property(node, "scom-controller", NULL, 0);

	switch(proc_gen) {
	case proc_gen_p7:
		dt_add_property_strings(node, "compatible",
					"ibm,xscom", "ibm,power7-xscom");
		break;
	case proc_gen_p8:
		dt_add_property_strings(node, "compatible",
					"ibm,xscom", "ibm,power8-xscom");
		break;
	case proc_gen_p9:
		dt_add_property_strings(node, "compatible",
					"ibm,xscom", "ibm,power9-xscom");
		break;
	default:
		dt_add_property_strings(node, "compatible", "ibm,xscom");
	}
	dt_add_property_u64s(node, "reg", addr, size);

	/* Derive bus frquency */
	freq = dt_prop_get_u64_def(dt_root, "nest-frequency", 0);
	freq /= 4;
	if (freq)
		dt_add_property_u64(node, "bus-frequency", freq);

	return node;
}

/*
 * Given a xscom@ node this will return a pointer into the SPPCRD
 * structure corresponding to that node
 */
#define GET_HDIF_HDR -1
static const void *xscom_to_pcrd(struct dt_node *xscom, int idata_index)
{
	struct spira_ntuple *t = &spira.ntuples.proc_chip;
	const struct HDIF_common_hdr *hdif;
	const void *idata;
	unsigned int size;
	uint32_t i;
	void *base;

	i = dt_prop_get_u32_def(xscom, DT_PRIVATE "sppcrd-index", 0xffffffff);
	if (i == 0xffffffff)
		return NULL;

	base = get_hdif(t, "SPPCRD");
	assert(base);
	assert(i < be16_to_cpu(t->act_cnt));

	hdif = base + i * be32_to_cpu(t->alloc_len);
	assert(hdif);

	if (idata_index == GET_HDIF_HDR)
		return hdif;

	idata = HDIF_get_idata(hdif, idata_index, &size);
	if (!idata || !size)
		return NULL;

	return idata;
}

struct dt_node *find_xscom_for_chip(uint32_t chip_id)
{
	struct dt_node *node;
	uint32_t id;

	dt_for_each_compatible(dt_root, node, "ibm,xscom") {
		id = dt_get_chip_id(node);
		if (id == chip_id)
			return node;
	}

	return NULL;
}

static void add_psihb_node(struct dt_node *np)
{
	u32 psi_scom, psi_slen;
	const char *psi_comp;

	/*
	 * We add a few things under XSCOM that aren't added
	 * by any other HDAT path
	 */

	/* PSI host bridge */
	switch(proc_gen) {
	case proc_gen_p7:
		psi_scom = 0x2010c00;
		psi_slen = 0x10;
		psi_comp = "ibm,power7-psihb-x";
		break;
	case proc_gen_p8:
		psi_scom = 0x2010900;
		psi_slen = 0x20;
		psi_comp = "ibm,power8-psihb-x";
		break;
	case proc_gen_p9:
		psi_scom = 0x5012900;
		psi_slen = 0x100;
		psi_comp = "ibm,power9-psihb-x";
		break;
	default:
		psi_comp = NULL;
	}
	if (psi_comp) {
		struct dt_node *psi_np;

		psi_np = dt_new_addr(np, "psihb", psi_scom);
		if (!psi_np)
			return;

		dt_add_property_cells(psi_np, "reg", psi_scom, psi_slen);
		dt_add_property_strings(psi_np, "compatible", psi_comp,
					"ibm,psihb-x");
	}
}

static void add_xive_node(struct dt_node *np)
{
	struct dt_node *xive = dt_new_addr(np, "xive", 0x5013000);

	dt_add_property_cells(xive, "reg", 0x5013000, 0x300);
	dt_add_property_string(xive, "compatible", "ibm,power9-xive-x");

	/* HACK: required for simics */
	dt_add_property(xive, "force-assign-bars", NULL, 0);
}

/*
 * SCOM Base Address from P9 SCOM Assignment spreadsheet
 */
#define VAS_SCOM_BASE_ADDR		0x03011800

static void add_vas_node(struct dt_node *np, int idx)
{
	struct  dt_node *vas = dt_new_addr(np, "vas", VAS_SCOM_BASE_ADDR);

	dt_add_property_cells(vas, "reg", VAS_SCOM_BASE_ADDR, 0x300);
	dt_add_property_string(vas, "compatible", "ibm,power9-vas-x");
	dt_add_property_cells(vas, "ibm,vas-id", idx);
}

static void add_ecid_data(const struct HDIF_common_hdr *hdr,
			  struct dt_node *xscom)
{
	char wafer_id[11];
	uint8_t tmp;
	int i;
	uint32_t size = 0;
	struct sppcrd_ecid *ecid;
	const struct HDIF_array_hdr *ec_hdr;

	ec_hdr = HDIF_get_idata(hdr, SPPCRD_IDATA_EC_LEVEL, &size);
	if (!ec_hdr || !size)
		return;

	ecid = (void *)ec_hdr + be32_to_cpu(ec_hdr->offset);
	dt_add_property_u64s(xscom, "ecid", be64_to_cpu(ecid->low),
			     be64_to_cpu(ecid->high));

	/*
	 * bits 4:63 of ECID data contains wafter ID data (ten 6 bit fields
	 * each containing a code).
	 */
	for (i = 0; i < 10; i++) {
		tmp = (u8)((be64_to_cpu(ecid->low) >> (i * 6)) & 0x3f);
		if (tmp <= 9)
			wafer_id[9 - i] = tmp + '0';
		else if (tmp >= 0xA && tmp <= 0x23)
			wafer_id[9 - i] = tmp + '0' + 7;
		else if (tmp == 0x3D)
			wafer_id[9 - i] = '-';
		else if (tmp == 0x3E)
			wafer_id[9 - i] = '.';
		else if (tmp == 0x3F)
			wafer_id[9 - i] = ' ';
		else /* Unknown code */
			wafer_id[9 - i] = tmp + '0';
	}
	wafer_id[10] = '\0';
	dt_add_property_nstr(xscom, "wafer-id", wafer_id, 10);

	dt_add_property_cells(xscom, "wafer-location",
			      (u32)((be64_to_cpu(ecid->high) >> 56) & 0xff),
			      (u32)((be64_to_cpu(ecid->high) >> 48) & 0xff));
}

static void add_xscom_add_pcia_assoc(struct dt_node *np, uint32_t pcid)
{
	const struct HDIF_common_hdr *hdr;
	u32 size;


	/*
	 * The SPPCRD doesn't contain all the affinity data, we have
	 * to dig it out of a core. I assume this is so that node
	 * affinity can be different for groups of cores within the
	 * chip, but for now we are going to ignore that
	 */
	hdr = get_hdif(&spira.ntuples.pcia, SPPCIA_HDIF_SIG);
	if (!hdr)
		return;

	for_each_pcia(hdr) {
		const struct sppcia_core_unique *id;

		id = HDIF_get_idata(hdr, SPPCIA_IDATA_CORE_UNIQUE, &size);
		if (!id || size < sizeof(*id))
			continue;

		if (be32_to_cpu(id->proc_chip_id) != pcid)
			continue;

		dt_add_property_cells(np, "ibm,ccm-node-id",
				      be32_to_cpu(id->ccm_node_id));
		dt_add_property_cells(np, "ibm,hw-card-id",
				      be32_to_cpu(id->hw_card_id));
		dt_add_property_cells(np, "ibm,hw-module-id",
				      be32_to_cpu(id->hw_module_id));
		if (!dt_find_property(np, "ibm,dbob-id"))
			dt_add_property_cells(np, "ibm,dbob-id",
				  be32_to_cpu(id->drawer_book_octant_blade_id));
		if (proc_gen < proc_gen_p9) {
			dt_add_property_cells(np, "ibm,mem-interleave-scope",
			          be32_to_cpu(id->memory_interleaving_scope));
		}
		return;
	}
}

static bool add_xscom_sppcrd(uint64_t xscom_base)
{
	const struct HDIF_common_hdr *hdif;
	unsigned int i, vpd_sz;
	const void *vpd;
	struct dt_node *np, *vpd_node;

	for_each_ntuple_idx(&spira.ntuples.proc_chip, hdif, i,
			    SPPCRD_HDIF_SIG) {
		const struct sppcrd_chip_info *cinfo;
		unsigned int csize;
		u32 ve, version;

		cinfo = HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_INFO, &csize);
		if (!CHECK_SPPTR(cinfo)) {
			prerror("XSCOM: Bad ChipID data %d\n", i);
			continue;
		}

		ve = be32_to_cpu(cinfo->verif_exist_flags) & CHIP_VERIFY_MASK;
		ve >>= CHIP_VERIFY_SHIFT;
		if (ve == CHIP_VERIFY_NOT_INSTALLED ||
		    ve == CHIP_VERIFY_UNUSABLE)
			continue;

		/* Create the XSCOM node */
		np = add_xscom_node(xscom_base,
				    be32_to_cpu(cinfo->xscom_id),
				    be32_to_cpu(cinfo->proc_chip_id));
		if (!np)
			continue;


		dt_add_property_cells(np, DT_PRIVATE "sppcrd-index", i);

		version = be16_to_cpu(hdif->version);

		/* Version 0A has additional OCC related stuff */
		if (version >= 0x000a) {
			if (!dt_find_property(np, "ibm,dbob-id"))
				dt_add_property_cells(np, "ibm,dbob-id",
					be32_to_cpu(cinfo->dbob_id));
			dt_add_property_cells(np, "ibm,occ-functional-state",
					      be32_to_cpu(cinfo->occ_state));
		}

		/* Add chip VPD */
		vpd_node = dt_add_vpd_node(hdif, SPPCRD_IDATA_FRU_ID,
					   SPPCRD_IDATA_KW_VPD);
		if (vpd_node)
			dt_add_property_cells(vpd_node, "ibm,chip-id",
					      be32_to_cpu(cinfo->xscom_id));

		/* Add module VPD on version A and later */
		if (version >= 0x000a) {
			vpd = HDIF_get_idata(hdif, SPPCRD_IDATA_MODULE_VPD,
					     &vpd_sz);
			if (CHECK_SPPTR(vpd))
				dt_add_property(np, "ibm,module-vpd", vpd,
						vpd_sz);
		}

		/*
		 * Extract additional associativity information from
		 * the core data. Pick one core on that chip
		 */
		add_xscom_add_pcia_assoc(np, be32_to_cpu(cinfo->proc_chip_id));

		/* Add PSI Host bridge */
		add_psihb_node(np);

		if (proc_gen >= proc_gen_p9) {
			add_xive_node(np);
			parse_i2c_devs(hdif, SPPCRD_IDATA_HOST_I2C, np);
			add_vas_node(np, i);
			add_ecid_data(hdif, np);
		}

		/*
		 * Add sw checkstop scom address (ibm,sw-checkstop-fir)
		 *
		 * The latest HDAT versions have sw checkstop scom address
		 * info.  But not sure from which version onwards (at least
		 * HDAT spec do not mention that explicitly). Hence use the
		 * sppcrd struct size returned by HDIF_get_idata to figure out
		 * whether it contains sw checkstop scom address info. Also
		 * check if sw_xstop_fir_scom address is non-zero.
		 */
		if ((csize >= (offsetof(struct sppcrd_chip_info,
					sw_xstop_fir_bitpos) + 1)) &&
						cinfo->sw_xstop_fir_scom) {
			__be32 fir_bit = cinfo->sw_xstop_fir_bitpos;

			if (!dt_find_property(dt_root, "ibm,sw-checkstop-fir"))
				dt_add_property_cells(dt_root,
					"ibm,sw-checkstop-fir",
					be32_to_cpu(cinfo->sw_xstop_fir_scom),
					be32_to_cpu(fir_bit));
		}
	}

	return i > 0;
}

static void add_xscom_sppaca(uint64_t xscom_base)
{
	const struct HDIF_common_hdr *hdif;
	unsigned int i;
	struct dt_node *np, *vpd_node;

	for_each_ntuple_idx(&spira.ntuples.paca, hdif, i, PACA_HDIF_SIG) {
		const struct sppaca_cpu_id *id;
		unsigned int chip_id, size;
		int ve;

		/* We only suport old style PACA on P7 ! */
		assert(proc_gen == proc_gen_p7);

		id = HDIF_get_idata(hdif, SPPACA_IDATA_CPU_ID, &size);

		if (!CHECK_SPPTR(id)) {
			prerror("XSCOM: Bad processor data %d\n", i);
			continue;
		}

		ve = be32_to_cpu(id->verify_exists_flags) & CPU_ID_VERIFY_MASK;
		ve >>= CPU_ID_VERIFY_SHIFT;
		if (ve == CPU_ID_VERIFY_NOT_INSTALLED ||
		    ve == CPU_ID_VERIFY_UNUSABLE)
			continue;

		/* Convert to HW chip ID */
		chip_id = P7_PIR2GCID(be32_to_cpu(id->pir));

		/* do we already have an XSCOM for this chip? */
		if (find_xscom_for_chip(chip_id))
			continue;

		/* Create the XSCOM node */
		np = add_xscom_node(xscom_base, chip_id,
				    be32_to_cpu(id->processor_chip_id));
		if (!np)
			continue;

		/* Add chip VPD */
		vpd_node = dt_add_vpd_node(hdif, SPPACA_IDATA_FRU_ID,
					   SPPACA_IDATA_KW_VPD);
		if (vpd_node)
			dt_add_property_cells(vpd_node, "ibm,chip-id", chip_id);

		/* Add chip associativity data */
		dt_add_property_cells(np, "ibm,ccm-node-id",
				      be32_to_cpu(id->ccm_node_id));
		if (size > SPIRA_CPU_ID_MIN_SIZE) {
			dt_add_property_cells(np, "ibm,hw-card-id",
					      be32_to_cpu(id->hw_card_id));
			dt_add_property_cells(np, "ibm,hw-module-id",
					  be32_to_cpu(id->hardware_module_id));
			if (!dt_find_property(np, "ibm,dbob-id"))
				dt_add_property_cells(np, "ibm,dbob-id",
				  be32_to_cpu(id->drawer_book_octant_blade_id));
			dt_add_property_cells(np, "ibm,mem-interleave-scope",
				 be32_to_cpu(id->memory_interleaving_scope));
		}

		/* Add PSI Host bridge */
		add_psihb_node(np);
	}
}

static void add_xscom(void)
{
	const void *ms_vpd;
	const struct msvpd_pmover_bsr_synchro *pmbs;
	unsigned int size;
	uint64_t xscom_base;

	ms_vpd = get_hdif(&spira.ntuples.ms_vpd, MSVPD_HDIF_SIG);
	if (!ms_vpd) {
		prerror("XSCOM: Can't find MS VPD\n");
		return;
	}

	pmbs = HDIF_get_idata(ms_vpd, MSVPD_IDATA_PMOVER_SYNCHRO, &size);
	if (!CHECK_SPPTR(pmbs) || size < sizeof(*pmbs)) {
		prerror("XSCOM: absent or bad PMBS size %u @ %p\n", size, pmbs);
		return;
	}

	if (!(be32_to_cpu(pmbs->flags) & MSVPD_PMS_FLAG_XSCOMBASE_VALID)) {
		prerror("XSCOM: No XSCOM base in PMBS, using default\n");
		return;
	}

	xscom_base = be64_to_cpu(pmbs->xscom_addr);

	/* Some FSP (on P7) give me a crap base address for XSCOM (it has
	 * spurious bits set as far as I can tell). Since only 5 bits 18:22 can
	 * be programmed in hardware, let's isolate these. This seems to give
	 * me the right value on VPL1
	 */
	if (cpu_type == PVR_TYPE_P7)
		xscom_base &= 0x80003e0000000000ul;

	/* Get rid of the top bits */
	xscom_base = cleanup_addr(xscom_base);

	/* First, try the new proc_chip ntuples for chip data */
	if (add_xscom_sppcrd(xscom_base))
		return;

	/* Otherwise, check the old-style PACA, looking for unique chips */
	add_xscom_sppaca(xscom_base);
}

static void add_chiptod_node(unsigned int chip_id, int flags)
{
	struct dt_node *node, *xscom_node;
	const char *compat_str;
	uint32_t addr, len;

	if ((flags & CHIPTOD_ID_FLAGS_STATUS_MASK) !=
			CHIPTOD_ID_FLAGS_STATUS_OK)
		return;

	xscom_node = find_xscom_for_chip(chip_id);
	if (!xscom_node) {
		prerror("CHIPTOD: No xscom for chiptod %d?\n", chip_id);
		return;
	}

	addr = 0x40000;
	len = 0x34;

	switch(proc_gen) {
	case proc_gen_p7:
		compat_str = "ibm,power7-chiptod";
		break;
	case proc_gen_p8:
		compat_str = "ibm,power8-chiptod";
		break;
	case proc_gen_p9:
		compat_str = "ibm,power9-chiptod";
		break;
	default:
		return;
	}

	prlog(PR_DEBUG, "CHIPTOD: Found on chip 0x%x %s\n", chip_id,
	      (flags & CHIPTOD_ID_FLAGS_PRIMARY) ? "[primary]" :
	      ((flags & CHIPTOD_ID_FLAGS_SECONDARY) ? "[secondary]" : ""));

	node = dt_new_addr(xscom_node, "chiptod", addr);
	if (!node)
		return;

	dt_add_property_cells(node, "reg", addr, len);
	dt_add_property_strings(node, "compatible", "ibm,power-chiptod",
			       compat_str);

	if (flags & CHIPTOD_ID_FLAGS_PRIMARY)
		dt_add_property(node, "primary", NULL, 0);
	if (flags & CHIPTOD_ID_FLAGS_SECONDARY)
		dt_add_property(node, "secondary", NULL, 0);
}

static bool add_chiptod_old(void)
{
	const void *hdif;
	unsigned int i;
	bool found = false;

	/*
	 * Locate chiptod ID structures in SPIRA
	 */
	if (!get_hdif(&spira.ntuples.chip_tod, "TOD   "))
		return found;

	for_each_ntuple_idx(&spira.ntuples.chip_tod, hdif, i, "TOD   ") {
		const struct chiptod_chipid *id;

		id = HDIF_get_idata(hdif, CHIPTOD_IDATA_CHIPID, NULL);
		if (!CHECK_SPPTR(id)) {
			prerror("CHIPTOD: Bad ChipID data %d\n", i);
			continue;
		}

		add_chiptod_node(pcid_to_chip_id(be32_to_cpu(id->chip_id)),
				 be32_to_cpu(id->flags));
		found = true;
	}
	return found;
}

static bool add_chiptod_new(void)
{
	const void *hdif;
	unsigned int i;
	bool found = false;

	/*
	 * Locate Proc Chip ID structures in SPIRA
	 */
	if (!get_hdif(&spira.ntuples.proc_chip, SPPCRD_HDIF_SIG))
		return found;

	for_each_ntuple_idx(&spira.ntuples.proc_chip, hdif, i,
			    SPPCRD_HDIF_SIG) {
		const struct sppcrd_chip_info *cinfo;
		const struct sppcrd_chip_tod *tinfo;
		unsigned int size;
		u32 ve, flags;

		cinfo = HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_INFO, NULL);
		if (!CHECK_SPPTR(cinfo)) {
			prerror("CHIPTOD: Bad ChipID data %d\n", i);
			continue;
		}

		ve = be32_to_cpu(cinfo->verif_exist_flags) & CHIP_VERIFY_MASK;
		ve >>= CHIP_VERIFY_SHIFT;
		if (ve == CHIP_VERIFY_NOT_INSTALLED ||
		    ve == CHIP_VERIFY_UNUSABLE)
			continue;

		tinfo = HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_TOD, &size);
		if (!CHECK_SPPTR(tinfo)) {
			prerror("CHIPTOD: Bad TOD data %d\n", i);
			continue;
		}

		flags = be32_to_cpu(tinfo->flags);

		/* The FSP may strip the chiptod info from HDAT; if we find
		 * a zero-ed out entry, assume that the chiptod is
		 * present, but we don't have any primary/secondary info. In
		 * this case, pick chip zero as the master.
		 */
		if (!size) {
			flags = CHIPTOD_ID_FLAGS_STATUS_OK;
			if (be32_to_cpu(cinfo->xscom_id) == 0x0)
				flags |= CHIPTOD_ID_FLAGS_PRIMARY;
		}

		add_chiptod_node(be32_to_cpu(cinfo->xscom_id), flags);
		found = true;
	}
	return found;
}

static void add_nx_node(u32 gcid)
{
	struct dt_node *nx;
	u32 addr;
	u32 size;
	struct dt_node *xscom;

	xscom = find_xscom_for_chip(gcid);
	if (xscom == NULL) {
		prerror("NX%d: did not found xscom node.\n", gcid);
		return;
	}

	/*
	 * The NX register space is relatively self contained on P7+ but
	 * a bit more messy on P8. However it's all contained within the
	 * PB chiplet port 1 so we'll stick to that in the "reg" property
	 * and let the NX "driver" deal with the details.
	 */
	addr = 0x2010000;
	size = 0x0004000;

	nx = dt_new_addr(xscom, "nx", addr);
	if (!nx)
		return;

	switch (proc_gen) {
	case proc_gen_p7:
		dt_add_property_strings(nx, "compatible", "ibm,power-nx",
					"ibm,power7-nx");
		break;
	case proc_gen_p8:
		dt_add_property_strings(nx, "compatible", "ibm,power-nx",
					"ibm,power8-nx");
		break;
	case proc_gen_p9:
		/* POWER9 NX is not software compatible with P7/P8 NX */
		dt_add_property_strings(nx, "compatible", "ibm,power9-nx");
		break;
	default:
		return;
	}

	dt_add_property_cells(nx, "reg", addr, size);
}

static void add_nx(void)
{
	unsigned int i;
	void *hdif;

	for_each_ntuple_idx(&spira.ntuples.proc_chip, hdif, i,
			SPPCRD_HDIF_SIG) {
		const struct sppcrd_chip_info *cinfo;
		u32 ve;

		cinfo = HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_INFO, NULL);
		if (!CHECK_SPPTR(cinfo)) {
			prerror("NX: Bad ChipID data %d\n", i);
			continue;
		}

		ve = be32_to_cpu(cinfo->verif_exist_flags) & CHIP_VERIFY_MASK;
		ve >>= CHIP_VERIFY_SHIFT;
		if (ve == CHIP_VERIFY_NOT_INSTALLED ||
				ve == CHIP_VERIFY_UNUSABLE)
			continue;

		if (cinfo->nx_state)
			add_nx_node(be32_to_cpu(cinfo->xscom_id));
	}
}

static void add_nmmu(void)
{
	struct dt_node *xscom, *nmmu;

	/* Nest MMU only exists on POWER9 */
	if (proc_gen != proc_gen_p9)
		return;

	dt_for_each_compatible(dt_root, xscom, "ibm,xscom") {
		nmmu = dt_new_addr(xscom, "nmmu", 0x5012c40);
		dt_add_property_strings(nmmu, "compatible", "ibm,power9-nest-mmu");
		dt_add_property_cells(nmmu, "reg", 0x5012c40, 0x20);
	}
}

static void add_iplparams_sys_params(const void *iplp, struct dt_node *node)
{
	const struct iplparams_sysparams *p;
	const struct HDIF_common_hdr *hdif = iplp;
	u16 version = be16_to_cpu(hdif->version);
	const char *vendor = NULL;
	u32 sys_attributes;

	p = HDIF_get_idata(iplp, IPLPARAMS_SYSPARAMS, NULL);
	if (!CHECK_SPPTR(p)) {
		prerror("IPLPARAMS: No SYS Parameters\n");
		/* Create a generic compatible property */
		dt_add_property_string(dt_root, "compatible", "ibm,powernv");
		return;
	}

	node = dt_new(node, "sys-params");
	assert(node);
	dt_add_property_cells(node, "#address-cells", 0);
	dt_add_property_cells(node, "#size-cells", 0);

	dt_add_property_nstr(node, "ibm,sys-model", p->sys_model, 4);

	/*
	 * Compatible has up to three entries:
	 *	"ibm,powernv", the system family and system type.
	 *
	 * On P9 and above the family and type strings come from the HDAT
	 * directly. On P8 we find it from the system ID numbers.
	 */
	if (proc_gen >= proc_gen_p9) {
		dt_add_property_strings(dt_root, "compatible", "ibm,powernv",
					p->sys_family_str, p->sys_type_str);

		prlog(PR_INFO, "IPLPARAMS: v0x70 Platform family/type: %s/%s\n",
		      p->sys_family_str, p->sys_type_str);
	} else {
		u32 sys_type = be32_to_cpu(p->system_type);
		const char *sys_family;

		switch (sys_type >> 28) {
		case 0:
			sys_family = "ibm,squadrons";
			break;
		case 1:
			sys_family = "ibm,eclipz";
			break;
		case 2:
			sys_family = "ibm,apollo";
			break;
		case 3:
			sys_family = "ibm,firenze";
			break;
		default:
			sys_family = NULL;
			prerror("IPLPARAMS: Unknown system family\n");
			break;
		}

		dt_add_property_strings(dt_root, "compatible", "ibm,powernv",
					sys_family);
		prlog(PR_INFO,
		      "IPLPARAMS: Legacy platform family: %s"
		      " (sys_type=0x%08x)\n", sys_family, sys_type);
	}

	/* Grab nest frequency when available */
	if (version >= 0x005b) {
		u64 freq = be32_to_cpu(p->nest_freq_mhz);

		freq *= 1000000;
		dt_add_property_u64(dt_root, "nest-frequency", freq);
	}

	if (version >= 0x5f)
		vendor = p->sys_vendor;

	/* Workaround a bug where we have NULL vendor */
	if (!vendor || vendor[0] == '\0')
		vendor = "IBM";

	dt_add_property_string(dt_root, "vendor", vendor);

	sys_attributes = be32_to_cpu(p->sys_attributes);
	if (sys_attributes & SYS_ATTR_RISK_LEVEL)
		dt_add_property(node, "elevated-risk-level", NULL, 0);
}

static void add_iplparams_ipl_params(const void *iplp, struct dt_node *node)
{
	const struct iplparams_iplparams *p;
	struct dt_node *led_node;

	p = HDIF_get_idata(iplp, IPLPARAMS_IPLPARAMS, NULL);
	if (!CHECK_SPPTR(p)) {
		prerror("IPLPARAMS: No IPL Parameters\n");
		return;
	}

	node = dt_new(node, "ipl-params");
	assert(node);
	dt_add_property_cells(node, "#address-cells", 0);
	dt_add_property_cells(node, "#size-cells", 0);

	/* On an ASM initiated factory reset, this bit will be set
	 * and the FSP expects the firmware to reset the PCI bus
	 * numbers and respond with a Power Down (CE,4D,02) message
	 */
	if (be32_to_cpu(p->other_attrib) & IPLPARAMS_OATTR_RST_PCI_BUSNO)
		dt_add_property_cells(node, "pci-busno-reset-ipl", 1);
	dt_add_property_strings(node, "cec-ipl-side",
				(p->ipl_side & IPLPARAMS_CEC_FW_IPL_SIDE_TEMP) ?
				"temp" : "perm");
	dt_add_property_strings(node, "fsp-ipl-side",
				(p->ipl_side & IPLPARAMS_FSP_FW_IPL_SIDE_TEMP) ?
				"temp" : "perm");
	dt_add_property_cells(node, "os-ipl-mode", p->os_ipl_mode);
	dt_add_property_strings(node, "cec-major-type",
				p->cec_ipl_maj_type ? "hot" : "cold");

	/* Add LED type info under '/ibm,opal/led' node */
	led_node = dt_find_by_path(opal_node, DT_PROPERTY_LED_NODE);
	assert(led_node);

	if (be32_to_cpu(p->other_attrib) & IPLPARAMS_OATRR_LIGHT_PATH)
		dt_add_property_strings(led_node, DT_PROPERTY_LED_MODE,
					LED_MODE_LIGHT_PATH);
	else
		dt_add_property_strings(led_node, DT_PROPERTY_LED_MODE,
					LED_MODE_GUIDING_LIGHT);
}

static void add_iplparams_serials(const void *iplp, struct dt_node *node)
{
	const struct iplparms_serial *ipser;
	struct dt_node *ser_node;
	int count, i;

	count = HDIF_get_iarray_size(iplp, IPLPARMS_IDATA_SERIAL);
	if (count <= 0)
		return;
	prlog(PR_INFO, "IPLPARAMS: %d serial ports in array\n", count);

	node = dt_new(node, "fsp-serial");
	assert(node);
	dt_add_property_cells(node, "#address-cells", 1);
	dt_add_property_cells(node, "#size-cells", 0);

	for (i = 0; i < count; i++) {
		u16 rsrc_id;
		ipser = HDIF_get_iarray_item(iplp, IPLPARMS_IDATA_SERIAL,
					     i, NULL);
		if (!CHECK_SPPTR(ipser))
			continue;
		rsrc_id = be16_to_cpu(ipser->rsrc_id);
		prlog(PR_INFO, "IPLPARAMS: Serial %d rsrc: %04x loc: %s\n",
		      i, rsrc_id, ipser->loc_code);
		ser_node = dt_new_addr(node, "serial", rsrc_id);
		if (!ser_node)
			continue;

		dt_add_property_cells(ser_node, "reg", rsrc_id);
		dt_add_property_nstr(ser_node, "ibm,loc-code",
				     ipser->loc_code, LOC_CODE_SIZE);
		dt_add_property_string(ser_node, "compatible",
				       "ibm,fsp-serial");
		/* XXX handle CALLHOME flag ? */
	}
}

/*
 * Check for platform dump, if present populate DT
 */
static void add_iplparams_platform_dump(const void *iplp, struct dt_node *node)
{
	const struct iplparams_dump *ipl_dump;

	ipl_dump = HDIF_get_idata(iplp, IPLPARAMS_PLATFORM_DUMP, NULL);
	if (!CHECK_SPPTR(ipl_dump))
		return;

	node = dt_new(node, "platform-dump");
	assert(node);

	if (be32_to_cpu(ipl_dump->dump_id)) {
		dt_add_property_cells(node, "dump-id",
				      be32_to_cpu(ipl_dump->dump_id));
		dt_add_property_u64(node, "total-size",
				    be64_to_cpu(ipl_dump->act_dump_sz));
		dt_add_property_u64(node, "hw-dump-size",
				    be32_to_cpu(ipl_dump->act_hw_dump_sz));
		dt_add_property_cells(node, "plog-id",
				      be32_to_cpu(ipl_dump->plid));
	}
}

static void add_iplparams(void)
{
	struct dt_node *iplp_node;
	const void *ipl_parms;

	ipl_parms = get_hdif(&spira.ntuples.ipl_parms, "IPLPMS");
	if (!ipl_parms) {
		prerror("IPLPARAMS: Cannot find IPL Parms in SPIRA\n");
		return;
	}

	iplp_node = dt_new(dt_root, "ipl-params");
	assert(iplp_node);
	dt_add_property_cells(iplp_node, "#address-cells", 0);
	dt_add_property_cells(iplp_node, "#size-cells", 0);

	add_iplparams_sys_params(ipl_parms, iplp_node);
	add_iplparams_ipl_params(ipl_parms, iplp_node);
	add_iplparams_serials(ipl_parms, iplp_node);
	add_iplparams_platform_dump(ipl_parms, iplp_node);
}

/* Various structure contain a "proc_chip_id" which is an arbitrary
 * numbering used by HDAT to reference chips, which doesn't correspond
 * to the HW IDs. We want to use the HW IDs everywhere in the DT so
 * we convert using this.
 *
 * Note: On P7, the HW ID is the XSCOM "GCID" including the T bit which
 * is *different* from the chip ID portion of the interrupt server#
 * (or PIR). See the explanations in chip.h
 */
uint32_t pcid_to_chip_id(uint32_t proc_chip_id)
{
	unsigned int i;
	const void *hdif;

	/* First, try the proc_chip ntuples for chip data */
	for_each_ntuple_idx(&spira.ntuples.proc_chip, hdif, i,
			    SPPCRD_HDIF_SIG) {
		const struct sppcrd_chip_info *cinfo;

		cinfo = HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_INFO,
						NULL);
		if (!CHECK_SPPTR(cinfo)) {
			prerror("XSCOM: Bad ChipID data %d\n", i);
			continue;
		}
		if (proc_chip_id == be32_to_cpu(cinfo->proc_chip_id))
			return be32_to_cpu(cinfo->xscom_id);
	}

	/* Otherwise, check the old-style PACA, looking for unique chips */
	for_each_ntuple_idx(&spira.ntuples.paca, hdif, i, PACA_HDIF_SIG) {
		const struct sppaca_cpu_id *id;

		/* We only suport old style PACA on P7 ! */
		assert(proc_gen == proc_gen_p7);

		id = HDIF_get_idata(hdif, SPPACA_IDATA_CPU_ID, NULL);

		if (!CHECK_SPPTR(id)) {
			prerror("XSCOM: Bad processor data %d\n", i);
			continue;
		}

		if (proc_chip_id == be32_to_cpu(id->processor_chip_id))
			return P7_PIR2GCID(be32_to_cpu(id->pir));
	}

	/* Not found, what to do ? Assert ? For now return a number
	 * guaranteed to not exist
	 */
	return (uint32_t)-1;
}

/* Create '/ibm,opal/led' node */
static void dt_init_led_node(void)
{
	struct dt_node *led_node;

	/* Create /ibm,opal node, if its not created already */
	if (!opal_node) {
		opal_node = dt_new(dt_root, "ibm,opal");
		assert(opal_node);
	}

	/* Crete LED parent node */
	led_node = dt_new(opal_node, DT_PROPERTY_LED_NODE);
	assert(led_node);
}

static void hostservices_parse(void)
{
	struct HDIF_common_hdr *hs_hdr;
	const void *dt_blob;
	unsigned int size;
	unsigned int ntuples_size;

	/* Deprecated on P9 */
	if (proc_gen >= proc_gen_p9)
		return;

	ntuples_size = sizeof(struct HDIF_array_hdr) + 
		be32_to_cpu(spira.ntuples.array_hdr.ecnt) *
		sizeof(struct spira_ntuple);

	if (offsetof(struct spira_ntuples, hs_data) >= ntuples_size) {
		prerror("SPIRA: No host services data found\n");
		return;
	}

	hs_hdr = get_hdif(&spira.ntuples.hs_data, HSERV_HDIF_SIG);
	if (!hs_hdr) {
		prerror("SPIRA: No host services data found\n");
		return;
	}

	dt_blob = HDIF_get_idata(hs_hdr, 0, &size);
	if (!dt_blob) {
		prerror("SPIRA: No host services idata found\n");
		return;
	}
	hservices_from_hdat(dt_blob, size);
}

static void add_stop_levels(void)
{
	struct spira_ntuple *t = &spira.ntuples.proc_chip;
	struct HDIF_common_hdr *hdif;
	u32 stop_levels = ~0;
	bool valid = false;
	int i;

	if (proc_gen < proc_gen_p9)
		return;

	/*
	 * OPAL only exports a single set of flags to indicate the supported
	 * STOP modes while the HDAT descibes the support top levels *per chip*
	 * We parse the list of chips to find a common set of STOP levels to
	 * export.
	 */
	for_each_ntuple_idx(t, hdif, i, SPPCRD_HDIF_SIG) {
		unsigned int size;
		const struct sppcrd_chip_info *cinfo =
			HDIF_get_idata(hdif, SPPCRD_IDATA_CHIP_INFO, &size);
		u32 ve, chip_levels;

		if (!cinfo)
			continue;

		/*
		 * If the chip info field is too small then assume we have no
		 * STOP level information.
		 */
		if (size < 0x44) {
			stop_levels = 0;
			break;
		}

		ve = be32_to_cpu(cinfo->verif_exist_flags) & CPU_ID_VERIFY_MASK;
		ve >>= CPU_ID_VERIFY_SHIFT;
		if (ve == CHIP_VERIFY_NOT_INSTALLED ||
		    ve == CHIP_VERIFY_UNUSABLE)
			continue;

		chip_levels = be32_to_cpu(cinfo->stop_levels);

		prlog(PR_INSANE, "CHIP[%x] supported STOP mask 0x%.8x\n",
			be32_to_cpu(cinfo->proc_chip_id), chip_levels);

		stop_levels &= chip_levels;
		valid = true;
	}

	if (!valid)
		stop_levels = 0;

	dt_add_property_cells(dt_new_check(opal_node, "power-mgt"),
		"ibm,enabled-stop-levels", stop_levels);
}

#define NPU_BASE 0x5011000
#define NPU_SIZE 0x2c
#define NPU_INDIRECT0	0x8000000009010c3fULL
#define NPU_INDIRECT1	0x800000000c010c3fULL

static void add_npu(struct dt_node *xscom, const struct HDIF_array_hdr *links,
			int npu_index, int phb_index)
{
	const struct sppcrd_smp_link *link;
	struct dt_node *npu;
	int group_target[6]; /* Tracks the PCI slot targeted each link group */
	int group_count = 0;
	int link_count = 0;
	uint32_t size, chip_id;
	int i;

	size = be32_to_cpu(links->esize);
	chip_id = dt_get_chip_id(xscom);

	memset(group_target, 0, sizeof(group_target));

	npu = dt_new_addr(xscom, "npu", NPU_BASE);
	dt_add_property_cells(npu, "reg", NPU_BASE, NPU_SIZE);
	dt_add_property_cells(npu, "#size-cells", 0);
	dt_add_property_cells(npu, "#address-cells", 1);

	dt_add_property_strings(npu, "compatible", "ibm,power9-npu");
	dt_add_property_cells(npu, "ibm,phb-index", phb_index);
	dt_add_property_cells(npu, "ibm,npu-index", npu_index);

	HDIF_iarray_for_each(links, i, link) {
		uint16_t slot_id = be16_to_cpu(link->pci_slot_idx);
		uint32_t link_id = be32_to_cpu(link->link_id);
		uint64_t speed = 0, nvlink_speed = 0;
		struct dt_node *node;

		/* only add a link node if this link is targeted at at device */
		if (be32_to_cpu(link->usage) != SMP_LINK_USE_DEVICE)
			continue;

		/*
		 * XXX: The link_id that we get from HDAT is essentially an
		 * arbitrary ID number so we can't use it as the reg for the
		 * link node.
		 *
		 * a) There's a 1-1 mapping between entries in the SMP link
		 *    structure and the NPU links.
		 *
		 * b) The SMP link array contains them in ascending order.
		 *
		 * We have some assurances that b) is correct, but if we get
		 * broken link numbering it's something to watch for.
		 *
		 * If we every have actual A-Bus (SMP) link info in here
		 * this is going to break.
		 */

		prlog(PR_DEBUG, "NPU: %04x:%d: Link (%d) targets slot %u",
			chip_id, link_count, link_count, slot_id);

		if (link_count >= 6) {
			prerror("NPU: %04x:%d: Ignoring extra link (max 6)\n",
				chip_id, link_count);
			break;
		}

		node = dt_new_addr(npu, "link", link_count);
		if (!node) {
			prerror("NPU: %04x:%d: Creating link node failed\n",
				chip_id, link_count);
			continue;
		}

		dt_add_property_string(node, "compatible", "ibm,npu-link");
		dt_add_property_cells(node, "reg", link_count);
		dt_add_property_cells(node, "ibm,npu-link-index", link_count);
		dt_add_property_cells(node, "ibm,workbook-link-id", link_id);

		dt_add_property_u64s(node, "ibm,npu-phy",
				link_count < 3 ? NPU_INDIRECT0 : NPU_INDIRECT1);
		dt_add_property_cells(node, "ibm,npu-lane-mask",
				be32_to_cpu(link->lane_mask));
		dt_add_property_cells(node, "ibm,npu-brick-id",
				be32_to_cpu(link->brick_id));

		link_count++;

		/*
		 * Add the group details if this is an NVlink.
		 *
		 * TODO: Cable card stuff.
		 */
		if (slot_id) {
			struct dt_node *slot;
			const char *name;
			int group;

			/*
			 * Search the existing groups for one targeting
			 * this PCI slot
			 */
			for (group = 0; group < group_count; group++)
				if (group_target[group] == slot_id)
					break;

			/* no group, make a new one */
			if (group == group_count) {
				group_target[group] = slot_id;
				group_count++;
			}

			dt_add_property_cells(node, "ibm,npu-group-id", group);

			slot = find_slot_entry_node(dt_root, slot_id);
			if (!slot) {
				prerror("NPU: %04x:%d: Unable find node for targeted PCIe slot\n",
					chip_id, link_count - 1);
				continue;
			}

			name = dt_prop_get_def(slot, "ibm,slot-label",
						(char *)"<SLOT NAME MISSING>");

			prlog(PR_DEBUG, "NPU: %04x:%d: Target slot %s\n",
				chip_id, link_count - 1, name);

			dt_add_property_string(node, "ibm,slot-label", name);
			dt_add_property_cells(node, "ibm,pcie-slot",
					slot->phandle);
		}

		/* Newer fields which might not be populated */
		if (size <= 0x24)
			continue;

		switch (link->link_speed) {
			case 0: /* 20Gbps */
				speed = 20000000000ul;
				nvlink_speed = 0x3;
				break;
			case 1: /* 25Gbps */
				speed = 25000000000ul;
				nvlink_speed = 0x9;
				break;
			case 2: /* 25.78125 Gbps */
				nvlink_speed =  0x8;
				speed = 25781250000ul;
				break;
		}

		/* ibm,link-speed is in bps and nvidia,link-speed is ~magic~ */
		dt_add_property_u64s(node, "ibm,link-speed", speed);
		dt_add_property_cells(node, "nvidia,link-speed", nvlink_speed);

		dt_add_property_cells(node, DT_PRIVATE "occ-flag-pos",
				PPC_BIT(link->occ_flag_bit));
	}

	dt_add_property_cells(npu, "ibm,npu-links", link_count);
}

static void add_npus(void)
{
	struct dt_node *xscom;
	int phb_index = 7; /* Start counting from 7, for no reason */
	int npu_index = 0;

	if (proc_gen < proc_gen_p9)
		return;

	dt_for_each_compatible(dt_root, xscom, "ibm,xscom") {
		const struct HDIF_array_hdr *links;

		links = xscom_to_pcrd(xscom, SPPCRD_IDATA_SMP_LINK);
		if (!links) {
			prerror("NPU: Unable to find matching SPPCRD for %s\n",
				xscom->name);
			continue;
		}

		/* should never happen, but stranger things have */
		if (!dt_find_by_name(dt_root, "ibm,pcie-slots")) {
			prerror("PCIe slot information missing, can't add npu");
			continue;
		}

		/* some hostboots will give us an empty array */
		if (be32_to_cpu(links->ecnt))
			add_npu(xscom, links, npu_index++, phb_index++);
	}
}

/*
 * Legacy SPIRA is being deprecated and we have new SPIRA-H/S structures.
 * But on older system (p7?) we will continue to get legacy SPIRA.
 *
 * SPIRA-S is initialized and provided by FSP. We use SPIRA-S signature
 * to identify supported format. Also if required adjust spira pointer.
 */
static void fixup_spira(void)
{
#if !defined(TEST)
	spiras = (struct spiras *)CPU_TO_BE64(SPIRA_HEAP_BASE);
#endif

	/* Validate SPIRA-S signature */
	if (!spiras)
		return;
	if (!HDIF_check(&spiras->hdr, SPIRAS_HDIF_SIG))
		return;

	prlog(PR_NOTICE, "SPIRA-S found.\n");

	spira.ntuples.sp_subsys = spiras->ntuples.sp_subsys;
	spira.ntuples.ipl_parms = spiras->ntuples.ipl_parms;
	spira.ntuples.nt_enclosure_vpd = spiras->ntuples.nt_enclosure_vpd;
	spira.ntuples.slca = spiras->ntuples.slca;
	spira.ntuples.backplane_vpd = spiras->ntuples.backplane_vpd;
	spira.ntuples.system_vpd = spiras->ntuples.system_vpd;
	spira.ntuples.proc_init = spirah.ntuples.proc_init;
	spira.ntuples.clock_vpd = spiras->ntuples.clock_vpd;
	spira.ntuples.anchor_vpd = spiras->ntuples.anchor_vpd;
	spira.ntuples.op_panel_vpd = spiras->ntuples.op_panel_vpd;
	spira.ntuples.misc_cec_fru_vpd = spiras->ntuples.misc_cec_fru_vpd;
	spira.ntuples.ms_vpd = spiras->ntuples.ms_vpd;
	spira.ntuples.cec_iohub_fru = spiras->ntuples.cec_iohub_fru;
	spira.ntuples.cpu_ctrl = spirah.ntuples.cpu_ctrl;
	spira.ntuples.mdump_src = spirah.ntuples.mdump_src;
	spira.ntuples.mdump_dst = spirah.ntuples.mdump_dst;
	spira.ntuples.mdump_res  = spirah.ntuples.mdump_res;
	spira.ntuples.pcia = spiras->ntuples.pcia;
	spira.ntuples.proc_chip = spiras->ntuples.proc_chip;
	spira.ntuples.hs_data = spiras->ntuples.hs_data;
	spira.ntuples.ipmi_sensor = spiras->ntuples.ipmi_sensor;
}

int parse_hdat(bool is_opal)
{
	cpu_type = PVR_TYPE(mfspr(SPR_PVR));

	prlog(PR_DEBUG, "Parsing HDAT...\n");

	fixup_spira();

	/*
	 * Basic DT root stuff
	 */
	dt_add_property_cells(dt_root, "#address-cells", 2);
	dt_add_property_cells(dt_root, "#size-cells", 2);

	if (proc_gen < proc_gen_p9)
		dt_add_property_string(dt_root, "lid-type", is_opal ? "opal" : "phyp");

	/* Add any BMCs and enable the LPC UART */
	bmc_parse();

	/* Create and populate /vpd node */
	dt_init_vpd_node();

	/* Create /ibm,opal/led node */
	dt_init_led_node();

	/* Parse SPPACA and/or PCIA */
	if (!pcia_parse())
		if (paca_parse() < 0)
			return -1;

	/* IPL params */
	add_iplparams();

	/* Parse MS VPD */
	memory_parse();

	/* Add XSCOM node (must be before chiptod, IO and FSP) */
	add_xscom();

	/* Add any FSPs */
	fsp_parse();

	/* Add ChipTOD's */
	if (!add_chiptod_old() && !add_chiptod_new())
		prerror("CHIPTOD: No ChipTOD found !\n");

	/* Add NX */
	add_nx();

	/* Add nest mmu */
	add_nmmu();

	/* Add IO HUBs and/or PHBs */
	io_parse();

	/* Add NPU nodes */
	if (proc_gen >= proc_gen_p9)
		add_npus();

	/* Parse VPD */
	vpd_parse();

	/* Host services information. */
 	hostservices_parse();

	/* Parse System Attention Indicator inforamtion */
	slca_dt_add_sai_node();

	add_stop_levels();

	prlog(PR_DEBUG, "Parsing HDAT...done\n");

	return 0;
}
