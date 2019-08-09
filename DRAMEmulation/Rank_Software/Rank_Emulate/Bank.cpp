#include "Bank.h"


//#define BANK_H
#ifdef BANK_H
//#include "Definitions.h"

// bank interface

void bank(
	// added
	//bool EN_i,
	unsigned id,
	// input
	BusPacketType busPacketType,
	unsigned row,
	unsigned column,
	const unsigned char data_in,
	//output
	unsigned char& data_out
) {
	// Bank has Enable Signal allowing it to receive inputs only when EN signal is ON

	//internal signal
	//static bool EN = false;
	/*static BusPacketType busPacketType;
	static unsigned row;
	static unsigned column;
	static unsigned char data_in;*/


	//EN = EN_i;
	// only when EN is ON we update internal signals

		//inputs
		//busPacketType = busPacketType_i;
		//row = row_i;
		//column = column_i;
		//data_in = data_in_i;


		//#pragma HLS INTERFACE s_axilite register port=busPacketType bundle=BankBundle
		//#pragma HLS INTERFACE s_axilite register port=row bundle=BankBundle
		//#pragma HLS INTERFACE s_axilite register port=column bundle=BankBundle
		//#pragma HLS INTERFACE s_axilite register port=data_in bundle=BankBundle
		//#pragma HLS INTERFACE s_axilite register port=data_out bundle=BankBundle
		//#pragma HLS INTERFACE s_axilite register port=return bundle=BankBundle




	// static memory creation based on ID 

	unsigned char* rowEntries;

	switch (id)
	{
	case 0:
		static unsigned char rowEntries0[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries0;
		break;
	case 1:
		static unsigned char rowEntries1[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries1;
		break;
	case 2:
		static unsigned char rowEntries2[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries2;
		break;
	case 3:
		static unsigned char rowEntries3[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries3;
		break;
	case 4:
		static unsigned char rowEntries4[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries4;
		break;
	case 5:
		static unsigned char rowEntries5[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries5;
		break;
	case 6:
		static unsigned char rowEntries6[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries6;
		break;
	default:
		static unsigned char rowEntries7[NUM_ROWS * NUM_COLS];
		rowEntries = rowEntries7;
		break;
	}


	// create as BRAM (1 port)
	//#pragma HLS RESOURCE variable=rowEntries core=RAM_1P_BRAM
	// Row Buffer
	unsigned char rowBuffer[NUM_COLS];
	// create as BRAM (2 port)
	//#pragma HLS RESOURCE variable=rowBuffer core=RAM_S2P_BRAM

	// concatenate as 1 array in order to save BRAM
	////#pragma HLS ARRAY_MAP variable=rowEntries instance=BANK_BRAM horizontal
	////#pragma HLS ARRAY_MAP variable=rowBuffer instance =BANK_BRAM horizontal

	// allocate as LUTRAM
	////#pragma HLS RESOURCE variable=rowBuffer core=RAM_1P_LUTRAM

	// reading, writing transaction (TODO: add all other Commands)
	//if (EN) {
	if (busPacketType == READ || busPacketType == WRITE) {
		// upgrade row buffer


		for (int j = 0; j < NUM_COLS; j++) {
			//#pragma HLS unroll
			rowBuffer[j] = rowEntries[row * NUM_ROWS + j];
		}

		// 2 different paths depending on whether we read or write
		if (busPacketType == READ) {
			// extract column
			data_out = rowBuffer[column];
			//the return packet should be a data packet, not a read packet
			busPacketType = DATA;
		}
		else if (busPacketType == WRITE) {
			// write column
			rowBuffer[column] = data_in;
		}

		//write back row buffer
		for (int i = 0; i < NUM_COLS; i++) {
			//#pragma HLS unroll
			rowEntries[row * NUM_COLS + i] = rowBuffer[i];
		}

	}
}
//}

// arbiter function to interface with Banks
// helps rank to select specific bank and interface with it

//void banks_arbiter(
//	// input
//	unsigned bank_id,
//	BusPacketType busPacketType,
//	unsigned row,
//	unsigned column,
//	const unsigned char data_in,
//	// output
//	unsigned char& data_out
//
//)
//{
//	unsigned char data_out_i[8];
//
//	// create static array of bank object
//	static Bank banks[8];
//	static bool banks_EN[8];
//	// Write to Banks (decoder logic in hardware)
//	for (int i = 0; i < 8; i++) {
//		banks_EN[i] = (i == bank_id) ? true : false;
//		banks[i].bank(banks_EN[i], busPacketType, row, column, data_in, data_out_i[i]);
//	}
//	// Read from Banks (mux logic in hardware)
//	for (int i = 0; i < 8; i++) {
//		if (i == bank_id) {
//			data_out = data_out_i[i];
//		}
//	}
//
//}

#endif