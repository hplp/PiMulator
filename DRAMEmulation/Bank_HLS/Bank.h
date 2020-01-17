#include <iostream>
using namespace std;

enum BusPacketType {
	READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
};

//1024x8192 is the Micron standard
#define NUM_ROWS 256
#define NUM_COLS 256

typedef struct {
	BusPacketType busPacketType;
	unsigned char row;
	unsigned char column;
	unsigned char data_in;
} bank_in;

#define TEST2
