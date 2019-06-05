#include "eth_fifo_interface.hpp"

// Ethernet FIFO interface
// Receives 128-bit wide data in
// Transmits a packet via PS Ethernet FIFO
// This version supports flushing out buffered data
void eth_fifo_interface(
		u1t dma_tx_end_tog,
		u1t tx_r_fixed_lat,
		u1t tx_r_rd,
		u4t tx_r_status,
		u128st &data_in,
		u1t &dma_tx_status_tog,
		u1t &tx_r_control,
		u8t &tx_r_data,
		u1t &tx_r_data_rdy,
		u1t &tx_r_eop,
		u1t &tx_r_err,
		u1t &tx_r_flushed,
		u1t &tx_r_sop,
		u1t &tx_r_underflow,
		u1t &tx_r_valid) {
#pragma HLS PIPELINE II=1 enable_flush
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_none port=dma_tx_end_tog
#pragma HLS INTERFACE ap_none port=tx_r_fixed_lat
#pragma HLS INTERFACE ap_none port=tx_r_rd
#pragma HLS INTERFACE ap_none port=tx_r_status
#pragma HLS INTERFACE axis register both port=data_in
#pragma HLS INTERFACE ap_none port=dma_tx_status_tog
#pragma HLS INTERFACE ap_none port=tx_r_control
#pragma HLS INTERFACE ap_none port=tx_r_data
#pragma HLS INTERFACE ap_none port=tx_r_data_rdy
#pragma HLS INTERFACE ap_none port=tx_r_eop
#pragma HLS INTERFACE ap_none port=tx_r_err
#pragma HLS INTERFACE ap_none port=tx_r_flushed
#pragma HLS INTERFACE ap_none port=tx_r_sop
#pragma HLS INTERFACE ap_none port=tx_r_underflow
#pragma HLS INTERFACE ap_none port=tx_r_valid
	
	// various state variables and useful constants
	static enum state {IDLE, MAC_DST, MAC_SRC, TYPE, PAYLOAD, ZEROS, ID} current_state = IDLE;
	const u8t src_mac[6] = {0x00, 0x0A, 0x35, 0x03, 0x59, 0xF5};
#pragma HLS ARRAY_PARTITION variable=src_mac complete dim=1
	const u8t dst_mac[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
#pragma HLS ARRAY_PARTITION variable=dst_mac complete dim=1
	const u14t idle_count = 16000, mac_count = 6, type_count = 2;
	static u14t count = idle_count;
	static u16t length;
	static u8t ID_num = 0;
	static u8st data_buffer;
#pragma HLS STREAM variable=data_buffer depth=16384
	static u128t data_word;
	static bool data_word_valid = false;
	static u4t word_byte = 0;

	// read in status, currently unused
	static u1t last_tx_status_valid = 0;
	u1t tx_status_valid = dma_tx_end_tog;
	u4t tx_status = tx_r_status;
	dma_tx_status_tog = last_tx_status_valid;
	last_tx_status_valid = tx_status_valid;

	// read in fixed_lat, currently unused
	u1t fixed_lat = tx_r_fixed_lat;

	// buffer fifo data
	static u14t buffer_count = 0;
	static bool buffer_added = false;
	bool buffer_removed = false;
	bool buffer_empty = data_buffer.empty();
	bool buffer_full = data_buffer.full();
	bool packet_buffered = buffer_count >= PACKET_SIZE;
	static u8t buffer_data = 0;

	// tie off unused signals
	tx_r_control = 0;
	tx_r_err = 0;
	tx_r_flushed = 0;
	tx_r_underflow = 0;

	// data output signals
	static u1t data_ready = 0;
	static u1t tx_valid = 0;
	static u1t sop = 0;
	static u1t eop = 0;
	static u8t tx_data = 0;
	tx_r_data_rdy = data_ready;
	tx_r_valid = tx_valid;
	tx_r_sop = sop;
	tx_r_eop = eop;
	tx_r_data = tx_data;

	// data read request
	u1t tx_read = 0;
	tx_read = tx_r_rd;

	// initialize variables
	tx_valid = tx_read;
	sop = 0;
	eop = 0;

	// state machine
	switch (current_state) {
    case IDLE:
    	// wait for a packet of data or timeout with some data
		if (packet_buffered) {
			length = PACKET_SIZE+1;
			count = mac_count;
			current_state = MAC_DST;
		} else if (count == 0 && !buffer_empty) {
			u14t temp_buffer_count = 0;
			temp_buffer_count(4,13) = buffer_count(4,13);
			length = temp_buffer_count < 48 ? (u16t)49 : (u16t)(temp_buffer_count+1);
			count = mac_count;
			current_state = MAC_DST;
		} else if (buffer_added) {
			count = idle_count;
		} else if (count != 0) {
			--count;
		}
		break;
	case MAC_DST:
		// transmit SOP and destination MAC address
		// destination is currently broadcast address
		data_ready = 1;

		tx_data = dst_mac[6-count];
		if (count(0,3) == mac_count(0,3)) {
			sop = 1;
		}

		if (tx_read) {
			if (count == 1) {
				current_state = MAC_SRC;
				count = mac_count;
			} else {
				--count;
			}
		}
		break;
	case MAC_SRC:
		// transmit unique source address
		// MAC address was pulled from a ZCU102 board
		data_ready = 0;

		tx_data = src_mac[6-count];

		if (tx_read) {
			if (count == 1) {
				current_state = TYPE;
				count = type_count;
			} else {
				--count;
			}
		}
		break;
	case TYPE:
		// transmit length field
		if (count == type_count) {
			tx_data = length(15,8);
		} else {
			tx_data = length(7,0);
		}

		if (tx_read) {
			if (count == 1) {
				data_buffer.read(buffer_data);
				buffer_removed = true;
				count = length-1;
				current_state = PAYLOAD;
			} else {
				--count;
			}
		}
		break;
	case PAYLOAD:
		// transmit trace data from buffer
		// if we run out, pad with zeros
		tx_data = buffer_data;

		if (tx_read) {
			if (count == 1) {
				current_state = ID;
			} else {
				--count;
				if (buffer_empty) {
					current_state = ZEROS;
				} else {
					data_buffer.read(buffer_data);
					buffer_removed = true;
				}
			}
		}
		break;
	case ZEROS:
		// pad remaining space with zeros
		tx_data = 0;

		if (tx_read) {
			if (count == 1) {
				current_state = ID;
			} else {
				--count;
			}
		}
		break;
	case ID:
		// transmit 8-bit packet ID and EOP
		// used to detect packet drops
		tx_data = ID_num;
		eop = 1;

		if (tx_read) {
			count = idle_count;
			current_state = IDLE;
			++ID_num;
		}
		break;
	}

	// convert 128-bit word to bytes and add to buffer
	buffer_added = false;
	if (data_word_valid && !buffer_full) {
		u8t temp_data;
		switch (word_byte) {
		case 0:
			temp_data = data_word(0,7);
			break;
		case 1:
			temp_data = data_word(8,15);
			break;
		case 2:
			temp_data = data_word(16,23);
			break;
		case 3:
			temp_data = data_word(24,31);
			break;
		case 4:
			temp_data = data_word(32,39);
			break;
		case 5:
			temp_data = data_word(40,47);
			break;
		case 6:
			temp_data = data_word(48,55);
			break;
		case 7:
			temp_data = data_word(56,63);
			break;
		case 8:
			temp_data = data_word(64,71);
			break;
		case 9:
			temp_data = data_word(72,79);
			break;
		case 10:
			temp_data = data_word(80,87);
			break;
		case 11:
			temp_data = data_word(88, 95);
			break;
		case 12:
			temp_data = data_word(96, 103);
			break;
		case 13:
			temp_data = data_word(104,111);
			break;
		case 14:
			temp_data = data_word(112,119);
			break;
		case 15:
			temp_data = data_word(120,127);
			break;
		}
		data_buffer.write(temp_data);
		buffer_added = true;
		if (word_byte == 15) {
			data_word_valid = false;
		} else {
			++word_byte;
		}
	}

	// read in new 128-bit word
	if (!data_in.empty() && !data_word_valid) {
		data_in.read(data_word);
		data_word_valid = true;
		word_byte = 0;
	}

	// update buffer entry count
	// this implementation improves timing significantly
	if (buffer_added && !buffer_removed) {
		++buffer_count;
	} else if (buffer_removed && !buffer_added) {
		--buffer_count;
	}
}
