
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
  800031:	e8 16 00 00 00       	call   80004c <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 14             	sub    $0x14,%esp
	cprintf("HELLO WORLD , FOS IS SAYING HI :D:D:D\n");	
  80003e:	68 60 0f 80 00       	push   $0x800f60
  800043:	e8 e4 00 00 00       	call   80012c <cprintf>
}
  800048:	c9                   	leave  
  800049:	c3                   	ret    
	...

0080004c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800055:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  800058:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  80005f:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 c9                	test   %ecx,%ecx
  800064:	7e 07                	jle    80006d <libmain+0x21>
		binaryname = argv[0];
  800066:	8b 02                	mov    (%edx),%eax
  800068:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  80006d:	83 ec 08             	sub    $0x8,%esp
  800070:	52                   	push   %edx
  800071:	51                   	push   %ecx
  800072:	e8 c1 ff ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  800077:	e8 13 00 00 00       	call   80008f <sleep>
}
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    
	...

00800080 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  800086:	6a 00                	push   $0x0
  800088:	e8 60 0a 00 00       	call   800aed <sys_env_destroy>
}
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <sleep>:

void
sleep(void)
{	
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800095:	e8 92 0a 00 00       	call   800b2c <sys_env_sleep>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <putch>:


static void
putch(int ch, struct printbuf *b)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 04             	sub    $0x4,%esp
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a6:	8b 03                	mov    (%ebx),%eax
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000af:	40                   	inc    %eax
  8000b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b7:	75 1a                	jne    8000d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	68 ff 00 00 00       	push   $0xff
  8000c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c4:	50                   	push   %eax
  8000c5:	e8 e6 09 00 00       	call   800ab0 <sys_cputs>
		b->idx = 0;
  8000ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000d3:	ff 43 04             	incl   0x4(%ebx)
}
  8000d6:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e4:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8000eb:	00 00 00 
	b.cnt = 0;
  8000ee:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8000f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f8:	ff 75 0c             	pushl  0xc(%ebp)
  8000fb:	ff 75 08             	pushl  0x8(%ebp)
  8000fe:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800104:	50                   	push   %eax
  800105:	68 9c 00 80 00       	push   $0x80009c
  80010a:	e8 2d 01 00 00       	call   80023c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010f:	83 c4 08             	add    $0x8,%esp
  800112:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800118:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 8c 09 00 00       	call   800ab0 <sys_cputs>

	return b.cnt;
  800124:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800132:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800135:	50                   	push   %eax
  800136:	ff 75 08             	pushl  0x8(%ebp)
  800139:	e8 9d ff ff ff       	call   8000db <vcprintf>
	va_end(ap);

	return cnt;
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	8b 75 10             	mov    0x10(%ebp),%esi
  80014c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80014f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800152:	8b 45 18             	mov    0x18(%ebp),%eax
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	39 d7                	cmp    %edx,%edi
  80015c:	72 39                	jb     800197 <printnum+0x57>
  80015e:	77 04                	ja     800164 <printnum+0x24>
  800160:	39 c6                	cmp    %eax,%esi
  800162:	72 33                	jb     800197 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800164:	83 ec 04             	sub    $0x4,%esp
  800167:	ff 75 20             	pushl  0x20(%ebp)
  80016a:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	ff 75 18             	pushl  0x18(%ebp)
  800171:	8b 45 18             	mov    0x18(%ebp),%eax
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	52                   	push   %edx
  80017a:	50                   	push   %eax
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	e8 ae 0a 00 00       	call   800c30 <__udivdi3>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	52                   	push   %edx
  800186:	50                   	push   %eax
  800187:	ff 75 0c             	pushl  0xc(%ebp)
  80018a:	ff 75 08             	pushl  0x8(%ebp)
  80018d:	e8 ae ff ff ff       	call   800140 <printnum>
  800192:	83 c4 20             	add    $0x20,%esp
  800195:	eb 19                	jmp    8001b0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800197:	4b                   	dec    %ebx
  800198:	85 db                	test   %ebx,%ebx
  80019a:	7e 14                	jle    8001b0 <printnum+0x70>
			putch(padc, putdat);
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	ff 75 0c             	pushl  0xc(%ebp)
  8001a2:	ff 75 20             	pushl  0x20(%ebp)
  8001a5:	ff 55 08             	call   *0x8(%ebp)
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	4b                   	dec    %ebx
  8001ac:	85 db                	test   %ebx,%ebx
  8001ae:	7f ec                	jg     80019c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	ff 75 0c             	pushl  0xc(%ebp)
  8001b6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001be:	83 ec 04             	sub    $0x4,%esp
  8001c1:	52                   	push   %edx
  8001c2:	50                   	push   %eax
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	e8 a6 0b 00 00       	call   800d70 <__umoddi3>
  8001ca:	83 c4 14             	add    $0x14,%esp
  8001cd:	0f be 80 07 10 80 00 	movsbl 0x801007(%eax),%eax
  8001d4:	50                   	push   %eax
  8001d5:	ff 55 08             	call   *0x8(%ebp)
}
  8001d8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8001e9:	83 f8 01             	cmp    $0x1,%eax
  8001ec:	7e 0f                	jle    8001fd <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8001ee:	8b 01                	mov    (%ecx),%eax
  8001f0:	83 c0 08             	add    $0x8,%eax
  8001f3:	89 01                	mov    %eax,(%ecx)
  8001f5:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8001f8:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8001fb:	eb 0f                	jmp    80020c <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8001fd:	8b 01                	mov    (%ecx),%eax
  8001ff:	83 c0 04             	add    $0x4,%eax
  800202:	89 01                	mov    %eax,(%ecx)
  800204:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800207:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	8b 55 08             	mov    0x8(%ebp),%edx
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800217:	83 f8 01             	cmp    $0x1,%eax
  80021a:	7e 0f                	jle    80022b <getint+0x1d>
		return va_arg(*ap, long long);
  80021c:	8b 02                	mov    (%edx),%eax
  80021e:	83 c0 08             	add    $0x8,%eax
  800221:	89 02                	mov    %eax,(%edx)
  800223:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800226:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800229:	eb 0f                	jmp    80023a <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80022b:	8b 02                	mov    (%edx),%eax
  80022d:	83 c0 04             	add    $0x4,%eax
  800230:	89 02                	mov    %eax,(%edx)
  800232:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800235:	89 c2                	mov    %eax,%edx
  800237:	c1 fa 1f             	sar    $0x1f,%edx
}
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 1c             	sub    $0x1c,%esp
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800248:	ba 00 00 00 00       	mov    $0x0,%edx
  80024d:	8a 13                	mov    (%ebx),%dl
  80024f:	43                   	inc    %ebx
  800250:	83 fa 25             	cmp    $0x25,%edx
  800253:	74 22                	je     800277 <vprintfmt+0x3b>
			if (ch == '\0')
  800255:	85 d2                	test   %edx,%edx
  800257:	0f 84 cd 02 00 00    	je     80052a <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	52                   	push   %edx
  800264:	ff 55 08             	call   *0x8(%ebp)
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	ba 00 00 00 00       	mov    $0x0,%edx
  80026f:	8a 13                	mov    (%ebx),%dl
  800271:	43                   	inc    %ebx
  800272:	83 fa 25             	cmp    $0x25,%edx
  800275:	75 de                	jne    800255 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  800277:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  80027b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  800282:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800287:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  80028c:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800293:	ba 00 00 00 00       	mov    $0x0,%edx
  800298:	8a 13                	mov    (%ebx),%dl
  80029a:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  80029d:	43                   	inc    %ebx
  80029e:	83 f8 55             	cmp    $0x55,%eax
  8002a1:	0f 87 5e 02 00 00    	ja     800505 <vprintfmt+0x2c9>
  8002a7:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ae:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8002b2:	eb df                	jmp    800293 <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002b4:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8002b8:	eb d9                	jmp    800293 <vprintfmt+0x57>

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
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002bf:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002c2:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8002c6:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8002c9:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8002cc:	83 f8 09             	cmp    $0x9,%eax
  8002cf:	77 27                	ja     8002f8 <vprintfmt+0xbc>
  8002d1:	43                   	inc    %ebx
  8002d2:	eb eb                	jmp    8002bf <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002d4:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8002d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002db:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8002de:	eb 18                	jmp    8002f8 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  8002e0:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8002e4:	79 ad                	jns    800293 <vprintfmt+0x57>
				width = 0;
  8002e6:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8002ed:	eb a4                	jmp    800293 <vprintfmt+0x57>

		case '#':
			altflag = 1;
  8002ef:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8002f6:	eb 9b                	jmp    800293 <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  8002f8:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8002fc:	79 95                	jns    800293 <vprintfmt+0x57>
				width = precision, precision = -1;
  8002fe:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800301:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800306:	eb 8b                	jmp    800293 <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800308:	41                   	inc    %ecx
			goto reswitch;
  800309:	eb 88                	jmp    800293 <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	ff 75 0c             	pushl  0xc(%ebp)
  800311:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80031b:	e9 da 01 00 00       	jmp    8004fa <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800320:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800324:	8b 45 14             	mov    0x14(%ebp),%eax
  800327:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	79 02                	jns    800330 <vprintfmt+0xf4>
				err = -err;
  80032e:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800330:	83 f8 07             	cmp    $0x7,%eax
  800333:	7f 0b                	jg     800340 <vprintfmt+0x104>
  800335:	8b 3c 85 40 10 80 00 	mov    0x801040(,%eax,4),%edi
  80033c:	85 ff                	test   %edi,%edi
  80033e:	75 08                	jne    800348 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  800340:	50                   	push   %eax
  800341:	68 18 10 80 00       	push   $0x801018
  800346:	eb 06                	jmp    80034e <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  800348:	57                   	push   %edi
  800349:	68 21 10 80 00       	push   $0x801021
  80034e:	ff 75 0c             	pushl  0xc(%ebp)
  800351:	ff 75 08             	pushl  0x8(%ebp)
  800354:	e8 d9 01 00 00       	call   800532 <printfmt>
  800359:	e9 9f 01 00 00       	jmp    8004fd <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80035e:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800362:	8b 45 14             	mov    0x14(%ebp),%eax
  800365:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  800368:	85 ff                	test   %edi,%edi
  80036a:	75 05                	jne    800371 <vprintfmt+0x135>
				p = "(null)";
  80036c:	bf 24 10 80 00       	mov    $0x801024,%edi
			if (width > 0 && padc != '-')
  800371:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800375:	0f 9f c2             	setg   %dl
  800378:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  80037c:	0f 95 c0             	setne  %al
  80037f:	21 d0                	and    %edx,%eax
  800381:	a8 01                	test   $0x1,%al
  800383:	74 35                	je     8003ba <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	56                   	push   %esi
  800389:	57                   	push   %edi
  80038a:	e8 5e 02 00 00       	call   8005ed <strnlen>
  80038f:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800399:	7e 1f                	jle    8003ba <vprintfmt+0x17e>
  80039b:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80039f:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	ff 75 0c             	pushl  0xc(%ebp)
  8003a8:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003ab:	ff 55 08             	call   *0x8(%ebp)
  8003ae:	83 c4 10             	add    $0x10,%esp
  8003b1:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003b4:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003b8:	7f e8                	jg     8003a2 <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8003ba:	0f be 17             	movsbl (%edi),%edx
  8003bd:	47                   	inc    %edi
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 3e                	je     800400 <vprintfmt+0x1c4>
  8003c2:	85 f6                	test   %esi,%esi
  8003c4:	78 03                	js     8003c9 <vprintfmt+0x18d>
  8003c6:	4e                   	dec    %esi
  8003c7:	78 37                	js     800400 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  8003c9:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8003cd:	74 12                	je     8003e1 <vprintfmt+0x1a5>
  8003cf:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8003d2:	83 f8 5e             	cmp    $0x5e,%eax
  8003d5:	76 0a                	jbe    8003e1 <vprintfmt+0x1a5>
					putch('?', putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	ff 75 0c             	pushl  0xc(%ebp)
  8003dd:	6a 3f                	push   $0x3f
  8003df:	eb 07                	jmp    8003e8 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	ff 75 0c             	pushl  0xc(%ebp)
  8003e7:	52                   	push   %edx
  8003e8:	ff 55 08             	call   *0x8(%ebp)
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003f1:	0f be 17             	movsbl (%edi),%edx
  8003f4:	47                   	inc    %edi
  8003f5:	85 d2                	test   %edx,%edx
  8003f7:	74 07                	je     800400 <vprintfmt+0x1c4>
  8003f9:	85 f6                	test   %esi,%esi
  8003fb:	78 cc                	js     8003c9 <vprintfmt+0x18d>
  8003fd:	4e                   	dec    %esi
  8003fe:	79 c9                	jns    8003c9 <vprintfmt+0x18d>
			for (; width > 0; width--)
  800400:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800404:	0f 8e 3e fe ff ff    	jle    800248 <vprintfmt+0xc>
				putch(' ', putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	ff 75 0c             	pushl  0xc(%ebp)
  800410:	6a 20                	push   $0x20
  800412:	ff 55 08             	call   *0x8(%ebp)
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80041b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80041f:	7f e9                	jg     80040a <vprintfmt+0x1ce>
			break;
  800421:	e9 22 fe ff ff       	jmp    800248 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	51                   	push   %ecx
  80042a:	8d 45 14             	lea    0x14(%ebp),%eax
  80042d:	50                   	push   %eax
  80042e:	e8 db fd ff ff       	call   80020e <getint>
  800433:	89 c6                	mov    %eax,%esi
  800435:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	85 d2                	test   %edx,%edx
  80043c:	79 15                	jns    800453 <vprintfmt+0x217>
				putch('-', putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 0c             	pushl  0xc(%ebp)
  800444:	6a 2d                	push   $0x2d
  800446:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800449:	f7 de                	neg    %esi
  80044b:	83 d7 00             	adc    $0x0,%edi
  80044e:	f7 df                	neg    %edi
  800450:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800453:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800458:	eb 78                	jmp    8004d2 <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	51                   	push   %ecx
  80045e:	8d 45 14             	lea    0x14(%ebp),%eax
  800461:	50                   	push   %eax
  800462:	e8 79 fd ff ff       	call   8001e0 <getuint>
  800467:	89 c6                	mov    %eax,%esi
  800469:	89 d7                	mov    %edx,%edi
			base = 10;
  80046b:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800470:	eb 5d                	jmp    8004cf <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	6a 58                	push   $0x58
  80047a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80047d:	83 c4 08             	add    $0x8,%esp
  800480:	ff 75 0c             	pushl  0xc(%ebp)
  800483:	6a 58                	push   $0x58
  800485:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800488:	83 c4 08             	add    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	6a 58                	push   $0x58
  800490:	eb 68                	jmp    8004fa <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 0c             	pushl  0xc(%ebp)
  800498:	6a 30                	push   $0x30
  80049a:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80049d:	83 c4 08             	add    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	6a 78                	push   $0x78
  8004a5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004a8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8004b2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  8004b7:	eb 11                	jmp    8004ca <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	51                   	push   %ecx
  8004bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8004c0:	50                   	push   %eax
  8004c1:	e8 1a fd ff ff       	call   8001e0 <getuint>
  8004c6:	89 c6                	mov    %eax,%esi
  8004c8:	89 d7                	mov    %edx,%edi
			base = 16;
  8004ca:	ba 10 00 00 00       	mov    $0x10,%edx
  8004cf:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8004d2:	83 ec 04             	sub    $0x4,%esp
  8004d5:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8004d9:	50                   	push   %eax
  8004da:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	57                   	push   %edi
  8004df:	56                   	push   %esi
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	ff 75 08             	pushl  0x8(%ebp)
  8004e6:	e8 55 fc ff ff       	call   800140 <printnum>
			break;
  8004eb:	83 c4 20             	add    $0x20,%esp
  8004ee:	e9 55 fd ff ff       	jmp    800248 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	ff 75 0c             	pushl  0xc(%ebp)
  8004f9:	52                   	push   %edx
  8004fa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	e9 43 fd ff ff       	jmp    800248 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	6a 25                	push   $0x25
  80050d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800510:	4b                   	dec    %ebx
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800518:	0f 84 2a fd ff ff    	je     800248 <vprintfmt+0xc>
  80051e:	4b                   	dec    %ebx
  80051f:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800523:	75 f9                	jne    80051e <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800525:	e9 1e fd ff ff       	jmp    800248 <vprintfmt+0xc>
		}
	}
}
  80052a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5e                   	pop    %esi
  80052f:	5f                   	pop    %edi
  800530:	5d                   	pop    %ebp
  800531:	c3                   	ret    

00800532 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800538:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053b:	50                   	push   %eax
  80053c:	ff 75 10             	pushl  0x10(%ebp)
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	ff 75 08             	pushl  0x8(%ebp)
  800545:	e8 f2 fc ff ff       	call   80023c <vprintfmt>
	va_end(ap);
}
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800552:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800555:	8b 0a                	mov    (%edx),%ecx
  800557:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80055a:	73 07                	jae    800563 <sprintputch+0x17>
		*b->buf++ = ch;
  80055c:	8b 45 08             	mov    0x8(%ebp),%eax
  80055f:	88 01                	mov    %al,(%ecx)
  800561:	ff 02                	incl   (%edx)
}
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	83 ec 18             	sub    $0x18,%esp
  80056b:	8b 55 08             	mov    0x8(%ebp),%edx
  80056e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800571:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800574:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800578:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  80057b:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  800582:	85 d2                	test   %edx,%edx
  800584:	0f 94 c2             	sete   %dl
  800587:	85 c9                	test   %ecx,%ecx
  800589:	0f 9e c0             	setle  %al
  80058c:	09 d0                	or     %edx,%eax
  80058e:	ba 03 00 00 00       	mov    $0x3,%edx
  800593:	a8 01                	test   $0x1,%al
  800595:	75 1d                	jne    8005b4 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800597:	ff 75 14             	pushl  0x14(%ebp)
  80059a:	ff 75 10             	pushl  0x10(%ebp)
  80059d:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005a0:	50                   	push   %eax
  8005a1:	68 4c 05 80 00       	push   $0x80054c
  8005a6:	e8 91 fc ff ff       	call   80023c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005ab:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8005ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005b1:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  8005b4:	89 d0                	mov    %edx,%eax
  8005b6:	c9                   	leave  
  8005b7:	c3                   	ret    

008005b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 10             	pushl  0x10(%ebp)
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	ff 75 08             	pushl  0x8(%ebp)
  8005cb:	e8 95 ff ff ff       	call   800565 <vsnprintf>
	va_end(ap);

	return rc;
}
  8005d0:	c9                   	leave  
  8005d1:	c3                   	ret    
	...

008005d4 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
  8005df:	80 3a 00             	cmpb   $0x0,(%edx)
  8005e2:	74 07                	je     8005eb <strlen+0x17>
		n++;
  8005e4:	40                   	inc    %eax
  8005e5:	42                   	inc    %edx
  8005e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8005e9:	75 f9                	jne    8005e4 <strlen+0x10>
	return n;
}
  8005eb:	5d                   	pop    %ebp
  8005ec:	c3                   	ret    

008005ed <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8005f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 0f                	je     80060e <strnlen+0x21>
  8005ff:	80 39 00             	cmpb   $0x0,(%ecx)
  800602:	74 0a                	je     80060e <strnlen+0x21>
		n++;
  800604:	40                   	inc    %eax
  800605:	41                   	inc    %ecx
  800606:	4a                   	dec    %edx
  800607:	74 05                	je     80060e <strnlen+0x21>
  800609:	80 39 00             	cmpb   $0x0,(%ecx)
  80060c:	75 f6                	jne    800604 <strnlen+0x17>
	return n;
}
  80060e:	5d                   	pop    %ebp
  80060f:	c3                   	ret    

00800610 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	53                   	push   %ebx
  800614:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800617:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80061a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80061c:	8a 02                	mov    (%edx),%al
  80061e:	88 01                	mov    %al,(%ecx)
  800620:	42                   	inc    %edx
  800621:	41                   	inc    %ecx
  800622:	84 c0                	test   %al,%al
  800624:	75 f6                	jne    80061c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800626:	89 d8                	mov    %ebx,%eax
  800628:	5b                   	pop    %ebx
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	57                   	push   %edi
  80062f:	56                   	push   %esi
  800630:	53                   	push   %ebx
  800631:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800634:	8b 55 0c             	mov    0xc(%ebp),%edx
  800637:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  80063a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80063c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800641:	39 f3                	cmp    %esi,%ebx
  800643:	73 17                	jae    80065c <strncpy+0x31>
		*dst++ = *src;
  800645:	8a 02                	mov    (%edx),%al
  800647:	88 01                	mov    %al,(%ecx)
  800649:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80064a:	80 3a 00             	cmpb   $0x0,(%edx)
  80064d:	0f 95 c0             	setne  %al
  800650:	25 ff 00 00 00       	and    $0xff,%eax
  800655:	01 c2                	add    %eax,%edx
  800657:	43                   	inc    %ebx
  800658:	39 f3                	cmp    %esi,%ebx
  80065a:	72 e9                	jb     800645 <strncpy+0x1a>
			src++;
	}
	return ret;
}
  80065c:	89 f8                	mov    %edi,%eax
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	56                   	push   %esi
  800667:	53                   	push   %ebx
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80066b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80066e:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800671:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800673:	85 d2                	test   %edx,%edx
  800675:	74 19                	je     800690 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800677:	4a                   	dec    %edx
  800678:	74 13                	je     80068d <strlcpy+0x2a>
  80067a:	80 39 00             	cmpb   $0x0,(%ecx)
  80067d:	74 0e                	je     80068d <strlcpy+0x2a>
			*dst++ = *src++;
  80067f:	8a 01                	mov    (%ecx),%al
  800681:	88 03                	mov    %al,(%ebx)
  800683:	41                   	inc    %ecx
  800684:	43                   	inc    %ebx
  800685:	4a                   	dec    %edx
  800686:	74 05                	je     80068d <strlcpy+0x2a>
  800688:	80 39 00             	cmpb   $0x0,(%ecx)
  80068b:	75 f2                	jne    80067f <strlcpy+0x1c>
		*dst = '\0';
  80068d:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800690:	89 d8                	mov    %ebx,%eax
  800692:	29 f0                	sub    %esi,%eax
}
  800694:	5b                   	pop    %ebx
  800695:	5e                   	pop    %esi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
  80069e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8006a1:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a4:	74 13                	je     8006b9 <strcmp+0x21>
  8006a6:	8a 02                	mov    (%edx),%al
  8006a8:	3a 01                	cmp    (%ecx),%al
  8006aa:	75 0d                	jne    8006b9 <strcmp+0x21>
		p++, q++;
  8006ac:	42                   	inc    %edx
  8006ad:	41                   	inc    %ecx
  8006ae:	80 3a 00             	cmpb   $0x0,(%edx)
  8006b1:	74 06                	je     8006b9 <strcmp+0x21>
  8006b3:	8a 02                	mov    (%edx),%al
  8006b5:	3a 01                	cmp    (%ecx),%al
  8006b7:	74 f3                	je     8006ac <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8006b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006be:	8a 02                	mov    (%edx),%al
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	8a 11                	mov    (%ecx),%dl
  8006c7:	29 d0                	sub    %edx,%eax
}
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	53                   	push   %ebx
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	74 1f                	je     8006fb <strncmp+0x30>
  8006dc:	80 3a 00             	cmpb   $0x0,(%edx)
  8006df:	74 16                	je     8006f7 <strncmp+0x2c>
  8006e1:	8a 02                	mov    (%edx),%al
  8006e3:	3a 03                	cmp    (%ebx),%al
  8006e5:	75 10                	jne    8006f7 <strncmp+0x2c>
		n--, p++, q++;
  8006e7:	42                   	inc    %edx
  8006e8:	43                   	inc    %ebx
  8006e9:	49                   	dec    %ecx
  8006ea:	74 0f                	je     8006fb <strncmp+0x30>
  8006ec:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ef:	74 06                	je     8006f7 <strncmp+0x2c>
  8006f1:	8a 02                	mov    (%edx),%al
  8006f3:	3a 03                	cmp    (%ebx),%al
  8006f5:	74 f0                	je     8006e7 <strncmp+0x1c>
	if (n == 0)
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	75 07                	jne    800702 <strncmp+0x37>
		return 0;
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 13                	jmp    800715 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800702:	8a 12                	mov    (%edx),%dl
  800704:	81 e2 ff 00 00 00    	and    $0xff,%edx
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	8a 03                	mov    (%ebx),%al
  800711:	29 c2                	sub    %eax,%edx
  800713:	89 d0                	mov    %edx,%eax
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 55 08             	mov    0x8(%ebp),%edx
  80071e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800721:	80 3a 00             	cmpb   $0x0,(%edx)
  800724:	74 0c                	je     800732 <strchr+0x1a>
		if (*s == c)
  800726:	89 d0                	mov    %edx,%eax
  800728:	38 0a                	cmp    %cl,(%edx)
  80072a:	74 0b                	je     800737 <strchr+0x1f>
  80072c:	42                   	inc    %edx
  80072d:	80 3a 00             	cmpb   $0x0,(%edx)
  800730:	75 f4                	jne    800726 <strchr+0xe>
			return (char *) s;
	return 0;
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800742:	80 38 00             	cmpb   $0x0,(%eax)
  800745:	74 0a                	je     800751 <strfind+0x18>
		if (*s == c)
  800747:	38 10                	cmp    %dl,(%eax)
  800749:	74 06                	je     800751 <strfind+0x18>
  80074b:	40                   	inc    %eax
  80074c:	80 38 00             	cmpb   $0x0,(%eax)
  80074f:	75 f6                	jne    800747 <strfind+0xe>
			break;
	return (char *) s;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80075a:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  80075d:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  80075f:	8b 55 10             	mov    0x10(%ebp),%edx
  800762:	4a                   	dec    %edx
  800763:	78 06                	js     80076b <memset+0x18>
		*p++ = c;
  800765:	88 01                	mov    %al,(%ecx)
  800767:	41                   	inc    %ecx
  800768:	4a                   	dec    %edx
  800769:	79 fa                	jns    800765 <memset+0x12>

	return v;
}
  80076b:	89 d8                	mov    %ebx,%eax
  80076d:	5b                   	pop    %ebx
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  80077e:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  800780:	89 c8                	mov    %ecx,%eax
  800782:	49                   	dec    %ecx
  800783:	85 c0                	test   %eax,%eax
  800785:	74 0d                	je     800794 <memcpy+0x24>
		*d++ = *s++;
  800787:	8a 03                	mov    (%ebx),%al
  800789:	88 02                	mov    %al,(%edx)
  80078b:	43                   	inc    %ebx
  80078c:	42                   	inc    %edx
  80078d:	89 c8                	mov    %ecx,%eax
  80078f:	49                   	dec    %ecx
  800790:	85 c0                	test   %eax,%eax
  800792:	75 f3                	jne    800787 <memcpy+0x17>

	return dst;
}
  800794:	89 f0                	mov    %esi,%eax
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a2:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  8007a8:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  8007aa:	39 f1                	cmp    %esi,%ecx
  8007ac:	73 22                	jae    8007d0 <memmove+0x36>
  8007ae:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  8007b1:	39 f0                	cmp    %esi,%eax
  8007b3:	76 1b                	jbe    8007d0 <memmove+0x36>
		s += n;
  8007b5:	89 c1                	mov    %eax,%ecx
		d += n;
  8007b7:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  8007ba:	89 d0                	mov    %edx,%eax
  8007bc:	4a                   	dec    %edx
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	74 23                	je     8007e4 <memmove+0x4a>
			*--d = *--s;
  8007c1:	4b                   	dec    %ebx
  8007c2:	49                   	dec    %ecx
  8007c3:	8a 01                	mov    (%ecx),%al
  8007c5:	88 03                	mov    %al,(%ebx)
  8007c7:	89 d0                	mov    %edx,%eax
  8007c9:	4a                   	dec    %edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	75 f3                	jne    8007c1 <memmove+0x27>
  8007ce:	eb 14                	jmp    8007e4 <memmove+0x4a>
	} else
		while (n-- > 0)
  8007d0:	89 d0                	mov    %edx,%eax
  8007d2:	4a                   	dec    %edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	74 0d                	je     8007e4 <memmove+0x4a>
			*d++ = *s++;
  8007d7:	8a 01                	mov    (%ecx),%al
  8007d9:	88 03                	mov    %al,(%ebx)
  8007db:	41                   	inc    %ecx
  8007dc:	43                   	inc    %ebx
  8007dd:	89 d0                	mov    %edx,%eax
  8007df:	4a                   	dec    %edx
  8007e0:	85 c0                	test   %eax,%eax
  8007e2:	75 f3                	jne    8007d7 <memmove+0x3d>

	return dst;
}
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  8007f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8007f7:	89 d0                	mov    %edx,%eax
  8007f9:	4a                   	dec    %edx
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 23                	je     800821 <memcmp+0x37>
		if (*s1 != *s2)
  8007fe:	8a 01                	mov    (%ecx),%al
  800800:	3a 03                	cmp    (%ebx),%al
  800802:	74 14                	je     800818 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  800804:	ba 00 00 00 00       	mov    $0x0,%edx
  800809:	8a 11                	mov    (%ecx),%dl
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	8a 03                	mov    (%ebx),%al
  800812:	29 c2                	sub    %eax,%edx
  800814:	89 d0                	mov    %edx,%eax
  800816:	eb 0e                	jmp    800826 <memcmp+0x3c>
		s1++, s2++;
  800818:	41                   	inc    %ecx
  800819:	43                   	inc    %ebx
  80081a:	89 d0                	mov    %edx,%eax
  80081c:	4a                   	dec    %edx
  80081d:	85 c0                	test   %eax,%eax
  80081f:	75 dd                	jne    8007fe <memcmp+0x14>
	}

	return 0;
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800832:	89 c2                	mov    %eax,%edx
  800834:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800837:	39 d0                	cmp    %edx,%eax
  800839:	73 09                	jae    800844 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80083b:	38 08                	cmp    %cl,(%eax)
  80083d:	74 05                	je     800844 <memfind+0x1b>
  80083f:	40                   	inc    %eax
  800840:	39 d0                	cmp    %edx,%eax
  800842:	72 f7                	jb     80083b <memfind+0x12>
			break;
	return (void *) s;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	57                   	push   %edi
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	83 ec 04             	sub    $0x4,%esp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800855:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800858:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  80085f:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800864:	80 39 20             	cmpb   $0x20,(%ecx)
  800867:	0f 94 c2             	sete   %dl
  80086a:	80 39 09             	cmpb   $0x9,(%ecx)
  80086d:	0f 94 c0             	sete   %al
  800870:	09 d0                	or     %edx,%eax
  800872:	a8 01                	test   $0x1,%al
  800874:	74 13                	je     800889 <strtol+0x43>
		s++;
  800876:	41                   	inc    %ecx
  800877:	80 39 20             	cmpb   $0x20,(%ecx)
  80087a:	0f 94 c2             	sete   %dl
  80087d:	80 39 09             	cmpb   $0x9,(%ecx)
  800880:	0f 94 c0             	sete   %al
  800883:	09 d0                	or     %edx,%eax
  800885:	a8 01                	test   $0x1,%al
  800887:	75 ed                	jne    800876 <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  800889:	80 39 2b             	cmpb   $0x2b,(%ecx)
  80088c:	75 03                	jne    800891 <strtol+0x4b>
		s++;
  80088e:	41                   	inc    %ecx
  80088f:	eb 0d                	jmp    80089e <strtol+0x58>
	else if (*s == '-')
  800891:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800894:	75 08                	jne    80089e <strtol+0x58>
		s++, neg = 1;
  800896:	41                   	inc    %ecx
  800897:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80089e:	85 db                	test   %ebx,%ebx
  8008a0:	0f 94 c2             	sete   %dl
  8008a3:	83 fb 10             	cmp    $0x10,%ebx
  8008a6:	0f 94 c0             	sete   %al
  8008a9:	09 d0                	or     %edx,%eax
  8008ab:	a8 01                	test   $0x1,%al
  8008ad:	74 15                	je     8008c4 <strtol+0x7e>
  8008af:	80 39 30             	cmpb   $0x30,(%ecx)
  8008b2:	75 10                	jne    8008c4 <strtol+0x7e>
  8008b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8008b8:	75 0a                	jne    8008c4 <strtol+0x7e>
		s += 2, base = 16;
  8008ba:	83 c1 02             	add    $0x2,%ecx
  8008bd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8008c2:	eb 1a                	jmp    8008de <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  8008c4:	85 db                	test   %ebx,%ebx
  8008c6:	75 16                	jne    8008de <strtol+0x98>
  8008c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8008cb:	75 08                	jne    8008d5 <strtol+0x8f>
		s++, base = 8;
  8008cd:	41                   	inc    %ecx
  8008ce:	bb 08 00 00 00       	mov    $0x8,%ebx
  8008d3:	eb 09                	jmp    8008de <strtol+0x98>
	else if (base == 0)
  8008d5:	85 db                	test   %ebx,%ebx
  8008d7:	75 05                	jne    8008de <strtol+0x98>
		base = 10;
  8008d9:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8008de:	8a 01                	mov    (%ecx),%al
  8008e0:	83 e8 30             	sub    $0x30,%eax
  8008e3:	3c 09                	cmp    $0x9,%al
  8008e5:	77 08                	ja     8008ef <strtol+0xa9>
			dig = *s - '0';
  8008e7:	0f be 01             	movsbl (%ecx),%eax
  8008ea:	83 e8 30             	sub    $0x30,%eax
  8008ed:	eb 20                	jmp    80090f <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  8008ef:	8a 01                	mov    (%ecx),%al
  8008f1:	83 e8 61             	sub    $0x61,%eax
  8008f4:	3c 19                	cmp    $0x19,%al
  8008f6:	77 08                	ja     800900 <strtol+0xba>
			dig = *s - 'a' + 10;
  8008f8:	0f be 01             	movsbl (%ecx),%eax
  8008fb:	83 e8 57             	sub    $0x57,%eax
  8008fe:	eb 0f                	jmp    80090f <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800900:	8a 01                	mov    (%ecx),%al
  800902:	83 e8 41             	sub    $0x41,%eax
  800905:	3c 19                	cmp    $0x19,%al
  800907:	77 12                	ja     80091b <strtol+0xd5>
			dig = *s - 'A' + 10;
  800909:	0f be 01             	movsbl (%ecx),%eax
  80090c:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80090f:	39 d8                	cmp    %ebx,%eax
  800911:	7d 08                	jge    80091b <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  800913:	41                   	inc    %ecx
  800914:	0f af f3             	imul   %ebx,%esi
  800917:	01 c6                	add    %eax,%esi
  800919:	eb c3                	jmp    8008de <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  80091b:	85 ff                	test   %edi,%edi
  80091d:	74 02                	je     800921 <strtol+0xdb>
		*endptr = (char *) s;
  80091f:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800921:	89 f0                	mov    %esi,%eax
  800923:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800927:	74 02                	je     80092b <strtol+0xe5>
  800929:	f7 d8                	neg    %eax
}
  80092b:	83 c4 04             	add    $0x4,%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	83 ec 04             	sub    $0x4,%esp
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800942:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800945:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  80094c:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800951:	80 39 20             	cmpb   $0x20,(%ecx)
  800954:	0f 94 c2             	sete   %dl
  800957:	80 39 09             	cmpb   $0x9,(%ecx)
  80095a:	0f 94 c0             	sete   %al
  80095d:	09 d0                	or     %edx,%eax
  80095f:	a8 01                	test   $0x1,%al
  800961:	74 13                	je     800976 <strtoul+0x43>
		s++;
  800963:	41                   	inc    %ecx
  800964:	80 39 20             	cmpb   $0x20,(%ecx)
  800967:	0f 94 c2             	sete   %dl
  80096a:	80 39 09             	cmpb   $0x9,(%ecx)
  80096d:	0f 94 c0             	sete   %al
  800970:	09 d0                	or     %edx,%eax
  800972:	a8 01                	test   $0x1,%al
  800974:	75 ed                	jne    800963 <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  800976:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800979:	75 03                	jne    80097e <strtoul+0x4b>
		s++;
  80097b:	41                   	inc    %ecx
  80097c:	eb 0d                	jmp    80098b <strtoul+0x58>
	else if (*s == '-')
  80097e:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800981:	75 08                	jne    80098b <strtoul+0x58>
		s++, neg = 1;
  800983:	41                   	inc    %ecx
  800984:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098b:	85 db                	test   %ebx,%ebx
  80098d:	0f 94 c2             	sete   %dl
  800990:	83 fb 10             	cmp    $0x10,%ebx
  800993:	0f 94 c0             	sete   %al
  800996:	09 d0                	or     %edx,%eax
  800998:	a8 01                	test   $0x1,%al
  80099a:	74 15                	je     8009b1 <strtoul+0x7e>
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 10                	jne    8009b1 <strtoul+0x7e>
  8009a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a5:	75 0a                	jne    8009b1 <strtoul+0x7e>
		s += 2, base = 16;
  8009a7:	83 c1 02             	add    $0x2,%ecx
  8009aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009af:	eb 1a                	jmp    8009cb <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  8009b1:	85 db                	test   %ebx,%ebx
  8009b3:	75 16                	jne    8009cb <strtoul+0x98>
  8009b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b8:	75 08                	jne    8009c2 <strtoul+0x8f>
		s++, base = 8;
  8009ba:	41                   	inc    %ecx
  8009bb:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009c0:	eb 09                	jmp    8009cb <strtoul+0x98>
	else if (base == 0)
  8009c2:	85 db                	test   %ebx,%ebx
  8009c4:	75 05                	jne    8009cb <strtoul+0x98>
		base = 10;
  8009c6:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cb:	8a 01                	mov    (%ecx),%al
  8009cd:	83 e8 30             	sub    $0x30,%eax
  8009d0:	3c 09                	cmp    $0x9,%al
  8009d2:	77 08                	ja     8009dc <strtoul+0xa9>
			dig = *s - '0';
  8009d4:	0f be 01             	movsbl (%ecx),%eax
  8009d7:	83 e8 30             	sub    $0x30,%eax
  8009da:	eb 20                	jmp    8009fc <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	83 e8 61             	sub    $0x61,%eax
  8009e1:	3c 19                	cmp    $0x19,%al
  8009e3:	77 08                	ja     8009ed <strtoul+0xba>
			dig = *s - 'a' + 10;
  8009e5:	0f be 01             	movsbl (%ecx),%eax
  8009e8:	83 e8 57             	sub    $0x57,%eax
  8009eb:	eb 0f                	jmp    8009fc <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  8009ed:	8a 01                	mov    (%ecx),%al
  8009ef:	83 e8 41             	sub    $0x41,%eax
  8009f2:	3c 19                	cmp    $0x19,%al
  8009f4:	77 12                	ja     800a08 <strtoul+0xd5>
			dig = *s - 'A' + 10;
  8009f6:	0f be 01             	movsbl (%ecx),%eax
  8009f9:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009fc:	39 d8                	cmp    %ebx,%eax
  8009fe:	7d 08                	jge    800a08 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a00:	41                   	inc    %ecx
  800a01:	0f af f3             	imul   %ebx,%esi
  800a04:	01 c6                	add    %eax,%esi
  800a06:	eb c3                	jmp    8009cb <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800a08:	85 ff                	test   %edi,%edi
  800a0a:	74 02                	je     800a0e <strtoul+0xdb>
		*endptr = (char *) s;
  800a0c:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a0e:	89 f0                	mov    %esi,%eax
  800a10:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a14:	74 02                	je     800a18 <strtoul+0xe5>
  800a16:	f7 d8                	neg    %eax
}
  800a18:	83 c4 04             	add    $0x4,%esp
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	83 ec 0c             	sub    $0xc,%esp
  800a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800a32:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800a38:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800a41:	eb 04                	jmp    800a47 <strsplit+0x27>
			*string++ = 0;
  800a43:	c6 03 00             	movb   $0x0,(%ebx)
  800a46:	43                   	inc    %ebx
  800a47:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a4a:	74 4b                	je     800a97 <strsplit+0x77>
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	0f be 03             	movsbl (%ebx),%eax
  800a52:	50                   	push   %eax
  800a53:	56                   	push   %esi
  800a54:	e8 bf fc ff ff       	call   800718 <strchr>
  800a59:	83 c4 10             	add    $0x10,%esp
  800a5c:	85 c0                	test   %eax,%eax
  800a5e:	75 e3                	jne    800a43 <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800a60:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a63:	74 32                	je     800a97 <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	83 3f 0f             	cmpl   $0xf,(%edi)
  800a6d:	74 39                	je     800aa8 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800a6f:	8b 07                	mov    (%edi),%eax
  800a71:	8b 55 10             	mov    0x10(%ebp),%edx
  800a74:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800a77:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800a79:	eb 01                	jmp    800a7c <strsplit+0x5c>
			string++;
  800a7b:	43                   	inc    %ebx
  800a7c:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a7f:	74 16                	je     800a97 <strsplit+0x77>
  800a81:	83 ec 08             	sub    $0x8,%esp
  800a84:	0f be 03             	movsbl (%ebx),%eax
  800a87:	50                   	push   %eax
  800a88:	56                   	push   %esi
  800a89:	e8 8a fc ff ff       	call   800718 <strchr>
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	85 c0                	test   %eax,%eax
  800a93:	74 e6                	je     800a7b <strsplit+0x5b>
  800a95:	eb b0                	jmp    800a47 <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800a97:	8b 07                	mov    (%edi),%eax
  800a99:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9c:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800aa3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800aa8:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	89 fb                	mov    %edi,%ebx
  800ac5:	89 fe                	mov    %edi,%esi
  800ac7:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	89 fa                	mov    %edi,%edx
  800ae0:	89 f9                	mov    %edi,%ecx
  800ae2:	89 fb                	mov    %edi,%ebx
  800ae4:	89 fe                	mov    %edi,%esi
  800ae6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	b8 03 00 00 00       	mov    $0x3,%eax
  800afb:	bf 00 00 00 00       	mov    $0x0,%edi
  800b00:	89 f9                	mov    %edi,%ecx
  800b02:	89 fb                	mov    %edi,%ebx
  800b04:	89 fe                	mov    %edi,%esi
  800b06:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_getenvid>:

int32 sys_getenvid(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	b8 02 00 00 00       	mov    $0x2,%eax
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1d:	89 fa                	mov    %edi,%edx
  800b1f:	89 f9                	mov    %edi,%ecx
  800b21:	89 fb                	mov    %edi,%ebx
  800b23:	89 fe                	mov    %edi,%esi
  800b25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_env_sleep>:

void sys_env_sleep(void)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	b8 04 00 00 00       	mov    $0x4,%eax
  800b37:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3c:	89 fa                	mov    %edi,%edx
  800b3e:	89 f9                	mov    %edi,%ecx
  800b40:	89 fb                	mov    %edi,%ebx
  800b42:	89 fe                	mov    %edi,%esi
  800b44:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b61:	89 fb                	mov    %edi,%ebx
  800b63:	89 fe                	mov    %edi,%esi
  800b65:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b82:	89 fb                	mov    %edi,%ebx
  800b84:	89 fe                	mov    %edi,%esi
  800b86:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba2:	b8 07 00 00 00       	mov    $0x7,%eax
  800ba7:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc4:	89 fb                	mov    %edi,%ebx
  800bc6:	89 fe                	mov    %edi,%esi
  800bc8:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
  800be5:	89 fb                	mov    %edi,%ebx
  800be7:	89 fe                	mov    %edi,%esi
  800be9:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800c00:	89 fa                	mov    %edi,%edx
  800c02:	89 f9                	mov    %edi,%ecx
  800c04:	89 fb                	mov    %edi,%ebx
  800c06:	89 fe                	mov    %edi,%esi
  800c08:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	89 fb                	mov    %edi,%ebx
  800c27:	89 fe                	mov    %edi,%esi
  800c29:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	83 ec 20             	sub    $0x20,%esp
  800c38:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800c3f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c42:	8b 55 14             	mov    0x14(%ebp),%edx
  800c45:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c48:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800c4e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c55:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800c58:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800c5b:	89 fe                	mov    %edi,%esi
  800c5d:	85 d2                	test   %edx,%edx
  800c5f:	75 2f                	jne    800c90 <__udivdi3+0x60>
  800c61:	39 f8                	cmp    %edi,%eax
  800c63:	76 62                	jbe    800cc7 <__udivdi3+0x97>
  800c65:	89 fa                	mov    %edi,%edx
  800c67:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800c6a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800c76:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800c79:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800c7c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800c7f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800c82:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800c85:	83 c4 20             	add    $0x20,%esp
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi),%esi
  800c90:	31 ff                	xor    %edi,%edi
  800c92:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800c99:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800c9c:	77 d8                	ja     800c76 <__udivdi3+0x46>
  800c9e:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800ca2:	89 c7                	mov    %eax,%edi
  800ca4:	83 f7 1f             	xor    $0x1f,%edi
  800ca7:	75 5b                	jne    800d04 <__udivdi3+0xd4>
  800ca9:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800cac:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800caf:	0f 97 c2             	seta   %dl
  800cb2:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800cb5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cba:	0f 93 c0             	setae  %al
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	a8 01                	test   $0x1,%al
  800cc1:	75 ac                	jne    800c6f <__udivdi3+0x3f>
  800cc3:	31 ff                	xor    %edi,%edi
  800cc5:	eb a8                	jmp    800c6f <__udivdi3+0x3f>
  800cc7:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	75 0e                	jne    800cdc <__udivdi3+0xac>
  800cce:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd3:	31 c9                	xor    %ecx,%ecx
  800cd5:	31 d2                	xor    %edx,%edx
  800cd7:	f7 f1                	div    %ecx
  800cd9:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ce3:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800ce6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800ce9:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800cf1:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800cf4:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800cf7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800cfa:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800cfd:	83 c4 20             	add    $0x20,%esp
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
  800d04:	b8 20 00 00 00       	mov    $0x20,%eax
  800d09:	89 f9                	mov    %edi,%ecx
  800d0b:	29 f8                	sub    %edi,%eax
  800d0d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800d10:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800d13:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d16:	d3 e2                	shl    %cl,%edx
  800d18:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d1b:	d3 e8                	shr    %cl,%eax
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800d24:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800d27:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d2a:	89 f2                	mov    %esi,%edx
  800d2c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d2f:	d3 ea                	shr    %cl,%edx
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	d3 e6                	shl    %cl,%esi
  800d35:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d38:	d3 e8                	shr    %cl,%eax
  800d3a:	09 c6                	or     %eax,%esi
  800d3c:	89 f9                	mov    %edi,%ecx
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	f7 75 ec             	divl   0xffffffec(%ebp)
  800d43:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800d46:	89 d6                	mov    %edx,%esi
  800d48:	89 c7                	mov    %eax,%edi
  800d4a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d4d:	f7 e7                	mul    %edi
  800d4f:	39 f2                	cmp    %esi,%edx
  800d51:	77 15                	ja     800d68 <__udivdi3+0x138>
  800d53:	39 f2                	cmp    %esi,%edx
  800d55:	0f 94 c2             	sete   %dl
  800d58:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800d5b:	0f 97 c0             	seta   %al
  800d5e:	21 d0                	and    %edx,%eax
  800d60:	a8 01                	test   $0x1,%al
  800d62:	0f 84 07 ff ff ff    	je     800c6f <__udivdi3+0x3f>
  800d68:	4f                   	dec    %edi
  800d69:	e9 01 ff ff ff       	jmp    800c6f <__udivdi3+0x3f>
  800d6e:	90                   	nop    
  800d6f:	90                   	nop    

00800d70 <__umoddi3>:
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	83 ec 38             	sub    $0x38,%esp
  800d78:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800d7b:	8b 55 14             	mov    0x14(%ebp),%edx
  800d7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800d81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d84:	8b 45 10             	mov    0x10(%ebp),%eax
  800d87:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800d8e:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800d95:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800d98:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800d9b:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800d9e:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800da1:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800da4:	85 d2                	test   %edx,%edx
  800da6:	75 48                	jne    800df0 <__umoddi3+0x80>
  800da8:	39 f8                	cmp    %edi,%eax
  800daa:	0f 86 d0 00 00 00    	jbe    800e80 <__umoddi3+0x110>
  800db0:	89 f0                	mov    %esi,%eax
  800db2:	89 fa                	mov    %edi,%edx
  800db4:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800db7:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800dba:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800dbd:	85 f6                	test   %esi,%esi
  800dbf:	74 49                	je     800e0a <__umoddi3+0x9a>
  800dc1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800dc4:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800dcb:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800dce:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800dd1:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800dd4:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800dd7:	89 10                	mov    %edx,(%eax)
  800dd9:	89 48 04             	mov    %ecx,0x4(%eax)
  800ddc:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800ddf:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800de2:	83 c4 38             	add    $0x38,%esp
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800df0:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800df3:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800df6:	76 1f                	jbe    800e17 <__umoddi3+0xa7>
  800df8:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800dfb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800dfe:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e01:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e04:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800e07:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e0a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e0d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e10:	83 c4 38             	add    $0x38,%esp
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
  800e17:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800e1b:	83 f0 1f             	xor    $0x1f,%eax
  800e1e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800e21:	0f 85 89 00 00 00    	jne    800eb0 <__umoddi3+0x140>
  800e27:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e2a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800e2d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800e30:	0f 97 c2             	seta   %dl
  800e33:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800e36:	0f 93 c0             	setae  %al
  800e39:	09 d0                	or     %edx,%eax
  800e3b:	a8 01                	test   $0x1,%al
  800e3d:	74 11                	je     800e50 <__umoddi3+0xe0>
  800e3f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e42:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e45:	29 c8                	sub    %ecx,%eax
  800e47:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800e4a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800e4d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e50:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e53:	85 c9                	test   %ecx,%ecx
  800e55:	74 b3                	je     800e0a <__umoddi3+0x9a>
  800e57:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e5a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e5d:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e60:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800e63:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e66:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e69:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e6c:	89 01                	mov    %eax,(%ecx)
  800e6e:	89 51 04             	mov    %edx,0x4(%ecx)
  800e71:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e74:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e77:	83 c4 38             	add    $0x38,%esp
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
  800e7e:	89 f6                	mov    %esi,%esi
  800e80:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  800e83:	85 ff                	test   %edi,%edi
  800e85:	75 0d                	jne    800e94 <__umoddi3+0x124>
  800e87:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8c:	31 d2                	xor    %edx,%edx
  800e8e:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800e91:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800e94:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800e97:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e9a:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800e9d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ea0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800ea3:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ea6:	e9 0c ff ff ff       	jmp    800db7 <__umoddi3+0x47>
  800eab:	90                   	nop    
  800eac:	8d 74 26 00          	lea    0x0(%esi),%esi
  800eb0:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  800eb3:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb8:	29 d0                	sub    %edx,%eax
  800eba:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ebd:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800ec0:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800ec3:	d3 e2                	shl    %cl,%edx
  800ec5:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  800ec8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ed2:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  800ed5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800ed8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800edb:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800ede:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  800ee1:	d3 ea                	shr    %cl,%edx
  800ee3:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ee6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ee9:	d3 e6                	shl    %cl,%esi
  800eeb:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800eee:	d3 e8                	shr    %cl,%eax
  800ef0:	09 c6                	or     %eax,%esi
  800ef2:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800ef5:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  800ef8:	89 f0                	mov    %esi,%eax
  800efa:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800efd:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  800f00:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f03:	f7 65 c4             	mull   0xffffffc4(%ebp)
  800f06:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f09:	89 d6                	mov    %edx,%esi
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	77 12                	ja     800f21 <__umoddi3+0x1b1>
  800f0f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f12:	0f 94 c2             	sete   %dl
  800f15:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  800f18:	0f 97 c0             	seta   %al
  800f1b:	21 d0                	and    %edx,%eax
  800f1d:	a8 01                	test   $0x1,%al
  800f1f:	74 06                	je     800f27 <__umoddi3+0x1b7>
  800f21:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  800f24:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  800f27:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	0f 84 d8 fe ff ff    	je     800e0a <__umoddi3+0x9a>
  800f32:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f35:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f38:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f3b:	29 f8                	sub    %edi,%eax
  800f3d:	19 f2                	sbb    %esi,%edx
  800f3f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f42:	d3 e2                	shl    %cl,%edx
  800f44:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f47:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f4a:	d3 e8                	shr    %cl,%eax
  800f4c:	09 c2                	or     %eax,%edx
  800f4e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f51:	d3 e8                	shr    %cl,%eax
  800f53:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  800f56:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800f59:	e9 70 fe ff ff       	jmp    800dce <__umoddi3+0x5e>
  800f5e:	90                   	nop    
  800f5f:	90                   	nop    
