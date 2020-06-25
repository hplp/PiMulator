#include "ddrfsm.h"

int main() {
	int i;
	bool eCLKtr = false;
	bool eCLK = false;

	for (i = 0; i < 100; i++) {
		eCLKtr = ((i % ((rand() % 3) + 2)) == 0) ? true : false;
		eCLK = ddrfsm(eCLKtr, eCLK);
		printf("m0 %d %d %d \n", eCLKtr, eCLK, i);
	}

	return 0;
}
