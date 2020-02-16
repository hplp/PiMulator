/* Copyright 2015 IBM Corp.
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
#include <chip.h>
#include <xscom.h>
#include <io.h>
#include <cpu.h>
#include <nx.h>
#include <vas.h>

static int nx_cfg_umac_tx_wc(u32 gcid, u64 xcfg)
{
	int rc = 0;
	u64 cfg;

	cfg = vas_get_wcbs_bar(gcid);
	if (!cfg) {
		prerror("NX%d: ERROR finding WC Backing store BAR\n", gcid);
		return -ENOMEM;
	}

	/*
	 * NOTE: Write the entire bar address to SCOM. VAS/NX will extract
	 *       the relevant (NX_P9_UMAC_TX_WINDOW_CONTEXT_ADDR) bits.
	 *       IOW, _don't_ just write the bit field like:
	 *
	 *       cfg = SETFIELD(NX_P9_UMAC_TX_WINDOW_CONTEXT_ADDR, 0ULL, cfg);
	 */
	rc = xscom_write(gcid, xcfg, cfg);

	if (rc)
		prerror("NX%d: ERROR: UMAC SEND WC BAR, %d\n", gcid, rc);
	else
		prlog(PR_DEBUG, "NX%d: UMAC SEND WC BAR, 0x%016lx, "
				"xcfg 0x%llx\n",
			gcid, (unsigned long)cfg, xcfg);

	return rc;
}

static int nx_cfg_dma_vas_mmio(u32 gcid, u64 xcfg)
{
	int rc = 0;
	u64 cfg;

	cfg = vas_get_hvwc_mmio_bar(gcid);
	/*
	 * NOTE: Write the entire bar address to SCOM. VAS/NX will extract
	 *       the relevant (NX_P9_UMAC_VAS_MMIO_ADDR) bits. IOW, _don't_
	 *       just write the bit field like:
	 *
	 *	cfg = SETFIELD(NX_P9_DMA_VAS_MMIO_ADDR, 0ULL, cfg);
	 */
	rc = xscom_write(gcid, xcfg, cfg);

	if (rc)
		prerror("NX%d: ERROR: DMA VAS MMIO BAR, %d\n", gcid, rc);
	else
		prlog(PR_DEBUG, "NX%d: DMA VAS MMIO BAR, 0x%016lx, xcfg 0x%llx\n",
			gcid, (unsigned long)cfg, xcfg);

	return rc;
}

static int nx_cfg_umac_vas_mmio(u32 gcid, u64 xcfg)
{
	int rc = 0;
	u64 cfg;

	cfg = vas_get_hvwc_mmio_bar(gcid);
	/*
	 * NOTE: Write the entire bar address to SCOM. VAS/NX will extract
	 *       the relevant (NX_P9_UMAC_VAS_MMIO_ADDR) bits. IOW, _don't_
	 *	 just write the bit field like:
	 *
	 *       cfg = SETFIELD(NX_P9_UMAC_VAS_MMIO_ADDR, 0ULL, cfg);
	 */
	rc = xscom_write(gcid, xcfg, cfg);

	if (rc)
		prerror("NX%d: ERROR: UMAC VAS MMIO BAR, %d\n", gcid, rc);
	else
		prlog(PR_DEBUG, "NX%d: UMAC VAS MMIO BAR, 0x%016lx, "
				"xcfg 0x%llx\n",
			gcid, (unsigned long)cfg, xcfg);

	return rc;
}

static int nx_cfg_umac_status_ctrl(u32 gcid, u64 xcfg)
{
	u64 uctrl;
	int rc;
#define CRB_ENABLE	1

	rc = xscom_read(gcid, xcfg, &uctrl);
	if (rc)
		return rc;

	uctrl = SETFIELD(NX_P9_UMAC_STATUS_CTRL_CRB_ENABLE, uctrl, CRB_ENABLE);
	rc = xscom_write(gcid, xcfg, uctrl);
	if (rc)
		prerror("NX%d: ERROR: Setting UMAC Status Control failure %d\n",
			gcid, rc);
	else
		prlog(PR_DEBUG, "NX%d: Setting UMAC Status Control 0x%016lx\n",
			gcid, (unsigned long)uctrl);

	return rc;
}

int nx_cfg_rx_fifo(struct dt_node *node, const char *compat,
			const char *priority, u32 gcid, u32 pid, u32 tid,
			u64 umac_bar, u64 umac_notify)
{
	u64 cfg;
	int rc, size;
	uint64_t fifo;
	u32 lpid = 0xfff; /* All 1's for 12 bits in UMAC notify match reg */
#define MATCH_ENABLE    1

	fifo = (uint64_t) local_alloc(gcid, RX_FIFO_SIZE, RX_FIFO_SIZE);
	assert(fifo);

	/*
	 * When configuring the address of the Rx FIFO into the Receive FIFO
	 * BAR, we should _NOT_ shift the address into bits 8:53. Instead we
	 * should copy the address as is and VAS/NX will extract relevant bits.
	 */
	/*
	 * Section 5.21 of P9 NX Workbook Version 2.42 shows Receive FIFO BAR
	 * 54:56 represents FIFO size
	 * 000 = 1KB, 8 CRBs
	 * 001 = 2KB, 16 CRBs
	 * 010 = 4KB, 32 CRBs
	 * 011 = 8KB, 64 CRBs
	 * 100 = 16KB, 128 CRBs
	 * 101 = 32KB, 256 CRBs
	 * 110 = 111 reserved
	 */
	size = RX_FIFO_SIZE / 1024;
	cfg = SETFIELD(NX_P9_RX_FIFO_BAR_SIZE, fifo, ilog2(size));

	rc = xscom_write(gcid, umac_bar, cfg);
	if (rc) {
		prerror("NX%d: ERROR: Setting UMAC FIFO bar failure %d\n",
			gcid, rc);
		return rc;
	} else
		prlog(PR_DEBUG, "NX%d: Setting UMAC FIFO bar 0x%016lx\n",
			gcid, (unsigned long)cfg);

	rc = xscom_read(gcid, umac_notify, &cfg);
	if (rc)
		return rc;

	/*
	 * VAS issues asb_notify with the unique ID to identify the target
	 * co-processor/engine. Logical partition ID (lpid), process ID (pid),
	 * and thread ID (tid) combination is used to define the unique ID
	 * in the system. Export these values in device-tree such that the
	 * driver configure RxFIFO with VAS. Set these values in RxFIFO notify
	 * match register for each engine which compares the ID with each
	 * request.
	 * To define unique indentification, 0xfff (1's for 12 bits),
	 * co-processor type, and counter within coprocessor type are used
	 * for lpid, pid, and tid respectively.
	 */
	cfg = SETFIELD(NX_P9_RX_FIFO_NOTIFY_MATCH_LPID, cfg, lpid);
	cfg = SETFIELD(NX_P9_RX_FIFO_NOTIFY_MATCH_PID, cfg, pid);
	cfg = SETFIELD(NX_P9_RX_FIFO_NOTIFY_MATCH_TID, cfg, tid);
	cfg = SETFIELD(NX_P9_RX_FIFO_NOTIFY_MATCH_MATCH_ENABLE, cfg,
			MATCH_ENABLE);

	rc = xscom_write(gcid, umac_notify, cfg);
	if (rc) {
		prerror("NX%d: ERROR: Setting UMAC notify match failure %d\n",
			gcid, rc);
		return rc;
	} else
		prlog(PR_DEBUG, "NX%d: Setting UMAC notify match 0x%016lx\n",
				gcid, (unsigned long)cfg);

	dt_add_property_string(node, "compatible", compat);
	dt_add_property_string(node, "priority", priority);
	dt_add_property_u64(node, "rx-fifo-address", fifo);
	dt_add_property_cells(node, "rx-fifo-size", RX_FIFO_SIZE);
	dt_add_property_cells(node, "lpid", lpid);
	dt_add_property_cells(node, "pid", pid);
	dt_add_property_cells(node, "tid", tid);

	return 0;
}

void nx_create_compress_node(struct dt_node *node)
{
	u32 gcid, pb_base;
	int rc;

	gcid = dt_get_chip_id(node);
	pb_base = dt_get_address(node, 0, NULL);

	prlog(PR_INFO, "NX%d: 842 at 0x%x\n", gcid, pb_base);

	if (dt_node_is_compatible(node, "ibm,power9-nx")) {
		u64 cfg_mmio, cfg_txwc, cfg_uctrl, cfg_dma;

		printf("Found ibm,power9-nx\n");
		cfg_mmio = pb_base + NX_P9_UMAC_VAS_MMIO_BAR;
		cfg_dma = pb_base + NX_P9_DMA_VAS_MMIO_BAR;
		cfg_txwc = pb_base + NX_P9_UMAC_TX_WINDOW_CONTEXT_BAR;
		cfg_uctrl = pb_base + NX_P9_UMAC_STATUS_CTRL;

		rc = nx_cfg_umac_vas_mmio(gcid, cfg_mmio);
		if (rc)
			return;

		rc = nx_cfg_dma_vas_mmio(gcid, cfg_dma);
		if (rc)
			return;

		rc = nx_cfg_umac_tx_wc(gcid, cfg_txwc);
		if (rc)
			return;

		rc = nx_cfg_umac_status_ctrl(gcid, cfg_uctrl);
		if (rc)
			return;

		p9_nx_enable_842(node, gcid, pb_base);
		p9_nx_enable_gzip(node, gcid, pb_base);
	} else
		nx_enable_842(node, gcid, pb_base);
}
