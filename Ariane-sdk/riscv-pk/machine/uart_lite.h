// See LICENSE for license details.

#ifndef _RISCV_UART_LITE_H
#define _RISCV_UART_LITE_H

#include <stdint.h>

extern volatile uint32_t* uart_lite;

#define UART_LITE_REG_RXFIFO	0
#define UART_LITE_REG_TXFIFO    1
#define UART_LITE_STAT_REG   	2
#define UART_LITE_CTRL_REG  	3

#define UART_LITE_TX_FULL	 3
#define UART_LITE_RX_FULL    1
#define UART_LITE_RX_VALID	 0


void uart_lite_putchar(uint8_t ch);
int uart_lite_getchar();
void query_uart_lite(uintptr_t dtb);

#endif
