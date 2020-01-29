#include "Bank.h"

int main() {

#ifdef TEST1
	// One Value Test
	unsigned char data_out = 0;
	bank_in bankpacket_in;
	bankpacket_in.busPacketType = WRITE;
	bankpacket_in.row = 0;
	bankpacket_in.column = 0;
	bankpacket_in.data_in = 30;

	Bank(bankpacket_in, data_out);
	cout << "[WRITE] Value: " << int(bankpacket_in.data_in) << " " << int(data_out) << endl;

	bankpacket_in.busPacketType = READ;
	bankpacket_in.data_in = 0;

	Bank(bankpacket_in, data_out);
	cout << "[READ] Value: " << int(bankpacket_in.data_in) << " " << int(data_out) << endl;
#endif

#ifdef TEST2
	// Brute Force Test All
	unsigned char data_out = 0;
	bank_in bankpacket_in;

	for (unsigned int i = 0; i < NUM_ROWS; i++) {
		bankpacket_in.row = (unsigned char) i;
		for (unsigned int j = 0; j < NUM_COLS; j++) {

			bankpacket_in.busPacketType = WRITE;
			bankpacket_in.column = (unsigned char) j;
			bankpacket_in.data_in = (unsigned char) ((i + j) % 256);

			Bank(bankpacket_in, data_out);

			bankpacket_in.busPacketType = READ;
			bankpacket_in.data_in = 0;

			Bank(bankpacket_in, data_out);

			if (data_out != (unsigned char) ((i + j) % 256)) {
				cout << "Wrong at iteration (" << i << ", " << j << ")" << endl;
				cout << "Data supposed to be " << (int) (unsigned char) ((i + j) % 256) << "\nData is: " << (int) data_out << endl;
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
