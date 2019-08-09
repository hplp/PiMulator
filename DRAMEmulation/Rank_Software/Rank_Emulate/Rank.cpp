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
#include "Rank.h"

//using namespace std;


#define BANK_TRANSACTION bank(bank_id, bank_busPacketType, bank_row, bank_column, bank_data_in, bank_data_out);


// performs READ of Bank
// Bank transaction happen in 2 steps: (1) set interface signals and (2) call bank function (which represents seperate chip)
#define BANK_READ \
	bank_id = packet->bank;\
	bank_busPacketType = READ;\
	bank_row = packet->row;\
	bank_column = packet->column;\
	bank_data_in = 0;\
	bank(bank_id, bank_busPacketType, bank_row, bank_column, bank_data_in, bank_data_out);\
	packet->data = bank_data_out;

// performs WRITE of Bank
// Bank transaction happen in 2 steps: (1) set interface signals and (2) call bank function (which represents seperate chip)
#define BANK_WRITE \
	bank_id = packet->bank;\
	bank_busPacketType = WRITE;\
	bank_row = packet->row;\
	bank_column = packet->column;\
	bank_data_in = packet->data;\
	bank_data_out = packet->data; \
	bank(bank_id, bank_busPacketType, bank_row, bank_column, bank_data_in, bank_data_out);

void Rank::print_param()
{
	printf("Params for WRITE:\n");
	printf("(READ) READ_TO_WRITE_DELAY: %d\n", READ_TO_WRITE_DELAY);
	printf("(WRITE): %d\n", max(BL / 2, tCCD));
	printf("(ACTIVATE): %d\n", (tRCD - AL));

	printf("\nParams for READ:\n");

	printf("(READ):%d\n", max(tCCD, BL / 2));
	printf("(WRITE):%d\n", WRITE_TO_READ_DELAY_B);
	printf("(ACTIVATE):%d\n", tRCD - AL);

	printf("\nParams for ACTIVATE:\n");

	printf("(READ_P):%d\n", READ_AUTOPRE_DELAY);
	printf("(WRITE_P):%d\n", WRITE_AUTOPRE_DELAY);
	printf("(ACTIVATE, current bank):%d\n", tRC);
	printf("(ACTIVATE, all other bank):%d\n", tRRD);
	printf("(PRECHARGE):%d\n", tRP);
	printf("(REFRESH):%d\n", tRFC);

	printf("\nParams for PRECHARGE:\n");

	printf("(READ): %d\n", READ_TO_PRE_DELAY);
	printf("(WRITE): %d\n", WRITE_TO_PRE_DELAY);
	printf("(ACTIVATE): %d\n", tRAS);

	printf("\n\nExtra\nRL:%d\n", RL);

}


Rank::Rank() :
	id(-1),
	//dramsim_log(dramsim_log_),
	isPowerDown(false),
	refreshWaiting(false)
	//readReturnCountdown(0)
	//banks(NUM_BANKS, Bank()),
	//bankStates(NUM_BANKS, BankState())

{
	//memoryController = NULL;
	outgoingDataPacket = NULL;
	dataCyclesLeft = 0;
	currentClockCycle = 0;

#ifndef NO_STORAGE
#endif

}


Rank::~Rank()
{
	//for (size_t i = 0; i < readReturnPacket.size(); i++)
	//{
	//	delete readReturnPacket[i];
	//}
	readReturnPacket.clear();
	delete outgoingDataPacket;
}
// MOST IMPORTANT ....

void Rank::receiveFromBus(BusPacket *packet)
{
	if (DEBUG_BUS)
	{
		printf(" -- R %d  Receiving On Bus    : ", this->id);
		
		packet->print();
	}
	if (VERIFICATION_OUTPUT)
	{
		packet->print();
		//packet->print(currentClockCycle, false);
	}

	switch (packet->busPacketType)
	{
	case READ:
		//make sure a read is allowed
		if (bankStates[packet->bank].currentBankState != RowActive ||
			currentClockCycle < bankStates[packet->bank].nextRead ||
			packet->row != bankStates[packet->bank].openRowAddress)
		{
			packet->print();
			printf("== Error - Rank %d received a READ when not allowed",id);
			exit(0);
		}

		//update state table
		bankStates[packet->bank].nextPrecharge = max(bankStates[packet->bank].nextPrecharge, currentClockCycle + READ_TO_PRE_DELAY);
		//printf("\n\n"); 
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			bankStates[i].nextRead = max(bankStates[i].nextRead, currentClockCycle + max(tCCD, BL / 2)); 
			bankStates[i].nextWrite = max(bankStates[i].nextWrite, currentClockCycle + READ_TO_WRITE_DELAY); 
			//printf("(READ)Bank %d: next_Read: %d, next_Write: %d\n", i,(bankStates[i].nextRead), bankStates[i].nextWrite );
		}

		//get the read data and put it in the storage which delays until the appropriate time (RL)
#ifndef NO_STORAGE
		// read bank
		BANK_READ
			//banks[packet->bank].bank(READ, packet->row, packet->column, 0, packet->data);
			//printf("Data: %d\n", packet->data); 
#else
		packet->busPacketType = DATA;
#endif
		//printf("packet->data : %d\n", packet->data); 
		readReturnPacket.push_back(packet);

		//printf("readReturnPacket: %d and we have to wait %d cycle\n", readReturnPacket.at(0)->data,RL);

		readReturnCountdown.push_back(RL);
		break;
	case READ_P:
		//make sure a read is allowed
		if (bankStates[packet->bank].currentBankState != RowActive ||
			currentClockCycle < bankStates[packet->bank].nextRead ||
			packet->row != bankStates[packet->bank].openRowAddress)
		{
			printf("== Error - Rank  %d received a READ_P when not allowed", id);
			exit(-1);
		}

		//update state table
		bankStates[packet->bank].currentBankState = Idle;
		bankStates[packet->bank].nextActivate = max(bankStates[packet->bank].nextActivate, currentClockCycle + READ_AUTOPRE_DELAY);
		//printf("\n\n");
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			//will set next read/write for all banks - including current (which shouldnt matter since its now idle)
			bankStates[i].nextRead = max(bankStates[i].nextRead, currentClockCycle + max(BL / 2, tCCD));
			bankStates[i].nextWrite = max(bankStates[i].nextWrite, currentClockCycle + READ_TO_WRITE_DELAY);
			//printf("(READ_P) Bank %d: next_Read: %d, next_Write: %d\n", i,bankStates[i].nextRead, bankStates[i].nextWrite);
		}

		//get the read data and put it in the storage which delays until the appropriate time (RL)
#ifndef NO_STORAGE
		//  READ bank
		BANK_READ
			//printf("Data: %d\n", packet->data);
#else
		packet->busPacketType = DATA;
#endif

		readReturnPacket.push_back(packet);
		readReturnCountdown.push_back(RL);
		break;
	case WRITE:
		//make sure a write is allowed
		if (bankStates[packet->bank].currentBankState != RowActive ||
			currentClockCycle < bankStates[packet->bank].nextWrite ||
			packet->row != bankStates[packet->bank].openRowAddress)
		{
			printf("== Error - Rank %d received a WRITE when not allowed", id);
			bankStates[packet->bank].print();
			exit(0);
		}

		//update state table
		bankStates[packet->bank].nextPrecharge = max(bankStates[packet->bank].nextPrecharge, currentClockCycle + WRITE_TO_PRE_DELAY);
		//printf("\n\n");
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			bankStates[i].nextRead = max(bankStates[i].nextRead, currentClockCycle + WRITE_TO_READ_DELAY_B);
			bankStates[i].nextWrite = max(bankStates[i].nextWrite, currentClockCycle + max(BL / 2, tCCD));
			//printf("(WRITE) Bank %d: next_Read: %d, next_Write: %d\n",i, bankStates[i].nextRead, bankStates[i].nextWrite);
		}

		//take note of where data is going when it arrives
		incomingWriteBank = packet->bank;
		incomingWriteRow = packet->row;
		incomingWriteColumn = packet->column;

		//get the read data and put it in the storage 
#ifndef NO_STORAGE
		// WRITE bank
		BANK_WRITE
			//printf("Data: %d\n", packet->data);
#else
		packet->busPacketType = DATA;
#endif

		delete(packet);
		break;
	case WRITE_P:
		//make sure a write is allowed
		if (bankStates[packet->bank].currentBankState != RowActive ||
			currentClockCycle < bankStates[packet->bank].nextWrite ||
			packet->row != bankStates[packet->bank].openRowAddress)
		{
			printf("== Error - Rank %d received a WRITE_P when not allowed",id);
			exit(0);
		}

		//update state table
		bankStates[packet->bank].currentBankState = Idle;
		bankStates[packet->bank].nextActivate = max(bankStates[packet->bank].nextActivate, currentClockCycle + WRITE_AUTOPRE_DELAY);
		//printf("\n\n");
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			bankStates[i].nextWrite = max(bankStates[i].nextWrite, currentClockCycle + max(tCCD, BL / 2));
			bankStates[i].nextRead = max(bankStates[i].nextRead, currentClockCycle + WRITE_TO_READ_DELAY_B);
			//printf("(WRITE_P) Bank %d: next_Read: %d, next_Write: %d\n", i,bankStates[i].nextRead, bankStates[i].nextWrite);
		}

		//take note of where data is going when it arrives
		incomingWriteBank = packet->bank;
		incomingWriteRow = packet->row;
		incomingWriteColumn = packet->column;

		//get the read data and put it in the storage 
#ifndef NO_STORAGE
		// WRITE BANK
		BANK_WRITE
			//banks[packet->bank].bank(WRITE, packet->row, packet->column, packet->data, packet->data);
			//printf("Data: %d\n", packet->data);
#else
		packet->busPacketType = DATA;
#endif

		delete(packet);
		break;
	case ACTIVATE:
		//make sure activate is allowed
		if (bankStates[packet->bank].currentBankState != Idle ||
			currentClockCycle < bankStates[packet->bank].nextActivate)
		{
			printf("== Error - Rank %d received an ACT when not allowed", id);
			packet->print();
			bankStates[packet->bank].print();
			exit(0);
		}

		bankStates[packet->bank].currentBankState = RowActive;
		bankStates[packet->bank].nextActivate = currentClockCycle + tRC;
		bankStates[packet->bank].openRowAddress = packet->row;


		//if AL is greater than one, then posted-cas is enabled - handle accordingly
		//printf("\n\n");
		if (AL > 0)
		{
			bankStates[packet->bank].nextWrite = currentClockCycle + (tRCD - AL);
			bankStates[packet->bank].nextRead = currentClockCycle + (tRCD - AL);
			//printf("(ACTIVATE) (AL>0)NextWrite: %d, NextRead: %d\n", bankStates[packet->bank].nextWrite, bankStates[packet->bank].nextRead);
		}
		else
		{
			bankStates[packet->bank].nextWrite = currentClockCycle + (tRCD - AL);
			bankStates[packet->bank].nextRead = currentClockCycle + (tRCD - AL);
			//printf("(ACTIVATE) (AL<=0)NextWrite: %d, NextRead: %d\n", bankStates[packet->bank].nextWrite, bankStates[packet->bank].nextRead);
		}

		bankStates[packet->bank].nextPrecharge = currentClockCycle + tRAS;
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			if (i != packet->bank)
			{
				bankStates[i].nextActivate = max(bankStates[i].nextActivate, currentClockCycle + tRRD);
				//printf("(ACTIVATE) Bank %d next_activate: %d\n",i, bankStates[i].nextActivate);
			}
		}
		delete(packet);
		break;
	case PRECHARGE:
		//make sure precharge is allowed
		if (bankStates[packet->bank].currentBankState != RowActive ||
			currentClockCycle < bankStates[packet->bank].nextPrecharge)
		{
			printf("== Error - Rank %d received a PRE when not allowed",id);
			exit(0);
		}
		//printf("\n\n");
		bankStates[packet->bank].currentBankState = Idle;
		bankStates[packet->bank].nextActivate = max(bankStates[packet->bank].nextActivate, currentClockCycle + tRP);
		//printf("(PRECHARGE) Bank %d next_precharge: %d\n", packet->bank, bankStates[packet->bank].nextActivate);
		delete(packet);
		break;
	case REFRESH:
		refreshWaiting = false;
		for (size_t i = 0; i < NUM_BANKS; i++)
		{
			if (bankStates[i].currentBankState != Idle)
			{
				printf("== Error - Rank %d received a REF when not allowed",id);
				exit(0);
			}
			//printf("\n\n");
			bankStates[i].nextActivate = currentClockCycle + tRFC;
			//printf("(REFRESH) Bank %d next_activate: %d\n", i, bankStates[i].nextActivate);
		}
		delete(packet);
		break;
	case DATA:
		// TODO: replace this check with something that works?
		/*
		if(packet->bank != incomingWriteBank ||
		packet->row != incomingWriteRow ||
		packet->column != incomingWriteColumn)
		{
		cout << "== Error - Rank " << id << " received a DATA packet to the wrong place" << endl;
		packet->print();
		bankStates[packet->bank].print();
		exit(0);
		}
		*/
#ifndef NO_STORAGE
		// WRITE BANK
		BANK_WRITE
			//banks[packet->bank].bank(WRITE, packet->row, packet->column, packet->data, packet->data);
#else
		// end of the line for the write packet
#endif
		delete(packet);
		break;
	default:
		printf("== Error - Unknown BusPacketType trying to be sent to Bank");
		exit(0);
		break;
	}
}


void Rank::update()
{
	//printf("Data cycles left: %d\n",dataCyclesLeft); 
	//printf("readReturnCountdown[0]: %d\n", readReturnCountdown[0]);


	// An outgoing packet is one that is currently sending on the bus
	// do the book keeping for the packet's time left on the bus

	// deals with receiving data on bus (data can be on bus for a fixed number of cycles)
	if (outgoingDataPacket != NULL)
	{
		//printf("outgoingDataPacket->data: %d\n", outgoingDataPacket->data);
		dataCyclesLeft--;
		if (dataCyclesLeft == 0)
		{
			//if the packet is done on the bus, call receiveFromBus and free up the bus
			//memoryController->receiveFromBus(outgoingDataPacket);
			outgoingDataPacket = NULL;
		}
	}

	// decrement the counter for all packets waiting to be sent back
	for (size_t i = 0; i < readReturnCountdown.size; i++)
	{
		readReturnCountdown.unsigned_arr[i]--;
	}

	//printf("readReturnCountdown[0]: %d\n", readReturnCountdown[0]);

	// assigns the outgoingDataPacket with actual data from the READ Queue

	if (readReturnCountdown.size > 0 && readReturnCountdown.at(0) == 0)
	{
		// RL time has passed since the read was issued; this packet is
		// ready to go out on the bus

		//outgoingDataPacket = readReturnPacket[0];
		outgoingDataPacket = readReturnPacket.at(0); 
		//printf("outgoingDataPacket: %d\n", outgoingDataPacket->data); 
		dataCyclesLeft = BL / 2;

		// remove the packet from the ranks
		readReturnPacket.pop(); 
		//readReturnPacket.erase(readReturnPacket.begin());
		readReturnCountdown.pop();
		//readReturnCountdown.erase(readReturnCountdown.begin());

		if (DEBUG_BUS)
		{
			printf(" -- R %d Issuing On Data Bus : ", this->id);
			outgoingDataPacket->print();
			printf("");
		}

	}
}

//power down the rank
void Rank::powerDown()
{
	//perform checks
	for (size_t i = 0; i < NUM_BANKS; i++)
	{
		if (bankStates[i].currentBankState != Idle)
		{
			printf("== Error - Trying to power down rank %d while not all banks are idle",id);
			exit(0);
		}

		bankStates[i].nextPowerUp = currentClockCycle + tCKE;
		bankStates[i].currentBankState = PowerDown;
	}

	isPowerDown = true;
}

//power up the rank
void Rank::powerUp()
{
	if (!isPowerDown)
	{
		printf("== Error - Trying to power up rank %d while it is not already powered down",id);
		exit(0);
	}

	isPowerDown = false;

	for (size_t i = 0; i < NUM_BANKS; i++)
	{
		if (bankStates[i].nextPowerUp > currentClockCycle)
		{
			printf("== Error - Trying to power up rank %d before we're allowed to",id);
			printf("%d      %d",bankStates[i].nextPowerUp,currentClockCycle);
			exit(0);
		}
		bankStates[i].nextActivate = currentClockCycle + tXP;
		bankStates[i].currentBankState = Idle;
	}
}

// previous Functions

// mutators
//void Rank::setId(int id)
//{
//	this->id = id;
//}

// attachMemoryController() must be called before any other Rank functions
// are called
//void Rank::attachMemoryController(MemoryController *memoryController)
//{
//	this->memoryController = memoryController;
//}


//int Rank::getId() const
//{
//	return this->id;
//}
// Deals with MemoryController Interface
