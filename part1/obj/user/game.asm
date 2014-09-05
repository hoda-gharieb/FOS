
obj/user/game:     file format elf32-i386

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
  800031:	e8 5e 00 00 00       	call   800094 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>
	
void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
	int i=28;
  80003d:	be 1c 00 00 00       	mov    $0x1c,%esi
	for(;i<128; i++)
	{
		int c=0;
  800042:	bb 00 00 00 00       	mov    $0x0,%ebx
		for(;c<10; c++)
		{
			cprintf("%c",i);
  800047:	83 ec 08             	sub    $0x8,%esp
  80004a:	56                   	push   %esi
  80004b:	68 c0 0f 80 00       	push   $0x800fc0
  800050:	e8 1f 01 00 00       	call   800174 <cprintf>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	43                   	inc    %ebx
  800059:	83 fb 09             	cmp    $0x9,%ebx
  80005c:	7e e9                	jle    800047 <_main+0xf>
		}
		int d=0;
  80005e:	b8 00 00 00 00       	mov    $0x0,%eax
		for(; d< 500000; d++);	
  800063:	40                   	inc    %eax
  800064:	3d 1f a1 07 00       	cmp    $0x7a11f,%eax
  800069:	7e f8                	jle    800063 <_main+0x2b>
		c=0;
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
		for(;c<10; c++)
		{
			cprintf("\b");
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 c3 0f 80 00       	push   $0x800fc3
  800078:	e8 f7 00 00 00       	call   800174 <cprintf>
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	43                   	inc    %ebx
  800081:	83 fb 09             	cmp    $0x9,%ebx
  800084:	7e ea                	jle    800070 <_main+0x38>
  800086:	46                   	inc    %esi
  800087:	83 fe 7f             	cmp    $0x7f,%esi
  80008a:	7e b6                	jle    800042 <_main+0xa>
		}		
	}
	
	return;	
}
  80008c:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
  80009a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80009d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000a0:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000a7:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	85 c9                	test   %ecx,%ecx
  8000ac:	7e 07                	jle    8000b5 <libmain+0x21>
		binaryname = argv[0];
  8000ae:	8b 02                	mov    (%edx),%eax
  8000b0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	52                   	push   %edx
  8000b9:	51                   	push   %ecx
  8000ba:	e8 79 ff ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  8000bf:	e8 13 00 00 00       	call   8000d7 <sleep>
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    
	...

008000c8 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  8000ce:	6a 00                	push   $0x0
  8000d0:	e8 60 0a 00 00       	call   800b35 <sys_env_destroy>
}
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    

008000d7 <sleep>:

void
sleep(void)
{	
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  8000dd:	e8 92 0a 00 00       	call   800b74 <sys_env_sleep>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 04             	sub    $0x4,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 03                	mov    (%ebx),%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000f7:	40                   	inc    %eax
  8000f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 1a                	jne    80011b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	68 ff 00 00 00       	push   $0xff
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	50                   	push   %eax
  80010d:	e8 e6 09 00 00       	call   800af8 <sys_cputs>
		b->idx = 0;
  800112:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800118:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011b:	ff 43 04             	incl   0x4(%ebx)
}
  80011e:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012c:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800133:	00 00 00 
	b.cnt = 0;
  800136:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  80013d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  80014c:	50                   	push   %eax
  80014d:	68 e4 00 80 00       	push   $0x8000e4
  800152:	e8 2d 01 00 00       	call   800284 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	e8 8c 09 00 00       	call   800af8 <sys_cputs>

	return b.cnt;
  80016c:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	50                   	push   %eax
  80017e:	ff 75 08             	pushl  0x8(%ebp)
  800181:	e8 9d ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	8b 75 10             	mov    0x10(%ebp),%esi
  800194:	8b 7d 14             	mov    0x14(%ebp),%edi
  800197:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019a:	8b 45 18             	mov    0x18(%ebp),%eax
  80019d:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a2:	39 d7                	cmp    %edx,%edi
  8001a4:	72 39                	jb     8001df <printnum+0x57>
  8001a6:	77 04                	ja     8001ac <printnum+0x24>
  8001a8:	39 c6                	cmp    %eax,%esi
  8001aa:	72 33                	jb     8001df <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	ff 75 20             	pushl  0x20(%ebp)
  8001b2:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 18             	pushl  0x18(%ebp)
  8001b9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c1:	52                   	push   %edx
  8001c2:	50                   	push   %eax
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	e8 b6 0a 00 00       	call   800c80 <__udivdi3>
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	52                   	push   %edx
  8001ce:	50                   	push   %eax
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	e8 ae ff ff ff       	call   800188 <printnum>
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 19                	jmp    8001f8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	4b                   	dec    %ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7e 14                	jle    8001f8 <printnum+0x70>
			putch(padc, putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	ff 75 20             	pushl  0x20(%ebp)
  8001ed:	ff 55 08             	call   *0x8(%ebp)
  8001f0:	83 c4 10             	add    $0x10,%esp
  8001f3:	4b                   	dec    %ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f ec                	jg     8001e4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	8b 45 18             	mov    0x18(%ebp),%eax
  800201:	ba 00 00 00 00       	mov    $0x0,%edx
  800206:	83 ec 04             	sub    $0x4,%esp
  800209:	52                   	push   %edx
  80020a:	50                   	push   %eax
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	e8 ae 0b 00 00       	call   800dc0 <__umoddi3>
  800212:	83 c4 14             	add    $0x14,%esp
  800215:	0f be 80 45 10 80 00 	movsbl 0x801045(%eax),%eax
  80021c:	50                   	push   %eax
  80021d:	ff 55 08             	call   *0x8(%ebp)
}
  800220:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800231:	83 f8 01             	cmp    $0x1,%eax
  800234:	7e 0f                	jle    800245 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800236:	8b 01                	mov    (%ecx),%eax
  800238:	83 c0 08             	add    $0x8,%eax
  80023b:	89 01                	mov    %eax,(%ecx)
  80023d:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800240:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800243:	eb 0f                	jmp    800254 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800245:	8b 01                	mov    (%ecx),%eax
  800247:	83 c0 04             	add    $0x4,%eax
  80024a:	89 01                	mov    %eax,(%ecx)
  80024c:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80024f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	8b 55 08             	mov    0x8(%ebp),%edx
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80025f:	83 f8 01             	cmp    $0x1,%eax
  800262:	7e 0f                	jle    800273 <getint+0x1d>
		return va_arg(*ap, long long);
  800264:	8b 02                	mov    (%edx),%eax
  800266:	83 c0 08             	add    $0x8,%eax
  800269:	89 02                	mov    %eax,(%edx)
  80026b:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80026e:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800271:	eb 0f                	jmp    800282 <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800273:	8b 02                	mov    (%edx),%eax
  800275:	83 c0 04             	add    $0x4,%eax
  800278:	89 02                	mov    %eax,(%edx)
  80027a:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80027d:	89 c2                	mov    %eax,%edx
  80027f:	c1 fa 1f             	sar    $0x1f,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 1c             	sub    $0x1c,%esp
  80028d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800290:	ba 00 00 00 00       	mov    $0x0,%edx
  800295:	8a 13                	mov    (%ebx),%dl
  800297:	43                   	inc    %ebx
  800298:	83 fa 25             	cmp    $0x25,%edx
  80029b:	74 22                	je     8002bf <vprintfmt+0x3b>
			if (ch == '\0')
  80029d:	85 d2                	test   %edx,%edx
  80029f:	0f 84 cd 02 00 00    	je     800572 <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	ff 75 0c             	pushl  0xc(%ebp)
  8002ab:	52                   	push   %edx
  8002ac:	ff 55 08             	call   *0x8(%ebp)
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	8a 13                	mov    (%ebx),%dl
  8002b9:	43                   	inc    %ebx
  8002ba:	83 fa 25             	cmp    $0x25,%edx
  8002bd:	75 de                	jne    80029d <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002bf:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002c3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002ca:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8002d4:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	8a 13                	mov    (%ebx),%dl
  8002e2:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002e5:	43                   	inc    %ebx
  8002e6:	83 f8 55             	cmp    $0x55,%eax
  8002e9:	0f 87 5e 02 00 00    	ja     80054d <vprintfmt+0x2c9>
  8002ef:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f6:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8002fa:	eb df                	jmp    8002db <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fc:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800300:	eb d9                	jmp    8002db <vprintfmt+0x57>

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
  800302:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800307:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80030a:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  80030e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800311:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  800314:	83 f8 09             	cmp    $0x9,%eax
  800317:	77 27                	ja     800340 <vprintfmt+0xbc>
  800319:	43                   	inc    %ebx
  80031a:	eb eb                	jmp    800307 <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800320:	8b 45 14             	mov    0x14(%ebp),%eax
  800323:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  800326:	eb 18                	jmp    800340 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  800328:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80032c:	79 ad                	jns    8002db <vprintfmt+0x57>
				width = 0;
  80032e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800335:	eb a4                	jmp    8002db <vprintfmt+0x57>

		case '#':
			altflag = 1;
  800337:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  80033e:	eb 9b                	jmp    8002db <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  800340:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800344:	79 95                	jns    8002db <vprintfmt+0x57>
				width = precision, precision = -1;
  800346:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800349:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80034e:	eb 8b                	jmp    8002db <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800350:	41                   	inc    %ecx
			goto reswitch;
  800351:	eb 88                	jmp    8002db <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	ff 75 0c             	pushl  0xc(%ebp)
  800359:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800363:	e9 da 01 00 00       	jmp    800542 <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800368:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	79 02                	jns    800378 <vprintfmt+0xf4>
				err = -err;
  800376:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800378:	83 f8 07             	cmp    $0x7,%eax
  80037b:	7f 0b                	jg     800388 <vprintfmt+0x104>
  80037d:	8b 3c 85 80 10 80 00 	mov    0x801080(,%eax,4),%edi
  800384:	85 ff                	test   %edi,%edi
  800386:	75 08                	jne    800390 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  800388:	50                   	push   %eax
  800389:	68 56 10 80 00       	push   $0x801056
  80038e:	eb 06                	jmp    800396 <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  800390:	57                   	push   %edi
  800391:	68 5f 10 80 00       	push   $0x80105f
  800396:	ff 75 0c             	pushl  0xc(%ebp)
  800399:	ff 75 08             	pushl  0x8(%ebp)
  80039c:	e8 d9 01 00 00       	call   80057a <printfmt>
  8003a1:	e9 9f 01 00 00       	jmp    800545 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003a6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003b0:	85 ff                	test   %edi,%edi
  8003b2:	75 05                	jne    8003b9 <vprintfmt+0x135>
				p = "(null)";
  8003b4:	bf 62 10 80 00       	mov    $0x801062,%edi
			if (width > 0 && padc != '-')
  8003b9:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003bd:	0f 9f c2             	setg   %dl
  8003c0:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003c4:	0f 95 c0             	setne  %al
  8003c7:	21 d0                	and    %edx,%eax
  8003c9:	a8 01                	test   $0x1,%al
  8003cb:	74 35                	je     800402 <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	57                   	push   %edi
  8003d2:	e8 5e 02 00 00       	call   800635 <strnlen>
  8003d7:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8003da:	83 c4 10             	add    $0x10,%esp
  8003dd:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003e1:	7e 1f                	jle    800402 <vprintfmt+0x17e>
  8003e3:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003e7:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	ff 75 0c             	pushl  0xc(%ebp)
  8003f0:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003fc:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800400:	7f e8                	jg     8003ea <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800402:	0f be 17             	movsbl (%edi),%edx
  800405:	47                   	inc    %edi
  800406:	85 d2                	test   %edx,%edx
  800408:	74 3e                	je     800448 <vprintfmt+0x1c4>
  80040a:	85 f6                	test   %esi,%esi
  80040c:	78 03                	js     800411 <vprintfmt+0x18d>
  80040e:	4e                   	dec    %esi
  80040f:	78 37                	js     800448 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  800411:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  800415:	74 12                	je     800429 <vprintfmt+0x1a5>
  800417:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  80041a:	83 f8 5e             	cmp    $0x5e,%eax
  80041d:	76 0a                	jbe    800429 <vprintfmt+0x1a5>
					putch('?', putdat);
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	ff 75 0c             	pushl  0xc(%ebp)
  800425:	6a 3f                	push   $0x3f
  800427:	eb 07                	jmp    800430 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	52                   	push   %edx
  800430:	ff 55 08             	call   *0x8(%ebp)
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800439:	0f be 17             	movsbl (%edi),%edx
  80043c:	47                   	inc    %edi
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 07                	je     800448 <vprintfmt+0x1c4>
  800441:	85 f6                	test   %esi,%esi
  800443:	78 cc                	js     800411 <vprintfmt+0x18d>
  800445:	4e                   	dec    %esi
  800446:	79 c9                	jns    800411 <vprintfmt+0x18d>
			for (; width > 0; width--)
  800448:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80044c:	0f 8e 3e fe ff ff    	jle    800290 <vprintfmt+0xc>
				putch(' ', putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	ff 75 0c             	pushl  0xc(%ebp)
  800458:	6a 20                	push   $0x20
  80045a:	ff 55 08             	call   *0x8(%ebp)
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800463:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800467:	7f e9                	jg     800452 <vprintfmt+0x1ce>
			break;
  800469:	e9 22 fe ff ff       	jmp    800290 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	51                   	push   %ecx
  800472:	8d 45 14             	lea    0x14(%ebp),%eax
  800475:	50                   	push   %eax
  800476:	e8 db fd ff ff       	call   800256 <getint>
  80047b:	89 c6                	mov    %eax,%esi
  80047d:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	85 d2                	test   %edx,%edx
  800484:	79 15                	jns    80049b <vprintfmt+0x217>
				putch('-', putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 0c             	pushl  0xc(%ebp)
  80048c:	6a 2d                	push   $0x2d
  80048e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800491:	f7 de                	neg    %esi
  800493:	83 d7 00             	adc    $0x0,%edi
  800496:	f7 df                	neg    %edi
  800498:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80049b:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004a0:	eb 78                	jmp    80051a <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	51                   	push   %ecx
  8004a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	e8 79 fd ff ff       	call   800228 <getuint>
  8004af:	89 c6                	mov    %eax,%esi
  8004b1:	89 d7                	mov    %edx,%edi
			base = 10;
  8004b3:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004b8:	eb 5d                	jmp    800517 <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	ff 75 0c             	pushl  0xc(%ebp)
  8004c0:	6a 58                	push   $0x58
  8004c2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	6a 58                	push   $0x58
  8004cd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004d0:	83 c4 08             	add    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 58                	push   $0x58
  8004d8:	eb 68                	jmp    800542 <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	6a 30                	push   $0x30
  8004e2:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004e5:	83 c4 08             	add    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 78                	push   $0x78
  8004ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004f0:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8004fa:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  8004ff:	eb 11                	jmp    800512 <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	51                   	push   %ecx
  800505:	8d 45 14             	lea    0x14(%ebp),%eax
  800508:	50                   	push   %eax
  800509:	e8 1a fd ff ff       	call   800228 <getuint>
  80050e:	89 c6                	mov    %eax,%esi
  800510:	89 d7                	mov    %edx,%edi
			base = 16;
  800512:	ba 10 00 00 00       	mov    $0x10,%edx
  800517:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  80051a:	83 ec 04             	sub    $0x4,%esp
  80051d:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800521:	50                   	push   %eax
  800522:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800525:	52                   	push   %edx
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	ff 75 08             	pushl  0x8(%ebp)
  80052e:	e8 55 fc ff ff       	call   800188 <printnum>
			break;
  800533:	83 c4 20             	add    $0x20,%esp
  800536:	e9 55 fd ff ff       	jmp    800290 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
			break;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	e9 43 fd ff ff       	jmp    800290 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	6a 25                	push   $0x25
  800555:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800558:	4b                   	dec    %ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800560:	0f 84 2a fd ff ff    	je     800290 <vprintfmt+0xc>
  800566:	4b                   	dec    %ebx
  800567:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80056b:	75 f9                	jne    800566 <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  80056d:	e9 1e fd ff ff       	jmp    800290 <vprintfmt+0xc>
		}
	}
}
  800572:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800580:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800583:	50                   	push   %eax
  800584:	ff 75 10             	pushl  0x10(%ebp)
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	ff 75 08             	pushl  0x8(%ebp)
  80058d:	e8 f2 fc ff ff       	call   800284 <vprintfmt>
	va_end(ap);
}
  800592:	c9                   	leave  
  800593:	c3                   	ret    

00800594 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80059a:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80059d:	8b 0a                	mov    (%edx),%ecx
  80059f:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005a2:	73 07                	jae    8005ab <sprintputch+0x17>
		*b->buf++ = ch;
  8005a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a7:	88 01                	mov    %al,(%ecx)
  8005a9:	ff 02                	incl   (%edx)
}
  8005ab:	5d                   	pop    %ebp
  8005ac:	c3                   	ret    

008005ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005ad:	55                   	push   %ebp
  8005ae:	89 e5                	mov    %esp,%ebp
  8005b0:	83 ec 18             	sub    $0x18,%esp
  8005b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005b9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005bc:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005c0:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005c3:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	0f 94 c2             	sete   %dl
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	0f 9e c0             	setle  %al
  8005d4:	09 d0                	or     %edx,%eax
  8005d6:	ba 03 00 00 00       	mov    $0x3,%edx
  8005db:	a8 01                	test   $0x1,%al
  8005dd:	75 1d                	jne    8005fc <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005df:	ff 75 14             	pushl  0x14(%ebp)
  8005e2:	ff 75 10             	pushl  0x10(%ebp)
  8005e5:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005e8:	50                   	push   %eax
  8005e9:	68 94 05 80 00       	push   $0x800594
  8005ee:	e8 91 fc ff ff       	call   800284 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005f3:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8005f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005f9:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  8005fc:	89 d0                	mov    %edx,%eax
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800609:	50                   	push   %eax
  80060a:	ff 75 10             	pushl  0x10(%ebp)
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	e8 95 ff ff ff       	call   8005ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800618:	c9                   	leave  
  800619:	c3                   	ret    
	...

0080061c <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  80061c:	55                   	push   %ebp
  80061d:	89 e5                	mov    %esp,%ebp
  80061f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800622:	b8 00 00 00 00       	mov    $0x0,%eax
  800627:	80 3a 00             	cmpb   $0x0,(%edx)
  80062a:	74 07                	je     800633 <strlen+0x17>
		n++;
  80062c:	40                   	inc    %eax
  80062d:	42                   	inc    %edx
  80062e:	80 3a 00             	cmpb   $0x0,(%edx)
  800631:	75 f9                	jne    80062c <strlen+0x10>
	return n;
}
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80063e:	b8 00 00 00 00       	mov    $0x0,%eax
  800643:	85 d2                	test   %edx,%edx
  800645:	74 0f                	je     800656 <strnlen+0x21>
  800647:	80 39 00             	cmpb   $0x0,(%ecx)
  80064a:	74 0a                	je     800656 <strnlen+0x21>
		n++;
  80064c:	40                   	inc    %eax
  80064d:	41                   	inc    %ecx
  80064e:	4a                   	dec    %edx
  80064f:	74 05                	je     800656 <strnlen+0x21>
  800651:	80 39 00             	cmpb   $0x0,(%ecx)
  800654:	75 f6                	jne    80064c <strnlen+0x17>
	return n;
}
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	53                   	push   %ebx
  80065c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800662:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800664:	8a 02                	mov    (%edx),%al
  800666:	88 01                	mov    %al,(%ecx)
  800668:	42                   	inc    %edx
  800669:	41                   	inc    %ecx
  80066a:	84 c0                	test   %al,%al
  80066c:	75 f6                	jne    800664 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80066e:	89 d8                	mov    %ebx,%eax
  800670:	5b                   	pop    %ebx
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	57                   	push   %edi
  800677:	56                   	push   %esi
  800678:	53                   	push   %ebx
  800679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067f:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  800682:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800684:	bb 00 00 00 00       	mov    $0x0,%ebx
  800689:	39 f3                	cmp    %esi,%ebx
  80068b:	73 17                	jae    8006a4 <strncpy+0x31>
		*dst++ = *src;
  80068d:	8a 02                	mov    (%edx),%al
  80068f:	88 01                	mov    %al,(%ecx)
  800691:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800692:	80 3a 00             	cmpb   $0x0,(%edx)
  800695:	0f 95 c0             	setne  %al
  800698:	25 ff 00 00 00       	and    $0xff,%eax
  80069d:	01 c2                	add    %eax,%edx
  80069f:	43                   	inc    %ebx
  8006a0:	39 f3                	cmp    %esi,%ebx
  8006a2:	72 e9                	jb     80068d <strncpy+0x1a>
			src++;
	}
	return ret;
}
  8006a4:	89 f8                	mov    %edi,%eax
  8006a6:	5b                   	pop    %ebx
  8006a7:	5e                   	pop    %esi
  8006a8:	5f                   	pop    %edi
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b6:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006b9:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	74 19                	je     8006d8 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8006bf:	4a                   	dec    %edx
  8006c0:	74 13                	je     8006d5 <strlcpy+0x2a>
  8006c2:	80 39 00             	cmpb   $0x0,(%ecx)
  8006c5:	74 0e                	je     8006d5 <strlcpy+0x2a>
			*dst++ = *src++;
  8006c7:	8a 01                	mov    (%ecx),%al
  8006c9:	88 03                	mov    %al,(%ebx)
  8006cb:	41                   	inc    %ecx
  8006cc:	43                   	inc    %ebx
  8006cd:	4a                   	dec    %edx
  8006ce:	74 05                	je     8006d5 <strlcpy+0x2a>
  8006d0:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d3:	75 f2                	jne    8006c7 <strlcpy+0x1c>
		*dst = '\0';
  8006d5:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006d8:	89 d8                	mov    %ebx,%eax
  8006da:	29 f0                	sub    %esi,%eax
}
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8006e9:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ec:	74 13                	je     800701 <strcmp+0x21>
  8006ee:	8a 02                	mov    (%edx),%al
  8006f0:	3a 01                	cmp    (%ecx),%al
  8006f2:	75 0d                	jne    800701 <strcmp+0x21>
		p++, q++;
  8006f4:	42                   	inc    %edx
  8006f5:	41                   	inc    %ecx
  8006f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f9:	74 06                	je     800701 <strcmp+0x21>
  8006fb:	8a 02                	mov    (%edx),%al
  8006fd:	3a 01                	cmp    (%ecx),%al
  8006ff:	74 f3                	je     8006f4 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
  800706:	8a 02                	mov    (%edx),%al
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
  80070d:	8a 11                	mov    (%ecx),%dl
  80070f:	29 d0                	sub    %edx,%eax
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
  80071a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800720:	85 c9                	test   %ecx,%ecx
  800722:	74 1f                	je     800743 <strncmp+0x30>
  800724:	80 3a 00             	cmpb   $0x0,(%edx)
  800727:	74 16                	je     80073f <strncmp+0x2c>
  800729:	8a 02                	mov    (%edx),%al
  80072b:	3a 03                	cmp    (%ebx),%al
  80072d:	75 10                	jne    80073f <strncmp+0x2c>
		n--, p++, q++;
  80072f:	42                   	inc    %edx
  800730:	43                   	inc    %ebx
  800731:	49                   	dec    %ecx
  800732:	74 0f                	je     800743 <strncmp+0x30>
  800734:	80 3a 00             	cmpb   $0x0,(%edx)
  800737:	74 06                	je     80073f <strncmp+0x2c>
  800739:	8a 02                	mov    (%edx),%al
  80073b:	3a 03                	cmp    (%ebx),%al
  80073d:	74 f0                	je     80072f <strncmp+0x1c>
	if (n == 0)
  80073f:	85 c9                	test   %ecx,%ecx
  800741:	75 07                	jne    80074a <strncmp+0x37>
		return 0;
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 13                	jmp    80075d <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80074a:	8a 12                	mov    (%edx),%dl
  80074c:	81 e2 ff 00 00 00    	and    $0xff,%edx
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	8a 03                	mov    (%ebx),%al
  800759:	29 c2                	sub    %eax,%edx
  80075b:	89 d0                	mov    %edx,%eax
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
  800766:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800769:	80 3a 00             	cmpb   $0x0,(%edx)
  80076c:	74 0c                	je     80077a <strchr+0x1a>
		if (*s == c)
  80076e:	89 d0                	mov    %edx,%eax
  800770:	38 0a                	cmp    %cl,(%edx)
  800772:	74 0b                	je     80077f <strchr+0x1f>
  800774:	42                   	inc    %edx
  800775:	80 3a 00             	cmpb   $0x0,(%edx)
  800778:	75 f4                	jne    80076e <strchr+0xe>
			return (char *) s;
	return 0;
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80078a:	80 38 00             	cmpb   $0x0,(%eax)
  80078d:	74 0a                	je     800799 <strfind+0x18>
		if (*s == c)
  80078f:	38 10                	cmp    %dl,(%eax)
  800791:	74 06                	je     800799 <strfind+0x18>
  800793:	40                   	inc    %eax
  800794:	80 38 00             	cmpb   $0x0,(%eax)
  800797:	75 f6                	jne    80078f <strfind+0xe>
			break;
	return (char *) s;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <memset>:


void *
memset(void *v, int c, uint32 n)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  8007a5:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	4a                   	dec    %edx
  8007ab:	78 06                	js     8007b3 <memset+0x18>
		*p++ = c;
  8007ad:	88 01                	mov    %al,(%ecx)
  8007af:	41                   	inc    %ecx
  8007b0:	4a                   	dec    %edx
  8007b1:	79 fa                	jns    8007ad <memset+0x12>

	return v;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  8007c6:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  8007c8:	89 c8                	mov    %ecx,%eax
  8007ca:	49                   	dec    %ecx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	74 0d                	je     8007dc <memcpy+0x24>
		*d++ = *s++;
  8007cf:	8a 03                	mov    (%ebx),%al
  8007d1:	88 02                	mov    %al,(%edx)
  8007d3:	43                   	inc    %ebx
  8007d4:	42                   	inc    %edx
  8007d5:	89 c8                	mov    %ecx,%eax
  8007d7:	49                   	dec    %ecx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	75 f3                	jne    8007cf <memcpy+0x17>

	return dst;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  8007f0:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  8007f2:	39 f1                	cmp    %esi,%ecx
  8007f4:	73 22                	jae    800818 <memmove+0x36>
  8007f6:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  8007f9:	39 f0                	cmp    %esi,%eax
  8007fb:	76 1b                	jbe    800818 <memmove+0x36>
		s += n;
  8007fd:	89 c1                	mov    %eax,%ecx
		d += n;
  8007ff:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  800802:	89 d0                	mov    %edx,%eax
  800804:	4a                   	dec    %edx
  800805:	85 c0                	test   %eax,%eax
  800807:	74 23                	je     80082c <memmove+0x4a>
			*--d = *--s;
  800809:	4b                   	dec    %ebx
  80080a:	49                   	dec    %ecx
  80080b:	8a 01                	mov    (%ecx),%al
  80080d:	88 03                	mov    %al,(%ebx)
  80080f:	89 d0                	mov    %edx,%eax
  800811:	4a                   	dec    %edx
  800812:	85 c0                	test   %eax,%eax
  800814:	75 f3                	jne    800809 <memmove+0x27>
  800816:	eb 14                	jmp    80082c <memmove+0x4a>
	} else
		while (n-- > 0)
  800818:	89 d0                	mov    %edx,%eax
  80081a:	4a                   	dec    %edx
  80081b:	85 c0                	test   %eax,%eax
  80081d:	74 0d                	je     80082c <memmove+0x4a>
			*d++ = *s++;
  80081f:	8a 01                	mov    (%ecx),%al
  800821:	88 03                	mov    %al,(%ebx)
  800823:	41                   	inc    %ecx
  800824:	43                   	inc    %ebx
  800825:	89 d0                	mov    %edx,%eax
  800827:	4a                   	dec    %edx
  800828:	85 c0                	test   %eax,%eax
  80082a:	75 f3                	jne    80081f <memmove+0x3d>

	return dst;
}
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  80083c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80083f:	89 d0                	mov    %edx,%eax
  800841:	4a                   	dec    %edx
  800842:	85 c0                	test   %eax,%eax
  800844:	74 23                	je     800869 <memcmp+0x37>
		if (*s1 != *s2)
  800846:	8a 01                	mov    (%ecx),%al
  800848:	3a 03                	cmp    (%ebx),%al
  80084a:	74 14                	je     800860 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
  800851:	8a 11                	mov    (%ecx),%dl
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	8a 03                	mov    (%ebx),%al
  80085a:	29 c2                	sub    %eax,%edx
  80085c:	89 d0                	mov    %edx,%eax
  80085e:	eb 0e                	jmp    80086e <memcmp+0x3c>
		s1++, s2++;
  800860:	41                   	inc    %ecx
  800861:	43                   	inc    %ebx
  800862:	89 d0                	mov    %edx,%eax
  800864:	4a                   	dec    %edx
  800865:	85 c0                	test   %eax,%eax
  800867:	75 dd                	jne    800846 <memcmp+0x14>
	}

	return 0;
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80087f:	39 d0                	cmp    %edx,%eax
  800881:	73 09                	jae    80088c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800883:	38 08                	cmp    %cl,(%eax)
  800885:	74 05                	je     80088c <memfind+0x1b>
  800887:	40                   	inc    %eax
  800888:	39 d0                	cmp    %edx,%eax
  80088a:	72 f7                	jb     800883 <memfind+0x12>
			break;
	return (void *) s;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	83 ec 04             	sub    $0x4,%esp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80089d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  8008a0:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  8008a7:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008ac:	80 39 20             	cmpb   $0x20,(%ecx)
  8008af:	0f 94 c2             	sete   %dl
  8008b2:	80 39 09             	cmpb   $0x9,(%ecx)
  8008b5:	0f 94 c0             	sete   %al
  8008b8:	09 d0                	or     %edx,%eax
  8008ba:	a8 01                	test   $0x1,%al
  8008bc:	74 13                	je     8008d1 <strtol+0x43>
		s++;
  8008be:	41                   	inc    %ecx
  8008bf:	80 39 20             	cmpb   $0x20,(%ecx)
  8008c2:	0f 94 c2             	sete   %dl
  8008c5:	80 39 09             	cmpb   $0x9,(%ecx)
  8008c8:	0f 94 c0             	sete   %al
  8008cb:	09 d0                	or     %edx,%eax
  8008cd:	a8 01                	test   $0x1,%al
  8008cf:	75 ed                	jne    8008be <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  8008d1:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8008d4:	75 03                	jne    8008d9 <strtol+0x4b>
		s++;
  8008d6:	41                   	inc    %ecx
  8008d7:	eb 0d                	jmp    8008e6 <strtol+0x58>
	else if (*s == '-')
  8008d9:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8008dc:	75 08                	jne    8008e6 <strtol+0x58>
		s++, neg = 1;
  8008de:	41                   	inc    %ecx
  8008df:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008e6:	85 db                	test   %ebx,%ebx
  8008e8:	0f 94 c2             	sete   %dl
  8008eb:	83 fb 10             	cmp    $0x10,%ebx
  8008ee:	0f 94 c0             	sete   %al
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	a8 01                	test   $0x1,%al
  8008f5:	74 15                	je     80090c <strtol+0x7e>
  8008f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8008fa:	75 10                	jne    80090c <strtol+0x7e>
  8008fc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800900:	75 0a                	jne    80090c <strtol+0x7e>
		s += 2, base = 16;
  800902:	83 c1 02             	add    $0x2,%ecx
  800905:	bb 10 00 00 00       	mov    $0x10,%ebx
  80090a:	eb 1a                	jmp    800926 <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  80090c:	85 db                	test   %ebx,%ebx
  80090e:	75 16                	jne    800926 <strtol+0x98>
  800910:	80 39 30             	cmpb   $0x30,(%ecx)
  800913:	75 08                	jne    80091d <strtol+0x8f>
		s++, base = 8;
  800915:	41                   	inc    %ecx
  800916:	bb 08 00 00 00       	mov    $0x8,%ebx
  80091b:	eb 09                	jmp    800926 <strtol+0x98>
	else if (base == 0)
  80091d:	85 db                	test   %ebx,%ebx
  80091f:	75 05                	jne    800926 <strtol+0x98>
		base = 10;
  800921:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800926:	8a 01                	mov    (%ecx),%al
  800928:	83 e8 30             	sub    $0x30,%eax
  80092b:	3c 09                	cmp    $0x9,%al
  80092d:	77 08                	ja     800937 <strtol+0xa9>
			dig = *s - '0';
  80092f:	0f be 01             	movsbl (%ecx),%eax
  800932:	83 e8 30             	sub    $0x30,%eax
  800935:	eb 20                	jmp    800957 <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800937:	8a 01                	mov    (%ecx),%al
  800939:	83 e8 61             	sub    $0x61,%eax
  80093c:	3c 19                	cmp    $0x19,%al
  80093e:	77 08                	ja     800948 <strtol+0xba>
			dig = *s - 'a' + 10;
  800940:	0f be 01             	movsbl (%ecx),%eax
  800943:	83 e8 57             	sub    $0x57,%eax
  800946:	eb 0f                	jmp    800957 <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800948:	8a 01                	mov    (%ecx),%al
  80094a:	83 e8 41             	sub    $0x41,%eax
  80094d:	3c 19                	cmp    $0x19,%al
  80094f:	77 12                	ja     800963 <strtol+0xd5>
			dig = *s - 'A' + 10;
  800951:	0f be 01             	movsbl (%ecx),%eax
  800954:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800957:	39 d8                	cmp    %ebx,%eax
  800959:	7d 08                	jge    800963 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  80095b:	41                   	inc    %ecx
  80095c:	0f af f3             	imul   %ebx,%esi
  80095f:	01 c6                	add    %eax,%esi
  800961:	eb c3                	jmp    800926 <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  800963:	85 ff                	test   %edi,%edi
  800965:	74 02                	je     800969 <strtol+0xdb>
		*endptr = (char *) s;
  800967:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800969:	89 f0                	mov    %esi,%eax
  80096b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80096f:	74 02                	je     800973 <strtol+0xe5>
  800971:	f7 d8                	neg    %eax
}
  800973:	83 c4 04             	add    $0x4,%esp
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	83 ec 04             	sub    $0x4,%esp
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  80098d:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800994:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800999:	80 39 20             	cmpb   $0x20,(%ecx)
  80099c:	0f 94 c2             	sete   %dl
  80099f:	80 39 09             	cmpb   $0x9,(%ecx)
  8009a2:	0f 94 c0             	sete   %al
  8009a5:	09 d0                	or     %edx,%eax
  8009a7:	a8 01                	test   $0x1,%al
  8009a9:	74 13                	je     8009be <strtoul+0x43>
		s++;
  8009ab:	41                   	inc    %ecx
  8009ac:	80 39 20             	cmpb   $0x20,(%ecx)
  8009af:	0f 94 c2             	sete   %dl
  8009b2:	80 39 09             	cmpb   $0x9,(%ecx)
  8009b5:	0f 94 c0             	sete   %al
  8009b8:	09 d0                	or     %edx,%eax
  8009ba:	a8 01                	test   $0x1,%al
  8009bc:	75 ed                	jne    8009ab <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  8009be:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8009c1:	75 03                	jne    8009c6 <strtoul+0x4b>
		s++;
  8009c3:	41                   	inc    %ecx
  8009c4:	eb 0d                	jmp    8009d3 <strtoul+0x58>
	else if (*s == '-')
  8009c6:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8009c9:	75 08                	jne    8009d3 <strtoul+0x58>
		s++, neg = 1;
  8009cb:	41                   	inc    %ecx
  8009cc:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	0f 94 c2             	sete   %dl
  8009d8:	83 fb 10             	cmp    $0x10,%ebx
  8009db:	0f 94 c0             	sete   %al
  8009de:	09 d0                	or     %edx,%eax
  8009e0:	a8 01                	test   $0x1,%al
  8009e2:	74 15                	je     8009f9 <strtoul+0x7e>
  8009e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e7:	75 10                	jne    8009f9 <strtoul+0x7e>
  8009e9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ed:	75 0a                	jne    8009f9 <strtoul+0x7e>
		s += 2, base = 16;
  8009ef:	83 c1 02             	add    $0x2,%ecx
  8009f2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f7:	eb 1a                	jmp    800a13 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	75 16                	jne    800a13 <strtoul+0x98>
  8009fd:	80 39 30             	cmpb   $0x30,(%ecx)
  800a00:	75 08                	jne    800a0a <strtoul+0x8f>
		s++, base = 8;
  800a02:	41                   	inc    %ecx
  800a03:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a08:	eb 09                	jmp    800a13 <strtoul+0x98>
	else if (base == 0)
  800a0a:	85 db                	test   %ebx,%ebx
  800a0c:	75 05                	jne    800a13 <strtoul+0x98>
		base = 10;
  800a0e:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a13:	8a 01                	mov    (%ecx),%al
  800a15:	83 e8 30             	sub    $0x30,%eax
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	77 08                	ja     800a24 <strtoul+0xa9>
			dig = *s - '0';
  800a1c:	0f be 01             	movsbl (%ecx),%eax
  800a1f:	83 e8 30             	sub    $0x30,%eax
  800a22:	eb 20                	jmp    800a44 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800a24:	8a 01                	mov    (%ecx),%al
  800a26:	83 e8 61             	sub    $0x61,%eax
  800a29:	3c 19                	cmp    $0x19,%al
  800a2b:	77 08                	ja     800a35 <strtoul+0xba>
			dig = *s - 'a' + 10;
  800a2d:	0f be 01             	movsbl (%ecx),%eax
  800a30:	83 e8 57             	sub    $0x57,%eax
  800a33:	eb 0f                	jmp    800a44 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800a35:	8a 01                	mov    (%ecx),%al
  800a37:	83 e8 41             	sub    $0x41,%eax
  800a3a:	3c 19                	cmp    $0x19,%al
  800a3c:	77 12                	ja     800a50 <strtoul+0xd5>
			dig = *s - 'A' + 10;
  800a3e:	0f be 01             	movsbl (%ecx),%eax
  800a41:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a44:	39 d8                	cmp    %ebx,%eax
  800a46:	7d 08                	jge    800a50 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a48:	41                   	inc    %ecx
  800a49:	0f af f3             	imul   %ebx,%esi
  800a4c:	01 c6                	add    %eax,%esi
  800a4e:	eb c3                	jmp    800a13 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800a50:	85 ff                	test   %edi,%edi
  800a52:	74 02                	je     800a56 <strtoul+0xdb>
		*endptr = (char *) s;
  800a54:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a56:	89 f0                	mov    %esi,%eax
  800a58:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a5c:	74 02                	je     800a60 <strtoul+0xe5>
  800a5e:	f7 d8                	neg    %eax
}
  800a60:	83 c4 04             	add    $0x4,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	83 ec 0c             	sub    $0xc,%esp
  800a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a77:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800a7a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800a80:	8b 45 10             	mov    0x10(%ebp),%eax
  800a83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800a89:	eb 04                	jmp    800a8f <strsplit+0x27>
			*string++ = 0;
  800a8b:	c6 03 00             	movb   $0x0,(%ebx)
  800a8e:	43                   	inc    %ebx
  800a8f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a92:	74 4b                	je     800adf <strsplit+0x77>
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	0f be 03             	movsbl (%ebx),%eax
  800a9a:	50                   	push   %eax
  800a9b:	56                   	push   %esi
  800a9c:	e8 bf fc ff ff       	call   800760 <strchr>
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	75 e3                	jne    800a8b <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800aa8:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aab:	74 32                	je     800adf <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	83 3f 0f             	cmpl   $0xf,(%edi)
  800ab5:	74 39                	je     800af0 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800ab7:	8b 07                	mov    (%edi),%eax
  800ab9:	8b 55 10             	mov    0x10(%ebp),%edx
  800abc:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800abf:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800ac1:	eb 01                	jmp    800ac4 <strsplit+0x5c>
			string++;
  800ac3:	43                   	inc    %ebx
  800ac4:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ac7:	74 16                	je     800adf <strsplit+0x77>
  800ac9:	83 ec 08             	sub    $0x8,%esp
  800acc:	0f be 03             	movsbl (%ebx),%eax
  800acf:	50                   	push   %eax
  800ad0:	56                   	push   %esi
  800ad1:	e8 8a fc ff ff       	call   800760 <strchr>
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	74 e6                	je     800ac3 <strsplit+0x5b>
  800add:	eb b0                	jmp    800a8f <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800adf:	8b 07                	mov    (%edi),%eax
  800ae1:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae4:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800aeb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800af0:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	89 f8                	mov    %edi,%eax
  800b0b:	89 fb                	mov    %edi,%ebx
  800b0d:	89 fe                	mov    %edi,%esi
  800b0f:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	bf 00 00 00 00       	mov    $0x0,%edi
  800b26:	89 fa                	mov    %edi,%edx
  800b28:	89 f9                	mov    %edi,%ecx
  800b2a:	89 fb                	mov    %edi,%ebx
  800b2c:	89 fe                	mov    %edi,%esi
  800b2e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	89 f9                	mov    %edi,%ecx
  800b4a:	89 fb                	mov    %edi,%ebx
  800b4c:	89 fe                	mov    %edi,%esi
  800b4e:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
  800b65:	89 fa                	mov    %edi,%edx
  800b67:	89 f9                	mov    %edi,%ecx
  800b69:	89 fb                	mov    %edi,%ebx
  800b6b:	89 fe                	mov    %edi,%esi
  800b6d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b84:	89 fa                	mov    %edi,%edx
  800b86:	89 f9                	mov    %edi,%ecx
  800b88:	89 fb                	mov    %edi,%ebx
  800b8a:	89 fe                	mov    %edi,%esi
  800b8c:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9f:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba9:	89 fb                	mov    %edi,%ebx
  800bab:	89 fe                	mov    %edi,%esi
  800bad:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bca:	89 fb                	mov    %edi,%ebx
  800bcc:	89 fe                	mov    %edi,%esi
  800bce:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bea:	b8 07 00 00 00       	mov    $0x7,%eax
  800bef:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	b8 08 00 00 00       	mov    $0x8,%eax
  800c07:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0c:	89 fb                	mov    %edi,%ebx
  800c0e:	89 fe                	mov    %edi,%esi
  800c10:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	b8 09 00 00 00       	mov    $0x9,%eax
  800c28:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2d:	89 fb                	mov    %edi,%ebx
  800c2f:	89 fe                	mov    %edi,%esi
  800c31:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
  800c48:	89 fa                	mov    %edi,%edx
  800c4a:	89 f9                	mov    %edi,%ecx
  800c4c:	89 fb                	mov    %edi,%ebx
  800c4e:	89 fe                	mov    %edi,%esi
  800c50:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6d:	89 fb                	mov    %edi,%ebx
  800c6f:	89 fe                	mov    %edi,%esi
  800c71:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
	...

00800c80 <__udivdi3>:
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	83 ec 20             	sub    $0x20,%esp
  800c88:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800c8f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c92:	8b 55 14             	mov    0x14(%ebp),%edx
  800c95:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800c9e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800ca5:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800ca8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800cab:	89 fe                	mov    %edi,%esi
  800cad:	85 d2                	test   %edx,%edx
  800caf:	75 2f                	jne    800ce0 <__udivdi3+0x60>
  800cb1:	39 f8                	cmp    %edi,%eax
  800cb3:	76 62                	jbe    800d17 <__udivdi3+0x97>
  800cb5:	89 fa                	mov    %edi,%edx
  800cb7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800cba:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800cbd:	89 c7                	mov    %eax,%edi
  800cbf:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800cc6:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800cc9:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800ccc:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800ccf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800cd2:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800cd5:	83 c4 20             	add    $0x20,%esp
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
  800cdc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ce0:	31 ff                	xor    %edi,%edi
  800ce2:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800ce9:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800cec:	77 d8                	ja     800cc6 <__udivdi3+0x46>
  800cee:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800cf2:	89 c7                	mov    %eax,%edi
  800cf4:	83 f7 1f             	xor    $0x1f,%edi
  800cf7:	75 5b                	jne    800d54 <__udivdi3+0xd4>
  800cf9:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800cfc:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800cff:	0f 97 c2             	seta   %dl
  800d02:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800d05:	bf 01 00 00 00       	mov    $0x1,%edi
  800d0a:	0f 93 c0             	setae  %al
  800d0d:	09 d0                	or     %edx,%eax
  800d0f:	a8 01                	test   $0x1,%al
  800d11:	75 ac                	jne    800cbf <__udivdi3+0x3f>
  800d13:	31 ff                	xor    %edi,%edi
  800d15:	eb a8                	jmp    800cbf <__udivdi3+0x3f>
  800d17:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	75 0e                	jne    800d2c <__udivdi3+0xac>
  800d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d23:	31 c9                	xor    %ecx,%ecx
  800d25:	31 d2                	xor    %edx,%edx
  800d27:	f7 f1                	div    %ecx
  800d29:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800d2c:	89 f0                	mov    %esi,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800d33:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800d36:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d39:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800d3c:	89 c7                	mov    %eax,%edi
  800d3e:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800d41:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800d44:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800d47:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800d4a:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800d4d:	83 c4 20             	add    $0x20,%esp
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
  800d54:	b8 20 00 00 00       	mov    $0x20,%eax
  800d59:	89 f9                	mov    %edi,%ecx
  800d5b:	29 f8                	sub    %edi,%eax
  800d5d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800d60:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800d63:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d66:	d3 e2                	shl    %cl,%edx
  800d68:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	09 c2                	or     %eax,%edx
  800d6f:	89 f9                	mov    %edi,%ecx
  800d71:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800d74:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800d77:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d7a:	89 f2                	mov    %esi,%edx
  800d7c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d7f:	d3 ea                	shr    %cl,%edx
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e6                	shl    %cl,%esi
  800d85:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d88:	d3 e8                	shr    %cl,%eax
  800d8a:	09 c6                	or     %eax,%esi
  800d8c:	89 f9                	mov    %edi,%ecx
  800d8e:	89 f0                	mov    %esi,%eax
  800d90:	f7 75 ec             	divl   0xffffffec(%ebp)
  800d93:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800d96:	89 d6                	mov    %edx,%esi
  800d98:	89 c7                	mov    %eax,%edi
  800d9a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d9d:	f7 e7                	mul    %edi
  800d9f:	39 f2                	cmp    %esi,%edx
  800da1:	77 15                	ja     800db8 <__udivdi3+0x138>
  800da3:	39 f2                	cmp    %esi,%edx
  800da5:	0f 94 c2             	sete   %dl
  800da8:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800dab:	0f 97 c0             	seta   %al
  800dae:	21 d0                	and    %edx,%eax
  800db0:	a8 01                	test   $0x1,%al
  800db2:	0f 84 07 ff ff ff    	je     800cbf <__udivdi3+0x3f>
  800db8:	4f                   	dec    %edi
  800db9:	e9 01 ff ff ff       	jmp    800cbf <__udivdi3+0x3f>
  800dbe:	90                   	nop    
  800dbf:	90                   	nop    

00800dc0 <__umoddi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	83 ec 38             	sub    $0x38,%esp
  800dc8:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800dcb:	8b 55 14             	mov    0x14(%ebp),%edx
  800dce:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd7:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800dde:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800de5:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800de8:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800deb:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800dee:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800df1:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800df4:	85 d2                	test   %edx,%edx
  800df6:	75 48                	jne    800e40 <__umoddi3+0x80>
  800df8:	39 f8                	cmp    %edi,%eax
  800dfa:	0f 86 d0 00 00 00    	jbe    800ed0 <__umoddi3+0x110>
  800e00:	89 f0                	mov    %esi,%eax
  800e02:	89 fa                	mov    %edi,%edx
  800e04:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800e07:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800e0a:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	74 49                	je     800e5a <__umoddi3+0x9a>
  800e11:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e14:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800e1b:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800e1e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800e21:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800e24:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800e27:	89 10                	mov    %edx,(%eax)
  800e29:	89 48 04             	mov    %ecx,0x4(%eax)
  800e2c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e2f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e32:	83 c4 38             	add    $0x38,%esp
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800e40:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e43:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800e46:	76 1f                	jbe    800e67 <__umoddi3+0xa7>
  800e48:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800e4b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e4e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e51:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e54:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800e57:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e5a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e5d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e60:	83 c4 38             	add    $0x38,%esp
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    
  800e67:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800e6b:	83 f0 1f             	xor    $0x1f,%eax
  800e6e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800e71:	0f 85 89 00 00 00    	jne    800f00 <__umoddi3+0x140>
  800e77:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e7a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800e7d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800e80:	0f 97 c2             	seta   %dl
  800e83:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800e86:	0f 93 c0             	setae  %al
  800e89:	09 d0                	or     %edx,%eax
  800e8b:	a8 01                	test   $0x1,%al
  800e8d:	74 11                	je     800ea0 <__umoddi3+0xe0>
  800e8f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e92:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e95:	29 c8                	sub    %ecx,%eax
  800e97:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800e9a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800e9d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800ea0:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800ea3:	85 c9                	test   %ecx,%ecx
  800ea5:	74 b3                	je     800e5a <__umoddi3+0x9a>
  800ea7:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800eaa:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800ead:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800eb0:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800eb3:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800eb6:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800eb9:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800ebc:	89 01                	mov    %eax,(%ecx)
  800ebe:	89 51 04             	mov    %edx,0x4(%ecx)
  800ec1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800ec4:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800ec7:	83 c4 38             	add    $0x38,%esp
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
  800ece:	89 f6                	mov    %esi,%esi
  800ed0:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  800ed3:	85 ff                	test   %edi,%edi
  800ed5:	75 0d                	jne    800ee4 <__umoddi3+0x124>
  800ed7:	b8 01 00 00 00       	mov    $0x1,%eax
  800edc:	31 d2                	xor    %edx,%edx
  800ede:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ee1:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800ee4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800ee7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800eea:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800eed:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ef0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800ef3:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ef6:	e9 0c ff ff ff       	jmp    800e07 <__umoddi3+0x47>
  800efb:	90                   	nop    
  800efc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800f00:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  800f03:	b8 20 00 00 00       	mov    $0x20,%eax
  800f08:	29 d0                	sub    %edx,%eax
  800f0a:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f0d:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800f10:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f13:	d3 e2                	shl    %cl,%edx
  800f15:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  800f18:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	09 c2                	or     %eax,%edx
  800f1f:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f22:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  800f25:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f28:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f2b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f2e:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  800f31:	d3 ea                	shr    %cl,%edx
  800f33:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f36:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f39:	d3 e6                	shl    %cl,%esi
  800f3b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f3e:	d3 e8                	shr    %cl,%eax
  800f40:	09 c6                	or     %eax,%esi
  800f42:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f45:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  800f48:	89 f0                	mov    %esi,%eax
  800f4a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f4d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  800f50:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f53:	f7 65 c4             	mull   0xffffffc4(%ebp)
  800f56:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f59:	89 d6                	mov    %edx,%esi
  800f5b:	89 c7                	mov    %eax,%edi
  800f5d:	77 12                	ja     800f71 <__umoddi3+0x1b1>
  800f5f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f62:	0f 94 c2             	sete   %dl
  800f65:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  800f68:	0f 97 c0             	seta   %al
  800f6b:	21 d0                	and    %edx,%eax
  800f6d:	a8 01                	test   $0x1,%al
  800f6f:	74 06                	je     800f77 <__umoddi3+0x1b7>
  800f71:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  800f74:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  800f77:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	0f 84 d8 fe ff ff    	je     800e5a <__umoddi3+0x9a>
  800f82:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f85:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f88:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f8b:	29 f8                	sub    %edi,%eax
  800f8d:	19 f2                	sbb    %esi,%edx
  800f8f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f92:	d3 e2                	shl    %cl,%edx
  800f94:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f97:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f9a:	d3 e8                	shr    %cl,%eax
  800f9c:	09 c2                	or     %eax,%edx
  800f9e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800fa1:	d3 e8                	shr    %cl,%eax
  800fa3:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  800fa6:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800fa9:	e9 70 fe ff ff       	jmp    800e1e <__umoddi3+0x5e>
  800fae:	90                   	nop    
  800faf:	90                   	nop    
