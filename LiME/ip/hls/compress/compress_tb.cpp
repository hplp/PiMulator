#include "compress.hpp"

// Fully automated test suite for compression module
// Tests most fields to make sure bits are passed properly
// Will return failure if module is found to not conform to spec

// Helper print functions
void print_in(const in_packet_t & in) {
	std::cout << "logID: " << in.logID << std::endl;
	std::cout << "timestamp: " << in.timestamp << std::endl;
	std::cout << "a0_wr_addr_latch: " << in.a0_wr_addr_latch << std::endl;
	std::cout << "a0_rd_addr_latch: " << in.a0_rd_addr_latch << std::endl;
	std::cout << "a0_araddr: " << in.a0_araddr << std::endl;
	std::cout << "a0_awaddr: " << in.a0_awaddr << std::endl;
	std::cout << "a1_wr_addr_latch: " << in.a1_wr_addr_latch << std::endl;
	std::cout << "a1_rd_addr_latch: " << in.a1_rd_addr_latch << std::endl;
	std::cout << "a1_araddr: " << in.a1_araddr << std::endl;
	std::cout << "a1_awaddr: " << in.a1_awaddr << std::endl;
}
void print_out(const out_packet_t & in) {
	std::cout << "logID: " << in.logID << std::endl;
	std::cout << "timestamp: " << in.timestamp << std::endl;
	std::cout << "slot: " << in.slot << std::endl;
	std::cout << "write: " << in.write << std::endl;
	std::cout << "addr_latch: " << in.addr_latch << std::endl;
	std::cout << "a_addr: " << in.a_addr << std::endl;
}

int main(int argc, char** argv) {
	const int num_transactions = 7;

	in_stream_t inputs("inputs");
	out_stream_t outputs("outputs");
	out_stream_t expected_outputs("expected_outputs");

	// Test various fields to see if bits are passed properly
	int num_expected_outputs = 0;
	static ap_uint<30> time_acc = 0;

	std::cout << std::hex;
	for (int i = 0; i < 54; ++i) {
		in_packet_t input(0);
		out_packet_t expected_output(0);
		int option = i % 5;

		input.timestamp = i;
		time_acc += i;
		expected_output.timestamp = time_acc;
		if (option == 0) {
			input.a0_wr_addr_latch = 1;
			input.a0_awaddr = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.addr_latch = 1;
			expected_output.a_addr = i;
		} else if (option == 1) {
			input.a0_rd_addr_latch = 1;
			input.a0_araddr = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.addr_latch = 1;
			expected_output.a_addr = i;
		} else if (option == 2) {
			input.a1_wr_addr_latch = 1;
			input.a1_awaddr = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.addr_latch = 1;
			expected_output.a_addr = i;
		} else if (option == 3) {
			input.a1_rd_addr_latch = 1;
			input.a1_araddr = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.addr_latch = 1;
			expected_output.a_addr = i;
		} else if (option == 4) {
			in_t input_packed = input;
			out_t expected_output_packed = expected_output;

			input_packed[0] = 1;
			input_packed(63,32) = 42;
			expected_output_packed(63,0) = input_packed(63,0);

			input = input_packed;
			expected_output = expected_output_packed;
		} else if (option == 5) {
			input.a0_first_wr = 1;
			input.a0_awlen = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.first = 1;
			expected_output.a_len = i;
		} else if (option == 6) {
			input.a0_first_rd = 1;
			input.a0_arlen = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.first = 1;
			expected_output.a_len = i;
		} else if (option == 7) {
			input.a0_last_wr = 1;
			input.a0_awlen = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.a_len = i;
		} else if (option == 8) {
			input.a0_last_rd = 1;
			input.a0_arlen = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.a_len = i;
		} else if (option == 9) {
			input.a0_last_wr = 1;
			input.a0_bid = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output._id = i;
		} else if (option == 10) {
			input.a0_last_rd = 1;
			input.a0_rid = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output._id = i;
		} else if (option == 11) {
			input.a0_last_wr = 1;
			input.a0_awid = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.a_id = i;
		} else if (option == 12) {
			input.a0_last_rd = 1;
			input.a0_arid = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.a_id = i;
		} else if (option == 13) {
			input.a0_last_wr = 1;
			input.a0_ext_event = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.ext_event = i;
		} else if (option == 14) {
			input.a0_last_rd = 1;
			input.a0_ext_event = i;
			expected_output.slot = 0;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.ext_event = i;
		} else if (option == 15) {
			input.a1_first_wr = 1;
			input.a1_awlen = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.first = 1;
			expected_output.a_len = i;
		} else if (option == 16) {
			input.a1_first_rd = 1;
			input.a1_arlen = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.first = 1;
			expected_output.a_len = i;
		} else if (option == 17) {
			input.a1_last_wr = 1;
			input.a1_awlen = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.a_len = i;
		} else if (option == 18) {
			input.a1_last_rd = 1;
			input.a1_arlen = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.a_len = i;
		} else if (option == 19) {
			input.a1_last_wr = 1;
			input.a1_bid = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output._id = i;
		} else if (option == 20) {
			input.a1_last_rd = 1;
			input.a1_rid = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output._id = i;
		} else if (option == 21) {
			input.a1_last_wr = 1;
			input.a1_awid = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.a_id = i;
		} else if (option == 22) {
			input.a1_last_rd = 1;
			input.a1_arid = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.a_id = i;
		} else if (option == 23) {
			input.a1_last_wr = 1;
			input.a1_ext_event = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.last = 1;
			expected_output.ext_event = i;
		} else if (option == 24) {
			input.a1_last_rd = 1;
			input.a1_ext_event = i;
			expected_output.slot = 1;
			expected_output.write = 0;
			expected_output.last = 1;
			expected_output.ext_event = i;
		} else if (option == 25) {
			input.a0_response = 1;
			input.a0_awaddr = i;
			expected_output.slot = 0;
			expected_output.write = 1;
			expected_output.response = 1;
			expected_output.a_addr = i;
		} else if (option == 26) {
			input.a1_response = 1;
			input.a1_awaddr = i;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.response = 1;
			expected_output.a_addr = i;
		} else if (option == 27) {
			input.a1_response = 1;
			input.loop = 1;
			expected_output.slot = 1;
			expected_output.write = 1;
			expected_output.response = 1;
			expected_output.loop = 1;
		}

		inputs.write((in_t)input);
		expected_outputs.write((out_t)expected_output);
		++num_expected_outputs;

		std::cout << "input: " << (in_t)input << std::endl;
		print_in(input);
		std::cout << "expected_output: " << (out_t)expected_output << std::endl;
		print_out(expected_output);
	}

	// Tests outputting multiple output events for single input events
	for (int j = 0; j < 5; ++j) {
		for (int i = 2; i <= 4; ++i) {
			in_packet_t input(0);
			input.timestamp = i+j;
			for (int option = 0; option < i; ++option) {
				out_packet_t expected_output(0);

				if (option == 0) {
					expected_output.timestamp = i+j;
				} else {
					expected_output.timestamp = 0;
				}
				if (option == 0) {
					input.a0_wr_addr_latch = 1;
					input.a0_awaddr = option+i+j;
					expected_output.slot = 0;
					expected_output.write = 1;
					expected_output.addr_latch = 1;
					expected_output.a_addr = option+i+j;
				} else if (option == 1) {
					input.a0_rd_addr_latch = 1;
					input.a0_araddr = option+i+j;
					expected_output.slot = 0;
					expected_output.write = 0;
					expected_output.addr_latch = 1;
					expected_output.a_addr = option+i+j;
				} else if (option == 2) {
					input.a1_wr_addr_latch = 1;
					input.a1_awaddr = option+i+j;
					expected_output.slot = 1;
					expected_output.write = 1;
					expected_output.addr_latch = 1;
					expected_output.a_addr = option+i+j;
				} else if (option == 3) {
					input.a1_rd_addr_latch = 1;
					input.a1_araddr = option+i+j;
					expected_output.slot = 1;
					expected_output.write = 0;
					expected_output.addr_latch = 1;
					expected_output.a_addr = option+i+j;
				}

				expected_outputs.write(expected_output);
				print_out(expected_output);
				std::cout << "-----------------" << std::endl;
				++num_expected_outputs;
			}
			inputs.write(input);
			print_in(input);
			std::cout << "--------------------------------" << std::endl;
		}
	}
	printf("expecting %d outputs\n", num_expected_outputs);

	// run tests
	for (int i = 0; i < num_expected_outputs*2; ++i) {
		compress(inputs, outputs);
	}

	// check if outputs conform to expectations
	bool pass = true;
	out_t output, expected_output;
	if (!outputs.empty()) {
		while (!outputs.empty()) {
			outputs.read(output);
			printf("here\n");
			if (expected_outputs.empty()) {
				printf("too many outputs\n");
				pass = false;
				continue;
			}
			std::cout << "--------------------------------" << std::endl;
			expected_outputs.read(expected_output);
			std::cout << output << " vs " << expected_output << std::endl;
			print_out(output);
			std::cout << "-----------------" << std::endl;
			print_out(expected_output);
			for (int i = 0; i < 128; ++i) {
				if (output[i] != expected_output[i]) {
					pass = false;
					printf("output differs at bit %u, %u != %u\n", i, (unsigned)output[i], (unsigned)expected_output[i]);
				}
			}
		}
	}
	if (!expected_outputs.empty()) {
		while (!expected_outputs.empty()) {
			printf("too few outputs\n");
			pass = false;
			expected_outputs.read(expected_output);
			std::cout << "expecting " << expected_output << std::endl;
		}
	}

	if (pass) printf("PASS\n");
	else printf("FAIL\n");
	//return 0;
	return !pass;
}
