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

// The following code models a DDR3 Bank as a C++ function that will undergo HLS synthesis
enum BusPacketType {
	READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
};

//8192
#define NUM_ROWS 512
#define NUM_COLS 512

void Bank(BusPacketType busPacketType, unsigned row, unsigned column,
		 unsigned char data_in, unsigned char& data_out) {

#pragma HLS INTERFACE s_axilite register port=busPacketType bundle=BankBundle
#pragma HLS INTERFACE s_axilite register port=row bundle=BankBundle
#pragma HLS INTERFACE s_axilite register port=column bundle=BankBundle
#pragma HLS INTERFACE s_axilite register port=data_in bundle=BankBundle
#pragma HLS INTERFACE s_axilite register port=data_out bundle=BankBundle
#pragma HLS INTERFACE s_axilite register port=return bundle=BankBundle



// Memory
	static unsigned char rowEntries[NUM_ROWS * NUM_COLS];
	// create as BRAM (1 port)
#pragma HLS RESOURCE variable=rowEntries core=RAM_1P_BRAM
	// Row Buffer
	unsigned char rowBuffer[NUM_COLS];
	// create as BRAM (2 port)
#pragma HLS RESOURCE variable=rowBuffer core=RAM_S2P_BRAM

// concatenate as 1 array in order to save BRAM
//#pragma HLS ARRAY_MAP variable=rowEntries instance=BANK_BRAM horizontal
//#pragma HLS ARRAY_MAP variable=rowBuffer instance =BANK_BRAM horizontal

// allocate as LUTRAM
//#pragma HLS RESOURCE variable=rowBuffer core=RAM_1P_LUTRAM

// reading, writing transaction (TODO: add all other Commands)

	if (busPacketType == READ || busPacketType == WRITE) {
		// upgrade row buffer


		for (int j = 0; j < NUM_COLS; j++) {
#pragma HLS unroll
			rowBuffer[j] = rowEntries[row * NUM_ROWS + j];
		}

		// 2 different paths depending on whether we read or write
		if (busPacketType == READ) {
			// extract column
			data_out = rowBuffer[column];
			//the return packet should be a data packet, not a read packet
			busPacketType = DATA;
		} else if (busPacketType == WRITE) {
			// write column
			rowBuffer[column] = data_in;
		}

		//write back row buffer
		for (int i = 0; i < NUM_COLS; i++) {
#pragma HLS unroll
			rowEntries[row * NUM_COLS + i] = rowBuffer[i];
		}

	}
}
