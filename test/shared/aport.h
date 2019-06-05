/*
 * aport.h
 *
 *  Created on: April 4, 2017
 *      Author: lloyd23
 */

#ifndef APORT_H_
#define APORT_H_

#include <stdint.h>
#include "stream.h"

#define ARM0_PN 0 /* ARM 0 port number */
#define MCU0_PN 1 /* MCU 0 port number */
#define LSU0_PN 2 /* LSU 0 port number */
#define LSU1_PN 3 /* LSU 1 port number */
#define HSU0_PN 4 /* HSU 0 port number */
#define LSU2_PN 5 /* LSU 2 port number */
#define PRU0_PN 6 /* PRU 0 port number */
#define getID(pn) ((pn)<<1)

#define AP_HEAD(go,wr,sel,len,tid,tdest) \
	((go) << 23 | (wr) << 22 | (sel) << 19 | (len) << 16 | (tid) << 8 | (tdest))

#define HSU_CMD(seldi,seldo,seed,tdest,tid,hlen,klen) \
	((seldi) << 29 | (seldo) << 28 | (seed) << 24 | (tdest) << 20 | (tid) << 16 | (hlen) << 8 | (klen))

#define LSU_CMD(reqs,cmd) \
	((reqs) << 7 | (cmd))

#define READ_CH 0
#define WRITE_CH 1

enum {
	LSU_nop,
	LSU_move,
	LSU_smove,
	LSU_index,
	LSU_index2,
	LSU_flush = 7,
};

typedef uint32_t flit_t;

#include <stdio.h>
inline flit_t addr_cast(const void *addr)
{
	// printf("addr:%p\n", addr);
#ifdef __cplusplus
	return static_cast<flit_t>(reinterpret_cast<uintptr_t>(addr));
#else
	return ((uintptr_t)addr);
#endif
}
// Address translation: takes low bits, limited to 4G
#define ATRAN(addr) addr_cast(addr)

extern stream_t *gport;

#ifdef __cplusplus
extern "C" {
#endif

extern void aport_set(stream_t *port);
extern flit_t aport_read(unsigned fwd_id, unsigned ret_id, unsigned sel);
extern void aport_write(unsigned fwd_id, unsigned ret_id, unsigned go, unsigned sel, flit_t val);
extern void aport_nread(unsigned fwd_id, unsigned ret_id, unsigned sel, flit_t *val, unsigned n);
extern void aport_nwrite(unsigned fwd_id, unsigned ret_id, unsigned go, unsigned sel, flit_t *val, unsigned n);

#ifdef __cplusplus
}
#endif

#endif /* APORT_H_ */

//      aport header
//       31 bits  0
//     |------------|
//   0 | header:24  | tuser:(go:1 write:1 select:3 length:3) tid:8 tdest:8
//     |------------|

//      hash unit
//      register map
// reg   31 bits  0
//     |------------|
//   0 | status:32  |
//   1 | tlen_lo:32 | currently used as a mask for hash instead of mod
//   2 | tlen_hi:32 |
//   3 | command:30 | seldi:1 seldo:1 seed:4 tdest:4 tid:4 hlen:8 klen:8
//   4 | data_lo:32 |
//   5 | data_hi:32 |
//   6 | hash_lo:32 |
//   7 | hash_hi:32 |
//     |------------|

//      load-store unit
//      register map
// reg   31  bits   0
//     |--------------|
//   0 | status:32    | zero:24 okay:1 slverr:1 decerr:1 interr:1 treqstat:1 tdest:3
//   1 | command:8    | tdest:8 tid:8 reqstat:1 ignore:4 command:3
//   2 | address:32   |
//   3 | size:30      |
//   4 | inc/index:30 |
//   5 | rep/trans:30 |
//   6 | ignore:32    |
//   7 | ignore:32    |
//     |--------------|

//      probe unit
//      register map
// reg   31 bits  0
//     |------------|
//   0 | status:32  |
//   1 | plen:10    | minus 1
//   2 | ignore:32  |
//   3 | ignore:32  |
//   4 | ignore:32  |
//   5 | ignore:32  |
//   6 | ignore:32  |
//   7 | ignore:32  |
//     |------------|

