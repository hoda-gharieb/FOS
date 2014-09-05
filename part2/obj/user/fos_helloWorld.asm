
obj/user/fos_helloWorld:     file format elf32-i386

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
  800031:	e8 1a 00 00 00       	call   800050 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 84 94 00 00    	sub    $0x9484,%esp
	int Arr[9500] ;
	cprintf("HELLO WORLD , FOS IS SAYING HI :D:D:D\n");	
  800041:	68 80 0f 80 00       	push   $0x800f80
  800046:	e8 e5 00 00 00       	call   800130 <cprintf>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    
  80004d:	00 00                	add    %al,(%eax)
	...

00800050 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 08             	sub    $0x8,%esp
  800056:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  80005c:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800063:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c9                	test   %ecx,%ecx
  800068:	7e 07                	jle    800071 <libmain+0x21>
		binaryname = argv[0];
  80006a:	8b 02                	mov    (%edx),%eax
  80006c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	52                   	push   %edx
  800075:	51                   	push   %ecx
  800076:	e8 bd ff ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  80007b:	e8 13 00 00 00       	call   800093 <sleep>
}
  800080:	c9                   	leave  
  800081:	c3                   	ret    
	...

00800084 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  80008a:	6a 00                	push   $0x0
  80008c:	e8 60 0a 00 00       	call   800af1 <sys_env_destroy>
}
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <sleep>:

void
sleep(void)
{	
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800099:	e8 92 0a 00 00       	call   800b30 <sys_env_sleep>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 04             	sub    $0x4,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	40                   	inc    %eax
  8000b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bb:	75 1a                	jne    8000d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	68 ff 00 00 00       	push   $0xff
  8000c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c8:	50                   	push   %eax
  8000c9:	e8 e6 09 00 00       	call   800ab4 <sys_cputs>
		b->idx = 0;
  8000ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000d7:	ff 43 04             	incl   0x4(%ebx)
}
  8000da:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e8:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8000ef:	00 00 00 
	b.cnt = 0;
  8000f2:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8000f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	ff 75 08             	pushl  0x8(%ebp)
  800102:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	68 a0 00 80 00       	push   $0x8000a0
  80010e:	e8 2d 01 00 00       	call   800240 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800113:	83 c4 08             	add    $0x8,%esp
  800116:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  80011c:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  800122:	50                   	push   %eax
  800123:	e8 8c 09 00 00       	call   800ab4 <sys_cputs>

	return b.cnt;
  800128:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800136:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800139:	50                   	push   %eax
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	e8 9d ff ff ff       	call   8000df <vcprintf>
	va_end(ap);

	return cnt;
}
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	8b 75 10             	mov    0x10(%ebp),%esi
  800150:	8b 7d 14             	mov    0x14(%ebp),%edi
  800153:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800156:	8b 45 18             	mov    0x18(%ebp),%eax
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	39 d7                	cmp    %edx,%edi
  800160:	72 39                	jb     80019b <printnum+0x57>
  800162:	77 04                	ja     800168 <printnum+0x24>
  800164:	39 c6                	cmp    %eax,%esi
  800166:	72 33                	jb     80019b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	ff 75 20             	pushl  0x20(%ebp)
  80016e:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800171:	50                   	push   %eax
  800172:	ff 75 18             	pushl  0x18(%ebp)
  800175:	8b 45 18             	mov    0x18(%ebp),%eax
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	52                   	push   %edx
  80017e:	50                   	push   %eax
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	e8 ba 0a 00 00       	call   800c40 <__udivdi3>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	52                   	push   %edx
  80018a:	50                   	push   %eax
  80018b:	ff 75 0c             	pushl  0xc(%ebp)
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 ae ff ff ff       	call   800144 <printnum>
  800196:	83 c4 20             	add    $0x20,%esp
  800199:	eb 19                	jmp    8001b4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80019b:	4b                   	dec    %ebx
  80019c:	85 db                	test   %ebx,%ebx
  80019e:	7e 14                	jle    8001b4 <printnum+0x70>
			putch(padc, putdat);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 0c             	pushl  0xc(%ebp)
  8001a6:	ff 75 20             	pushl  0x20(%ebp)
  8001a9:	ff 55 08             	call   *0x8(%ebp)
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	4b                   	dec    %ebx
  8001b0:	85 db                	test   %ebx,%ebx
  8001b2:	7f ec                	jg     8001a0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8001bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c2:	83 ec 04             	sub    $0x4,%esp
  8001c5:	52                   	push   %edx
  8001c6:	50                   	push   %eax
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	e8 b2 0b 00 00       	call   800d80 <__umoddi3>
  8001ce:	83 c4 14             	add    $0x14,%esp
  8001d1:	0f be 80 27 10 80 00 	movsbl 0x801027(%eax),%eax
  8001d8:	50                   	push   %eax
  8001d9:	ff 55 08             	call   *0x8(%ebp)
}
  8001dc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8001ed:	83 f8 01             	cmp    $0x1,%eax
  8001f0:	7e 0f                	jle    800201 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8001f2:	8b 01                	mov    (%ecx),%eax
  8001f4:	83 c0 08             	add    $0x8,%eax
  8001f7:	89 01                	mov    %eax,(%ecx)
  8001f9:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8001fc:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8001ff:	eb 0f                	jmp    800210 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800201:	8b 01                	mov    (%ecx),%eax
  800203:	83 c0 04             	add    $0x4,%eax
  800206:	89 01                	mov    %eax,(%ecx)
  800208:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  80020b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	8b 55 08             	mov    0x8(%ebp),%edx
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80021b:	83 f8 01             	cmp    $0x1,%eax
  80021e:	7e 0f                	jle    80022f <getint+0x1d>
		return va_arg(*ap, long long);
  800220:	8b 02                	mov    (%edx),%eax
  800222:	83 c0 08             	add    $0x8,%eax
  800225:	89 02                	mov    %eax,(%edx)
  800227:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  80022a:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80022d:	eb 0f                	jmp    80023e <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	83 c0 04             	add    $0x4,%eax
  800234:	89 02                	mov    %eax,(%edx)
  800236:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800239:	89 c2                	mov    %eax,%edx
  80023b:	c1 fa 1f             	sar    $0x1f,%edx
}
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 1c             	sub    $0x1c,%esp
  800249:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80024c:	ba 00 00 00 00       	mov    $0x0,%edx
  800251:	8a 13                	mov    (%ebx),%dl
  800253:	43                   	inc    %ebx
  800254:	83 fa 25             	cmp    $0x25,%edx
  800257:	74 22                	je     80027b <vprintfmt+0x3b>
			if (ch == '\0')
  800259:	85 d2                	test   %edx,%edx
  80025b:	0f 84 cd 02 00 00    	je     80052e <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	52                   	push   %edx
  800268:	ff 55 08             	call   *0x8(%ebp)
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	8a 13                	mov    (%ebx),%dl
  800275:	43                   	inc    %ebx
  800276:	83 fa 25             	cmp    $0x25,%edx
  800279:	75 de                	jne    800259 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  80027b:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  80027f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800286:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80028b:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800290:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	8a 13                	mov    (%ebx),%dl
  80029e:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002a1:	43                   	inc    %ebx
  8002a2:	83 f8 55             	cmp    $0x55,%eax
  8002a5:	0f 87 5e 02 00 00    	ja     800509 <vprintfmt+0x2c9>
  8002ab:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002b2:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8002b6:	eb df                	jmp    800297 <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b8:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8002bc:	eb d9                	jmp    800297 <vprintfmt+0x57>

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
  8002be:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002c3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002c6:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8002ca:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8002cd:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8002d0:	83 f8 09             	cmp    $0x9,%eax
  8002d3:	77 27                	ja     8002fc <vprintfmt+0xbc>
  8002d5:	43                   	inc    %ebx
  8002d6:	eb eb                	jmp    8002c3 <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002d8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8002dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002df:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8002e2:	eb 18                	jmp    8002fc <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  8002e4:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8002e8:	79 ad                	jns    800297 <vprintfmt+0x57>
				width = 0;
  8002ea:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8002f1:	eb a4                	jmp    800297 <vprintfmt+0x57>

		case '#':
			altflag = 1;
  8002f3:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8002fa:	eb 9b                	jmp    800297 <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  8002fc:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800300:	79 95                	jns    800297 <vprintfmt+0x57>
				width = precision, precision = -1;
  800302:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800305:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80030a:	eb 8b                	jmp    800297 <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80030c:	41                   	inc    %ecx
			goto reswitch;
  80030d:	eb 88                	jmp    800297 <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800319:	8b 45 14             	mov    0x14(%ebp),%eax
  80031c:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80031f:	e9 da 01 00 00       	jmp    8004fe <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800324:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800328:	8b 45 14             	mov    0x14(%ebp),%eax
  80032b:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	79 02                	jns    800334 <vprintfmt+0xf4>
				err = -err;
  800332:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800334:	83 f8 07             	cmp    $0x7,%eax
  800337:	7f 0b                	jg     800344 <vprintfmt+0x104>
  800339:	8b 3c 85 60 10 80 00 	mov    0x801060(,%eax,4),%edi
  800340:	85 ff                	test   %edi,%edi
  800342:	75 08                	jne    80034c <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  800344:	50                   	push   %eax
  800345:	68 38 10 80 00       	push   $0x801038
  80034a:	eb 06                	jmp    800352 <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  80034c:	57                   	push   %edi
  80034d:	68 41 10 80 00       	push   $0x801041
  800352:	ff 75 0c             	pushl  0xc(%ebp)
  800355:	ff 75 08             	pushl  0x8(%ebp)
  800358:	e8 d9 01 00 00       	call   800536 <printfmt>
  80035d:	e9 9f 01 00 00       	jmp    800501 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800362:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  80036c:	85 ff                	test   %edi,%edi
  80036e:	75 05                	jne    800375 <vprintfmt+0x135>
				p = "(null)";
  800370:	bf 44 10 80 00       	mov    $0x801044,%edi
			if (width > 0 && padc != '-')
  800375:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800379:	0f 9f c2             	setg   %dl
  80037c:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800380:	0f 95 c0             	setne  %al
  800383:	21 d0                	and    %edx,%eax
  800385:	a8 01                	test   $0x1,%al
  800387:	74 35                	je     8003be <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	56                   	push   %esi
  80038d:	57                   	push   %edi
  80038e:	e8 5e 02 00 00       	call   8005f1 <strnlen>
  800393:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80039d:	7e 1f                	jle    8003be <vprintfmt+0x17e>
  80039f:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003a3:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ac:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003af:	ff 55 08             	call   *0x8(%ebp)
  8003b2:	83 c4 10             	add    $0x10,%esp
  8003b5:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003b8:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003bc:	7f e8                	jg     8003a6 <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8003be:	0f be 17             	movsbl (%edi),%edx
  8003c1:	47                   	inc    %edi
  8003c2:	85 d2                	test   %edx,%edx
  8003c4:	74 3e                	je     800404 <vprintfmt+0x1c4>
  8003c6:	85 f6                	test   %esi,%esi
  8003c8:	78 03                	js     8003cd <vprintfmt+0x18d>
  8003ca:	4e                   	dec    %esi
  8003cb:	78 37                	js     800404 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  8003cd:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8003d1:	74 12                	je     8003e5 <vprintfmt+0x1a5>
  8003d3:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8003d6:	83 f8 5e             	cmp    $0x5e,%eax
  8003d9:	76 0a                	jbe    8003e5 <vprintfmt+0x1a5>
					putch('?', putdat);
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	6a 3f                	push   $0x3f
  8003e3:	eb 07                	jmp    8003ec <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	52                   	push   %edx
  8003ec:	ff 55 08             	call   *0x8(%ebp)
  8003ef:	83 c4 10             	add    $0x10,%esp
  8003f2:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003f5:	0f be 17             	movsbl (%edi),%edx
  8003f8:	47                   	inc    %edi
  8003f9:	85 d2                	test   %edx,%edx
  8003fb:	74 07                	je     800404 <vprintfmt+0x1c4>
  8003fd:	85 f6                	test   %esi,%esi
  8003ff:	78 cc                	js     8003cd <vprintfmt+0x18d>
  800401:	4e                   	dec    %esi
  800402:	79 c9                	jns    8003cd <vprintfmt+0x18d>
			for (; width > 0; width--)
  800404:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800408:	0f 8e 3e fe ff ff    	jle    80024c <vprintfmt+0xc>
				putch(' ', putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	ff 75 0c             	pushl  0xc(%ebp)
  800414:	6a 20                	push   $0x20
  800416:	ff 55 08             	call   *0x8(%ebp)
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80041f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800423:	7f e9                	jg     80040e <vprintfmt+0x1ce>
			break;
  800425:	e9 22 fe ff ff       	jmp    80024c <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	51                   	push   %ecx
  80042e:	8d 45 14             	lea    0x14(%ebp),%eax
  800431:	50                   	push   %eax
  800432:	e8 db fd ff ff       	call   800212 <getint>
  800437:	89 c6                	mov    %eax,%esi
  800439:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	85 d2                	test   %edx,%edx
  800440:	79 15                	jns    800457 <vprintfmt+0x217>
				putch('-', putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	ff 75 0c             	pushl  0xc(%ebp)
  800448:	6a 2d                	push   $0x2d
  80044a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80044d:	f7 de                	neg    %esi
  80044f:	83 d7 00             	adc    $0x0,%edi
  800452:	f7 df                	neg    %edi
  800454:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800457:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80045c:	eb 78                	jmp    8004d6 <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	51                   	push   %ecx
  800462:	8d 45 14             	lea    0x14(%ebp),%eax
  800465:	50                   	push   %eax
  800466:	e8 79 fd ff ff       	call   8001e4 <getuint>
  80046b:	89 c6                	mov    %eax,%esi
  80046d:	89 d7                	mov    %edx,%edi
			base = 10;
  80046f:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800474:	eb 5d                	jmp    8004d3 <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 0c             	pushl  0xc(%ebp)
  80047c:	6a 58                	push   $0x58
  80047e:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800481:	83 c4 08             	add    $0x8,%esp
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	6a 58                	push   $0x58
  800489:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80048c:	83 c4 08             	add    $0x8,%esp
  80048f:	ff 75 0c             	pushl  0xc(%ebp)
  800492:	6a 58                	push   $0x58
  800494:	eb 68                	jmp    8004fe <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	ff 75 0c             	pushl  0xc(%ebp)
  80049c:	6a 30                	push   $0x30
  80049e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004a1:	83 c4 08             	add    $0x8,%esp
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	6a 78                	push   $0x78
  8004a9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004ac:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8004b6:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  8004bb:	eb 11                	jmp    8004ce <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	51                   	push   %ecx
  8004c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8004c4:	50                   	push   %eax
  8004c5:	e8 1a fd ff ff       	call   8001e4 <getuint>
  8004ca:	89 c6                	mov    %eax,%esi
  8004cc:	89 d7                	mov    %edx,%edi
			base = 16;
  8004ce:	ba 10 00 00 00       	mov    $0x10,%edx
  8004d3:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8004d6:	83 ec 04             	sub    $0x4,%esp
  8004d9:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8004dd:	50                   	push   %eax
  8004de:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8004e1:	52                   	push   %edx
  8004e2:	57                   	push   %edi
  8004e3:	56                   	push   %esi
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	ff 75 08             	pushl  0x8(%ebp)
  8004ea:	e8 55 fc ff ff       	call   800144 <printnum>
			break;
  8004ef:	83 c4 20             	add    $0x20,%esp
  8004f2:	e9 55 fd ff ff       	jmp    80024c <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	52                   	push   %edx
  8004fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	e9 43 fd ff ff       	jmp    80024c <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	ff 75 0c             	pushl  0xc(%ebp)
  80050f:	6a 25                	push   $0x25
  800511:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800514:	4b                   	dec    %ebx
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80051c:	0f 84 2a fd ff ff    	je     80024c <vprintfmt+0xc>
  800522:	4b                   	dec    %ebx
  800523:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800527:	75 f9                	jne    800522 <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800529:	e9 1e fd ff ff       	jmp    80024c <vprintfmt+0xc>
		}
	}
}
  80052e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800531:	5b                   	pop    %ebx
  800532:	5e                   	pop    %esi
  800533:	5f                   	pop    %edi
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    

00800536 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80053c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053f:	50                   	push   %eax
  800540:	ff 75 10             	pushl  0x10(%ebp)
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 f2 fc ff ff       	call   800240 <vprintfmt>
	va_end(ap);
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800556:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800559:	8b 0a                	mov    (%edx),%ecx
  80055b:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80055e:	73 07                	jae    800567 <sprintputch+0x17>
		*b->buf++ = ch;
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	88 01                	mov    %al,(%ecx)
  800565:	ff 02                	incl   (%edx)
}
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	83 ec 18             	sub    $0x18,%esp
  80056f:	8b 55 08             	mov    0x8(%ebp),%edx
  800572:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800575:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800578:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  80057c:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80057f:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800586:	85 d2                	test   %edx,%edx
  800588:	0f 94 c2             	sete   %dl
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	0f 9e c0             	setle  %al
  800590:	09 d0                	or     %edx,%eax
  800592:	ba 03 00 00 00       	mov    $0x3,%edx
  800597:	a8 01                	test   $0x1,%al
  800599:	75 1d                	jne    8005b8 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80059b:	ff 75 14             	pushl  0x14(%ebp)
  80059e:	ff 75 10             	pushl  0x10(%ebp)
  8005a1:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005a4:	50                   	push   %eax
  8005a5:	68 50 05 80 00       	push   $0x800550
  8005aa:	e8 91 fc ff ff       	call   800240 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005af:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8005b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005b5:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  8005b8:	89 d0                	mov    %edx,%eax
  8005ba:	c9                   	leave  
  8005bb:	c3                   	ret    

008005bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8005c5:	50                   	push   %eax
  8005c6:	ff 75 10             	pushl  0x10(%ebp)
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	ff 75 08             	pushl  0x8(%ebp)
  8005cf:	e8 95 ff ff ff       	call   800569 <vsnprintf>
	va_end(ap);

	return rc;
}
  8005d4:	c9                   	leave  
  8005d5:	c3                   	ret    
	...

008005d8 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8005de:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e3:	80 3a 00             	cmpb   $0x0,(%edx)
  8005e6:	74 07                	je     8005ef <strlen+0x17>
		n++;
  8005e8:	40                   	inc    %eax
  8005e9:	42                   	inc    %edx
  8005ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8005ed:	75 f9                	jne    8005e8 <strlen+0x10>
	return n;
}
  8005ef:	5d                   	pop    %ebp
  8005f0:	c3                   	ret    

008005f1 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8005fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ff:	85 d2                	test   %edx,%edx
  800601:	74 0f                	je     800612 <strnlen+0x21>
  800603:	80 39 00             	cmpb   $0x0,(%ecx)
  800606:	74 0a                	je     800612 <strnlen+0x21>
		n++;
  800608:	40                   	inc    %eax
  800609:	41                   	inc    %ecx
  80060a:	4a                   	dec    %edx
  80060b:	74 05                	je     800612 <strnlen+0x21>
  80060d:	80 39 00             	cmpb   $0x0,(%ecx)
  800610:	75 f6                	jne    800608 <strnlen+0x17>
	return n;
}
  800612:	5d                   	pop    %ebp
  800613:	c3                   	ret    

00800614 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	53                   	push   %ebx
  800618:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80061e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800620:	8a 02                	mov    (%edx),%al
  800622:	88 01                	mov    %al,(%ecx)
  800624:	42                   	inc    %edx
  800625:	41                   	inc    %ecx
  800626:	84 c0                	test   %al,%al
  800628:	75 f6                	jne    800620 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80062a:	89 d8                	mov    %ebx,%eax
  80062c:	5b                   	pop    %ebx
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	57                   	push   %edi
  800633:	56                   	push   %esi
  800634:	53                   	push   %ebx
  800635:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063b:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  80063e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800640:	bb 00 00 00 00       	mov    $0x0,%ebx
  800645:	39 f3                	cmp    %esi,%ebx
  800647:	73 17                	jae    800660 <strncpy+0x31>
		*dst++ = *src;
  800649:	8a 02                	mov    (%edx),%al
  80064b:	88 01                	mov    %al,(%ecx)
  80064d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80064e:	80 3a 00             	cmpb   $0x0,(%edx)
  800651:	0f 95 c0             	setne  %al
  800654:	25 ff 00 00 00       	and    $0xff,%eax
  800659:	01 c2                	add    %eax,%edx
  80065b:	43                   	inc    %ebx
  80065c:	39 f3                	cmp    %esi,%ebx
  80065e:	72 e9                	jb     800649 <strncpy+0x1a>
			src++;
	}
	return ret;
}
  800660:	89 f8                	mov    %edi,%eax
  800662:	5b                   	pop    %ebx
  800663:	5e                   	pop    %esi
  800664:	5f                   	pop    %edi
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    

00800667 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	56                   	push   %esi
  80066b:	53                   	push   %ebx
  80066c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80066f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800672:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800675:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800677:	85 d2                	test   %edx,%edx
  800679:	74 19                	je     800694 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  80067b:	4a                   	dec    %edx
  80067c:	74 13                	je     800691 <strlcpy+0x2a>
  80067e:	80 39 00             	cmpb   $0x0,(%ecx)
  800681:	74 0e                	je     800691 <strlcpy+0x2a>
			*dst++ = *src++;
  800683:	8a 01                	mov    (%ecx),%al
  800685:	88 03                	mov    %al,(%ebx)
  800687:	41                   	inc    %ecx
  800688:	43                   	inc    %ebx
  800689:	4a                   	dec    %edx
  80068a:	74 05                	je     800691 <strlcpy+0x2a>
  80068c:	80 39 00             	cmpb   $0x0,(%ecx)
  80068f:	75 f2                	jne    800683 <strlcpy+0x1c>
		*dst = '\0';
  800691:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800694:	89 d8                	mov    %ebx,%eax
  800696:	29 f0                	sub    %esi,%eax
}
  800698:	5b                   	pop    %ebx
  800699:	5e                   	pop    %esi
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8006a5:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a8:	74 13                	je     8006bd <strcmp+0x21>
  8006aa:	8a 02                	mov    (%edx),%al
  8006ac:	3a 01                	cmp    (%ecx),%al
  8006ae:	75 0d                	jne    8006bd <strcmp+0x21>
		p++, q++;
  8006b0:	42                   	inc    %edx
  8006b1:	41                   	inc    %ecx
  8006b2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b5:	74 06                	je     8006bd <strcmp+0x21>
  8006b7:	8a 02                	mov    (%edx),%al
  8006b9:	3a 01                	cmp    (%ecx),%al
  8006bb:	74 f3                	je     8006b0 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	8a 02                	mov    (%edx),%al
  8006c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c9:	8a 11                	mov    (%ecx),%dl
  8006cb:	29 d0                	sub    %edx,%eax
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	53                   	push   %ebx
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 1f                	je     8006ff <strncmp+0x30>
  8006e0:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e3:	74 16                	je     8006fb <strncmp+0x2c>
  8006e5:	8a 02                	mov    (%edx),%al
  8006e7:	3a 03                	cmp    (%ebx),%al
  8006e9:	75 10                	jne    8006fb <strncmp+0x2c>
		n--, p++, q++;
  8006eb:	42                   	inc    %edx
  8006ec:	43                   	inc    %ebx
  8006ed:	49                   	dec    %ecx
  8006ee:	74 0f                	je     8006ff <strncmp+0x30>
  8006f0:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f3:	74 06                	je     8006fb <strncmp+0x2c>
  8006f5:	8a 02                	mov    (%edx),%al
  8006f7:	3a 03                	cmp    (%ebx),%al
  8006f9:	74 f0                	je     8006eb <strncmp+0x1c>
	if (n == 0)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	75 07                	jne    800706 <strncmp+0x37>
		return 0;
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 13                	jmp    800719 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800706:	8a 12                	mov    (%edx),%dl
  800708:	81 e2 ff 00 00 00    	and    $0xff,%edx
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	8a 03                	mov    (%ebx),%al
  800715:	29 c2                	sub    %eax,%edx
  800717:	89 d0                	mov    %edx,%eax
}
  800719:	5b                   	pop    %ebx
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
  800722:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800725:	80 3a 00             	cmpb   $0x0,(%edx)
  800728:	74 0c                	je     800736 <strchr+0x1a>
		if (*s == c)
  80072a:	89 d0                	mov    %edx,%eax
  80072c:	38 0a                	cmp    %cl,(%edx)
  80072e:	74 0b                	je     80073b <strchr+0x1f>
  800730:	42                   	inc    %edx
  800731:	80 3a 00             	cmpb   $0x0,(%edx)
  800734:	75 f4                	jne    80072a <strchr+0xe>
			return (char *) s;
	return 0;
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800746:	80 38 00             	cmpb   $0x0,(%eax)
  800749:	74 0a                	je     800755 <strfind+0x18>
		if (*s == c)
  80074b:	38 10                	cmp    %dl,(%eax)
  80074d:	74 06                	je     800755 <strfind+0x18>
  80074f:	40                   	inc    %eax
  800750:	80 38 00             	cmpb   $0x0,(%eax)
  800753:	75 f6                	jne    80074b <strfind+0xe>
			break;
	return (char *) s;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  800761:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  800763:	8b 55 10             	mov    0x10(%ebp),%edx
  800766:	4a                   	dec    %edx
  800767:	78 06                	js     80076f <memset+0x18>
		*p++ = c;
  800769:	88 01                	mov    %al,(%ecx)
  80076b:	41                   	inc    %ecx
  80076c:	4a                   	dec    %edx
  80076d:	79 fa                	jns    800769 <memset+0x12>

	return v;
}
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	5b                   	pop    %ebx
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	56                   	push   %esi
  800778:	53                   	push   %ebx
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  800782:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  800784:	89 c8                	mov    %ecx,%eax
  800786:	49                   	dec    %ecx
  800787:	85 c0                	test   %eax,%eax
  800789:	74 0d                	je     800798 <memcpy+0x24>
		*d++ = *s++;
  80078b:	8a 03                	mov    (%ebx),%al
  80078d:	88 02                	mov    %al,(%edx)
  80078f:	43                   	inc    %ebx
  800790:	42                   	inc    %edx
  800791:	89 c8                	mov    %ecx,%eax
  800793:	49                   	dec    %ecx
  800794:	85 c0                	test   %eax,%eax
  800796:	75 f3                	jne    80078b <memcpy+0x17>

	return dst;
}
  800798:	89 f0                	mov    %esi,%eax
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  8007ac:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  8007ae:	39 f1                	cmp    %esi,%ecx
  8007b0:	73 22                	jae    8007d4 <memmove+0x36>
  8007b2:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  8007b5:	39 f0                	cmp    %esi,%eax
  8007b7:	76 1b                	jbe    8007d4 <memmove+0x36>
		s += n;
  8007b9:	89 c1                	mov    %eax,%ecx
		d += n;
  8007bb:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  8007be:	89 d0                	mov    %edx,%eax
  8007c0:	4a                   	dec    %edx
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	74 23                	je     8007e8 <memmove+0x4a>
			*--d = *--s;
  8007c5:	4b                   	dec    %ebx
  8007c6:	49                   	dec    %ecx
  8007c7:	8a 01                	mov    (%ecx),%al
  8007c9:	88 03                	mov    %al,(%ebx)
  8007cb:	89 d0                	mov    %edx,%eax
  8007cd:	4a                   	dec    %edx
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	75 f3                	jne    8007c5 <memmove+0x27>
  8007d2:	eb 14                	jmp    8007e8 <memmove+0x4a>
	} else
		while (n-- > 0)
  8007d4:	89 d0                	mov    %edx,%eax
  8007d6:	4a                   	dec    %edx
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 0d                	je     8007e8 <memmove+0x4a>
			*d++ = *s++;
  8007db:	8a 01                	mov    (%ecx),%al
  8007dd:	88 03                	mov    %al,(%ebx)
  8007df:	41                   	inc    %ecx
  8007e0:	43                   	inc    %ebx
  8007e1:	89 d0                	mov    %edx,%eax
  8007e3:	4a                   	dec    %edx
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	75 f3                	jne    8007db <memmove+0x3d>

	return dst;
}
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  8007f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8007fb:	89 d0                	mov    %edx,%eax
  8007fd:	4a                   	dec    %edx
  8007fe:	85 c0                	test   %eax,%eax
  800800:	74 23                	je     800825 <memcmp+0x37>
		if (*s1 != *s2)
  800802:	8a 01                	mov    (%ecx),%al
  800804:	3a 03                	cmp    (%ebx),%al
  800806:	74 14                	je     80081c <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  800808:	ba 00 00 00 00       	mov    $0x0,%edx
  80080d:	8a 11                	mov    (%ecx),%dl
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	8a 03                	mov    (%ebx),%al
  800816:	29 c2                	sub    %eax,%edx
  800818:	89 d0                	mov    %edx,%eax
  80081a:	eb 0e                	jmp    80082a <memcmp+0x3c>
		s1++, s2++;
  80081c:	41                   	inc    %ecx
  80081d:	43                   	inc    %ebx
  80081e:	89 d0                	mov    %edx,%eax
  800820:	4a                   	dec    %edx
  800821:	85 c0                	test   %eax,%eax
  800823:	75 dd                	jne    800802 <memcmp+0x14>
	}

	return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800836:	89 c2                	mov    %eax,%edx
  800838:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80083b:	39 d0                	cmp    %edx,%eax
  80083d:	73 09                	jae    800848 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80083f:	38 08                	cmp    %cl,(%eax)
  800841:	74 05                	je     800848 <memfind+0x1b>
  800843:	40                   	inc    %eax
  800844:	39 d0                	cmp    %edx,%eax
  800846:	72 f7                	jb     80083f <memfind+0x12>
			break;
	return (void *) s;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	83 ec 04             	sub    $0x4,%esp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800859:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  80085c:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  800863:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800868:	80 39 20             	cmpb   $0x20,(%ecx)
  80086b:	0f 94 c2             	sete   %dl
  80086e:	80 39 09             	cmpb   $0x9,(%ecx)
  800871:	0f 94 c0             	sete   %al
  800874:	09 d0                	or     %edx,%eax
  800876:	a8 01                	test   $0x1,%al
  800878:	74 13                	je     80088d <strtol+0x43>
		s++;
  80087a:	41                   	inc    %ecx
  80087b:	80 39 20             	cmpb   $0x20,(%ecx)
  80087e:	0f 94 c2             	sete   %dl
  800881:	80 39 09             	cmpb   $0x9,(%ecx)
  800884:	0f 94 c0             	sete   %al
  800887:	09 d0                	or     %edx,%eax
  800889:	a8 01                	test   $0x1,%al
  80088b:	75 ed                	jne    80087a <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  80088d:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800890:	75 03                	jne    800895 <strtol+0x4b>
		s++;
  800892:	41                   	inc    %ecx
  800893:	eb 0d                	jmp    8008a2 <strtol+0x58>
	else if (*s == '-')
  800895:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800898:	75 08                	jne    8008a2 <strtol+0x58>
		s++, neg = 1;
  80089a:	41                   	inc    %ecx
  80089b:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008a2:	85 db                	test   %ebx,%ebx
  8008a4:	0f 94 c2             	sete   %dl
  8008a7:	83 fb 10             	cmp    $0x10,%ebx
  8008aa:	0f 94 c0             	sete   %al
  8008ad:	09 d0                	or     %edx,%eax
  8008af:	a8 01                	test   $0x1,%al
  8008b1:	74 15                	je     8008c8 <strtol+0x7e>
  8008b3:	80 39 30             	cmpb   $0x30,(%ecx)
  8008b6:	75 10                	jne    8008c8 <strtol+0x7e>
  8008b8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8008bc:	75 0a                	jne    8008c8 <strtol+0x7e>
		s += 2, base = 16;
  8008be:	83 c1 02             	add    $0x2,%ecx
  8008c1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8008c6:	eb 1a                	jmp    8008e2 <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  8008c8:	85 db                	test   %ebx,%ebx
  8008ca:	75 16                	jne    8008e2 <strtol+0x98>
  8008cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8008cf:	75 08                	jne    8008d9 <strtol+0x8f>
		s++, base = 8;
  8008d1:	41                   	inc    %ecx
  8008d2:	bb 08 00 00 00       	mov    $0x8,%ebx
  8008d7:	eb 09                	jmp    8008e2 <strtol+0x98>
	else if (base == 0)
  8008d9:	85 db                	test   %ebx,%ebx
  8008db:	75 05                	jne    8008e2 <strtol+0x98>
		base = 10;
  8008dd:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8008e2:	8a 01                	mov    (%ecx),%al
  8008e4:	83 e8 30             	sub    $0x30,%eax
  8008e7:	3c 09                	cmp    $0x9,%al
  8008e9:	77 08                	ja     8008f3 <strtol+0xa9>
			dig = *s - '0';
  8008eb:	0f be 01             	movsbl (%ecx),%eax
  8008ee:	83 e8 30             	sub    $0x30,%eax
  8008f1:	eb 20                	jmp    800913 <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  8008f3:	8a 01                	mov    (%ecx),%al
  8008f5:	83 e8 61             	sub    $0x61,%eax
  8008f8:	3c 19                	cmp    $0x19,%al
  8008fa:	77 08                	ja     800904 <strtol+0xba>
			dig = *s - 'a' + 10;
  8008fc:	0f be 01             	movsbl (%ecx),%eax
  8008ff:	83 e8 57             	sub    $0x57,%eax
  800902:	eb 0f                	jmp    800913 <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800904:	8a 01                	mov    (%ecx),%al
  800906:	83 e8 41             	sub    $0x41,%eax
  800909:	3c 19                	cmp    $0x19,%al
  80090b:	77 12                	ja     80091f <strtol+0xd5>
			dig = *s - 'A' + 10;
  80090d:	0f be 01             	movsbl (%ecx),%eax
  800910:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800913:	39 d8                	cmp    %ebx,%eax
  800915:	7d 08                	jge    80091f <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  800917:	41                   	inc    %ecx
  800918:	0f af f3             	imul   %ebx,%esi
  80091b:	01 c6                	add    %eax,%esi
  80091d:	eb c3                	jmp    8008e2 <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  80091f:	85 ff                	test   %edi,%edi
  800921:	74 02                	je     800925 <strtol+0xdb>
		*endptr = (char *) s;
  800923:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800925:	89 f0                	mov    %esi,%eax
  800927:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80092b:	74 02                	je     80092f <strtol+0xe5>
  80092d:	f7 d8                	neg    %eax
}
  80092f:	83 c4 04             	add    $0x4,%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	83 ec 04             	sub    $0x4,%esp
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800949:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800950:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800955:	80 39 20             	cmpb   $0x20,(%ecx)
  800958:	0f 94 c2             	sete   %dl
  80095b:	80 39 09             	cmpb   $0x9,(%ecx)
  80095e:	0f 94 c0             	sete   %al
  800961:	09 d0                	or     %edx,%eax
  800963:	a8 01                	test   $0x1,%al
  800965:	74 13                	je     80097a <strtoul+0x43>
		s++;
  800967:	41                   	inc    %ecx
  800968:	80 39 20             	cmpb   $0x20,(%ecx)
  80096b:	0f 94 c2             	sete   %dl
  80096e:	80 39 09             	cmpb   $0x9,(%ecx)
  800971:	0f 94 c0             	sete   %al
  800974:	09 d0                	or     %edx,%eax
  800976:	a8 01                	test   $0x1,%al
  800978:	75 ed                	jne    800967 <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  80097a:	80 39 2b             	cmpb   $0x2b,(%ecx)
  80097d:	75 03                	jne    800982 <strtoul+0x4b>
		s++;
  80097f:	41                   	inc    %ecx
  800980:	eb 0d                	jmp    80098f <strtoul+0x58>
	else if (*s == '-')
  800982:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800985:	75 08                	jne    80098f <strtoul+0x58>
		s++, neg = 1;
  800987:	41                   	inc    %ecx
  800988:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098f:	85 db                	test   %ebx,%ebx
  800991:	0f 94 c2             	sete   %dl
  800994:	83 fb 10             	cmp    $0x10,%ebx
  800997:	0f 94 c0             	sete   %al
  80099a:	09 d0                	or     %edx,%eax
  80099c:	a8 01                	test   $0x1,%al
  80099e:	74 15                	je     8009b5 <strtoul+0x7e>
  8009a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a3:	75 10                	jne    8009b5 <strtoul+0x7e>
  8009a5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a9:	75 0a                	jne    8009b5 <strtoul+0x7e>
		s += 2, base = 16;
  8009ab:	83 c1 02             	add    $0x2,%ecx
  8009ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b3:	eb 1a                	jmp    8009cf <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  8009b5:	85 db                	test   %ebx,%ebx
  8009b7:	75 16                	jne    8009cf <strtoul+0x98>
  8009b9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bc:	75 08                	jne    8009c6 <strtoul+0x8f>
		s++, base = 8;
  8009be:	41                   	inc    %ecx
  8009bf:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009c4:	eb 09                	jmp    8009cf <strtoul+0x98>
	else if (base == 0)
  8009c6:	85 db                	test   %ebx,%ebx
  8009c8:	75 05                	jne    8009cf <strtoul+0x98>
		base = 10;
  8009ca:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cf:	8a 01                	mov    (%ecx),%al
  8009d1:	83 e8 30             	sub    $0x30,%eax
  8009d4:	3c 09                	cmp    $0x9,%al
  8009d6:	77 08                	ja     8009e0 <strtoul+0xa9>
			dig = *s - '0';
  8009d8:	0f be 01             	movsbl (%ecx),%eax
  8009db:	83 e8 30             	sub    $0x30,%eax
  8009de:	eb 20                	jmp    800a00 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  8009e0:	8a 01                	mov    (%ecx),%al
  8009e2:	83 e8 61             	sub    $0x61,%eax
  8009e5:	3c 19                	cmp    $0x19,%al
  8009e7:	77 08                	ja     8009f1 <strtoul+0xba>
			dig = *s - 'a' + 10;
  8009e9:	0f be 01             	movsbl (%ecx),%eax
  8009ec:	83 e8 57             	sub    $0x57,%eax
  8009ef:	eb 0f                	jmp    800a00 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  8009f1:	8a 01                	mov    (%ecx),%al
  8009f3:	83 e8 41             	sub    $0x41,%eax
  8009f6:	3c 19                	cmp    $0x19,%al
  8009f8:	77 12                	ja     800a0c <strtoul+0xd5>
			dig = *s - 'A' + 10;
  8009fa:	0f be 01             	movsbl (%ecx),%eax
  8009fd:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a00:	39 d8                	cmp    %ebx,%eax
  800a02:	7d 08                	jge    800a0c <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a04:	41                   	inc    %ecx
  800a05:	0f af f3             	imul   %ebx,%esi
  800a08:	01 c6                	add    %eax,%esi
  800a0a:	eb c3                	jmp    8009cf <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800a0c:	85 ff                	test   %edi,%edi
  800a0e:	74 02                	je     800a12 <strtoul+0xdb>
		*endptr = (char *) s;
  800a10:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a12:	89 f0                	mov    %esi,%eax
  800a14:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a18:	74 02                	je     800a1c <strtoul+0xe5>
  800a1a:	f7 d8                	neg    %eax
}
  800a1c:	83 c4 04             	add    $0x4,%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	83 ec 0c             	sub    $0xc,%esp
  800a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800a36:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800a45:	eb 04                	jmp    800a4b <strsplit+0x27>
			*string++ = 0;
  800a47:	c6 03 00             	movb   $0x0,(%ebx)
  800a4a:	43                   	inc    %ebx
  800a4b:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a4e:	74 4b                	je     800a9b <strsplit+0x77>
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	0f be 03             	movsbl (%ebx),%eax
  800a56:	50                   	push   %eax
  800a57:	56                   	push   %esi
  800a58:	e8 bf fc ff ff       	call   80071c <strchr>
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	85 c0                	test   %eax,%eax
  800a62:	75 e3                	jne    800a47 <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800a64:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a67:	74 32                	je     800a9b <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	83 3f 0f             	cmpl   $0xf,(%edi)
  800a71:	74 39                	je     800aac <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800a73:	8b 07                	mov    (%edi),%eax
  800a75:	8b 55 10             	mov    0x10(%ebp),%edx
  800a78:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800a7b:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800a7d:	eb 01                	jmp    800a80 <strsplit+0x5c>
			string++;
  800a7f:	43                   	inc    %ebx
  800a80:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a83:	74 16                	je     800a9b <strsplit+0x77>
  800a85:	83 ec 08             	sub    $0x8,%esp
  800a88:	0f be 03             	movsbl (%ebx),%eax
  800a8b:	50                   	push   %eax
  800a8c:	56                   	push   %esi
  800a8d:	e8 8a fc ff ff       	call   80071c <strchr>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	85 c0                	test   %eax,%eax
  800a97:	74 e6                	je     800a7f <strsplit+0x5b>
  800a99:	eb b0                	jmp    800a4b <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800a9b:	8b 07                	mov    (%edi),%eax
  800a9d:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa0:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800aa7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800aac:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	89 f8                	mov    %edi,%eax
  800ac7:	89 fb                	mov    %edi,%ebx
  800ac9:	89 fe                	mov    %edi,%esi
  800acb:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	b8 01 00 00 00       	mov    $0x1,%eax
  800add:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae2:	89 fa                	mov    %edi,%edx
  800ae4:	89 f9                	mov    %edi,%ecx
  800ae6:	89 fb                	mov    %edi,%ebx
  800ae8:	89 fe                	mov    %edi,%esi
  800aea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aff:	bf 00 00 00 00       	mov    $0x0,%edi
  800b04:	89 f9                	mov    %edi,%ecx
  800b06:	89 fb                	mov    %edi,%ebx
  800b08:	89 fe                	mov    %edi,%esi
  800b0a:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	89 fa                	mov    %edi,%edx
  800b23:	89 f9                	mov    %edi,%ecx
  800b25:	89 fb                	mov    %edi,%ebx
  800b27:	89 fe                	mov    %edi,%esi
  800b29:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b40:	89 fa                	mov    %edi,%edx
  800b42:	89 f9                	mov    %edi,%ecx
  800b44:	89 fb                	mov    %edi,%ebx
  800b46:	89 fe                	mov    %edi,%esi
  800b48:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
  800b65:	89 fb                	mov    %edi,%ebx
  800b67:	89 fe                	mov    %edi,%esi
  800b69:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
  800b86:	89 fb                	mov    %edi,%ebx
  800b88:	89 fe                	mov    %edi,%esi
  800b8a:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba6:	b8 07 00 00 00       	mov    $0x7,%eax
  800bab:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc8:	89 fb                	mov    %edi,%ebx
  800bca:	89 fe                	mov    %edi,%esi
  800bcc:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800be4:	bf 00 00 00 00       	mov    $0x0,%edi
  800be9:	89 fb                	mov    %edi,%ebx
  800beb:	89 fe                	mov    %edi,%esi
  800bed:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
  800c04:	89 fa                	mov    %edi,%edx
  800c06:	89 f9                	mov    %edi,%ecx
  800c08:	89 fb                	mov    %edi,%ebx
  800c0a:	89 fe                	mov    %edi,%esi
  800c0c:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c24:	bf 00 00 00 00       	mov    $0x0,%edi
  800c29:	89 fb                	mov    %edi,%ebx
  800c2b:	89 fe                	mov    %edi,%esi
  800c2d:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
	...

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	83 ec 20             	sub    $0x20,%esp
  800c48:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c52:	8b 55 14             	mov    0x14(%ebp),%edx
  800c55:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c58:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800c5e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c65:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800c68:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800c6b:	89 fe                	mov    %edi,%esi
  800c6d:	85 d2                	test   %edx,%edx
  800c6f:	75 2f                	jne    800ca0 <__udivdi3+0x60>
  800c71:	39 f8                	cmp    %edi,%eax
  800c73:	76 62                	jbe    800cd7 <__udivdi3+0x97>
  800c75:	89 fa                	mov    %edi,%edx
  800c77:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800c7a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800c7d:	89 c7                	mov    %eax,%edi
  800c7f:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800c86:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800c89:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800c8c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800c8f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800c92:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800c95:	83 c4 20             	add    $0x20,%esp
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    
  800c9c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ca0:	31 ff                	xor    %edi,%edi
  800ca2:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800ca9:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800cac:	77 d8                	ja     800c86 <__udivdi3+0x46>
  800cae:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800cb2:	89 c7                	mov    %eax,%edi
  800cb4:	83 f7 1f             	xor    $0x1f,%edi
  800cb7:	75 5b                	jne    800d14 <__udivdi3+0xd4>
  800cb9:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800cbc:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800cbf:	0f 97 c2             	seta   %dl
  800cc2:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800cc5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cca:	0f 93 c0             	setae  %al
  800ccd:	09 d0                	or     %edx,%eax
  800ccf:	a8 01                	test   $0x1,%al
  800cd1:	75 ac                	jne    800c7f <__udivdi3+0x3f>
  800cd3:	31 ff                	xor    %edi,%edi
  800cd5:	eb a8                	jmp    800c7f <__udivdi3+0x3f>
  800cd7:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	75 0e                	jne    800cec <__udivdi3+0xac>
  800cde:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce3:	31 c9                	xor    %ecx,%ecx
  800ce5:	31 d2                	xor    %edx,%edx
  800ce7:	f7 f1                	div    %ecx
  800ce9:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800cec:	89 f0                	mov    %esi,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800cf3:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800cf6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800cf9:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800d01:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800d04:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800d07:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800d0a:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800d0d:	83 c4 20             	add    $0x20,%esp
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    
  800d14:	b8 20 00 00 00       	mov    $0x20,%eax
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	29 f8                	sub    %edi,%eax
  800d1d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800d20:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800d23:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d26:	d3 e2                	shl    %cl,%edx
  800d28:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d2b:	d3 e8                	shr    %cl,%eax
  800d2d:	09 c2                	or     %eax,%edx
  800d2f:	89 f9                	mov    %edi,%ecx
  800d31:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800d34:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800d37:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d3a:	89 f2                	mov    %esi,%edx
  800d3c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d3f:	d3 ea                	shr    %cl,%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 e6                	shl    %cl,%esi
  800d45:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d48:	d3 e8                	shr    %cl,%eax
  800d4a:	09 c6                	or     %eax,%esi
  800d4c:	89 f9                	mov    %edi,%ecx
  800d4e:	89 f0                	mov    %esi,%eax
  800d50:	f7 75 ec             	divl   0xffffffec(%ebp)
  800d53:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800d56:	89 d6                	mov    %edx,%esi
  800d58:	89 c7                	mov    %eax,%edi
  800d5a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d5d:	f7 e7                	mul    %edi
  800d5f:	39 f2                	cmp    %esi,%edx
  800d61:	77 15                	ja     800d78 <__udivdi3+0x138>
  800d63:	39 f2                	cmp    %esi,%edx
  800d65:	0f 94 c2             	sete   %dl
  800d68:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800d6b:	0f 97 c0             	seta   %al
  800d6e:	21 d0                	and    %edx,%eax
  800d70:	a8 01                	test   $0x1,%al
  800d72:	0f 84 07 ff ff ff    	je     800c7f <__udivdi3+0x3f>
  800d78:	4f                   	dec    %edi
  800d79:	e9 01 ff ff ff       	jmp    800c7f <__udivdi3+0x3f>
  800d7e:	90                   	nop    
  800d7f:	90                   	nop    

00800d80 <__umoddi3>:
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	83 ec 38             	sub    $0x38,%esp
  800d88:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800d8b:	8b 55 14             	mov    0x14(%ebp),%edx
  800d8e:	8b 75 08             	mov    0x8(%ebp),%esi
  800d91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d94:	8b 45 10             	mov    0x10(%ebp),%eax
  800d97:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800da5:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800da8:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800dab:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800dae:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800db1:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800db4:	85 d2                	test   %edx,%edx
  800db6:	75 48                	jne    800e00 <__umoddi3+0x80>
  800db8:	39 f8                	cmp    %edi,%eax
  800dba:	0f 86 d0 00 00 00    	jbe    800e90 <__umoddi3+0x110>
  800dc0:	89 f0                	mov    %esi,%eax
  800dc2:	89 fa                	mov    %edi,%edx
  800dc4:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800dc7:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800dca:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800dcd:	85 f6                	test   %esi,%esi
  800dcf:	74 49                	je     800e1a <__umoddi3+0x9a>
  800dd1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800dd4:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800ddb:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800dde:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800de1:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800de4:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800de7:	89 10                	mov    %edx,(%eax)
  800de9:	89 48 04             	mov    %ecx,0x4(%eax)
  800dec:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800def:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800df2:	83 c4 38             	add    $0x38,%esp
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800e00:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e03:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800e06:	76 1f                	jbe    800e27 <__umoddi3+0xa7>
  800e08:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800e0b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e0e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e11:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e14:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800e17:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e1a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e1d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e20:	83 c4 38             	add    $0x38,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
  800e27:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800e2b:	83 f0 1f             	xor    $0x1f,%eax
  800e2e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800e31:	0f 85 89 00 00 00    	jne    800ec0 <__umoddi3+0x140>
  800e37:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e3a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800e3d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800e40:	0f 97 c2             	seta   %dl
  800e43:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800e46:	0f 93 c0             	setae  %al
  800e49:	09 d0                	or     %edx,%eax
  800e4b:	a8 01                	test   $0x1,%al
  800e4d:	74 11                	je     800e60 <__umoddi3+0xe0>
  800e4f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e52:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e55:	29 c8                	sub    %ecx,%eax
  800e57:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800e5a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800e5d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e60:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e63:	85 c9                	test   %ecx,%ecx
  800e65:	74 b3                	je     800e1a <__umoddi3+0x9a>
  800e67:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e6a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e6d:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e70:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800e73:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e76:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e79:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e7c:	89 01                	mov    %eax,(%ecx)
  800e7e:	89 51 04             	mov    %edx,0x4(%ecx)
  800e81:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e84:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e87:	83 c4 38             	add    $0x38,%esp
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    
  800e8e:	89 f6                	mov    %esi,%esi
  800e90:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  800e93:	85 ff                	test   %edi,%edi
  800e95:	75 0d                	jne    800ea4 <__umoddi3+0x124>
  800e97:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9c:	31 d2                	xor    %edx,%edx
  800e9e:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ea1:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800ea4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800ea7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800eaa:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ead:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800eb0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800eb3:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800eb6:	e9 0c ff ff ff       	jmp    800dc7 <__umoddi3+0x47>
  800ebb:	90                   	nop    
  800ebc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ec0:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  800ec3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec8:	29 d0                	sub    %edx,%eax
  800eca:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ecd:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800ed0:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800ed3:	d3 e2                	shl    %cl,%edx
  800ed5:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  800ed8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800edb:	d3 e8                	shr    %cl,%eax
  800edd:	09 c2                	or     %eax,%edx
  800edf:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ee2:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  800ee5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800ee8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800eeb:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800eee:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  800ef1:	d3 ea                	shr    %cl,%edx
  800ef3:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ef6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ef9:	d3 e6                	shl    %cl,%esi
  800efb:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800efe:	d3 e8                	shr    %cl,%eax
  800f00:	09 c6                	or     %eax,%esi
  800f02:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f05:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  800f08:	89 f0                	mov    %esi,%eax
  800f0a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f0d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  800f10:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f13:	f7 65 c4             	mull   0xffffffc4(%ebp)
  800f16:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f19:	89 d6                	mov    %edx,%esi
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	77 12                	ja     800f31 <__umoddi3+0x1b1>
  800f1f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f22:	0f 94 c2             	sete   %dl
  800f25:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  800f28:	0f 97 c0             	seta   %al
  800f2b:	21 d0                	and    %edx,%eax
  800f2d:	a8 01                	test   $0x1,%al
  800f2f:	74 06                	je     800f37 <__umoddi3+0x1b7>
  800f31:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  800f34:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  800f37:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	0f 84 d8 fe ff ff    	je     800e1a <__umoddi3+0x9a>
  800f42:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f45:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f48:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f4b:	29 f8                	sub    %edi,%eax
  800f4d:	19 f2                	sbb    %esi,%edx
  800f4f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f52:	d3 e2                	shl    %cl,%edx
  800f54:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f57:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f5a:	d3 e8                	shr    %cl,%eax
  800f5c:	09 c2                	or     %eax,%edx
  800f5e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f61:	d3 e8                	shr    %cl,%eax
  800f63:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  800f66:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800f69:	e9 70 fe ff ff       	jmp    800dde <__umoddi3+0x5e>
  800f6e:	90                   	nop    
  800f6f:	90                   	nop    
