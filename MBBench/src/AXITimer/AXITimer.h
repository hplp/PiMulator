#ifndef SRC_AXITIMER_H_
#define SRC_AXITIMER_H_

#include "xil_types.h"
#include "xtmrctr.h"
#include "xparameters.h"

class AXITimer {
public:
	AXITimer();
	virtual ~AXITimer();
	unsigned int getElapsedTicks();
	double getElapsedTimerInSeconds();
	unsigned int startTimer();
	unsigned int stopTimer();
	double getClockPeriod();
	double getTimerClockFreq();
private:
	XTmrCtr m_AxiTimer;
	unsigned int m_tickCounter1;
	unsigned int m_tickCounter2;
	double m_clockPeriodSeconds;
	double m_timerClockFreq;
};

#endif /* SRC_AXITIMER_H_ */
