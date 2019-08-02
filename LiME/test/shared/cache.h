/*
 * cache.h
 *
 *  Created on: Sep 16, 2014
 *      Author: lloyd23
 */

#ifndef CACHE_H_
#define CACHE_H_

//------------------ Cache ------------------//
// cache management on host and accelerator

/* NOTE: if invalidate is used on non-cache aligned and sized allocations, */
/* it can corrupt the heap. */

#if defined(CLIENT)
#define CACHE_BARRIER {dre.cache_flush(); dre.cache_invalidate(); host::cache_flush_invalidate();}
#define CACHE_DISPOSE(p,n) {dre.cache_invalidate(p,n); host::cache_invalidate(p,n);}

#else
#define CACHE_BARRIER {host::cache_flush_invalidate();}
#define CACHE_DISPOSE(p,n) {host::cache_invalidate(p,n);}
#endif

#if defined(USE_STREAM)
/* Not enabled with defined(DIRECT) */
#define CACHE_SEND_ALL(a) {host::cache_flush(); /*a.cache_flush(); a.cache_invalidate();*/}
#define CACHE_RECV_ALL(a) {/*a.cache_flush();*/ host::cache_flush_invalidate();}
#define CACHE_SEND(a,p,n) {host::cache_flush(p,n); /*a.cache_invalidate(p,n);*/}
#define CACHE_RECV(a,p,n) {/*a.cache_flush(p,n);*/ host::cache_invalidate(p,n);}

#else
#define CACHE_SEND_ALL(a)
#define CACHE_RECV_ALL(a)
#define CACHE_SEND(a,p,n)
#define CACHE_RECV(a,p,n)
#endif

#if defined(ZYNQ)
#include "xpseudo_asm.h" // mtcp*, dsb
#include "xil_cache.h" // Xil_D*

#if defined(__aarch64__)
#define Xil_L1DCacheFlush Xil_DCacheFlush
#define Xil_L1DCacheFlushRange Xil_DCacheFlushRange
#define Xil_L1DCacheInvalidateRange Xil_DCacheInvalidateRange
#define dc_CVAC(va) mtcpdc(CVAC,(INTPTR)(va))
#define dc_CIVAC(va) mtcpdc(CIVAC,(INTPTR)(va))
#else // __aarch64__
#include "xil_cache_l.h" // Xil_L1D*
#define dc_CVAC(va) mtcp(XREG_CP15_CLEAN_DC_LINE_MVA_POC,(INTPTR)(va))
#define dc_CIVAC(va) mtcp(XREG_CP15_CLEAN_INVAL_DC_LINE_MVA_POC,(INTPTR)(va))
#endif // __aarch64__

#else // ZYNQ
/* Data Synchronization Barrier */
#define dsb()
/* flush & invalidate entire L1 data cache */
#define Xil_L1DCacheFlush()
/* invalidate range of L1 data cache */
#define Xil_L1DCacheInvalidateRange(addr, size)
/* ARM cache line management */
#define dc_CVAC(va)
#define dc_CIVAC(va)
#endif // ZYNQ

#ifdef __cplusplus
namespace host {

#if defined(ZYNQ)
inline void cache_flush(void) {Xil_DCacheFlush();}
inline void cache_flush(const void *ptr, size_t size) {Xil_DCacheFlushRange((INTPTR)ptr, size);}
inline void cache_flush_invalidate(void) {Xil_DCacheFlush();}
inline void cache_flush_invalidate(const void *ptr, size_t size) {Xil_DCacheFlushRange((INTPTR)ptr, size);}
inline void cache_invalidate(void) {Xil_DCacheInvalidate();}
inline void cache_invalidate(const void *ptr, size_t size) {Xil_DCacheInvalidateRange((INTPTR)ptr, size);}

#else // ZYNQ
inline void cache_flush(void) {}
inline void cache_flush(const void *ptr, size_t size) {}
inline void cache_flush_invalidate(void) {}
inline void cache_flush_invalidate(const void *ptr, size_t size) {}
inline void cache_invalidate(void) {}
inline void cache_invalidate(const void *ptr, size_t size) {}
#endif // ZYNQ

} // namespace host
#endif // __cplusplus

#endif /* CACHE_H_ */
