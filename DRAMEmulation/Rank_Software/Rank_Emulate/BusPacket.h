// Declaration of BusPacket: the primary object to transfer data in Memory

#include <stdio.h>

enum BusPacketType {
	READ, READ_P, WRITE, WRITE_P, ACTIVATE, PRECHARGE, REFRESH, DATA
};

struct BusPacket {
	BusPacket() {}
	BusPacket(BusPacketType bp, unsigned pa, unsigned c, unsigned r, unsigned ra, unsigned b, unsigned char d) {
		busPacketType = bp; column = c; row = r; bank = b; rank = ra; physicalAddress = pa; data = d;
	}
	void print() {
		printf("Bus Packet Data: type: %d, col: %d, row: %d, bank %d, rank %d, address %x, data %d\n", busPacketType, column, row, bank, rank, physicalAddress, data);
	}

	BusPacketType busPacketType;
	unsigned column;
	unsigned row;
	unsigned bank;
	unsigned rank;
	unsigned long int physicalAddress;
	unsigned char data;
};

#pragma once
