/*
 * clocks.h
 *
 *  Created on: Dec 10, 2014
 *      Author: lloyd23
 */

#ifndef CLOCKS_H_
#define CLOCKS_H_

#include "config.h"

/* expects ticks.h to be included elsewhere */
#define tesec(f,s) ((_us long long)tdiff(f,s)/(double)TICKS_ESEC)
#define tvesec(v) ((_us long long)(v)/(double)TICKS_ESEC)

#if defined(CLOCKS)

#if !defined(T_W)
#define T_W 106 // Average DRAM Write, off-chip
#endif
#if !defined(T_R)
#define T_R  85 // Average DRAM Read, off-chip
#endif
#if !defined(T_TRANS)
#define T_TRANS 24 // 24 32 40
#endif
#define T_SRAM_W 12
#define T_SRAM_R 12
#define T_DRAM_W 45 // (T_W - T_TRANS) // 45
#define T_DRAM_R 45 // (T_R - T_TRANS) // 45
#define T_QUEUE_W (T_W - T_DRAM_W - T_TRANS) // 00 20 40
#define T_QUEUE_R (T_R - T_DRAM_R - T_TRANS) // 00 20 40

#if defined(ZYNQ)

#if ZYNQ == _Z7_
/* Zynq-7000 Device */
#define TICKS_ESEC (2571428545UL/2)
#elif ZYNQ == _ZU_
/* Zynq UltraScale+ Device */
#define TICKS_ESEC (1999980000UL) // 99999000*20
#endif

#else /* not ZYNQ */

#define TICKS_ESEC (TICKS_SEC*20)

#endif /* ZYNQ */

#define CLOCKS_EMULATE clocks_emulate();
#define CLOCKS_NORMAL  clocks_normal();

#ifdef __cplusplus
extern "C" {
#endif

void clocks_emulate(void);
void clocks_normal(void);

#ifdef __cplusplus
}
#endif

#else /* not CLOCKS */

#define CLOCKS_EMULATE
#define CLOCKS_NORMAL
#define TICKS_ESEC TICKS_SEC

#endif /* CLOCKS */

#endif /* CLOCKS_H_ */
