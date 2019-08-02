/*
 * lsu_cmd.h
 *
 *  Created on: May 1, 2014
 *      Author: lloyd23
 */

#ifndef LSU_CMD_H_
#define LSU_CMD_H_

#include <stddef.h> /* size_t */
#include "aport.h" /* stream_t, gport, getID, port numbers */

extern unsigned gfwd_id;
extern unsigned gret_id;

#ifdef __cplusplus
extern "C" {
#endif

extern void lsu_setport(stream_t *port, unsigned fwd_pn, unsigned ret_pn);
extern void *lsu_memcpy(void *dst, const void *src, size_t n);
extern void *lsu_smemcpy(void *dst, const void *src, size_t block_sz, size_t dst_inc, size_t src_inc, size_t n);

#ifdef __cplusplus
}
#endif

#endif /* LSU_CMD_H_ */
