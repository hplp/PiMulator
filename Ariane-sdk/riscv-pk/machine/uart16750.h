// See LICENSE for license details.

#ifndef _RISCV_16750_H
#define _RISCV_16750_H

#include <stdint.h>

extern volatile uint32_t* uart16750;

void uart16750_putchar(uint8_t ch);
int uart16750_getchar();
void query_uart16750(uintptr_t dtb);

#endif
