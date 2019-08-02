/*
 * monitor_sa.c
 *
 *  Created on: Sep 16, 2014
 *      Author: lloyd23
 */

//------------------ Initialization ------------------//

#if defined(STATS) || defined(TRACE)

#include "xparameters.h" /* XPAR_* */
#include "xaxipmon.h" /* XAxiPmon_* */
#include "xil_printf.h" /* print, xil_printf */
#include "monitor.h"

static XAxiPmon apm;

void monitor_init(void)
{
	int apm_status = XST_FAILURE;
	XAxiPmon_Config *apm_config = XAxiPmon_LookupConfig(XPAR_AXIPMON_0_DEVICE_ID);
	if (apm_config != NULL) apm_status = XAxiPmon_CfgInitialize(&apm, apm_config, apm_config->BaseAddress);
	if (apm_status != XST_SUCCESS) print(" -- error: failed to init AXI Performance Monitor\r\n");
}

void monitor_finish(void)
{
}

#endif // STATS || TRACE

//------------------ Statistics ------------------//

#if defined(STATS)

void stats_start(void)
{
	XAxiPmon_SetMetrics(&apm, 0, XAPM_METRIC_SET_0, XAPM_METRIC_COUNTER_0); /* Slot 0 Write Transaction Count */
	XAxiPmon_SetMetrics(&apm, 0, XAPM_METRIC_SET_1, XAPM_METRIC_COUNTER_1); /* Slot 0 Read Transaction Count */
	XAxiPmon_SetMetrics(&apm, 0, XAPM_METRIC_SET_2, XAPM_METRIC_COUNTER_2); /* Slot 0 Write Byte Count */
	XAxiPmon_SetMetrics(&apm, 0, XAPM_METRIC_SET_3, XAPM_METRIC_COUNTER_3); /* Slot 0 Read Byte Count */
	XAxiPmon_SetIncrementerRange(&apm, XAPM_INCREMENTER_2, 3, 0); /* counts data beats with low strobes on the 32-bit data channel */
#if defined(USE_ACC)
	XAxiPmon_SetMetrics(&apm, 1, XAPM_METRIC_SET_0, XAPM_METRIC_COUNTER_4); /* Slot 1 Write Transaction Count */
	XAxiPmon_SetMetrics(&apm, 1, XAPM_METRIC_SET_1, XAPM_METRIC_COUNTER_5); /* Slot 1 Read Transaction Count */
	XAxiPmon_SetMetrics(&apm, 1, XAPM_METRIC_SET_2, XAPM_METRIC_COUNTER_6); /* Slot 1 Write Byte Count */
	XAxiPmon_SetMetrics(&apm, 1, XAPM_METRIC_SET_3, XAPM_METRIC_COUNTER_7); /* Slot 1 Read Byte Count */
	XAxiPmon_SetIncrementerRange(&apm, XAPM_INCREMENTER_6, 7, 0); /* counts data beats with low strobes on the 64-bit data channel */
#endif
	XAxiPmon_IntrClear(&apm, XAPM_IXR_ALL_MASK);
	XAxiPmon_ResetMetricCounter(&apm);
	XAxiPmon_EnableMetricsCounter(&apm);
}

void stats_stop(void)
{
	XAxiPmon_DisableMetricsCounter(&apm);
#if defined(USE_ACC)
#endif
}

/* Xilinx header has ';' on end of macro */
#undef XAxiPmon_IntrGetStatus
#define XAxiPmon_IntrGetStatus(InstancePtr) XAxiPmon_ReadReg((InstancePtr)->Config.BaseAddress, XAPM_IS_OFFSET)

void stats_print(void)
{
	xil_printf("Slot TranW TranR ByteW ByteR StrobeLW\r\n");
	xil_printf("CPU %s%u %s%u %s%u %s%u %u\r\n",
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC0_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_0),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC1_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_1),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC2_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_2),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC3_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_3),
		XAxiPmon_GetIncrementer(&apm, XAPM_INCREMENTER_2)
		);
#if defined(USE_ACC)
	xil_printf("ACC %s%u %s%u %s%u %s%u %u\r\n",
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC4_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_4),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC5_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_5),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC6_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_6),
		(XAxiPmon_IntrGetStatus(&apm) & XAPM_IXR_MC7_OVERFLOW_MASK) ? "*" : "", XAxiPmon_GetMetricCounter(&apm, XAPM_METRIC_COUNTER_7),
		XAxiPmon_GetIncrementer(&apm, XAPM_INCREMENTER_6)
		);
#endif
}

#endif // STATS

//------------------ Trace ------------------//

#if defined(TRACE)

#include <stdint.h> /* uintptr_t */
#include <unistd.h> /* _exit */
#include "xil_cache.h" /* Xil_DCacheFlush */
#include <xtime_l.h> /* XTime, XTime_GetTime, COUNTS_PER_SECOND */

void trace_start(void)
{
#if TRACE == _TALL_
	XAxiPmon_StartEventLog(&apm,
		XAPM_FLAG_WRADDR|
		XAPM_FLAG_FIRSTWR|
		XAPM_FLAG_LASTWR|
		XAPM_FLAG_RESPONSE|
		XAPM_FLAG_RDADDR|
		XAPM_FLAG_FIRSTRD|
		XAPM_FLAG_LASTRD|
		XAPM_FLAG_SWDATA
	);
#else
	XAxiPmon_StartEventLog(&apm,
		XAPM_FLAG_WRADDR|
		XAPM_FLAG_RDADDR|
		XAPM_FLAG_SWDATA
	);
#endif
	XAxiPmon_SetSwDataReg(&apm, 0xAAAAAAAA);
}

void trace_stop(void)
{
	int i;
	/* flush FIFO in trace capture device with 16 events */
	for (i = 0; i < 16; i++) XAxiPmon_SetSwDataReg(&apm, 0xDEADBEEF);
	XAxiPmon_StopEventLog(&apm);
}

#if defined(ZYNQ) && ZYNQ == _Z7_
#define ENTRY_SZ 32U   /* 32 bytes, 256 bits */
#define ADDR_MASK 0x3FFFFFFFU
#define TRACE_MEM_SZ (1LU<<30) /* ZC706 */
#else
#define ENTRY_SZ 64U   /* 64 bytes, 512 bits */
#define ADDR_MASK 0x7FFFFFFFU /* limited to lower 2G window */
#define TRACE_MEM_SZ (1LU<<29) /* ZCU102 */
#endif
#define BLK_SZ (1U<<17) /* 128 Kbytes */

#if defined(USE_SD)
#include "ff.h"
#if _FFCONF == 8255
#define f_mount(fs,path,opt) f_mount(opt,fs)
#endif

#if 0
/*
   Save a memory trace to SD card. A file name is prompted for and entered
   from the terminal. Data is copied from a port on the Trace Capture Device
   (tcd) to Zynq on-chip memory in blocks of size BLK_SZ and then written to
   the SD card.
*/
void trace_capture(void)
{
	typedef int tcd_t;
	tcd_t *buf_beg = (tcd_t*)0x00000000U; /* copy buffer */
	tcd_t *buf_end = (tcd_t*)((uintptr_t)buf_beg + BLK_SZ);
	volatile tcd_t *tcd = (tcd_t*)XPAR_AXI_TCD_0_BASEADDR;
	register tcd_t *bptr = buf_beg;
	register tcd_t tmp;
	unsigned int blen = 0;
	unsigned long tot = 0, time;
	unsigned int fn_len;
	XTime start, finish;
	FATFS fs; /* Work area (file system object) for logical drives */
	TCHAR *drive = (TCHAR *)"0:/"; /* Logical drive */
	FIL fdst; /* File object */
	TCHAR fn[80]; /* File name */
	FRESULT fr; /* FatFs function common result code */
	UINT bw; /* File write count */
	//BYTE buffer[BLK_SZ] __attribute__ ((aligned (512))); /* File copy buffer */

	/* get file name */
	print("enter trace file name: ");
	fn_len = 0;
	for (;;) {
		char ch = inbyte();
		if (ch == '\r') {outbyte('\r'); outbyte('\n'); break;}
		if (ch == '\b') {if (fn_len > 0) {fn_len--; outbyte('\b'); outbyte(' '); outbyte('\b');} continue;}
		if (fn_len < sizeof(fn)-1) {fn[fn_len++] = ch; outbyte(ch);}
	}
	fn[fn_len] = '\0';
	if (fn_len == 0) return;
	XTime_GetTime(&start);
	//Xil_DCacheDisable();
	/* register work area for each logical drive */
print("f_mount\r\n");
	fr = f_mount(&fs, drive, 0);
	if (fr != FR_OK) {
		xil_printf("fr:%d = mount(fs, drive, 0)\r\n", fr);
		goto tc;
	}
	/* create destination file */
print("f_open\r\n");
	fr = f_open(&fdst, fn, FA_CREATE_ALWAYS | FA_WRITE);
	if (fr != FR_OK) {
		xil_printf("fr:%d = open(fd, fn:%s, FA_CREATE_ALWAYS | FA_WRITE)\r\n", fr, fn);
		goto tc;
	}
	Xil_DCacheFlush();
print("grab\r\n");
	*tcd = 0;
	do { /* grab trace */
		bptr = buf_beg;
print("fill\r\n");
		do { /* fill buffer */
			unsigned int i;
			tmp = 0;
			for (i = 0; i < (ENTRY_SZ/sizeof(tcd_t)); i++) /* fill entry */
				{ outbyte('.'); tmp |= *bptr++ = *tcd; }
			blen += ENTRY_SZ;
xil_printf("entry - tmp:%x blen:%d tot:0x%lx\r\n", tmp, blen, tot);
		} while (tmp && bptr < buf_end);
		Xil_L1DCacheFlush(); /* L1 only is enabled for scratchpad area */
		/* write buffer */
print("f_write\r\n");
		fr = f_write(&fdst, buf_beg, blen, &bw);
		if (fr != FR_OK /*|| bw != blen*/) {
			xil_printf("fr:%d = write(fd, buf, br:%d, bw:%d)\r\n", fr, blen, bw);
			goto tc;
		}
		tot += blen;
		if ((tot & ((1U<<20)-1)) == 0U) xil_printf("\rtrace length:0x%x\r", tot);
		if (tot >= TRACE_MEM_SZ) {
			print(" -- error: trace capture memory exceeded\r\n");
			goto tc;
		}
	} while (tmp);
tc:
	/* close file */
print("f_close\r\n");
	fr = f_close(&fdst);
	if (fr != FR_OK) {
		xil_printf("fr:%d = close(fd)\r\n", fr);
	}
	/* unregister work area prior to discarding it */
	fr = f_mount(NULL, drive, 0);
	if (fr != FR_OK) {
		xil_printf("fr:%d = unmount(NULL, drive, 0)\r\n", fr);
	}
	//Xil_DCacheEnable();
	XTime_GetTime(&finish);
	time = (finish-start)/COUNTS_PER_SECOND;
	xil_printf("trace length:0x%lx\r\n", tot);
	xil_printf("capture time:%ld sec\r\n", time);
	xil_printf("capture bandwidth:%ld bytes/sec\r\n", tot/time);
}
#else
/*
   Save a memory trace to SD card. A file name is prompted for and entered
   from the terminal. Data is copied from a port on the Trace Capture Device
   (tcd) to the heap in one contiguous block and then written to the SD card.
*/
void trace_capture(void)
{
	typedef int elem_t;
	extern unsigned char _heap_start[];
	extern unsigned char _heap_end[];
	/* use direct DRAM address not alias */
	elem_t *mem_beg = (elem_t*)(((uintptr_t)&_heap_start) & ADDR_MASK);
	elem_t *mem_end = (elem_t*)(((uintptr_t)&_heap_end) & ADDR_MASK);
	volatile elem_t *tcd = (elem_t*)XPAR_AXI_TCD_0_BASEADDR;
	register elem_t *dst = mem_beg;
	register elem_t tmp;
	unsigned int fn_len;
	unsigned long tot = 0, time;
	XTime start, finish;
	FATFS fs; /* Work area (file system object) for logical drives */
	TCHAR *drive = (TCHAR *)"0:/"; /* Logical drive */
	FIL fdst; /* File object */
	TCHAR fn[80]; /* File name */
	FRESULT fr; /* FatFs function common result code */
	UINT bw; /* File write count */

	/* get file name */
	print("enter trace file name: ");
	fn_len = 0;
	for (;;) {
		char ch = inbyte();
		if (ch == '\r') {outbyte('\r'); outbyte('\n'); break;}
		if (ch == '\b') {if (fn_len > 0) {fn_len--; outbyte('\b'); outbyte(' '); outbyte('\b');} continue;}
		if (fn_len < sizeof(fn)-1) {fn[fn_len++] = ch; outbyte(ch);}
	}
	fn[fn_len] = '\0';
	if (fn_len == 0) return;

	/* copy trace to heap */
	XTime_GetTime(&start);
	Xil_DCacheFlush();
	*tcd = 0;
	do {
		unsigned int i;
		tmp = 0;
		for (i = 0; i < (ENTRY_SZ/sizeof(elem_t)); i++)
			tmp |= *dst++ = *tcd;
		tot += ENTRY_SZ;
	} while (tmp && dst < mem_end);
	Xil_DCacheFlush();

	//Xil_DCacheDisable();
	/* register work area for each logical drive */
	fr = f_mount(&fs, drive, 0);
	if (fr != FR_OK) {
		xil_printf("fr:%d = mount(fs, drive, 0)\r\n", fr);
		goto tc;
	}
	/* create destination file */
	fr = f_open(&fdst, fn, FA_CREATE_ALWAYS | FA_WRITE);
	if (fr != FR_OK) {
		xil_printf("fr:%d = open(fd, fn:%s, FA_CREATE_ALWAYS | FA_WRITE)\r\n", fr, fn);
		goto tc;
	}
	/* write buffer */
	fr = f_write(&fdst, mem_beg, tot, &bw);
	if (fr != FR_OK /*|| bw != blen*/) {
		xil_printf("fr:%d = write(fd, buf, br:%d, bw:%d)\r\n", fr, tot, bw);
		goto tc;
	}
tc:
	/* close file */
	fr = f_close(&fdst);
	if (fr != FR_OK) {
		xil_printf("fr:%d = close(fd)\r\n", fr);
	}
	/* unregister work area prior to discarding it */
	fr = f_mount(NULL, drive, 0);
	if (fr != FR_OK) {
		xil_printf("fr:%d = unmount(NULL, drive, 0)\r\n", fr);
	}
	//Xil_DCacheEnable();
	XTime_GetTime(&finish);
	time = (finish-start)/COUNTS_PER_SECOND;
	if (tmp) print(" -- error: ran out of heap for trace\r\n");
	xil_printf("trace address:0x%lx length:0x%lx\r\n", (long)mem_beg, tot);
	xil_printf("capture time:%ld sec\r\n", time);
	xil_printf("capture bandwidth:%ld bytes/sec\r\n", tot/time);

	_exit(0); /* avoid destructors, type XMD% stop to terminate */
}
#endif
#else /* not USE_SD */
/*
   Save a memory trace to the heap for later download through JTAG with the
   "Dump/Restore Data File" tool. Data is first copied from a port on the
   Trace Capture Device (tcd) to the heap in one contiguous block.
*/
void trace_capture(void)
{
	typedef int elem_t;
	extern unsigned char _heap_start[];
	extern unsigned char _heap_end[];
	/* use direct DRAM address not alias */
	elem_t *mem_beg = (elem_t*)(((uintptr_t)&_heap_start) & ADDR_MASK);
	elem_t *mem_end = (elem_t*)(((uintptr_t)&_heap_end) & ADDR_MASK);
	volatile elem_t *tcd = (elem_t*)XPAR_AXI_TCD_0_BASEADDR;
	elem_t *dst = mem_beg;
	register elem_t tmp;
	unsigned long tot = 0;
	Xil_DCacheFlush();
	*tcd = 0;
	do {
		unsigned int i;
		tmp = 0;
		for (i = 0; i < (ENTRY_SZ/sizeof(elem_t)); i++)
			tmp |= *dst++ = *tcd;
		tot += ENTRY_SZ;
	} while (tmp && dst < mem_end);
	Xil_DCacheFlush();
	if (tmp) print(" -- error: ran out of heap for trace\r\n");
	xil_printf("trace address:0x%lx length:0x%lx\r\n", (long)mem_beg, tot);
	_exit(0); /* avoid destructors, type XMD% stop to terminate */
	/* if needed run "hw_server -s tcp::3121" before "Dump/Restore Data File" tool */
}
#endif /* USE_SD */

#endif // TRACE
