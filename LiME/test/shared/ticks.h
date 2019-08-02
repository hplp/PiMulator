/*
$Id: ticks.h,v 1.3 2010/11/23 22:42:02 scott Exp $

Description: Macros for timing
Usage: Define the timer call desired (e.g. #define FTIME, TIMEOFDAY, GETTIME)
before including "ticks.h"

Example:
#define TIMEOFDAY 1
#include "ticks.h"

void benchmark(void)
{
	tick_t start, finish;

	tget(start);
	timed_section();
	tget(finish);
	printf("time in seconds:%f\n", tsec(finish, start));
}

$Log: ticks.h,v $
Revision 1.3  2010/11/23 22:42:02  scott
Add RDTSC (Read Time-Stamp Counter) option that uses the x86 instruction.
By default, use signed long for faster int to float conversion.
Change TICKS_SEC type to unsigned long (nUL).

Revision 1.2  2010/05/12 23:25:24  scott
Update comments for version control

*/

#ifndef _TICKS_H
#define _TICKS_H

/*
Casting the ticks to a signed value allows a more efficient
conversion to a float on x86 CPUs, but it limits the count to one
less high-order bit. Uncomment "unsigned" to use a full tick count.
*/
#define _us /*unsigned*/

#if defined(FTIME)

/* deprecated */
#include <sys/timeb.h>
typedef struct timeb tick_t;
#define TICKS_SEC 1000U
#define tget(t) ftime(&(t))
#define tval(t) ((unsigned long long)t.time*TICKS_SEC+t.millitm)

#elif defined(TIMEOFDAY)

#include <sys/time.h>
typedef struct timeval tick_t;
#define TICKS_SEC 1000000UL
#define tget(t) gettimeofday(&(t),NULL)
#define tval(t) ((unsigned long long)t.tv_sec*TICKS_SEC+t.tv_usec)

#elif defined(GETTIME)

/* may need to link with lib -lrt */
#include <time.h>
typedef struct timespec tick_t;
#define TICKS_SEC 1000000000UL
#ifndef CLOCK_TYPE
#error CLOCK_TYPE must be defined as one of: \
CLOCK_REALTIME, CLOCK_MONOTONIC, CLOCK_PROCESS_CPUTIME_ID, CLOCK_THREAD_CPUTIME_ID
#endif
#define tget(t) clock_gettime(CLOCK_TYPE,&(t))
#define tval(t) ((unsigned long long)t.tv_sec*TICKS_SEC+t.tv_nsec)

#elif defined(RDTSC)

typedef union {
	unsigned long long ui64;
	struct {unsigned int lo, hi;} ui32;
} tick_t;
#ifndef TICKS_SEC
#error TICKS_SEC must be defined to match the CPU clock frequency
#endif
#define tget(t) __asm__ __volatile__ ("lfence\n\trdtsc" : "=a" ((t).ui32.lo), "=d"((t).ui32.hi))
#define tval(t) ((t).ui64)

#elif defined(XILTIME)

#include <xtime_l.h>
typedef XTime tick_t;
#ifndef TICKS_SEC
#define TICKS_SEC COUNTS_PER_SECOND
#endif
#define tget(t) XTime_GetTime(&(t))
#define tval(t) (t)

#elif defined(M5RPNS)

/* must link with m5op_<arch>.o */
#include <m5op.h>
typedef uint64_t tick_t;
#define TICKS_SEC 1000000000UL
#define tget(t) t = rpns()
#define tval(t) (t)

#elif defined(SYSTEMC)

#include <systemc.h>
typedef uint64 tick_t;
#define TICKS_SEC 1000000000000ULL
#define tget(t) t = sc_time_stamp().value()
#define tval(t) (t)

#else

#include <time.h>
typedef clock_t tick_t;
#define TICKS_SEC CLOCKS_PER_SEC
#define tget(t) t = clock()
#define tval(t) (t)

#endif

#define tinc(a,b) ((a) += (b))
#define tdec(a,b) ((a) -= (b))
#define tdiff(f,s) (tval(f)-tval(s))
#define tsec(f,s) ((_us long long)tdiff(f,s)/(double)TICKS_SEC)
#define tvsec(v) ((_us long long)(v)/(double)TICKS_SEC)

#endif /* _TICKS_H */
