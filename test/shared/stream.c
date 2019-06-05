/*
 * stream.c
 *
 *  Created on: Jan 13, 2014
 *      Author: lloyd23
 */

#include "stream.h"

#if defined(__microblaze__)

#include "xstatus.h"

int stream_init(stream_t *port, unsigned id)
{
	return XST_SUCCESS;
}

int stream_send(stream_t *port, void *buf, size_t size, unsigned flags)
{
	u32 *wptr = (u32*)buf;
	unsigned words;

	words = size/sizeof(u32);
	while (words-- > 1) {
		putfslx(*wptr++, 0, FSL_DEFAULT);
	}
	if (flags & F_ENDP) putfslx(*wptr, 0, FSL_CONTROL);
	else putfslx(*wptr, 0, FSL_DEFAULT);

	return XST_SUCCESS;
}

int stream_recv(stream_t *port, void *buf, size_t size, unsigned flags)
{
	u32 *wptr = (u32*)buf;
	unsigned words;

	words = size/sizeof(u32);
	while (words-- > 1) {
		getfslx(*wptr++, 0, FSL_DEFAULT);
	}
	if (flags & F_ENDP) getfslx(*wptr, 0, FSL_CONTROL);
	else getfslx(*wptr, 0, FSL_DEFAULT);

	return XST_SUCCESS;
}

#else /* ARM */

#define NDEBUG 1
#include <assert.h>
#include "xstatus.h"

#define min(a,b) (((a) < (b)) ? (a) : (b))


int stream_init(stream_t *port, unsigned id)
{
	XLlFifo *InstancePtr = &port->Instance;
	XLlFifo_Config *Config;
	int Status;

	/* Initialize the Device Configuration Interface driver */
	Config = XLlFfio_LookupConfig(id);
	if (Config == NULL) {
		// xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	/*
	 * This is where the virtual address would be used, this example
	 * uses physical address.
	 */
	Status = XLlFifo_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		// xil_printf("Initialization failed\n\r");
		return Status;
	}

	/* Check for the Reset value */
	Status = XLlFifo_Status(InstancePtr);
	XLlFifo_IntClear(InstancePtr, 0xffffffff);
	XLlFifo_IntDisable(InstancePtr, 0xffffffff);
	Status = XLlFifo_Status(InstancePtr);
	if (Status != XST_SUCCESS) {
		// xil_printf("\n ERROR : Reset value of ISR0 : 0x%x\tExpected : 0x0\n\r", XLlFifo_Status(InstancePtr));
		return XST_FAILURE;
	}

	port->TransmitLength = 0;
	port->ReceiveLength = 0;

	return Status;
}

//#include <stdio.h>
int stream_send(stream_t *port, void *buf, size_t size, unsigned flags)
{
	XLlFifo *InstancePtr = &port->Instance;
	unsigned Words;

	assert((size & (sizeof(u32)-1)) == 0); /* must be a multiple of the word size */

//printf("send: Status:%08lx iTxVacancy:%08lx\n", XLlFifo_Status(InstancePtr), XLlFifo_iTxVacancy(InstancePtr));
	if (flags & F_BEGP) {
		port->TransmitLength = 0;
	}

	Words = size/sizeof(u32);
	while (Words > XLlFifo_iTxVacancy(InstancePtr)) {
		if (flags & F_NOWA) return XST_FAILURE;
	}
	XLlFifo_iWrite_Aligned(InstancePtr, buf, Words); /* can handle 0 Words */
	port->TransmitLength += Words*sizeof(u32);

	if (flags & F_ENDP) {
		XLlFifo_iTxSetLen(InstancePtr, port->TransmitLength);
	}
//printf("done: Status:%08lx iTxVacancy:%08lx\n", XLlFifo_Status(InstancePtr), XLlFifo_iTxVacancy(InstancePtr));

	return XST_SUCCESS;
}

int stream_recv(stream_t *port, void *buf, size_t size, unsigned flags)
{
	XLlFifo *InstancePtr = &port->Instance;
	unsigned Words;

	assert((size & (sizeof(u32)-1)) == 0); /* must be a multiple of the word size */
//printf("recv: Status:%08lx iRxOccupancy:%08lx\n", XLlFifo_Status(InstancePtr), XLlFifo_iRxOccupancy(InstancePtr));
	/* iRxOccupancy must be called before iRxGetLen */
	/* iRxOccupancy returns bit 31 set if partial packet received */
	/* iRxGetLen zeros out iRxOccupancy if no more packets are available */
	/* iRxGetLen returns bit 31 set if underrun */
	if (flags & F_BEGP) {
		/* wait for packet, signaled by AXI Stream TLAST */
		register u32 tmp;
		while ((tmp = XLlFifo_iRxOccupancy(InstancePtr)) == 0 || tmp & 0x80000000) {
			if (flags & F_NOWA) return XST_FAILURE;
		}
		/* only call when whole packet received */
		port->ReceiveLength = XLlFifo_iRxGetLen(InstancePtr);
	}

	Words = size/sizeof(u32);
	XLlFifo_iRead_Aligned(InstancePtr, buf, Words); /* can handle 0 Words */
	port->ReceiveLength -= Words*sizeof(u32);

	if (flags & F_ENDP) {
		while (port->ReceiveLength) {
			XLlFifo_RxGetWord(InstancePtr); /* unload FIFO */
			port->ReceiveLength -= min(port->ReceiveLength,sizeof(u32));
		}
	}
//printf("done: Status:%08lx iRxOccupancy:%08lx\n", XLlFifo_Status(InstancePtr), XLlFifo_iRxOccupancy(InstancePtr));

	return XST_SUCCESS;
}

#endif /* ARM */
