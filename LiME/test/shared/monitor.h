/*
 * monitor.h
 *
 *  Created on: Sep 16, 2014
 *      Author: lloyd23
 */

#ifndef MONITOR_H_
#define MONITOR_H_

#include "config.h"

//------------------ Initialization ------------------//

#if defined(STATS) || defined(TRACE)

#define MONITOR_INIT   monitor_init();
#define MONITOR_FINISH monitor_finish();
#define _MONITOR_INIT

#ifdef __cplusplus
extern "C" {
#endif

void monitor_init(void);
void monitor_finish(void);

#ifdef __cplusplus
}
#endif

#else // not (STATS || TRACE)

#define MONITOR_INIT
#define MONITOR_FINISH

#endif // STATS || TRACE

//------------------ Statistics ------------------//

// TODO: Want to push, pop, or peek (get) stats for a section without printing
// Wait to print until after benchmark section since printing can modify the stats
// Consider making stat stack (class) external to memory stack, use STL for stack
// Where to locate stat stack? make global, put in DRE class, or put in namespace host?
// Make stat methods in memory stack closer to APM functionality (get counters, clear)
// Incorporate APM into stats macros
// Macros: STATS_PUSH, STATS_POP, STATS_PEEK, STATS_PRINT
// Example Usage:
//   ...setup...
//   STATS_PUSH
//   ...benchmark...
//   STATS_PUSH
//   ...other...
//   STATS_POP   # toss ...other...
//   STATS_PRINT # print ...benchmark... section

#if defined(STATS)

#define STATS_START stats_start();
#define STATS_STOP  stats_stop();
#define STATS_PRINT stats_print();

#ifdef __cplusplus
extern "C" {
#endif

void stats_start(void);
void stats_stop(void);
void stats_print(void);

#ifdef __cplusplus
}
#endif

#else // not STATS

#define STATS_START
#define STATS_STOP
#define STATS_PRINT

#endif // STATS

//------------------ Trace ------------------//

#if defined(TRACE)

#define TRACE_START    trace_start();
#define TRACE_STOP     trace_stop();
#define TRACE_CAP      trace_capture();
#define TRACE_EVENT(e) trace_event(e);

#ifdef __cplusplus
extern "C" {
#endif

void trace_start(void);
void trace_stop(void);
void trace_capture(void);
void trace_event(int e);

#ifdef __cplusplus
}
#endif

#else // not TRACE

#define TRACE_START
#define TRACE_STOP
#define TRACE_CAP
#define TRACE_EVENT(e)

#endif // TRACE

//------------------ gem5 Work Region ------------------//
// Tie into STATS macro instead of creating yet another one.

#if defined(M5)

#undef STATS_START
#undef STATS_STOP
#undef STATS_PRINT

#include "m5op.h"

#define STATS_START m5_work_begin(0,0);
#define STATS_STOP  m5_work_end(0,0);
#define STATS_PRINT

#endif // M5

#endif /* MONITOR_H_ */
