/*********************************************************************************
*  Copyright (c) 2010-2011, Elliott Cooper-Balis
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


// Software Interface for Rank
// Controls Banks throug Output Signals (Controls 8 bank functions with static memories)
// can get inputs in terms of commands (from software or from memory controller)

#ifndef RANK_H
#define RANK_H
#endif
#ifdef  RANK_H

#include "Bank.h"
//#include <vector>
using namespace std;
#define readReturnPacket_size 32
//#include "SimulatorObject.h"
//#include "SystemConfiguration.h"
//#include "Definitions.h"
//#include "SystemConfiguration.h"
//#include "PrintMacros.h"
//#include "AddressMapping.h"
//#include "BusPacket.h"
//#include "BankState.h"
//using namespace DRAMSim;
//class MemoryController; //forward declaration

// replacing vector of BusPacket* (size fixed to readReturnPacket_size)

struct vector_Bus_Packet {
	// constructor  
	vector_Bus_Packet() {
		for (int i = 0; i < readReturnPacket_size; i++) {
			readReturnPacket[i] = NULL;
		}
		size = 0;
	}
	// attrubutes
	BusPacket * readReturnPacket[readReturnPacket_size];
	int size;
	// add elements
	void push_back(BusPacket* bp) {
		if (size != readReturnPacket_size) {
			readReturnPacket[size] = bp;
			size++;
		}
	}
	// access element
	BusPacket* at(int pos) {
		if (pos < size) {
			return readReturnPacket[pos];
		}
		else {
			return NULL;
		}
	}
	// erase 1st element
	void pop() {
		for (int i = 1; i < size; i++) {
			readReturnPacket[i - 1] = readReturnPacket[i];
		}
		if (readReturnPacket[size] != NULL) {
			delete readReturnPacket[size];
			readReturnPacket[size] = NULL;
		}
		size--;
	}
	// clear 
	void clear() {
		for (int i = 0; i < size; i++) {
			if (readReturnPacket[i] != NULL) {
				delete readReturnPacket[i];
				readReturnPacket[i] = NULL;
			}
		}
		size = 0;
	}
};

// replacing vector of unsigned type (size fixed to readReturnPacket_size)

struct vector_unsigned {
	// constructor  
	vector_unsigned() {
		for (int i = 0; i < readReturnPacket_size; i++) {
			unsigned_arr[i] = 0;
		}
		size = 0;
	}
	// attrubutes
	unsigned unsigned_arr[readReturnPacket_size];
	int size;
	// add elements
	void push_back(unsigned u) {
		if (size != readReturnPacket_size) {
			unsigned_arr[size] = u;
			size++;
		}
	}
	// access element
	unsigned at(int pos) {
		if (pos < size) {
			return unsigned_arr[pos];
		}
		else {
			return 0;
		}
	}
	// erase 1st element
	void pop() {
		for (int i = 1; i < size; i++) {
			unsigned_arr[i - 1] = unsigned_arr[i];
		}
		size--;
	}
	// clear 
	void clear() {
		for (int i = 0; i < size; i++) {
			unsigned_arr[i] = 0;
		}
		size = 0;
	}
};

// Banks States, info kept by rank

enum CurrentBankState
{
	Idle,
	RowActive,
	Precharging,
	Refreshing,
	PowerDown
};

struct BankState {

	CurrentBankState currentBankState;
	unsigned openRowAddress;
	unsigned long int nextRead;
	unsigned long int nextWrite;
	unsigned long int nextActivate;
	unsigned long int nextPrecharge;
	unsigned long int nextPowerUp;

	BusPacketType lastCommand;
	unsigned stateChangeCountdown;
	BankState() :
		currentBankState(Idle),
		openRowAddress(0),
		nextRead(0),
		nextWrite(0),
		nextActivate(0),
		nextPrecharge(0),
		nextPowerUp(0),
		lastCommand(READ),
		stateChangeCountdown(0)
	{}
	void print()
	{
		printf("Bank State Info: currentBankState: %d, openRowAddress: %u, nextRead: %u,nextWrite: %u, nextActivate: %u, nextPrecharge: %u"
			" nextPowerUp: %u, lastCommand:  %u, stateChangeCountdown: %u\n", currentBankState, openRowAddress, nextRead, nextWrite, nextActivate,
			nextPrecharge, nextPowerUp, lastCommand, stateChangeCountdown);

	}
};

// rank Object 
class Rank
{
public:
	// Inputs (from Memory Controller)
	void receiveFromBus(BusPacket *packet); // means of ACTIVATE, READ, WRITE, PRECHARGE
	void powerUp();							// ON
	void powerDown();						// OFF
	void update();							// means of transferring READ data back to memory controller
	bool refreshWaiting;					// memory controller tells rank it needs refresh

	// Outputs (to Banks or to Memory Controller)

	//* going to Memory Controller
	BusPacket *outgoingDataPacket;          // data going to MCC

	//* going to Banks (means of passing commands to Banks)
	unsigned bank_id; //selects which bank
	BusPacketType bank_busPacketType;
	unsigned  bank_row;
	unsigned  bank_column;
	unsigned char bank_data_in;
	unsigned char bank_data_out;

	// Internal Signals (a.k.a Control Logic)
	BankState bankStates[8];			// keep track of Bank States (for proper commands timing)
	uint64_t currentClockCycle;				// clk signal (or counter keeping track of clock cycles for proper commands timing)

	// transform to arrays of fixed size
	//BusPacket**readReturnPacket;   // keep track of what goes back to MCC
	//unsigned *readReturnCountdown;	// keep track of what goes back to MCC

	vector_Bus_Packet readReturnPacket;		// keep track of what goes back to MCC
	vector_unsigned readReturnCountdown;	// keep track of what goes back to MCC
	//vector<BusPacket *> readReturnPacket;  // keep track of what goes back to MCC
	//vector<unsigned> readReturnCountdown;	// keep track of what goes back to MCC


	bool isPowerDown;						// is Rank tuned OFF
	int id;									// ID of Rank
	unsigned dataCyclesLeft;				// house-keeping of cycles left until transfer of data

	// debug

	void print_param();
	void print_debug();

	// extra (no need in hardware)
	//---------------------------------------------------------------------------------------------------------------------------------------

	//ostream &dramsim_log;
	unsigned incomingWriteBank;
	unsigned incomingWriteRow;
	unsigned incomingWriteColumn;

	//functions
	Rank();
	virtual ~Rank();
	//getter, setter (not needed, everything is public)
	//int getId() const;
	//void setId(int id);
};
#endif

// old code of Rank object

//fields
//void attachMemoryController(MemoryController *mc);
//MemoryController *memoryController;

// where we can observe the data


//these are vectors so that each element is per-bank


//
