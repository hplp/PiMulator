#include "lpddrstm.h"

int main() {
	int i;
	bool eCLKtr = false;
	bool eCLK = false;

	for (i = 0; i < 100; i++) {
		eCLK = lpddrstm(eCLKtr, eCLK);
		printf("m0 %d %d %d \n", eCLKtr, eCLK, i);
		eCLKtr = (i % 2 == 0) ? !eCLKtr : eCLKtr;
	}

	return 0;
}
