#include "memory_config.h"
#include "xparameters.h"

struct memory_range_s memory_ranges[] = {
#if defined(XPAR_PSU_DDR_0_S_AXI_BASEADDR)
	{
		"psu_ddr_0_MEM_0",
		"psu_ddr_0",
		XPAR_PSU_DDR_0_S_AXI_BASEADDR,
		DDR0_SZ,
	},
#endif
#if defined(XPAR_PSU_DDR_1_S_AXI_BASEADDR)
	{
		"psu_ddr_1_MEM_0",
		"psu_ddr_1",
		XPAR_PSU_DDR_1_S_AXI_BASEADDR,
		SHIM_SZ,
	},
#endif
#if defined(XPAR_AXI_SHIM_0_BASEADDR)
	{
		"axi_shim_0_mem0",
		"axi_shim_0",
		XPAR_AXI_SHIM_0_BASEADDR,
		SHIM_SZ,
	},
#endif
	/* psu_ocm_ram_0_MEM_0 memory will not be tested since application resides in the same memory */
};

int n_memory_ranges = sizeof(memory_ranges)/sizeof(struct memory_range_s);
