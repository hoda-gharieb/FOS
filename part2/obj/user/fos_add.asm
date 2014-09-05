
obj/user/fos_add:     file format elf32-i386

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
  800031:	e8 42 00 00 00       	call   800078 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	53                   	push   %ebx
  80003c:	83 ec 08             	sub    $0x8,%esp
	int i1=0;
	int i2=0;

	i1 = strtol("1", NULL, 10);
  80003f:	6a 0a                	push   $0xa
  800041:	6a 00                	push   $0x0
  800043:	68 a0 0f 80 00       	push   $0x800fa0
  800048:	e8 25 08 00 00       	call   800872 <strtol>
  80004d:	89 c3                	mov    %eax,%ebx
	i2 = strtol("2", NULL, 10);
  80004f:	83 c4 0c             	add    $0xc,%esp
  800052:	6a 0a                	push   $0xa
  800054:	6a 00                	push   $0x0
  800056:	68 a2 0f 80 00       	push   $0x800fa2
  80005b:	e8 12 08 00 00       	call   800872 <strtol>

	cprintf("number 1 + number 2 = %d\n",i1+i2);
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	8d 04 18             	lea    (%eax,%ebx,1),%eax
  800066:	50                   	push   %eax
  800067:	68 a4 0f 80 00       	push   $0x800fa4
  80006c:	e8 e7 00 00 00       	call   800158 <cprintf>
	return;	
}
  800071:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800081:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  800084:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  80008b:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 c9                	test   %ecx,%ecx
  800090:	7e 07                	jle    800099 <libmain+0x21>
		binaryname = argv[0];
  800092:	8b 02                	mov    (%edx),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  800099:	83 ec 08             	sub    $0x8,%esp
  80009c:	52                   	push   %edx
  80009d:	51                   	push   %ecx
  80009e:	e8 95 ff ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  8000a3:	e8 13 00 00 00       	call   8000bb <sleep>
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 60 0a 00 00       	call   800b19 <sys_env_destroy>
}
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <sleep>:

void
sleep(void)
{	
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  8000c1:	e8 92 0a 00 00       	call   800b58 <sys_env_sleep>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 1a                	jne    8000ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	68 ff 00 00 00       	push   $0xff
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	50                   	push   %eax
  8000f1:	e8 e6 09 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ff:	ff 43 04             	incl   0x4(%ebx)
}
  800102:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800105:	c9                   	leave  
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	ff 75 0c             	pushl  0xc(%ebp)
  800127:	ff 75 08             	pushl  0x8(%ebp)
  80012a:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800130:	50                   	push   %eax
  800131:	68 c8 00 80 00       	push   $0x8000c8
  800136:	e8 2d 01 00 00       	call   800268 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800144:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 8c 09 00 00       	call   800adc <sys_cputs>

	return b.cnt;
  800150:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	50                   	push   %eax
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	e8 9d ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	8b 75 10             	mov    0x10(%ebp),%esi
  800178:	8b 7d 14             	mov    0x14(%ebp),%edi
  80017b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 45 18             	mov    0x18(%ebp),%eax
  800181:	ba 00 00 00 00       	mov    $0x0,%edx
  800186:	39 d7                	cmp    %edx,%edi
  800188:	72 39                	jb     8001c3 <printnum+0x57>
  80018a:	77 04                	ja     800190 <printnum+0x24>
  80018c:	39 c6                	cmp    %eax,%esi
  80018e:	72 33                	jb     8001c3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	ff 75 20             	pushl  0x20(%ebp)
  800196:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800199:	50                   	push   %eax
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	52                   	push   %edx
  8001a6:	50                   	push   %eax
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	e8 b2 0a 00 00       	call   800c60 <__udivdi3>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	52                   	push   %edx
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 0c             	pushl  0xc(%ebp)
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	e8 ae ff ff ff       	call   80016c <printnum>
  8001be:	83 c4 20             	add    $0x20,%esp
  8001c1:	eb 19                	jmp    8001dc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c3:	4b                   	dec    %ebx
  8001c4:	85 db                	test   %ebx,%ebx
  8001c6:	7e 14                	jle    8001dc <printnum+0x70>
			putch(padc, putdat);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ce:	ff 75 20             	pushl  0x20(%ebp)
  8001d1:	ff 55 08             	call   *0x8(%ebp)
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	4b                   	dec    %ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f ec                	jg     8001c8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	52                   	push   %edx
  8001ee:	50                   	push   %eax
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	e8 aa 0b 00 00       	call   800da0 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff 55 08             	call   *0x8(%ebp)
}
  800204:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800212:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800215:	83 f8 01             	cmp    $0x1,%eax
  800218:	7e 0f                	jle    800229 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80021a:	8b 01                	mov    (%ecx),%eax
  80021c:	83 c0 08             	add    $0x8,%eax
  80021f:	89 01                	mov    %eax,(%ecx)
  800221:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800224:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800227:	eb 0f                	jmp    800238 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800229:	8b 01                	mov    (%ecx),%eax
  80022b:	83 c0 04             	add    $0x4,%eax
  80022e:	89 01                	mov    %eax,(%ecx)
  800230:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800233:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800243:	83 f8 01             	cmp    $0x1,%eax
  800246:	7e 0f                	jle    800257 <getint+0x1d>
		return va_arg(*ap, long long);
  800248:	8b 02                	mov    (%edx),%eax
  80024a:	83 c0 08             	add    $0x8,%eax
  80024d:	89 02                	mov    %eax,(%edx)
  80024f:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800252:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800255:	eb 0f                	jmp    800266 <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800257:	8b 02                	mov    (%edx),%eax
  800259:	83 c0 04             	add    $0x4,%eax
  80025c:	89 02                	mov    %eax,(%edx)
  80025e:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800261:	89 c2                	mov    %eax,%edx
  800263:	c1 fa 1f             	sar    $0x1f,%edx
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 1c             	sub    $0x1c,%esp
  800271:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800274:	ba 00 00 00 00       	mov    $0x0,%edx
  800279:	8a 13                	mov    (%ebx),%dl
  80027b:	43                   	inc    %ebx
  80027c:	83 fa 25             	cmp    $0x25,%edx
  80027f:	74 22                	je     8002a3 <vprintfmt+0x3b>
			if (ch == '\0')
  800281:	85 d2                	test   %edx,%edx
  800283:	0f 84 cd 02 00 00    	je     800556 <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	ff 75 0c             	pushl  0xc(%ebp)
  80028f:	52                   	push   %edx
  800290:	ff 55 08             	call   *0x8(%ebp)
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	8a 13                	mov    (%ebx),%dl
  80029d:	43                   	inc    %ebx
  80029e:	83 fa 25             	cmp    $0x25,%edx
  8002a1:	75 de                	jne    800281 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002a3:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002a7:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002ae:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002b3:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8002b8:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c4:	8a 13                	mov    (%ebx),%dl
  8002c6:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002c9:	43                   	inc    %ebx
  8002ca:	83 f8 55             	cmp    $0x55,%eax
  8002cd:	0f 87 5e 02 00 00    	ja     800531 <vprintfmt+0x2c9>
  8002d3:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002da:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  8002de:	eb df                	jmp    8002bf <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e0:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  8002e4:	eb d9                	jmp    8002bf <vprintfmt+0x57>

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
  8002e6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002eb:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002ee:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8002f2:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8002f5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8002f8:	83 f8 09             	cmp    $0x9,%eax
  8002fb:	77 27                	ja     800324 <vprintfmt+0xbc>
  8002fd:	43                   	inc    %ebx
  8002fe:	eb eb                	jmp    8002eb <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800300:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800304:	8b 45 14             	mov    0x14(%ebp),%eax
  800307:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80030a:	eb 18                	jmp    800324 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  80030c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800310:	79 ad                	jns    8002bf <vprintfmt+0x57>
				width = 0;
  800312:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  800319:	eb a4                	jmp    8002bf <vprintfmt+0x57>

		case '#':
			altflag = 1;
  80031b:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800322:	eb 9b                	jmp    8002bf <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  800324:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800328:	79 95                	jns    8002bf <vprintfmt+0x57>
				width = precision, precision = -1;
  80032a:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  80032d:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800332:	eb 8b                	jmp    8002bf <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800334:	41                   	inc    %ecx
			goto reswitch;
  800335:	eb 88                	jmp    8002bf <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	ff 70 fc             	pushl  0xfffffffc(%eax)
  800347:	e9 da 01 00 00       	jmp    800526 <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80034c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	79 02                	jns    80035c <vprintfmt+0xf4>
				err = -err;
  80035a:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80035c:	83 f8 07             	cmp    $0x7,%eax
  80035f:	7f 0b                	jg     80036c <vprintfmt+0x104>
  800361:	8b 3c 85 80 10 80 00 	mov    0x801080(,%eax,4),%edi
  800368:	85 ff                	test   %edi,%edi
  80036a:	75 08                	jne    800374 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  80036c:	50                   	push   %eax
  80036d:	68 4f 10 80 00       	push   $0x80104f
  800372:	eb 06                	jmp    80037a <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  800374:	57                   	push   %edi
  800375:	68 58 10 80 00       	push   $0x801058
  80037a:	ff 75 0c             	pushl  0xc(%ebp)
  80037d:	ff 75 08             	pushl  0x8(%ebp)
  800380:	e8 d9 01 00 00       	call   80055e <printfmt>
  800385:	e9 9f 01 00 00       	jmp    800529 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80038a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  800394:	85 ff                	test   %edi,%edi
  800396:	75 05                	jne    80039d <vprintfmt+0x135>
				p = "(null)";
  800398:	bf 5b 10 80 00       	mov    $0x80105b,%edi
			if (width > 0 && padc != '-')
  80039d:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003a1:	0f 9f c2             	setg   %dl
  8003a4:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003a8:	0f 95 c0             	setne  %al
  8003ab:	21 d0                	and    %edx,%eax
  8003ad:	a8 01                	test   $0x1,%al
  8003af:	74 35                	je     8003e6 <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	56                   	push   %esi
  8003b5:	57                   	push   %edi
  8003b6:	e8 5e 02 00 00       	call   800619 <strnlen>
  8003bb:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003c5:	7e 1f                	jle    8003e6 <vprintfmt+0x17e>
  8003c7:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003cb:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003d7:	ff 55 08             	call   *0x8(%ebp)
  8003da:	83 c4 10             	add    $0x10,%esp
  8003dd:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8003e0:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003e4:	7f e8                	jg     8003ce <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8003e6:	0f be 17             	movsbl (%edi),%edx
  8003e9:	47                   	inc    %edi
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	74 3e                	je     80042c <vprintfmt+0x1c4>
  8003ee:	85 f6                	test   %esi,%esi
  8003f0:	78 03                	js     8003f5 <vprintfmt+0x18d>
  8003f2:	4e                   	dec    %esi
  8003f3:	78 37                	js     80042c <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  8003f5:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8003f9:	74 12                	je     80040d <vprintfmt+0x1a5>
  8003fb:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8003fe:	83 f8 5e             	cmp    $0x5e,%eax
  800401:	76 0a                	jbe    80040d <vprintfmt+0x1a5>
					putch('?', putdat);
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	ff 75 0c             	pushl  0xc(%ebp)
  800409:	6a 3f                	push   $0x3f
  80040b:	eb 07                	jmp    800414 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	52                   	push   %edx
  800414:	ff 55 08             	call   *0x8(%ebp)
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80041d:	0f be 17             	movsbl (%edi),%edx
  800420:	47                   	inc    %edi
  800421:	85 d2                	test   %edx,%edx
  800423:	74 07                	je     80042c <vprintfmt+0x1c4>
  800425:	85 f6                	test   %esi,%esi
  800427:	78 cc                	js     8003f5 <vprintfmt+0x18d>
  800429:	4e                   	dec    %esi
  80042a:	79 c9                	jns    8003f5 <vprintfmt+0x18d>
			for (; width > 0; width--)
  80042c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800430:	0f 8e 3e fe ff ff    	jle    800274 <vprintfmt+0xc>
				putch(' ', putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	ff 75 0c             	pushl  0xc(%ebp)
  80043c:	6a 20                	push   $0x20
  80043e:	ff 55 08             	call   *0x8(%ebp)
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800447:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80044b:	7f e9                	jg     800436 <vprintfmt+0x1ce>
			break;
  80044d:	e9 22 fe ff ff       	jmp    800274 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	51                   	push   %ecx
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
  800459:	50                   	push   %eax
  80045a:	e8 db fd ff ff       	call   80023a <getint>
  80045f:	89 c6                	mov    %eax,%esi
  800461:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 d2                	test   %edx,%edx
  800468:	79 15                	jns    80047f <vprintfmt+0x217>
				putch('-', putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	6a 2d                	push   $0x2d
  800472:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800475:	f7 de                	neg    %esi
  800477:	83 d7 00             	adc    $0x0,%edi
  80047a:	f7 df                	neg    %edi
  80047c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80047f:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800484:	eb 78                	jmp    8004fe <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	51                   	push   %ecx
  80048a:	8d 45 14             	lea    0x14(%ebp),%eax
  80048d:	50                   	push   %eax
  80048e:	e8 79 fd ff ff       	call   80020c <getuint>
  800493:	89 c6                	mov    %eax,%esi
  800495:	89 d7                	mov    %edx,%edi
			base = 10;
  800497:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80049c:	eb 5d                	jmp    8004fb <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	6a 58                	push   $0x58
  8004a6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004a9:	83 c4 08             	add    $0x8,%esp
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	6a 58                	push   $0x58
  8004b1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004b4:	83 c4 08             	add    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 58                	push   $0x58
  8004bc:	eb 68                	jmp    800526 <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 0c             	pushl  0xc(%ebp)
  8004c4:	6a 30                	push   $0x30
  8004c6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004c9:	83 c4 08             	add    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	6a 78                	push   $0x78
  8004d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004d4:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  8004de:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  8004e3:	eb 11                	jmp    8004f6 <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	51                   	push   %ecx
  8004e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	e8 1a fd ff ff       	call   80020c <getuint>
  8004f2:	89 c6                	mov    %eax,%esi
  8004f4:	89 d7                	mov    %edx,%edi
			base = 16;
  8004f6:	ba 10 00 00 00       	mov    $0x10,%edx
  8004fb:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8004fe:	83 ec 04             	sub    $0x4,%esp
  800501:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800505:	50                   	push   %eax
  800506:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  800509:	52                   	push   %edx
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	ff 75 0c             	pushl  0xc(%ebp)
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 55 fc ff ff       	call   80016c <printnum>
			break;
  800517:	83 c4 20             	add    $0x20,%esp
  80051a:	e9 55 fd ff ff       	jmp    800274 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
			break;
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	e9 43 fd ff ff       	jmp    800274 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	6a 25                	push   $0x25
  800539:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80053c:	4b                   	dec    %ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800544:	0f 84 2a fd ff ff    	je     800274 <vprintfmt+0xc>
  80054a:	4b                   	dec    %ebx
  80054b:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  80054f:	75 f9                	jne    80054a <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800551:	e9 1e fd ff ff       	jmp    800274 <vprintfmt+0xc>
		}
	}
}
  800556:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800559:	5b                   	pop    %ebx
  80055a:	5e                   	pop    %esi
  80055b:	5f                   	pop    %edi
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800564:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800567:	50                   	push   %eax
  800568:	ff 75 10             	pushl  0x10(%ebp)
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 f2 fc ff ff       	call   800268 <vprintfmt>
	va_end(ap);
}
  800576:	c9                   	leave  
  800577:	c3                   	ret    

00800578 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80057e:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800581:	8b 0a                	mov    (%edx),%ecx
  800583:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800586:	73 07                	jae    80058f <sprintputch+0x17>
		*b->buf++ = ch;
  800588:	8b 45 08             	mov    0x8(%ebp),%eax
  80058b:	88 01                	mov    %al,(%ecx)
  80058d:	ff 02                	incl   (%edx)
}
  80058f:	5d                   	pop    %ebp
  800590:	c3                   	ret    

00800591 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	83 ec 18             	sub    $0x18,%esp
  800597:	8b 55 08             	mov    0x8(%ebp),%edx
  80059a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80059d:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005a0:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005a4:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005a7:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	0f 94 c2             	sete   %dl
  8005b3:	85 c9                	test   %ecx,%ecx
  8005b5:	0f 9e c0             	setle  %al
  8005b8:	09 d0                	or     %edx,%eax
  8005ba:	ba 03 00 00 00       	mov    $0x3,%edx
  8005bf:	a8 01                	test   $0x1,%al
  8005c1:	75 1d                	jne    8005e0 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005c3:	ff 75 14             	pushl  0x14(%ebp)
  8005c6:	ff 75 10             	pushl  0x10(%ebp)
  8005c9:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005cc:	50                   	push   %eax
  8005cd:	68 78 05 80 00       	push   $0x800578
  8005d2:	e8 91 fc ff ff       	call   800268 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005d7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8005da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005dd:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8005ed:	50                   	push   %eax
  8005ee:	ff 75 10             	pushl  0x10(%ebp)
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	ff 75 08             	pushl  0x8(%ebp)
  8005f7:	e8 95 ff ff ff       	call   800591 <vsnprintf>
	va_end(ap);

	return rc;
}
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    
	...

00800600 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800606:	b8 00 00 00 00       	mov    $0x0,%eax
  80060b:	80 3a 00             	cmpb   $0x0,(%edx)
  80060e:	74 07                	je     800617 <strlen+0x17>
		n++;
  800610:	40                   	inc    %eax
  800611:	42                   	inc    %edx
  800612:	80 3a 00             	cmpb   $0x0,(%edx)
  800615:	75 f9                	jne    800610 <strlen+0x10>
	return n;
}
  800617:	5d                   	pop    %ebp
  800618:	c3                   	ret    

00800619 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800622:	b8 00 00 00 00       	mov    $0x0,%eax
  800627:	85 d2                	test   %edx,%edx
  800629:	74 0f                	je     80063a <strnlen+0x21>
  80062b:	80 39 00             	cmpb   $0x0,(%ecx)
  80062e:	74 0a                	je     80063a <strnlen+0x21>
		n++;
  800630:	40                   	inc    %eax
  800631:	41                   	inc    %ecx
  800632:	4a                   	dec    %edx
  800633:	74 05                	je     80063a <strnlen+0x21>
  800635:	80 39 00             	cmpb   $0x0,(%ecx)
  800638:	75 f6                	jne    800630 <strnlen+0x17>
	return n;
}
  80063a:	5d                   	pop    %ebp
  80063b:	c3                   	ret    

0080063c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	53                   	push   %ebx
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800646:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800648:	8a 02                	mov    (%edx),%al
  80064a:	88 01                	mov    %al,(%ecx)
  80064c:	42                   	inc    %edx
  80064d:	41                   	inc    %ecx
  80064e:	84 c0                	test   %al,%al
  800650:	75 f6                	jne    800648 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800652:	89 d8                	mov    %ebx,%eax
  800654:	5b                   	pop    %ebx
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
  800663:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  800666:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800668:	bb 00 00 00 00       	mov    $0x0,%ebx
  80066d:	39 f3                	cmp    %esi,%ebx
  80066f:	73 17                	jae    800688 <strncpy+0x31>
		*dst++ = *src;
  800671:	8a 02                	mov    (%edx),%al
  800673:	88 01                	mov    %al,(%ecx)
  800675:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800676:	80 3a 00             	cmpb   $0x0,(%edx)
  800679:	0f 95 c0             	setne  %al
  80067c:	25 ff 00 00 00       	and    $0xff,%eax
  800681:	01 c2                	add    %eax,%edx
  800683:	43                   	inc    %ebx
  800684:	39 f3                	cmp    %esi,%ebx
  800686:	72 e9                	jb     800671 <strncpy+0x1a>
			src++;
	}
	return ret;
}
  800688:	89 f8                	mov    %edi,%eax
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	56                   	push   %esi
  800693:	53                   	push   %ebx
  800694:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800697:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069a:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80069d:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	74 19                	je     8006bc <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8006a3:	4a                   	dec    %edx
  8006a4:	74 13                	je     8006b9 <strlcpy+0x2a>
  8006a6:	80 39 00             	cmpb   $0x0,(%ecx)
  8006a9:	74 0e                	je     8006b9 <strlcpy+0x2a>
			*dst++ = *src++;
  8006ab:	8a 01                	mov    (%ecx),%al
  8006ad:	88 03                	mov    %al,(%ebx)
  8006af:	41                   	inc    %ecx
  8006b0:	43                   	inc    %ebx
  8006b1:	4a                   	dec    %edx
  8006b2:	74 05                	je     8006b9 <strlcpy+0x2a>
  8006b4:	80 39 00             	cmpb   $0x0,(%ecx)
  8006b7:	75 f2                	jne    8006ab <strlcpy+0x1c>
		*dst = '\0';
  8006b9:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006bc:	89 d8                	mov    %ebx,%eax
  8006be:	29 f0                	sub    %esi,%eax
}
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8006cd:	80 3a 00             	cmpb   $0x0,(%edx)
  8006d0:	74 13                	je     8006e5 <strcmp+0x21>
  8006d2:	8a 02                	mov    (%edx),%al
  8006d4:	3a 01                	cmp    (%ecx),%al
  8006d6:	75 0d                	jne    8006e5 <strcmp+0x21>
		p++, q++;
  8006d8:	42                   	inc    %edx
  8006d9:	41                   	inc    %ecx
  8006da:	80 3a 00             	cmpb   $0x0,(%edx)
  8006dd:	74 06                	je     8006e5 <strcmp+0x21>
  8006df:	8a 02                	mov    (%edx),%al
  8006e1:	3a 01                	cmp    (%ecx),%al
  8006e3:	74 f3                	je     8006d8 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	8a 02                	mov    (%edx),%al
  8006ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f1:	8a 11                	mov    (%ecx),%dl
  8006f3:	29 d0                	sub    %edx,%eax
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800701:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  800704:	85 c9                	test   %ecx,%ecx
  800706:	74 1f                	je     800727 <strncmp+0x30>
  800708:	80 3a 00             	cmpb   $0x0,(%edx)
  80070b:	74 16                	je     800723 <strncmp+0x2c>
  80070d:	8a 02                	mov    (%edx),%al
  80070f:	3a 03                	cmp    (%ebx),%al
  800711:	75 10                	jne    800723 <strncmp+0x2c>
		n--, p++, q++;
  800713:	42                   	inc    %edx
  800714:	43                   	inc    %ebx
  800715:	49                   	dec    %ecx
  800716:	74 0f                	je     800727 <strncmp+0x30>
  800718:	80 3a 00             	cmpb   $0x0,(%edx)
  80071b:	74 06                	je     800723 <strncmp+0x2c>
  80071d:	8a 02                	mov    (%edx),%al
  80071f:	3a 03                	cmp    (%ebx),%al
  800721:	74 f0                	je     800713 <strncmp+0x1c>
	if (n == 0)
  800723:	85 c9                	test   %ecx,%ecx
  800725:	75 07                	jne    80072e <strncmp+0x37>
		return 0;
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 13                	jmp    800741 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80072e:	8a 12                	mov    (%edx),%dl
  800730:	81 e2 ff 00 00 00    	and    $0xff,%edx
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	8a 03                	mov    (%ebx),%al
  80073d:	29 c2                	sub    %eax,%edx
  80073f:	89 d0                	mov    %edx,%eax
}
  800741:	5b                   	pop    %ebx
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
  80074a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80074d:	80 3a 00             	cmpb   $0x0,(%edx)
  800750:	74 0c                	je     80075e <strchr+0x1a>
		if (*s == c)
  800752:	89 d0                	mov    %edx,%eax
  800754:	38 0a                	cmp    %cl,(%edx)
  800756:	74 0b                	je     800763 <strchr+0x1f>
  800758:	42                   	inc    %edx
  800759:	80 3a 00             	cmpb   $0x0,(%edx)
  80075c:	75 f4                	jne    800752 <strchr+0xe>
			return (char *) s;
	return 0;
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80076e:	80 38 00             	cmpb   $0x0,(%eax)
  800771:	74 0a                	je     80077d <strfind+0x18>
		if (*s == c)
  800773:	38 10                	cmp    %dl,(%eax)
  800775:	74 06                	je     80077d <strfind+0x18>
  800777:	40                   	inc    %eax
  800778:	80 38 00             	cmpb   $0x0,(%eax)
  80077b:	75 f6                	jne    800773 <strfind+0xe>
			break;
	return (char *) s;
}
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <memset>:


void *
memset(void *v, int c, uint32 n)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  800789:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
  80078e:	4a                   	dec    %edx
  80078f:	78 06                	js     800797 <memset+0x18>
		*p++ = c;
  800791:	88 01                	mov    %al,(%ecx)
  800793:	41                   	inc    %ecx
  800794:	4a                   	dec    %edx
  800795:	79 fa                	jns    800791 <memset+0x12>

	return v;
}
  800797:	89 d8                	mov    %ebx,%eax
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  8007aa:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  8007ac:	89 c8                	mov    %ecx,%eax
  8007ae:	49                   	dec    %ecx
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	74 0d                	je     8007c0 <memcpy+0x24>
		*d++ = *s++;
  8007b3:	8a 03                	mov    (%ebx),%al
  8007b5:	88 02                	mov    %al,(%edx)
  8007b7:	43                   	inc    %ebx
  8007b8:	42                   	inc    %edx
  8007b9:	89 c8                	mov    %ecx,%eax
  8007bb:	49                   	dec    %ecx
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	75 f3                	jne    8007b3 <memcpy+0x17>

	return dst;
}
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  8007d4:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  8007d6:	39 f1                	cmp    %esi,%ecx
  8007d8:	73 22                	jae    8007fc <memmove+0x36>
  8007da:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  8007dd:	39 f0                	cmp    %esi,%eax
  8007df:	76 1b                	jbe    8007fc <memmove+0x36>
		s += n;
  8007e1:	89 c1                	mov    %eax,%ecx
		d += n;
  8007e3:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  8007e6:	89 d0                	mov    %edx,%eax
  8007e8:	4a                   	dec    %edx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	74 23                	je     800810 <memmove+0x4a>
			*--d = *--s;
  8007ed:	4b                   	dec    %ebx
  8007ee:	49                   	dec    %ecx
  8007ef:	8a 01                	mov    (%ecx),%al
  8007f1:	88 03                	mov    %al,(%ebx)
  8007f3:	89 d0                	mov    %edx,%eax
  8007f5:	4a                   	dec    %edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	75 f3                	jne    8007ed <memmove+0x27>
  8007fa:	eb 14                	jmp    800810 <memmove+0x4a>
	} else
		while (n-- > 0)
  8007fc:	89 d0                	mov    %edx,%eax
  8007fe:	4a                   	dec    %edx
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 0d                	je     800810 <memmove+0x4a>
			*d++ = *s++;
  800803:	8a 01                	mov    (%ecx),%al
  800805:	88 03                	mov    %al,(%ebx)
  800807:	41                   	inc    %ecx
  800808:	43                   	inc    %ebx
  800809:	89 d0                	mov    %edx,%eax
  80080b:	4a                   	dec    %edx
  80080c:	85 c0                	test   %eax,%eax
  80080e:	75 f3                	jne    800803 <memmove+0x3d>

	return dst;
}
  800810:	89 f0                	mov    %esi,%eax
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  800820:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  800823:	89 d0                	mov    %edx,%eax
  800825:	4a                   	dec    %edx
  800826:	85 c0                	test   %eax,%eax
  800828:	74 23                	je     80084d <memcmp+0x37>
		if (*s1 != *s2)
  80082a:	8a 01                	mov    (%ecx),%al
  80082c:	3a 03                	cmp    (%ebx),%al
  80082e:	74 14                	je     800844 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  800830:	ba 00 00 00 00       	mov    $0x0,%edx
  800835:	8a 11                	mov    (%ecx),%dl
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
  80083c:	8a 03                	mov    (%ebx),%al
  80083e:	29 c2                	sub    %eax,%edx
  800840:	89 d0                	mov    %edx,%eax
  800842:	eb 0e                	jmp    800852 <memcmp+0x3c>
		s1++, s2++;
  800844:	41                   	inc    %ecx
  800845:	43                   	inc    %ebx
  800846:	89 d0                	mov    %edx,%eax
  800848:	4a                   	dec    %edx
  800849:	85 c0                	test   %eax,%eax
  80084b:	75 dd                	jne    80082a <memcmp+0x14>
	}

	return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80085e:	89 c2                	mov    %eax,%edx
  800860:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800863:	39 d0                	cmp    %edx,%eax
  800865:	73 09                	jae    800870 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800867:	38 08                	cmp    %cl,(%eax)
  800869:	74 05                	je     800870 <memfind+0x1b>
  80086b:	40                   	inc    %eax
  80086c:	39 d0                	cmp    %edx,%eax
  80086e:	72 f7                	jb     800867 <memfind+0x12>
			break;
	return (void *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	83 ec 04             	sub    $0x4,%esp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800881:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800884:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  80088b:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800890:	80 39 20             	cmpb   $0x20,(%ecx)
  800893:	0f 94 c2             	sete   %dl
  800896:	80 39 09             	cmpb   $0x9,(%ecx)
  800899:	0f 94 c0             	sete   %al
  80089c:	09 d0                	or     %edx,%eax
  80089e:	a8 01                	test   $0x1,%al
  8008a0:	74 13                	je     8008b5 <strtol+0x43>
		s++;
  8008a2:	41                   	inc    %ecx
  8008a3:	80 39 20             	cmpb   $0x20,(%ecx)
  8008a6:	0f 94 c2             	sete   %dl
  8008a9:	80 39 09             	cmpb   $0x9,(%ecx)
  8008ac:	0f 94 c0             	sete   %al
  8008af:	09 d0                	or     %edx,%eax
  8008b1:	a8 01                	test   $0x1,%al
  8008b3:	75 ed                	jne    8008a2 <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  8008b5:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8008b8:	75 03                	jne    8008bd <strtol+0x4b>
		s++;
  8008ba:	41                   	inc    %ecx
  8008bb:	eb 0d                	jmp    8008ca <strtol+0x58>
	else if (*s == '-')
  8008bd:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8008c0:	75 08                	jne    8008ca <strtol+0x58>
		s++, neg = 1;
  8008c2:	41                   	inc    %ecx
  8008c3:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008ca:	85 db                	test   %ebx,%ebx
  8008cc:	0f 94 c2             	sete   %dl
  8008cf:	83 fb 10             	cmp    $0x10,%ebx
  8008d2:	0f 94 c0             	sete   %al
  8008d5:	09 d0                	or     %edx,%eax
  8008d7:	a8 01                	test   $0x1,%al
  8008d9:	74 15                	je     8008f0 <strtol+0x7e>
  8008db:	80 39 30             	cmpb   $0x30,(%ecx)
  8008de:	75 10                	jne    8008f0 <strtol+0x7e>
  8008e0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8008e4:	75 0a                	jne    8008f0 <strtol+0x7e>
		s += 2, base = 16;
  8008e6:	83 c1 02             	add    $0x2,%ecx
  8008e9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8008ee:	eb 1a                	jmp    80090a <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  8008f0:	85 db                	test   %ebx,%ebx
  8008f2:	75 16                	jne    80090a <strtol+0x98>
  8008f4:	80 39 30             	cmpb   $0x30,(%ecx)
  8008f7:	75 08                	jne    800901 <strtol+0x8f>
		s++, base = 8;
  8008f9:	41                   	inc    %ecx
  8008fa:	bb 08 00 00 00       	mov    $0x8,%ebx
  8008ff:	eb 09                	jmp    80090a <strtol+0x98>
	else if (base == 0)
  800901:	85 db                	test   %ebx,%ebx
  800903:	75 05                	jne    80090a <strtol+0x98>
		base = 10;
  800905:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80090a:	8a 01                	mov    (%ecx),%al
  80090c:	83 e8 30             	sub    $0x30,%eax
  80090f:	3c 09                	cmp    $0x9,%al
  800911:	77 08                	ja     80091b <strtol+0xa9>
			dig = *s - '0';
  800913:	0f be 01             	movsbl (%ecx),%eax
  800916:	83 e8 30             	sub    $0x30,%eax
  800919:	eb 20                	jmp    80093b <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  80091b:	8a 01                	mov    (%ecx),%al
  80091d:	83 e8 61             	sub    $0x61,%eax
  800920:	3c 19                	cmp    $0x19,%al
  800922:	77 08                	ja     80092c <strtol+0xba>
			dig = *s - 'a' + 10;
  800924:	0f be 01             	movsbl (%ecx),%eax
  800927:	83 e8 57             	sub    $0x57,%eax
  80092a:	eb 0f                	jmp    80093b <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  80092c:	8a 01                	mov    (%ecx),%al
  80092e:	83 e8 41             	sub    $0x41,%eax
  800931:	3c 19                	cmp    $0x19,%al
  800933:	77 12                	ja     800947 <strtol+0xd5>
			dig = *s - 'A' + 10;
  800935:	0f be 01             	movsbl (%ecx),%eax
  800938:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80093b:	39 d8                	cmp    %ebx,%eax
  80093d:	7d 08                	jge    800947 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  80093f:	41                   	inc    %ecx
  800940:	0f af f3             	imul   %ebx,%esi
  800943:	01 c6                	add    %eax,%esi
  800945:	eb c3                	jmp    80090a <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  800947:	85 ff                	test   %edi,%edi
  800949:	74 02                	je     80094d <strtol+0xdb>
		*endptr = (char *) s;
  80094b:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800953:	74 02                	je     800957 <strtol+0xe5>
  800955:	f7 d8                	neg    %eax
}
  800957:	83 c4 04             	add    $0x4,%esp
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	83 ec 04             	sub    $0x4,%esp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80096e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800971:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800978:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097d:	80 39 20             	cmpb   $0x20,(%ecx)
  800980:	0f 94 c2             	sete   %dl
  800983:	80 39 09             	cmpb   $0x9,(%ecx)
  800986:	0f 94 c0             	sete   %al
  800989:	09 d0                	or     %edx,%eax
  80098b:	a8 01                	test   $0x1,%al
  80098d:	74 13                	je     8009a2 <strtoul+0x43>
		s++;
  80098f:	41                   	inc    %ecx
  800990:	80 39 20             	cmpb   $0x20,(%ecx)
  800993:	0f 94 c2             	sete   %dl
  800996:	80 39 09             	cmpb   $0x9,(%ecx)
  800999:	0f 94 c0             	sete   %al
  80099c:	09 d0                	or     %edx,%eax
  80099e:	a8 01                	test   $0x1,%al
  8009a0:	75 ed                	jne    80098f <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  8009a2:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8009a5:	75 03                	jne    8009aa <strtoul+0x4b>
		s++;
  8009a7:	41                   	inc    %ecx
  8009a8:	eb 0d                	jmp    8009b7 <strtoul+0x58>
	else if (*s == '-')
  8009aa:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8009ad:	75 08                	jne    8009b7 <strtoul+0x58>
		s++, neg = 1;
  8009af:	41                   	inc    %ecx
  8009b0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	0f 94 c2             	sete   %dl
  8009bc:	83 fb 10             	cmp    $0x10,%ebx
  8009bf:	0f 94 c0             	sete   %al
  8009c2:	09 d0                	or     %edx,%eax
  8009c4:	a8 01                	test   $0x1,%al
  8009c6:	74 15                	je     8009dd <strtoul+0x7e>
  8009c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cb:	75 10                	jne    8009dd <strtoul+0x7e>
  8009cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d1:	75 0a                	jne    8009dd <strtoul+0x7e>
		s += 2, base = 16;
  8009d3:	83 c1 02             	add    $0x2,%ecx
  8009d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009db:	eb 1a                	jmp    8009f7 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  8009dd:	85 db                	test   %ebx,%ebx
  8009df:	75 16                	jne    8009f7 <strtoul+0x98>
  8009e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e4:	75 08                	jne    8009ee <strtoul+0x8f>
		s++, base = 8;
  8009e6:	41                   	inc    %ecx
  8009e7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009ec:	eb 09                	jmp    8009f7 <strtoul+0x98>
	else if (base == 0)
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	75 05                	jne    8009f7 <strtoul+0x98>
		base = 10;
  8009f2:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f7:	8a 01                	mov    (%ecx),%al
  8009f9:	83 e8 30             	sub    $0x30,%eax
  8009fc:	3c 09                	cmp    $0x9,%al
  8009fe:	77 08                	ja     800a08 <strtoul+0xa9>
			dig = *s - '0';
  800a00:	0f be 01             	movsbl (%ecx),%eax
  800a03:	83 e8 30             	sub    $0x30,%eax
  800a06:	eb 20                	jmp    800a28 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800a08:	8a 01                	mov    (%ecx),%al
  800a0a:	83 e8 61             	sub    $0x61,%eax
  800a0d:	3c 19                	cmp    $0x19,%al
  800a0f:	77 08                	ja     800a19 <strtoul+0xba>
			dig = *s - 'a' + 10;
  800a11:	0f be 01             	movsbl (%ecx),%eax
  800a14:	83 e8 57             	sub    $0x57,%eax
  800a17:	eb 0f                	jmp    800a28 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800a19:	8a 01                	mov    (%ecx),%al
  800a1b:	83 e8 41             	sub    $0x41,%eax
  800a1e:	3c 19                	cmp    $0x19,%al
  800a20:	77 12                	ja     800a34 <strtoul+0xd5>
			dig = *s - 'A' + 10;
  800a22:	0f be 01             	movsbl (%ecx),%eax
  800a25:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a28:	39 d8                	cmp    %ebx,%eax
  800a2a:	7d 08                	jge    800a34 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a2c:	41                   	inc    %ecx
  800a2d:	0f af f3             	imul   %ebx,%esi
  800a30:	01 c6                	add    %eax,%esi
  800a32:	eb c3                	jmp    8009f7 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800a34:	85 ff                	test   %edi,%edi
  800a36:	74 02                	je     800a3a <strtoul+0xdb>
		*endptr = (char *) s;
  800a38:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a3a:	89 f0                	mov    %esi,%eax
  800a3c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a40:	74 02                	je     800a44 <strtoul+0xe5>
  800a42:	f7 d8                	neg    %eax
}
  800a44:	83 c4 04             	add    $0x4,%esp
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	83 ec 0c             	sub    $0xc,%esp
  800a55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800a5e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800a6d:	eb 04                	jmp    800a73 <strsplit+0x27>
			*string++ = 0;
  800a6f:	c6 03 00             	movb   $0x0,(%ebx)
  800a72:	43                   	inc    %ebx
  800a73:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a76:	74 4b                	je     800ac3 <strsplit+0x77>
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	0f be 03             	movsbl (%ebx),%eax
  800a7e:	50                   	push   %eax
  800a7f:	56                   	push   %esi
  800a80:	e8 bf fc ff ff       	call   800744 <strchr>
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	75 e3                	jne    800a6f <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800a8c:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a8f:	74 32                	je     800ac3 <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	83 3f 0f             	cmpl   $0xf,(%edi)
  800a99:	74 39                	je     800ad4 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800a9b:	8b 07                	mov    (%edi),%eax
  800a9d:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa0:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800aa3:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800aa5:	eb 01                	jmp    800aa8 <strsplit+0x5c>
			string++;
  800aa7:	43                   	inc    %ebx
  800aa8:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aab:	74 16                	je     800ac3 <strsplit+0x77>
  800aad:	83 ec 08             	sub    $0x8,%esp
  800ab0:	0f be 03             	movsbl (%ebx),%eax
  800ab3:	50                   	push   %eax
  800ab4:	56                   	push   %esi
  800ab5:	e8 8a fc ff ff       	call   800744 <strchr>
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	85 c0                	test   %eax,%eax
  800abf:	74 e6                	je     800aa7 <strsplit+0x5b>
  800ac1:	eb b0                	jmp    800a73 <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800ac3:	8b 07                	mov    (%edi),%eax
  800ac5:	8b 55 10             	mov    0x10(%ebp),%edx
  800ac8:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ad4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	89 fb                	mov    %edi,%ebx
  800af1:	89 fe                	mov    %edi,%esi
  800af3:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cgetc>:

int
sys_cgetc(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	b8 01 00 00 00       	mov    $0x1,%eax
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0a:	89 fa                	mov    %edi,%edx
  800b0c:	89 f9                	mov    %edi,%ecx
  800b0e:	89 fb                	mov    %edi,%ebx
  800b10:	89 fe                	mov    %edi,%esi
  800b12:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	b8 03 00 00 00       	mov    $0x3,%eax
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2c:	89 f9                	mov    %edi,%ecx
  800b2e:	89 fb                	mov    %edi,%ebx
  800b30:	89 fe                	mov    %edi,%esi
  800b32:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b44:	bf 00 00 00 00       	mov    $0x0,%edi
  800b49:	89 fa                	mov    %edi,%edx
  800b4b:	89 f9                	mov    %edi,%ecx
  800b4d:	89 fb                	mov    %edi,%ebx
  800b4f:	89 fe                	mov    %edi,%esi
  800b51:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
  800b68:	89 fa                	mov    %edi,%edx
  800b6a:	89 f9                	mov    %edi,%ecx
  800b6c:	89 fb                	mov    %edi,%ebx
  800b6e:	89 fe                	mov    %edi,%esi
  800b70:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	b8 05 00 00 00       	mov    $0x5,%eax
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8d:	89 fb                	mov    %edi,%ebx
  800b8f:	89 fe                	mov    %edi,%esi
  800b91:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	89 fb                	mov    %edi,%ebx
  800bb0:	89 fe                	mov    %edi,%esi
  800bb2:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	b8 07 00 00 00       	mov    $0x7,%eax
  800bd3:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	b8 08 00 00 00       	mov    $0x8,%eax
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf0:	89 fb                	mov    %edi,%ebx
  800bf2:	89 fe                	mov    %edi,%esi
  800bf4:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c11:	89 fb                	mov    %edi,%ebx
  800c13:	89 fe                	mov    %edi,%esi
  800c15:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2c:	89 fa                	mov    %edi,%edx
  800c2e:	89 f9                	mov    %edi,%ecx
  800c30:	89 fb                	mov    %edi,%ebx
  800c32:	89 fe                	mov    %edi,%esi
  800c34:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	89 fb                	mov    %edi,%ebx
  800c53:	89 fe                	mov    %edi,%esi
  800c55:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
  800c5c:	00 00                	add    %al,(%eax)
	...

00800c60 <__udivdi3>:
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	83 ec 20             	sub    $0x20,%esp
  800c68:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800c6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c72:	8b 55 14             	mov    0x14(%ebp),%edx
  800c75:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800c7e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800c85:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800c88:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800c8b:	89 fe                	mov    %edi,%esi
  800c8d:	85 d2                	test   %edx,%edx
  800c8f:	75 2f                	jne    800cc0 <__udivdi3+0x60>
  800c91:	39 f8                	cmp    %edi,%eax
  800c93:	76 62                	jbe    800cf7 <__udivdi3+0x97>
  800c95:	89 fa                	mov    %edi,%edx
  800c97:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800c9a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800c9d:	89 c7                	mov    %eax,%edi
  800c9f:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800ca6:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800ca9:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800cac:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800caf:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800cb2:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800cb5:	83 c4 20             	add    $0x20,%esp
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    
  800cbc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800cc0:	31 ff                	xor    %edi,%edi
  800cc2:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800cc9:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800ccc:	77 d8                	ja     800ca6 <__udivdi3+0x46>
  800cce:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800cd2:	89 c7                	mov    %eax,%edi
  800cd4:	83 f7 1f             	xor    $0x1f,%edi
  800cd7:	75 5b                	jne    800d34 <__udivdi3+0xd4>
  800cd9:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800cdc:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800cdf:	0f 97 c2             	seta   %dl
  800ce2:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800ce5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cea:	0f 93 c0             	setae  %al
  800ced:	09 d0                	or     %edx,%eax
  800cef:	a8 01                	test   $0x1,%al
  800cf1:	75 ac                	jne    800c9f <__udivdi3+0x3f>
  800cf3:	31 ff                	xor    %edi,%edi
  800cf5:	eb a8                	jmp    800c9f <__udivdi3+0x3f>
  800cf7:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	75 0e                	jne    800d0c <__udivdi3+0xac>
  800cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800d03:	31 c9                	xor    %ecx,%ecx
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	f7 f1                	div    %ecx
  800d09:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800d0c:	89 f0                	mov    %esi,%eax
  800d0e:	31 d2                	xor    %edx,%edx
  800d10:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800d13:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800d16:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d19:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800d21:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800d24:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800d27:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800d2a:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800d2d:	83 c4 20             	add    $0x20,%esp
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
  800d34:	b8 20 00 00 00       	mov    $0x20,%eax
  800d39:	89 f9                	mov    %edi,%ecx
  800d3b:	29 f8                	sub    %edi,%eax
  800d3d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800d40:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800d43:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d46:	d3 e2                	shl    %cl,%edx
  800d48:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	09 c2                	or     %eax,%edx
  800d4f:	89 f9                	mov    %edi,%ecx
  800d51:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800d54:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800d57:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d5a:	89 f2                	mov    %esi,%edx
  800d5c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800d5f:	d3 ea                	shr    %cl,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	d3 e6                	shl    %cl,%esi
  800d65:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800d68:	d3 e8                	shr    %cl,%eax
  800d6a:	09 c6                	or     %eax,%esi
  800d6c:	89 f9                	mov    %edi,%ecx
  800d6e:	89 f0                	mov    %esi,%eax
  800d70:	f7 75 ec             	divl   0xffffffec(%ebp)
  800d73:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800d76:	89 d6                	mov    %edx,%esi
  800d78:	89 c7                	mov    %eax,%edi
  800d7a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800d7d:	f7 e7                	mul    %edi
  800d7f:	39 f2                	cmp    %esi,%edx
  800d81:	77 15                	ja     800d98 <__udivdi3+0x138>
  800d83:	39 f2                	cmp    %esi,%edx
  800d85:	0f 94 c2             	sete   %dl
  800d88:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800d8b:	0f 97 c0             	seta   %al
  800d8e:	21 d0                	and    %edx,%eax
  800d90:	a8 01                	test   $0x1,%al
  800d92:	0f 84 07 ff ff ff    	je     800c9f <__udivdi3+0x3f>
  800d98:	4f                   	dec    %edi
  800d99:	e9 01 ff ff ff       	jmp    800c9f <__udivdi3+0x3f>
  800d9e:	90                   	nop    
  800d9f:	90                   	nop    

00800da0 <__umoddi3>:
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	83 ec 38             	sub    $0x38,%esp
  800da8:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800dab:	8b 55 14             	mov    0x14(%ebp),%edx
  800dae:	8b 75 08             	mov    0x8(%ebp),%esi
  800db1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db4:	8b 45 10             	mov    0x10(%ebp),%eax
  800db7:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800dbe:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800dc5:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800dc8:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800dcb:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800dce:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800dd1:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800dd4:	85 d2                	test   %edx,%edx
  800dd6:	75 48                	jne    800e20 <__umoddi3+0x80>
  800dd8:	39 f8                	cmp    %edi,%eax
  800dda:	0f 86 d0 00 00 00    	jbe    800eb0 <__umoddi3+0x110>
  800de0:	89 f0                	mov    %esi,%eax
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800de7:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800dea:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800ded:	85 f6                	test   %esi,%esi
  800def:	74 49                	je     800e3a <__umoddi3+0x9a>
  800df1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800df4:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800dfb:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800dfe:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800e01:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800e04:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800e07:	89 10                	mov    %edx,(%eax)
  800e09:	89 48 04             	mov    %ecx,0x4(%eax)
  800e0c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e0f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e12:	83 c4 38             	add    $0x38,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800e20:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e23:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800e26:	76 1f                	jbe    800e47 <__umoddi3+0xa7>
  800e28:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800e2b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e2e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e31:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e34:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800e37:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e3a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e3d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e40:	83 c4 38             	add    $0x38,%esp
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
  800e47:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800e4b:	83 f0 1f             	xor    $0x1f,%eax
  800e4e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800e51:	0f 85 89 00 00 00    	jne    800ee0 <__umoddi3+0x140>
  800e57:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800e5a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800e5d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800e60:	0f 97 c2             	seta   %dl
  800e63:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800e66:	0f 93 c0             	setae  %al
  800e69:	09 d0                	or     %edx,%eax
  800e6b:	a8 01                	test   $0x1,%al
  800e6d:	74 11                	je     800e80 <__umoddi3+0xe0>
  800e6f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e72:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e75:	29 c8                	sub    %ecx,%eax
  800e77:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800e7a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800e7d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e80:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e83:	85 c9                	test   %ecx,%ecx
  800e85:	74 b3                	je     800e3a <__umoddi3+0x9a>
  800e87:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800e8a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800e8d:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800e90:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800e93:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800e96:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800e99:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800e9c:	89 01                	mov    %eax,(%ecx)
  800e9e:	89 51 04             	mov    %edx,0x4(%ecx)
  800ea1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800ea4:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800ea7:	83 c4 38             	add    $0x38,%esp
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    
  800eae:	89 f6                	mov    %esi,%esi
  800eb0:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  800eb3:	85 ff                	test   %edi,%edi
  800eb5:	75 0d                	jne    800ec4 <__umoddi3+0x124>
  800eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebc:	31 d2                	xor    %edx,%edx
  800ebe:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ec1:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800ec4:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800ec7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800eca:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ecd:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800ed0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800ed3:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800ed6:	e9 0c ff ff ff       	jmp    800de7 <__umoddi3+0x47>
  800edb:	90                   	nop    
  800edc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800ee0:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  800ee3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee8:	29 d0                	sub    %edx,%eax
  800eea:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800eed:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  800ef0:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800ef3:	d3 e2                	shl    %cl,%edx
  800ef5:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  800ef8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800efb:	d3 e8                	shr    %cl,%eax
  800efd:	09 c2                	or     %eax,%edx
  800eff:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f02:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  800f05:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f08:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f0b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f0e:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  800f11:	d3 ea                	shr    %cl,%edx
  800f13:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f16:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f19:	d3 e6                	shl    %cl,%esi
  800f1b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f1e:	d3 e8                	shr    %cl,%eax
  800f20:	09 c6                	or     %eax,%esi
  800f22:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f25:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  800f28:	89 f0                	mov    %esi,%eax
  800f2a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800f2d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  800f30:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f33:	f7 65 c4             	mull   0xffffffc4(%ebp)
  800f36:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f39:	89 d6                	mov    %edx,%esi
  800f3b:	89 c7                	mov    %eax,%edi
  800f3d:	77 12                	ja     800f51 <__umoddi3+0x1b1>
  800f3f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  800f42:	0f 94 c2             	sete   %dl
  800f45:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  800f48:	0f 97 c0             	seta   %al
  800f4b:	21 d0                	and    %edx,%eax
  800f4d:	a8 01                	test   $0x1,%al
  800f4f:	74 06                	je     800f57 <__umoddi3+0x1b7>
  800f51:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  800f54:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  800f57:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	0f 84 d8 fe ff ff    	je     800e3a <__umoddi3+0x9a>
  800f62:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  800f65:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f68:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f6b:	29 f8                	sub    %edi,%eax
  800f6d:	19 f2                	sbb    %esi,%edx
  800f6f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800f72:	d3 e2                	shl    %cl,%edx
  800f74:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  800f77:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800f7a:	d3 e8                	shr    %cl,%eax
  800f7c:	09 c2                	or     %eax,%edx
  800f7e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  800f81:	d3 e8                	shr    %cl,%eax
  800f83:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  800f86:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800f89:	e9 70 fe ff ff       	jmp    800dfe <__umoddi3+0x5e>
  800f8e:	90                   	nop    
  800f8f:	90                   	nop    
