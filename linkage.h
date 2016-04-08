/* $Id: linkage.h,v 1.1 2000/11/11 18:04:17 honda Exp $
 *
 * This file is originally developed at Linux SH project
 *		
 * Modifications for the uITRON4.0 specification OS "TOPPERS" by Shinya Honda
 *
 */
#ifndef __LINKAGE_H
#define __LINKAGE_H

#ifdef __cplusplus
#define CPP_ASMLINKAGE extern "C"
#else
#define CPP_ASMLINKAGE
#endif

#define asmlinkage CPP_ASMLINKAGE

#define STRINGIFY(X) #X
#define SYMBOL_NAME_STR(X) STRINGIFY(SYMBOL_NAME(X))
#ifdef __STDC__
#define SYMBOL_NAME(X) ##X
#define SYMBOL_NAME_LABEL(X) ##X##:
#else
#define SYMBOL_NAME(X) _/**/X
#define SYMBOL_NAME_LABEL(X) _/**/X/**/:
#endif
 
#define __ALIGN .balign 4
#define __ALIGN_STR ".balign 4"

#ifdef __ASSEMBLY__

#define ALIGN __ALIGN
#define ALIGN_STR __ALIGN_STR

#define ENTRY(name) \
  .globl SYMBOL_NAME(name); \
  ALIGN; \
  SYMBOL_NAME_LABEL(name);

#endif

#endif
