//#include "SystemConfiguration.h"
#include "Constants.h"
#include "Definitions.h"

#ifndef BANK_H
#define BANK_H
#ifdef BANK_H
// helps format input for Bank Interface
#define format_input(data_in,column,row,busPacketType) (((((((0|data_in) << 8) | column) << 8) | row) << 3) | busPacketType)
// Bank Function that is to be mapped to Hardware IP
void Bank(unsigned input, unsigned char& data_out);

#endif
#endif
