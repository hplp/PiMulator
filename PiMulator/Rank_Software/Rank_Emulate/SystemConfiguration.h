/*********************************************************************************
*  Copyright (c) 2010-2011, Elliott Cooper-Balis
*                             Paul Rosenfeld
*                             Bruce Jacob
*                             University of Maryland
*                             dramninjas [at] gmail [dot] com
*  All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without
*  modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright notice,
*        this list of conditions and the following disclaimer.
*
*     * Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
*  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
*  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
*  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
*  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
*  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*********************************************************************************/



#ifndef SYSCONFIG_H
#define SYSCONFIG_H

#include <string>

//#include <iostream>
//#include <fstream>
//#include <vector>
//#include <cstdlib>
//#include <stdint.h>
//#include "PrintMacros.h"
//#ifdef __APPLE__
//#include <sys/types.h>
//#endif

// Here we place definitions and parameters, which we'll need
// Part (1) : original DRAMSim2 Definitions
// Part (2) : added constant parameters (not to bother to read those from external files)

//Configuration values for the current system

// Part (1) : original DRAMSim2 Definitions

//number of latencies per bucket in the latency histogram
//TODO: move to system ini file
#define HISTOGRAM_BIN_SIZE 10

/* Power computations are localized to MemoryController.cpp */
extern unsigned IDD0;
extern unsigned IDD1;
extern unsigned IDD2P;
extern unsigned IDD2Q;
extern unsigned IDD2N;
extern unsigned IDD3Pf;
extern unsigned IDD3Ps;
extern unsigned IDD3N;
extern unsigned IDD4W;
extern unsigned IDD4R;
extern unsigned IDD5;
extern unsigned IDD6;
extern unsigned IDD6L;
extern unsigned IDD7;
extern float Vdd;

extern std::ofstream cmd_verify_out; //used by BusPacket.cpp if VERIFICATION_OUTPUT is enabled
									 //extern std::ofstream visDataOut;

									 //TODO: namespace these to DRAMSim:: 
extern bool VERIFICATION_OUTPUT; // output suitable to feed to modelsim

extern bool DEBUG_TRANS_Q;
extern bool DEBUG_CMD_Q;
extern bool DEBUG_ADDR_MAP;
extern bool DEBUG_BANKSTATE;
extern bool DEBUG_BUS;
extern bool DEBUG_BANKS;
extern bool DEBUG_POWER;
extern bool USE_LOW_POWER;
extern bool VIS_FILE_OUTPUT;

extern uint64_t TOTAL_STORAGE;
extern unsigned NUM_BANKS;
extern unsigned NUM_BANKS_LOG;
extern unsigned NUM_RANKS;
extern unsigned NUM_RANKS_LOG;
extern unsigned NUM_CHANS;
extern unsigned NUM_CHANS_LOG;
extern unsigned NUM_ROWS;
extern unsigned NUM_ROWS_LOG;
extern unsigned NUM_COLS;
extern unsigned NUM_COLS_LOG;
extern unsigned DEVICE_WIDTH;
extern unsigned BYTE_OFFSET_WIDTH;
extern unsigned TRANSACTION_SIZE;
extern unsigned THROW_AWAY_BITS;
extern unsigned COL_LOW_BIT_WIDTH;

//in nanoseconds
extern unsigned REFRESH_PERIOD;
extern float tCK;

extern unsigned CL;
extern unsigned AL;
#define RL (CL+AL)
#define WL (RL-1)
extern unsigned BL;
extern unsigned tRAS;
extern unsigned tRCD;
extern unsigned tRRD;
extern unsigned tRC;
extern unsigned tRP;
extern unsigned tCCD;
extern unsigned tRTP;
extern unsigned tWTR;
extern unsigned tWR;
extern unsigned tRTRS;
extern unsigned tRFC;
extern unsigned tFAW;
extern unsigned tCKE;
extern unsigned tXP;

extern unsigned tCMD;

/* For power parameters (current and voltage), see externs in MemoryController.cpp */

extern unsigned NUM_DEVICES;



extern unsigned JEDEC_DATA_BUS_BITS;

//Memory Controller related parameters
extern unsigned TRANS_QUEUE_DEPTH;
extern unsigned CMD_QUEUE_DEPTH;

extern unsigned EPOCH_LENGTH;

extern unsigned TOTAL_ROW_ACCESSES;

extern std::string ROW_BUFFER_POLICY;
extern std::string SCHEDULING_POLICY;
extern std::string ADDRESS_MAPPING_SCHEME;
extern std::string QUEUING_STRUCTURE;

enum TraceType
{
	k6,
	mase,
	misc
};

enum AddressMappingScheme
{
	Scheme1,
	Scheme2,
	Scheme3,
	Scheme4,
	Scheme5,
	Scheme6,
	Scheme7
};

// used in MemoryController and CommandQueue
enum RowBufferPolicy
{
	OpenPage,
	ClosePage
};

// Only used in CommandQueue
enum QueuingStructure
{
	PerRank,
	PerRankPerBank
};

enum SchedulingPolicy
{
	RankThenBankRoundRobin,
	BankThenRankRoundRobin
};


// set by IniReader.cpp


//namespace DRAMSim
//{
// COMMENTED
//typedef void(*returnCallBack_t)(unsigned id, uint64_t addr, uint64_t clockcycle);
//typedef void(*powerCallBack_t)(double bgpower, double burstpower, double refreshpower, double actprepower);

extern RowBufferPolicy rowBufferPolicy;
extern SchedulingPolicy schedulingPolicy;
extern AddressMappingScheme addressMappingScheme;
extern QueuingStructure queuingStructure;
//
//FUNCTIONS
//

// COMMENTED
//unsigned inline dramsim_log2(unsigned value)
//{
//	unsigned logbase2 = 0;
//	unsigned orig = value;
//	value >>= 1;
//	while (value > 0)
//	{
//		value >>= 1;
//		logbase2++;
//	}
//	if ((unsigned)1 << logbase2 < orig)logbase2++;
//	return logbase2;
//}
//inline bool isPowerOfTwo(unsigned long x)
//{
//	return (1UL << dramsim_log2(x)) == x;
//}


//}
;

// Part (2) : added constant parameters (not to bother to read those from external files)

// added params (cmd_queue)
#define CMD_QUEUE_DEPTH 32
// 
// add definitions of constants (mcc)

#define TRANS_QUEUE_DEPTH 32

//
// same bank
//same bank
#define READ_TO_PRE_DELAY (AL+BL/2+ max(tRTP,tCCD)-tCCD)
#define WRITE_TO_PRE_DELAY (WL+BL/2+tWR)
#define READ_TO_WRITE_DELAY (RL+BL/2+tRTRS-WL)
#define READ_AUTOPRE_DELAY (AL+tRTP+tRP)
#define WRITE_AUTOPRE_DELAY (WL+BL/2+tWR+tRP)
#define WRITE_TO_READ_DELAY_B (WL+BL/2+tWTR) //interbank
#define WRITE_TO_READ_DELAY_R (WL+BL/2+tRTRS-RL) //interrank

// add all timing paramater here (rank)
#define NUM_BANKS 8
#define AL 5
#define BL 8
#define tRTP 5
#define	tCCD 4
#define CL 10

//#define READ_TO_PRE_DELAY (AL+BL/2+ max(tRTP,tCCD)-tCCD)
//#define READ_TO_WRITE_DELAY (RL+BL/2+tRTRS-WL)
#define RL (CL+AL)
#define	tRTRS 1
#define WL (RL-1)
//#define READ_AUTOPRE_DELAY (AL+tRTP+tRP)
#define tRP 10

//#define WRITE_TO_PRE_DELAY (WL+BL/2+tWR)
#define tWR 10
//#define WRITE_TO_READ_DELAY_B (WL+BL/2+tWTR)
#define tWTR 5
//#define WRITE_AUTOPRE_DELAY (WL+BL/2+tWR+tRP)
#define tRC 34
#define tRCD 10
#define tRAS 24
#define tRRD 4
#define tRFC 74
#define tCKE 4
#define tXP 4
//

// extra (from system.ini)

#define NUM_CHANS  1 //number of *logically independent* channels(i.e.each with a separate memory controller); should be a power of
#define JEDEC_DATA_BUS_BITS   64 //; Always 64 for DDRx; if you want multiple *ganged* channels, set this to N * 64
#define TRANS_QUEUE_DEPTH   32//; transaction queue, i.e., CPU - level commands such as : READ 0xbeef
#define CMD_QUEUE_DEPTH   32//; command queue, i.e., DRAM - level commands such as : CAS 544, RAS 4
#define EPOCH_LENGTH   666666666//; length of an epoch in cycles(granularity of simulation)
#define ROW_BUFFER_POLICY   open_page//; close_page or open_page
#define ADDRESS_MAPPING_SCHEME   scheme1; //valid schemes 1 - 7; For multiple independent channels, use scheme7 since it has the most parallelism
#define SCHEDULING_POLICY   rank_then_bank_round_robin//; bank_then_rank_round_robin or rank_then_bank_round_robin
#define QUEUING_STRUCTURE   per_rank//; per_rank or per_rank_per_bank

//; for true / false, please use all lowercase
#define DEBUG_TRANS_Q   false
#define DEBUG_CMD_Q   false
#define DEBUG_ADDR_MAP   false
#define DEBUG_BUS   false
#define DEBUG_BANKSTATE   false
#define DEBUG_BANKS   false
#define DEBUG_POWER   false
#define VIS_FILE_OUTPUT   true

#define USE_LOW_POWER   true//; go into low power mode when idle ?
#define VERIFICATION_OUTPUT   true//; should be false for normal operation
#define TOTAL_ROW_ACCESSES   4//;

// extra (from device.ini)

//#define NUM_BANKS   8
#define NUM_ROWS   512
#define NUM_COLS   512
#define DEVICE_WIDTH   16

// in nanoseconds
// #define REFRESH_PERIOD 7800
#define REFRESH_PERIOD   7800
#define tCK   1.5// *

//#define CL   10// *
//#define AL   0// *
//#define  AL   3// needs to be tRCD - 1 or 0
//#define  RL   (CL + AL)
//#define WL   (RL - 1)
//#define BL   8// *
//#define tRAS   24// *
//#define tRCD   10// *
//#define tRRD   4// *
//#define tRC   34// *
//#define tRP   10// *
//#define tCCD   4// *
//#define tRTP   5// *
//#define tWTR   5// *
//#define tWR   10// *
//#define tRTRS   1// --RANK PARAMETER, TODO
//#define tRFC   74// *
#define tFAW   20// *
//#define tCKE   4// *
//#define tXP   4// *

#define tCMD   1// *
//
#define IDD0   110//
#define IDD1   150//
#define IDD2P   12//
#define IDD2Q   60//
#define IDD2N   65//
#define IDD3Pf   40//
#define IDD3Ps   40//
#define IDD3N   60//
#define IDD4W   355//
#define IDD4R   290//
#define IDD5   240//
#define IDD6   6//
#define IDD6L   9//
#define IDD7   420//
#define Vdd   1.5/// TODO: double check this


// max compute
#define max(a1,a2) (a1 > a2) ? a1 : a2

#endif

#pragma once
