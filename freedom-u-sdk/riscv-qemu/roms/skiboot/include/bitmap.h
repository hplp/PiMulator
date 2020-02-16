/* Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __BITMAP_H
#define __BITMAP_H

#include <stdint.h>
#include <stdbool.h>

typedef unsigned long bitmap_elem_t;
typedef bitmap_elem_t bitmap_t[];

#define BITMAP_ELSZ	(sizeof(bitmap_elem_t) << 3)

/* Number of elements for _n bits (rounded up) */
#define BITMAP_ELEMS(_n)	(((_n) + (BITMAP_ELSZ - 1)) / BITMAP_ELSZ)
/* Number of bytes for _n bits (rounded up) */
#define BITMAP_BYTES(_n)	(BITMAP_ELEMS(_n) * sizeof(bitmap_elem_t))
/* Bit number within an elemnt for bit _n */
#define BITMAP_BIT(_n)		((_n) & (BITMAP_ELSZ - 1))
/* Corresponding mask */
#define BITMAP_MASK(_n)		(1ul << BITMAP_BIT(_n))
/* Element number for bit _n */
#define BITMAP_ELEM(_n)		((_n) / BITMAP_ELSZ)

static inline void bitmap_set_bit(bitmap_t map, unsigned int bit)
{
	map[BITMAP_ELEM(bit)] |= BITMAP_MASK(bit);
}

static inline void bitmap_clr_bit(bitmap_t map, unsigned int bit)
{
	map[BITMAP_ELEM(bit)] &= ~BITMAP_MASK(bit);
}

static inline bool bitmap_tst_bit(bitmap_t map, unsigned int bit)
{
	return map[BITMAP_ELEM(bit)] & BITMAP_MASK(bit);
}

extern int bitmap_find_zero_bit(bitmap_t map, unsigned int start,
				unsigned int count);
extern int bitmap_find_one_bit(bitmap_t map, unsigned int start,
				unsigned int count);

#define bitmap_for_each_zero(map, size, bit)                   \
	for (bit = bitmap_find_zero_bit(map, 0, size);         \
	     bit >= 0;					       \
	     bit = bitmap_find_zero_bit(map, bit + 1, size))

#define bitmap_for_each_one(map, size, bit)                    \
	for (bit = bitmap_find_one_bit(map, 0, size);          \
	     bit >= 0;					       \
	     bit = bitmap_find_one_bit(map, bit + 1, size))

#endif /* __BITMAP_H */
