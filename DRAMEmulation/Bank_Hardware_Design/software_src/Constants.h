// All DDR3 Parameters needed

#define CMD_QUEUE_DEPTH 32
#define TRANS_QUEUE_DEPTH 32
// same bank

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
#define RL (CL+AL)
#define	tRTRS 1
#define WL (RL-1)
#define tRP 10


#define tWR 10
#define tWTR 5
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

#define NUM_ROWS 256
#define NUM_COLS 256
#define DEVICE_WIDTH   16

// in nanoseconds
#define REFRESH_PERIOD   7800
#define tCK   1.5// *
#define tFAW   20// *

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

