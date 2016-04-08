/* $Id: init_dvesh3.S,v 1.1 2000/11/11 18:04:17 honda Exp $
 *
 *  init_dvesh3.S
 *
 *
 */

#include "linkage.h"
#include "config.h"
					
ENTRY(init_bsc)
	mov.l	FRQCR_A,r1	/* FRQCR Address */
	mov.l	FRQCR_D,r0	/* FRQCR Data */
	mov.w	r0,@r1

	mov.l	BCR1_A,r1	/* BCR1 Address */
	mov.l	BCR1_D,r0	/* BCR1 Data */
	mov.w	r0,@r1

	mov.l	BCR2_A,r1	/* BCR2 Address */
	mov.l	BCR2_D,r0	/* BCR2 Data */
	mov.w	r0,@r1


	mov.l	WCR1_A,r1	/* WCR1 Address */
	mov.l	WCR1_D,r0	/* WCR1 Data */
	mov.w	r0,@r1

	mov.l	WCR2_A,r1	/* WCR2 Address */
	mov.l	WCR2_D,r0	/* WCR2 Data */
	mov.w	r0,@r1

	mov.l	MCR_A,r1	/* MCR Address */
	mov.l	MCR_D,r0	/* MCR Data */
	mov.w	r0,@r1

	mov.l	DCR_A,r1	/* DCR Address */
	mov.l	DCR_D,r0	/* DCR Data */
	mov.w	r0,@r1

	! Do you need PCMCIA setting?
	! If so, please add the lines here...

	mov.l	RTCOR_A,r1	/* RTCOR Address */
	mov.l	RTCOR_D,r0	/* RTCOR Data */
	mov.w	r0,@r1
	
	mov.l	RTCSR_A,r1	/* RTCSR Address */
	mov.l	RTCSR_D,r0	/* RTCSR Data */
	mov.w	r0,@r1

	mov.l	RTCNT_A,r1	/* RTCNT Address */
	mov.l	RTCNT_D,r0	/* RTCNT Data */
	mov.w	r0,@r1

	mov.l	SDMR3_A,r1	/* Set SDRAM mode */
	mov	#0,r0
	mov.b	r0,@r1	


	mov.l	RFCR_A,r1	/* RFCR Address */
	mov.l	RFCR_D,r0	/* RFCR Data */
	mov.w	r0,@r1		/* Clear reflesh counter */

	/* Wait DRAM refresh 8 times */
	mov.l	RFCR_A,r1	/* RFCR Address */
	mov	#8,r3
1:
	mov.w	@r1,r0
	extu.w	r0,r2
	cmp/hi	r3,r2
	bf	1b

	mov.l   DGR_CSR0_A,r1
	mov.l   DGR_CSR0_D,r0
	mov.l   r0,@r1

	mov.l   DGR_CSR21_A,r1
	mov.l   DGR_CSR21_D,r0
	mov.l   r0,@r1


	mov.l   DGR_CSR23_A,r1
	mov.l   DGR_CSR23_D,r0
	mov.l   r0,@r1


	mov.l   DGR_CSR24_A,r1
	mov.l   DGR_CSR24_D,r0
	mov.l   r0,@r1	

	rts
        nop

	.balign 4
FRQCR_A:
	.long	0xFFFFFF80	/* FRQCR Address */
FRQCR_D:
	.long	0x00000101      /* mode 7 60MHz 1:1:1/2 */
BCR1_A:
	.long	0xFFFFFF60	/* BCR1 Address */
BCR1_D:
	.long	0x00001008	/* Area 3 SDRAM */
BCR2_A:
	.long	0xFFFFFF62	/* BCR2 Address */
BCR2_D:
	.long	0x00003ffc	/* Area 2:32bit Area 4:32bit 
		                   Area 3:32bit	Area 5:32bit Area 6:32bit */
WCR1_A:
	.long	0xFFFFFF64	/* WCR1 Address */
WCR1_D:
	.long	0x3FD5		/* Idle state cycle:
				   WAITSEL=0  A6:1 A5:3 A4:3 A3:1 A2:3 A0:1 */
WCR2_A:
	.long	0xFFFFFF66	/* WCR2 Address */
WCR2_D:
	.long	0xFFEF		/* A6: 3 A5: 10 A4: 10 A3: 2 A2: 3 A0: 3  */
MCR_A:
	.long	0xFFFFFF68	/* MCR Address */
MCR_D:
	.long	0x973C
DCR_A:
	.long	0xFFFFFF6A	/* DCR Address */
DCR_D:
	.long	0x0000
RTCSR_A:
	.long	0xFFFFFF6E	/* RTCSR Address */
RTCSR_D:
	.long	0xA508

RTCNT_A:
	.long	0xFFFFFF70	/* RTCOR Address */
RTCNT_D:
	.long	0xA500		/* RTCNT Write Code A5h Data 00h */

RTCOR_A:
	.long	0xFFFFFF72	/* RTCOR Address */
RTCOR_D:
#ifdef CONFIG_30MHZ		
	.long	0xA575
#else	/* 60MHz */
	.long	0xA5EA
#endif	
	
RFCR_A:
	.long	0xFFFFFF74	/* RFCR Address */
RFCR_D:
	.long	0xA400		/* RFCR Write Code A4h Data 00h */
SDMR3_A:
	.long	0xFFFFE8C0	/* SDMR3 Address */
DGR_CSR0_A:	
	.long   0xa4800000
DGR_CSR0_D:	
	.long   0x2087c0c0	
DGR_CSR21_A:
	.long   0xa4800054
DGR_CSR21_D:
	.long   0x40000000     /* Abort ON      */
DGR_CSR23_A:	
	.long   0xa480005c
DGR_CSR23_D:	
	.long   0x40000000    /* Abor rach clear */	
DGR_CSR24_A:	
	.long   0xa4800060
DGR_CSR24_D:	
	.long   0x07000000    /* Abor -> IRQ7 -> NMI */
	







