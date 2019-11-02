#include <iostream>

using namespace std;

enum BusPacketType {
    READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
};

//1024x8192 is the Micron standard
#define NUM_ROWS 256
#define NUM_COLS 256
