
#ifndef SBRK_H_
#define SBRK_H_

extern char *heap_beg;
extern char *heap_end;
extern char *heap_ptr;

#ifdef __cplusplus
extern "C" {
#endif

extern char *sbrk(int nbytes);

#ifdef __cplusplus
}
#endif

#endif /* SBRK_H_ */
