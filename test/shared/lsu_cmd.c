/*
 * lsu_cmd.c
 *
 *  Created on: May 1, 2014
 *      Author: lloyd23
 */

#include "lsu_cmd.h"

typedef struct {
	unsigned int tdest :  8; /* forward route id */
	unsigned int tid   :  8; /* return route id */
	unsigned int tuser : 16; /* command */

//	unsigned int stat  : 32; /* status */
	unsigned int cmd   : 32; /* command */
	unsigned int addr  : 32; /* address */
	unsigned int size  : 32; /* size */
} lsu_move;

typedef struct {
	unsigned int tdest :  8; /* forward route id */
	unsigned int tid   :  8; /* return route id */
	unsigned int tuser : 16; /* command */

//	unsigned int stat  : 32; /* status */
	unsigned int cmd   : 32; /* command */
	unsigned int addr  : 32; /* address */
	unsigned int size  : 32; /* size */
	unsigned int inc   : 32; /* increment */
	unsigned int rep   : 32; /* repetitions */
} lsu_smove;

typedef struct {
	unsigned int tdest :  8; /* forward route id */
	unsigned int tid   :  8; /* return route id */
	unsigned int tuser : 16; /* command */

	unsigned int tag    :  4; /* echos the tag from the command */
	unsigned int interr :  1; /* 1 = internal error */
	unsigned int decerr :  1; /* 1 = address decode error */
	unsigned int slverr :  1; /* 1 = slave asserted error */
	unsigned int okay   :  1; /* 1 = okay response */
	unsigned int        : 24;
} lsu_status;

unsigned gfwd_id;
unsigned gret_id;


void lsu_setport(stream_t *port, unsigned fwd_pn, unsigned ret_pn)
{
	gport = port;
	gfwd_id = fwd_pn<<1;
	gret_id = ret_pn<<1;
}

void *lsu_memcpy(void *dst, const void *src, size_t n)
{
	lsu_move command;
	lsu_status status;

	command.tid = gret_id;
	command.tuser = 0313; /* go=1, write=1, select=1, length=3 */
//	command.stat = 0;
	command.size = n;

	/* send load command */
	command.cmd = LSU_CMD(0,LSU_move); /* reqstat=0, command=move */
	command.tdest = gfwd_id+READ_CH;
	command.addr = ATRAN(src);
	stream_send(gport, &command, sizeof(command), F_BEGP|F_ENDP);

	/* send store command */
	command.cmd = LSU_CMD(1,LSU_move); /* reqstat=1, command=move */
	command.tdest = gfwd_id+WRITE_CH;
	command.addr = ATRAN(dst);
	stream_send(gport, &command, sizeof(command), F_BEGP|F_ENDP);

	/* receive store status */
	stream_recv(gport, &status, sizeof(status), F_BEGP|F_ENDP);

	return dst;
}

void *lsu_smemcpy(void *dst, const void *src, size_t block_sz, size_t dst_inc, size_t src_inc, size_t n)
{
	lsu_smove command;
	lsu_status status;

	command.tid = gret_id;
	command.tuser = 0315; /* go=1, write=1, select=1, length=5 */
//	command.stat = 0;
	command.size = block_sz;
	command.rep = n;

	/* send load command */
	command.cmd = LSU_CMD(0,LSU_smove); /* reqstat=0, command=smove */
	command.tdest = gfwd_id+READ_CH;
	command.addr = ATRAN(src);
	command.inc = src_inc;
	stream_send(gport, &command, sizeof(command), F_BEGP|F_ENDP);

	/* send store command */
	command.cmd = LSU_CMD(1,LSU_smove); /* reqstat=1, command=smove */
	command.tdest = gfwd_id+WRITE_CH;
	command.addr = ATRAN(dst);
	command.inc = dst_inc;
	stream_send(gport, &command, sizeof(command), F_BEGP|F_ENDP);

	/* receive store status */
	stream_recv(gport, &status, sizeof(status), F_BEGP|F_ENDP);

	return dst;
}
