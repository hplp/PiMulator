/*
 * alloc.h
 *
 *  Created on: Sep 16, 2014
 *      Author: lloyd23
 */

#ifndef ALLOC_H_
#define ALLOC_H_

//------------------ Allocation ------------------//

/* Since cache management is done explicitly, allocations must be */
/* aligned to the cache line size which is 32 bytes for the ARM A9 */
/* and 64 bytes for the x86 and AArch64. */

#if !defined(ALIGN_SZ)
#if defined(__aarch64__)
// #define ALIGN_SZ 64
#define ALIGN_SZ 128 // match HMC MAX_BLOCK_SIZE
#else
#define ALIGN_SZ 32
#endif
#endif
#define CEIL(n,s) ((((n)+((s)-1)) / (s)) * (s))
#define FLOOR(n,s) (((n) / (s)) * (s))

/* NOTE:
   use: void *aligned_alloc(size_t alignment, size_t size); (since C++11)
   when available instead of memalign(). Make sure "size" is also a multiple
   of the alignment.
*/
#ifdef __cplusplus

#if defined(SYSTEMC) && defined(__LP64__)
#define NALLOC(t,n) (t*)sbrk(CEIL((n)*sizeof(t),ALIGN_SZ))
#define NFREE(p)

#elif defined(USE_ACC)
// FIXME: NEWA doesn't construct, only works for simple types
// TODO: make allocator for accelerator
#include <malloc.h> // memalign, free
#define ALLOCATOR(t)
#define NEWA(t,n) (t*)memalign(ALIGN_SZ,CEIL((n)*sizeof(t),ALIGN_SZ))
#define DELETEA(p) free(p)
#define NALLOC(t,n) (t*)memalign(ALIGN_SZ,CEIL((n)*sizeof(t),ALIGN_SZ))
#define NFREE(p) free(p)

#else
#include <memory> // std::allocator
#include <cstdlib> // std::malloc, std::free
#define ALLOCATOR(t) std::allocator<t>
#define NEWA(t,n) new t [n]
#define DELETEA(p) delete[] p
#define NALLOC(t,n) (t*)std::malloc((n)*sizeof(t))
#define NFREE(p) std::free(p)
#endif

#else // __cplusplus

#if defined(USE_ACC)
#include <malloc.h> // memalign, free
#define NALLOC(t,n) (t*)memalign(ALIGN_SZ,CEIL((n)*sizeof(t),ALIGN_SZ))
#define NFREE(p) free(p)

#else
#include <stdlib.h> // malloc, free
#define NALLOC(t,n) (t*)malloc((n)*sizeof(t))
#define NFREE(p) free(p)
#endif

#endif // __cplusplus

#if defined(USE_SP)
/* This feature is currently only supported on the emulator */
/* ARMv7-A only: Scratch Pad (SP) memory must not have L2 cache enabled. */
/* This means the ARM page table attribute must be outer non-cacheable. */
#include <stdint.h> // uintptr_t
extern unsigned char _heap_start[];

#if defined(USE_OCM)
/* SRAM */
//#define SP_BEG (((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL)
//#define SP_END ((((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL) + 0x030000)
//#define SP_SIZE 0x030000
/* DRAM in SRAM address space, ADDR < 0x00100000 */
#define SP_BEG ((((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL) + 0x080000)
#define SP_END ((((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL) + 0x100000)
#define SP_SIZE 0x080000
#else /* USE_OCM */
/* DRAM in DRAM address space, ADDR >= 0x00100000 */
#define SP_BEG ((((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL) + 0x100000)
#define SP_END ((((uintptr_t)&_heap_start) & ~(uintptr_t)0x3FFFFFFFUL) + 0x200000)
#define SP_SIZE 0x100000
#endif /* USE_OCM */

inline void *spalloc(size_t nbytes)
{
	static unsigned char *top = (unsigned char *)SP_BEG;
	unsigned char *ptr = top;

	if ((uintptr_t)ptr + nbytes > SP_END) return NULL;
	top += CEIL(nbytes, ALIGN_SZ);
	return ptr;
}

inline void spfree(void *aptr)
{
}

#define SP_NALLOC(t,n) (t*)spalloc((n)*sizeof(t))
#define SP_NFREE(p) spfree(p)

#else /* USE_SP */
#define SP_NALLOC(t,n) NALLOC(t,n)
#define SP_NFREE(p) NFREE(p)
#endif /* USE_SP */

#if defined(ZYNQ)
#ifdef __cplusplus
#include <cstdio> // printf
#include <cstdint> // uintXX_t
extern "C" {void *_sbrk(intptr_t increment); void *sbrk(intptr_t increment);}
#else
#include <stdio.h> // printf
#include <stdint.h> // uintXX_t
extern void *_sbrk(intptr_t increment); extern void *sbrk(intptr_t increment);
#endif
extern unsigned char _heap_start[];
extern unsigned char _heap_end[];
inline void show_heap(void)
{
	unsigned char *_ptr = (unsigned char *)_sbrk(0);
	unsigned char *ptr = (unsigned char *)sbrk(0);
	printf("heap start:%p top:%p end:%p\ntotal:%tu used:%tu\n",
	_heap_start, _ptr, _heap_end, _heap_end - _heap_start, _ptr - _heap_start);
	if (ptr != _heap_start) {
		printf(" -- warning: sbrk has been called!\n");
		printf("heap start:%p top:%p end:%p\ntotal:%tu used:%tu\n",
		_heap_start, ptr, _heap_end, _heap_end - _heap_start, ptr - _heap_start);
	}
}
#define SHOW_HEAP show_heap();
#else /* ZYNQ */
#define SHOW_HEAP
#endif /* ZYNQ */

#if !defined(__microblaze__)
#include <stdio.h> /* fprintf */
#endif /* __microblaze__ */

#include <stdlib.h> /* exit */

inline void chk_alloc(const void *aptr, size_t nbytes, const char *str)
{
	if (aptr == NULL) {
#if !defined(__microblaze__)
		fprintf(stderr, " -- error: %s\n", str);
		fprintf(stderr, " -- need:%u bytes\n", (unsigned)nbytes);
#endif
		SHOW_HEAP
		exit(EXIT_FAILURE);
	}
	// else fprintf(stderr, "chk_alloc: %p %lu: %s\n", aptr, (unsigned long)nbytes, str);
}

#endif /* ALLOC_H_ */
