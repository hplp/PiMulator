#define BANK_H
#ifdef BANK_H
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

#include "Bank.h"

void Bank(bank_in input, unsigned char& data_out) {

	unsigned char busPacketType = input.busPacketType;
	unsigned row = input.row;
	unsigned column = input.column;
	unsigned char data_in = input.data_in;

// Memory (main memory)
	static unsigned char rowEntries[NUM_ROWS][NUM_COLS];

// Row Buffer
	static unsigned char rowBuffer[NUM_COLS];

// ACTIVATE
	if (busPacketType == ACTIVATE) {
		//* upgrade row buffer
		for (int j = 0; j < NUM_COLS; j++) {
			rowBuffer[j] = rowEntries[row][j];
		}
	}

	// READ
	// read from row buffer
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
			rowEntries[row][j] = rowBuffer[j];
		}
	}

	// PRECHARGE
	// double check: clear out contents of row buffer, write all zeros ?
	if (busPacketType == PRECHARGE) {
		for (int j = 0; j < NUM_COLS; j++) {
			rowBuffer[j] = 0;
		}
	}

	// REFRESH
	if (busPacketType == REFRESH) {

		for (int i = 0; i < NUM_ROWS; i++) {
			// read row into row buffer
			for (int j = 0; j < NUM_COLS; j++) {
				rowBuffer[j] = rowEntries[i][j];
			}
			//write row buffer back
			for (int j = 0; j < NUM_COLS; j++) {
				rowEntries[i][j] = rowBuffer[j];
			}
		}
	}
}

#endif
