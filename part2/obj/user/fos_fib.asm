
obj/user/fos_fib:     file format elf32-i386

Disassembly of section .text:

00800020 <_start>:
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 8a 00 00 00       	call   8000c0 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <fib>:
#include <inc/lib.h>


int fib( int n)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
	if( n == 0 || n == 1)
  800040:	89 f0                	mov    %esi,%eax
  800042:	83 fe 01             	cmp    $0x1,%esi
  800045:	76 1c                	jbe    800063 <fib+0x2b>
		return n;
	return fib(n-1)+fib(n-2);
  800047:	83 ec 0c             	sub    $0xc,%esp
  80004a:	8d 46 ff             	lea    0xffffffff(%esi),%eax
  80004d:	50                   	push   %eax
  80004e:	e8 e5 ff ff ff       	call   800038 <fib>
  800053:	89 c3                	mov    %eax,%ebx
  800055:	8d 46 fe             	lea    0xfffffffe(%esi),%eax
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 d8 ff ff ff       	call   800038 <fib>
  800060:	8d 04 18             	lea    (%eax,%ebx,1),%eax
}
  800063:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800066:	5b                   	pop    %ebx
  800067:	5e                   	pop    %esi
  800068:	5d                   	pop    %ebp
  800069:	c3                   	ret    

0080006a <_main>:
void
_main(void)
{
  80006a:	55                   	push   %ebp
  80006b:	89 e5                	mov    %esp,%ebp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	83 ec 10             	sub    $0x10,%esp
	int n = 0;
	char c[10];
	while(  n != -1)
  800072:	8d 75 e8             	lea    0xffffffe8(%ebp),%esi
	{
		readline("Enter Fib Index (-1 for exit): ",c);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	56                   	push   %esi
  800079:	68 00 11 80 00       	push   $0x801100
  80007e:	e8 c5 05 00 00       	call   800648 <readline>
		n = strtol(c,NULL,10);
  800083:	83 c4 0c             	add    $0xc,%esp
  800086:	6a 0a                	push   $0xa
  800088:	6a 00                	push   $0x0
  80008a:	56                   	push   %esi
  80008b:	e8 0e 09 00 00       	call   80099e <strtol>
  800090:	89 c3                	mov    %eax,%ebx
		if( n == -1 )
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	83 f8 ff             	cmp    $0xffffffff,%eax
  800098:	74 1d                	je     8000b7 <_main+0x4d>
			break;
		//int *x = malloc(sizeof(int)*(n+2)) ;
		//int x[ 50 ];
		//cprintf("done");
		int i;
		//x[ 0 ]= 0; x[ 1 ] = 1;
		//for( i = 2 ; i<= n ; i++)
			//x[ i ] = x[ i -1 ] + x[ i-2 ];
		cprintf("Fib of %d = %d\n", n, fib(n));
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	50                   	push   %eax
  80009e:	e8 95 ff ff ff       	call   800038 <fib>
  8000a3:	83 c4 0c             	add    $0xc,%esp
  8000a6:	50                   	push   %eax
  8000a7:	53                   	push   %ebx
  8000a8:	68 20 11 80 00       	push   $0x801120
  8000ad:	e8 ee 00 00 00       	call   8001a0 <cprintf>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	eb be                	jmp    800075 <_main+0xb>
	}
}
  8000b7:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    
	...

008000c0 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000cc:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000d3:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d6:	85 c9                	test   %ecx,%ecx
  8000d8:	7e 07                	jle    8000e1 <libmain+0x21>
		binaryname = argv[0];
  8000da:	8b 02                	mov    (%edx),%eax
  8000dc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	52                   	push   %edx
  8000e5:	51                   	push   %ecx
  8000e6:	e8 7f ff ff ff       	call   80006a <_main>

	// exit gracefully
	//exit();
	sleep();
  8000eb:	e8 13 00 00 00       	call   800103 <sleep>
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    
	...

008000f4 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 44 0b 00 00       	call   800c45 <sys_env_destroy>
}
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <sleep>:

void
sleep(void)
{	
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800109:	e8 76 0b 00 00       	call   800c84 <sys_env_sleep>
}
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 04             	sub    $0x4,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 1a                	jne    800147 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	68 ff 00 00 00       	push   $0xff
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	50                   	push   %eax
  800139:	e8 ca 0a 00 00       	call   800c08 <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800144:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800147:	ff 43 04             	incl   0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 10 01 80 00       	push   $0x800110
  80017e:	e8 2d 01 00 00       	call   8002b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  80018c:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 70 0a 00 00       	call   800c08 <sys_cputs>

	return b.cnt;
  800198:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ce:	39 d7                	cmp    %edx,%edi
  8001d0:	72 39                	jb     80020b <printnum+0x57>
  8001d2:	77 04                	ja     8001d8 <printnum+0x24>
  8001d4:	39 c6                	cmp    %eax,%esi
  8001d6:	72 33                	jb     80020b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 20             	pushl  0x20(%ebp)
  8001de:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ed:	52                   	push   %edx
  8001ee:	50                   	push   %eax
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	e8 ca 0b 00 00       	call   800dc0 <__udivdi3>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	52                   	push   %edx
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 ae ff ff ff       	call   8001b4 <printnum>
  800206:	83 c4 20             	add    $0x20,%esp
  800209:	eb 19                	jmp    800224 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020b:	4b                   	dec    %ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7e 14                	jle    800224 <printnum+0x70>
			putch(padc, putdat);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	ff 75 0c             	pushl  0xc(%ebp)
  800216:	ff 75 20             	pushl  0x20(%ebp)
  800219:	ff 55 08             	call   *0x8(%ebp)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	4b                   	dec    %ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ec                	jg     800210 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	ff 75 0c             	pushl  0xc(%ebp)
  80022a:	8b 45 18             	mov    0x18(%ebp),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
  800232:	83 ec 04             	sub    $0x4,%esp
  800235:	52                   	push   %edx
  800236:	50                   	push   %eax
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	e8 c2 0c 00 00       	call   800f00 <__umoddi3>
  80023e:	83 c4 14             	add    $0x14,%esp
  800241:	0f be 80 b0 11 80 00 	movsbl 0x8011b0(%eax),%eax
  800248:	50                   	push   %eax
  800249:	ff 55 08             	call   *0x8(%ebp)
}
  80024c:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80025d:	83 f8 01             	cmp    $0x1,%eax
  800260:	7e 0f                	jle    800271 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800262:	8b 01                	mov    (%ecx),%eax
  800264:	83 c0 08             	add    $0x8,%eax
  800267:	89 01                	mov    %eax,(%ecx)
  800269:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80026c:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80026f:	eb 0f                	jmp    800280 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800271:	8b 01                	mov    (%ecx),%eax
  800273:	83 c0 04             	add    $0x4,%eax
  800276:	89 01                	mov    %eax,(%ecx)
  800278:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80028b:	83 f8 01             	cmp    $0x1,%eax
  80028e:	7e 0f                	jle    80029f <getint+0x1d>
		return va_arg(*ap, long long);
  800290:	8b 02                	mov    (%edx),%eax
  800292:	83 c0 08             	add    $0x8,%eax
  800295:	89 02                	mov    %eax,(%edx)
  800297:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80029a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80029d:	eb 0f                	jmp    8002ae <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	83 c0 04             	add    $0x4,%eax
  8002a4:	89 02                	mov    %eax,(%edx)
  8002a6:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002a9:	89 c2                	mov    %eax,%edx
  8002ab:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 1c             	sub    $0x1c,%esp
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c1:	8a 13                	mov    (%ebx),%dl
  8002c3:	43                   	inc    %ebx
  8002c4:	83 fa 25             	cmp    $0x25,%edx
  8002c7:	74 22                	je     8002eb <vprintfmt+0x3b>
			if (ch == '\0')
  8002c9:	85 d2                	test   %edx,%edx
  8002cb:	0f 84 cd 02 00 00    	je     80059e <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 0c             	pushl  0xc(%ebp)
  8002d7:	52                   	push   %edx
  8002d8:	ff 55 08             	call   *0x8(%ebp)
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	8a 13                	mov    (%ebx),%dl
  8002e5:	43                   	inc    %ebx
  8002e6:	83 fa 25             	cmp    $0x25,%edx
  8002e9:	75 de                	jne    8002c9 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002eb:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002ef:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002f6:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002fb:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800300:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	8a 13                	mov    (%ebx),%dl
  80030e:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800311:	43                   	inc    %ebx
  800312:	83 f8 55             	cmp    $0x55,%eax
  800315:	0f 87 5e 02 00 00    	ja     800579 <vprintfmt+0x2c9>
  80031b:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800322:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800326:	eb df                	jmp    800307 <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  80032c:	eb d9                	jmp    800307 <vprintfmt+0x57>

		// width field
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032e:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800333:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800336:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  80033a:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800340:	83 f8 09             	cmp    $0x9,%eax
  800343:	77 27                	ja     80036c <vprintfmt+0xbc>
  800345:	43                   	inc    %ebx
  800346:	eb eb                	jmp    800333 <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800348:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80034c:	8b 45 14             	mov    0x14(%ebp),%eax
  80034f:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800352:	eb 18                	jmp    80036c <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  800354:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800358:	79 ad                	jns    800307 <vprintfmt+0x57>
				width = 0;
  80035a:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800361:	eb a4                	jmp    800307 <vprintfmt+0x57>

		case '#':
			altflag = 1;
  800363:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  80036a:	eb 9b                	jmp    800307 <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  80036c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800370:	79 95                	jns    800307 <vprintfmt+0x57>
				width = precision, precision = -1;
  800372:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800375:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80037a:	eb 8b                	jmp    800307 <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037c:	41                   	inc    %ecx
			goto reswitch;
  80037d:	eb 88                	jmp    800307 <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80038f:	e9 da 01 00 00       	jmp    80056e <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800394:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	79 02                	jns    8003a4 <vprintfmt+0xf4>
				err = -err;
  8003a2:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8003a4:	83 f8 07             	cmp    $0x7,%eax
  8003a7:	7f 0b                	jg     8003b4 <vprintfmt+0x104>
  8003a9:	8b 3c 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edi
  8003b0:	85 ff                	test   %edi,%edi
  8003b2:	75 08                	jne    8003bc <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  8003b4:	50                   	push   %eax
  8003b5:	68 c1 11 80 00       	push   $0x8011c1
  8003ba:	eb 06                	jmp    8003c2 <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  8003bc:	57                   	push   %edi
  8003bd:	68 ca 11 80 00       	push   $0x8011ca
  8003c2:	ff 75 0c             	pushl  0xc(%ebp)
  8003c5:	ff 75 08             	pushl  0x8(%ebp)
  8003c8:	e8 d9 01 00 00       	call   8005a6 <printfmt>
  8003cd:	e9 9f 01 00 00       	jmp    800571 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003dc:	85 ff                	test   %edi,%edi
  8003de:	75 05                	jne    8003e5 <vprintfmt+0x135>
				p = "(null)";
  8003e0:	bf cd 11 80 00       	mov    $0x8011cd,%edi
			if (width > 0 && padc != '-')
  8003e5:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003e9:	0f 9f c2             	setg   %dl
  8003ec:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003f0:	0f 95 c0             	setne  %al
  8003f3:	21 d0                	and    %edx,%eax
  8003f5:	a8 01                	test   $0x1,%al
  8003f7:	74 35                	je     80042e <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	56                   	push   %esi
  8003fd:	57                   	push   %edi
  8003fe:	e8 42 03 00 00       	call   800745 <strnlen>
  800403:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80040d:	7e 1f                	jle    80042e <vprintfmt+0x17e>
  80040f:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800413:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	ff 75 0c             	pushl  0xc(%ebp)
  80041c:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  80041f:	ff 55 08             	call   *0x8(%ebp)
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800428:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80042c:	7f e8                	jg     800416 <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042e:	0f be 17             	movsbl (%edi),%edx
  800431:	47                   	inc    %edi
  800432:	85 d2                	test   %edx,%edx
  800434:	74 3e                	je     800474 <vprintfmt+0x1c4>
  800436:	85 f6                	test   %esi,%esi
  800438:	78 03                	js     80043d <vprintfmt+0x18d>
  80043a:	4e                   	dec    %esi
  80043b:	78 37                	js     800474 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  80043d:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800441:	74 12                	je     800455 <vprintfmt+0x1a5>
  800443:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800446:	83 f8 5e             	cmp    $0x5e,%eax
  800449:	76 0a                	jbe    800455 <vprintfmt+0x1a5>
					putch('?', putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	ff 75 0c             	pushl  0xc(%ebp)
  800451:	6a 3f                	push   $0x3f
  800453:	eb 07                	jmp    80045c <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 0c             	pushl  0xc(%ebp)
  80045b:	52                   	push   %edx
  80045c:	ff 55 08             	call   *0x8(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800465:	0f be 17             	movsbl (%edi),%edx
  800468:	47                   	inc    %edi
  800469:	85 d2                	test   %edx,%edx
  80046b:	74 07                	je     800474 <vprintfmt+0x1c4>
  80046d:	85 f6                	test   %esi,%esi
  80046f:	78 cc                	js     80043d <vprintfmt+0x18d>
  800471:	4e                   	dec    %esi
  800472:	79 c9                	jns    80043d <vprintfmt+0x18d>
			for (; width > 0; width--)
  800474:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800478:	0f 8e 3e fe ff ff    	jle    8002bc <vprintfmt+0xc>
				putch(' ', putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 0c             	pushl  0xc(%ebp)
  800484:	6a 20                	push   $0x20
  800486:	ff 55 08             	call   *0x8(%ebp)
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80048f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800493:	7f e9                	jg     80047e <vprintfmt+0x1ce>
			break;
  800495:	e9 22 fe ff ff       	jmp    8002bc <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	51                   	push   %ecx
  80049e:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a1:	50                   	push   %eax
  8004a2:	e8 db fd ff ff       	call   800282 <getint>
  8004a7:	89 c6                	mov    %eax,%esi
  8004a9:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	79 15                	jns    8004c7 <vprintfmt+0x217>
				putch('-', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	6a 2d                	push   $0x2d
  8004ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004bd:	f7 de                	neg    %esi
  8004bf:	83 d7 00             	adc    $0x0,%edi
  8004c2:	f7 df                	neg    %edi
  8004c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004c7:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004cc:	eb 78                	jmp    800546 <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	51                   	push   %ecx
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8004d5:	50                   	push   %eax
  8004d6:	e8 79 fd ff ff       	call   800254 <getuint>
  8004db:	89 c6                	mov    %eax,%esi
  8004dd:	89 d7                	mov    %edx,%edi
			base = 10;
  8004df:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004e4:	eb 5d                	jmp    800543 <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ec:	6a 58                	push   $0x58
  8004ee:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	6a 58                	push   $0x58
  8004f9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004fc:	83 c4 08             	add    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	6a 58                	push   $0x58
  800504:	eb 68                	jmp    80056e <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	6a 30                	push   $0x30
  80050e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	6a 78                	push   $0x78
  800519:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80051c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800526:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  80052b:	eb 11                	jmp    80053e <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	51                   	push   %ecx
  800531:	8d 45 14             	lea    0x14(%ebp),%eax
  800534:	50                   	push   %eax
  800535:	e8 1a fd ff ff       	call   800254 <getuint>
  80053a:	89 c6                	mov    %eax,%esi
  80053c:	89 d7                	mov    %edx,%edi
			base = 16;
  80053e:	ba 10 00 00 00       	mov    $0x10,%edx
  800543:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800546:	83 ec 04             	sub    $0x4,%esp
  800549:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800551:	52                   	push   %edx
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 55 fc ff ff       	call   8001b4 <printnum>
			break;
  80055f:	83 c4 20             	add    $0x20,%esp
  800562:	e9 55 fd ff ff       	jmp    8002bc <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	ff 75 0c             	pushl  0xc(%ebp)
  80056d:	52                   	push   %edx
  80056e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	e9 43 fd ff ff       	jmp    8002bc <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	6a 25                	push   $0x25
  800581:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800584:	4b                   	dec    %ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80058c:	0f 84 2a fd ff ff    	je     8002bc <vprintfmt+0xc>
  800592:	4b                   	dec    %ebx
  800593:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800597:	75 f9                	jne    800592 <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800599:	e9 1e fd ff ff       	jmp    8002bc <vprintfmt+0xc>
		}
	}
}
  80059e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8005a1:	5b                   	pop    %ebx
  8005a2:	5e                   	pop    %esi
  8005a3:	5f                   	pop    %edi
  8005a4:	5d                   	pop    %ebp
  8005a5:	c3                   	ret    

008005a6 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005af:	50                   	push   %eax
  8005b0:	ff 75 10             	pushl  0x10(%ebp)
  8005b3:	ff 75 0c             	pushl  0xc(%ebp)
  8005b6:	ff 75 08             	pushl  0x8(%ebp)
  8005b9:	e8 f2 fc ff ff       	call   8002b0 <vprintfmt>
	va_end(ap);
}
  8005be:	c9                   	leave  
  8005bf:	c3                   	ret    

008005c0 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005c6:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005c9:	8b 0a                	mov    (%edx),%ecx
  8005cb:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005ce:	73 07                	jae    8005d7 <sprintputch+0x17>
		*b->buf++ = ch;
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	88 01                	mov    %al,(%ecx)
  8005d5:	ff 02                	incl   (%edx)
}
  8005d7:	5d                   	pop    %ebp
  8005d8:	c3                   	ret    

008005d9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	83 ec 18             	sub    $0x18,%esp
  8005df:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005e5:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005e8:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005ec:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005ef:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	0f 94 c2             	sete   %dl
  8005fb:	85 c9                	test   %ecx,%ecx
  8005fd:	0f 9e c0             	setle  %al
  800600:	09 d0                	or     %edx,%eax
  800602:	ba 03 00 00 00       	mov    $0x3,%edx
  800607:	a8 01                	test   $0x1,%al
  800609:	75 1d                	jne    800628 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80060b:	ff 75 14             	pushl  0x14(%ebp)
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  800614:	50                   	push   %eax
  800615:	68 c0 05 80 00       	push   $0x8005c0
  80061a:	e8 91 fc ff ff       	call   8002b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80061f:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800622:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800625:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  800628:	89 d0                	mov    %edx,%eax
  80062a:	c9                   	leave  
  80062b:	c3                   	ret    

0080062c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80062c:	55                   	push   %ebp
  80062d:	89 e5                	mov    %esp,%ebp
  80062f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800635:	50                   	push   %eax
  800636:	ff 75 10             	pushl  0x10(%ebp)
  800639:	ff 75 0c             	pushl  0xc(%ebp)
  80063c:	ff 75 08             	pushl  0x8(%ebp)
  80063f:	e8 95 ff ff ff       	call   8005d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800644:	c9                   	leave  
  800645:	c3                   	ret    
	...

00800648 <readline>:
#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	57                   	push   %edi
  80064c:	56                   	push   %esi
  80064d:	53                   	push   %ebx
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;
	
	if (prompt != NULL)
  800654:	85 c0                	test   %eax,%eax
  800656:	74 11                	je     800669 <readline+0x21>
		cprintf("%s", prompt);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	50                   	push   %eax
  80065c:	68 ca 11 80 00       	push   $0x8011ca
  800661:	e8 3a fb ff ff       	call   8001a0 <cprintf>
  800666:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
  800669:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);	
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	6a 00                	push   $0x0
  800673:	e8 36 07 00 00       	call   800dae <iscons>
  800678:	89 c7                	mov    %eax,%edi
	while (1) {
  80067a:	83 c4 10             	add    $0x10,%esp
		c = getchar();
  80067d:	e8 1f 07 00 00       	call   800da1 <getchar>
  800682:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800684:	85 c0                	test   %eax,%eax
  800686:	79 1c                	jns    8006a4 <readline+0x5c>
			if (c != -E_EOF)
  800688:	83 f8 07             	cmp    $0x7,%eax
  80068b:	0f 84 92 00 00 00    	je     800723 <readline+0xdb>
				cprintf("read error: %e\n", c);			
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	50                   	push   %eax
  800695:	68 58 13 80 00       	push   $0x801358
  80069a:	e8 01 fb ff ff       	call   8001a0 <cprintf>
  80069f:	83 c4 10             	add    $0x10,%esp
			return;
  8006a2:	eb 7f                	jmp    800723 <readline+0xdb>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8006a4:	83 f8 1f             	cmp    $0x1f,%eax
  8006a7:	0f 9f c2             	setg   %dl
  8006aa:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8006b0:	0f 9e c0             	setle  %al
  8006b3:	21 d0                	and    %edx,%eax
  8006b5:	a8 01                	test   $0x1,%al
  8006b7:	74 19                	je     8006d2 <readline+0x8a>
			if (echoing)
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	74 0c                	je     8006c9 <readline+0x81>
				cputchar(c);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	e8 c2 06 00 00       	call   800d88 <cputchar>
  8006c6:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8006c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cc:	88 1c 06             	mov    %bl,(%esi,%eax,1)
  8006cf:	46                   	inc    %esi
  8006d0:	eb ab                	jmp    80067d <readline+0x35>
		} else if (c == '\b' && i > 0) {
  8006d2:	83 fb 08             	cmp    $0x8,%ebx
  8006d5:	0f 94 c2             	sete   %dl
  8006d8:	85 f6                	test   %esi,%esi
  8006da:	0f 9f c0             	setg   %al
  8006dd:	21 d0                	and    %edx,%eax
  8006df:	a8 01                	test   $0x1,%al
  8006e1:	74 13                	je     8006f6 <readline+0xae>
			if (echoing)
  8006e3:	85 ff                	test   %edi,%edi
  8006e5:	74 0c                	je     8006f3 <readline+0xab>
				cputchar(c);
  8006e7:	83 ec 0c             	sub    $0xc,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	e8 98 06 00 00       	call   800d88 <cputchar>
  8006f0:	83 c4 10             	add    $0x10,%esp
			i--;
  8006f3:	4e                   	dec    %esi
  8006f4:	eb 87                	jmp    80067d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
  8006f6:	83 fb 0a             	cmp    $0xa,%ebx
  8006f9:	0f 94 c2             	sete   %dl
  8006fc:	83 fb 0d             	cmp    $0xd,%ebx
  8006ff:	0f 94 c0             	sete   %al
  800702:	09 d0                	or     %edx,%eax
  800704:	a8 01                	test   $0x1,%al
  800706:	0f 84 71 ff ff ff    	je     80067d <readline+0x35>
			if (echoing)
  80070c:	85 ff                	test   %edi,%edi
  80070e:	74 0c                	je     80071c <readline+0xd4>
				cputchar(c);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	53                   	push   %ebx
  800714:	e8 6f 06 00 00       	call   800d88 <cputchar>
  800719:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
  80071c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071f:	c6 04 16 00          	movb   $0x0,(%esi,%edx,1)
			return;		
		}
	}
}
  800723:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    
	...

0080072c <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	80 3a 00             	cmpb   $0x0,(%edx)
  80073a:	74 07                	je     800743 <strlen+0x17>
		n++;
  80073c:	40                   	inc    %eax
  80073d:	42                   	inc    %edx
  80073e:	80 3a 00             	cmpb   $0x0,(%edx)
  800741:	75 f9                	jne    80073c <strlen+0x10>
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	85 d2                	test   %edx,%edx
  800755:	74 0f                	je     800766 <strnlen+0x21>
  800757:	80 39 00             	cmpb   $0x0,(%ecx)
  80075a:	74 0a                	je     800766 <strnlen+0x21>
		n++;
  80075c:	40                   	inc    %eax
  80075d:	41                   	inc    %ecx
  80075e:	4a                   	dec    %edx
  80075f:	74 05                	je     800766 <strnlen+0x21>
  800761:	80 39 00             	cmpb   $0x0,(%ecx)
  800764:	75 f6                	jne    80075c <strnlen+0x17>
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800772:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800774:	8a 02                	mov    (%edx),%al
  800776:	88 01                	mov    %al,(%ecx)
  800778:	42                   	inc    %edx
  800779:	41                   	inc    %ecx
  80077a:	84 c0                	test   %al,%al
  80077c:	75 f6                	jne    800774 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077e:	89 d8                	mov    %ebx,%eax
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	57                   	push   %edi
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078f:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  800792:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800794:	bb 00 00 00 00       	mov    $0x0,%ebx
  800799:	39 f3                	cmp    %esi,%ebx
  80079b:	73 17                	jae    8007b4 <strncpy+0x31>
		*dst++ = *src;
  80079d:	8a 02                	mov    (%edx),%al
  80079f:	88 01                	mov    %al,(%ecx)
  8007a1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8007a2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a5:	0f 95 c0             	setne  %al
  8007a8:	25 ff 00 00 00       	and    $0xff,%eax
  8007ad:	01 c2                	add    %eax,%edx
  8007af:	43                   	inc    %ebx
  8007b0:	39 f3                	cmp    %esi,%ebx
  8007b2:	72 e9                	jb     80079d <strncpy+0x1a>
			src++;
	}
	return ret;
}
  8007b4:	89 f8                	mov    %edi,%eax
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5f                   	pop    %edi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007c9:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 19                	je     8007e8 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8007cf:	4a                   	dec    %edx
  8007d0:	74 13                	je     8007e5 <strlcpy+0x2a>
  8007d2:	80 39 00             	cmpb   $0x0,(%ecx)
  8007d5:	74 0e                	je     8007e5 <strlcpy+0x2a>
			*dst++ = *src++;
  8007d7:	8a 01                	mov    (%ecx),%al
  8007d9:	88 03                	mov    %al,(%ebx)
  8007db:	41                   	inc    %ecx
  8007dc:	43                   	inc    %ebx
  8007dd:	4a                   	dec    %edx
  8007de:	74 05                	je     8007e5 <strlcpy+0x2a>
  8007e0:	80 39 00             	cmpb   $0x0,(%ecx)
  8007e3:	75 f2                	jne    8007d7 <strlcpy+0x1c>
		*dst = '\0';
  8007e5:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007e8:	89 d8                	mov    %ebx,%eax
  8007ea:	29 f0                	sub    %esi,%eax
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8007f9:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fc:	74 13                	je     800811 <strcmp+0x21>
  8007fe:	8a 02                	mov    (%edx),%al
  800800:	3a 01                	cmp    (%ecx),%al
  800802:	75 0d                	jne    800811 <strcmp+0x21>
		p++, q++;
  800804:	42                   	inc    %edx
  800805:	41                   	inc    %ecx
  800806:	80 3a 00             	cmpb   $0x0,(%edx)
  800809:	74 06                	je     800811 <strcmp+0x21>
  80080b:	8a 02                	mov    (%edx),%al
  80080d:	3a 01                	cmp    (%ecx),%al
  80080f:	74 f3                	je     800804 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	8a 02                	mov    (%edx),%al
  800818:	ba 00 00 00 00       	mov    $0x0,%edx
  80081d:	8a 11                	mov    (%ecx),%dl
  80081f:	29 d0                	sub    %edx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 55 08             	mov    0x8(%ebp),%edx
  80082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800830:	85 c9                	test   %ecx,%ecx
  800832:	74 1f                	je     800853 <strncmp+0x30>
  800834:	80 3a 00             	cmpb   $0x0,(%edx)
  800837:	74 16                	je     80084f <strncmp+0x2c>
  800839:	8a 02                	mov    (%edx),%al
  80083b:	3a 03                	cmp    (%ebx),%al
  80083d:	75 10                	jne    80084f <strncmp+0x2c>
		n--, p++, q++;
  80083f:	42                   	inc    %edx
  800840:	43                   	inc    %ebx
  800841:	49                   	dec    %ecx
  800842:	74 0f                	je     800853 <strncmp+0x30>
  800844:	80 3a 00             	cmpb   $0x0,(%edx)
  800847:	74 06                	je     80084f <strncmp+0x2c>
  800849:	8a 02                	mov    (%edx),%al
  80084b:	3a 03                	cmp    (%ebx),%al
  80084d:	74 f0                	je     80083f <strncmp+0x1c>
	if (n == 0)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 07                	jne    80085a <strncmp+0x37>
		return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 13                	jmp    80086d <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	8a 12                	mov    (%edx),%dl
  80085c:	81 e2 ff 00 00 00    	and    $0xff,%edx
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
  800867:	8a 03                	mov    (%ebx),%al
  800869:	29 c2                	sub    %eax,%edx
  80086b:	89 d0                	mov    %edx,%eax
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
  800876:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800879:	80 3a 00             	cmpb   $0x0,(%edx)
  80087c:	74 0c                	je     80088a <strchr+0x1a>
		if (*s == c)
  80087e:	89 d0                	mov    %edx,%eax
  800880:	38 0a                	cmp    %cl,(%edx)
  800882:	74 0b                	je     80088f <strchr+0x1f>
  800884:	42                   	inc    %edx
  800885:	80 3a 00             	cmpb   $0x0,(%edx)
  800888:	75 f4                	jne    80087e <strchr+0xe>
			return (char *) s;
	return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80089a:	80 38 00             	cmpb   $0x0,(%eax)
  80089d:	74 0a                	je     8008a9 <strfind+0x18>
		if (*s == c)
  80089f:	38 10                	cmp    %dl,(%eax)
  8008a1:	74 06                	je     8008a9 <strfind+0x18>
  8008a3:	40                   	inc    %eax
  8008a4:	80 38 00             	cmpb   $0x0,(%eax)
  8008a7:	75 f6                	jne    80089f <strfind+0xe>
			break;
	return (char *) s;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memset>:


void *
memset(void *v, int c, uint32 n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  8008b5:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  8008b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ba:	4a                   	dec    %edx
  8008bb:	78 06                	js     8008c3 <memset+0x18>
		*p++ = c;
  8008bd:	88 01                	mov    %al,(%ecx)
  8008bf:	41                   	inc    %ecx
  8008c0:	4a                   	dec    %edx
  8008c1:	79 fa                	jns    8008bd <memset+0x12>

	return v;
}
  8008c3:	89 d8                	mov    %ebx,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8008d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  8008d6:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  8008d8:	89 c8                	mov    %ecx,%eax
  8008da:	49                   	dec    %ecx
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	74 0d                	je     8008ec <memcpy+0x24>
		*d++ = *s++;
  8008df:	8a 03                	mov    (%ebx),%al
  8008e1:	88 02                	mov    %al,(%edx)
  8008e3:	43                   	inc    %ebx
  8008e4:	42                   	inc    %edx
  8008e5:	89 c8                	mov    %ecx,%eax
  8008e7:	49                   	dec    %ecx
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	75 f3                	jne    8008df <memcpy+0x17>

	return dst;
}
  8008ec:	89 f0                	mov    %esi,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  800900:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  800902:	39 f1                	cmp    %esi,%ecx
  800904:	73 22                	jae    800928 <memmove+0x36>
  800906:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  800909:	39 f0                	cmp    %esi,%eax
  80090b:	76 1b                	jbe    800928 <memmove+0x36>
		s += n;
  80090d:	89 c1                	mov    %eax,%ecx
		d += n;
  80090f:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  800912:	89 d0                	mov    %edx,%eax
  800914:	4a                   	dec    %edx
  800915:	85 c0                	test   %eax,%eax
  800917:	74 23                	je     80093c <memmove+0x4a>
			*--d = *--s;
  800919:	4b                   	dec    %ebx
  80091a:	49                   	dec    %ecx
  80091b:	8a 01                	mov    (%ecx),%al
  80091d:	88 03                	mov    %al,(%ebx)
  80091f:	89 d0                	mov    %edx,%eax
  800921:	4a                   	dec    %edx
  800922:	85 c0                	test   %eax,%eax
  800924:	75 f3                	jne    800919 <memmove+0x27>
  800926:	eb 14                	jmp    80093c <memmove+0x4a>
	} else
		while (n-- > 0)
  800928:	89 d0                	mov    %edx,%eax
  80092a:	4a                   	dec    %edx
  80092b:	85 c0                	test   %eax,%eax
  80092d:	74 0d                	je     80093c <memmove+0x4a>
			*d++ = *s++;
  80092f:	8a 01                	mov    (%ecx),%al
  800931:	88 03                	mov    %al,(%ebx)
  800933:	41                   	inc    %ecx
  800934:	43                   	inc    %ebx
  800935:	89 d0                	mov    %edx,%eax
  800937:	4a                   	dec    %edx
  800938:	85 c0                	test   %eax,%eax
  80093a:	75 f3                	jne    80092f <memmove+0x3d>

	return dst;
}
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  800949:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  80094c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80094f:	89 d0                	mov    %edx,%eax
  800951:	4a                   	dec    %edx
  800952:	85 c0                	test   %eax,%eax
  800954:	74 23                	je     800979 <memcmp+0x37>
		if (*s1 != *s2)
  800956:	8a 01                	mov    (%ecx),%al
  800958:	3a 03                	cmp    (%ebx),%al
  80095a:	74 14                	je     800970 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  80095c:	ba 00 00 00 00       	mov    $0x0,%edx
  800961:	8a 11                	mov    (%ecx),%dl
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
  800968:	8a 03                	mov    (%ebx),%al
  80096a:	29 c2                	sub    %eax,%edx
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	eb 0e                	jmp    80097e <memcmp+0x3c>
		s1++, s2++;
  800970:	41                   	inc    %ecx
  800971:	43                   	inc    %ebx
  800972:	89 d0                	mov    %edx,%eax
  800974:	4a                   	dec    %edx
  800975:	85 c0                	test   %eax,%eax
  800977:	75 dd                	jne    800956 <memcmp+0x14>
	}

	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098f:	39 d0                	cmp    %edx,%eax
  800991:	73 09                	jae    80099c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800993:	38 08                	cmp    %cl,(%eax)
  800995:	74 05                	je     80099c <memfind+0x1b>
  800997:	40                   	inc    %eax
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	72 f7                	jb     800993 <memfind+0x12>
			break;
	return (void *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	83 ec 04             	sub    $0x4,%esp
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  8009b0:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  8009b7:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bc:	80 39 20             	cmpb   $0x20,(%ecx)
  8009bf:	0f 94 c2             	sete   %dl
  8009c2:	80 39 09             	cmpb   $0x9,(%ecx)
  8009c5:	0f 94 c0             	sete   %al
  8009c8:	09 d0                	or     %edx,%eax
  8009ca:	a8 01                	test   $0x1,%al
  8009cc:	74 13                	je     8009e1 <strtol+0x43>
		s++;
  8009ce:	41                   	inc    %ecx
  8009cf:	80 39 20             	cmpb   $0x20,(%ecx)
  8009d2:	0f 94 c2             	sete   %dl
  8009d5:	80 39 09             	cmpb   $0x9,(%ecx)
  8009d8:	0f 94 c0             	sete   %al
  8009db:	09 d0                	or     %edx,%eax
  8009dd:	a8 01                	test   $0x1,%al
  8009df:	75 ed                	jne    8009ce <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  8009e1:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8009e4:	75 03                	jne    8009e9 <strtol+0x4b>
		s++;
  8009e6:	41                   	inc    %ecx
  8009e7:	eb 0d                	jmp    8009f6 <strtol+0x58>
	else if (*s == '-')
  8009e9:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8009ec:	75 08                	jne    8009f6 <strtol+0x58>
		s++, neg = 1;
  8009ee:	41                   	inc    %ecx
  8009ef:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f6:	85 db                	test   %ebx,%ebx
  8009f8:	0f 94 c2             	sete   %dl
  8009fb:	83 fb 10             	cmp    $0x10,%ebx
  8009fe:	0f 94 c0             	sete   %al
  800a01:	09 d0                	or     %edx,%eax
  800a03:	a8 01                	test   $0x1,%al
  800a05:	74 15                	je     800a1c <strtol+0x7e>
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 10                	jne    800a1c <strtol+0x7e>
  800a0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a10:	75 0a                	jne    800a1c <strtol+0x7e>
		s += 2, base = 16;
  800a12:	83 c1 02             	add    $0x2,%ecx
  800a15:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1a:	eb 1a                	jmp    800a36 <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	75 16                	jne    800a36 <strtol+0x98>
  800a20:	80 39 30             	cmpb   $0x30,(%ecx)
  800a23:	75 08                	jne    800a2d <strtol+0x8f>
		s++, base = 8;
  800a25:	41                   	inc    %ecx
  800a26:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a2b:	eb 09                	jmp    800a36 <strtol+0x98>
	else if (base == 0)
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	75 05                	jne    800a36 <strtol+0x98>
		base = 10;
  800a31:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a36:	8a 01                	mov    (%ecx),%al
  800a38:	83 e8 30             	sub    $0x30,%eax
  800a3b:	3c 09                	cmp    $0x9,%al
  800a3d:	77 08                	ja     800a47 <strtol+0xa9>
			dig = *s - '0';
  800a3f:	0f be 01             	movsbl (%ecx),%eax
  800a42:	83 e8 30             	sub    $0x30,%eax
  800a45:	eb 20                	jmp    800a67 <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800a47:	8a 01                	mov    (%ecx),%al
  800a49:	83 e8 61             	sub    $0x61,%eax
  800a4c:	3c 19                	cmp    $0x19,%al
  800a4e:	77 08                	ja     800a58 <strtol+0xba>
			dig = *s - 'a' + 10;
  800a50:	0f be 01             	movsbl (%ecx),%eax
  800a53:	83 e8 57             	sub    $0x57,%eax
  800a56:	eb 0f                	jmp    800a67 <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800a58:	8a 01                	mov    (%ecx),%al
  800a5a:	83 e8 41             	sub    $0x41,%eax
  800a5d:	3c 19                	cmp    $0x19,%al
  800a5f:	77 12                	ja     800a73 <strtol+0xd5>
			dig = *s - 'A' + 10;
  800a61:	0f be 01             	movsbl (%ecx),%eax
  800a64:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a67:	39 d8                	cmp    %ebx,%eax
  800a69:	7d 08                	jge    800a73 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a6b:	41                   	inc    %ecx
  800a6c:	0f af f3             	imul   %ebx,%esi
  800a6f:	01 c6                	add    %eax,%esi
  800a71:	eb c3                	jmp    800a36 <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a73:	85 ff                	test   %edi,%edi
  800a75:	74 02                	je     800a79 <strtol+0xdb>
		*endptr = (char *) s;
  800a77:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a79:	89 f0                	mov    %esi,%eax
  800a7b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a7f:	74 02                	je     800a83 <strtol+0xe5>
  800a81:	f7 d8                	neg    %eax
}
  800a83:	83 c4 04             	add    $0x4,%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 04             	sub    $0x4,%esp
  800a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a97:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800a9d:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800aa4:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	80 39 20             	cmpb   $0x20,(%ecx)
  800aac:	0f 94 c2             	sete   %dl
  800aaf:	80 39 09             	cmpb   $0x9,(%ecx)
  800ab2:	0f 94 c0             	sete   %al
  800ab5:	09 d0                	or     %edx,%eax
  800ab7:	a8 01                	test   $0x1,%al
  800ab9:	74 13                	je     800ace <strtoul+0x43>
		s++;
  800abb:	41                   	inc    %ecx
  800abc:	80 39 20             	cmpb   $0x20,(%ecx)
  800abf:	0f 94 c2             	sete   %dl
  800ac2:	80 39 09             	cmpb   $0x9,(%ecx)
  800ac5:	0f 94 c0             	sete   %al
  800ac8:	09 d0                	or     %edx,%eax
  800aca:	a8 01                	test   $0x1,%al
  800acc:	75 ed                	jne    800abb <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  800ace:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800ad1:	75 03                	jne    800ad6 <strtoul+0x4b>
		s++;
  800ad3:	41                   	inc    %ecx
  800ad4:	eb 0d                	jmp    800ae3 <strtoul+0x58>
	else if (*s == '-')
  800ad6:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800ad9:	75 08                	jne    800ae3 <strtoul+0x58>
		s++, neg = 1;
  800adb:	41                   	inc    %ecx
  800adc:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	0f 94 c2             	sete   %dl
  800ae8:	83 fb 10             	cmp    $0x10,%ebx
  800aeb:	0f 94 c0             	sete   %al
  800aee:	09 d0                	or     %edx,%eax
  800af0:	a8 01                	test   $0x1,%al
  800af2:	74 15                	je     800b09 <strtoul+0x7e>
  800af4:	80 39 30             	cmpb   $0x30,(%ecx)
  800af7:	75 10                	jne    800b09 <strtoul+0x7e>
  800af9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afd:	75 0a                	jne    800b09 <strtoul+0x7e>
		s += 2, base = 16;
  800aff:	83 c1 02             	add    $0x2,%ecx
  800b02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b07:	eb 1a                	jmp    800b23 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 16                	jne    800b23 <strtoul+0x98>
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	75 08                	jne    800b1a <strtoul+0x8f>
		s++, base = 8;
  800b12:	41                   	inc    %ecx
  800b13:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b18:	eb 09                	jmp    800b23 <strtoul+0x98>
	else if (base == 0)
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	75 05                	jne    800b23 <strtoul+0x98>
		base = 10;
  800b1e:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b23:	8a 01                	mov    (%ecx),%al
  800b25:	83 e8 30             	sub    $0x30,%eax
  800b28:	3c 09                	cmp    $0x9,%al
  800b2a:	77 08                	ja     800b34 <strtoul+0xa9>
			dig = *s - '0';
  800b2c:	0f be 01             	movsbl (%ecx),%eax
  800b2f:	83 e8 30             	sub    $0x30,%eax
  800b32:	eb 20                	jmp    800b54 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800b34:	8a 01                	mov    (%ecx),%al
  800b36:	83 e8 61             	sub    $0x61,%eax
  800b39:	3c 19                	cmp    $0x19,%al
  800b3b:	77 08                	ja     800b45 <strtoul+0xba>
			dig = *s - 'a' + 10;
  800b3d:	0f be 01             	movsbl (%ecx),%eax
  800b40:	83 e8 57             	sub    $0x57,%eax
  800b43:	eb 0f                	jmp    800b54 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800b45:	8a 01                	mov    (%ecx),%al
  800b47:	83 e8 41             	sub    $0x41,%eax
  800b4a:	3c 19                	cmp    $0x19,%al
  800b4c:	77 12                	ja     800b60 <strtoul+0xd5>
			dig = *s - 'A' + 10;
  800b4e:	0f be 01             	movsbl (%ecx),%eax
  800b51:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800b54:	39 d8                	cmp    %ebx,%eax
  800b56:	7d 08                	jge    800b60 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800b58:	41                   	inc    %ecx
  800b59:	0f af f3             	imul   %ebx,%esi
  800b5c:	01 c6                	add    %eax,%esi
  800b5e:	eb c3                	jmp    800b23 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800b60:	85 ff                	test   %edi,%edi
  800b62:	74 02                	je     800b66 <strtoul+0xdb>
		*endptr = (char *) s;
  800b64:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800b66:	89 f0                	mov    %esi,%eax
  800b68:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800b6c:	74 02                	je     800b70 <strtoul+0xe5>
  800b6e:	f7 d8                	neg    %eax
}
  800b70:	83 c4 04             	add    $0x4,%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b87:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800b8a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800b90:	8b 45 10             	mov    0x10(%ebp),%eax
  800b93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800b99:	eb 04                	jmp    800b9f <strsplit+0x27>
			*string++ = 0;
  800b9b:	c6 03 00             	movb   $0x0,(%ebx)
  800b9e:	43                   	inc    %ebx
  800b9f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ba2:	74 4b                	je     800bef <strsplit+0x77>
  800ba4:	83 ec 08             	sub    $0x8,%esp
  800ba7:	0f be 03             	movsbl (%ebx),%eax
  800baa:	50                   	push   %eax
  800bab:	56                   	push   %esi
  800bac:	e8 bf fc ff ff       	call   800870 <strchr>
  800bb1:	83 c4 10             	add    $0x10,%esp
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	75 e3                	jne    800b9b <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800bb8:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bbb:	74 32                	je     800bef <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	83 3f 0f             	cmpl   $0xf,(%edi)
  800bc5:	74 39                	je     800c00 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800bc7:	8b 07                	mov    (%edi),%eax
  800bc9:	8b 55 10             	mov    0x10(%ebp),%edx
  800bcc:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800bcf:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800bd1:	eb 01                	jmp    800bd4 <strsplit+0x5c>
			string++;
  800bd3:	43                   	inc    %ebx
  800bd4:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bd7:	74 16                	je     800bef <strsplit+0x77>
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	0f be 03             	movsbl (%ebx),%eax
  800bdf:	50                   	push   %eax
  800be0:	56                   	push   %esi
  800be1:	e8 8a fc ff ff       	call   800870 <strchr>
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	85 c0                	test   %eax,%eax
  800beb:	74 e6                	je     800bd3 <strsplit+0x5b>
  800bed:	eb b0                	jmp    800b9f <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800bef:	8b 07                	mov    (%edi),%eax
  800bf1:	8b 55 10             	mov    0x10(%ebp),%edx
  800bf4:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800c00:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	bf 00 00 00 00       	mov    $0x0,%edi
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	89 fb                	mov    %edi,%ebx
  800c1d:	89 fe                	mov    %edi,%esi
  800c1f:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
  800c36:	89 fa                	mov    %edi,%edx
  800c38:	89 f9                	mov    %edi,%ecx
  800c3a:	89 fb                	mov    %edi,%ebx
  800c3c:	89 fe                	mov    %edi,%esi
  800c3e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
  800c58:	89 f9                	mov    %edi,%ecx
  800c5a:	89 fb                	mov    %edi,%ebx
  800c5c:	89 fe                	mov    %edi,%esi
  800c5e:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c70:	bf 00 00 00 00       	mov    $0x0,%edi
  800c75:	89 fa                	mov    %edi,%edx
  800c77:	89 f9                	mov    %edi,%ecx
  800c79:	89 fb                	mov    %edi,%ebx
  800c7b:	89 fe                	mov    %edi,%esi
  800c7d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c94:	89 fa                	mov    %edi,%edx
  800c96:	89 f9                	mov    %edi,%ecx
  800c98:	89 fb                	mov    %edi,%ebx
  800c9a:	89 fe                	mov    %edi,%esi
  800c9c:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb4:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb9:	89 fb                	mov    %edi,%ebx
  800cbb:	89 fe                	mov    %edi,%esi
  800cbd:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd5:	bf 00 00 00 00       	mov    $0x0,%edi
  800cda:	89 fb                	mov    %edi,%ebx
  800cdc:	89 fe                	mov    %edi,%esi
  800cde:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfa:	b8 07 00 00 00       	mov    $0x7,%eax
  800cff:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	b8 08 00 00 00       	mov    $0x8,%eax
  800d17:	bf 00 00 00 00       	mov    $0x0,%edi
  800d1c:	89 fb                	mov    %edi,%ebx
  800d1e:	89 fe                	mov    %edi,%esi
  800d20:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 09 00 00 00       	mov    $0x9,%eax
  800d38:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3d:	89 fb                	mov    %edi,%ebx
  800d3f:	89 fe                	mov    %edi,%esi
  800d41:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	bf 00 00 00 00       	mov    $0x0,%edi
  800d58:	89 fa                	mov    %edi,%edx
  800d5a:	89 f9                	mov    %edi,%ecx
  800d5c:	89 fb                	mov    %edi,%ebx
  800d5e:	89 fe                	mov    %edi,%esi
  800d60:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d78:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7d:	89 fb                	mov    %edi,%ebx
  800d7f:	89 fe                	mov    %edi,%esi
  800d81:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <cputchar>:
#include <inc/lib.h>

void
cputchar(int ch)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 10             	sub    $0x10,%esp
	char c = ch;
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	88 45 ff             	mov    %al,0xffffffff(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800d94:	6a 01                	push   $0x1
  800d96:	8d 45 ff             	lea    0xffffffff(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	e8 69 fe ff ff       	call   800c08 <sys_cputs>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <getchar>:

int
getchar(void)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	return sys_cgetc();
  800da7:	e8 7a fe ff ff       	call   800c26 <sys_cgetc>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <iscons>:


int iscons(int fdnum)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
  800db1:	b8 01 00 00 00       	mov    $0x1,%eax
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
	...

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	83 ec 20             	sub    $0x20,%esp
  800dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800dcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd2:	8b 55 14             	mov    0x14(%ebp),%edx
  800dd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddb:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800dde:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800de5:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800de8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800deb:	89 fe                	mov    %edi,%esi
  800ded:	85 d2                	test   %edx,%edx
  800def:	75 2f                	jne    800e20 <__udivdi3+0x60>
  800df1:	39 f8                	cmp    %edi,%eax
  800df3:	76 62                	jbe    800e57 <__udivdi3+0x97>
  800df5:	89 fa                	mov    %edi,%edx
  800df7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800dfa:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800dfd:	89 c7                	mov    %eax,%edi
  800dff:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e06:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e09:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e0c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e0f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e12:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e15:	83 c4 20             	add    $0x20,%esp
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    
  800e1c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e29:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800e2c:	77 d8                	ja     800e06 <__udivdi3+0x46>
  800e2e:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e32:	89 c7                	mov    %eax,%edi
  800e34:	83 f7 1f             	xor    $0x1f,%edi
  800e37:	75 5b                	jne    800e94 <__udivdi3+0xd4>
  800e39:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800e3c:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e3f:	0f 97 c2             	seta   %dl
  800e42:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800e45:	bf 01 00 00 00       	mov    $0x1,%edi
  800e4a:	0f 93 c0             	setae  %al
  800e4d:	09 d0                	or     %edx,%eax
  800e4f:	a8 01                	test   $0x1,%al
  800e51:	75 ac                	jne    800dff <__udivdi3+0x3f>
  800e53:	31 ff                	xor    %edi,%edi
  800e55:	eb a8                	jmp    800dff <__udivdi3+0x3f>
  800e57:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	75 0e                	jne    800e6c <__udivdi3+0xac>
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	31 c9                	xor    %ecx,%ecx
  800e65:	31 d2                	xor    %edx,%edx
  800e67:	f7 f1                	div    %ecx
  800e69:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e6c:	89 f0                	mov    %esi,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e73:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e76:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e79:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e7c:	89 c7                	mov    %eax,%edi
  800e7e:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e81:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e84:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e87:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e8a:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e8d:	83 c4 20             	add    $0x20,%esp
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
  800e94:	b8 20 00 00 00       	mov    $0x20,%eax
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	29 f8                	sub    %edi,%eax
  800e9d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800ea0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800ea3:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ea6:	d3 e2                	shl    %cl,%edx
  800ea8:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 c2                	or     %eax,%edx
  800eaf:	89 f9                	mov    %edi,%ecx
  800eb1:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800eb4:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800eb7:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800eba:	89 f2                	mov    %esi,%edx
  800ebc:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ebf:	d3 ea                	shr    %cl,%edx
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e6                	shl    %cl,%esi
  800ec5:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ec8:	d3 e8                	shr    %cl,%eax
  800eca:	09 c6                	or     %eax,%esi
  800ecc:	89 f9                	mov    %edi,%ecx
  800ece:	89 f0                	mov    %esi,%eax
  800ed0:	f7 75 ec             	divl   0xffffffec(%ebp)
  800ed3:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800ed6:	89 d6                	mov    %edx,%esi
  800ed8:	89 c7                	mov    %eax,%edi
  800eda:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800edd:	f7 e7                	mul    %edi
  800edf:	39 f2                	cmp    %esi,%edx
  800ee1:	77 15                	ja     800ef8 <__udivdi3+0x138>
  800ee3:	39 f2                	cmp    %esi,%edx
  800ee5:	0f 94 c2             	sete   %dl
  800ee8:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800eeb:	0f 97 c0             	seta   %al
  800eee:	21 d0                	and    %edx,%eax
  800ef0:	a8 01                	test   $0x1,%al
  800ef2:	0f 84 07 ff ff ff    	je     800dff <__udivdi3+0x3f>
  800ef8:	4f                   	dec    %edi
  800ef9:	e9 01 ff ff ff       	jmp    800dff <__udivdi3+0x3f>
  800efe:	90                   	nop    
  800eff:	90                   	nop    

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	83 ec 38             	sub    $0x38,%esp
  800f08:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800f0b:	8b 55 14             	mov    0x14(%ebp),%edx
  800f0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f14:	8b 45 10             	mov    0x10(%ebp),%eax
  800f17:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800f1e:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f25:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800f28:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800f2b:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f2e:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f31:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f34:	85 d2                	test   %edx,%edx
  800f36:	75 48                	jne    800f80 <__umoddi3+0x80>
  800f38:	39 f8                	cmp    %edi,%eax
  800f3a:	0f 86 d0 00 00 00    	jbe    801010 <__umoddi3+0x110>
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	89 fa                	mov    %edi,%edx
  800f44:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800f47:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800f4a:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f4d:	85 f6                	test   %esi,%esi
  800f4f:	74 49                	je     800f9a <__umoddi3+0x9a>
  800f51:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f54:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f5b:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f5e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f61:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f64:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f67:	89 10                	mov    %edx,(%eax)
  800f69:	89 48 04             	mov    %ecx,0x4(%eax)
  800f6c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f6f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f72:	83 c4 38             	add    $0x38,%esp
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800f80:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f83:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f86:	76 1f                	jbe    800fa7 <__umoddi3+0xa7>
  800f88:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f8b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f8e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f91:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f94:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f97:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f9a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f9d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800fa0:	83 c4 38             	add    $0x38,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800fab:	83 f0 1f             	xor    $0x1f,%eax
  800fae:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800fb1:	0f 85 89 00 00 00    	jne    801040 <__umoddi3+0x140>
  800fb7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800fba:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800fbd:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800fc0:	0f 97 c2             	seta   %dl
  800fc3:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800fc6:	0f 93 c0             	setae  %al
  800fc9:	09 d0                	or     %edx,%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	74 11                	je     800fe0 <__umoddi3+0xe0>
  800fcf:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fd2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fd5:	29 c8                	sub    %ecx,%eax
  800fd7:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800fda:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fdd:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800fe0:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fe3:	85 c9                	test   %ecx,%ecx
  800fe5:	74 b3                	je     800f9a <__umoddi3+0x9a>
  800fe7:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fea:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fed:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800ff0:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800ff3:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800ff6:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800ff9:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800ffc:	89 01                	mov    %eax,(%ecx)
  800ffe:	89 51 04             	mov    %edx,0x4(%ecx)
  801001:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  801004:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  801007:	83 c4 38             	add    $0x38,%esp
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    
  80100e:	89 f6                	mov    %esi,%esi
  801010:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  801013:	85 ff                	test   %edi,%edi
  801015:	75 0d                	jne    801024 <__umoddi3+0x124>
  801017:	b8 01 00 00 00       	mov    $0x1,%eax
  80101c:	31 d2                	xor    %edx,%edx
  80101e:	f7 75 c4             	divl   0xffffffc4(%ebp)
  801021:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  801024:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801027:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80102a:	f7 75 c4             	divl   0xffffffc4(%ebp)
  80102d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801030:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801033:	f7 75 c4             	divl   0xffffffc4(%ebp)
  801036:	e9 0c ff ff ff       	jmp    800f47 <__umoddi3+0x47>
  80103b:	90                   	nop    
  80103c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801040:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  801043:	b8 20 00 00 00       	mov    $0x20,%eax
  801048:	29 d0                	sub    %edx,%eax
  80104a:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  80104d:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  801050:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801053:	d3 e2                	shl    %cl,%edx
  801055:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  801058:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	09 c2                	or     %eax,%edx
  80105f:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801062:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  801065:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801068:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80106b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80106e:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  801071:	d3 ea                	shr    %cl,%edx
  801073:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801076:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801079:	d3 e6                	shl    %cl,%esi
  80107b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80107e:	d3 e8                	shr    %cl,%eax
  801080:	09 c6                	or     %eax,%esi
  801082:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801085:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  801088:	89 f0                	mov    %esi,%eax
  80108a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80108d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801090:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801093:	f7 65 c4             	mull   0xffffffc4(%ebp)
  801096:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801099:	89 d6                	mov    %edx,%esi
  80109b:	89 c7                	mov    %eax,%edi
  80109d:	77 12                	ja     8010b1 <__umoddi3+0x1b1>
  80109f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  8010a2:	0f 94 c2             	sete   %dl
  8010a5:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  8010a8:	0f 97 c0             	seta   %al
  8010ab:	21 d0                	and    %edx,%eax
  8010ad:	a8 01                	test   $0x1,%al
  8010af:	74 06                	je     8010b7 <__umoddi3+0x1b7>
  8010b1:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  8010b4:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  8010b7:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	0f 84 d8 fe ff ff    	je     800f9a <__umoddi3+0x9a>
  8010c2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010c5:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010c8:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010cb:	29 f8                	sub    %edi,%eax
  8010cd:	19 f2                	sbb    %esi,%edx
  8010cf:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010d2:	d3 e2                	shl    %cl,%edx
  8010d4:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  8010d7:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8010da:	d3 e8                	shr    %cl,%eax
  8010dc:	09 c2                	or     %eax,%edx
  8010de:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8010e1:	d3 e8                	shr    %cl,%eax
  8010e3:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8010e6:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8010e9:	e9 70 fe ff ff       	jmp    800f5e <__umoddi3+0x5e>
  8010ee:	90                   	nop    
  8010ef:	90                   	nop    
