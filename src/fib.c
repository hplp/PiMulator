#include <stdio.h>
#include <stdlib.h>

// This program computes the nth fibonacci number

int rfib(int n){
	if(n <= 1){
		return n;
	}
	else{
		return rfib(n-1) + rfib(n-2);
	}
}

int main(int argc, char *argv[]){
	int n = atoi(argv[1]);
	printf("Computing FIB(%d)\n", n);
	printf("%d\n", rfib(n));
	return 0;
}
