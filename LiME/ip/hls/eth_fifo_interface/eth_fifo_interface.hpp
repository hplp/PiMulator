#ifndef EFI_H
#define EFI_H

#include <ap_int.h>
#include <hls_stream.h>
#include <assert.h>

// Shortened data types
typedef ap_uint<1> u1t;
typedef ap_uint<4> u4t;
typedef ap_uint<8> u8t;
typedef ap_uint<11> u11t;
typedef ap_uint<14> u14t;
typedef ap_uint<16> u16t;
typedef ap_uint<128> u128t;

// Data stream types for I/O and FIFO
typedef hls::stream<u8t> u8st;
typedef hls::stream<u128t> u128st;

// Number of max trace data bytes in packet
// MUST BE MULTIPLE OF 16
// Add 1 for true max data size (for ID field)
// Add another 14 bytes for Ethernet header
// Useful values:
// Max value for meeting IEEE spec: 1488
// Max value for common jumbo frame support: 8992
const int PACKET_SIZE = 1488;

void eth_fifo_interface(
	u1t dma_tx_end_tog,
	u1t tx_r_fixed_lat,
	u1t tx_r_rd,
	u4t tx_r_status,
	u128st &data_in,
	u1t &dma_tx_status_tog,
	u1t &tx_r_control,
	u8t &tx_r_data,
	u1t &tx_r_data_rdy,
	u1t &tx_r_eop,
	u1t &tx_r_err,
	u1t &tx_r_flushed,
	u1t &tx_r_sop,
	u1t &tx_r_underflow,
	u1t &tx_r_valid);

#endif   // EFI_H
