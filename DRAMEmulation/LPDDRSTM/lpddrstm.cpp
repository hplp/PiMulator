#include "lpddrstm.h"

bool lpddrstm(bool eCLKtr, bool eCLK) {
//#pragma HLS INTERFACE ap_none port=CLK
//#pragma HLS INTERFACE s_axilite port=eCLKtr bundle=args

	printf("k1 %d %d \n", eCLKtr, eCLK);

	switch (eCLK) {
	case false:
		eCLK = eCLKtr ? true : false;
		break;
	case true:
		eCLK = eCLKtr ? false : true;
		break;
	}

	printf("k2 %d %d \n", eCLKtr, eCLK);
	return eCLK;
}
