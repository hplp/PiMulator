#include "AXITimer.h"

AXITimer::AXITimer() {
	XTmrCtr_Initialize(&m_AxiTimer, XPAR_TMRCTR_0_DEVICE_ID);
	m_timerClockFreq = (double) XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ;
	m_clockPeriodSeconds = (double) 1 / m_timerClockFreq;
}

AXITimer::~AXITimer() {
}

unsigned int AXITimer::getElapsedTicks() {
	return m_tickCounter2 - m_tickCounter1;
}

unsigned int AXITimer::startTimer() {
	XTmrCtr_Reset(&m_AxiTimer, 0);
	m_tickCounter1 = XTmrCtr_GetValue(&m_AxiTimer, 0);
	XTmrCtr_Start(&m_AxiTimer, 0);
	return m_tickCounter1;
}

unsigned int AXITimer::stopTimer() {
	XTmrCtr_Stop(&m_AxiTimer, 0);
	m_tickCounter2 = XTmrCtr_GetValue(&m_AxiTimer, 0);
	return m_tickCounter2 - m_tickCounter1;
}

double AXITimer::getElapsedTimerInSeconds() {
	return (double) (m_tickCounter2 - m_tickCounter1) * m_clockPeriodSeconds;
}

double AXITimer::getClockPeriod() {
	return m_clockPeriodSeconds;
}

double AXITimer::getTimerClockFreq() {
	return m_timerClockFreq;
}
