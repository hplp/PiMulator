#include "eth_fifo_interface.hpp"

// This testbench makes the Ethernet module output one packet

// Output must be inspected manually in Wave Viewer
// Look for:
// A 1-cycle delay between tx_r_rd and tx_r_valid
// Should be able to output valid data every cycle
// First byte should have tx_r_sop high
// Last byte should have tx_r_eop high
// First 6 data bytes should be 0xFF
// Second 6 data bytes should be a MAC address
// Next 2 data bytes should be the number of bytes that follow
// The last data byte is zero (the initial ID value)

// If 0, provides a full packet of data so the module can send immediately
// If 1, provides less than a full packet, so the module must wait before flushing
#define TIMEOUT 1
// If 0, packet has enough data so padding is not needed
// If 1, module will have to pad data to meet minimum Ethernet frame size
#define TINY 1

const int NUM_BYTES_IN = TIMEOUT ? (TINY ? 32 : 64) : PACKET_SIZE;
const int NUM_BYTES_OUT = TIMEOUT ? (TINY ? 48 : 64) : PACKET_SIZE;

int main(int argc, char **argv) {
	// module inputs
	u1t dma_tx_end_tog;
	u1t tx_r_fixed_lat;
	u1t tx_r_rd;
	u4t tx_r_status;
	u128t data_word;
	u128st data_in;

	// create input data
	for (int i = 0; i < NUM_BYTES_IN; ++i) {
		data_word((i%16)*8,(i%16)*8+7) = i;
		if (i%16==15) data_in.write(data_word);
	}

	// module outputs
	u1t dma_tx_status_tog;
	u1t tx_r_control;
	u8t tx_r_data;
	u1t tx_r_data_rdy = 0;
	u1t tx_r_eop;
	u1t tx_r_err;
	u1t tx_r_flushed;
	u1t tx_r_sop;
	u1t tx_r_underflow;
	u1t tx_r_valid;

	// wait for data ready
	// module has to read in data first and potentially wait for timeout
	// this signal should go high eventually or something is wrong
	while (tx_r_data_rdy == 0) {
		eth_fifo_interface(1, 0, 0, 0,
			data_in,
			dma_tx_status_tog,
			tx_r_control,
			tx_r_data,
			tx_r_data_rdy,
			tx_r_eop,
			tx_r_err,
			tx_r_flushed,
			tx_r_sop,
			tx_r_underflow,
			tx_r_valid);
	}

	// read out data
	for (int i = 0; i < NUM_BYTES_OUT+1+14; ++i) {
		eth_fifo_interface(0, 0, 1, 0,
			data_in,
			dma_tx_status_tog,
			tx_r_control,
			tx_r_data,
			tx_r_data_rdy,
			tx_r_eop,
			tx_r_err,
			tx_r_flushed,
			tx_r_sop,
			tx_r_underflow,
			tx_r_valid);
	}

	// padding cycles at end
	for (int i = 0; i < 5; ++i) {
		eth_fifo_interface(0, 0, 0, 0,
			data_in,
			dma_tx_status_tog,
			tx_r_control,
			tx_r_data,
			tx_r_data_rdy,
			tx_r_eop,
			tx_r_err,
			tx_r_flushed,
			tx_r_sop,
			tx_r_underflow,
			tx_r_valid);
	}
}
