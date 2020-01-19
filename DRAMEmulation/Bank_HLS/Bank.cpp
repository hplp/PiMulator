/*********************************************************************************
 *  Copyright (c) 2010-2011,   Elliott Cooper-Balis
 *                             Paul Rosenfeld
 *                             Bruce Jacob
 *                             University of Maryland
 *                             dramninjas [at] gmail [dot] com
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notice,
 *        this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above copyright notice,
 *        this list of conditions and the following disclaimer in the documentation
 *        and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *********************************************************************************/

/**************************************************************************************
 * Hardware Model for DDR3 Bank
 * NOTE: even though model is based on DRAMSim2, the C-code is modified fundamentally to
 * reflect DDR3 Bank operation in Hardware
 * Added is row buffer, as well as an accurate representation of what happens in DRAM during each Bank Command.
 * The Memory being used is BRAM: BRAM is configured to be NUM_COLUMS * 8 bits wide, so that one can read
 * an entire row of memory data (a.k.a. ACTIVATE a row) during 1 clock cycle. (see #pragma after each array declaration)
 * Here are things that need to be added or improved
 * 1) add sub-array row buffers: a bank is divided into sub-arrays, where each one has its own row buffer
 * 	  the current emulation models the entire bank with only 1 row buffer, so to be more accurate
 * 	  (1.1) divide main memory array into sub-arrays (1.2) create row buffer (as the one we already have) for each sub-array
 * 2) Max out BRAM usage: current Bank usage is configured 256x256 bytes to max out Pynq Board BRAM resources
 * 	  Synthesize for a bigger board (e.g. UltraZed EG) and max BRAM (or make memory rows x columns configuration as large as possible for the new board)
 * 3) Map BRAM to DRAM (** HARDEST AND MOST CRITICAL **): Instead of BRAM, emulate with DRAM, or abstract DRAM (see LiME paper) so that bank sees a black
 * 	  box for memory access, which is made of DRAM. This is challenging because BRAM can be configured to have the width we want, but DRAM  cannot be
 * 	  Suggestion: see if we have control over activating an entire row of DRAM cells, which can serve our purpose
 * 4) Make DDR3 commands accurate: I have put some logic to carry out commands in BusPacketType, to make our emulation DDR3-accurate,
 * 	  if some commands are missing, they will need to be added; or the already coded commands may need to be adjusted for sub-array configuration,
 * 	  greater accuracy to DDR3 Bank operation, etc.
 *
 *	PS: please see ? and TODO in code where things might need to be checked or worked on
 *
 ****************************************************************************************/

// The following code models a DDR3 Bank as a C++ function that will undergo HLS synthesis
#include "Bank.h"

void Bank(bank_in input, unsigned char& data_out) {

#pragma HLS INTERFACE s_axilite register port=input bundle=Bank
#pragma HLS INTERFACE s_axilite register port=data_out bundle=Bank
#pragma HLS INTERFACE s_axilite register port=return bundle=Bank

	BusPacketType busPacketType = input.busPacketType;
	unsigned row = input.row;
	unsigned column = input.column;
	unsigned char data_in = input.data_in;

	/*	// decide which memory to use (for the sake of saving FPGA resource) done before to split memory into BRAM and LUT config (IGNORE)
	 //	bool LUT_use = (row > 255);
	 //	if (LUT_use) {
	 //		row = row % 256;
	 //	}
	 //	if (EN)
	 //	{
	 //		printf("busPacketType: %d, row: %d, column: %d, data_in: %d \n ",busPacketType,row,column,data_in);
	 //	}
	 //*/

// Memory
// main memory
	static unsigned char rowEntries[NUM_ROWS][NUM_COLS];
#pragma HLS array_partition variable=rowEntries complete dim=2

// for Resource Usage Limit we need to split main memory into (1) BRAM and (2) LUTRAM
//	static unsigned char rowEntries_BRAM[NUM_ROWS / 2][NUM_COLS];
//#pragma HLS array_partition variable=rowEntries_BRAM complete dim=2
//#pragma HLS RESOURCE variable=rowEntries_BRAM core=RAM_1P_BRAM
//
//	static unsigned char rowEntries_LUT[NUM_ROWS / 2][NUM_COLS];
//#pragma HLS array_partition variable=rowEntries_LUT complete dim=2
//#pragma HLS RESOURCE variable=rowEntries_LUT core=RAM_1P_LUTRAM

// Row Buffer
	static unsigned char rowBuffer[NUM_COLS];
#pragma HLS array_partition variable=rowBuffer complete dim=1

// commands execution (TODO: check and add commands if needed, modify when sub-arrays added)

// ACTIVATE
	if (busPacketType == ACTIVATE) {
		//* upgrade row buffer
		for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
			rowBuffer[j] = rowEntries[row][j];
			//			rowBuffer[j] =
			//					(LUT_use) ?
			//							rowEntries_LUT[row][j] : rowEntries_BRAM[row][j];
		}
	}
	// READ
	//* read from row buffer
	if (busPacketType == READ || busPacketType == READ_P) {
		// extract column
		data_out = rowBuffer[column];
		//the return packet should be a data packet, not a read packet
		busPacketType = DATA;
	}
	// WRITE
	if (busPacketType == WRITE || busPacketType == WRITE_P) {
		// write column to row buffer
		rowBuffer[column] = data_in;

		//write back row buffer
		for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
			rowEntries[row][j] = rowBuffer[j];
		}
	}
	// PRECHARGE
	//* double check: clear out contents of row buffer, write all zeros ?
	if (busPacketType == PRECHARGE) {
		for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
			rowBuffer[j] = 0;
		}
	}
	// REFRESH

	//* doube check: read all contents and write all contents back (read / write all rows via row buffer)?
	//* this latency will be significantly improved when we have sub-arrays

	if (busPacketType == REFRESH) {

		Refresh_Loop: for (int i = 0; i < NUM_ROWS; i++) {
			// read row into row buffer
			for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
				rowBuffer[j] = rowEntries[i][j];
			}
			//write row buffer back
			for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
				rowEntries[i][j] = rowBuffer[j];
			}
		}
	}
}

//void Bank(BusPacketType busPacketType, unsigned row, unsigned column, unsigned char data_in, unsigned char& data_out) {}

//#pragma HLS INTERFACE s_axilite register port=busPacketType bundle=Bank
//#pragma HLS INTERFACE s_axilite register port=row bundle=Bank
//#pragma HLS INTERFACE s_axilite register port=column bundle=Bank
//#pragma HLS INTERFACE s_axilite register port=data_in bundle=Bank
//#pragma HLS INTERFACE s_axilite register port=data_out bundle=Bank
//#pragma HLS INTERFACE s_axilite register port=return bundle=Bank

//separate input signals (shift and mask)
//unsigned char busPacketType = input % 8;
//unsigned row = (input >> 3) % 256;
//unsigned column = (input >> 11) % 256;
//unsigned char data_in = (input >> 19) % 256;
