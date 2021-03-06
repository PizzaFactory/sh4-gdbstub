/* $Id: sh-stub.c,v 1.3 2001/03/01 05:02:29 honda Exp $
 *
 * This file is originally developed at GNU/Linux on SuperH Project
 *
 * Modifications for the uITRON4.0 specification OS "TOPPERS" by Shinya Honda
 *
 */


/*
 * gdb-sh-stub/sh-stub.c -- debugging stub for the Hitachi-SH.
 * Based on sh-stub.c distributed with GDB-4.18.
 */


/*   This is originally based on an m68k software stub written by Glenn
     Engel at HP, but has changed quite a bit.

     Modifications for the SH by Ben Lee and Steve Chamberlain

*/

/****************************************************************************

                THIS SOFTWARE IS NOT COPYRIGHTED

   HP offers the following for use in the public domain.  HP makes no
   warranty with regard to the software or it's performance and the
   user accepts the software "AS IS" with all faults.

   HP DISCLAIMS ANY WARRANTIES, EXPRESS OR IMPLIED, WITH REGARD
   TO THIS SOFTWARE INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

****************************************************************************/


/* Remote communication protocol.

   A debug packet whose contents are <data>
   is encapsulated for transmission in the form:

        $ <data> # CSUM1 CSUM2

        <data> must be ASCII alphanumeric and cannot include characters
        '$' or '#'.  If <data> starts with two characters followed by
        ':', then the existing stubs interpret this as a sequence number.

        CSUM1 and CSUM2 are ascii hex representation of an 8-bit
        checksum of <data>, the most significant nibble is sent first.
        the hex digits 0-9,a-f are used.

   Receiver responds with:

        +       - if CSUM is correct and ready for next packet
        -       - if CSUM is incorrect

   <data> is as follows:
   All values are encoded in ascii hex digits.

        Request         Packet

        read registers  g
        reply           XX....X         Each byte of register data
                                        is described by two hex digits.
                                        Registers are in the internal order
                                        for GDB, and the bytes in a register
                                        are in the same order the machine uses.
                        or ENN          for an error.

        write regs      GXX..XX         Each byte of register data
                                        is described by two hex digits.
        reply           OK              for success
                        ENN             for an error

        write reg       Pn...=r...      Write register n... with value r...,
                                        which contains two hex digits for each
                                        byte in the register (target byte
                                        order).
        reply           OK              for success
                        ENN             for an error
        (not supported by all stubs).

        read mem        mAA..AA,LLLL    AA..AA is address, LLLL is length.
        reply           XX..XX          XX..XX is mem contents
                                        Can be fewer bytes than requested
                                        if able to read only part of the data.
                        or ENN          NN is errno

        write mem       MAA..AA,LLLL:XX..XX
                                        AA..AA is address,
                                        LLLL is number of bytes,
                                        XX..XX is data
        reply           OK              for success
                        ENN             for an error (this includes the case
                                        where only part of the data was
                                        written).

        write mem       XAA..AA,LLLL:XX..XX
         (binary)                       AA..AA is address,
                                        LLLL is number of bytes,
                                        XX..XX is binary data
        reply           OK              for success
                        ENN             for an error

        cont            cAA..AA         AA..AA is address to resume
                                        If AA..AA is omitted,
                                        resume at same address.

        step            sAA..AA         AA..AA is address to resume
                                        If AA..AA is omitted,
                                        resume at same address.

        last signal     ?               Reply the current reason for stopping.
                                        This is the same reply as is generated
                                        for step or cont : SAA where AA is the
                                        signal number.

        There is no immediate reply to step or cont.
        The reply comes when the machine stops.
        It is           SAA             AA is the "signal number"

        or...           TAAn...:r...;n:r...;n...:r...;
                                        AA = signal number
                                        n... = register number
                                        r... = register contents
        or...           WAA             The process exited, and AA is
                                        the exit status.  This is only
                                        applicable for certains sorts of
                                        targets.
        kill request    k

        toggle debug    d               toggle debug flag (see 386 & 68k stubs)
        reset           r               reset -- see sparc stub.
        reserved        <other>         On other requests, the stub should
                                        ignore the request and send an empty
                                        response ($#<checksum>).  This way
                                        we can extend the protocol and GDB
                                        can tell whether the stub it is
                                        talking to uses the old or the new.
        search          tAA:PP,MM       Search backwards starting at address
                                        AA for a match with pattern PP and
                                        mask MM.  PP and MM are 4 bytes.
                                        Not supported by all stubs.

        general query   qXXXX           Request info about XXXX.
        general set     QXXXX=yyyy      Set value of XXXX to yyyy.
        query sect offs qOffsets        Get section offsets.  Reply is
                                        Text=xxx;Data=yyy;Bss=zzz
        console output  Otext           Send text to stdout.  Only comes from
                                        remote target.

        Responses can be run-length encoded to save space.  A '*' means that
        the next character is an ASCII encoding giving a repeat count which
        stands for that many repititions of the character preceding the '*'.
        The encoding is n+29, yielding a printable character where n >=3
        (which is where rle starts to win).  Don't use an n > 126.

        So
        "0* " means the same as "0000".  */

#include "string.h"
#include "setjmp.h"

#define COND_BR_MASK            0xff00
#define UCOND_DBR_MASK          0xe000
#define UCOND_RBR_MASK          0xf0df
#define TRAPA_MASK              0xff00

#define COND_DISP               0x00ff
#define UCOND_DISP              0x0fff
#define UCOND_REG               0x0f00

#define BF_INSTR                0x8b00
#define BT_INSTR                0x8900
#define BFS_INSTR               0x8f00
#define BTS_INSTR               0x8d00
#define BRA_INSTR               0xa000
#define BRAF_INSTR              0x0023
#define BSRF_INSTR              0x0003
#define BSR_INSTR               0xb000
#define JMP_INSTR               0x402b
#define JSR_INSTR               0x400b
#define RTS_INSTR               0x000b
#define RTE_INSTR               0x002b
#define TRAPA_INSTR             0xc300

#define SSTEP_INSTR             0xc320

#define BIOS_CALL_TRAP          0x3f

#define T_BIT_MASK              0x0001
/*
 * BUFMAX defines the maximum number of characters in inbound/outbound
 * buffers at least NUMREGBYTES*2 are needed for register packets
 */
#define BUFMAX 1024

/*
 * Number of bytes for registers
 */
#define NUMREGBYTES 92

extern void putDebugChar (char);
extern char getDebugChar (void);
extern int exception_handling_table[];

/*
 * Forward declarations
 */
static int hex (char);
static char *mem2hex (char *, char *, int);
static char *hex2mem (char *, char *, int);
static char *ebin2mem (char *, char *, int);
static int hexToInt (char **, int *);
static void getpacket (char *);
static void putpacket (char *);
static int computeSignal (int exceptionVector);

static void handle_bios_call (void);

/*
  Runs at P2 Area

  VBR = 0xa0000000

  ROM:
   0xa0000000 ---> [ .text  ]

  RAM:
                [ .data  ]  <-------   RAM = 0xa8000000
                [ .bss   ]
init_stack ---> [ .stack ]  RAM+0x0a00
                    :
                [        ]
                [        ]  RAM+0x0eff <--- init_sp (= initial R15)
stub_stack ---> [ .stack ]  RAM+0x0F00
                    :
                [        ]
                [        ]  RAM+0x1000 <--- stub_sp (= stub R15)
 */

#define stub_stack_size 64
#define init_stack_size 320
static int init_stack[init_stack_size]
        __attribute__ ((section (".stack"))) = {0};
int stub_stack[stub_stack_size]
        __attribute__ ((section (".stack"))) = {0};

/* When you link take care that this is at address 0 -
   or wherever your vbr points */

#define ADDRESS_ERROR_LOAD_VEC   7
#define ADDRESS_ERROR_STORE_VEC  8
#define TRAP_VEC                11
#define INVALID_INSN_VEC        12
#define INVALID_SLOT_VEC        13
#define NMI_VEC                 14
#define USER_BREAK_VEC          15
#define SERIAL_BREAK_VEC        58

char in_nmi;   /* Set when handling an NMI, so we don't reenter */
int dofault;   /* Non zero, bus errors will raise exception */
int exception;

int *stub_sp;

/* debug > 0 prints ill-formed commands in valid packets & checksum errors */
static int remote_debug;

/* jump buffer used for setjmp/longjmp */
static jmp_buf remcomEnv;

enum regnames
{
  R0,  R1, R2,  R3,  R4,   R5,   R6,  R7,
  R8,  R9, R10, R11, R12,  R13,  R14, R15,
  PC,  PR, GBR, VBR, MACH, MACL, SR,
};

typedef struct
{
  short *memAddr;
  short oldInstr;
} stepData;

unsigned int registers[NUMREGBYTES / 4];
static stepData instrBuffer;
static char stepped;
static const char hexchars[] = "0123456789abcdef";
static char remcomInBuffer[BUFMAX];
static char remcomOutBuffer[BUFMAX];

static char highhex(int  x)
{
  return hexchars[(x >> 4) & 0xf];
}

static char lowhex(int  x)
{
  return hexchars[x & 0xf];
}

/*
 * Routines to handle hex data
 */

static int
hex (char ch)
{
  if ((ch >= 'a') && (ch <= 'f'))
    return (ch - 'a' + 10);
  if ((ch >= '0') && (ch <= '9'))
    return (ch - '0');
  if ((ch >= 'A') && (ch <= 'F'))
    return (ch - 'A' + 10);
  return (-1);
}

/* convert the memory, pointed to by mem into hex, placing result in buf */
/* return a pointer to the last char put in buf (null) */
static char *
mem2hex (char *mem, char *buf, int count)
{
  int i;
  int ch;
  for (i = 0; i < count; i++)
    {
      ch = *mem++;
      *buf++ = highhex (ch);
      *buf++ = lowhex (ch);
    }
  *buf = 0;
  return (buf);
}

/* convert the hex array pointed to by buf into binary, to be placed in mem */
/* return a pointer to the character after the last byte written */

static char *
hex2mem (char *buf, char *mem, int count)
{
  int i;
  unsigned char ch;
  for (i = 0; i < count; i++)
    {
      ch = hex (*buf++) << 4;
      ch = ch + hex (*buf++);
      *mem++ = ch;
    }
  return (mem);
}

/*
 * Convert the escaped-binary array pointed to by buf into binary, to
 * be placed in mem. Return a pointer to the character after the last
 * byte written.
 */

static char *
ebin2mem (char *buf, char *mem, int count)
{
  for ( ; count>0 ; count--, buf++)
    {
      if (*buf == 0x7d)
        *mem++ = *(++buf) ^ 0x20;
      else
        *mem++ = *buf;
    }
  return (mem);
}

/**********************************************/
/* WHILE WE FIND NICE HEX CHARS, BUILD AN INT */
/* RETURN NUMBER OF CHARS PROCESSED           */
/**********************************************/
static int
hexToInt (char **ptr, int *intValue)
{
  int numChars = 0;
  int hexValue;

  *intValue = 0;

  while (**ptr)
    {
      hexValue = hex (**ptr);
      if (hexValue >= 0)
        {
          *intValue = (*intValue << 4) | hexValue;
          numChars++;
        }
      else
        break;

      (*ptr)++;
    }

  return (numChars);
}

/*
 * Routines to get and put packets
 */

/* scan for the sequence $<data>#<checksum>     */

static void
getpacket (char *buffer)
{
  unsigned char checksum;
  unsigned char xmitcsum;
  int i;
  int count;
  char ch;
  do
    {
      /* wait around for the start character, ignore all other characters */
      while ((ch = getDebugChar ()) != '$');
      checksum = 0;
      xmitcsum = -1;

      count = 0;

      /* now, read until a # or end of buffer is found */
      while (count < BUFMAX)
        {
          ch = getDebugChar ();
          if (ch == '#')
            break;
          checksum = checksum + ch;
          buffer[count] = ch;
          count = count + 1;
        }
      buffer[count] = 0;

      if (ch == '#')
        {
          xmitcsum = hex (getDebugChar ()) << 4;
          xmitcsum += hex (getDebugChar ());
          if (checksum != xmitcsum)
            putDebugChar ('-'); /* failed checksum */
          else
            {
              putDebugChar ('+');       /* successful transfer */
              /* if a sequence char is present, reply the sequence ID */
              if (buffer[2] == ':')
                {
                  putDebugChar (buffer[0]);
                  putDebugChar (buffer[1]);
                  /* remove sequence chars from buffer */
                  count = strlen (buffer);
                  for (i = 3; i <= count; i++)
                    buffer[i - 3] = buffer[i];
                }
            }
        }
    }
  while (checksum != xmitcsum);

}


/* send the packet in buffer.  The host get's one chance to read it.
   This routine does not wait for a positive acknowledge.  */

static void
putpacket (register char *buffer)
{
  register  int checksum;
  register  int count;

  /*  $<packet info>#<checksum>. */
  do
    {
      char *src = buffer;
      putDebugChar ('$');
      checksum = 0;

      while (*src)
        {
          int runlen;

          /* Do run length encoding */
          for (runlen = 0; runlen < 100; runlen ++)
            {
              if (src[0] != src[runlen] || runlen == 99)
                {
                  if (runlen > 3)
                    {
                      int encode;
                      /* Got a useful amount */
                      putDebugChar (*src);
                      checksum += *src;
                      putDebugChar ('*');
                      checksum += '*';
                      checksum += (encode = runlen + ' ' - 4);
                      putDebugChar (encode);
                      src += runlen;
                    }
                  else
                    {
                      putDebugChar (*src);
                      checksum += *src;
                      src++;
                    }
                  break;
                }
            }
        }


      putDebugChar ('#');
      putDebugChar (highhex(checksum));
      putDebugChar (lowhex(checksum));
    }
  while  (getDebugChar() != '+');

}


/* a bus error has occurred, perform a longjmp
   to return execution and allow handling of the error */

void
handle_buserror (void)
{
  longjmp (remcomEnv, 1);
}

/*
 * this function takes the SH-3/SH-4 exception number and attempts to
 * translate this number into a unix compatible signal value
 */
static int
computeSignal (int exceptionVector)
{
  int sigval;
  switch (exceptionVector)
    {
    case INVALID_INSN_VEC:
    case INVALID_SLOT_VEC:
      sigval = 4;               /* SIGILL */
      break;
    case ADDRESS_ERROR_LOAD_VEC:
    case ADDRESS_ERROR_STORE_VEC:
      sigval = 10;              /* SIGSEGV is 11???*/
      break;

    case SERIAL_BREAK_VEC:
    case NMI_VEC:
      sigval = 2;               /* SIGINT */
      break;

    case USER_BREAK_VEC:
    case TRAP_VEC:
      sigval = 5;               /* SIGTRAP */
      break;

    default:
      sigval = 7;               /* SIGBUS, "software generated" */
      break;
    }
  return (sigval);
}

static inline unsigned int ctrl_inl(unsigned long addr)
{
        return *(volatile unsigned long*)addr;
}

#if defined(__sh3__)
#define flush_icache_range(start,end)   do {} while(0)
#elif defined(__SH4__)

#if 0
#define L1_CACHE_BYTES 32
#define CACHE_IC_ADDRESS_ARRAY  0xf0000000
#define CACHE_IC_ENTRY_MASK     0x1fe0

struct __large_struct { unsigned long buf[100]; };
#define __m(x) (*(struct __large_struct *)(x))

static inline void ctrl_outl(unsigned int b, unsigned long addr)
{
        *(volatile unsigned long*)addr = b;
}
static inline unsigned int ctrl_in(unsigned long addr)
{
        return *(volatile unsigned long*)addr;
}

/* Write back data caches, and invalidates instructiin caches */
void flush_icache_range(unsigned long start, unsigned long end)
{
        unsigned long addr, data, v;

        start &= ~(L1_CACHE_BYTES-1);

        for (v = start; v < end; v+=L1_CACHE_BYTES) {
                /* Write back O Cache */
                asm volatile("ocbwb     %0"
                             : /* no output */
                             : "m" (__m(v)));
                /* Invalidate I Cache */
                addr = CACHE_IC_ADDRESS_ARRAY |
                        (v&CACHE_IC_ENTRY_MASK) | 0x8 /* A-bit */;
                data = (v&0xfffffc00); /* Valid=0 */
                ctrl_outl(data,addr);
        }
}
#else
/*
   Breakpoints設定がIC/OCの影響で有効とならないため
   デバッグ対象のプログラムでもCCRのICE/OCEを無効とすること
 */
#define flush_icache_range(start,end)   do {} while(0)
#endif

#endif

static void
doSStep (void)
{
  short *instrMem;
  int displacement;
  int reg;
  unsigned short opcode;

  instrMem = (short *) registers[PC];

  opcode = *instrMem;
  stepped = 1;

  if ((opcode & COND_BR_MASK) == BT_INSTR) /* BT */
    {
      if (registers[SR] & T_BIT_MASK)
        {
          displacement = (opcode & COND_DISP) << 1;
          if (displacement & 0x80)
            displacement |= 0xffffff00;
          /*
                   * Remember PC points to second instr.
                   * after PC of branch ... so add 4
                   */
          instrMem = (short *) (registers[PC] + displacement + 4);
        }
      else
        instrMem += 1;
    }
  else if ((opcode & COND_BR_MASK) == BF_INSTR) /* BF */
    {
      if (registers[SR] & T_BIT_MASK)
        instrMem += 1;
      else
        {
          displacement = (opcode & COND_DISP) << 1;
          if (displacement & 0x80)
            displacement |= 0xffffff00;
          /*
                   * Remember PC points to second instr.
                   * after PC of branch ... so add 4
                   */
          instrMem = (short *) (registers[PC] + displacement + 4);
        }
    }
  else if ((opcode & COND_BR_MASK) == BTS_INSTR) /* BTS */
    {
      if (registers[SR] & T_BIT_MASK)
        {
          displacement = (opcode & COND_DISP) << 1;
          if (displacement & 0x80)
            displacement |= 0xffffff00;
          /*
                   * Remember PC points to second instr.
                   * after PC of branch ... so add 4
                   */
          instrMem = (short *) (registers[PC] + displacement + 4);
        }
      else
        instrMem += 2;          /* We should not place trapa at the slot */
    }
  else if ((opcode & COND_BR_MASK) == BFS_INSTR) /* BFS */
    {
      if (registers[SR] & T_BIT_MASK)
        instrMem += 2;          /* We should not place trapa at the slot */
      else
        {
          displacement = (opcode & COND_DISP) << 1;
          if (displacement & 0x80)
            displacement |= 0xffffff00;
          /*
                   * Remember PC points to second instr.
                   * after PC of branch ... so add 4
                   */
          instrMem = (short *) (registers[PC] + displacement + 4);
        }
    }
  else if ((opcode & UCOND_DBR_MASK) == BRA_INSTR) /* BRA/BSR */
    {
      displacement = (opcode & UCOND_DISP) << 1;
      if (displacement & 0x0800)
        displacement |= 0xfffff000;

      /*
           * Remember PC points to second instr.
           * after PC of branch ... so add 4
           */
      instrMem = (short *) (registers[PC] + displacement + 4);
    }
  else if ((opcode & UCOND_RBR_MASK) == JSR_INSTR) /* JMP/JSR */
    {
      reg = (char) ((opcode & UCOND_REG) >> 8);

      instrMem = (short *) registers[reg];
    }
  else if ((opcode & UCOND_RBR_MASK) == BSRF_INSTR) /* BRAF/BSRF */
    {
      reg = (char) ((opcode & UCOND_REG) >> 8);

      instrMem = (short *) (registers[reg] + (registers[PC]&0xfffffffc) + 4);
    }
  else if (opcode == RTS_INSTR)
    instrMem = (short *) registers[PR];
  else if (opcode == RTE_INSTR)
    instrMem = (short *) registers[15];
#if 0                           /* following code is for SH-1 */
  else if ((opcode & TRAPA_MASK) == TRAPA_INSTR)
    instrMem = (short *) ((opcode & ~TRAPA_MASK) << 2);
#endif
  else
    instrMem += 1;

  instrBuffer.memAddr = instrMem;
  instrBuffer.oldInstr = *instrMem;
  *instrMem = SSTEP_INSTR;
  flush_icache_range((unsigned long)instrMem, (unsigned long)(instrMem+1));
}

/* Undo the effect of a previous doSStep.  If we single stepped,
   restore the old instruction. */

static void
undoSStep (void)
{
  if (stepped)
    {  short *instrMem;
      instrMem = instrBuffer.memAddr;
      *instrMem = instrBuffer.oldInstr;
      flush_icache_range((unsigned long)instrMem, (unsigned long)(instrMem+1));
    }
  stepped = 0;
}

/*
This function does all exception handling.  It only does two things -
it figures out why it was called and tells gdb, and then it reacts
to gdb's requests.

When in the monitor mode we talk a human on the serial line rather than gdb.

*/

#if 0
#define EXCARRAY_SZ 1024
char excArray[EXCARRAY_SZ];
int excArrayIdx=0;
#endif

static void
gdb_handle_exception (int exceptionVector, int trapa_value)
{
  int sigval;
  int addr, length;
  char *ptr;

  /* reply to host that an exception has occurred */
  sigval = computeSignal (exceptionVector);
  remcomOutBuffer[0] = 'S';
  remcomOutBuffer[1] = highhex(sigval);
  remcomOutBuffer[2] = lowhex (sigval);
  remcomOutBuffer[3] = 0;

  putpacket (remcomOutBuffer);

  /*
   * TRAP_VEC exception indicates a software trap
   * inserted in place of code ... so back up
   * PC by one instruction, since this instruction
   * will later be replaced by its original one!
   */
  /*
   * step及びgdb側からのbreakの場合はPCを元に戻す。
   * 0x20を変更するためには、gdb-4.18/gdb/config/sh/tm-sh.hの
   * #define BIG_REMOTE_BREAKPOINT    { 0xc3, 0x20 }
   * #define LITTLE_REMOTE_BREAKPOINT { 0x20, 0xc3 }
   * を変更する必要がある。
   */
  if (exceptionVector == TRAP_VEC && trapa_value != (0xff<<2))
    registers[PC] -= 2;

  /*
   * Do the thangs needed to undo
   * any stepping we may have done!
   */
  undoSStep ();

  while (1)
    {
      remcomOutBuffer[0] = 0;
      getpacket (remcomInBuffer);

      #if 0
      {
        int i=0;
        do
        {
            excArray[excArrayIdx]=remcomInBuffer[i];
            excArrayIdx++;
            if(excArrayIdx>=EXCARRAY_SZ)
              excArrayIdx=0;
        }
        while(remcomInBuffer[i++]);
      }
      #endif

      switch (remcomInBuffer[0])
        {
        case '?':
          remcomOutBuffer[0] = 'S';
          remcomOutBuffer[1] = highhex (sigval);
          remcomOutBuffer[2] = lowhex (sigval);
          remcomOutBuffer[3] = 0;
          break;
        case 'd':
          remote_debug = !(remote_debug);       /* toggle debug flag */
          break;
        case 'g':               /* return the value of the CPU registers */
          mem2hex ((char *) registers, remcomOutBuffer, NUMREGBYTES);
          break;
        case 'G':               /* set the value of the CPU registers - return OK */
          hex2mem (&remcomInBuffer[1], (char *) registers, NUMREGBYTES);
          strcpy (remcomOutBuffer, "OK");
          break;

          /* mAA..AA,LLLL  Read LLLL bytes at address AA..AA */
        case 'm':
          if (setjmp (remcomEnv) == 0)
            {
              dofault = 0;
              /* TRY, TO READ %x,%x.  IF SUCCEED, SET PTR = 0 */
              ptr = &remcomInBuffer[1];
              if (hexToInt (&ptr, &addr))
                if (*(ptr++) == ',')
                  if (hexToInt (&ptr, &length))
                    {
                      ptr = 0;
                      mem2hex ((char *) addr, remcomOutBuffer, length);
                    }
              if (ptr)
                strcpy (remcomOutBuffer, "E01");
            }
          else
            strcpy (remcomOutBuffer, "E03");

          /* restore handler for bus error */
          dofault = 1;
          break;

          /* MAA..AA,LLLL: Write LLLL bytes (encoded hex) at address AA.AA return OK */
          /* XAA..AA,LLLL: Write LLLL bytes (encoded escaped-binary) at address AA.AA return OK */
        case 'M':
        case 'X':
          if (setjmp (remcomEnv) == 0)
            {
              dofault = 0;

              /* TRY, TO READ '%x,%x:'.  IF SUCCEED, SET PTR = 0 */
              ptr = &remcomInBuffer[1];
              if (hexToInt (&ptr, &addr))
                if (*(ptr++) == ',')
                  if (hexToInt (&ptr, &length))
                    if (*(ptr++) == ':')
                      {
                        if (remcomInBuffer[0] == 'M')
                            hex2mem (ptr, (char *) addr, length);
                        else
                            ebin2mem (ptr, (char *) addr, length);
                        ptr = 0;
                        strcpy (remcomOutBuffer, "OK");
                      }
              if (ptr)
                strcpy (remcomOutBuffer, "E02");
            }
          else
            strcpy (remcomOutBuffer, "E03");

          /* restore handler for bus error */
          dofault = 1;
          break;

          /* cAA..AA    Continue at address AA..AA(optional) */
          /* sAA..AA    Step one instruction from AA..AA(optional) */
        case 'c':
        case 's':
          {
            /* tRY, to read optional parameter, pc unchanged if no parm */
            ptr = &remcomInBuffer[1];
            if (hexToInt (&ptr, &addr))
              registers[PC] = addr;

            if (remcomInBuffer[0] == 's')
              doSStep ();
          }
          return;
          break;

          /* CSS[:AA..AA] Continue with signal SS at address AA..AA(optional) */
          /* SSS[:AA..AA] Step with signal SS at address AA..AA(optional) */
        case 'C':
        case 'S':
          {
            /* tRY, to read optional parameter, pc unchanged if no parm */
            int i;
            for(i = 1
              ;
              ; i++)
            {
              if(remcomInBuffer[i] == 0
              || remcomInBuffer[i] == ':')
              {
                break;
              }
            }
            ptr = &remcomInBuffer[i];
            if (hexToInt (&ptr, &addr))
              registers[PC] = addr;

            if (remcomInBuffer[0] == 'S')
              doSStep ();
          }
          return;
          break;

          /* kill the program */
        case 'k':               /* do nothing */
          break;
        }                       /* switch */

      /* reply to the request */
      putpacket (remcomOutBuffer);
    }
}

#if defined(__sh3__)
#define TRA 0xffffffd0
#elif defined(__SH4__)
#define TRA 0xff000020
#endif

static int ingdbmode;

/* We've had an exception - choose to go into the monitor or
   the gdb stub */
void handle_exception(int exceptionVector)
{
  int trapa_value = ctrl_inl(TRA);

  if(exceptionVector == TRAP_VEC && (trapa_value >> 2) == BIOS_CALL_TRAP ){
      handle_bios_call ();
      return;
  }


  ingdbmode = 1;
  gdb_handle_exception (exceptionVector, trapa_value);
}

/* This function will generate a breakpoint exception.  It is used at the
   beginning of a program to sync up with a debugger and can be used
   otherwise as a quick means to stop program execution and "break" into
   the debugger. */

void
breakpoint (void)
{
  asm volatile("trapa   #0xff");
}

void
start_gdbstub (void)
{
  in_nmi = 0;
  dofault = 1;
  stepped = 0;

  stub_sp = stub_stack + stub_stack_size;
  breakpoint ();

  while (1)
    ;
}

/*
   R0: Function Number
   R4-R7: Input Arguments
   R0: Return value
 */
static void
handle_bios_call (void)
{
  unsigned int func = registers[R0];
  unsigned int arg0 = registers[R4];
  unsigned int arg1 = registers[R5];
  unsigned int arg2 = registers[R6];
  unsigned int arg3 = registers[R7];
  unsigned int ret;

  switch (func)
    {
    case 0:
        /*
         *  gdbのconsoleへの出力
         *  breakを受け取ることなしにgcbに出力したい場合は、
         *  /gdb-4.18/gdb/remote.cに
         *  fputs_filtered (tb, gdb_stdout);
         *  +gdb_flush(gdb_stdout);
         *  を追加する。
         */
        if (ingdbmode)
        {
            remcomOutBuffer[0] = 'O';
            remcomOutBuffer[1] = highhex(arg0);
            remcomOutBuffer[2] = lowhex (arg0);
            remcomOutBuffer[3] = 0;
            putpacket (remcomOutBuffer);
        }
        else
        {
            int ch;
            char *p = (char *)arg0;

            while ((ch = *p++))
                putDebugChar (ch);
        }
        ret = 0;
        break;

    case 1:
      /* Second strage access */
      /* Not implemented yet */
      ret = ~0;
      break;
    case 8:
        /*
         * exception_handling_tableに登録する。
         * arg0のINVENT番号、arg1にアドレスを設定する
         */
        exception_handling_table[(arg0 >> 5)] = arg1;
        ret = 0;
        break;
    case 255:
      /* Detach gdb mode */
      ingdbmode = 0;
      putpacket ("W00");
      getDebugChar ();
      ret = 0;
      break;

    default:
      /* Do nothing */
      ret = ~0;
      break;
    }

  registers[R0] = ret;
}
