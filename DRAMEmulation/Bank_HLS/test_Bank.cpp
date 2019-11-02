#include "Bank.h"

#define TEST2 // TEST1 TEST2

unsigned get_b_input(unsigned busPacketType, unsigned row, unsigned column, unsigned data_in) {
//	unsigned return_val=0;
//	return_val = data_in;
//	return_val <<= 9;
//	return return_val;
//	return data_in << 9;
    return ((((((0 | data_in) << 8) | column) << 8) | row) << 3) | busPacketType;
}
//void Bank(BusPacketType busPacketType, unsigned row, unsigned column,
//		 unsigned char data_in, unsigned char& data_out);
void Bank(unsigned b_input, unsigned char& data_out);

int main() {

#ifdef TEST1
    // One Value Test
    unsigned char data_in = 35;
    unsigned char data_out = 0;
    Bank(get_b_input(WRITE, 0, 0, data_in), data_out);
    std::cout << "Value: " << int(data_in) << " " << int(data_out) << std::endl;
    Bank(get_b_input(READ, 0, 0, data_in), data_out);
    std::cout << "Value: " << int(data_in) << " " << int(data_out) << std::endl;
#endif

#ifdef TEST2
    // Brute Force Test
    unsigned char data_out1 = 0;
    unsigned char data_out2 = 0;
    unsigned b_input = 0;

    for (int i = 0; i < NUM_ROWS; i++) {
        for (int j = 0; j < NUM_COLS; j++) {
//			Bank(WRITE, i, j, (unsigned char) ((i + j) % 256), data_out1);
//			Bank(READ, i, j, 0, data_out2);
//			b_input(WRITE, i, j, (unsigned char) ((i + j) % 256));
            Bank(get_b_input(WRITE, i, j, (unsigned char) ((i + j) % 256)), data_out1);
//			if (j==8 && i==3){
//				Bank(get_(WRITE, i, j, (unsigned char) ((i + j+1) % 256)),
//						data_out1);
////				printf(": %x\n",get_(WRITE, i, j, (unsigned char) ((i + j) % 256)));
//
////				return 0;
//			}

            Bank(get_b_input(READ, i, j, 0), data_out2);

            if (data_out2 != (unsigned char) ((i + j) % 256)) {
                std::cout << "Wrong at iteration " << i << ", " << j << std::endl;
                cout << "Data supposed to be " << (int) (unsigned char) ((i + j) % 256) << "\nData is: " << (int) data_out2 << endl;
                return 0;
            }

        }
    }
    cout << "Success\n";
#endif

    return 0;
}
