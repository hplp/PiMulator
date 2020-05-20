#include "lpddrstm.h"

void lpddrstm(volatile int *a, int increment, bool *CLK) {

#pragma HLS INTERFACE s_axilite port=increment bundle=args
#pragma HLS INTERFACE m_axi port=a depth=16

	bool CLKSTM = 0;

	inc: for (int i = 0; i < ADEPTH; i++) {
#pragma HLS PIPELINE
		a[i] = a[i] + increment;
	}

	switch (CLKSTM) {
	case 0:
		CLKSTM = 1;
		break;
	case 1:
		CLKSTM = 0;
		break;
	}

	*CLK = &CLKSTM;
}
