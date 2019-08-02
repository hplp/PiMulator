
#include <errno.h>
#include "sbrk.h"

char *heap_beg;
char *heap_end;
char *heap_ptr;

char *sbrk(int nbytes)
{
  char *base;

  if (!heap_ptr) heap_ptr = heap_beg;

  base = heap_ptr;
  heap_ptr += nbytes;

  if (heap_ptr <= heap_end) return base;

  errno = ENOMEM;
  return((char *)-1);
}
