
obj/user/fos_alloc:     file format elf32-i386

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
  800031:	e8 f2 00 00 00       	call   800128 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	57                   	push   %edi
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	83 ec 18             	sub    $0x18,%esp
	int size = 10 ;
	int *x = malloc(sizeof(int)*size) ;
  800041:	6a 28                	push   $0x28
  800043:	e8 44 0b 00 00       	call   800b8c <malloc>
  800048:	89 c6                	mov    %eax,%esi
	int *y = malloc(sizeof(int)*size) ;
  80004a:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
  800051:	e8 36 0b 00 00       	call   800b8c <malloc>
  800056:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int *z = malloc(sizeof(int)*size) ;
  800059:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
  800060:	e8 27 0b 00 00       	call   800b8c <malloc>
  800065:	89 c7                	mov    %eax,%edi

	int i ;
	for (i = 0 ; i < size ; i++)
  800067:	bb 00 00 00 00       	mov    $0x0,%ebx
  80006c:	83 c4 10             	add    $0x10,%esp
	{
		x[i] = i ;
  80006f:	89 1c 9e             	mov    %ebx,(%esi,%ebx,4)
		y[i] = 10 ;
  800072:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800075:	c7 04 98 0a 00 00 00 	movl   $0xa,(%eax,%ebx,4)
		z[i] = (int)x[i]  * y[i]  ;
  80007c:	6b 04 9e 0a          	imul   $0xa,(%esi,%ebx,4),%eax
  800080:	89 04 9f             	mov    %eax,(%edi,%ebx,4)
  800083:	43                   	inc    %ebx
  800084:	83 fb 0a             	cmp    $0xa,%ebx
  800087:	7c e6                	jl     80006f <_main+0x37>
	}
	
	for (i = 0 ; i < size ; i++)
  800089:	bb 00 00 00 00       	mov    $0x0,%ebx
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	7d 1f                	jge    8000b2 <_main+0x7a>
		cprintf("%d * %d = %d\n",x[i], y[i], z[i]);
  800093:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800096:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  800099:	ff 34 98             	pushl  (%eax,%ebx,4)
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	68 e0 10 80 00       	push   $0x8010e0
  8000a4:	e8 5f 01 00 00       	call   800208 <cprintf>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	43                   	inc    %ebx
  8000ad:	83 fb 0a             	cmp    $0xa,%ebx
  8000b0:	7c e1                	jl     800093 <_main+0x5b>
	
	freeHeap();
  8000b2:	e8 ec 0a 00 00       	call   800ba3 <freeHeap>
	cprintf("the heap is freed successfully\n");
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	68 20 11 80 00       	push   $0x801120
  8000bf:	e8 44 01 00 00       	call   800208 <cprintf>
	z = malloc(sizeof(int)*size) ;
  8000c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8000c9:	c1 e0 02             	shl    $0x2,%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 b8 0a 00 00       	call   800b8c <malloc>
  8000d4:	89 c7                	mov    %eax,%edi
	for (i = 0 ; i < size ; i++)
  8000d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb 0a             	cmp    $0xa,%ebx
  8000e1:	7d 3c                	jge    80011f <_main+0xe7>
	{
		cprintf("x[i] = %d\t",x[i]);
  8000e3:	83 ec 08             	sub    $0x8,%esp
  8000e6:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000e9:	68 ee 10 80 00       	push   $0x8010ee
  8000ee:	e8 15 01 00 00       	call   800208 <cprintf>
		cprintf("y[i] = %d\t",y[i]);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
  8000f9:	ff 34 98             	pushl  (%eax,%ebx,4)
  8000fc:	68 f9 10 80 00       	push   $0x8010f9
  800101:	e8 02 01 00 00       	call   800208 <cprintf>
		cprintf("z[i] = %d\n",z[i]);
  800106:	83 c4 08             	add    $0x8,%esp
  800109:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80010c:	68 04 11 80 00       	push   $0x801104
  800111:	e8 f2 00 00 00       	call   800208 <cprintf>
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	43                   	inc    %ebx
  80011a:	83 fb 0a             	cmp    $0xa,%ebx
  80011d:	7c c4                	jl     8000e3 <_main+0xab>
	
	}

	return;	
}
  80011f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    
	...

00800128 <libmain>:
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800131:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  800134:	c7 05 08 20 80 00 00 	movl   $0xeec00000,0x802008
  80013b:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013e:	85 c9                	test   %ecx,%ecx
  800140:	7e 07                	jle    800149 <libmain+0x21>
		binaryname = argv[0];
  800142:	8b 02                	mov    (%edx),%eax
  800144:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	52                   	push   %edx
  80014d:	51                   	push   %ecx
  80014e:	e8 e5 fe ff ff       	call   800038 <_main>

	// exit gracefully
	//exit();
	sleep();
  800153:	e8 13 00 00 00       	call   80016b <sleep>
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    
	...

0080015c <exit>:
#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);	
  800162:	6a 00                	push   $0x0
  800164:	e8 90 0a 00 00       	call   800bf9 <sys_env_destroy>
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <sleep>:

void
sleep(void)
{	
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800171:	e8 c2 0a 00 00       	call   800c38 <sys_env_sleep>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <putch>:


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 03                	mov    (%ebx),%eax
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018b:	40                   	inc    %eax
  80018c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800193:	75 1a                	jne    8001af <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	68 ff 00 00 00       	push   $0xff
  80019d:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a0:	50                   	push   %eax
  8001a1:	e8 16 0a 00 00       	call   800bbc <sys_cputs>
		b->idx = 0;
  8001a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001af:	ff 43 04             	incl   0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 e8 fe ff ff 00 	movl   $0x0,0xfffffee8(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 ec fe ff ff 00 	movl   $0x0,0xfffffeec(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 e8 fe ff ff    	lea    0xfffffee8(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 78 01 80 00       	push   $0x800178
  8001e6:	e8 2d 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 e8 fe ff ff    	pushl  0xfffffee8(%ebp)
  8001f4:	8d 85 f0 fe ff ff    	lea    0xfffffef0(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 bc 09 00 00       	call   800bbc <sys_cputs>

	return b.cnt;
  800200:	8b 85 ec fe ff ff    	mov    0xfffffeec(%ebp),%eax
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	8b 75 10             	mov    0x10(%ebp),%esi
  800228:	8b 7d 14             	mov    0x14(%ebp),%edi
  80022b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022e:	8b 45 18             	mov    0x18(%ebp),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	39 d7                	cmp    %edx,%edi
  800238:	72 39                	jb     800273 <printnum+0x57>
  80023a:	77 04                	ja     800240 <printnum+0x24>
  80023c:	39 c6                	cmp    %eax,%esi
  80023e:	72 33                	jb     800273 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 20             	pushl  0x20(%ebp)
  800246:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
  800249:	50                   	push   %eax
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 18             	mov    0x18(%ebp),%eax
  800250:	ba 00 00 00 00       	mov    $0x0,%edx
  800255:	52                   	push   %edx
  800256:	50                   	push   %eax
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	e8 42 0b 00 00       	call   800da0 <__udivdi3>
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	52                   	push   %edx
  800262:	50                   	push   %eax
  800263:	ff 75 0c             	pushl  0xc(%ebp)
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 ae ff ff ff       	call   80021c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 19                	jmp    80028c <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800273:	4b                   	dec    %ebx
  800274:	85 db                	test   %ebx,%ebx
  800276:	7e 14                	jle    80028c <printnum+0x70>
			putch(padc, putdat);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	ff 75 20             	pushl  0x20(%ebp)
  800281:	ff 55 08             	call   *0x8(%ebp)
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	4b                   	dec    %ebx
  800288:	85 db                	test   %ebx,%ebx
  80028a:	7f ec                	jg     800278 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	8b 45 18             	mov    0x18(%ebp),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	e8 3a 0c 00 00       	call   800ee0 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 c0 11 80 00 	movsbl 0x8011c0(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff 55 08             	call   *0x8(%ebp)
}
  8002b4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002c5:	83 f8 01             	cmp    $0x1,%eax
  8002c8:	7e 0f                	jle    8002d9 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002ca:	8b 01                	mov    (%ecx),%eax
  8002cc:	83 c0 08             	add    $0x8,%eax
  8002cf:	89 01                	mov    %eax,(%ecx)
  8002d1:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  8002d4:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  8002d7:	eb 0f                	jmp    8002e8 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 01                	mov    (%ecx),%eax
  8002db:	83 c0 04             	add    $0x4,%eax
  8002de:	89 01                	mov    %eax,(%ecx)
  8002e0:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002f3:	83 f8 01             	cmp    $0x1,%eax
  8002f6:	7e 0f                	jle    800307 <getint+0x1d>
		return va_arg(*ap, long long);
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	83 c0 08             	add    $0x8,%eax
  8002fd:	89 02                	mov    %eax,(%edx)
  8002ff:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
  800302:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
  800305:	eb 0f                	jmp    800316 <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
  800307:	8b 02                	mov    (%edx),%eax
  800309:	83 c0 04             	add    $0x4,%eax
  80030c:	89 02                	mov    %eax,(%edx)
  80030e:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
  800311:	89 c2                	mov    %eax,%edx
  800313:	c1 fa 1f             	sar    $0x1f,%edx
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 1c             	sub    $0x1c,%esp
  800321:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800324:	ba 00 00 00 00       	mov    $0x0,%edx
  800329:	8a 13                	mov    (%ebx),%dl
  80032b:	43                   	inc    %ebx
  80032c:	83 fa 25             	cmp    $0x25,%edx
  80032f:	74 22                	je     800353 <vprintfmt+0x3b>
			if (ch == '\0')
  800331:	85 d2                	test   %edx,%edx
  800333:	0f 84 cd 02 00 00    	je     800606 <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	52                   	push   %edx
  800340:	ff 55 08             	call   *0x8(%ebp)
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	8a 13                	mov    (%ebx),%dl
  80034d:	43                   	inc    %ebx
  80034e:	83 fa 25             	cmp    $0x25,%edx
  800351:	75 de                	jne    800331 <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
  800353:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
  800357:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
  80035e:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800363:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
  800368:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	ba 00 00 00 00       	mov    $0x0,%edx
  800374:	8a 13                	mov    (%ebx),%dl
  800376:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
  800379:	43                   	inc    %ebx
  80037a:	83 f8 55             	cmp    $0x55,%eax
  80037d:	0f 87 5e 02 00 00    	ja     8005e1 <vprintfmt+0x2c9>
  800383:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80038a:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
  80038e:	eb df                	jmp    80036f <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800390:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
  800394:	eb d9                	jmp    80036f <vprintfmt+0x57>

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
  800396:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80039b:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80039e:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
  8003a2:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  8003a5:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
  8003a8:	83 f8 09             	cmp    $0x9,%eax
  8003ab:	77 27                	ja     8003d4 <vprintfmt+0xbc>
  8003ad:	43                   	inc    %ebx
  8003ae:	eb eb                	jmp    80039b <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
  8003ba:	eb 18                	jmp    8003d4 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
  8003bc:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003c0:	79 ad                	jns    80036f <vprintfmt+0x57>
				width = 0;
  8003c2:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
  8003c9:	eb a4                	jmp    80036f <vprintfmt+0x57>

		case '#':
			altflag = 1;
  8003cb:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
  8003d2:	eb 9b                	jmp    80036f <vprintfmt+0x57>

		process_precision:
			if (width < 0)
  8003d4:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8003d8:	79 95                	jns    80036f <vprintfmt+0x57>
				width = precision, precision = -1;
  8003da:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
  8003dd:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003e2:	eb 8b                	jmp    80036f <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e4:	41                   	inc    %ecx
			goto reswitch;
  8003e5:	eb 88                	jmp    80036f <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	ff 75 0c             	pushl  0xc(%ebp)
  8003ed:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	ff 70 fc             	pushl  0xfffffffc(%eax)
  8003f7:	e9 da 01 00 00       	jmp    8005d6 <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
  800406:	85 c0                	test   %eax,%eax
  800408:	79 02                	jns    80040c <vprintfmt+0xf4>
				err = -err;
  80040a:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80040c:	83 f8 07             	cmp    $0x7,%eax
  80040f:	7f 0b                	jg     80041c <vprintfmt+0x104>
  800411:	8b 3c 85 00 12 80 00 	mov    0x801200(,%eax,4),%edi
  800418:	85 ff                	test   %edi,%edi
  80041a:	75 08                	jne    800424 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
  80041c:	50                   	push   %eax
  80041d:	68 d1 11 80 00       	push   $0x8011d1
  800422:	eb 06                	jmp    80042a <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
  800424:	57                   	push   %edi
  800425:	68 da 11 80 00       	push   $0x8011da
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	ff 75 08             	pushl  0x8(%ebp)
  800430:	e8 d9 01 00 00       	call   80060e <printfmt>
  800435:	e9 9f 01 00 00       	jmp    8005d9 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
  800444:	85 ff                	test   %edi,%edi
  800446:	75 05                	jne    80044d <vprintfmt+0x135>
				p = "(null)";
  800448:	bf dd 11 80 00       	mov    $0x8011dd,%edi
			if (width > 0 && padc != '-')
  80044d:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800451:	0f 9f c2             	setg   %dl
  800454:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
  800458:	0f 95 c0             	setne  %al
  80045b:	21 d0                	and    %edx,%eax
  80045d:	a8 01                	test   $0x1,%al
  80045f:	74 35                	je     800496 <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	57                   	push   %edi
  800466:	e8 5e 02 00 00       	call   8006c9 <strnlen>
  80046b:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800475:	7e 1f                	jle    800496 <vprintfmt+0x17e>
  800477:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  80047b:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 0c             	pushl  0xc(%ebp)
  800484:	ff 75 e4             	pushl  0xffffffe4(%ebp)
  800487:	ff 55 08             	call   *0x8(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	ff 4d f0             	decl   0xfffffff0(%ebp)
  800490:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800494:	7f e8                	jg     80047e <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800496:	0f be 17             	movsbl (%edi),%edx
  800499:	47                   	inc    %edi
  80049a:	85 d2                	test   %edx,%edx
  80049c:	74 3e                	je     8004dc <vprintfmt+0x1c4>
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	78 03                	js     8004a5 <vprintfmt+0x18d>
  8004a2:	4e                   	dec    %esi
  8004a3:	78 37                	js     8004dc <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
  8004a9:	74 12                	je     8004bd <vprintfmt+0x1a5>
  8004ab:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
  8004ae:	83 f8 5e             	cmp    $0x5e,%eax
  8004b1:	76 0a                	jbe    8004bd <vprintfmt+0x1a5>
					putch('?', putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 0c             	pushl  0xc(%ebp)
  8004b9:	6a 3f                	push   $0x3f
  8004bb:	eb 07                	jmp    8004c4 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004cd:	0f be 17             	movsbl (%edi),%edx
  8004d0:	47                   	inc    %edi
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 07                	je     8004dc <vprintfmt+0x1c4>
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	78 cc                	js     8004a5 <vprintfmt+0x18d>
  8004d9:	4e                   	dec    %esi
  8004da:	79 c9                	jns    8004a5 <vprintfmt+0x18d>
			for (; width > 0; width--)
  8004dc:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004e0:	0f 8e 3e fe ff ff    	jle    800324 <vprintfmt+0xc>
				putch(' ', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff 55 08             	call   *0x8(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	ff 4d f0             	decl   0xfffffff0(%ebp)
  8004f7:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  8004fb:	7f e9                	jg     8004e6 <vprintfmt+0x1ce>
			break;
  8004fd:	e9 22 fe ff ff       	jmp    800324 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	51                   	push   %ecx
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
  800509:	50                   	push   %eax
  80050a:	e8 db fd ff ff       	call   8002ea <getint>
  80050f:	89 c6                	mov    %eax,%esi
  800511:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	85 d2                	test   %edx,%edx
  800518:	79 15                	jns    80052f <vprintfmt+0x217>
				putch('-', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	6a 2d                	push   $0x2d
  800522:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800525:	f7 de                	neg    %esi
  800527:	83 d7 00             	adc    $0x0,%edi
  80052a:	f7 df                	neg    %edi
  80052c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80052f:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800534:	eb 78                	jmp    8005ae <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	51                   	push   %ecx
  80053a:	8d 45 14             	lea    0x14(%ebp),%eax
  80053d:	50                   	push   %eax
  80053e:	e8 79 fd ff ff       	call   8002bc <getuint>
  800543:	89 c6                	mov    %eax,%esi
  800545:	89 d7                	mov    %edx,%edi
			base = 10;
  800547:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80054c:	eb 5d                	jmp    8005ab <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 58                	push   $0x58
  800556:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	ff 75 0c             	pushl  0xc(%ebp)
  80055f:	6a 58                	push   $0x58
  800561:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800564:	83 c4 08             	add    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	6a 58                	push   $0x58
  80056c:	eb 68                	jmp    8005d6 <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 30                	push   $0x30
  800576:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800579:	83 c4 08             	add    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	6a 78                	push   $0x78
  800581:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800584:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
  80058e:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
  800593:	eb 11                	jmp    8005a6 <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	51                   	push   %ecx
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	50                   	push   %eax
  80059d:	e8 1a fd ff ff       	call   8002bc <getuint>
  8005a2:	89 c6                	mov    %eax,%esi
  8005a4:	89 d7                	mov    %edx,%edi
			base = 16;
  8005a6:	ba 10 00 00 00       	mov    $0x10,%edx
  8005ab:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ae:	83 ec 04             	sub    $0x4,%esp
  8005b1:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
  8005b5:	50                   	push   %eax
  8005b6:	ff 75 f0             	pushl  0xfffffff0(%ebp)
  8005b9:	52                   	push   %edx
  8005ba:	57                   	push   %edi
  8005bb:	56                   	push   %esi
  8005bc:	ff 75 0c             	pushl  0xc(%ebp)
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 55 fc ff ff       	call   80021c <printnum>
			break;
  8005c7:	83 c4 20             	add    $0x20,%esp
  8005ca:	e9 55 fd ff ff       	jmp    800324 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	52                   	push   %edx
  8005d6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	e9 43 fd ff ff       	jmp    800324 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 0c             	pushl  0xc(%ebp)
  8005e7:	6a 25                	push   $0x25
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ec:	4b                   	dec    %ebx
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005f4:	0f 84 2a fd ff ff    	je     800324 <vprintfmt+0xc>
  8005fa:	4b                   	dec    %ebx
  8005fb:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
  8005ff:	75 f9                	jne    8005fa <vprintfmt+0x2e2>
				/* do nothing */;
			break;
  800601:	e9 1e fd ff ff       	jmp    800324 <vprintfmt+0xc>
		}
	}
}
  800606:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800609:	5b                   	pop    %ebx
  80060a:	5e                   	pop    %esi
  80060b:	5f                   	pop    %edi
  80060c:	5d                   	pop    %ebp
  80060d:	c3                   	ret    

0080060e <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800617:	50                   	push   %eax
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	ff 75 0c             	pushl  0xc(%ebp)
  80061e:	ff 75 08             	pushl  0x8(%ebp)
  800621:	e8 f2 fc ff ff       	call   800318 <vprintfmt>
	va_end(ap);
}
  800626:	c9                   	leave  
  800627:	c3                   	ret    

00800628 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80062e:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800631:	8b 0a                	mov    (%edx),%ecx
  800633:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800636:	73 07                	jae    80063f <sprintputch+0x17>
		*b->buf++ = ch;
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	88 01                	mov    %al,(%ecx)
  80063d:	ff 02                	incl   (%edx)
}
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	83 ec 18             	sub    $0x18,%esp
  800647:	8b 55 08             	mov    0x8(%ebp),%edx
  80064a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064d:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
  800650:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
  800654:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
  800657:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
  80065e:	85 d2                	test   %edx,%edx
  800660:	0f 94 c2             	sete   %dl
  800663:	85 c9                	test   %ecx,%ecx
  800665:	0f 9e c0             	setle  %al
  800668:	09 d0                	or     %edx,%eax
  80066a:	ba 03 00 00 00       	mov    $0x3,%edx
  80066f:	a8 01                	test   $0x1,%al
  800671:	75 1d                	jne    800690 <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800673:	ff 75 14             	pushl  0x14(%ebp)
  800676:	ff 75 10             	pushl  0x10(%ebp)
  800679:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	68 28 06 80 00       	push   $0x800628
  800682:	e8 91 fc ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800687:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
  80068a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068d:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
  800690:	89 d0                	mov    %edx,%eax
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069d:	50                   	push   %eax
  80069e:	ff 75 10             	pushl  0x10(%ebp)
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	ff 75 08             	pushl  0x8(%ebp)
  8006a7:	e8 95 ff ff ff       	call   800641 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    
	...

008006b0 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8006be:	74 07                	je     8006c7 <strlen+0x17>
		n++;
  8006c0:	40                   	inc    %eax
  8006c1:	42                   	inc    %edx
  8006c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c5:	75 f9                	jne    8006c0 <strlen+0x10>
	return n;
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	74 0f                	je     8006ea <strnlen+0x21>
  8006db:	80 39 00             	cmpb   $0x0,(%ecx)
  8006de:	74 0a                	je     8006ea <strnlen+0x21>
		n++;
  8006e0:	40                   	inc    %eax
  8006e1:	41                   	inc    %ecx
  8006e2:	4a                   	dec    %edx
  8006e3:	74 05                	je     8006ea <strnlen+0x21>
  8006e5:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e8:	75 f6                	jne    8006e0 <strnlen+0x17>
	return n;
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	53                   	push   %ebx
  8006f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006f6:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006f8:	8a 02                	mov    (%edx),%al
  8006fa:	88 01                	mov    %al,(%ecx)
  8006fc:	42                   	inc    %edx
  8006fd:	41                   	inc    %ecx
  8006fe:	84 c0                	test   %al,%al
  800700:	75 f6                	jne    8006f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	5b                   	pop    %ebx
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
  800713:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
  800716:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800718:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071d:	39 f3                	cmp    %esi,%ebx
  80071f:	73 17                	jae    800738 <strncpy+0x31>
		*dst++ = *src;
  800721:	8a 02                	mov    (%edx),%al
  800723:	88 01                	mov    %al,(%ecx)
  800725:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800726:	80 3a 00             	cmpb   $0x0,(%edx)
  800729:	0f 95 c0             	setne  %al
  80072c:	25 ff 00 00 00       	and    $0xff,%eax
  800731:	01 c2                	add    %eax,%edx
  800733:	43                   	inc    %ebx
  800734:	39 f3                	cmp    %esi,%ebx
  800736:	72 e9                	jb     800721 <strncpy+0x1a>
			src++;
	}
	return ret;
}
  800738:	89 f8                	mov    %edi,%eax
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5f                   	pop    %edi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074a:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80074d:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 19                	je     80076c <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
  800753:	4a                   	dec    %edx
  800754:	74 13                	je     800769 <strlcpy+0x2a>
  800756:	80 39 00             	cmpb   $0x0,(%ecx)
  800759:	74 0e                	je     800769 <strlcpy+0x2a>
			*dst++ = *src++;
  80075b:	8a 01                	mov    (%ecx),%al
  80075d:	88 03                	mov    %al,(%ebx)
  80075f:	41                   	inc    %ecx
  800760:	43                   	inc    %ebx
  800761:	4a                   	dec    %edx
  800762:	74 05                	je     800769 <strlcpy+0x2a>
  800764:	80 39 00             	cmpb   $0x0,(%ecx)
  800767:	75 f2                	jne    80075b <strlcpy+0x1c>
		*dst = '\0';
  800769:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80076c:	89 d8                	mov    %ebx,%eax
  80076e:	29 f0                	sub    %esi,%eax
}
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
  80077d:	80 3a 00             	cmpb   $0x0,(%edx)
  800780:	74 13                	je     800795 <strcmp+0x21>
  800782:	8a 02                	mov    (%edx),%al
  800784:	3a 01                	cmp    (%ecx),%al
  800786:	75 0d                	jne    800795 <strcmp+0x21>
		p++, q++;
  800788:	42                   	inc    %edx
  800789:	41                   	inc    %ecx
  80078a:	80 3a 00             	cmpb   $0x0,(%edx)
  80078d:	74 06                	je     800795 <strcmp+0x21>
  80078f:	8a 02                	mov    (%edx),%al
  800791:	3a 01                	cmp    (%ecx),%al
  800793:	74 f3                	je     800788 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	8a 02                	mov    (%edx),%al
  80079c:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a1:	8a 11                	mov    (%ecx),%dl
  8007a3:	29 d0                	sub    %edx,%eax
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
  8007b4:	85 c9                	test   %ecx,%ecx
  8007b6:	74 1f                	je     8007d7 <strncmp+0x30>
  8007b8:	80 3a 00             	cmpb   $0x0,(%edx)
  8007bb:	74 16                	je     8007d3 <strncmp+0x2c>
  8007bd:	8a 02                	mov    (%edx),%al
  8007bf:	3a 03                	cmp    (%ebx),%al
  8007c1:	75 10                	jne    8007d3 <strncmp+0x2c>
		n--, p++, q++;
  8007c3:	42                   	inc    %edx
  8007c4:	43                   	inc    %ebx
  8007c5:	49                   	dec    %ecx
  8007c6:	74 0f                	je     8007d7 <strncmp+0x30>
  8007c8:	80 3a 00             	cmpb   $0x0,(%edx)
  8007cb:	74 06                	je     8007d3 <strncmp+0x2c>
  8007cd:	8a 02                	mov    (%edx),%al
  8007cf:	3a 03                	cmp    (%ebx),%al
  8007d1:	74 f0                	je     8007c3 <strncmp+0x1c>
	if (n == 0)
  8007d3:	85 c9                	test   %ecx,%ecx
  8007d5:	75 07                	jne    8007de <strncmp+0x37>
		return 0;
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	eb 13                	jmp    8007f1 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007de:	8a 12                	mov    (%edx),%dl
  8007e0:	81 e2 ff 00 00 00    	and    $0xff,%edx
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	8a 03                	mov    (%ebx),%al
  8007ed:	29 c2                	sub    %eax,%edx
  8007ef:	89 d0                	mov    %edx,%eax
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fa:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007fd:	80 3a 00             	cmpb   $0x0,(%edx)
  800800:	74 0c                	je     80080e <strchr+0x1a>
		if (*s == c)
  800802:	89 d0                	mov    %edx,%eax
  800804:	38 0a                	cmp    %cl,(%edx)
  800806:	74 0b                	je     800813 <strchr+0x1f>
  800808:	42                   	inc    %edx
  800809:	80 3a 00             	cmpb   $0x0,(%edx)
  80080c:	75 f4                	jne    800802 <strchr+0xe>
			return (char *) s;
	return 0;
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80081e:	80 38 00             	cmpb   $0x0,(%eax)
  800821:	74 0a                	je     80082d <strfind+0x18>
		if (*s == c)
  800823:	38 10                	cmp    %dl,(%eax)
  800825:	74 06                	je     80082d <strfind+0x18>
  800827:	40                   	inc    %eax
  800828:	80 38 00             	cmpb   $0x0,(%eax)
  80082b:	75 f6                	jne    800823 <strfind+0xe>
			break;
	return (char *) s;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <memset>:


void *
memset(void *v, int c, uint32 n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
  800839:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
  80083b:	8b 55 10             	mov    0x10(%ebp),%edx
  80083e:	4a                   	dec    %edx
  80083f:	78 06                	js     800847 <memset+0x18>
		*p++ = c;
  800841:	88 01                	mov    %al,(%ecx)
  800843:	41                   	inc    %ecx
  800844:	4a                   	dec    %edx
  800845:	79 fa                	jns    800841 <memset+0x12>

	return v;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
  80085a:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
  80085c:	89 c8                	mov    %ecx,%eax
  80085e:	49                   	dec    %ecx
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 0d                	je     800870 <memcpy+0x24>
		*d++ = *s++;
  800863:	8a 03                	mov    (%ebx),%al
  800865:	88 02                	mov    %al,(%edx)
  800867:	43                   	inc    %ebx
  800868:	42                   	inc    %edx
  800869:	89 c8                	mov    %ecx,%eax
  80086b:	49                   	dec    %ecx
  80086c:	85 c0                	test   %eax,%eax
  80086e:	75 f3                	jne    800863 <memcpy+0x17>

	return dst;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
  800884:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
  800886:	39 f1                	cmp    %esi,%ecx
  800888:	73 22                	jae    8008ac <memmove+0x36>
  80088a:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
  80088d:	39 f0                	cmp    %esi,%eax
  80088f:	76 1b                	jbe    8008ac <memmove+0x36>
		s += n;
  800891:	89 c1                	mov    %eax,%ecx
		d += n;
  800893:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
  800896:	89 d0                	mov    %edx,%eax
  800898:	4a                   	dec    %edx
  800899:	85 c0                	test   %eax,%eax
  80089b:	74 23                	je     8008c0 <memmove+0x4a>
			*--d = *--s;
  80089d:	4b                   	dec    %ebx
  80089e:	49                   	dec    %ecx
  80089f:	8a 01                	mov    (%ecx),%al
  8008a1:	88 03                	mov    %al,(%ebx)
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	4a                   	dec    %edx
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	75 f3                	jne    80089d <memmove+0x27>
  8008aa:	eb 14                	jmp    8008c0 <memmove+0x4a>
	} else
		while (n-- > 0)
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	4a                   	dec    %edx
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	74 0d                	je     8008c0 <memmove+0x4a>
			*d++ = *s++;
  8008b3:	8a 01                	mov    (%ecx),%al
  8008b5:	88 03                	mov    %al,(%ebx)
  8008b7:	41                   	inc    %ecx
  8008b8:	43                   	inc    %ebx
  8008b9:	89 d0                	mov    %edx,%eax
  8008bb:	4a                   	dec    %edx
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	75 f3                	jne    8008b3 <memmove+0x3d>

	return dst;
}
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	53                   	push   %ebx
  8008ca:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
  8008d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	4a                   	dec    %edx
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	74 23                	je     8008fd <memcmp+0x37>
		if (*s1 != *s2)
  8008da:	8a 01                	mov    (%ecx),%al
  8008dc:	3a 03                	cmp    (%ebx),%al
  8008de:	74 14                	je     8008f4 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
  8008e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e5:	8a 11                	mov    (%ecx),%dl
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	8a 03                	mov    (%ebx),%al
  8008ee:	29 c2                	sub    %eax,%edx
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	eb 0e                	jmp    800902 <memcmp+0x3c>
		s1++, s2++;
  8008f4:	41                   	inc    %ecx
  8008f5:	43                   	inc    %ebx
  8008f6:	89 d0                	mov    %edx,%eax
  8008f8:	4a                   	dec    %edx
  8008f9:	85 c0                	test   %eax,%eax
  8008fb:	75 dd                	jne    8008da <memcmp+0x14>
	}

	return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80090e:	89 c2                	mov    %eax,%edx
  800910:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800913:	39 d0                	cmp    %edx,%eax
  800915:	73 09                	jae    800920 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800917:	38 08                	cmp    %cl,(%eax)
  800919:	74 05                	je     800920 <memfind+0x1b>
  80091b:	40                   	inc    %eax
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	72 f7                	jb     800917 <memfind+0x12>
			break;
	return (void *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	83 ec 04             	sub    $0x4,%esp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800934:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
  80093b:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800940:	80 39 20             	cmpb   $0x20,(%ecx)
  800943:	0f 94 c2             	sete   %dl
  800946:	80 39 09             	cmpb   $0x9,(%ecx)
  800949:	0f 94 c0             	sete   %al
  80094c:	09 d0                	or     %edx,%eax
  80094e:	a8 01                	test   $0x1,%al
  800950:	74 13                	je     800965 <strtol+0x43>
		s++;
  800952:	41                   	inc    %ecx
  800953:	80 39 20             	cmpb   $0x20,(%ecx)
  800956:	0f 94 c2             	sete   %dl
  800959:	80 39 09             	cmpb   $0x9,(%ecx)
  80095c:	0f 94 c0             	sete   %al
  80095f:	09 d0                	or     %edx,%eax
  800961:	a8 01                	test   $0x1,%al
  800963:	75 ed                	jne    800952 <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
  800965:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800968:	75 03                	jne    80096d <strtol+0x4b>
		s++;
  80096a:	41                   	inc    %ecx
  80096b:	eb 0d                	jmp    80097a <strtol+0x58>
	else if (*s == '-')
  80096d:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800970:	75 08                	jne    80097a <strtol+0x58>
		s++, neg = 1;
  800972:	41                   	inc    %ecx
  800973:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097a:	85 db                	test   %ebx,%ebx
  80097c:	0f 94 c2             	sete   %dl
  80097f:	83 fb 10             	cmp    $0x10,%ebx
  800982:	0f 94 c0             	sete   %al
  800985:	09 d0                	or     %edx,%eax
  800987:	a8 01                	test   $0x1,%al
  800989:	74 15                	je     8009a0 <strtol+0x7e>
  80098b:	80 39 30             	cmpb   $0x30,(%ecx)
  80098e:	75 10                	jne    8009a0 <strtol+0x7e>
  800990:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800994:	75 0a                	jne    8009a0 <strtol+0x7e>
		s += 2, base = 16;
  800996:	83 c1 02             	add    $0x2,%ecx
  800999:	bb 10 00 00 00       	mov    $0x10,%ebx
  80099e:	eb 1a                	jmp    8009ba <strtol+0x98>
	else if (base == 0 && s[0] == '0')
  8009a0:	85 db                	test   %ebx,%ebx
  8009a2:	75 16                	jne    8009ba <strtol+0x98>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 08                	jne    8009b1 <strtol+0x8f>
		s++, base = 8;
  8009a9:	41                   	inc    %ecx
  8009aa:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009af:	eb 09                	jmp    8009ba <strtol+0x98>
	else if (base == 0)
  8009b1:	85 db                	test   %ebx,%ebx
  8009b3:	75 05                	jne    8009ba <strtol+0x98>
		base = 10;
  8009b5:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ba:	8a 01                	mov    (%ecx),%al
  8009bc:	83 e8 30             	sub    $0x30,%eax
  8009bf:	3c 09                	cmp    $0x9,%al
  8009c1:	77 08                	ja     8009cb <strtol+0xa9>
			dig = *s - '0';
  8009c3:	0f be 01             	movsbl (%ecx),%eax
  8009c6:	83 e8 30             	sub    $0x30,%eax
  8009c9:	eb 20                	jmp    8009eb <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  8009cb:	8a 01                	mov    (%ecx),%al
  8009cd:	83 e8 61             	sub    $0x61,%eax
  8009d0:	3c 19                	cmp    $0x19,%al
  8009d2:	77 08                	ja     8009dc <strtol+0xba>
			dig = *s - 'a' + 10;
  8009d4:	0f be 01             	movsbl (%ecx),%eax
  8009d7:	83 e8 57             	sub    $0x57,%eax
  8009da:	eb 0f                	jmp    8009eb <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	83 e8 41             	sub    $0x41,%eax
  8009e1:	3c 19                	cmp    $0x19,%al
  8009e3:	77 12                	ja     8009f7 <strtol+0xd5>
			dig = *s - 'A' + 10;
  8009e5:	0f be 01             	movsbl (%ecx),%eax
  8009e8:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009eb:	39 d8                	cmp    %ebx,%eax
  8009ed:	7d 08                	jge    8009f7 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
  8009ef:	41                   	inc    %ecx
  8009f0:	0f af f3             	imul   %ebx,%esi
  8009f3:	01 c6                	add    %eax,%esi
  8009f5:	eb c3                	jmp    8009ba <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f7:	85 ff                	test   %edi,%edi
  8009f9:	74 02                	je     8009fd <strtol+0xdb>
		*endptr = (char *) s;
  8009fb:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  8009fd:	89 f0                	mov    %esi,%eax
  8009ff:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800a03:	74 02                	je     800a07 <strtol+0xe5>
  800a05:	f7 d8                	neg    %eax
}
  800a07:	83 c4 04             	add    $0x4,%esp
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	83 ec 04             	sub    $0x4,%esp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
  800a21:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
  800a28:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	80 39 20             	cmpb   $0x20,(%ecx)
  800a30:	0f 94 c2             	sete   %dl
  800a33:	80 39 09             	cmpb   $0x9,(%ecx)
  800a36:	0f 94 c0             	sete   %al
  800a39:	09 d0                	or     %edx,%eax
  800a3b:	a8 01                	test   $0x1,%al
  800a3d:	74 13                	je     800a52 <strtoul+0x43>
		s++;
  800a3f:	41                   	inc    %ecx
  800a40:	80 39 20             	cmpb   $0x20,(%ecx)
  800a43:	0f 94 c2             	sete   %dl
  800a46:	80 39 09             	cmpb   $0x9,(%ecx)
  800a49:	0f 94 c0             	sete   %al
  800a4c:	09 d0                	or     %edx,%eax
  800a4e:	a8 01                	test   $0x1,%al
  800a50:	75 ed                	jne    800a3f <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
  800a52:	80 39 2b             	cmpb   $0x2b,(%ecx)
  800a55:	75 03                	jne    800a5a <strtoul+0x4b>
		s++;
  800a57:	41                   	inc    %ecx
  800a58:	eb 0d                	jmp    800a67 <strtoul+0x58>
	else if (*s == '-')
  800a5a:	80 39 2d             	cmpb   $0x2d,(%ecx)
  800a5d:	75 08                	jne    800a67 <strtoul+0x58>
		s++, neg = 1;
  800a5f:	41                   	inc    %ecx
  800a60:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	0f 94 c2             	sete   %dl
  800a6c:	83 fb 10             	cmp    $0x10,%ebx
  800a6f:	0f 94 c0             	sete   %al
  800a72:	09 d0                	or     %edx,%eax
  800a74:	a8 01                	test   $0x1,%al
  800a76:	74 15                	je     800a8d <strtoul+0x7e>
  800a78:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7b:	75 10                	jne    800a8d <strtoul+0x7e>
  800a7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a81:	75 0a                	jne    800a8d <strtoul+0x7e>
		s += 2, base = 16;
  800a83:	83 c1 02             	add    $0x2,%ecx
  800a86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8b:	eb 1a                	jmp    800aa7 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 16                	jne    800aa7 <strtoul+0x98>
  800a91:	80 39 30             	cmpb   $0x30,(%ecx)
  800a94:	75 08                	jne    800a9e <strtoul+0x8f>
		s++, base = 8;
  800a96:	41                   	inc    %ecx
  800a97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9c:	eb 09                	jmp    800aa7 <strtoul+0x98>
	else if (base == 0)
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	75 05                	jne    800aa7 <strtoul+0x98>
		base = 10;
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa7:	8a 01                	mov    (%ecx),%al
  800aa9:	83 e8 30             	sub    $0x30,%eax
  800aac:	3c 09                	cmp    $0x9,%al
  800aae:	77 08                	ja     800ab8 <strtoul+0xa9>
			dig = *s - '0';
  800ab0:	0f be 01             	movsbl (%ecx),%eax
  800ab3:	83 e8 30             	sub    $0x30,%eax
  800ab6:	eb 20                	jmp    800ad8 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
  800ab8:	8a 01                	mov    (%ecx),%al
  800aba:	83 e8 61             	sub    $0x61,%eax
  800abd:	3c 19                	cmp    $0x19,%al
  800abf:	77 08                	ja     800ac9 <strtoul+0xba>
			dig = *s - 'a' + 10;
  800ac1:	0f be 01             	movsbl (%ecx),%eax
  800ac4:	83 e8 57             	sub    $0x57,%eax
  800ac7:	eb 0f                	jmp    800ad8 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
  800ac9:	8a 01                	mov    (%ecx),%al
  800acb:	83 e8 41             	sub    $0x41,%eax
  800ace:	3c 19                	cmp    $0x19,%al
  800ad0:	77 12                	ja     800ae4 <strtoul+0xd5>
			dig = *s - 'A' + 10;
  800ad2:	0f be 01             	movsbl (%ecx),%eax
  800ad5:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800ad8:	39 d8                	cmp    %ebx,%eax
  800ada:	7d 08                	jge    800ae4 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
  800adc:	41                   	inc    %ecx
  800add:	0f af f3             	imul   %ebx,%esi
  800ae0:	01 c6                	add    %eax,%esi
  800ae2:	eb c3                	jmp    800aa7 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	74 02                	je     800aea <strtoul+0xdb>
		*endptr = (char *) s;
  800ae8:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
  800aea:	89 f0                	mov    %esi,%eax
  800aec:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
  800af0:	74 02                	je     800af4 <strtoul+0xe5>
  800af2:	f7 d8                	neg    %eax
}
  800af4:	83 c4 04             	add    $0x4,%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800b0e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800b1d:	eb 04                	jmp    800b23 <strsplit+0x27>
			*string++ = 0;
  800b1f:	c6 03 00             	movb   $0x0,(%ebx)
  800b22:	43                   	inc    %ebx
  800b23:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b26:	74 4b                	je     800b73 <strsplit+0x77>
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	0f be 03             	movsbl (%ebx),%eax
  800b2e:	50                   	push   %eax
  800b2f:	56                   	push   %esi
  800b30:	e8 bf fc ff ff       	call   8007f4 <strchr>
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	75 e3                	jne    800b1f <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800b3c:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b3f:	74 32                	je     800b73 <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	83 3f 0f             	cmpl   $0xf,(%edi)
  800b49:	74 39                	je     800b84 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800b4b:	8b 07                	mov    (%edi),%eax
  800b4d:	8b 55 10             	mov    0x10(%ebp),%edx
  800b50:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
  800b53:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800b55:	eb 01                	jmp    800b58 <strsplit+0x5c>
			string++;
  800b57:	43                   	inc    %ebx
  800b58:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b5b:	74 16                	je     800b73 <strsplit+0x77>
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	0f be 03             	movsbl (%ebx),%eax
  800b63:	50                   	push   %eax
  800b64:	56                   	push   %esi
  800b65:	e8 8a fc ff ff       	call   8007f4 <strchr>
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	74 e6                	je     800b57 <strsplit+0x5b>
  800b71:	eb b0                	jmp    800b23 <strsplit+0x27>
	}
	(argv)[*argc] = 0;
  800b73:	8b 07                	mov    (%edi),%eax
  800b75:	8b 55 10             	mov    0x10(%ebp),%edx
  800b78:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800b84:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <malloc>:
 
static uint8 *ptr_user_free_mem  = (uint8*) USER_HEAP_START;

void* malloc(uint32 size)
{	
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	//PROJECT 2008: your code here
	//	

	panic("malloc is not implemented yet");
  800b92:	68 78 13 80 00       	push   $0x801378
  800b97:	6a 2b                	push   $0x2b
  800b99:	68 96 13 80 00       	push   $0x801396
  800b9e:	e8 99 01 00 00       	call   800d3c <_panic>

00800ba3 <freeHeap>:
	
	// [1] Check if the required allocation is within the user heap area, 
	//	if not then return NULL.


	// [2] Calculate the required number of frames (for pages and page tables) for the new heap allocation. 
	//	Hint: Use function sys_calculate_required_frames(uint32 start_virtual_address,uint32 size).
	// 	This function will switch to the kernel mode, calls the kernel function 
	//	calculate_required_frames(uint32* ptr_page_directory, uint32 start_virtual_address, uint32 size) in 
	//	"memory_manager.c" then switch back to user mode, the later function is empty, please go fill it.


	// [3] Calculate the number of free frames in the physical memory. 
	//	Hint: Use function sys_calculate_free_frames() to calculate the free frames.
	// 	This function will switch to the kernel mode, calls the kernel function calculate_free_frames() in 
	//	"memory_manager.c" then switch back to user mode, the later function is empty, please go fill it.


	// [4] Check if the required number of frames available.
	// If available:
	// 	For each page in the range [ ptr_user_free_mem, ptr_user_free_mem + size ] do:
	// 		Make sure that the page is not mapped to an allocated frame 
	// 		Note: the first page of the range may be partially used by previous allocation (i.e. already allocated)
	// 		If the page is not mapped:
	// 			Allocate a frame from the physical memory, 
	// 			Map the page to the allocated frame
	// Hint: Use sys_get_page (void *virtual	_address, int perm) to perform these steps. This function will switch to kernel mode, calls the kernel function get_page (uint32* ptr_page_directory, void *virtual_address, int perm) in "memory_manager.c" then switch back to user mode, the later function is empty, please go fill it.


	// 	Update the ptr_user_free_mem.
	// 	Return pointer containing the virtual address of allocated space, the pointer should not exceed USER_HEAP_MAX - 1
	// Else:
	// 	Print error message and return NULL.


	return NULL	;
}

//=================================================================================//
//============================== BONUS FUNCTION ===================================//
//=================================================================================//

// freeHeap:
//	This function frees all the dynamic allocated space starting at USER_HEAP_START 
//	to ptr_user_free_mem
//	Steps:
//		1) Unmap all mapped pages in the range [USER_HEAP_START, ptr_user_free_mem]
//		2) Free all mapped page tables in this range
//		3) Set ptr_user_free_mem to USER_HEAP_START 
//	To do these steps, we need to switch to the kernel, unmap the pages and page tables
//	then switch back to the user again. 
//	Hint: Use function sys_freeMem(void* start_virtual_address, uint32 size) which 
//	will switch to the kernel mode, then calls 
//	freeMem(uint32* ptr_page_directory, void* start_virtual_address, uint32 size) in 
//	"memory_manager.c" then switch back to user mode, the later function is empty, 
//	please go fill it.

void freeHeap()
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//PROJECT 2008: your code here
	//	

	panic("freeHeap is not implemented yet");
  800ba9:	68 c0 13 80 00       	push   $0x8013c0
  800bae:	6a 6a                	push   $0x6a
  800bb0:	68 96 13 80 00       	push   $0x801396
  800bb5:	e8 82 01 00 00       	call   800d3c <_panic>
	...

00800bbc <sys_cputs>:
}

void
sys_cputs(const char *s, uint32 len)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	89 fb                	mov    %edi,%ebx
  800bd1:	89 fe                	mov    %edi,%esi
  800bd3:	cd 30                	int    $0x30
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_cgetc>:

int
sys_cgetc(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	b8 01 00 00 00       	mov    $0x1,%eax
  800be5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bea:	89 fa                	mov    %edi,%edx
  800bec:	89 f9                	mov    %edi,%ecx
  800bee:	89 fb                	mov    %edi,%ebx
  800bf0:	89 fe                	mov    %edi,%esi
  800bf2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	b8 03 00 00 00       	mov    $0x3,%eax
  800c07:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0c:	89 f9                	mov    %edi,%ecx
  800c0e:	89 fb                	mov    %edi,%ebx
  800c10:	89 fe                	mov    %edi,%esi
  800c12:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c24:	bf 00 00 00 00       	mov    $0x0,%edi
  800c29:	89 fa                	mov    %edi,%edx
  800c2b:	89 f9                	mov    %edi,%ecx
  800c2d:	89 fb                	mov    %edi,%ebx
  800c2f:	89 fe                	mov    %edi,%esi
  800c31:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
  800c48:	89 fa                	mov    %edi,%edx
  800c4a:	89 f9                	mov    %edi,%ecx
  800c4c:	89 fb                	mov    %edi,%ebx
  800c4e:	89 fe                	mov    %edi,%esi
  800c50:	cd 30                	int    $0x30
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	b8 05 00 00 00       	mov    $0x5,%eax
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6d:	89 fb                	mov    %edi,%ebx
  800c6f:	89 fe                	mov    %edi,%esi
  800c71:	cd 30                	int    $0x30
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	b8 06 00 00 00       	mov    $0x6,%eax
  800c89:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8e:	89 fb                	mov    %edi,%ebx
  800c90:	89 fe                	mov    %edi,%esi
  800c92:	cd 30                	int    $0x30
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cab:	8b 75 18             	mov    0x18(%ebp),%esi
  800cae:	b8 07 00 00 00       	mov    $0x7,%eax
  800cb3:	cd 30                	int    $0x30
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd0:	89 fb                	mov    %edi,%ebx
  800cd2:	89 fe                	mov    %edi,%esi
  800cd4:	cd 30                	int    $0x30
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf1:	89 fb                	mov    %edi,%ebx
  800cf3:	89 fe                	mov    %edi,%esi
  800cf5:	cd 30                	int    $0x30
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d07:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0c:	89 fa                	mov    %edi,%edx
  800d0e:	89 f9                	mov    %edi,%ecx
  800d10:	89 fb                	mov    %edi,%ebx
  800d12:	89 fe                	mov    %edi,%esi
  800d14:	cd 30                	int    $0x30
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d31:	89 fb                	mov    %edi,%ebx
  800d33:	89 fe                	mov    %edi,%esi
  800d35:	cd 30                	int    $0x30
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
	return;
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <_panic>:
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	va_start(ap, fmt);
  800d43:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800d46:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800d4d:	74 16                	je     800d65 <_panic+0x29>
		cprintf("%s: ", argv0);
  800d4f:	83 ec 08             	sub    $0x8,%esp
  800d52:	ff 35 0c 20 80 00    	pushl  0x80200c
  800d58:	68 e0 13 80 00       	push   $0x8013e0
  800d5d:	e8 a6 f4 ff ff       	call   800208 <cprintf>
  800d62:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	ff 75 08             	pushl  0x8(%ebp)
  800d6b:	ff 35 00 20 80 00    	pushl  0x802000
  800d71:	68 e5 13 80 00       	push   $0x8013e5
  800d76:	e8 8d f4 ff ff       	call   800208 <cprintf>
	vcprintf(fmt, ap);
  800d7b:	83 c4 08             	add    $0x8,%esp
  800d7e:	53                   	push   %ebx
  800d7f:	ff 75 10             	pushl  0x10(%ebp)
  800d82:	e8 30 f4 ff ff       	call   8001b7 <vcprintf>
	cprintf("\n");
  800d87:	c7 04 24 0d 11 80 00 	movl   $0x80110d,(%esp)
  800d8e:	e8 75 f4 ff ff       	call   800208 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800d93:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800d96:	cc                   	int3   
  800d97:	eb fd                	jmp    800d96 <_panic+0x5a>
}
  800d99:	00 00                	add    %al,(%eax)
  800d9b:	00 00                	add    %al,(%eax)
  800d9d:	00 00                	add    %al,(%eax)
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
