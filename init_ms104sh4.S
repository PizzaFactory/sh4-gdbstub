/* $Id: init_sesh3.S,v 1.1 2001/03/03 18:22:21 honda Exp $
 *
 *  init_ms104sh4.S
 *
 */

#include "linkage.h"


ENTRY(init_bsc)
!	外部端子設定
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
FRQCR_A:				/* クロック設定 */
	.long	0xFFC00000	/* FRQCR Address */
FRQCR_D:
	.long	0x0E1A		/* 12:3:3 */

BCR1_A:					/* エンディアン設定とメモリタイプ設定 */
	.long	0xFF800000	/* BCR1 Address */
BCR1_D:
	.long	0x80000009	/* Little Endian
						   Area 2:SRAM Area 3:SDRAM Area 5/6:PCMCIA */

BCR2_A:					/* バス幅設定 */
	.long	0xFF800004	/* BCR2 Address */
BCR2_D:
    .long   0xAAE5		/* Area 0:16bit Area 6:16bit Area 5:16bit Area4:16bit
						   Area 3:32bit Area 2:16bit Area 1: 8bit PORTEN:On */

BCR3_A:					/* エリア設定 */
	.long	0xFF800050	/* BCR3 Address */
BCR3_D:
	.long	0x0000		/* Same as initial value */

BCR4_A:					/* 非同期入力設定 */
	.long	0xFE0A00F0	/* BCR4 Address */
BCR4_D:
	.long	0x00000013	/* ASYNC4:_IOIS16 ASYNC1:_BREQ ASYNC0:_RDY */

WCR1_A:					/* サイクル間アイドル指定 - アイドルサイクル数 */
	.long	0xFF800008	/* WCR1 Address */
WCR1_D:
	.long	0x71111211	/* DMA:15 A6:1 A5:1 A4:1 A3:1 A2:2 A1:1 A0:1 */

WCR2_A:					/* ウェイトステート数 - ウェイトサイクル */
	.long	0xFF80000C	/* WCR2 Address */
WCR2_D:
	.long	0xDFF2466A	/* A6W:12 A6B:7 A5W:15 A5B:7 A4W:1
						   A3W:3 A2W:3 A1W:1 A0W:9 A0B:2 */

WCR3_A:					/* ライトストローブセットアップ時間とデータホールド時間 */
	.long	0xFF800010	/* WCR3 Address */
WCR3_D:
	.long	0x07777575	/* A6 S:1/H:3  A5 S:1/H:3  A4 RDH:0/S:1/H:3  A3 S:1/H:3
									   A2 S:1/H:1  A1 RDH:0/S:1/H:3  A0 S:1/H:1 */

MCR_A:					/* SDRAMモードレジスタ設定 */
	.long	0xFF800014	/* MCR Address */
MCR_D:
	.long	0x1009019c	/* RASD:通常モード
						   MRSET:全バンクプリチャージ
						   TRC:リフレッシュ後のRASプリジャージ期間 6
						   TCAS:CASネゲート 1
						   TPC:RASプリジャージ期間 1
						   RCD:RAS-CAS遅延 3
						   TRWL:書き込みプリチャージ遅延 1
						   TRAS:CASビフォRASリフレッシュ_RASアサート期間 4+TRC
						   SZ:メモリデータサイズ 32ビット
						   AMX:アドレスマルチプレクス（64M：2M×8 ビット×4）×4
						   RFSH:リフレッシュ制御 実行
						   RMODE:リフレッシュモード CASビフォRASリフレッシュ
						   EDOMODE:：EDOモード 0 */
MCR_D1:
	.long	0x5009019c	/* MRSET:モードレジスタ設定 */

PCR_A:					/* PCMCIA コントロールレジスタ */
	.long	0xFF800018	/* PCR Address */
PCR_D:
	.long	0xCF3B		/* ウェイト数 Area 5:50 Area 6:0
						   アドレス - OE/WEアサート遅延  Area 5:15 Area 6:6
						   アドレス - OE/WEネゲート遅延  Area 5:15 Area 6:3 */

RTCSR_A:				/* リフレッシュタイマコントロール／ステータスレジスタ */
	.long	0xFF80001C	/* RTCSR Address */
RTCSR_D:
	.long	0xA508      /* RTCSR Write Code A5h Data 08h */

RTCNT_A:				/* リフレッシュタイマカウンタ */
	.long	0xFF800020	/* RTCOR Address */
RTCNT_D:
	.long	0xA500		/* RTCNT Write Code A5h Data 00h */

RTCOR_A:				/* リフレッシュタイムコンスタントレジスタ */
	.long	0xFF800024	/* RTCOR Address */
RTCOR_D:
	.long	0xA5BC      /* RTCOR Write Code A5h Data BCh
						   4kCycle/64msec */

RFCR_A:					/* リフレッシュカウントレジスタ */
	.long	0xFF800028	/* RFCR Address */
RFCR_D:
	.long	0xA400		/* RFCR Write Code A4h Data 00h */

SDMR3_A:				/* シンクロナスDRAM モードレジスタ */
	.long	0xFF94008C	/* SDMR3 Address バス幅32, バースト長8, CASレイテンシ2 */


