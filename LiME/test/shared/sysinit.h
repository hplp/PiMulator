/*
 * sysinit.h
 *
 *  Created on: Dec 30, 2017
 *      Author: lloyd23
 */

#ifndef SYSINIT_H_
#define SYSINIT_H_

#include "config.h"
#include "monitor.h"

/* Switching back to making attribute changes in translation_table.S */
#if 0 && defined(ZYNQ) && ZYNQ == _Z7_
#include "xil_mmu.h" // Xil_SetTlbAttributes
// #include "xil_cache.h" // Xil_xCacheEnable
/* 0x15de6: Shareable, Domain:1111, Outer & Inner Cacheable: Write-Back, Write-Allocate */
/* 0x14de6: Shareable, Domain:1111, Inner Cacheable: Write-Back, Write-Allocate */
/* 0x04c06: Non-shareable, Domain:0000, Inner Cacheable: Write-Back, Write-Allocate */
/* 0x04c0e: Non-shareable, Domain:0000, Inner Cacheable: Write-Back, no Write-Allocate */
static inline void mmu_setup(void) {
	char *ptr;
	Xil_SetTlbAttributes((INTPTR)0x40000000, 0x04c06); /* Inner Cacheable */
	Xil_SetTlbAttributes((INTPTR)0x40100000, 0x04c06); /* Inner Cacheable */
	for (ptr = (char*)0x40200000; ptr < (char*)0x7fffffff; ptr += 0x100000)
		Xil_SetTlbAttributes((INTPTR)ptr, 0x15de6); /* Cacheable */
	// printf("mmu_setup\n");
}
#define MMU_SETUP {mmu_setup(); /*Xil_ICacheEnable(); Xil_DCacheEnable();*/}
#define _MMU_SETUP
#else
#define MMU_SETUP
#endif

#if defined(USE_MARGS)
#include <stdlib.h> /* malloc */
#include <string.h> /* strlen, strcpy, strrchr */
#if !defined(MARGS)
#define MARGS ""
// #include "margs.h"
#endif
static inline void get_args(const char *arg0, int *argc, char **argv[]) {
	int i, n;
	char *ptr, *end;
	char *str, **args;
	// static char str[256], *args[32];
	str = (char*)malloc(strlen(MARGS)+1);
	if (str == NULL) return;
	strcpy(str, MARGS);
	end = str+strlen(MARGS);
	for (ptr = str, n = 0; ptr < end; ) {
		while (ptr < end && *ptr <= ' ') *ptr++ = '\0';
		if (*ptr > ' ') n++;
		while (ptr < end && *ptr >  ' ') ptr++;
	}
	args = (char**)malloc(sizeof(char*)*(n+2));
	if (args == NULL) return;
	if ((ptr = strrchr(arg0, '/')) == NULL) ptr = (char*)arg0; else ptr++;
	args[0] = ptr;
	for (ptr = str, i = 1; ptr < end; ) {
		while (ptr < end && *ptr <= ' ') ptr++;
		if (*ptr > ' ') args[i++] = ptr;
		while (ptr < end && *ptr >  ' ') ptr++;
	}
	args[i] = NULL;
	*argc = i;
	*argv = args;
	// #define MARGS (char*)"-ARG1", (char*)"-ARG2"
	// char *args[] = {(char*)arg0, MARGS, 0};
	// *argc = sizeof(args)/sizeof(char *)-1;
	// *argv = (char**)malloc(sizeof(args));
	// memcpy(*argv, args, sizeof(args));
	// {int i; for (i = 0; i < *argc; i++) printf(" %s",(*argv)[i]); printf("\n");}
}
#define GET_ARGS(arg0) {get_args(arg0,&argc,&argv);}
#define _GET_ARGS
#else
#define GET_ARGS(arg0)
#endif

/*
  There appears to be a bug in clean up after return from main (xil-crt0.S).
  After multiple runs of a standalone application, it will hang, give
  irregular results, or not pass self checks. Adding a call to 
  Xil_DCacheDisable() before return from main seems to fix the problem.
  Using atexit(Xil_DCacheDisable) does not work. When using atexit,
  clean up may occur before Xil_DCacheDisable is called.
*/
#if defined(ZYNQ) && ZYNQ == _Z7_
#include "xil_cache.h" // Xil_DCacheDisable
#define FINI_BUG Xil_DCacheDisable();
#define _FINI_BUG
#else
#define FINI_BUG
#endif

#if defined(_MMU_SETUP) || defined(_GET_ARGS) || defined(_MONITOR_INIT) || defined(_FINI_BUG)
#define MAIN \
static int _sub_main(int argc, char *argv[]); \
int main(int argc, char *argv[]) \
{ \
	int ret; \
	MMU_SETUP \
	GET_ARGS(__FILE__) \
	MONITOR_INIT \
	ret = _sub_main(argc, argv); \
	MONITOR_FINISH \
	FINI_BUG \
	return ret; \
} \
static int _sub_main(int argc, char *argv[])
#elif defined(SYSTEMC)
#define MAIN int _sub_main(int argc, char *argv[])
#else
#define MAIN int main(int argc, char *argv[])
#endif

#endif /* SYSINIT_H_ */
