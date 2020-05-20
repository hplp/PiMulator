#include "lpddrstm.h"

int main() {
	int i, increment = 11;
	int A[ADEPTH];
	int B[ADEPTH];

	//Put data into A
	for (i = 0; i < ADEPTH; i++) {
		A[i] = i;
	}

	//Call the hardware function
	lpddrstm(A, increment);

	//Run a software version of the hardware function to validate results
	for (i = 0; i < ADEPTH; i++) {
		B[i] = i + increment;
	}

	//Compare results
	for (i = 0; i < ADEPTH; i++) {
		if (B[i] != A[i]) {
			printf("i = %d A = %d B= %d\n", i, A[i], B[i]);
			printf("ERROR HW and SW results mismatch\n");
			return 1;
		}
	}
	printf("Success HW and SW results match\n");
	return 0;
}
