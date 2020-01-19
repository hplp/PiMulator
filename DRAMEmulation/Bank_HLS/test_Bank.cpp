#include "Bank.h"

void Bank(bank_in input, unsigned char& data_out);

int main() {

#ifdef TEST1
	// One Value Test
	unsigned char data_out = 0;
	bank_in input;
	input.busPacketType = WRITE;
	input.row = 0;
	input.column = 0;
	input.data_in = 30;

	Bank(input, data_out);
	cout << "[WRITE] Value: " << int(input.data_in) << " " << int(data_out) << endl;

	input.busPacketType = READ;
	Bank(input, data_out);
	cout << "[READ] Value: " << int(input.data_in) << " " << int(data_out) << endl;
#endif

#ifdef TEST2
	// Brute Force Test All
	unsigned char data_out = 0;
	bank_in input;

	for (unsigned int i = 0; i < NUM_ROWS; i++) {
		input.row = i;
		for (unsigned int j = 0; j < NUM_COLS; j++) {
			input.column = j;
			input.data_in = (unsigned char) ((i + j) % 256);

			input.busPacketType = WRITE;
			Bank(input, data_out);

			input.busPacketType = READ;
			Bank(input, data_out);

			if (data_out != (unsigned char) ((i + j) % 256)) {
				cout << "Wrong at iteration " << i << ", " << j << endl;
				cout << "Data supposed to be " << (int) (unsigned char) ((i + j) % 256) << "\nData is: " << (int) data_out << endl;
				return 0;
			} else {
				cout << ". ";
			}

			//cout << "Wrote: " << (int) (unsigned char) ((i + j) % 256) << " Read: " << int(data) << endl;

		}
	}

	cout << "Success\n";
#endif

	return 0;
}
