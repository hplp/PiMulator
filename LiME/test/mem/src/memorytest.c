/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

#include <stdio.h>
#include <string.h> /* memset, memcpy */

#include "xparameters.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xil_testmem.h"
#include "xil_printf.h"
#include "xil_io.h" /* Xil_In32, Xil_Out32 */
//#include "xil_mmu.h" /* Xil_SetTlbAttributes */
#include "xil_cache.h" /* Xil_DCache_ */

#include "memory_config.h"
#define XILTIME 1
#include "ticks.h"

/*
 * XIL_TESTMEM_ALLMEMTESTS
 * XIL_TESTMEM_INCREMENT
 * XIL_TESTMEM_WALKONES
 * XIL_TESTMEM_WALKZEROS
 * XIL_TESTMEM_INVERSEADDR
 * XIL_TESTMEM_FIXEDPATTERN
 */
#define SUB_TEST XIL_TESTMEM_INVERSEADDR

#define MAX_SIZE (DDR0_SZ+DDR1_SZ)

#define DDRC_SARBASE0_OFFSET 0xFD070F04
#define DDRC_SARSIZE0_OFFSET 0xFD070F08
#define DDRC_SARBASE1_OFFSET 0xFD070F0C
#define DDRC_SARSIZE1_OFFSET 0xFD070F10

#if !defined(ALIGN_SZ)
#define ALIGN_SZ 64
#endif
#define CEIL(n,s) ((((n)+((s)-1)) / (s)) * (s))
#define FLOOR(n,s) (((n) / (s)) * (s))


/*
 * memory_test.c: Test memory ranges present in the Hardware Design.
 *
 * This application runs with D-Caches disabled. As a result cacheline requests
 * will not be generated.
 *
 * For MicroBlaze/PowerPC, the BSP doesn't enable caches and this application
 * enables only I-Caches. For ARM, the BSP enables caches by default, so this
 * application disables D-Caches before running memory tests.
 */

#if 0
#define Memory (0x405 | (3 << 8) | 0x0) /* normal writeback write allocate inner shared read write */

void init_pagetable(void)
{
	char *ptr;

	for (ptr = (char*)0x1000000000UL; ptr < (char*)0x1400000000UL; ptr += 0x40000000)
		Xil_SetTlbAttributes((UINTPTR)ptr, Memory); /* Cacheable */
	for (ptr = (char*)0x0800000000UL; ptr < (char*)0x0C00000000UL; ptr += 0x40000000)
		Xil_SetTlbAttributes((UINTPTR)ptr, Memory); /* Cacheable */
}
#endif

#define puteol print("\r\n")

void putnum(unsigned long num)
{
	unsigned cnt = sizeof(num) << 1; /* nibbles */
	unsigned digit;

	if (cnt > 10) cnt = 10; /* up to 40 bits */
	while (cnt) {
		cnt--;
		digit = ((num >> (cnt * 4U)) & 0xFU);

		if (digit < 10U) {
			outbyte(digit + '0');
		} else {
			outbyte(digit - 10U + 'A');
		}
	}
}

void test_memset(void *ptr, size_t sz)
{
	tick_t start, finish;

	Xil_DCacheFlush();
	Xil_DCacheInvalidateRange((INTPTR)ptr, sz);
	ptr = (void *)CEIL((size_t)ptr, ALIGN_SZ);
	sz = FLOOR(sz, ALIGN_SZ);
	printf("memset dst: %p, sz: %lx\n", ptr, (unsigned long)sz);
	tget(start);
	memset(ptr, 0xFF, sz);
	tget(finish);
	printf("memset ticks: %llu, time: %.3f us, bandwidth(wo): %.3f MB/s\n",
		(unsigned long long)tdiff(finish,start),
		tsec(finish,start)*1000000,
		sz/tsec(finish,start)/1000000);
}

void test_memcpy(void *ptr, size_t sz)
{
	tick_t start, finish;
	void *dst, *src;

	Xil_DCacheFlush();
	Xil_DCacheInvalidateRange((INTPTR)ptr, sz);
	sz = FLOOR(sz/2, ALIGN_SZ);
	src = (void *)CEIL((size_t)ptr, ALIGN_SZ);
	dst = src + sz;
	printf("memcpy dst: %p, src: %p, sz: %lx\n", dst, src, (unsigned long)sz);
	tget(start);
	memcpy(dst, src, sz);
	tget(finish);
	printf("memcpy ticks: %llu, time: %.3f us, bandwidth(rw): %.3f MB/s\n",
		(unsigned long long)tdiff(finish,start),
		tsec(finish,start)*1000000,
		sz*2/tsec(finish,start)/1000000);
}

void test_memory_range(struct memory_range_s *range) {
	XStatus status;
	unsigned long test_size = range->size;

	/* This application uses print statements instead of xil_printf/printf
	 * to reduce the text size.
	 *
	 * The default linker script generated for this application does not have
	 * heap memory allocated. This implies that this program cannot use any
	 * routines that allocate memory on heap (printf is one such function).
	 * If you'd like to add such functions, then please generate a linker script
	 * that does allocate sufficient heap memory.
	 */

	print("Testing memory region: "); print(range->name); puteol;
	print("    Memory Controller: "); print(range->ip); puteol;
	print("         Base Address: 0x"); putnum(range->base); puteol;
	print("                 Size: 0x"); putnum(range->size); print(" bytes"); puteol;
	if (test_size > MAX_SIZE) test_size = MAX_SIZE;

	Xil_DCacheFlush();
	Xil_DCacheInvalidateRange((INTPTR)range->base, test_size);

	status = Xil_TestMem32l((u32*)range->base, test_size/sizeof(u32), 0xAAAA5555, SUB_TEST);
	print("          32-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); puteol;

	// status = Xil_TestMem16l((u16*)range->base, test_size/sizeof(u16), 0xAA55, SUB_TEST);
	// print("          16-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); puteol;

	// status = Xil_TestMem8l((u8*)range->base, test_size/sizeof(u8), 0xA5, SUB_TEST);
	// print("           8-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); puteol;

	test_memset((void *)range->base, test_size);
	test_memcpy((void *)range->base, test_size);
}

void test_alias(void)
{
	unsigned int *pa = (unsigned int *)0x0000000000;
	unsigned int *pb = (unsigned int *)0x0800000000;
	unsigned int *pc = (unsigned int *)0x1000000000;
	int i, errb = 0, errc = 0, errbh = 0;

	Xil_DCacheDisable();
	for (i = 0; i < 64; i++) {
		pb[i] = 0; DATA_SYNC;
		pc[i] = 0; DATA_SYNC;
		pb[i+0x20000000] = ~i; DATA_SYNC;
		pc[i+0x20000000] = ~i; DATA_SYNC;
		pa[i] = i; DATA_SYNC;
	}
	//for (i = 0; i < 64; i++) {
		//putnum(pa[i]); outbyte(' '); putnum(pb[i]); outbyte(' '); putnum(pc[i]); outbyte(' ');
		//putnum(pb[i+0x20000000]); outbyte(' '); putnum(pc[i+0x20000000]); outbyte('\n');
	//}
	for (i = 0; i < 64; i++) {
		errb |= pa[i] != pb[i] || pb[i] != i;
		errc |= pa[i] != pc[i] || pc[i] != i;
	}
	if (errb) {print("Error at 0x"); putnum((unsigned long)pb); puteol;}
	if (errc) {print("Error at 0x"); putnum((unsigned long)pc); puteol;}
	for (i = 0; i < 64; i++) {
		pa[i] = 0; DATA_SYNC;
		pb[i+0x20000000] = 0; DATA_SYNC;
		pc[i+0x20000000] = i; DATA_SYNC;
	}
	for (i = 0; i < 64; i++) {
		errbh |= pc[i+0x20000000] != pb[i+0x20000000] || pb[i+0x20000000] != i;
	}
	if (errbh) {print("Error at 0x"); putnum((unsigned long)(pb+0x20000000)); puteol;}
	if (!(errb || errc || errbh)) {print("Alias OK"); puteol;}
	Xil_DCacheEnable();
}

int main()
{
	int i;

	//init_pagetable(); /* done in translation_table.S */
	//Xil_DCacheDisable();

	print("--Starting Memory Test Application--"); puteol;

	print("SARBASE0: 0x"); putnum(Xil_In32(DDRC_SARBASE0_OFFSET)); puteol;
	print("SARSIZE0: 0x"); putnum(Xil_In32(DDRC_SARSIZE0_OFFSET)); puteol;
	print("SARBASE1: 0x"); putnum(Xil_In32(DDRC_SARBASE1_OFFSET)); puteol;
	print("SARSIZE1: 0x"); putnum(Xil_In32(DDRC_SARSIZE1_OFFSET)); puteol;

	test_alias();
	for (i = 0; i < n_memory_ranges; i++) {
		test_memory_range(&memory_ranges[i]);
	}

	print("--Memory Test Application Complete--"); puteol;

	return 0;
}
