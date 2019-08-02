#ifndef COMPRESS_H
#define COMPRESS_H

#include <ap_int.h>
#include <hls_stream.h>
#include <assert.h>

// Old APM format
/*
typedef struct {
	ap_uint<1> logID;
	ap_uint<30> timestamp;
	ap_uint<1> loop;
	// ap_uint<32> SW;
	ap_uint<3> a0_ext_event;
	ap_uint<1> a0_wr_addr_latch;
	ap_uint<1> a0_first_wr;
	ap_uint<1> a0_last_wr;
	ap_uint<1> a0_response;
	ap_uint<1> a0_rd_addr_latch;
	ap_uint<1> a0_first_rd;
	ap_uint<1> a0_last_rd;
	ap_uint<8> a0_arlen;
	ap_uint<8> a0_awlen;
	ap_uint<6> a0_rid;
	ap_uint<6> a0_arid;
	ap_uint<6> a0_bid;
	ap_uint<6> a0_awid;
	ap_uint<32> a0_araddr;
	ap_uint<32> a0_awaddr;

	ap_uint<3> a1_ext_event;
	ap_uint<1> a1_wr_addr_latch;
	ap_uint<1> a1_first_wr;
	ap_uint<1> a1_last_wr;
	ap_uint<1> a1_response;
	ap_uint<1> a1_rd_addr_latch;
	ap_uint<1> a1_first_rd;
	ap_uint<1> a1_last_rd;
	ap_uint<8> a1_arlen;
	ap_uint<8> a1_awlen;
	ap_uint<2> a1_rid;
	ap_uint<2> a1_arid;
	ap_uint<2> a1_bid;
	ap_uint<2> a1_awid;
	ap_uint<32> a1_araddr;
	ap_uint<32> a1_awaddr;

	ap_uint<12> padding;
} in_packet_256_t;*/

// Current APM format
// Bits must be manually packed due to HLS pragma limitations
typedef struct in_packet_t {
	ap_uint<1> logID;
	ap_uint<30> timestamp;
	ap_uint<1> loop;
	// ap_uint<32> SW;
	ap_uint<3> a0_ext_event;
	ap_uint<1> a0_wr_addr_latch;
	ap_uint<1> a0_first_wr;
	ap_uint<1> a0_last_wr;
	ap_uint<1> a0_response;
	ap_uint<1> a0_rd_addr_latch;
	ap_uint<1> a0_first_rd;
	ap_uint<1> a0_last_rd;
	ap_uint<8> a0_arlen;
	ap_uint<8> a0_awlen;
	ap_uint<16> a0_rid;
	ap_uint<16> a0_arid;
	ap_uint<16> a0_bid;
	ap_uint<16> a0_awid;
	ap_uint<40> a0_araddr;
	ap_uint<40> a0_awaddr;

	ap_uint<3> a1_ext_event;
	ap_uint<1> a1_wr_addr_latch;
	ap_uint<1> a1_first_wr;
	ap_uint<1> a1_last_wr;
	ap_uint<1> a1_response;
	ap_uint<1> a1_rd_addr_latch;
	ap_uint<1> a1_first_rd;
	ap_uint<1> a1_last_rd;
	ap_uint<8> a1_arlen;
	ap_uint<8> a1_awlen;
	ap_uint<3> a1_rid;
	ap_uint<3> a1_arid;
	ap_uint<3> a1_bid;
	ap_uint<3> a1_awid;
	ap_uint<40> a1_araddr;
	ap_uint<40> a1_awaddr;

	// ap_uint<4> padding;

	in_packet_t() {}

	in_packet_t(const ap_uint<320> &i) :
		logID(i(0,0)),
		timestamp(i(30,1)),
		loop(i(31,31)),
		a0_ext_event(i(34,32)),
		a0_wr_addr_latch(i(35,35)),
		a0_first_wr(i(36,36)),
		a0_last_wr(i(37,37)),
		a0_response(i(38,38)),
		a0_rd_addr_latch(i(39,39)),
		a0_first_rd(i(40,40)),
		a0_last_rd(i(41,41)),
		a0_arlen(i(49,42)),
		a0_awlen(i(57,50)),
		a0_rid(i(73,58)),
		a0_arid(i(89,74)),
		a0_bid(i(105,90)),
		a0_awid(i(121,106)),
		a0_araddr(i(161,122)),
		a0_awaddr(i(201,162)),

		a1_ext_event(i(204,202)),
		a1_wr_addr_latch(i(205,205)),
		a1_first_wr(i(206,206)),
		a1_last_wr(i(207,207)),
		a1_response(i(208,208)),
		a1_rd_addr_latch(i(209,209)),
		a1_first_rd(i(210,210)),
		a1_last_rd(i(211,211)),
		a1_arlen(i(219,212)),
		a1_awlen(i(227,220)),
		a1_rid(i(230,228)),
		a1_arid(i(233,231)),
		a1_bid(i(236,234)),
		a1_awid(i(239,237)),
		a1_araddr(i(279,240)),
		a1_awaddr(i(319,280))

		// padding(i(327,324))
	{}

	operator ap_uint<320>() {
		return (/*padding,*/ a1_awaddr, a1_araddr, a1_awid, a1_bid, a1_arid,
				a1_rid, a1_awlen, a1_arlen, a1_last_rd, a1_first_rd,
				a1_rd_addr_latch, a1_response, a1_last_wr, a1_first_wr,
				a1_wr_addr_latch, a1_ext_event, a0_awaddr, a0_araddr,
				a0_awid, a0_bid, a0_arid, a0_rid, a0_awlen, a0_arlen,
				a0_last_rd, a0_first_rd, a0_rd_addr_latch, a0_response,
				a0_last_wr, a0_first_wr, a0_wr_addr_latch, a0_ext_event,
				loop, timestamp, logID);
	}
} in_packet_t;

// 128-bit event output format
// Bits must be manually packed due to HLS pragma limitations
typedef struct out_packet_t {
	ap_uint<1> logID;
	ap_uint<30> timestamp;
	ap_uint<1> loop;
	ap_uint<1> slot;
	ap_uint<1> write;

	ap_uint<3> ext_event;
	ap_uint<1> addr_latch;
	ap_uint<1> first;
	ap_uint<1> last;
	ap_uint<1> response;
	ap_uint<8> a_len;
	ap_uint<16> _id;
	ap_uint<16> a_id;
	ap_uint<40> a_addr;

	ap_uint<7> padding;

	out_packet_t() {}

	out_packet_t(const ap_uint<128> &i) :
		logID(i(0,0)),
		timestamp(i(30,1)),
		loop(i(31,31)),
		slot(i(32,32)),
		write(i(33,33)),
		ext_event(i(36,34)),
		addr_latch(i(37,37)),
		first(i(38,38)),
		last(i(39,39)),
		response(i(40,40)),
		a_len(i(48,41)),
		_id(i(64,49)),
		a_id(i(80,65)),
		a_addr(i(120,81)),
		padding(i(127,121))
	{}

	operator ap_uint<128>() {
		return (padding, a_addr, a_id, _id, a_len, response, last, first,
				addr_latch, ext_event, write, slot, loop, timestamp, logID);
	}
} out_packet_t;

typedef ap_uint<320> in_t;
typedef ap_uint<128> out_t;
typedef ap_uint<516> pack_t;

// Package of 4 128-bit events
// Bits must be manually packed due to HLS pragma limitations
typedef struct pack_packet_t {
	out_t data0, data1, data2, data3;
	bool valid0, valid1, valid2, valid3;

	pack_packet_t() :
		valid0(false),
		valid1(false),
		valid2(false),
		valid3(false)
	{}

	pack_packet_t(const ap_uint<516> &i) :
		data0(i(127,0)),
		data1(i(255,128)),
		data2(i(383,256)),
		data3(i(511,384)),
		valid0(i(512,512)),
		valid1(i(513,513)),
		valid2(i(514,514)),
		valid3(i(515,515))
	{}

	operator ap_uint<516>() {
		return ((ap_uint<1>)valid3, (ap_uint<1>)valid2, (ap_uint<1>)valid1,
				(ap_uint<1>)valid0, data3, data2, data1, data0);
	}
} pack_packet_t;

typedef hls::stream<in_t> in_stream_t;
typedef hls::stream<out_t> out_stream_t;
typedef hls::stream<pack_t> pack_stream_t;

void compress(in_stream_t &in, out_stream_t &out);

#endif // COMPRESS_H
