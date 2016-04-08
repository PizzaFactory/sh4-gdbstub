# $Id: Makefile,v 1.4 2001/03/09 04:55:48 honda Exp $
#
# gdb-sh-stub/Makefile
#

.S.o:
	$(CC) -D__ASSEMBLY__ $(AFLAGS) -traditional -c -o $*.o $<

include config.mk

CROSS_COMPILE= sh-hitachi-elf-

CC	=$(CROSS_COMPILE)gcc -I.
LD	=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

CFLAGS = -O2 -g

ifdef CONFIG_CPU_SH3
CFLAGS		+= -m3
AFLAGS		+= -m3
endif
ifdef CONFIG_CPU_SH4
CFLAGS		+= -m4
AFLAGS		+= -m4
endif

ifdef CONFIG_LITTLE_ENDIAN
CFLAGS		+= -ml
AFLAGS		+= -ml
LINKFLAGS	+= -EL
else
CFLAGS		+= -mb
AFLAGS		+= -mb
LINKFLAGS	+= -EB
endif

CFLAGS		+= -pipe
LINKSCRIPT    = sh-stub.lds
LINKFLAGS	+= -T $(word 1,$(LINKSCRIPT))


ADJUST_VMA=0x0


ifdef CONFIG_SESH3
MACHINE_DEPENDS :=	init_sesh3.o
all : sh-stub.src
endif

ifdef CONFIG_CARD_E09A
MACHINE_DEPENDS :=	init_card-e09a.o
endif

ifdef CONFIG_RSH3
MACHINE_DEPENDS :=	init_rsh3.o
endif

ifdef CONFIG_DVESH3
MACHINE_DEPENDS :=	init_dvesh3.o
endif

ifdef CONFIG_MS104SH4
MACHINE_DEPENDS :=	init_ms104sh4.o
all : sh-stub.src
endif




sh-stub.bin: sh-stub
	$(OBJCOPY) -S -R .stack -R .bss -R .comment -O binary \
		sh-stub sh-stub.bin


sh-stub.elf: sh-stub
	$(OBJCOPY) -S -R .data -R .stack -R .bss -R .comment \
		--adjust-vma=${ADJUST_VMA} \
		sh-stub sh-stub.elf

sh-stub.hex: sh-stub
	$(OBJCOPY) -S -R .data -R .stack -R .bss -R .comment \
		--adjust-vma=${ADJUST_VMA} -O ihex \
		sh-stub sh-stub.hex


sh-stub.src: sh-stub
	$(OBJCOPY) -S -R .stack -R .bss -R .comment \
	--adjust-vma=${ADJUST_VMA} -O srec \
    sh-stub sh-stub.src


sh-stub: sh-stub.o entry.o ${MACHINE_DEPENDS} sh-sci.o setjmp.o string.o sh-stub.lds
	$(LD) $(LINKFLAGS) entry.o sh-stub.o ${MACHINE_DEPENDS} sh-sci.o \
		setjmp.o string.o \
		-o sh-stub


sh-stub.lds: sh-stub.lds.S
	$(CC) -E -C -P -I. sh-stub.lds.S >sh-stub.lds

clean:
	rm -rf sh-stub sh-stub.bin sh-stub.elf *.o sh-stub.lds \
       sh-stub.src sh-stub.bin sh-stub.hex sh-stu.elf








