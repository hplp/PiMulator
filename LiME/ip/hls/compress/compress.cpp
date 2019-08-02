#include "compress.hpp"

// Buffers input data
// Can accept an APM event every cycle
// Applies backpressure when full
void buffer_inputs(in_stream_t &in, in_stream_t &out) {
	if (!in.empty() && !out.full()) {
		in_t input;
		in.read(input);
		out.write(input);
	}
}

// Converts APM event to 4 128-bit events
// HLS synthesis may warn that this logic may not meet timing
// However, it will meet timing after HDL synthesis and implementation
void convert_inputs(in_stream_t &in, pack_stream_t &out) {
#pragma HLS PIPELINE II=1 enable_flush
	if (!in.empty() && !out.full()) {
		in_t packed_input;
		in_packet_t input;
		pack_packet_t pack;
		in.read(packed_input);
		input = packed_input;
		static ap_uint<30> time_acc = 0;

		pack.data0 = 0;
		pack.data1 = 0;
		pack.data2 = 0;
		pack.data3 = 0;
		pack.valid0 = false;
		pack.valid1 = false;
		pack.valid2 = false;
		pack.valid3 = false;

		if (input.logID) {
			// SW packet
			out_t output = 0;
			output(63,0) = packed_input(63,0);
			pack.data0 = output;
			pack.valid0 = true;
		} else {
			// regular data
			out_packet_t output0(0), output1(0), output2(0), output3(0);
			time_acc += input.timestamp;

			output0.logID = input.logID;
			output0.timestamp = 0;
			output0.loop = 0;
			output0.slot = 0;
			output0.write = 1;
			output0.ext_event = input.a0_ext_event;
			output0.addr_latch = input.a0_wr_addr_latch;
			output0.first = input.a0_first_wr;
			output0.last = input.a0_last_wr;
			output0.response = input.a0_response;
			output0.a_len = input.a0_awlen;
			output0._id = input.a0_bid;
			output0.a_id = input.a0_awid;
			output0.a_addr = input.a0_awaddr;
			if (input.a0_wr_addr_latch || input.a0_first_wr
			    || input.a0_last_wr || input.a0_response) {
				pack.valid0 = true;
			}

			output1.logID = input.logID;
			output1.timestamp = 0;
			output1.loop = 0;
			output1.slot = 0;
			output1.write = 0;
			output1.ext_event = input.a0_ext_event;
			output1.addr_latch = input.a0_rd_addr_latch;
			output1.first = input.a0_first_rd;
			output1.last = input.a0_last_rd;
			output1.response = 0;
			output1.a_len = input.a0_arlen;
			output1._id = input.a0_rid;
			output1.a_id = input.a0_arid;
			output1.a_addr = input.a0_araddr;
			if (input.a0_rd_addr_latch || input.a0_first_rd
			    || input.a0_last_rd) {
				pack.valid1 = true;
			}

			output2.logID = input.logID;
			output2.timestamp = 0;
			output2.loop = 0;
			output2.slot = 1;
			output2.write = 1;
			output2.ext_event = input.a1_ext_event;
			output2.addr_latch = input.a1_wr_addr_latch;
			output2.first = input.a1_first_wr;
			output2.last = input.a1_last_wr;
			output2.response = input.a1_response;
			output2.a_len = input.a1_awlen;
			output2._id = input.a1_bid;
			output2.a_id = input.a1_awid;
			output2.a_addr = input.a1_awaddr;
			if (input.a1_wr_addr_latch || input.a1_first_wr
			    || input.a1_last_wr || input.a1_response) {
				pack.valid2 = true;
			}

			output3.logID = input.logID;
			output3.timestamp = 0;
			output3.loop = 0;
			output3.slot = 1;
			output3.write = 0;
			output3.ext_event = input.a1_ext_event;
			output3.addr_latch = input.a1_rd_addr_latch;
			output3.first = input.a1_first_rd;
			output3.last = input.a1_last_rd;
			output3.response = 0;
			output3.a_len = input.a1_arlen;
			output3._id = input.a1_rid;
			output3.a_id = input.a1_arid;
			output3.a_addr = input.a1_araddr;
			if (input.a1_rd_addr_latch || input.a1_first_rd
			    || input.a1_last_rd) {
				pack.valid3 = true;
			}


			if (pack.valid0) {
				output0.timestamp = time_acc;
				output0.loop = input.loop;
			} else if (pack.valid1) {
				output1.timestamp = time_acc;
				output1.loop = input.loop;
			} else if (pack.valid2) {
				output2.timestamp = time_acc;
				output2.loop = input.loop;
			} else if (pack.valid3) {
				output3.timestamp = time_acc;
				output3.loop = input.loop;
			}

			pack.data0 = (out_t)output0;
			pack.data1 = (out_t)output1;
			pack.data2 = (out_t)output2;
			pack.data3 = (out_t)output3;
		}
		out.write(pack);
	}
}

// Writes 128-bit events to output stream
// Can output 128-bit events every cycle
// FUTURE WORK: see if enum can be replaced by integer to reduce redundant code
void write_out(pack_stream_t &in, out_stream_t &out) {
	static enum state {S_IDLE = 0, S_ONE_LEFT = 1, S_TWO_LEFT = 2,
	                   S_THREE_LEFT = 3, S_FOUR_LEFT = 4} current_state = S_IDLE;
	static pack_packet_t current_input;

	unsigned char num_left = 0;
	pack_t next_input_temp;
	pack_packet_t next_input;
	switch (current_state) {
	case S_IDLE:
		if (!in.empty()) {
			in.read(next_input_temp);
			next_input = next_input_temp;
			num_left = next_input.valid0 + next_input.valid1
			           + next_input.valid2 + next_input.valid3;
			assert(num_left <= 4);

			current_state = (state)num_left;
			current_input = next_input;
		}
		break;
	case S_ONE_LEFT:
		if (!out.full()) {
			if (current_input.valid0) {
				out.write(current_input.data0);
			} else if (current_input.valid1) {
				out.write(current_input.data1);
			} else if (current_input.valid2) {
				out.write(current_input.data2);
			} else {
				out.write(current_input.data3);
			}

			current_state = S_IDLE;
			if (!in.empty()) {
				in.read(next_input_temp);
				next_input = next_input_temp;
				num_left = next_input.valid0 + next_input.valid1
				           + next_input.valid2 + next_input.valid3;
				assert(num_left <= 4);

				current_state = (state)num_left;
				current_input = next_input;
			}
		}
		break;
	case S_TWO_LEFT:
		if (!out.full()) {
			if (current_input.valid0) {
				out.write(current_input.data0);
				current_input.valid0 = false;
			} else if (current_input.valid1) {
				out.write(current_input.data1);
				current_input.valid1 = false;
			} else if (current_input.valid2) {
				out.write(current_input.data2);
				current_input.valid2 = false;
			} else {
				out.write(current_input.data3);
				current_input.valid3 = false;
			}
			current_state = S_ONE_LEFT;
		}
		break;
	case S_THREE_LEFT:
		if (!out.full()) {
			if (current_input.valid0) {
				out.write(current_input.data0);
				current_input.valid0 = false;
			} else if (current_input.valid1) {
				out.write(current_input.data1);
				current_input.valid1 = false;
			} else if (current_input.valid2) {
				out.write(current_input.data2);
				current_input.valid2 = false;
			} else {
				out.write(current_input.data3);
				current_input.valid3 = false;
			}
			current_state = S_TWO_LEFT;
		}
		break;
	case S_FOUR_LEFT:
		if (!out.full()) {
			if (current_input.valid0) {
				out.write(current_input.data0);
				current_input.valid0 = false;
			} else if (current_input.valid1) {
				out.write(current_input.data1);
				current_input.valid1 = false;
			} else if (current_input.valid2) {
				out.write(current_input.data2);
				current_input.valid2 = false;
			} else {
				out.write(current_input.data3);
				current_input.valid3 = false;
			}
			current_state = S_THREE_LEFT;
		}
		break;
	}
}

// Top module, combines prior stages with dataflow directive
// Testbench may report incorrect stats with ap_ctrl_none
// However, ap_ctrl_none is necessary when exporting logic
void compress(in_stream_t &in, out_stream_t &out) {
#pragma HLS DATAFLOW
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE axis register both port=out
#pragma HLS INTERFACE axis register both port=in
	static pack_stream_t pack_buffer("pack_buffer");
#pragma HLS STREAM variable=pack_buffer depth=1024

	convert_inputs(in, pack_buffer);
	write_out(pack_buffer, out);
}
