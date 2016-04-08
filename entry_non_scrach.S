/* $Id: entry_non_scrach.S,v 1.3 2001/03/01 05:02:29 honda Exp $
 *
 * This file is originally written by Niibe Yutaka at GNU/Linux on SuperH 
 * Project
 *		
 * Modifications for the uITRON4.0 specification OS "TOPPERS" by Shinya Honda
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License.  See the file "COPYING.LIB" in the main
 * directory of this archive for more details.
 *
 * 例外/割り込み発生時にアクティブなバンクのレジスタをgdbに返す。	
 * バンク0,1どちらのレジスタも破壊しないが、スタックを使用するため、
 * スタックポインタの設定にミスがあるとリセットされる	
 *
 */
 
	
/* 
 *
 * gdb-sh-stub/entry.S
 *
 * Some code was taken from sh-stub.c of GDB 4.18.
 *
 *  Copyright (C) 1999, 2000  Niibe Yutaka
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License.  See the file "COPYING.LIB" in the main
 * directory of this archive for more details.
 *
 */
  
#include "linkage.h"
#include "config.h"
	
#if defined(__sh3__)
TRA      = 0xffffffd0
EXPEVT   = 0xffffffd4
INTEVT   = 0xffffffd8
INTEVT2  = 0xa4000000
TMU0_TCR = 0xfffffe9c
#define CCR			0xffffffec	/* Cache Control Register */
#define CCR_CACHE_DISABLE	0x008		/* Flush the cache, disable */
#define CCR_CACHE_INIT		0x0		/* disable */
#elif defined(__SH4__)
TRA      = 0xff000020
EXPEVT   = 0xff000024
INTEVT   = 0xff000028
TMU0_TCR = 0xffd80010
#define CCR			0xFF00001C	/* Cache Control Register */
#define CCR_CACHE_DISABLE	0x0808		/* Flush the cache, disable */
#define CCR_CACHE_INIT		0x0		/* disable */
#endif

#if defined(CONFIG_CARD_E09A)	
	.global	_PCE_header
	.section .text
	.align 2
_PCE_header:
	.ascii	"SEIKO EPSON CARD-PCE"
	.long	0
	.long	-1409089536
	.long	_start
	.ident	"GCC: (GNU) 2.95.1 19990816 (release)"	
#endif
	
	.align 2
	.global _start
	.section .text
ENTRY(start)
	/* Disable cache */
	mov.l	CCR_A,r1	/* CCR Address */
	mov.l	CCR_DISABLE,r0	/* CCR Data */
	mov.l	r0,@r1

	/* Initialize BSC */
	mov.l	1f,r0
	jsr	@r0
	 nop

	/* Initialize cache */
	mov.l	CCR_A,r1	/* CCR Address */
	mov.l	CCR_D,r0	/* CCR Data */
	mov.l	r0,@r1

	/* Initialize VBR */
	mov.l	VBR_INIT,r0
	ldc	r0,vbr

	/* SR: MD=1, BL=0, RB=0 */
	mov.l	INITIAL_SR,r0
	ldc	r0,sr

	mov.l	INITIAL_STACK,r0
	mov	r0,r15

	/* Initialize Serial Port */
	mov.l	2f,r0
	jsr	@r0
	 nop

	/* Initialize BSS */
	mov.l	4f,r1
	add	#4,r1
	mov.l	5f,r2
	mov	#0,r0
9:	cmp/hs	r2,r1
	bf/s	9b		! while (r1 < r2)
	 mov.l	r0,@-r2

        /* Initialize Data */
        mov.l   6f,r0
        mov.l   7f,r1
        cmp/eq  r0,r1
        bt      11f
        mov.l   8f,r2
        mov     #4,r3
10:
        mov.l   @r0+,r4
        mov.l   r4,@r2
        cmp/eq  r0,r1
        add     r3,r2
        bf      10b
	
	/* Jump to GDB Stub */	
11:	mov.l	3f,r0
	jmp	@r0
	 nop

	.balign	4
1:	.long	SYMBOL_NAME(init_bsc)
2:	.long	SYMBOL_NAME(init_serial)
3:	.long	SYMBOL_NAME(start_gdbstub)
4:	.long	SYMBOL_NAME(__bss_start)
5:	.long	SYMBOL_NAME(__bss_end)
6:	.long   SYMBOL_NAME(_idata_start)
7:	.long   SYMBOL_NAME(_idata_end)
8:	.long   SYMBOL_NAME(_data_start)	
CCR_A:	.long	CCR
CCR_DISABLE:
	.long	CCR_CACHE_DISABLE
CCR_D:	.long	CCR_CACHE_INIT
INITIAL_SR:
	.long	0x40000000	/* MD=1, RD=0, BL=0 */
INITIAL_STACK:
	.long	SYMBOL_NAME(stub_stack)
VBR_INIT:
	.long   SYMBOL_NAME(_text)	


#ifdef CONFIG_CARD_E09A
LED_CON:	
	.long   0xB1000780
LED_ADD:	
	.long   0xBBC00080
LED_INIT:	
	.long   0x00000080			
LED_DATA:
	.word   0xf0f0
#endif
	

		
!
!
	.balign 	256,0,256
general_exception:
	mov.l   r2,@-r15
	mov.l	1f,r2
	bra	do_exception
	 mov.l	@r2,r2
	.balign	4
1:	.long	EXPEVT
!
!
	.balign 	1024,0,1024
tlb_miss:
	mov.l   r2,@-r15
	mov.l	1f,r2
	bra	do_exception
	 mov.l	@r2,r2
!
	.balign 	512,0,512
interrupt:
	mov.l   r2,@-r15
	mov.l	2f,r2
	bra	do_exception
	 mov.l	@r2,r2
	.balign	4
1:	.long	EXPEVT
#ifdef	CONFIG_SH7709
2:	.long	INTEVT2
#else   /* CONFIG_SH77708 */
2:	.long	INTEVT	
#endif	
!
!
do_exception:
	shlr2	r2
	shlr2	r2
	shlr	r2
	mov.l   r0,@-r15
	mov.l   1f,r0
	mov.l   r2,@r0
	shll2   r2              !       (original)r0
	mov.l	2f,r0           ! stack (original)r2
	add	r0,r2
	mov.l	@r2,r2
	mov.l   @r15+,r0     	! (original)r0 -> r0
	jmp	@r2
	mov.l   @r15+,r2        ! (original)r2 -> r2
	.balign	4
1:	.long   SYMBOL_NAME(exception)	
2:	.long	_exception_handling_table


saveRegisters:
	mov.l	L_reg, r0
	mov.l	@r15+, r1			! pop R0
	mov.l	r2, @(0x08, r0)			! save R2
	mov.l	r1, @r0				! save R0
	mov.l	@r15+, r1			! pop R1
	mov.l	r3, @(0x0c, r0)			! save R3
	mov.l	r1, @(0x04, r0)			! save R1
	mov.l	r4, @(0x10, r0)			! save R4
	mov.l	r5, @(0x14, r0)			! save R5
	mov.l	r6, @(0x18, r0)			! save R6
	mov.l	r7, @(0x1c, r0)			! save R7
	mov.l	r8, @(0x20, r0)			! save R8
	mov.l	r9, @(0x24, r0)			! save R9
	mov.l	r10, @(0x28, r0)		! save R10
	mov.l	r11, @(0x2c, r0)		! save R11
	mov.l	r12, @(0x30, r0)		! save R12
	mov.l	r13, @(0x34, r0)		! save R13
	mov.l	r14, @(0x38, r0)		! save R14
	mov.l	@r15+, r4			! save arg to handleException
	mov.l	r15, @(0x3c, r0)		! save R15
	add	#92, r0				! readjust register pointer
	mov	r15, r2
	add	#4, r2
	stc	ssr, r2				! R2 has SR
	stc	spc, r1				! R1 has PC
	mov.l	r2, @-r0			! save SR
	sts.l	macl, @-r0			! save MACL
	sts.l	mach, @-r0			! save MACH
	stc.l	vbr, @-r0			! save VBR
	stc.l	gbr, @-r0			! save GBR
	sts.l	pr, @-r0			! save PR
	mov.l	L_stubstack, r2
	mov.l	L_hdl_except, r3
	mov.l	@r2, r15
	jsr	@r3
	 mov.l	r1, @-r0			! save PC
	mov.l	L_stubstack, r0
	mov.l	L_reg, r1
	bra	restoreRegisters
	 mov.l	r15, @r0			! save __stub_stack

	.balign	4
L_reg:
	.long	SYMBOL_NAME(registers)
L_stubstack:
	.long	SYMBOL_NAME(stub_sp)
L_hdl_except:
	.long	SYMBOL_NAME(handle_exception)

restoreRegisters:
	add	#8, r1				! skip to R2
	mov.l	@r1+, r2			! restore R2
	mov.l	@r1+, r3			! restore R3
	mov.l	@r1+, r4			! restore R4
	mov.l	@r1+, r5			! restore R5
	mov.l	@r1+, r6			! restore R6
	mov.l	@r1+, r7			! restore R7
	mov.l	@r1+, r8			! restore R8
	mov.l	@r1+, r9			! restore R9
	mov.l	@r1+, r10			! restore R10
	mov.l	@r1+, r11			! restore R11
	mov.l	@r1+, r12			! restore R12
	mov.l	@r1+, r13			! restore R13
	mov.l	@r1+, r14			! restore R14
	mov.l	@r1+, r15			! restore programs stack
	mov.l	@r1+, r0
	ldc	r0, spc				! restore PC
	lds.l	@r1+, pr			! restore PR
	ldc.l	@r1+, gbr			! restore GBR		
	ldc.l	@r1+, vbr			! restore VBR
	lds.l	@r1+, mach			! restore MACH
	lds.l	@r1+, macl			! restore MACL
	mov.l	@r1, r0	
	add	#-88, r1			! readjust reg pointer to R1
	ldc	r0, ssr				! restore SR
	mov.l	r2, @-r15
	mov.l	L_in_nmi, r0
	mov	#0, r2
	mov.b	r2, @r0
	mov.l	@r15+, r2
	mov.l	@r1+, r0			! restore R0
	rte
	 mov.l	@r1, r1				! restore R1

address_error_load:
address_error_store:
	add	#-4,r15			! reserve spot on stack
	mov.l	r1,@-r15		! push R1
	  /* Exception 9 (bus errors) are disasbleable - so that you
	     can probe memory and get zero instead of a fault.
	     Because the vector table may be in ROM we don't revector
	     the interrupt like all the other stubs, we check in here
	     */
	mov.l	L_dofault,r1
	mov.l	@r1,r1
	tst	r1,r1
	bf	2f
	mov.l	L_handle_buserror,r0
	jmp	@r0
	 nop
	.balign	4
L_dofault:
	.long 	SYMBOL_NAME(dofault)
L_handle_buserror:
	.long	SYMBOL_NAME(handle_buserror)
1:	.long	SYMBOL_NAME(handleError)
	
break:
	add	#-4,r15			! reserve spot on stack
	mov.l	r1,@-r15		! push R1
	mov.l	r0,@-r15		! push R0
	mov.l	r2,@-r15		! push R2
	mov.l	1f,r0
	jsr	@r0
        mov.l	r3,@-r15		! push R3
	mov.l	@r15+,r3		! pop R3
	bra	2f
        mov.l	@r15+,r2		! pop R2

	.balign	4
1:	.long	SYMBOL_NAME(handleBreak)

unconditional_trap:
reserved_instruction:
illegal_slot_instruction:
user_break:
	add	#-4,r15			! reserve spot on stack
	mov.l	r1,@-r15		! push R1

1:	mov.l	r0,@-r15		! push R0
	/* Prepare for saving context, we've already pushed r0 and r1, stick
	   exception number into the frame */
2:	stc     ssr,r0
	shll2   r0
	shll    r0
	bt      3f
	mov.l	5f,r1	
	stc	sr,r0
	and	r1,r0
	or      #0xf0,r0
	mov     r0,r1
	mov.l   @r15+,r0                ! maybe do not need
	ldc	r1,sr                   ! change bank RB=0 BL=0
	ldc.l   @r15+,r1_bank           ! maybe do not need
	mov.l	r1,@-r15		! push R1
	mov.l	r0,@-r15		! push R0
	bra     4f
3:	mov.l   6f,r1
	stc	sr,r0
	and	r1,r0
	or      #0xf0,r0
	mov     r0,r1	
	ldc	r1,sr
4:	mov	r15,r0
	add	#8,r0
	mov.l   7f,r1
	mov.l   @r1,r1
	bra	saveRegisters		! save register values
	 mov.l	r1,@r0			! save exception #

	.balign	4
5:	.long	0xcfffffff	! RB=0,BL=0
6:	.long	0xefffffff	! BL=0
7:	.long   SYMBOL_NAME(exception)	
	
nmi:
	add	#-4,r15			! reserve spot on stack
	mov.l	r1,@-r15		! push R1
	mov.l	r0,@-r15		! push R0
#ifdef CONFIG_DVESH3
	mov.l   DGR_CSR23_A,r1
	mov.l   DGR_CSR23_D,r0
	mov.l   r0,@r1
#endif	
	/* Special case for NMI - make sure that they don't nest */	
	mov.l	L_in_nmi,r0
	tas.b	@r0			! Fend off against addtnl NMIs
	mov     #0x1,r1
	mov.b   r1,@r0
	bt	2b
	mov.l	@r15+,r0
	mov.l	@r15+,r1
	add	#4, r15
	rte
        nop

	.balign	4
L_in_nmi:
	.long	SYMBOL_NAME(in_nmi)
#ifdef CONFIG_DVESH3
DGR_CSR23_A:	
	.long   0xa480005c	
DGR_CSR23_D:	
	.long   0x40000000    /* Abor rach clear */	
#endif
		
do_IRQ:
	rte
	 nop

do_timer:			/* Clear flag */
	mov.l	1f,r0
	mov.w	@r0,r1
	mov.w	2f,r2
	and	r2,r1
	mov.w	r1,@r0
	rte
	 nop
	.balign	4
1:	.long	TMU0_TCR
2:	.word	0xfeff



	.global _exception_handling_table
	.section .data
_exception_handling_table:
	.long	0 !                                  0,0   
	.long	0 !				     20,1  
	.long	0 ! tlb_miss_load		     40,2  
	.long	0 ! tlb_miss_store		     60,3  
	.long	0 ! initial_page_write		     80,4  
	.long	0 ! tlb_protection_violation_load    A0,5  
	.long	0 ! tlb_protection_violation_store   C0,6  
	.long	address_error_load		    !E0,7  
	.long	address_error_store		    !100,8 
	.long	0 				    !120,9 
	.long	0 				    !140,10
	.long	unconditional_trap		    !160,11
	.long	reserved_instruction		    !180,12
	.long	illegal_slot_instruction	    !1A0,13
	.long	nmi                                 !1C0,14
	.long	user_break			    !1E0,15

ENTRY(interrupt_table)
	! external hardware
	.long	do_IRQ	! 0000			     200,16
	.long	do_IRQ	! 0001			     220,17
	.long	do_IRQ	! 0010			     240,18
	.long	do_IRQ	! 0011			     260,19
	.long	do_IRQ	! 0100			     280,20
	.long	do_IRQ	! 0101			     2A0,21
	.long	do_IRQ	! 0110			     2C0,22
	.long	do_IRQ	! 0111			     2E0,23
	.long	do_IRQ	! 1000			     300,24
	.long	do_IRQ	! 1001			     320,25
	.long	do_IRQ	! 1010			     340,26
	.long	do_IRQ	! 1011			     360,27
	.long	do_IRQ	! 1100			     380,28
	.long	do_IRQ	! 1101			     3A0,29
	.long	do_IRQ	! 1110			     3C0,30
	.long	0				    !3E0,31
	! Internal hardware
	.long	do_timer	! TMU0 tuni0	     400,32
	.long	do_IRQ		! TMU1 tuni1	     420,33
	.long	do_IRQ		! TMU2 tuni2	     440,34
	.long	do_IRQ		!      ticpi2	     460,35
	.long	do_IRQ		! RTC  ati	     480,36
	.long	do_IRQ		!      pri	     4A0,37
	.long	do_IRQ		!      cui	     4C0,38
	.long	do_IRQ		! SCI  eri	     4E0,39
	.long	do_IRQ		!      rxi	     500,40
	.long	do_IRQ		!      txi	     520,41
	.long	do_IRQ		!      tei	     540,42
	.long	do_IRQ		! WDT  iti	     560,43
	.long	do_IRQ		! REF  rcmi	     580,44
	.long	do_IRQ		!      rovi	     5A0,45
#ifdef	CONFIG_SH7709			
	.long	do_IRQ		!		     5C0,46
	.long	do_IRQ          ! Hitachi UDI	     5E0,47
	.long	do_IRQ		! IRQ0		     600,48
	.long	do_IRQ          ! IRQ1 		     620,49
	.long	do_IRQ		! IRQ2 		     640,50
	.long	do_IRQ		! IRQ3 		     660,51
	.long	do_IRQ		! IRQ4 		     680,52
	.long	do_IRQ		! IRQ5 		     6A0,53
	.long	do_IRQ		!		     6C0,54
	.long	do_IRQ		!		     6E0,55
	.long	do_IRQ		!		     700,56
	.long	do_IRQ		!		     720,57
	.long	do_IRQ		!		     740,58
	.long	do_IRQ		!		     760,59
	.long	do_IRQ		!	             780,60
	.long	do_IRQ		!		     7A0,61
	.long	do_IRQ		!		     7C0,62
	.long	do_IRQ		!		     7E0,63
	.long	do_IRQ		! DMAC dmte0	     800,64
	.long	do_IRQ		!      dmte1	     820,65
	.long	do_IRQ		!      dmte2	     840,66
	.long	do_IRQ		!      dmte3	     860,67
	.long   do_IRQ		! IrDA eri	     880,68
	.long   do_IRQ		!      rxi	     8A0,69
	.long   do_IRQ		!      bri	     8C0,70
	.long   do_IRQ		!      txi	     8E0,71
	.long   do_IRQ		! SCIF eri	     900,72
	.long   break		!      rxi	     920,73
	.long   break		!      bri	     940,74
	.long   do_IRQ		!      txi	     960,75
	.long   do_IRQ		! ADC  adi	     980,76
#endif	
	
/* End of entry.S */











