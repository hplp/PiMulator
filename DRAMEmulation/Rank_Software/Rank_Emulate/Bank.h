// Bank Function Declaration
#include "BusPacket.h"
#include "SystemConfiguration.h"

#ifndef BANK_H
#define BANK_H
#ifdef BANK_H

void bank(
	// added
	unsigned id,
	// input
	BusPacketType busPacketType,
	unsigned row,
	unsigned column,
	const unsigned char data_in,
	//output
	unsigned char& data_out);

#endif
#endif
