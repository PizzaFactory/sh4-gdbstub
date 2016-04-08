#ifndef __SETJMP_H
#define __SETJMP_H

#define _JBLEN 9
typedef	int jmp_buf[_JBLEN];

void	longjmp(jmp_buf __jmpb, int __retval);
int	setjmp(jmp_buf __jmpb);

#endif /* __SETJMP_H */
