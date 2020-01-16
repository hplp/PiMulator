#include "Bank.h"

void Bank(bank_in input, unsigned char& data_out);

int main() {

#ifdef TEST1
	// One Value Test
	unsigned char data = 0;
	bank_in input;
	input.busPacketType = WRITE;
	input.row = 0;
	input.column = 0;
	input.data_in = 30;

	Bank(input, data);
	cout << "[WRITE] Value: " << int(data) << endl;

	input.busPacketType = READ;
	input.data_in = 0;

	Bank(input, data);
	cout << "[READ] Value: " << int(data) << endl;
#endif

#ifdef TEST2
	// Brute Force Test All
	unsigned char data_out1 = 0;
	unsigned char data_out2 = 0;
	bank_in input;

	for (unsigned int i = 0; i < NUM_ROWS; i++) {
		for (unsigned int j = 0; j < NUM_COLS; j++) {

			input.busPacketType = WRITE;
			input.row = (unsigned char) i;
			input.column = (unsigned char) j;
			input.data_in = (unsigned char) ((i + j) % 256);

			Bank(input, data_out1);

			input.busPacketType = READ;
			input.data_in = 0;

			Bank(input, data_out2);

			if (data_out2 != (unsigned char) ((i + j) % 256)) {
				cout << "Wrong at iteration (" << (int) i << ", " << (int) j << ")" << endl;
				cout << "Data supposed to be " << (int) (unsigned char) ((i + j) % 256) << "\nData is: " << (int) data_out2 << endl;
				return 0;
			} else {
				cout << ". ";
			}
		}
	}
	cout << "Success\n";
#endif

	return 0;
}

//void Bank(BusPacketType busPacketType, unsigned row, unsigned column, unsigned char data_in, unsigned char& data_out);

//unsigned get_input(unsigned busPacketType, unsigned row, unsigned column, unsigned data_in) {
//	unsigned return_val=0;
//	return_val = data_in;
//	return_val <<= 9;
//	return return_val;
//	return data_in << 9;
//	return ((((((0 | data_in) << 8) | column) << 8) | row) << 3) | busPacketType;
//}
//void Bank(unsigned input, unsigned char& data_out);

//			Bank(WRITE, i, j, (unsigned char) ((i + j) % 256), data_out1);
//			Bank(READ, i, j, 0, data_out2);
//			Bank(get_input(WRITE, i, j, (unsigned char) ((i + j) % 256)), data_out1);
//			Bank(get_input(READ, i, j, 0), data_out2);

//Bank(WRITE, 0, 0, 30, data);
//Bank(READ, 0, 0, 0, data);
