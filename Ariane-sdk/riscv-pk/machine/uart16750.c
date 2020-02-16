// See LICENSE for license details.

#include <string.h>
#include "uart16750.h"
#include "fdt.h"

volatile uint32_t* uart16750;

#define UART_REG_QUEUE     0
#define UART_REG_LINESTAT  5
#define UART_REG_STATUS_RX 0x01
#define UART_REG_STATUS_TX 0x20
#define UART_REG_DLL       0

void uart16750_putchar(uint8_t ch)
{
  while ((uart16750[UART_REG_LINESTAT] & UART_REG_STATUS_TX) == 0);
  uart16750[UART_REG_QUEUE] = ch;
}

int uart16750_getchar()
{
  if (uart16750[UART_REG_LINESTAT] & UART_REG_STATUS_RX)
    return uart16750[UART_REG_QUEUE];
  return -1;
}

struct uart16750_scan
{
  int compat;
  uint64_t reg;
  uint32_t freq;
  uint32_t baud;
};

static void uart16750_open(const struct fdt_scan_node *node, void *extra)
{
  struct uart16750_scan *scan = (struct uart16750_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void uart16750_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct uart16750_scan *scan = (struct uart16750_scan *)extra;
  if (!strcmp(prop->name, "compatible") && !strcmp((const char*)prop->value, "ns16750")) {
    scan->compat = 1;
  } else if (!strcmp(prop->name, "clock-frequency")) {
    fdt_get_value(prop->value, &scan->freq);
  } else if (!strcmp(prop->name, "current-speed")) {
    fdt_get_value(prop->value, &scan->baud);
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void uart16750_done(const struct fdt_scan_node *node, void *extra)
{
  struct uart16750_scan *scan = (struct uart16750_scan *)extra;
  if (!scan->compat || !scan->reg || uart16750) return;

  uart16750 = (void*)(uintptr_t)scan->reg;

  // calculate divisor
  uint32_t divisor = scan->freq / (scan->baud << 4);

  // http://wiki.osdev.org/Serial_Ports
  uart16750[1] = 0x00;    // Disable all interrupts
  uart16750[3] = 0x80;    // Enable DLAB (set baud rate divisor)
  uart16750[0] = divisor      & 0xFF;    // divisor (lo byte) 
  uart16750[1] = (divisor>>8) & 0xFF;    // divisor (hi byte)
  uart16750[3] = 0x03;    // 8 bits, no parity, one stop bit
  uart16750[2] = 0xC7;    // Enable FIFO, clear them, with 14-byte threshold
}

void query_uart16750(uintptr_t fdt)
{
  struct fdt_cb cb;
  struct uart16750_scan scan;

  // default
  scan.freq = 50000000;
  scan.baud = 115200;

  memset(&cb, 0, sizeof(cb));
  cb.open = uart16750_open;
  cb.prop = uart16750_prop;
  cb.done = uart16750_done;
  cb.extra = &scan;

  fdt_scan(fdt, &cb);
}
