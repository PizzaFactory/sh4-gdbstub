/* $Id: io.h,v 1.1 2000/11/11 18:04:17 honda Exp $
 *
 * gdb-sh-stub/io.h
 *
 *  Copyright (C) 1999  Niibe Yutaka
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License.  See the file "COPYING.LIB" in the main
 * directory of this archive for more details.
 *
 */

#ifndef _IO_H
#define _IO_H	1

extern __inline__ void cli(void)
{
	unsigned long __dummy;
	__asm__ __volatile__("stc	sr,%0\n\t"
			     "or	%1,%0\n\t"
			     "ldc	%0,sr"
			     : "=&z" (__dummy)
			     : "r" (0x10000000)
			     : "memory");
}

extern __inline__ void sti(void)
{
	unsigned long __dummy;

	__asm__ __volatile__("stc	sr,%0\n\t"
			     "and	%1,%0\n\t"
			     "ldc	%0,sr"
			     : "=&z" (__dummy)
			     : "r" (0xefffffff)
			     : "memory");
}

extern __inline__ unsigned long p4_inb(unsigned long addr)
{
       return *(volatile unsigned char*)addr;
}

extern __inline__ unsigned long p4_inw(unsigned long addr)
{
       return *(volatile unsigned short*)addr;
}

extern __inline__ unsigned long p4_inl(unsigned long addr)
{
       return *(volatile unsigned long*)addr;
}

extern __inline__ void p4_outb(unsigned long addr, unsigned short b)
{
       *(volatile unsigned char*)addr = b;
}

extern __inline__ void p4_outw(unsigned long addr,unsigned short b)
{
       *(volatile unsigned short*)addr = b;
}

extern __inline__ void p4_outl(unsigned long addr, unsigned int b)
{
        *(volatile unsigned long*)addr = b;
}

#define p4_in(addr)	*(addr)
#define p4_out(addr,data) *(addr) = (data)

#endif /* _IO_H */
