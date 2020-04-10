#include <stdio.h>
#include <unistd.h>
#include <cstdlib>

#include "xil_types.h"
#include "xtmrctr.h"
#include "xparameters.h"

#include "xstatus.h"
#include "xil_printf.h"

#define CLK_FREQ XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ

XTmrCtr AxiTimerInit() {
	XTmrCtr m_AxiTimer;
	XTmrCtr_Initialize(&m_AxiTimer, XPAR_TMRCTR_0_DEVICE_ID);
	return m_AxiTimer;
}

unsigned int AxiTimerStart(XTmrCtr m_AxiTimer) {
	XTmrCtr_Reset(&m_AxiTimer, 0);
	XTmrCtr_Start(&m_AxiTimer, 0);
	unsigned int tStart = XTmrCtr_GetValue(&m_AxiTimer, 0);
	return tStart;
}

unsigned int AxiTimerStop(XTmrCtr m_AxiTimer) {
	XTmrCtr_Stop(&m_AxiTimer, 0);
	unsigned int tEnd = XTmrCtr_GetValue(&m_AxiTimer, 0);
	return tEnd;
}

double getDuration(unsigned int tStart, unsigned int tEnd) {
	return (double) (tEnd - tStart) / CLK_FREQ;
}

unsigned long int getDuration_us(unsigned int tStart, unsigned int tEnd) {
	return (unsigned long int) 1000000 * (tEnd - tStart) / CLK_FREQ;
}

int main() {

	XTmrCtr m_AxiTimer = AxiTimerInit();

	printf("\n");
	printf("Hello! This is Alveo U280!\n");
	unsigned long int sum = 0;

	unsigned int tStart = AxiTimerStart(m_AxiTimer);
	for (unsigned int i = 0; i < 1000000; i++) {
		sum = sum + i;
	}
	printf("sum(0..1000000)=%lu\n", sum);
	unsigned int tEnd = AxiTimerStop(m_AxiTimer);

	printf("Start=%d End=%d\n", tStart, tEnd);
	printf("Elapsed %d clks\n", (tEnd - tStart));
	printf("Elapsed_gD_us %lu us\n", getDuration_us(tStart, tEnd));
	printf("Elapsed_gD    %f  s\n", getDuration(tStart, tEnd));
	printf("return 0 \n");

	return 0;
}
