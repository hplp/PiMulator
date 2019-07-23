#include <iostream>
using namespace std;
enum BusPacketType {
	READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
};



#define NUM_ROWS 512
#define NUM_COLS 512

#define TEST2


void Bank(BusPacketType busPacketType, unsigned row, unsigned column,
		 unsigned char data_in, unsigned char& data_out);

int main() {

#ifdef TEST1
	// One Value Test
	unsigned char data = 0;
	Bank(WRITE, 0,  0, 30, data);
	Bank(READ, 0, 0, 0, data);
	std::cout << "Value: " << int(data) << std::endl;
#endif

#ifdef TEST2
	// Brute Force Test
	unsigned char data_out1 = 0;
	unsigned char data_out2 = 0;

	for (int i = 0; i < NUM_ROWS; i++) {
		for (int j = 0; j < NUM_COLS; j++) {
			Bank(WRITE, i, j, (unsigned char) ((i + j) % 256), data_out1);
			Bank(READ, i, j, 0, data_out2);

			if (data_out2 != (unsigned char) ((i + j) % 256)) {
				std::cout << "Wrong at iteration " << i << ", " << j
						<< std::endl;
				cout << "Data supposed to be "
						<< (int) (unsigned char) ((i + j) % 256)
						<< "\nData is: " << (int) data_out2 << endl;
				return 0;
			}

		}
	}
	cout << "Success\n";
#endif

	return 0;
}
