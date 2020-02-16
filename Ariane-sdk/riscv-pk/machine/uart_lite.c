// See LICENSE for license details.

#include <string.h>
#include "uart_lite.h"
#include "fdt.h"

volatile uint32_t* uart_lite = 0;

void uart_lite_putchar(uint8_t ch)
{
  while (uart_lite[UART_LITE_STAT_REG] & (1 << UART_LITE_TX_FULL));
  uart_lite[UART_LITE_REG_TXFIFO] = ch;
}

int uart_lite_getchar()
{
  if (uart_lite[UART_LITE_STAT_REG] & (1 << UART_LITE_RX_VALID))
    return uart_lite[UART_LITE_REG_RXFIFO];
  return -1;
}

struct uart_lite_scan
{
  int compat;
  uint64_t reg;
};

static void uart_lite_open(const struct fdt_scan_node *node, void *extra)
{
  struct uart_lite_scan *scan = (struct uart_lite_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void uart_lite_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct uart_lite_scan *scan = (struct uart_lite_scan *)extra;
  if (!strcmp(prop->name, "compatible") && !strcmp((const char*)prop->value, "xlnx,axi-uartlite-1.02.a")) {
    scan->compat = 1;
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void uart_lite_done(const struct fdt_scan_node *node, void *extra)
{
  struct uart_lite_scan *scan = (struct uart_lite_scan *)extra;
  if (!scan->compat || !scan->reg || uart_lite) return;

  uart_lite = (void*)(uintptr_t)scan->reg;
  // https://www.xilinx.com/support/documentation/ip_documentation/axi_uartlite/v2_0/pg142-axi-uartlite.pdf
  // clear TX and RX FIFOs
  uart_lite[UART_LITE_CTRL_REG] = 0x3;
}

void query_uart_lite(uintptr_t fdt)
{
  struct fdt_cb cb;
  struct uart_lite_scan scan;

  memset(&cb, 0, sizeof(cb));
  cb.open = uart_lite_open;
  cb.prop = uart_lite_prop;
  cb.done = uart_lite_done;
  cb.extra = &scan;

  fdt_scan(fdt, &cb);
}
