/*
 * aport.c
 *
 *  Created on: April 4, 2017
 *      Author: lloyd23
 */

#include "aport.h"

stream_t *gport;


void aport_set(stream_t *port)
{
	gport = port;
}

flit_t aport_read(unsigned fwd_id, unsigned ret_id, unsigned sel)
{
	flit_t command[2];
	flit_t response[2];

	/* go=0, write=0, select=sel, length=1, tid=ret_id, tdest=fwd_id */
	command[0] = sel << 19 | 1 << 16 | ret_id << 8 | fwd_id;
	command[1] = 0;
	stream_send(gport, command, sizeof(command), F_BEGP|F_ENDP);
	stream_recv(gport, response, sizeof(response), F_BEGP|F_ENDP);
	return response[1];
}

void aport_write(unsigned fwd_id, unsigned ret_id, unsigned go, unsigned sel, flit_t val)
{
	flit_t command[2];

	/* go=go, write=1, select=sel, length=1, tid=ret_id, tdest=fwd_id */
	command[0] = go << 23 | 1 << 22 | sel << 19 | 1 << 16 | ret_id << 8 | fwd_id;
	command[1] = val;
	stream_send(gport, command, sizeof(command), F_BEGP|F_ENDP);
}

/* The first location of value is reserved for the header. When a new host interface
 * is implemented, then the header can be implemented as a separate variable.
 */

void aport_nread(unsigned fwd_id, unsigned ret_id, unsigned sel, flit_t *val, unsigned n)
{
	/* go=0, write=0, select=sel, length=n, tid=ret_id, tdest=fwd_id */
	val[0] = sel << 19 | n << 16 | ret_id << 8 | fwd_id;
	stream_send(gport, val, 2*sizeof(unsigned), F_BEGP|F_ENDP);
	stream_recv(gport, val, (n+1)*sizeof(unsigned), F_BEGP|F_ENDP);
}

void aport_nwrite(unsigned fwd_id, unsigned ret_id, unsigned go, unsigned sel, flit_t *val, unsigned n)
{
	/* go=go, write=1, select=sel, length=n, tid=ret_id, tdest=fwd_id */
	val[0] = go << 23 | 1 << 22 | sel << 19 | n << 16 | ret_id << 8 | fwd_id;
	stream_send(gport, val, (n+1)*sizeof(unsigned), F_BEGP|F_ENDP);
}
