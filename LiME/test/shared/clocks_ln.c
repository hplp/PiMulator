/*
 * clocks_ln.c
 *
 *  Created on: Jun 21, 2018
 *      Author: Abhishek Jain
 */


#if defined(CLOCKS)

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
#include "xparam.h"
#include "clocks.h"

#define MAP_SIZE 4096

void clocks_emulate(void)
{
  volatile unsigned int *delay0;
  volatile unsigned int *delay1;
  // volatile unsigned int *delay2;
  // volatile unsigned int *delay3;
  int delay0_fd;
  int delay1_fd;
  FILE *fp;

  delay0_fd = open("/dev/mem", O_RDWR|O_SYNC);
  if (delay0_fd < 0) {
    printf("Opening file /dev/mem : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  delay0 = (unsigned int *)mmap(NULL,
      XPAR_AXI_DELAY_0_HIGHADDR - XPAR_AXI_DELAY_0_BASEADDR,
      PROT_READ|PROT_WRITE, MAP_SHARED, delay0_fd,
      XPAR_AXI_DELAY_0_BASEADDR);

  if (delay0 == MAP_FAILED) {
    printf("delay0 mmap failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n",strerror(errno));
    exit(1);
  }

  delay1_fd = open("/dev/mem", O_RDWR|O_SYNC);
  if (delay1_fd < 0) {
    printf("Opening file /dev/mem : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  delay1 = (unsigned int *)mmap(NULL,
      XPAR_AXI_DELAY_1_HIGHADDR - XPAR_AXI_DELAY_1_BASEADDR,
      PROT_READ|PROT_WRITE, MAP_SHARED, delay1_fd,
      XPAR_AXI_DELAY_1_BASEADDR);

  if (delay1 == MAP_FAILED) {
    printf("delay1 mmap failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  fp = fopen("/sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed", "w+b");
  if (fp == NULL) {
    printf("Opening file for frequency scaling : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  {char *str = (char *)"137999"; fwrite(str, sizeof(char), sizeof(str), fp);}
  delay0[2] = 6*(T_SRAM_W+T_TRANS)           - 52; delay0[4] = 6*(T_SRAM_R+T_TRANS)           - 69; /* .16 ns per count */
  delay1[2] = 6*(T_DRAM_W+T_QUEUE_W+T_TRANS) - 52; delay1[4] = 6*(T_DRAM_R+T_QUEUE_R+T_TRANS) - 69;
  // delay2[2] = 6*(T_SRAM_W)                   - 48; delay2[4] = 6*(T_SRAM_R)                   - 66;
  // delay3[2] = 6*(T_DRAM_W+T_QUEUE_W)         - 48; delay3[4] = 6*(T_DRAM_R+T_QUEUE_R)         - 66;

  printf("SRAM_W:%d SRAM_R:%d DRAM_W:%d DRAM_R:%d\nQUEUE_W:%d QUEUE_R:%d TRANS:%d W:%d R:%d\n",
    T_SRAM_W, T_SRAM_R, T_DRAM_W, T_DRAM_R, T_QUEUE_W, T_QUEUE_R, T_TRANS,
    T_DRAM_W+T_QUEUE_W+T_TRANS, T_DRAM_R+T_QUEUE_R+T_TRANS);
  // printf("ARM_PLL_CTRL:%08X DDR_PLL_CTRL:%08X IO_PLL_CTRL:%08X\n", *apll_c, *dpll_c, *iopll_c);
  // printf("ARM_CLK_CTRL:%08X DDR_CLK_CTRL:%08X\n", *arm_cc, *ddr_cc);
  // printf("FPGA0_CLK_CTRL:%08X FPGA1_CLK_CTRL:%08X\n", *fpga0_cc, *fpga1_cc);
  printf("Slot 0 - CPU_SRAM_B:%u CPU_SRAM_R:%u CPU_DRAM_B:%u CPU_DRAM_R:%u\n", delay0[2], delay0[4], delay1[2], delay1[4]);
  // printf("Slot 1 - ACC_SRAM_B:%u ACC_SRAM_R:%u ACC_DRAM_B:%u ACC_DRAM_R:%u\n", delay2[2], delay2[4], delay3[2], delay3[4]);

  fclose(fp);
  munmap((void *)delay0, MAP_SIZE);
  munmap((void *)delay1, MAP_SIZE);
  close(delay0_fd);
  close(delay1_fd);
}

void clocks_normal(void)
{
  volatile unsigned int *delay0;
  volatile unsigned int *delay1;
  // volatile unsigned int *delay2;
  // volatile unsigned int *delay3;
  int delay0_fd;
  int delay1_fd;
  FILE *fp;

  delay0_fd = open("/dev/mem", O_RDWR|O_SYNC);
  if (delay0_fd < 0) {
    printf("Opening file /dev/mem : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  delay0 = (unsigned int *)mmap(NULL,
      XPAR_AXI_DELAY_0_HIGHADDR - XPAR_AXI_DELAY_0_BASEADDR,
      PROT_READ|PROT_WRITE, MAP_SHARED, delay0_fd,
      XPAR_AXI_DELAY_0_BASEADDR);

  if (delay0 == MAP_FAILED) {
    printf("delay0 mmap failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n",strerror(errno));
    exit(1);
  }

  delay1_fd = open("/dev/mem", O_RDWR|O_SYNC);
  if (delay1_fd < 0) {
    printf("Opening file /dev/mem : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  delay1 = (unsigned int *)mmap(NULL,
      XPAR_AXI_DELAY_1_HIGHADDR - XPAR_AXI_DELAY_1_BASEADDR,
      PROT_READ|PROT_WRITE, MAP_SHARED, delay1_fd,
      XPAR_AXI_DELAY_1_BASEADDR);

  if (delay1 == MAP_FAILED) {
    printf("delay1 mmap failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  fp = fopen("/sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed", "w+b");
  if (fp == NULL) {
    printf("Opening file for frequency scaling : Failed\n");
    printf("Error no is : %d\n", errno);
    printf("Error description is : %s\n", strerror(errno));
    exit(1);
  }

  {char *str = (char *)"1099999"; fwrite(str, sizeof(char), sizeof(str), fp);}
  delay0[2] = 0; delay0[4] = 0; delay1[2] = 0; delay1[4] = 0;
  // delay2[2] = 0; delay2[4] = 0; delay3[2] = 0; delay3[4] = 0;

  fclose(fp);
  munmap((void *)delay0, MAP_SIZE);
  munmap((void *)delay1, MAP_SIZE);
  close(delay0_fd);
  close(delay1_fd);
}

#endif /* CLOCKS */
