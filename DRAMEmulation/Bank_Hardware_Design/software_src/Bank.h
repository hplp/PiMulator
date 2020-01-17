#include "Constants.h"
#include "Definitions.h"

//1024x8192 is the Micron standard
#define NUM_ROWS 256
#define NUM_COLS 256

typedef struct {
	BusPacketType busPacketType;
	unsigned char row;
	unsigned char column;
	unsigned char data_in;
} bank_in;

// Bank Function that is to be mapped to Hardware IP
void Bank(bank_in input, unsigned char& data_out);
