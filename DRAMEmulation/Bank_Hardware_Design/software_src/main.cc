/*
 * DRAM Bank Hardware Test for (i) Bank Software Model and (ii) Bank Hardware Model
 *  The main idea of this test is to (1) first, write all Bank memory location with known data
 *  (all NUM_ROWS * NUM_COLS locations) and then (2) second, to read all Bank memory locations
 *  and make sure the read data for each Bank location matches the written data to that location
 *  in step (1).
 *
 *  This is done either for Software Simulation, which includes only the Bank Software Model
 *  (Hint: see all other .cpp and .h files, which model the Bank in software) or it can be done
 *  for Bank Hardware Emulation, which uses the Bank Hardware created in the Vivado Project
 *
 *  This was done for consistency in the timing measurement, so that the time the Read / Write benchmark takes
 *  for either software simulation or hardware emulation is measured in terms of clock cycles
 *  on the Zynq CPU
 *
 *  Here is an explanation how the benchmark works:
 *  I. Write All Memory Locations:
 *  	1. Loop through each memory row (NUM_ROW times) and activate each row (or place row in row buffer)
 *  		1.1. Loop through each memory column (NUM_COLS times) and write it with known data (or write row buffer)
 *  	2. issue PRECHARGE command to clear row buffer before moving on to another row
 * II. Read All Memory Locations:
 *  	1. Loop through each memory row (NUM_ROW times) and activate each row (or place row in row buffer)
 *  		1.1. Loop through each memory column (NUM_COLS times) and read it  (or read row buffer)
 *  		1.2  Optionally, check whether the read data matches the data that was written to that location
 *  	2. issue PRECHARGE command to clear row buffer before moving on to another row
 *
 *  Macros control what testing takes place, here is an explanation of each:
 *
 *  SOFTWARE: turn ON Bank Software Test (Make sure to turn OFF HARDWARE test)
 *  HARDWARE: turn ON Bank Hardware Test (Make sure to turn OFF SOFTWARE test)
 *  REPORT_TIMING: Reports the timing of the test, in terms of Zynq clock cycles
 *  (will specify whether Emulation or Simulation was timed)
 *  CHECK: Turns ON checking whether the read data matches the data previously written to that
 *  memory location, recommended to turn it OFF if you want an exact timing comparison to avoid extra latency
 *
 *	Feel free to modify this code and use the provided functions to issue different Bank Commands
 *	and see how timing is affected by that.
 */

#include "Bank.h"

#include "xil_printf.h"
#include "xtime_l.h"
#include "xil_types.h"
#include "xtime_l.h"
#include "xil_io.h"

#include "xbank.h"

// Software or Hardware Test
#define HARDWARE // SOFTWARE HARDWARE

// Whether to report timing
#define REPORT_TIMING

// Whether to check if read data is correct
#define CHECK

// Easy trick
#define printf xil_printf

// Helps format input for Bank Interface
#ifdef HARDWARE
#define format_input(busPacketType,row,column,data_in) (((((((0|data_in) << 8) | column) << 8) | row) << 8) | busPacketType)
#endif
#ifdef SOFTWARE
bank_in format_input(BusPacketType busPacketType, unsigned char row, unsigned char column, unsigned char data_in) {
	bank_in input;
	input.busPacketType = busPacketType;
	input.row = row;
	input.column = column;
	input.data_in = data_in;

	return input;
}
#endif

// Hardware-related (only needed for HARDWARE test)
#ifdef HARDWARE

void setup(XBank *do_xbank) {
	// Setup Bank HLS
	int status;

	XBank_Config *do_xbank_cfg;
	do_xbank_cfg = XBank_LookupConfig(
	XPAR_XBANK_0_DEVICE_ID);

	if (!do_xbank_cfg) {
		printf("Error loading configuration for do_xbank_cfg \n\r");
		return;
	}

	status = XBank_CfgInitialize(do_xbank, do_xbank_cfg);
	if (status != XST_SUCCESS) {
		printf("Error initializing for do_xbank \n\r");
		return;
	}

	XBank_Initialize(do_xbank, XPAR_XBANK_0_DEVICE_ID); // this is optional in this case
}

void wait(XBank *do_xbank) {
	// Start, wait to finish
	XBank_Start(do_xbank);
	// Wait until it's done (optional here)
	while (!XBank_IsDone(do_xbank))
		;
}

// Following are functions to interface with Bank
// Input Values to Bank (WRITE, ACTIVATE, REFRESH, PRECHARGE)
void toBank(XBank *do_xbank, u32 input) {
	XBank_Set_bankpacket_in(do_xbank, input);
	wait(do_xbank);
}
// Get Values to Bank (READ)
u32 fromBank(XBank *do_xbank, u32 input) {
	XBank_Set_bankpacket_in(do_xbank, input);
	wait(do_xbank);
	return XBank_Get_data_out(do_xbank);
}

#endif

int main() {
	//
#ifdef HARDWARE
#ifdef SOFTWARE
	return 0;
#endif
#endif
#ifndef HARDWARE
#ifndef SOFTWARE
	return 0;
#endif
#endif
	//
	xil_printf("Start ...\n");
	unsigned char data_o;

	XTime tStart, tEnd, difference;

	// Bank Hardware Test
#ifdef HARDWARE

	// Setup Bank HLS
	XBank do_xbank;
	setup(&do_xbank);

	// Start timer
	XTime_GetTime(&tStart);

	// Test 1: Write / Read  all memory location

	// Write all memory location
	for (unsigned short i = 0; i < NUM_ROWS; i++) {

		// (1) Activate row
		toBank(&do_xbank, format_input(ACTIVATE, i, 0, 0));

		for (unsigned short j = 0; j < NUM_COLS; j++) {
			// (2) Write bank
			toBank(&do_xbank, format_input(WRITE, i, j, (u32 ) ((i + j) % 256)));
		}

		// (3) PRECHARGE row buffer
		toBank(&do_xbank, format_input(PRECHARGE, 0, 0, 0));
	}

	// Read all memory location & check
	for (unsigned short i = 0; i < NUM_ROWS; i++) {
		// (1) Activate row
		toBank(&do_xbank, format_input(ACTIVATE, i, 0, 0));

		for (unsigned short j = 0; j < NUM_COLS; j++) {
			// (2) READ bank
			data_o = fromBank(&do_xbank, format_input(READ, i, j, 0));

			// Check if read data is correct
#ifdef CHECK
			if (data_o != (i + j) % 256) {
				printf("Mismatch at (%d, %d), Data is supposed to be %d, but it is %d\n", i, j, (i + j) % 256, data_o);
				return 0;
			} // else printf("Equal at (%d, %d), %d = %d\n", i, j, (i + j) % 256, data_o);
#endif

		}
		// (3) PRECHARGE row buffer
		toBank(&do_xbank, format_input(PRECHARGE, 0, 0, 0));
	}
#endif

	// Bank Software Model Test
#ifdef SOFTWARE

	// start timer
	XTime_GetTime(&tStart);

	// Write all memory location
	for (unsigned i = 0; i < NUM_ROWS; i++) {
		// (1) Activate row
		Bank(format_input(ACTIVATE, i, 0, 0), data_o);

		for (unsigned j = 0; j < NUM_COLS; j++) {
			// (2) Write bank
			Bank(format_input(WRITE, i, j, (unsigned char) ((i + j) % 256)), data_o);
		}

		// (3) PRECHARGE row buffer
		Bank(format_input(PRECHARGE, 0, 0, 0), data_o);
	}

	// Read all memory location & check that contents are correct
	for (unsigned short i = 0; i < NUM_ROWS; i++) {
		// (1) Activate row
		Bank(format_input(ACTIVATE, i, 0, 0), data_o);

		for (unsigned short j = 0; j < NUM_COLS; j++) {
			// (2) Read bank
			Bank(format_input(READ, i, j, 0), data_o);

			// Check
#ifdef CHECK
			if (data_o != (i + j) % 256) {
				printf("Mismatch at (%d, %d), Data is supposed to be %d, but it is %d\n", i, j, (i + j) % 256, data_o);
				return 0;
			} //else printf("Equal at (%d, %d), %d = %d\n", i, j, (i + j) % 256, data_o);
#endif
		}
		// (3) PRECHARGE row buffer
		Bank(format_input(PRECHARGE, 0, 0, 0), data_o);
	}

#endif

// Report timing information
#ifdef REPORT_TIMING
	XTime_GetTime(&tEnd);
	difference = tEnd - tStart;
#ifdef SOFTWARE
	printf("(SOFTWARE) Simulation ");
#endif

#ifdef HARDWARE
	printf("(HARDWARE) Emulation ");
#endif
	printf("took %u CC.\n", (unsigned) (difference));
#endif
	printf("End of script.\n");
	return 0;
}
