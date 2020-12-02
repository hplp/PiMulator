/*
* Rank Test
// Goal: (1) Write All Rank Memory Locations  (meaning all 8 banks of the rank) w. known data
//		 (2) Read  All Rank Memory Locations  (meaning all 8 banks of the rank) & check whether data is what we expect it to be when read
// how to read or write a specific location : ACTIVATE (specified row) -> READ or WRITE (specific column) -> PRECHARGE (if you wish to go to another row)
// Rank is timing accurate, so we need to advance clock cycles in between commands based on DDR3 timing: advance_clock_cycle() function used for that
// Simulation timing report includes simulated clock cycles and the actual amount of clock cycles simulation took; the factor by which simulation is slower than physical device operation is also reported
// The Macros defined are as follows:
// RANK_TEST: enable testing the rank
   BANK_TEST: enable testing the bank
   REPORT_TIMING: enable simulation timing report
   CHECK: check whether read data is as expected (turn OFF to measure simulation time more accurately)
*/


#include "Rank.h"
#include <time.h>

//#include <stdio.h>  
//#include <iostream>
//#include <windows.h>
//#define BANK_TEST   

#define RANK_TEST
#define REPORT_TIMING
#define CHECK

// Done to quit application
void quit()
{
	printf("Press any character ...\n");
	char ch = NULL;
	while (true) {
		ch = getchar();
		if (ch != NULL) { break; }
	}
}

#ifdef RANK_TEST

// incrementing clock of Rank Device (or in hardware it would be incrementing rank internal counter keeping 
// track of the clock cycles)

void advance_clock_cycle(Rank * r, int num)
{
	for (int i = 0; i < num; i++) {
		r->currentClockCycle++;
	}
}
#endif

int main()
{
	// Here is where we test Rank Software Interface w. Exhaustive combination of inputs and report the timing 

#ifdef RANK_TEST

	Rank * rank = new Rank();

// Rank Test Begins
// Goal: (1) Write All Rank Memory Locations (meaning all 8 banks of the rank) w. known data
//		 (2) Read All Rank Memory Locations  (meaning all 8 banks of the rank) & check whether data is what we expect it to be when read
// how to read or write a specific location : ACTIVATE (specified row) -> READ or WRITE (specific column) -> PRECHARGE (if you wish to go to another row)
// Rank is timing accurate, so we need to advance clock cycles in between commands based on DDR3 timing: advance_clock_cycle() function used for that
// Simulation time or our simple benchmark is reported at the end

#ifdef REPORT_TIMING
	clock_t before = clock();
#endif
	unsigned char data1 = 0;
	unsigned char ref_data = 0;

	// (1) WRITE all Rank locations with known data

	//* WRITE an entire bank
	for (int i = 0; i < NUM_BANKS; i++) {
		//*  WRITE an entire row
		for (int j = 0; j < NUM_ROWS; j++) {
			// activate row
			rank->receiveFromBus(new BusPacket(ACTIVATE, 0, 0, j, 0, i, data1));
			// wait for a WRITE after ACTIVATE
			advance_clock_cycle(rank, 5);

			for (int k = 0; k < NUM_COLS; k++)
			{
				// perform Write (ref_data is the random data we wish to write, as you can see every memory location would have unique data)

				data1 = (i + j + k) % 256;

				// cause failure
				//if (i == 1 && j == 1 && k == 1) {
				//	data1 = (i + j + k +1) % 256;
				//}

				// write column 
				rank->receiveFromBus(new BusPacket(WRITE, 0, k, j, 0, i, data1));
				//  wait for a WRITE after WRITE 
				advance_clock_cycle(rank, 4);
			}
			// END

			// wait for PRECHARGE after WRITE - WRITE after WRITE
			advance_clock_cycle(rank, 28 - 4);
			// PRECHARGE
			rank->receiveFromBus(new BusPacket(PRECHARGE, 0, 0, j, 0, i, data1));
			// wait for an ACTIVATE after PRECHARGE
			advance_clock_cycle(rank, 10);
		}

		//END

	}
	//END

	// (2) READ all Rank locations and check whether read data is what we would expect 

	//* READ  an entire bank
	for (int i = 0; i < NUM_BANKS; i++) {
		//* READ an entire row
		for (int j = 0; j < NUM_ROWS; j++) {
			// activate row
			rank->receiveFromBus(new BusPacket(ACTIVATE, 0, 0, j, 0, i, data1));
			// wait for a READ after ACTIVATE
			advance_clock_cycle(rank, 5);

			for (int k = 0; k < NUM_COLS; k++)
			{
				// perform READ
				rank->receiveFromBus(new BusPacket(READ, 0, k, j, 0, i, data1));
				//* wait for READ after READ
				advance_clock_cycle(rank, 4);

				//* issue 15 updates (RL time) so that the read from the most recent transaction goes on the outgoing bus
				//* 15 updates would translate into waiting for 15 clock cycles (RL time)
				for (int l = 0; l < 15; l++) {
					rank->update();
					//advance_clock_cycle(rank, 1);
				}
				// retrieve read data
				data1 = rank->outgoingDataPacket->data;
#ifdef CHECK
				// check if read data is what we expect
				// data we expect to read from that memory location
				ref_data = (i + j + k) % 256;
				//printf("ref_data: %d\n", ref_data); 
				if (data1 != ref_data) {
					printf("Wrong at (bank, row, col): (%d, %d, %d), Data is: %d when it's supposed to be %d\n", i, j, k, data1, ref_data);
					quit();
					break;
				}
#endif
			}
			// END
			// wait for a PRECHARGE after READ - READ after READ
			advance_clock_cycle(rank, 5 - 4);
			// PRECHARGE
			rank->receiveFromBus(new BusPacket(PRECHARGE, 0, 0, j, 0, i, data1));
			// wait for an ACTIVATE after PRECHARGE
			advance_clock_cycle(rank, 10);
		}

		//END

	}
	//END
#ifdef REPORT_TIMING
	clock_t difference = clock() - before;

	printf("Simulated time to READ/WRITE all 8 banks of a single rank: %d CC\n", (int)rank->currentClockCycle); 

	printf("Simulation took %d CC\n", difference); 

	//printf("Simulation of Rank Benchmark is %u times slower than physical Rank device\n", difference / rank->currentClockCycle);
#endif
#endif
	// END Rank Transaction Test

	// done previosly for Bank Testing (IGNORE)

#ifdef BANK_TEST
	//Bank * b = new Bank();
	unsigned char data_o = 0;

	// added
	bool EN_i = true;
	//CurrentBankState currentBankState_i;
	//unsigned openRowAddress_i;
	//unsigned long int nextRead_i;
	//unsigned long int nextWrite_i;
	//unsigned long int nextActivate_i;
	//unsigned long int nextPrecharge_i;
	//unsigned long int nextPowerUp_i;

	//BusPacketType lastCommand_i;
	//unsigned stateChangeCountdown_i;

	// additional logic
	bool break_outer = false;

#ifdef REPORT_TIMING
	clock_t before = clock();
#endif
	/*for (unsigned k = 0; k < 1; k++) {
	if (break_outer) { break; }*/
	for (unsigned i = 0; i < NUM_ROWS; i++) {
		if (break_outer) { break; }
		for (unsigned j = 0; j < NUM_COLS; j++) {
			//data_o = 0;
			// fail
			//if (k == 4 && i == 7 && j == 89) {
			//	//write bank
			//	b->bank(7, WRITE, i, j, (unsigned char)(i + j + k), data_o);
			//}
			//else {

			//write bank                                                
			bank(0, WRITE, i, j, (unsigned char)(i + j), data_o);

			//}
			// read bank
			bank(0, READ, i, j, 0, data_o);
			// check
			/*if (data_o != (unsigned char)(i + j)) {
			printf("Mismatch at (%d, %d, %d)\n", i, j);
			break_outer = true;
			break;
			}*/

		}

	}

	//}
#ifdef REPORT_TIMING

	clock_t difference = clock() - before;

	//printf("Simulated time to READ/WRITE all locations of bank: %d\n", rank->currentClockCycle);            

	printf("Simulation took %u CC\n", difference);

#endif



#endif // BANK_TEST
	quit();
	return 0;
}