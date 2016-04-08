/* $Id: init_card-e09a.S,v 1.1 2000/11/11 18:04:17 honda Exp $
 *
 *  init_card-e09a.S
 *
 *
 */

#include "linkage.h"
ENTRY(init_bsc)
	mov   #0x00,r0
	mov.l ICR0,r1
	mov.w r0,@r1
	mov.l ICR1,r1
	mov.w r0,@r1
	mov.l ICR2,r1
	mov.w r0,@r1
	mov.l PINTER,r1
	mov.w r0,@r1
	mov.l IPRA,r1
	mov.w r0,@r1
	mov.l IPRB,r1
	mov.w r0,@r1
	mov.l IPRC,r1
	mov.w r0,@r1
	mov.l IPRD,r1
	mov.w r0,@r1
	mov.l IPRE,r1
	mov.w r0,@r1
	mov.l IRR0,r1
	mov.b r0,@r1			
	mov.l IRR1,r1
	mov.b r0,@r1
	mov.l IRR2,r1
	mov.b r0,@r1		
	rts
        nop
	
	.balign	4
ICR0:	
	.long 0xfffffee0
ICR1:
	.long 0xa4000010
ICR2:
	.long 0xa4000012
PINTER:
	.long 0xa4000014
IPRA:
	.long 0xfffffee2
IPRB:	
	.long 0xfffffee4
IPRC:	
	.long 0xa4000016
IPRD:	
	.long 0xa4000018			
IPRE:	
	.long 0xa400001a					
IRR0:
	.long 0xa4000004
IRR1:
	.long 0xa4000006
IRR2:
	.long 0xa4000008
	
	


