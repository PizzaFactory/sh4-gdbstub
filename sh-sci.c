/* $Id: sh-sci.c,v 1.7 2002/03/20 05:01:18 honda Exp $
 *
 * This file is originally developed at GNU/Linux on SuperH Project
 *
 * Modifications for the uITRON4.0 specification OS "TOPPERS" by Shinya Honda
 *
 */

/*
 * gdb-sh-stub/sh-scif.c
 *
 * Support for Serial I/O using on chip SCI/SCIF of SuperH
 *
 *  Copyright (C) 1999  Takeshi Yaegachi & Niibe Yutaka
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License.  See the file "COPYING.LIB" in the main
 * directory of this archive for more details.
 *
 */

#include "config.h"
#include "io.h"
#if defined(__sh3__)
#define IPRB (volatile unsigned short *)0xfffffee4
#define IPRE (volatile unsigned short *)0xa400001a
#define IPRSCI  IPRB
#define IPRSCIF IPRE
#elif defined(__SH4__)
#define IPRB (volatile unsigned short *)0xFFD00008  /* for SCI, IPRB (7～4ビット) */
#define IPRC (volatile unsigned short *)0xFFD0000C  /* for SCIF, IPRC (7～4ビット) */
#define IPRSCI  IPRB
#define IPRSCIF IPRC
#endif

#if defined(CONFIG_SCI)
#ifdef REMOTE_BREAK
#define SCSCR_INIT      0x0070 /* TIE=0,RIE=1,TE=1,RE=1 */
#else
#define SCSCR_INIT      0x0030 /* TIE=0,RIE=0,TE=1,RE=1 */
#endif
#if defined(__sh3__)
#define SCSMR  (volatile unsigned char *)0xfffffe80
#define SCBRR  0xfffffe82
#define SCSCR  (volatile unsigned char *)0xfffffe84
#define SC_TDR  0xfffffe86
#define SC_SR  (volatile unsigned char *)0xfffffe88
#define SC_RDR  0xfffffe8a
#elif defined(__SH4__)
#define SCSMR   (volatile unsigned char *)0xffe00000
#define SCBRR   0xffe00004
#define SCSCR   (volatile unsigned char *)0xffe00008
#define SC_TDR  0xffe0000c
#define SC_SR   (volatile unsigned char *)0xffe00010
#define SC_RDR  0xffe00014
#endif
#elif defined(CONFIG_SCIF)
#ifdef REMOTE_BREAK
#define SCSCR_INIT      0x0070 /* TIE=0,RIE=1,REIE=1,TE=1,RE=1 */
#else
#define SCSCR_INIT      0x0030 /* TIE=0,RIE=0,REIE=1,TE=1,RE=1 */
#endif
#if defined(__sh3__)
#define SCSMR  (volatile unsigned char *)0xA4000150
#define SCBRR  0xA4000152
#define SCSCR  (volatile unsigned char *)0xA4000154
#define SC_TDR 0xA4000156
#define SC_SR  (volatile unsigned short *)0xA4000158
#define SC_RDR 0xA400015A

#define SCFCR  (volatile unsigned char *)0xA400015C

#define SCPCR  0xA4000116
#define SCPDR  0xA4000136

#elif defined(__SH4__)
#define SCSMR  (volatile unsigned short *)0xFFE80000
#define SCBRR  0xFFE80004
#define SCSCR  (volatile unsigned short *)0xFFE80008
#define SC_TDR 0xFFE8000C
#define SC_SR  (volatile unsigned short *)0xFFE80010
#define SC_RDR 0xFFE80014

#define SCSPTR 0xFFE80020

#define SCFCR  (volatile unsigned short *)0xFFE80018

#endif /* __SH4__ */
#endif /* CONFIG_SCIF */

#if defined(__sh3__)

#define RFCR    0xffffff74
#if defined(CONFIG_SESH3)
#define BPS_SETTING_VALUE       8 /* 8: 115200 bps */

#elif defined(CONFIG_CARD_E09A)
#define BPS_SETTING_VALUE       8 /* 8: 115200 bps */

#elif defined(CONFIG_RSH3)
#if defined(CONFIG_16MHZ)
#define BPS_SETTING_VALUE       8  /* 8: 57600 bps */
#elif defined(CONFIG_40MHZ)
#define BPS_SETTING_VALUE       10 /*10: 57600 bps */
#endif

#elif defined(CONFIG_DVESH3)
#if defined(CONFIG_30MHZ)
#define BPS_SETTING_VALUE       3 /* 7: 115200 bps */
#elif defined(CONFIG_60MHZ)
#define BPS_SETTING_VALUE       7 /* 7: 115200 bps */
#endif

#else
#define BPS_SETTING_VALUE       3 /* 3: 115200 bps */
#endif

#elif defined(__SH4__)

#define RFCR    0xFF800028
#if defined(CONFIG_MS104SH4)
/* SCBRR1 の設定値
    Ｎ＝（Ｐφ／（６４×（２の（２ｎ－１）乗）×Ｂ））×１０の６乗－１
        Ｂ  ： ビットレート（bit/s）
        Ｎ  ： ボーレートジェネレータのSCBRR1 の設定値（0≦N≦255）
        Ｐφ： 周辺モジュール用動作周波数（MHz）
        ｎ  ： ボーレートジェネレータ入力クロック（n＝0、1、2、3）

    Ｂ＝115200、Ｐφ＝58.9824MHz、ｎ＝０の場合
        N = (58.9824 / (64 * 2^(2x0 - 1) * 115200)) * 10^6 - 1
          = 15
 */
#define BPS_SETTING_VALUE      15 /* 15: 115200 bps */

#else
#define BPS_SETTING_VALUE       8 /* 3: 230400 bps */
                                  /* 8: 115200 bps */

#endif /* CONFIG_MS104SH4 */
#endif

#if defined(CONFIG_SCI)

#define SCI_ER    0x0000
#define SCI_TD_E  0x0080
#define SCI_BRK   0x0020
#define SCI_FER   0x0010
#define SCI_PER   0x0008
#define SCI_RD_F  0x0040

#define SCI_TDRE_CLEAR          0x0078
#define SCI_RDRF_CLEAR          0x00bc
#define SCI_ERROR_CLEAR         0x00c4

#elif defined(CONFIG_SCIF)

#define SCI_ER    0x0080
#define SCI_TD_E  0x0020
#define SCI_BRK   0x0010
#define SCI_FER   0x0008
#define SCI_PER   0x0004
#define SCI_RD_F  0x0003

#define SCI_TDRE_CLEAR          0x00df
#define SCI_RDRF_CLEAR          0x00fc
#define SCI_ERROR_CLEAR         0x0063


#endif

#define WAIT_RFCR_COUNTER       200

#define DEVICE_S3S_LED_ADDRESS         0xBBC00080
typedef struct
{
    char       LED1;
    char       LED2;
}S3S_led_t;

#define S3S_LED (*((volatile S3S_led_t *)DEVICE_S3S_LED_ADDRESS))



void
handleBreak(void)
{
    /*
     * GDBからブレークを送ると^c'\003'が送られるので、これを読んでおかない
     * とネゴシエーションに時間がかかる。
     */

    unsigned short status;
    char ch;

    ch = p4_inb(SC_RDR);
    status = p4_in(SC_SR);
    p4_out(SC_SR, (SCI_ERROR_CLEAR & SCI_RDRF_CLEAR));
}

void
handleError (void)
{
  p4_in(SC_SR);
  p4_out(SC_SR, SCI_ERROR_CLEAR);
}

void
init_serial(void)
{
  p4_out(SCSCR, 0x0000);        /* TE=0, RE=0, CKE1=0 */
#if defined(CONFIG_SCIF)
  p4_out(SCFCR, 0x0006);        /* TFRST=1, RFRST=1 */
#endif
  p4_out(SCSMR, 0x0000);        /* CHR=0, PE=0, STOP=0, CKS=00 */
                        /* 8-bit, non-parity, 1 stop bit, pf/1 clock */


#if defined(CONFIG_SCIF)
#if defined(__sh3__)
  { /* For SH7709, SH7709A, SH7729 */
    unsigned short data;
    /* We need to set SCPCR to enable RTS/CTS */
    data = p4_inw(SCPCR);
    /* Clear out SCP7MD1,0, SCP4MD1,0,
       Set SCP6MD1,0 = {01} (output)  */
    p4_outw(SCPCR, (data&0x0fcf)|0x1000);

    data = p4_inb(SCPDR);
    /* Set /RTS2 (bit6) = 0 */
    p4_outb(SCPDR, data&0xbf);
  }
#elif defined(__SH4__)
  p4_outw(SCSPTR, 0x0080); /* Set RTS = 1 */
#endif
  p4_out(SCFCR, 0x0000);        /* RTRG=00, TTRG=00 */
                                /* MCE=1,TFRST=0,RFRST=0,LOOP=0 */
#endif

  p4_outb(SCBRR, BPS_SETTING_VALUE);

  p4_outw(RFCR, 0xa400);                /* Refresh counter clear */
  while(p4_inw(RFCR) < WAIT_RFCR_COUNTER);

  p4_out(SCSCR, SCSCR_INIT);

#ifdef REMOTE_BREAK
#if defined(CONFIG_SCI)
  *IPRSCI=(*IPRSCI&0xff0f)|(0xf0);
#elif defined(CONFIG_SCIF)
  *IPRSCIF=(*IPRSCIF&0xff0f)|(0xf0);
#endif
#endif

}

static inline int
getDebugCharReady (void)
{
  unsigned short status;

  status = p4_in(SC_SR);
  if (status & ( SCI_PER | SCI_FER | SCI_ER | SCI_BRK))
    handleError ();

  return (status & SCI_RD_F);
}

char
getDebugChar (void)
{
  unsigned short status;
  char ch;

  while ( ! getDebugCharReady());

  ch = p4_inb(SC_RDR);
  status = p4_in(SC_SR);
  p4_out(SC_SR, SCI_RDRF_CLEAR);

  if (status & (SCI_PER | SCI_FER | SCI_ER | SCI_BRK))
    handleError ();

  return ch;
}

static inline int
putDebugCharReady (void)
{
  unsigned short status;

  status = p4_in(SC_SR);
  return (status & SCI_TD_E);
}

void
putDebugChar (char ch)
{

  while (!putDebugCharReady())
    ;

  p4_outb(SC_TDR, ch);
  p4_in(SC_SR);
  p4_out(SC_SR, SCI_TDRE_CLEAR);
}
