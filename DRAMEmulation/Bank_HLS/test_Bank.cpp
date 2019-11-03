#include "Bank.h"

unsigned get_b_input(unsigned busPacketType, unsigned row, unsigned column, unsigned data_in) {
//	unsigned return_val=0;
//	return_val = data_in;
//	return_val <<= 9;
//	return return_val;
//	return data_in << 9;
    return ((((((0 | data_in) << 8) | column) << 8) | row) << 3) | busPacketType;
}

void Bank(bank_in b_input, unsigned char& data_out);

int main() {

#ifdef TEST1
    // One Value Test
    unsigned char data_out = 0;
    bank_in b_input;

    b_input.row = 0;
    b_input.column = 0;
    b_input.data_in = 35;

    b_input.busPacketType = WRITE;
    Bank(b_input, data_out);
    cout << "WRITE: " << int(b_input.data_in) << " " << int(data_out) << endl;

    b_input.busPacketType = READ;
    Bank(b_input, data_out);
    cout << "READ: " << int(b_input.data_in) << " " << int(data_out) << endl;
#endif

#ifdef TEST2
    // Brute Force Test
    unsigned char data_out = 0;
    bank_in b_input;

    for (unsigned int i = 0; i < NUM_ROWS; i++) {
        b_input.row = i;
        for (unsigned int j = 0; j < NUM_COLS; j++) {
            b_input.column = j;
            b_input.data_in = (unsigned char) ((i + j) % 256);

            b_input.busPacketType = WRITE;
            Bank(b_input, data_out);

            b_input.busPacketType = READ;
            Bank(b_input, data_out);

            if (data_out != (unsigned char) ((i + j) % 256)) {
                cout << "Wrong at iteration " << i << ", " << j << endl;
                cout << "Data supposed to be " << (int) (unsigned char) ((i + j) % 256) << "\nData is: " << (int) data_out << endl;
                return 0;
            }

            //cout << "Wrote: " << (int) (unsigned char) ((i + j) % 256) << " Read: " << int(data_out) << endl;

        }
    }

    cout << "Success\n";
#endif

    return 0;
}
