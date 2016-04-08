#include "config.h"
#ifdef CONFIG_LITTLE_ENDIAN
OUTPUT_FORMAT("elf32-shl", "elf32-shl", "elf32-shl")
#else
OUTPUT_FORMAT("elf32-sh", "elf32-sh", "elf32-sh")
#endif
OUTPUT_ARCH(sh)
#if defined(CONFIG_CQSH3)
#include "cqsh3.mem"
#elif defined(CONFIG_CQSH4)
#include "cqsh4.mem"
#elif defined(CONFIG_YAEGASHI)
#include "yaegashi.mem"
#elif defined(CONFIG_SESH3)
#include "sesh3.mem"
#elif defined(CONFIG_SESH4)
#include "sesh4.mem"
#elif defined(CONFIG_CARD_E09A)
#include "card-e09a.mem"
#elif defined(CONFIG_RSH3)
#include "rsh3.mem"
#elif defined(CONFIG_DVESH3)
#include "dvesh3.mem"	
#endif
SECTIONS
{
  .text :
  {
    __text = .			; 
    entry.o(.text)
    *(.text)
    *(.rodata)
  } > ROM
  . = ALIGN(4);
  __idata_start = .		; 
  .data : AT(__idata_start)
  {
    __data_start = .		; 
    *(.data)
  } > RAM
  . = ALIGN(4);	
    __idata_end = __idata_start + SIZEOF(.data);
   _edata = .			; 
  __bss_start = .;		/* BSS */
  .bss :
  {
    *(.bss)
    *(COMMON)
  } > RAM
  . = ALIGN(4);
  __bss_end = .;
  .stack   :
  {
    *(.stack)
  } > STACK
}
