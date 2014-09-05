
obj/user/fos_input:     file format elf32-i386

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
  800031:	e8 66 00 00 00       	call   80009c <libmain>
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
  80003d:	81 ec 08 02 00 00    	sub    $0x208,%esp
	int i1=0;
	int i2=0;
	char buff1[256];
	char buff2[256];	
	
	readline("Please enter first number :", buff1);	
  800043:	8d 9d f8 fe ff ff    	lea    0xfffffef8(%ebp),%ebx
  800049:	53                   	push   %ebx
  80004a:	68 e0 10 80 00       	push   $0x8010e0
  80004f:	e8 d0 05 00 00       	call   800624 <readline>
	i1 = strtol(buff1, NULL, 10);
  800054:	83 c4 0c             	add    $0xc,%esp
  800057:	6a 0a                	push   $0xa
  800059:	6a 00                	push   $0x0
  80005b:	53                   	push   %ebx
  80005c:	e8 19 09 00 00       	call   80097a <strtol>
  800061:	89 c6                	mov    %eax,%esi
	readline("Please enter second number :", buff2);
  800063:	83 c4 08             	add    $0x8,%esp
  800066:	8d 9d f8 fd ff ff    	lea    0xfffffdf8(%ebp),%ebx
  80006c:	53                   	push   %ebx
  80006d:	68 fc 10 80 00       	push   $0x8010fc
  800072:	e8 ad 05 00 00       	call   800624 <readline>
	
	i2 = strtol(buff2, NULL, 10);
  800077:	83 c4 0c             	add    $0xc,%esp
  80007a:	6a 0a                	push   $0xa
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	e8 f6 08 00 00       	call   80097a <strtol>

	cprintf("number 1 + number 2 = %d\n",i1+i2);
  800084:	83 c4 08             	add    $0x8,%esp
  800087:	8d 04 30             	lea    (%eax,%esi,1),%eax
  80008a:	50                   	push   %eax
  80008b:	68 19 11 80 00       	push   $0x801119
  800090:	e8 e7 00 00 00       	call   80017c <cprintf>
	return;	
}
  800095:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 08             	sub    $0x8,%esp
  8000a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000a8:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000af:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	85 c9                	test   %ecx,%ecx
  8000b4:	7e 07                	jle    8000bd <libmain+0x21>
		binaryname = argv[0];
  8000b6:	8b 02                	mov    (%edx),%eax
  8000b8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	52                   	push   %edx
  8000c1:	51                   	push   %ecx
  8000c2:	e8 71 ff ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  8000c7:	e8 13 00 00 00       	call   8000df <sleep>
}
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
	...

008000d0 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 44 0b 00 00       	call   800c21 <sys_env_destroy>
}
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <sleep>:

void
sleep(void)
{	
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  8000e5:	e8 76 0b 00 00       	call   800c60 <sys_env_sleep>
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <putch>:


static void
putch(int ch, struct printbuf *b)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000ff:	40                   	inc    %eax
  800100:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800102:	3d ff 00 00 00       	cmp    $0xff,%eax
  800107:	75 1a                	jne    800123 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	68 ff 00 00 00       	push   $0xff
  800111:	8d 43 08             	lea    0x8(%ebx),%eax
  800114:	50                   	push   %eax
  800115:	e8 ca 0a 00 00       	call   800be4 <sys_cputs>
		b->idx = 0;
  80011a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800123:	ff 43 04             	incl   0x4(%ebx)
}
  800126:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800134:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  80013b:	00 00 00 
	b.cnt = 0;
  80013e:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  800145:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  800154:	50                   	push   %eax
  800155:	68 ec 00 80 00       	push   $0x8000ec
  80015a:	e8 2d 01 00 00       	call   80028c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	83 c4 08             	add    $0x8,%esp
  800162:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 70 0a 00 00       	call   800be4 <sys_cputs>

	return b.cnt;
  800174:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 9d ff ff ff       	call   80012b <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	8b 75 10             	mov    0x10(%ebp),%esi
  80019c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	39 d7                	cmp    %edx,%edi
  8001ac:	72 39                	jb     8001e7 <printnum+0x57>
  8001ae:	77 04                	ja     8001b4 <printnum+0x24>
  8001b0:	39 c6                	cmp    %eax,%esi
  8001b2:	72 33                	jb     8001e7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	83 ec 04             	sub    $0x4,%esp
  8001b7:	ff 75 20             	pushl  0x20(%ebp)
  8001ba:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c9:	52                   	push   %edx
  8001ca:	50                   	push   %eax
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	e8 ce 0b 00 00       	call   800da0 <__udivdi3>
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	52                   	push   %edx
  8001d6:	50                   	push   %eax
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 ae ff ff ff       	call   800190 <printnum>
  8001e2:	83 c4 20             	add    $0x20,%esp
  8001e5:	eb 19                	jmp    800200 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	4b                   	dec    %ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7e 14                	jle    800200 <printnum+0x70>
			putch(padc, putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 20             	pushl  0x20(%ebp)
  8001f5:	ff 55 08             	call   *0x8(%ebp)
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f ec                	jg     8001ec <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	8b 45 18             	mov    0x18(%ebp),%eax
  800209:	ba 00 00 00 00       	mov    $0x0,%edx
  80020e:	83 ec 04             	sub    $0x4,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	e8 c6 0c 00 00       	call   800ee0 <__umoddi3>
  80021a:	83 c4 14             	add    $0x14,%esp
  80021d:	0f be 80 b3 11 80 00 	movsbl 0x8011b3(%eax),%eax
  800224:	50                   	push   %eax
  800225:	ff 55 08             	call   *0x8(%ebp)
}
  800228:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800239:	83 f8 01             	cmp    $0x1,%eax
  80023c:	7e 0f                	jle    80024d <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 01                	mov    (%ecx),%eax
  800240:	83 c0 08             	add    $0x8,%eax
  800243:	89 01                	mov    %eax,(%ecx)
  800245:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800248:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  80024b:	eb 0f                	jmp    80025c <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80024d:	8b 01                	mov    (%ecx),%eax
  80024f:	83 c0 04             	add    $0x4,%eax
  800252:	89 01                	mov    %eax,(%ecx)
  800254:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800257:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800267:	83 f8 01             	cmp    $0x1,%eax
  80026a:	7e 0f                	jle    80027b <getint+0x1d>
		return va_arg(*ap, long long);
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	83 c0 08             	add    $0x8,%eax
  800271:	89 02                	mov    %eax,(%edx)
  800273:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800276:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800279:	eb 0f                	jmp    80028a <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	83 c0 04             	add    $0x4,%eax
  800280:	89 02                	mov    %eax,(%edx)
  800282:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800285:	89 c2                	mov    %eax,%edx
  800287:	c1 fa 1f             	sar    $0x1f,%edx
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 1c             	sub    $0x1c,%esp
  800295:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	8a 13                	mov    (%ebx),%dl
  80029f:	43                   	inc    %ebx
  8002a0:	83 fa 25             	cmp    $0x25,%edx
  8002a3:	74 22                	je     8002c7 <vprintfmt+0x3b>
			if (ch == '\0')
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	0f 84 cd 02 00 00    	je     80057a <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	ff 75 0c             	pushl  0xc(%ebp)
  8002b3:	52                   	push   %edx
  8002b4:	ff 55 08             	call   *0x8(%ebp)
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	8a 13                	mov    (%ebx),%dl
  8002c1:	43                   	inc    %ebx
  8002c2:	83 fa 25             	cmp    $0x25,%edx
  8002c5:	75 de                	jne    8002a5 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002c7:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  8002cb:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  8002d2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  8002dc:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	8a 13                	mov    (%ebx),%dl
  8002ea:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  8002ed:	43                   	inc    %ebx
  8002ee:	83 f8 55             	cmp    $0x55,%eax
  8002f1:	0f 87 5e 02 00 00    	ja     800555 <vprintfmt+0x2c9>
  8002f7:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fe:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  800302:	eb df                	jmp    8002e3 <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800304:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800308:	eb d9                	jmp    8002e3 <vprintfmt+0x57>

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
  80030a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80030f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800312:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  800316:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800319:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  80031c:	83 f8 09             	cmp    $0x9,%eax
  80031f:	77 27                	ja     800348 <vprintfmt+0xbc>
  800321:	43                   	inc    %ebx
  800322:	eb eb                	jmp    80030f <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800324:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800328:	8b 45 14             	mov    0x14(%ebp),%eax
  80032b:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  80032e:	eb 18                	jmp    800348 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  800330:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800334:	79 ad                	jns    8002e3 <vprintfmt+0x57>
				width = 0;
  800336:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  80033d:	eb a4                	jmp    8002e3 <vprintfmt+0x57>

		case '#':
			altflag = 1;
  80033f:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  800346:	eb 9b                	jmp    8002e3 <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  800348:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80034c:	79 95                	jns    8002e3 <vprintfmt+0x57>
				width = precision, precision = -1;
  80034e:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  800351:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800356:	eb 8b                	jmp    8002e3 <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800358:	41                   	inc    %ecx
			goto reswitch;
  800359:	eb 88                	jmp    8002e3 <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 0c             	pushl  0xc(%ebp)
  800361:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	ff 70 fc             	pushl  0xfffffffc(%eax)
  80036b:	e9 da 01 00 00       	jmp    80054a <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800370:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	79 02                	jns    800380 <vprintfmt+0xf4>
				err = -err;
  80037e:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800380:	83 f8 07             	cmp    $0x7,%eax
  800383:	7f 0b                	jg     800390 <vprintfmt+0x104>
  800385:	8b 3c 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edi
  80038c:	85 ff                	test   %edi,%edi
  80038e:	75 08                	jne    800398 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  800390:	50                   	push   %eax
  800391:	68 c4 11 80 00       	push   $0x8011c4
  800396:	eb 06                	jmp    80039e <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  800398:	57                   	push   %edi
  800399:	68 cd 11 80 00       	push   $0x8011cd
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 d9 01 00 00       	call   800582 <printfmt>
  8003a9:	e9 9f 01 00 00       	jmp    80054d <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ae:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  8003b8:	85 ff                	test   %edi,%edi
  8003ba:	75 05                	jne    8003c1 <vprintfmt+0x135>
				p = "(null)";
  8003bc:	bf d0 11 80 00       	mov    $0x8011d0,%edi
			if (width > 0 && padc != '-')
  8003c1:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003c5:	0f 9f c2             	setg   %dl
  8003c8:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  8003cc:	0f 95 c0             	setne  %al
  8003cf:	21 d0                	and    %edx,%eax
  8003d1:	a8 01                	test   $0x1,%al
  8003d3:	74 35                	je     80040a <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	56                   	push   %esi
  8003d9:	57                   	push   %edi
  8003da:	e8 42 03 00 00       	call   800721 <strnlen>
  8003df:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003e9:	7e 1f                	jle    80040a <vprintfmt+0x17e>
  8003eb:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8003ef:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  8003fb:	ff 55 08             	call   *0x8(%ebp)
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800404:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800408:	7f e8                	jg     8003f2 <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80040a:	0f be 17             	movsbl (%edi),%edx
  80040d:	47                   	inc    %edi
  80040e:	85 d2                	test   %edx,%edx
  800410:	74 3e                	je     800450 <vprintfmt+0x1c4>
  800412:	85 f6                	test   %esi,%esi
  800414:	78 03                	js     800419 <vprintfmt+0x18d>
  800416:	4e                   	dec    %esi
  800417:	78 37                	js     800450 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  800419:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  80041d:	74 12                	je     800431 <vprintfmt+0x1a5>
  80041f:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  800422:	83 f8 5e             	cmp    $0x5e,%eax
  800425:	76 0a                	jbe    800431 <vprintfmt+0x1a5>
					putch('?', putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	6a 3f                	push   $0x3f
  80042f:	eb 07                	jmp    800438 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 0c             	pushl  0xc(%ebp)
  800437:	52                   	push   %edx
  800438:	ff 55 08             	call   *0x8(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800441:	0f be 17             	movsbl (%edi),%edx
  800444:	47                   	inc    %edi
  800445:	85 d2                	test   %edx,%edx
  800447:	74 07                	je     800450 <vprintfmt+0x1c4>
  800449:	85 f6                	test   %esi,%esi
  80044b:	78 cc                	js     800419 <vprintfmt+0x18d>
  80044d:	4e                   	dec    %esi
  80044e:	79 c9                	jns    800419 <vprintfmt+0x18d>
			for (; width > 0; width--)
  800450:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800454:	0f 8e 3e fe ff ff    	jle    800298 <vprintfmt+0xc>
				putch(' ', putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	6a 20                	push   $0x20
  800462:	ff 55 08             	call   *0x8(%ebp)
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	ff 4d f0             	decl   0xfffffff0(%ebp)
  80046b:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  80046f:	7f e9                	jg     80045a <vprintfmt+0x1ce>
			break;
  800471:	e9 22 fe ff ff       	jmp    800298 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	51                   	push   %ecx
  80047a:	8d 45 14             	lea    0x14(%ebp),%eax
  80047d:	50                   	push   %eax
  80047e:	e8 db fd ff ff       	call   80025e <getint>
  800483:	89 c6                	mov    %eax,%esi
  800485:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 d2                	test   %edx,%edx
  80048c:	79 15                	jns    8004a3 <vprintfmt+0x217>
				putch('-', putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 0c             	pushl  0xc(%ebp)
  800494:	6a 2d                	push   $0x2d
  800496:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800499:	f7 de                	neg    %esi
  80049b:	83 d7 00             	adc    $0x0,%edi
  80049e:	f7 df                	neg    %edi
  8004a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004a3:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004a8:	eb 78                	jmp    800522 <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	51                   	push   %ecx
  8004ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8004b1:	50                   	push   %eax
  8004b2:	e8 79 fd ff ff       	call   800230 <getuint>
  8004b7:	89 c6                	mov    %eax,%esi
  8004b9:	89 d7                	mov    %edx,%edi
			base = 10;
  8004bb:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004c0:	eb 5d                	jmp    80051f <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 0c             	pushl  0xc(%ebp)
  8004c8:	6a 58                	push   $0x58
  8004ca:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004cd:	83 c4 08             	add    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	6a 58                	push   $0x58
  8004d5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8004d8:	83 c4 08             	add    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	6a 58                	push   $0x58
  8004e0:	eb 68                	jmp    80054a <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 30                	push   $0x30
  8004ea:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004ed:	83 c4 08             	add    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 78                	push   $0x78
  8004f5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004f8:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  800502:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  800507:	eb 11                	jmp    80051a <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	51                   	push   %ecx
  80050d:	8d 45 14             	lea    0x14(%ebp),%eax
  800510:	50                   	push   %eax
  800511:	e8 1a fd ff ff       	call   800230 <getuint>
  800516:	89 c6                	mov    %eax,%esi
  800518:	89 d7                	mov    %edx,%edi
			base = 16;
  80051a:	ba 10 00 00 00       	mov    $0x10,%edx
  80051f:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800522:	83 ec 04             	sub    $0x4,%esp
  800525:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  800529:	50                   	push   %eax
  80052a:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  80052d:	52                   	push   %edx
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	ff 75 08             	pushl  0x8(%ebp)
  800536:	e8 55 fc ff ff       	call   800190 <printnum>
			break;
  80053b:	83 c4 20             	add    $0x20,%esp
  80053e:	e9 55 fd ff ff       	jmp    800298 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	52                   	push   %edx
  80054a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	e9 43 fd ff ff       	jmp    800298 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 0c             	pushl  0xc(%ebp)
  80055b:	6a 25                	push   $0x25
  80055d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800560:	4b                   	dec    %ebx
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800568:	0f 84 2a fd ff ff    	je     800298 <vprintfmt+0xc>
  80056e:	4b                   	dec    %ebx
  80056f:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  800573:	75 f9                	jne    80056e <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800575:	e9 1e fd ff ff       	jmp    800298 <vprintfmt+0xc>
		}
	}
}
  80057a:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  80057d:	5b                   	pop    %ebx
  80057e:	5e                   	pop    %esi
  80057f:	5f                   	pop    %edi
  800580:	5d                   	pop    %ebp
  800581:	c3                   	ret    

00800582 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80058b:	50                   	push   %eax
  80058c:	ff 75 10             	pushl  0x10(%ebp)
  80058f:	ff 75 0c             	pushl  0xc(%ebp)
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 f2 fc ff ff       	call   80028c <vprintfmt>
	va_end(ap);
}
  80059a:	c9                   	leave  
  80059b:	c3                   	ret    

0080059c <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005a2:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005a5:	8b 0a                	mov    (%edx),%ecx
  8005a7:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005aa:	73 07                	jae    8005b3 <sprintputch+0x17>
		*b->buf++ = ch;
  8005ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8005af:	88 01                	mov    %al,(%ecx)
  8005b1:	ff 02                	incl   (%edx)
}
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    

008005b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 18             	sub    $0x18,%esp
  8005bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005c1:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  8005c4:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  8005c8:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  8005cb:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	0f 94 c2             	sete   %dl
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	0f 9e c0             	setle  %al
  8005dc:	09 d0                	or     %edx,%eax
  8005de:	ba 03 00 00 00       	mov    $0x3,%edx
  8005e3:	a8 01                	test   $0x1,%al
  8005e5:	75 1d                	jne    800604 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005e7:	ff 75 14             	pushl  0x14(%ebp)
  8005ea:	ff 75 10             	pushl  0x10(%ebp)
  8005ed:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  8005f0:	50                   	push   %eax
  8005f1:	68 9c 05 80 00       	push   $0x80059c
  8005f6:	e8 91 fc ff ff       	call   80028c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005fb:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  8005fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800601:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  800604:	89 d0                	mov    %edx,%eax
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800611:	50                   	push   %eax
  800612:	ff 75 10             	pushl  0x10(%ebp)
  800615:	ff 75 0c             	pushl  0xc(%ebp)
  800618:	ff 75 08             	pushl  0x8(%ebp)
  80061b:	e8 95 ff ff ff       	call   8005b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800620:	c9                   	leave  
  800621:	c3                   	ret    
	...

00800624 <readline>:
#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	57                   	push   %edi
  800628:	56                   	push   %esi
  800629:	53                   	push   %ebx
  80062a:	83 ec 0c             	sub    $0xc,%esp
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;
	
	if (prompt != NULL)
  800630:	85 c0                	test   %eax,%eax
  800632:	74 11                	je     800645 <readline+0x21>
		cprintf("%s", prompt);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	50                   	push   %eax
  800638:	68 cd 11 80 00       	push   $0x8011cd
  80063d:	e8 3a fb ff ff       	call   80017c <cprintf>
  800642:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
  800645:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);	
  80064a:	83 ec 0c             	sub    $0xc,%esp
  80064d:	6a 00                	push   $0x0
  80064f:	e8 36 07 00 00       	call   800d8a <iscons>
  800654:	89 c7                	mov    %eax,%edi
	while (1) {
  800656:	83 c4 10             	add    $0x10,%esp
		c = getchar();
  800659:	e8 1f 07 00 00       	call   800d7d <getchar>
  80065e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800660:	85 c0                	test   %eax,%eax
  800662:	79 1c                	jns    800680 <readline+0x5c>
			if (c != -E_EOF)
  800664:	83 f8 07             	cmp    $0x7,%eax
  800667:	0f 84 92 00 00 00    	je     8006ff <readline+0xdb>
				cprintf("read error: %e\n", c);			
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	50                   	push   %eax
  800671:	68 58 13 80 00       	push   $0x801358
  800676:	e8 01 fb ff ff       	call   80017c <cprintf>
  80067b:	83 c4 10             	add    $0x10,%esp
			return;
  80067e:	eb 7f                	jmp    8006ff <readline+0xdb>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800680:	83 f8 1f             	cmp    $0x1f,%eax
  800683:	0f 9f c2             	setg   %dl
  800686:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80068c:	0f 9e c0             	setle  %al
  80068f:	21 d0                	and    %edx,%eax
  800691:	a8 01                	test   $0x1,%al
  800693:	74 19                	je     8006ae <readline+0x8a>
			if (echoing)
  800695:	85 ff                	test   %edi,%edi
  800697:	74 0c                	je     8006a5 <readline+0x81>
				cputchar(c);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	53                   	push   %ebx
  80069d:	e8 c2 06 00 00       	call   800d64 <cputchar>
  8006a2:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a8:	88 1c 06             	mov    %bl,(%esi,%eax,1)
  8006ab:	46                   	inc    %esi
  8006ac:	eb ab                	jmp    800659 <readline+0x35>
		} else if (c == '\b' && i > 0) {
  8006ae:	83 fb 08             	cmp    $0x8,%ebx
  8006b1:	0f 94 c2             	sete   %dl
  8006b4:	85 f6                	test   %esi,%esi
  8006b6:	0f 9f c0             	setg   %al
  8006b9:	21 d0                	and    %edx,%eax
  8006bb:	a8 01                	test   $0x1,%al
  8006bd:	74 13                	je     8006d2 <readline+0xae>
			if (echoing)
  8006bf:	85 ff                	test   %edi,%edi
  8006c1:	74 0c                	je     8006cf <readline+0xab>
				cputchar(c);
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	e8 98 06 00 00       	call   800d64 <cputchar>
  8006cc:	83 c4 10             	add    $0x10,%esp
			i--;
  8006cf:	4e                   	dec    %esi
  8006d0:	eb 87                	jmp    800659 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
  8006d2:	83 fb 0a             	cmp    $0xa,%ebx
  8006d5:	0f 94 c2             	sete   %dl
  8006d8:	83 fb 0d             	cmp    $0xd,%ebx
  8006db:	0f 94 c0             	sete   %al
  8006de:	09 d0                	or     %edx,%eax
  8006e0:	a8 01                	test   $0x1,%al
  8006e2:	0f 84 71 ff ff ff    	je     800659 <readline+0x35>
			if (echoing)
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	74 0c                	je     8006f8 <readline+0xd4>
				cputchar(c);
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	e8 6f 06 00 00       	call   800d64 <cputchar>
  8006f5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fb:	c6 04 16 00          	movb   $0x0,(%esi,%edx,1)
			return;		
		}
	}
}
  8006ff:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    
	...

00800708 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	80 3a 00             	cmpb   $0x0,(%edx)
  800716:	74 07                	je     80071f <strlen+0x17>
		n++;
  800718:	40                   	inc    %eax
  800719:	42                   	inc    %edx
  80071a:	80 3a 00             	cmpb   $0x0,(%edx)
  80071d:	75 f9                	jne    800718 <strlen+0x10>
	return n;
}
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	85 d2                	test   %edx,%edx
  800731:	74 0f                	je     800742 <strnlen+0x21>
  800733:	80 39 00             	cmpb   $0x0,(%ecx)
  800736:	74 0a                	je     800742 <strnlen+0x21>
		n++;
  800738:	40                   	inc    %eax
  800739:	41                   	inc    %ecx
  80073a:	4a                   	dec    %edx
  80073b:	74 05                	je     800742 <strnlen+0x21>
  80073d:	80 39 00             	cmpb   $0x0,(%ecx)
  800740:	75 f6                	jne    800738 <strnlen+0x17>
	return n;
}
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80074e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800750:	8a 02                	mov    (%edx),%al
  800752:	88 01                	mov    %al,(%ecx)
  800754:	42                   	inc    %edx
  800755:	41                   	inc    %ecx
  800756:	84 c0                	test   %al,%al
  800758:	75 f6                	jne    800750 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	5b                   	pop    %ebx
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	57                   	push   %edi
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076b:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  80076e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800770:	bb 00 00 00 00       	mov    $0x0,%ebx
  800775:	39 f3                	cmp    %esi,%ebx
  800777:	73 17                	jae    800790 <strncpy+0x31>
		*dst++ = *src;
  800779:	8a 02                	mov    (%edx),%al
  80077b:	88 01                	mov    %al,(%ecx)
  80077d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80077e:	80 3a 00             	cmpb   $0x0,(%edx)
  800781:	0f 95 c0             	setne  %al
  800784:	25 ff 00 00 00       	and    $0xff,%eax
  800789:	01 c2                	add    %eax,%edx
  80078b:	43                   	inc    %ebx
  80078c:	39 f3                	cmp    %esi,%ebx
  80078e:	72 e9                	jb     800779 <strncpy+0x1a>
			src++;
	}
	return ret;
}
  800790:	89 f8                	mov    %edi,%eax
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5f                   	pop    %edi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a2:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007a5:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	74 19                	je     8007c4 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  8007ab:	4a                   	dec    %edx
  8007ac:	74 13                	je     8007c1 <strlcpy+0x2a>
  8007ae:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b1:	74 0e                	je     8007c1 <strlcpy+0x2a>
			*dst++ = *src++;
  8007b3:	8a 01                	mov    (%ecx),%al
  8007b5:	88 03                	mov    %al,(%ebx)
  8007b7:	41                   	inc    %ecx
  8007b8:	43                   	inc    %ebx
  8007b9:	4a                   	dec    %edx
  8007ba:	74 05                	je     8007c1 <strlcpy+0x2a>
  8007bc:	80 39 00             	cmpb   $0x0,(%ecx)
  8007bf:	75 f2                	jne    8007b3 <strlcpy+0x1c>
		*dst = '\0';
  8007c1:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	29 f0                	sub    %esi,%eax
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  8007d5:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d8:	74 13                	je     8007ed <strcmp+0x21>
  8007da:	8a 02                	mov    (%edx),%al
  8007dc:	3a 01                	cmp    (%ecx),%al
  8007de:	75 0d                	jne    8007ed <strcmp+0x21>
		p++, q++;
  8007e0:	42                   	inc    %edx
  8007e1:	41                   	inc    %ecx
  8007e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e5:	74 06                	je     8007ed <strcmp+0x21>
  8007e7:	8a 02                	mov    (%edx),%al
  8007e9:	3a 01                	cmp    (%ecx),%al
  8007eb:	74 f3                	je     8007e0 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	8a 02                	mov    (%edx),%al
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f9:	8a 11                	mov    (%ecx),%dl
  8007fb:	29 d0                	sub    %edx,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
  800806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800809:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	74 1f                	je     80082f <strncmp+0x30>
  800810:	80 3a 00             	cmpb   $0x0,(%edx)
  800813:	74 16                	je     80082b <strncmp+0x2c>
  800815:	8a 02                	mov    (%edx),%al
  800817:	3a 03                	cmp    (%ebx),%al
  800819:	75 10                	jne    80082b <strncmp+0x2c>
		n--, p++, q++;
  80081b:	42                   	inc    %edx
  80081c:	43                   	inc    %ebx
  80081d:	49                   	dec    %ecx
  80081e:	74 0f                	je     80082f <strncmp+0x30>
  800820:	80 3a 00             	cmpb   $0x0,(%edx)
  800823:	74 06                	je     80082b <strncmp+0x2c>
  800825:	8a 02                	mov    (%edx),%al
  800827:	3a 03                	cmp    (%ebx),%al
  800829:	74 f0                	je     80081b <strncmp+0x1c>
	if (n == 0)
  80082b:	85 c9                	test   %ecx,%ecx
  80082d:	75 07                	jne    800836 <strncmp+0x37>
		return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
  800834:	eb 13                	jmp    800849 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	8a 12                	mov    (%edx),%dl
  800838:	81 e2 ff 00 00 00    	and    $0xff,%edx
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	8a 03                	mov    (%ebx),%al
  800845:	29 c2                	sub    %eax,%edx
  800847:	89 d0                	mov    %edx,%eax
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 55 08             	mov    0x8(%ebp),%edx
  800852:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800855:	80 3a 00             	cmpb   $0x0,(%edx)
  800858:	74 0c                	je     800866 <strchr+0x1a>
		if (*s == c)
  80085a:	89 d0                	mov    %edx,%eax
  80085c:	38 0a                	cmp    %cl,(%edx)
  80085e:	74 0b                	je     80086b <strchr+0x1f>
  800860:	42                   	inc    %edx
  800861:	80 3a 00             	cmpb   $0x0,(%edx)
  800864:	75 f4                	jne    80085a <strchr+0xe>
			return (char *) s;
	return 0;
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800876:	80 38 00             	cmpb   $0x0,(%eax)
  800879:	74 0a                	je     800885 <strfind+0x18>
		if (*s == c)
  80087b:	38 10                	cmp    %dl,(%eax)
  80087d:	74 06                	je     800885 <strfind+0x18>
  80087f:	40                   	inc    %eax
  800880:	80 38 00             	cmpb   $0x0,(%eax)
  800883:	75 f6                	jne    80087b <strfind+0xe>
			break;
	return (char *) s;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  800891:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  800893:	8b 55 10             	mov    0x10(%ebp),%edx
  800896:	4a                   	dec    %edx
  800897:	78 06                	js     80089f <memset+0x18>
		*p++ = c;
  800899:	88 01                	mov    %al,(%ecx)
  80089b:	41                   	inc    %ecx
  80089c:	4a                   	dec    %edx
  80089d:	79 fa                	jns    800899 <memset+0x12>

	return v;
}
  80089f:	89 d8                	mov    %ebx,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8008af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  8008b2:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  8008b4:	89 c8                	mov    %ecx,%eax
  8008b6:	49                   	dec    %ecx
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	74 0d                	je     8008c8 <memcpy+0x24>
		*d++ = *s++;
  8008bb:	8a 03                	mov    (%ebx),%al
  8008bd:	88 02                	mov    %al,(%edx)
  8008bf:	43                   	inc    %ebx
  8008c0:	42                   	inc    %edx
  8008c1:	89 c8                	mov    %ecx,%eax
  8008c3:	49                   	dec    %ecx
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	75 f3                	jne    8008bb <memcpy+0x17>

	return dst;
}
  8008c8:	89 f0                	mov    %esi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d6:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  8008dc:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  8008de:	39 f1                	cmp    %esi,%ecx
  8008e0:	73 22                	jae    800904 <memmove+0x36>
  8008e2:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  8008e5:	39 f0                	cmp    %esi,%eax
  8008e7:	76 1b                	jbe    800904 <memmove+0x36>
		s += n;
  8008e9:	89 c1                	mov    %eax,%ecx
		d += n;
  8008eb:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	4a                   	dec    %edx
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	74 23                	je     800918 <memmove+0x4a>
			*--d = *--s;
  8008f5:	4b                   	dec    %ebx
  8008f6:	49                   	dec    %ecx
  8008f7:	8a 01                	mov    (%ecx),%al
  8008f9:	88 03                	mov    %al,(%ebx)
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	4a                   	dec    %edx
  8008fe:	85 c0                	test   %eax,%eax
  800900:	75 f3                	jne    8008f5 <memmove+0x27>
  800902:	eb 14                	jmp    800918 <memmove+0x4a>
	} else
		while (n-- > 0)
  800904:	89 d0                	mov    %edx,%eax
  800906:	4a                   	dec    %edx
  800907:	85 c0                	test   %eax,%eax
  800909:	74 0d                	je     800918 <memmove+0x4a>
			*d++ = *s++;
  80090b:	8a 01                	mov    (%ecx),%al
  80090d:	88 03                	mov    %al,(%ebx)
  80090f:	41                   	inc    %ecx
  800910:	43                   	inc    %ebx
  800911:	89 d0                	mov    %edx,%eax
  800913:	4a                   	dec    %edx
  800914:	85 c0                	test   %eax,%eax
  800916:	75 f3                	jne    80090b <memmove+0x3d>

	return dst;
}
  800918:	89 f0                	mov    %esi,%eax
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  800928:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	4a                   	dec    %edx
  80092e:	85 c0                	test   %eax,%eax
  800930:	74 23                	je     800955 <memcmp+0x37>
		if (*s1 != *s2)
  800932:	8a 01                	mov    (%ecx),%al
  800934:	3a 03                	cmp    (%ebx),%al
  800936:	74 14                	je     80094c <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	8a 11                	mov    (%ecx),%dl
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	8a 03                	mov    (%ebx),%al
  800946:	29 c2                	sub    %eax,%edx
  800948:	89 d0                	mov    %edx,%eax
  80094a:	eb 0e                	jmp    80095a <memcmp+0x3c>
		s1++, s2++;
  80094c:	41                   	inc    %ecx
  80094d:	43                   	inc    %ebx
  80094e:	89 d0                	mov    %edx,%eax
  800950:	4a                   	dec    %edx
  800951:	85 c0                	test   %eax,%eax
  800953:	75 dd                	jne    800932 <memcmp+0x14>
	}

	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800966:	89 c2                	mov    %eax,%edx
  800968:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096b:	39 d0                	cmp    %edx,%eax
  80096d:	73 09                	jae    800978 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096f:	38 08                	cmp    %cl,(%eax)
  800971:	74 05                	je     800978 <memfind+0x1b>
  800973:	40                   	inc    %eax
  800974:	39 d0                	cmp    %edx,%eax
  800976:	72 f7                	jb     80096f <memfind+0x12>
			break;
	return (void *) s;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	83 ec 04             	sub    $0x4,%esp
  800983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800986:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  80098c:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  800993:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800998:	80 39 20             	cmpb   $0x20,(%ecx)
  80099b:	0f 94 c2             	sete   %dl
  80099e:	80 39 09             	cmpb   $0x9,(%ecx)
  8009a1:	0f 94 c0             	sete   %al
  8009a4:	09 d0                	or     %edx,%eax
  8009a6:	a8 01                	test   $0x1,%al
  8009a8:	74 13                	je     8009bd <strtol+0x43>
		s++;
  8009aa:	41                   	inc    %ecx
  8009ab:	80 39 20             	cmpb   $0x20,(%ecx)
  8009ae:	0f 94 c2             	sete   %dl
  8009b1:	80 39 09             	cmpb   $0x9,(%ecx)
  8009b4:	0f 94 c0             	sete   %al
  8009b7:	09 d0                	or     %edx,%eax
  8009b9:	a8 01                	test   $0x1,%al
  8009bb:	75 ed                	jne    8009aa <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  8009bd:	80 39 2b             	cmpb   $0x2b,(%ecx)
  8009c0:	75 03                	jne    8009c5 <strtol+0x4b>
		s++;
  8009c2:	41                   	inc    %ecx
  8009c3:	eb 0d                	jmp    8009d2 <strtol+0x58>
	else if (*s == '-')
  8009c5:	80 39 2d             	cmpb   $0x2d,(%ecx)
  8009c8:	75 08                	jne    8009d2 <strtol+0x58>
		s++, neg = 1;
  8009ca:	41                   	inc    %ecx
  8009cb:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d2:	85 db                	test   %ebx,%ebx
  8009d4:	0f 94 c2             	sete   %dl
  8009d7:	83 fb 10             	cmp    $0x10,%ebx
  8009da:	0f 94 c0             	sete   %al
  8009dd:	09 d0                	or     %edx,%eax
  8009df:	a8 01                	test   $0x1,%al
  8009e1:	74 15                	je     8009f8 <strtol+0x7e>
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 10                	jne    8009f8 <strtol+0x7e>
  8009e8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ec:	75 0a                	jne    8009f8 <strtol+0x7e>
		s += 2, base = 16;
  8009ee:	83 c1 02             	add    $0x2,%ecx
  8009f1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f6:	eb 1a                	jmp    800a12 <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	75 16                	jne    800a12 <strtol+0x98>
  8009fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ff:	75 08                	jne    800a09 <strtol+0x8f>
		s++, base = 8;
  800a01:	41                   	inc    %ecx
  800a02:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a07:	eb 09                	jmp    800a12 <strtol+0x98>
	else if (base == 0)
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	75 05                	jne    800a12 <strtol+0x98>
		base = 10;
  800a0d:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a12:	8a 01                	mov    (%ecx),%al
  800a14:	83 e8 30             	sub    $0x30,%eax
  800a17:	3c 09                	cmp    $0x9,%al
  800a19:	77 08                	ja     800a23 <strtol+0xa9>
			dig = *s - '0';
  800a1b:	0f be 01             	movsbl (%ecx),%eax
  800a1e:	83 e8 30             	sub    $0x30,%eax
  800a21:	eb 20                	jmp    800a43 <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800a23:	8a 01                	mov    (%ecx),%al
  800a25:	83 e8 61             	sub    $0x61,%eax
  800a28:	3c 19                	cmp    $0x19,%al
  800a2a:	77 08                	ja     800a34 <strtol+0xba>
			dig = *s - 'a' + 10;
  800a2c:	0f be 01             	movsbl (%ecx),%eax
  800a2f:	83 e8 57             	sub    $0x57,%eax
  800a32:	eb 0f                	jmp    800a43 <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	8a 01                	mov    (%ecx),%al
  800a36:	83 e8 41             	sub    $0x41,%eax
  800a39:	3c 19                	cmp    $0x19,%al
  800a3b:	77 12                	ja     800a4f <strtol+0xd5>
			dig = *s - 'A' + 10;
  800a3d:	0f be 01             	movsbl (%ecx),%eax
  800a40:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a43:	39 d8                	cmp    %ebx,%eax
  800a45:	7d 08                	jge    800a4f <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  800a47:	41                   	inc    %ecx
  800a48:	0f af f3             	imul   %ebx,%esi
  800a4b:	01 c6                	add    %eax,%esi
  800a4d:	eb c3                	jmp    800a12 <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	74 02                	je     800a55 <strtol+0xdb>
		*endptr = (char *) s;
  800a53:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800a55:	89 f0                	mov    %esi,%eax
  800a57:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a5b:	74 02                	je     800a5f <strtol+0xe5>
  800a5d:	f7 d8                	neg    %eax
}
  800a5f:	83 c4 04             	add    $0x4,%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 04             	sub    $0x4,%esp
  800a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a73:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800a79:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800a80:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a85:	80 39 20             	cmpb   $0x20,(%ecx)
  800a88:	0f 94 c2             	sete   %dl
  800a8b:	80 39 09             	cmpb   $0x9,(%ecx)
  800a8e:	0f 94 c0             	sete   %al
  800a91:	09 d0                	or     %edx,%eax
  800a93:	a8 01                	test   $0x1,%al
  800a95:	74 13                	je     800aaa <strtoul+0x43>
		s++;
  800a97:	41                   	inc    %ecx
  800a98:	80 39 20             	cmpb   $0x20,(%ecx)
  800a9b:	0f 94 c2             	sete   %dl
  800a9e:	80 39 09             	cmpb   $0x9,(%ecx)
  800aa1:	0f 94 c0             	sete   %al
  800aa4:	09 d0                	or     %edx,%eax
  800aa6:	a8 01                	test   $0x1,%al
  800aa8:	75 ed                	jne    800a97 <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  800aaa:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800aad:	75 03                	jne    800ab2 <strtoul+0x4b>
		s++;
  800aaf:	41                   	inc    %ecx
  800ab0:	eb 0d                	jmp    800abf <strtoul+0x58>
	else if (*s == '-')
  800ab2:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800ab5:	75 08                	jne    800abf <strtoul+0x58>
		s++, neg = 1;
  800ab7:	41                   	inc    %ecx
  800ab8:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	0f 94 c2             	sete   %dl
  800ac4:	83 fb 10             	cmp    $0x10,%ebx
  800ac7:	0f 94 c0             	sete   %al
  800aca:	09 d0                	or     %edx,%eax
  800acc:	a8 01                	test   $0x1,%al
  800ace:	74 15                	je     800ae5 <strtoul+0x7e>
  800ad0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad3:	75 10                	jne    800ae5 <strtoul+0x7e>
  800ad5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad9:	75 0a                	jne    800ae5 <strtoul+0x7e>
		s += 2, base = 16;
  800adb:	83 c1 02             	add    $0x2,%ecx
  800ade:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae3:	eb 1a                	jmp    800aff <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  800ae5:	85 db                	test   %ebx,%ebx
  800ae7:	75 16                	jne    800aff <strtoul+0x98>
  800ae9:	80 39 30             	cmpb   $0x30,(%ecx)
  800aec:	75 08                	jne    800af6 <strtoul+0x8f>
		s++, base = 8;
  800aee:	41                   	inc    %ecx
  800aef:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af4:	eb 09                	jmp    800aff <strtoul+0x98>
	else if (base == 0)
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	75 05                	jne    800aff <strtoul+0x98>
		base = 10;
  800afa:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aff:	8a 01                	mov    (%ecx),%al
  800b01:	83 e8 30             	sub    $0x30,%eax
  800b04:	3c 09                	cmp    $0x9,%al
  800b06:	77 08                	ja     800b10 <strtoul+0xa9>
			dig = *s - '0';
  800b08:	0f be 01             	movsbl (%ecx),%eax
  800b0b:	83 e8 30             	sub    $0x30,%eax
  800b0e:	eb 20                	jmp    800b30 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800b10:	8a 01                	mov    (%ecx),%al
  800b12:	83 e8 61             	sub    $0x61,%eax
  800b15:	3c 19                	cmp    $0x19,%al
  800b17:	77 08                	ja     800b21 <strtoul+0xba>
			dig = *s - 'a' + 10;
  800b19:	0f be 01             	movsbl (%ecx),%eax
  800b1c:	83 e8 57             	sub    $0x57,%eax
  800b1f:	eb 0f                	jmp    800b30 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800b21:	8a 01                	mov    (%ecx),%al
  800b23:	83 e8 41             	sub    $0x41,%eax
  800b26:	3c 19                	cmp    $0x19,%al
  800b28:	77 12                	ja     800b3c <strtoul+0xd5>
			dig = *s - 'A' + 10;
  800b2a:	0f be 01             	movsbl (%ecx),%eax
  800b2d:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800b30:	39 d8                	cmp    %ebx,%eax
  800b32:	7d 08                	jge    800b3c <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800b34:	41                   	inc    %ecx
  800b35:	0f af f3             	imul   %ebx,%esi
  800b38:	01 c6                	add    %eax,%esi
  800b3a:	eb c3                	jmp    800aff <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	74 02                	je     800b42 <strtoul+0xdb>
		*endptr = (char *) s;
  800b40:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800b42:	89 f0                	mov    %esi,%eax
  800b44:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800b48:	74 02                	je     800b4c <strtoul+0xe5>
  800b4a:	f7 d8                	neg    %eax
}
  800b4c:	83 c4 04             	add    $0x4,%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800b66:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800b75:	eb 04                	jmp    800b7b <strsplit+0x27>
			*string++ = 0;
  800b77:	c6 03 00             	movb   $0x0,(%ebx)
  800b7a:	43                   	inc    %ebx
  800b7b:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b7e:	74 4b                	je     800bcb <strsplit+0x77>
  800b80:	83 ec 08             	sub    $0x8,%esp
  800b83:	0f be 03             	movsbl (%ebx),%eax
  800b86:	50                   	push   %eax
  800b87:	56                   	push   %esi
  800b88:	e8 bf fc ff ff       	call   80084c <strchr>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	85 c0                	test   %eax,%eax
  800b92:	75 e3                	jne    800b77 <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800b94:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b97:	74 32                	je     800bcb <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	83 3f 0f             	cmpl   $0xf,(%edi)
  800ba1:	74 39                	je     800bdc <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800ba3:	8b 07                	mov    (%edi),%eax
  800ba5:	8b 55 10             	mov    0x10(%ebp),%edx
  800ba8:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800bab:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800bad:	eb 01                	jmp    800bb0 <strsplit+0x5c>
			string++;
  800baf:	43                   	inc    %ebx
  800bb0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bb3:	74 16                	je     800bcb <strsplit+0x77>
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	0f be 03             	movsbl (%ebx),%eax
  800bbb:	50                   	push   %eax
  800bbc:	56                   	push   %esi
  800bbd:	e8 8a fc ff ff       	call   80084c <strchr>
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	74 e6                	je     800baf <strsplit+0x5b>
  800bc9:	eb b0                	jmp    800b7b <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800bcb:	8b 07                	mov    (%edi),%eax
  800bcd:	8b 55 10             	mov    0x10(%ebp),%edx
  800bd0:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800bd7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800bdc:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	89 fb                	mov    %edi,%ebx
  800bf9:	89 fe                	mov    %edi,%esi
  800bfb:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c12:	89 fa                	mov    %edi,%edx
  800c14:	89 f9                	mov    %edi,%ecx
  800c16:	89 fb                	mov    %edi,%ebx
  800c18:	89 fe                	mov    %edi,%esi
  800c1a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	89 f9                	mov    %edi,%ecx
  800c36:	89 fb                	mov    %edi,%ebx
  800c38:	89 fe                	mov    %edi,%esi
  800c3a:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	89 fa                	mov    %edi,%edx
  800c53:	89 f9                	mov    %edi,%ecx
  800c55:	89 fb                	mov    %edi,%ebx
  800c57:	89 fe                	mov    %edi,%esi
  800c59:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	89 fa                	mov    %edi,%edx
  800c72:	89 f9                	mov    %edi,%ecx
  800c74:	89 fb                	mov    %edi,%ebx
  800c76:	89 fe                	mov    %edi,%esi
  800c78:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c90:	bf 00 00 00 00       	mov    $0x0,%edi
  800c95:	89 fb                	mov    %edi,%ebx
  800c97:	89 fe                	mov    %edi,%esi
  800c99:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb6:	89 fb                	mov    %edi,%ebx
  800cb8:	89 fe                	mov    %edi,%esi
  800cba:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd6:	b8 07 00 00 00       	mov    $0x7,%eax
  800cdb:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf8:	89 fb                	mov    %edi,%ebx
  800cfa:	89 fe                	mov    %edi,%esi
  800cfc:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d14:	bf 00 00 00 00       	mov    $0x0,%edi
  800d19:	89 fb                	mov    %edi,%ebx
  800d1b:	89 fe                	mov    %edi,%esi
  800d1d:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d34:	89 fa                	mov    %edi,%edx
  800d36:	89 f9                	mov    %edi,%ecx
  800d38:	89 fb                	mov    %edi,%ebx
  800d3a:	89 fe                	mov    %edi,%esi
  800d3c:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d54:	bf 00 00 00 00       	mov    $0x0,%edi
  800d59:	89 fb                	mov    %edi,%ebx
  800d5b:	89 fe                	mov    %edi,%esi
  800d5d:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <cputchar>:
#include <inc/lib.h>

void
cputchar(int ch)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 10             	sub    $0x10,%esp
	char c = ch;
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	88 45 ff             	mov    %al,0xffffffff(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800d70:	6a 01                	push   $0x1
  800d72:	8d 45 ff             	lea    0xffffffff(%ebp),%eax
  800d75:	50                   	push   %eax
  800d76:	e8 69 fe ff ff       	call   800be4 <sys_cputs>
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <getchar>:

int
getchar(void)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 08             	sub    $0x8,%esp
	return sys_cgetc();
  800d83:	e8 7a fe ff ff       	call   800c02 <sys_cgetc>
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <iscons>:


int iscons(int fdnum)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
  800d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
	...

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	83 ec 20             	sub    $0x20,%esp
  800da8:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
  800daf:	8b 75 08             	mov    0x8(%ebp),%esi
  800db2:	8b 55 14             	mov    0x14(%ebp),%edx
  800db5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbb:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
  800dbe:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
  800dc5:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800dc8:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800dcb:	89 fe                	mov    %edi,%esi
  800dcd:	85 d2                	test   %edx,%edx
  800dcf:	75 2f                	jne    800e00 <__udivdi3+0x60>
  800dd1:	39 f8                	cmp    %edi,%eax
  800dd3:	76 62                	jbe    800e37 <__udivdi3+0x97>
  800dd5:	89 fa                	mov    %edi,%edx
  800dd7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800dda:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800ddd:	89 c7                	mov    %eax,%edi
  800ddf:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800de6:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800de9:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800dec:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800def:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800df2:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800df5:	83 c4 20             	add    $0x20,%esp
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    
  800dfc:	8d 74 26 00          	lea    0x0(%esi),%esi
  800e00:	31 ff                	xor    %edi,%edi
  800e02:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
  800e09:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
  800e0c:	77 d8                	ja     800de6 <__udivdi3+0x46>
  800e0e:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
  800e12:	89 c7                	mov    %eax,%edi
  800e14:	83 f7 1f             	xor    $0x1f,%edi
  800e17:	75 5b                	jne    800e74 <__udivdi3+0xd4>
  800e19:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
  800e1c:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
  800e1f:	0f 97 c2             	seta   %dl
  800e22:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
  800e25:	bf 01 00 00 00       	mov    $0x1,%edi
  800e2a:	0f 93 c0             	setae  %al
  800e2d:	09 d0                	or     %edx,%eax
  800e2f:	a8 01                	test   $0x1,%al
  800e31:	75 ac                	jne    800ddf <__udivdi3+0x3f>
  800e33:	31 ff                	xor    %edi,%edi
  800e35:	eb a8                	jmp    800ddf <__udivdi3+0x3f>
  800e37:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	75 0e                	jne    800e4c <__udivdi3+0xac>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 c9                	xor    %ecx,%ecx
  800e45:	31 d2                	xor    %edx,%edx
  800e47:	f7 f1                	div    %ecx
  800e49:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e53:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800e56:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e59:	f7 75 dc             	divl   0xffffffdc(%ebp)
  800e5c:	89 c7                	mov    %eax,%edi
  800e5e:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
  800e61:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
  800e64:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800e67:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800e6a:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800e6d:	83 c4 20             	add    $0x20,%esp
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
  800e74:	b8 20 00 00 00       	mov    $0x20,%eax
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	29 f8                	sub    %edi,%eax
  800e7d:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
  800e80:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  800e83:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800e86:	d3 e2                	shl    %cl,%edx
  800e88:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e8b:	d3 e8                	shr    %cl,%eax
  800e8d:	09 c2                	or     %eax,%edx
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
  800e94:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
  800e97:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800e9a:	89 f2                	mov    %esi,%edx
  800e9c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  800e9f:	d3 ea                	shr    %cl,%edx
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e6                	shl    %cl,%esi
  800ea5:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
  800ea8:	d3 e8                	shr    %cl,%eax
  800eaa:	09 c6                	or     %eax,%esi
  800eac:	89 f9                	mov    %edi,%ecx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	f7 75 ec             	divl   0xffffffec(%ebp)
  800eb3:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
  800eb6:	89 d6                	mov    %edx,%esi
  800eb8:	89 c7                	mov    %eax,%edi
  800eba:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
  800ebd:	f7 e7                	mul    %edi
  800ebf:	39 f2                	cmp    %esi,%edx
  800ec1:	77 15                	ja     800ed8 <__udivdi3+0x138>
  800ec3:	39 f2                	cmp    %esi,%edx
  800ec5:	0f 94 c2             	sete   %dl
  800ec8:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
  800ecb:	0f 97 c0             	seta   %al
  800ece:	21 d0                	and    %edx,%eax
  800ed0:	a8 01                	test   $0x1,%al
  800ed2:	0f 84 07 ff ff ff    	je     800ddf <__udivdi3+0x3f>
  800ed8:	4f                   	dec    %edi
  800ed9:	e9 01 ff ff ff       	jmp    800ddf <__udivdi3+0x3f>
  800ede:	90                   	nop    
  800edf:	90                   	nop    

00800ee0 <__umoddi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	83 ec 38             	sub    $0x38,%esp
  800ee8:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
  800eeb:	8b 55 14             	mov    0x14(%ebp),%edx
  800eee:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ef4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef7:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
  800efe:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f05:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
  800f08:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  800f0b:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  800f0e:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
  800f11:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
  800f14:	85 d2                	test   %edx,%edx
  800f16:	75 48                	jne    800f60 <__umoddi3+0x80>
  800f18:	39 f8                	cmp    %edi,%eax
  800f1a:	0f 86 d0 00 00 00    	jbe    800ff0 <__umoddi3+0x110>
  800f20:	89 f0                	mov    %esi,%eax
  800f22:	89 fa                	mov    %edi,%edx
  800f24:	f7 75 c4             	divl   0xffffffc4(%ebp)
  800f27:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
  800f2a:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
  800f2d:	85 f6                	test   %esi,%esi
  800f2f:	74 49                	je     800f7a <__umoddi3+0x9a>
  800f31:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800f34:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
  800f3b:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800f3e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  800f41:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
  800f44:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
  800f47:	89 10                	mov    %edx,(%eax)
  800f49:	89 48 04             	mov    %ecx,0x4(%eax)
  800f4c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f4f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f52:	83 c4 38             	add    $0x38,%esp
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
  800f60:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800f63:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
  800f66:	76 1f                	jbe    800f87 <__umoddi3+0xa7>
  800f68:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
  800f6b:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800f6e:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800f71:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800f74:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
  800f77:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
  800f7a:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800f7d:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800f80:	83 c4 38             	add    $0x38,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
  800f8b:	83 f0 1f             	xor    $0x1f,%eax
  800f8e:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
  800f91:	0f 85 89 00 00 00    	jne    801020 <__umoddi3+0x140>
  800f97:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  800f9a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
  800f9d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
  800fa0:	0f 97 c2             	seta   %dl
  800fa3:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
  800fa6:	0f 93 c0             	setae  %al
  800fa9:	09 d0                	or     %edx,%eax
  800fab:	a8 01                	test   $0x1,%al
  800fad:	74 11                	je     800fc0 <__umoddi3+0xe0>
  800faf:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fb2:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fb5:	29 c8                	sub    %ecx,%eax
  800fb7:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
  800fba:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  800fbd:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  800fc0:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fc3:	85 c9                	test   %ecx,%ecx
  800fc5:	74 b3                	je     800f7a <__umoddi3+0x9a>
  800fc7:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  800fca:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  800fcd:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
  800fd0:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
  800fd3:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
  800fd6:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
  800fd9:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
  800fdc:	89 01                	mov    %eax,(%ecx)
  800fde:	89 51 04             	mov    %edx,0x4(%ecx)
  800fe1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800fe4:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
  800fe7:	83 c4 38             	add    $0x38,%esp
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    
  800fee:	89 f6                	mov    %esi,%esi
  800ff0:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
  800ff3:	85 ff                	test   %edi,%edi
  800ff5:	75 0d                	jne    801004 <__umoddi3+0x124>
  800ff7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	f7 75 c4             	divl   0xffffffc4(%ebp)
  801001:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
  801004:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  801007:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  80100a:	f7 75 c4             	divl   0xffffffc4(%ebp)
  80100d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801010:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801013:	f7 75 c4             	divl   0xffffffc4(%ebp)
  801016:	e9 0c ff ff ff       	jmp    800f27 <__umoddi3+0x47>
  80101b:	90                   	nop    
  80101c:	8d 74 26 00          	lea    0x0(%esi),%esi
  801020:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
  801023:	b8 20 00 00 00       	mov    $0x20,%eax
  801028:	29 d0                	sub    %edx,%eax
  80102a:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  80102d:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
  801030:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
  801033:	d3 e2                	shl    %cl,%edx
  801035:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
  801038:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	09 c2                	or     %eax,%edx
  80103f:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801042:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
  801045:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
  801048:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80104b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  80104e:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
  801051:	d3 ea                	shr    %cl,%edx
  801053:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801056:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  801059:	d3 e6                	shl    %cl,%esi
  80105b:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  80105e:	d3 e8                	shr    %cl,%eax
  801060:	09 c6                	or     %eax,%esi
  801062:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  801065:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
  801068:	89 f0                	mov    %esi,%eax
  80106a:	f7 75 dc             	divl   0xffffffdc(%ebp)
  80106d:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
  801070:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  801073:	f7 65 c4             	mull   0xffffffc4(%ebp)
  801076:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801079:	89 d6                	mov    %edx,%esi
  80107b:	89 c7                	mov    %eax,%edi
  80107d:	77 12                	ja     801091 <__umoddi3+0x1b1>
  80107f:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
  801082:	0f 94 c2             	sete   %dl
  801085:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
  801088:	0f 97 c0             	seta   %al
  80108b:	21 d0                	and    %edx,%eax
  80108d:	a8 01                	test   $0x1,%al
  80108f:	74 06                	je     801097 <__umoddi3+0x1b7>
  801091:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
  801094:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
  801097:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
  80109a:	85 c0                	test   %eax,%eax
  80109c:	0f 84 d8 fe ff ff    	je     800f7a <__umoddi3+0x9a>
  8010a2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
  8010a5:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
  8010a8:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
  8010ab:	29 f8                	sub    %edi,%eax
  8010ad:	19 f2                	sbb    %esi,%edx
  8010af:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
  8010b2:	d3 e2                	shl    %cl,%edx
  8010b4:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
  8010b7:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
  8010ba:	d3 e8                	shr    %cl,%eax
  8010bc:	09 c2                	or     %eax,%edx
  8010be:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
  8010c1:	d3 e8                	shr    %cl,%eax
  8010c3:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
  8010c6:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
  8010c9:	e9 70 fe ff ff       	jmp    800f3e <__umoddi3+0x5e>
  8010ce:	90                   	nop    
  8010cf:	90                   	nop    
