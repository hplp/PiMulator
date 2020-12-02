#define max(a1,a2) (a1 > a2) ? a1 : a2

enum BusPacketType {
		READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
	};

// extra code that might be needed for Rank development

//enum CurrentBankState
//{
//	Idle,
//	RowActive,
//	Precharging,
//	Refreshing,
//	PowerDown
//};

//struct BankState {
//
//	CurrentBankState currentBankState;
//	unsigned openRowAddress;
//	unsigned long int nextRead;
//	unsigned long int nextWrite;
//	unsigned long int nextActivate;
//	unsigned long int nextPrecharge;
//	unsigned long int nextPowerUp;
//
//	BusPacketType lastCommand;
//	unsigned stateChangeCountdown;
//	BankState() :
//		currentBankState(Idle),
//		openRowAddress(0),
//		nextRead(0),
//		nextWrite(0),
//		nextActivate(0),
//		nextPrecharge(0),
//		nextPowerUp(0),
//		lastCommand(READ),
//		stateChangeCountdown(0)
//	{}
//	void print()
//	{
//		printf("Bank State Info: currentBankState: %d, openRowAddress: %u, nextRead: %u,nextWrite: %u, nextActivate: %u, nextPrecharge: %u"
//			" nextPowerUp: %u, lastCommand:  %u, stateChangeCountdown: %u\n", currentBankState, openRowAddress, nextRead, nextWrite, nextActivate,
//			nextPrecharge, nextPowerUp, lastCommand, stateChangeCountdown);
//
//	}
//};

//struct BusPacket {
////	BusPacket() {}
//	BusPacket(BusPacketType bp, unsigned pa, unsigned c, unsigned r, unsigned ra, unsigned b, unsigned char d) {
//		busPacketType = bp; column = c; row = r; bank = b; rank = ra; physicalAddress = pa; data = d;
//	}
//	void print() {
//		//printf("Bus Packet Data: type: %d, col: %d, row: %d, bank %d, rank %d, address %x, data %d\n", busPacketType, column, row, bank, rank, physicalAddress, data);
//	}
//
//	BusPacketType busPacketType;
//	unsigned column;
//	unsigned row;
//	unsigned bank;
//	unsigned rank;
//	unsigned long int physicalAddress;
//	unsigned char data;
//};

//#pragma once
