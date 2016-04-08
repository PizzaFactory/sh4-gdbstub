/* $Id: init_sesh3.S,v 1.1 2001/03/03 18:22:21 honda Exp $
 *
 *  init_ms104sh4.S
 *
 */

#include "linkage.h"


ENTRY(init_bsc)
!	�O���[�q�ݒ�
!	mov.l	FRQCR_A,r1	/* FRQCR Address */
!	mov.l	FRQCR_D,r0	/* FRQCR Data */
!	mov.w	r0,@r1

	mov.l	BCR1_A,r1	/* BCR1 Address */
	mov.l	BCR1_D,r0	/* BCR1 Data */
	mov.l	r0,@r1

	mov.l	BCR2_A,r1	/* BCR2 Address */
	mov.l	BCR2_D,r0	/* BCR2 Data */
	mov.w	r0,@r1

	mov.l	BCR3_A,r1	/* BCR3 Address */
	mov.l	BCR3_D,r0	/* BCR3 Data */
	mov.w	r0,@r1

	mov.l	BCR4_A,r1	/* BCR4 Address */
	mov.l	BCR4_D,r0	/* BCR4 Data */
	mov.l	r0,@r1

	mov.l	WCR1_A,r1	/* WCR1 Address */
	mov.l	WCR1_D,r0	/* WCR1 Data */
	mov.l	r0,@r1

	mov.l	WCR2_A,r1	/* WCR2 Address */
	mov.l	WCR2_D,r0	/* WCR2 Data */
	mov.l	r0,@r1

	mov.l	WCR3_A,r1	/* WCR3 Address */
	mov.l	WCR3_D,r0	/* WCR3 Data */
	mov.l	r0,@r1

	mov.l	MCR_A,r1	/* MCR Address */
	mov.l	MCR_D,r0	/* MCR Data */
	mov.l	r0,@r1

	! Do you need PCMCIA setting?
	! If so, please add the lines here...

	mov.l	PCR_A,r1	/* PCR Address */
	mov.l	PCR_D,r0	/* PCR Data */
	mov.w	r0,@r1

	mov.l	RTCOR_A,r1	/* RTCOR Address */
	mov.l	RTCOR_D,r0	/* RTCOR Data */
	mov.w	r0,@r1

	mov.l	RTCSR_A,r1	/* RTCSR Address */
	mov.l	RTCSR_D,r0	/* RTCSR Data */
	mov.w	r0,@r1

	mov.l	RTCNT_A,r1	/* RTCNT Address */
	mov.l	RTCNT_D,r0	/* RTCNT Data */
	mov.w	r0,@r1

	mov.l	RFCR_A,r1	/* RFCR Address */
	mov.l	RFCR_D,r0	/* RFCR Data */
	mov.w	r0,@r1		/* Clear reflesh counter */

	/* Wait DRAM refresh 8 times */
	mov.l	RFCR_A,r1	/* RFCR Address */
	mov		#8,r3
1:
	mov.w	@r1,r0
	extu.w	r0,r2
	cmp/hi	r3,r2
	bf	1b

	mov.l	SDMR3_A,r1	/* Set SDRAM mode */
	mov		#0,r0
	mov.b	r0,@r1

	rts
	nop

	.balign 4
FRQCR_A:				/* �N���b�N�ݒ� */
	.long	0xFFC00000	/* FRQCR Address */
FRQCR_D:
	.long	0x0E1A		/* 12:3:3 */

BCR1_A:					/* �G���f�B�A���ݒ�ƃ������^�C�v�ݒ� */
	.long	0xFF800000	/* BCR1 Address */
BCR1_D:
	.long	0x80000009	/* Little Endian
						   Area 2:SRAM Area 3:SDRAM Area 5/6:PCMCIA */

BCR2_A:					/* �o�X���ݒ� */
	.long	0xFF800004	/* BCR2 Address */
BCR2_D:
    .long   0xAAE5		/* Area 0:16bit Area 6:16bit Area 5:16bit Area4:16bit
						   Area 3:32bit Area 2:16bit Area 1: 8bit PORTEN:On */

BCR3_A:					/* �G���A�ݒ� */
	.long	0xFF800050	/* BCR3 Address */
BCR3_D:
	.long	0x0000		/* Same as initial value */

BCR4_A:					/* �񓯊����͐ݒ� */
	.long	0xFE0A00F0	/* BCR4 Address */
BCR4_D:
	.long	0x00000013	/* ASYNC4:_IOIS16 ASYNC1:_BREQ ASYNC0:_RDY */

WCR1_A:					/* �T�C�N���ԃA�C�h���w�� - �A�C�h���T�C�N���� */
	.long	0xFF800008	/* WCR1 Address */
WCR1_D:
	.long	0x71111211	/* DMA:15 A6:1 A5:1 A4:1 A3:1 A2:2 A1:1 A0:1 */

WCR2_A:					/* �E�F�C�g�X�e�[�g�� - �E�F�C�g�T�C�N�� */
	.long	0xFF80000C	/* WCR2 Address */
WCR2_D:
	.long	0xDFF2466A	/* A6W:12 A6B:7 A5W:15 A5B:7 A4W:1
						   A3W:3 A2W:3 A1W:1 A0W:9 A0B:2 */

WCR3_A:					/* ���C�g�X�g���[�u�Z�b�g�A�b�v���Ԃƃf�[�^�z�[���h���� */
	.long	0xFF800010	/* WCR3 Address */
WCR3_D:
	.long	0x07777575	/* A6 S:1/H:3  A5 S:1/H:3  A4 RDH:0/S:1/H:3  A3 S:1/H:3
									   A2 S:1/H:1  A1 RDH:0/S:1/H:3  A0 S:1/H:1 */

MCR_A:					/* SDRAM���[�h���W�X�^�ݒ� */
	.long	0xFF800014	/* MCR Address */
MCR_D:
	.long	0x1009019c	/* RASD:�ʏ탂�[�h
						   MRSET:�S�o���N�v���`���[�W
						   TRC:���t���b�V�����RAS�v���W���[�W���� 6
						   TCAS:CAS�l�Q�[�g 1
						   TPC:RAS�v���W���[�W���� 1
						   RCD:RAS-CAS�x�� 3
						   TRWL:�������݃v���`���[�W�x�� 1
						   TRAS:CAS�r�t�HRAS���t���b�V��_RAS�A�T�[�g���� 4+TRC
						   SZ:�������f�[�^�T�C�Y 32�r�b�g
						   AMX:�A�h���X�}���`�v���N�X�i64M�F2M�~8 �r�b�g�~4�j�~4
						   RFSH:���t���b�V������ ���s
						   RMODE:���t���b�V�����[�h CAS�r�t�HRAS���t���b�V��
						   EDOMODE:�FEDO���[�h 0 */
MCR_D1:
	.long	0x5009019c	/* MRSET:���[�h���W�X�^�ݒ� */

PCR_A:					/* PCMCIA �R���g���[�����W�X�^ */
	.long	0xFF800018	/* PCR Address */
PCR_D:
	.long	0xCF3B		/* �E�F�C�g�� Area 5:50 Area 6:0
						   �A�h���X - OE/WE�A�T�[�g�x��  Area 5:15 Area 6:6
						   �A�h���X - OE/WE�l�Q�[�g�x��  Area 5:15 Area 6:3 */

RTCSR_A:				/* ���t���b�V���^�C�}�R���g���[���^�X�e�[�^�X���W�X�^ */
	.long	0xFF80001C	/* RTCSR Address */
RTCSR_D:
	.long	0xA508      /* RTCSR Write Code A5h Data 08h */

RTCNT_A:				/* ���t���b�V���^�C�}�J�E���^ */
	.long	0xFF800020	/* RTCOR Address */
RTCNT_D:
	.long	0xA500		/* RTCNT Write Code A5h Data 00h */

RTCOR_A:				/* ���t���b�V���^�C���R���X�^���g���W�X�^ */
	.long	0xFF800024	/* RTCOR Address */
RTCOR_D:
	.long	0xA5BC      /* RTCOR Write Code A5h Data BCh
						   4kCycle/64msec */

RFCR_A:					/* ���t���b�V���J�E���g���W�X�^ */
	.long	0xFF800028	/* RFCR Address */
RFCR_D:
	.long	0xA400		/* RFCR Write Code A4h Data 00h */

SDMR3_A:				/* �V���N���i�XDRAM ���[�h���W�X�^ */
	.long	0xFF94008C	/* SDMR3 Address �o�X��32, �o�[�X�g��8, CAS���C�e���V2 */

