/*
 * Xilinx AXI Performance Monitor Example
 *
 * Copyright (c) 2013 Xilinx Inc.
 *
 * The code may be used by anyone for any purpose and can serve as a
 * starting point for developing applications using Xilinx AXI
 * Performance Monitor.
 *
 * This example based on Xilinx AXI Performance Monitor UIO driver shows
 * sequence to read metrics from Xilinx AXI Performance Monitor IP.
 * User need to provide the uio device file with option -d:
 * main -d /dev/uio0, say /dev/uio0 as device file for AXI Performance
 * Monitor driver. User need not clear Interrupt Status Register after
 * waiting for interrupt on read since driver clears it.
 * 
 * Modified by Maya Gokhale (LLNL) to access LLNL IP of Trace Capture 
 * Device (TCD) that extends the Xilinx IP to include memory address.
 *
 */

#if defined(STATS) || defined(TRACE)

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/time.h>  /* to time trace capture */
#include <errno.h>
#include <sys/msg.h>
#include <sys/ipc.h>
#include <stdint.h>
#if defined(PAPI)
#include <papi.h>
#endif
#include "xapm.h"
#include "xparam.h"
#include "monitor.h"

/*
   Renamed Linux version of xaxipmon to xapm to avoid a name collision
   with the standalone version. The xaxipmon.c source code is included
   here to keep the xaxipmon.[ch] code relatively untouched. Limited
   baseaddr and params to file scope (made static).
*/

#include "xapm.c"

#define MAP_SIZE 4096

static int uiofd;
#if defined(PAPI)
int PAPI_events[] = {
  PAPI_L1_DCA, PAPI_L1_DCM, PAPI_L2_DCA, PAPI_L2_DCM,
  PAPI_LD_INS, PAPI_SR_INS, PAPI_TOT_CYC
};
static long long counters[7];
#endif

/* baseaddr and params are defined in xapm.h */

void monitor_init(void) {
  char* uiod = "/dev/uio0";

  uiofd = open(uiod, O_RDWR|O_SYNC);
  if (uiofd < 1) {
    printf("Invalid UIO device file:%s.\n", uiod);
    exit(1);
  }

  baseaddr = (ulong)mmap(0, MAP_SIZE, PROT_READ|PROT_WRITE,
                         MAP_SHARED, uiofd, 0);
  if ((u32 *)baseaddr == MAP_FAILED)
    perror("mmap failed\n");

  /* mmap the UIO device */
  params = (struct xapm_param *)mmap(0, MAP_SIZE, PROT_READ|PROT_WRITE,
                                     MAP_SHARED, uiofd, getpagesize());
  if (params == MAP_FAILED)
    perror("mmap failed\n");

  if (params->mode == 1)
    printf("AXI PMON is in Advanced Mode\n");
  else if (params->mode == 2)
    printf("AXI PMON is in Profile Mode\n");
  else
    printf("AXI PMON is in trace Mode\n");

#if defined(PAPI)
  PAPI_library_init(PAPI_VER_CURRENT);
#endif
}

void monitor_finish(void) {
  close(uiofd);
  munmap((u32 *)baseaddr, MAP_SIZE);
  munmap(params, MAP_SIZE);
}

#endif // STATS || TRACE

#if defined(STATS)

void stats_start(void) {
  /* CPU */
  setmetrics(0, XAPM_METRIC_SET_0, XAPM_METRIC_COUNTER_0); /* Slot 0 Write Transaction Count */
  setmetrics(0, XAPM_METRIC_SET_1, XAPM_METRIC_COUNTER_1); /* Slot 0 Read Transaction Count */
  setmetrics(0, XAPM_METRIC_SET_2, XAPM_METRIC_COUNTER_2); /* Slot 0 Write Byte Count */
  setmetrics(0, XAPM_METRIC_SET_3, XAPM_METRIC_COUNTER_3); /* Slot 0 Read Byte Count */
  setincrementerrange(XAPM_INCREMENTER_2, 3, 0); /* counts data beats with low strobes on the 32-bit data channel */
#if defined(USE_ACC)
  /* ACC */
  setmetrics(1, XAPM_METRIC_SET_0, XAPM_METRIC_COUNTER_4); /* Slot 1 Write Transaction Count */
  setmetrics(1, XAPM_METRIC_SET_1, XAPM_METRIC_COUNTER_5); /* Slot 1 Read Transaction Count */
  setmetrics(1, XAPM_METRIC_SET_2, XAPM_METRIC_COUNTER_6); /* Slot 1 Write Byte Count */
  setmetrics(1, XAPM_METRIC_SET_3, XAPM_METRIC_COUNTER_6); /* Slot 1 Read Byte Count */
  setincrementerrange(XAPM_INCREMENTER_6, 7, 0); /* counts data beats with low strobes on the 64-bit data channel */
#endif
  intrclear(XAPM_IXR_ALL_MASK);
  resetmetriccounter();
  enablemetricscounter();

#if defined(PAPI)
  PAPI_start_counters(PAPI_events, 7);
#endif
}

void stats_stop(void) {
  disablemetricscounter();

#if defined(PAPI)
  PAPI_read_counters(counters, 7);
#endif
}

void stats_print(void) {
  /*intrglobaldisable();*/
  /*printf("scalefactor is %d\n", params->scalefactor);*/
  printf("Slot TranW TranR ByteW ByteR StrobeLW\r\n");
  printf("CPU %s%u %s%u %s%u %s%u %u\r\n",
    (intrhwgetstatus() & XAPM_IXR_MC0_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_0),
    (intrhwgetstatus() & XAPM_IXR_MC1_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_1),
    (intrhwgetstatus() & XAPM_IXR_MC2_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_2),
    (intrhwgetstatus() & XAPM_IXR_MC3_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_3),
    getincrementer(XAPM_INCREMENTER_2)
    );
#if defined(USE_ACC) 
  printf("ACC %s%u %s%u %s%u %s%u %u\r\n",
    (intrhwgetstatus() & XAPM_IXR_MC4_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_4),
    (intrhwgetstatus() & XAPM_IXR_MC5_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_5),
    (intrhwgetstatus() & XAPM_IXR_MC6_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_6),
    (intrhwgetstatus() & XAPM_IXR_MC7_OVERFLOW_MASK) ? "*" : "", getmetriccounter( XAPM_METRIC_COUNTER_7),
    getincrementer(XAPM_INCREMENTER_6)
    );
#endif

#if defined(PAPI)
  printf("%lld L1 accesses, %lld L1 misses (%.2lf%%), %lld L2 accesses and %lld L2 misses (%.2lf%%)\n", counters[0], counters[1], (double)counters[1]*100 / (double)counters[0],counters[2], counters[3], (double)counters[3]*100 / (double)counters[2]);
  printf("%lld Loads, %lld Stores, %lld Total and %lld Clock cycle\n", counters[4], counters[5], counters[4]+counters[5], counters[6]);
#endif
}

#endif // STATS

#if defined(TRACE)

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

void trace_start(void) {
  starteventlog(
#if TRACE == _TALL_
    XAPM_FLAG_WRADDR|
    XAPM_FLAG_FIRSTWR|
    XAPM_FLAG_LASTWR|
    XAPM_FLAG_RESPONSE|
    XAPM_FLAG_RDADDR|
    XAPM_FLAG_FIRSTRD|
    XAPM_FLAG_LASTRD|
    XAPM_FLAG_SWDATA
#else
    XAPM_FLAG_WRADDR|
    XAPM_FLAG_RDADDR|
    XAPM_FLAG_SWDATA
#endif
    );
  setswdatareg(0xAAAAAAAA);
}

void trace_stop(void)
{
  int i;
  /* flush FIFO in trace capture device with 16 events */
  for (i = 0; i < 16; i++) setswdatareg(0xDEADBEEF);
  stopeventlog();
}

void trace_capture(void) {

  typedef int elem_t;
  register elem_t tmp;

  unsigned long tot = 0;
  struct timeval start, finish;

  elem_t buffer[BLK_SZ/sizeof(elem_t)]; /* File copy buffer */

  int memfd = open("/dev/mem", O_RDWR|O_SYNC);
  if (memfd < 0) {
    printf("Opening file /dev/mem : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }
  /* map in tcd, size is difference of high and base
     addresses of the tcd in xparameter.h for this design/
  */

  volatile elem_t *tcd = (elem_t *) mmap(NULL,
      XPAR_AXI_TCD_0_HIGHADDR - XPAR_AXI_TCD_0_BASEADDR,
      PROT_READ|PROT_WRITE, MAP_SHARED, memfd,
      XPAR_AXI_TCD_0_BASEADDR);

  if (tcd == MAP_FAILED) {
    printf("TCD mmap failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  gettimeofday(&start, NULL); 

  FILE * tfd = fopen("/mnt/tracefile.dat", "w+b");
  if (tfd < 0) {
    printf("Opening file /mnt/tracefile.dat : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  *tcd = 0;
  do { /* grab trace */
    register elem_t *bptr = (elem_t*)buffer;
    unsigned int blen = 0;
    do { /* fill buffer */
      unsigned int i;
      tmp = 0;
      for (i = 0; i < (ENTRY_SZ/sizeof(elem_t)); i++) /* fill entry */
        tmp |= *bptr++ = *tcd;
      blen += ENTRY_SZ;
    } while (tmp && blen < BLK_SZ);
    /* write buffer */
    size_t fr = fwrite(buffer, sizeof(elem_t), blen/sizeof(elem_t), tfd);
    if (fr !=  blen/sizeof(elem_t)) {
      printf("fwrite : bytes requested:%d, actual:%d)\r\n", blen, (int)(fr*sizeof(elem_t)));
      goto tc;
    }
    tot += blen;
    if ((tot & ((1U<<20)-1)) == 0U) printf("\rtrace length:0x%lx\r", tot);
    if (tot >= TRACE_MEM_SZ) {
      printf(" -- error: trace capture memory exceeded\r\n");
      goto tc;
    }
  } while (tmp);

  tc:

  fclose(tfd);

  gettimeofday(&finish, NULL);
  printf("trace length:0x%lx\r\n", tot);
  printf("capture time:%f sec\r\n", 
         (double) (finish.tv_usec - start.tv_usec) / 1000000 +
         (double) (finish.tv_sec - start.tv_sec));
}

void trace_event(int e) {
  setswdatareg(e);
}

#endif // TRACE
