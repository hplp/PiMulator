#include "lpddrstm.h"

void lpddrstm(volatile int *a, int increment) {

#pragma HLS INTERFACE s_axilite port=increment bundle=args
#pragma HLS INTERFACE m_axi port=a depth=16

	int i;
	int buff[ADEPTH];

	//memcpy(buff, (const int*) a, ADEPTH * sizeof(int));

	inc: for (i = 0; i < ADEPTH; i++) {
#pragma HLS PIPELINE
		a[i] = a[i] + increment;
	}

	//memcpy((int *) a, buff, ADEPTH * sizeof(int));
}
