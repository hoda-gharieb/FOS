
obj/kern/kernel:     file format elf32-i386

Disassembly of section .text:

f0100000 <start_of_kernel-0xc>:
.long CHECKSUM

.globl		start_of_kernel
start_of_kernel:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <start_of_kernel>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 e0 11 00 	lgdtl  0x11e018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Leave a few words on the stack for the user trap frame
	movl	$(ptr_stack_top-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc df 11 f0       	mov    $0xf011dfbc,%esp

	# now to C code
	call	FOS_initialize
f0100038:	e8 03 00 00 00       	call   f0100040 <FOS_initialize>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <FOS_initialize>:


//First ever function called in FOS kernel
void FOS_initialize()
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	//get actual addresses after code linking 
	extern char start_of_uninitialized_data_section[], end_of_kernel[];

	// Before doing anything else,
	// clear the uninitialized global data (BSS) section of our program, from start_of_uninitialized_data_section to end_of_kernel 
	// This ensures that all static/global variables start with zero value.
	memset(start_of_uninitialized_data_section, 0, end_of_kernel - start_of_uninitialized_data_section);
f0100046:	b8 90 e9 19 f0       	mov    $0xf019e990,%eax
f010004b:	2d 86 de 19 f0       	sub    $0xf019de86,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 86 de 19 f0       	push   $0xf019de86
f0100058:	e8 32 44 00 00       	call   f010448f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	console_initialize();
f010005d:	e8 d5 05 00 00       	call   f0100637 <console_initialize>

	//print welcome message
	print_welcome_message();
f0100062:	e8 3d 00 00 00       	call   f01000a4 <print_welcome_message>

	// Lab 2 memory management initialization functions
	detect_memory();
f0100067:	e8 5a 15 00 00       	call   f01015c6 <detect_memory>
	initialize_kernel_VM();
f010006c:	e8 57 21 00 00       	call   f01021c8 <initialize_kernel_VM>
	initialize_paging();
f0100071:	e8 f7 23 00 00       	call   f010246d <initialize_paging>
	page_check();
f0100076:	e8 05 18 00 00       	call   f0101880 <page_check>

	
	// Lab 3 user environment initialization functions
	env_init();
f010007b:	e8 49 2e 00 00       	call   f0102ec9 <env_init>
	idt_init();
f0100080:	e8 94 33 00 00       	call   f0103419 <idt_init>

	
	// start the kernel command prompt.
	while (1==1)
	{
		cprintf("\nWelcome to the FOS kernel command prompt!\n");
f0100085:	c7 04 24 20 4b 10 f0 	movl   $0xf0104b20,(%esp)
f010008c:	e8 4d 33 00 00       	call   f01033de <cprintf>
		cprintf("Type 'help' for a list of commands.\n");	
f0100091:	c7 04 24 60 4b 10 f0 	movl   $0xf0104b60,(%esp)
f0100098:	e8 41 33 00 00       	call   f01033de <cprintf>
		run_command_prompt();
f010009d:	e8 f2 05 00 00       	call   f0100694 <run_command_prompt>
f01000a2:	eb e1                	jmp    f0100085 <FOS_initialize+0x45>

f01000a4 <print_welcome_message>:
	}
}


void print_welcome_message()
{
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	83 ec 14             	sub    $0x14,%esp
	cprintf("\n\n\n");
f01000aa:	68 a6 4c 10 f0       	push   $0xf0104ca6
f01000af:	e8 2a 33 00 00       	call   f01033de <cprintf>
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000b4:	c7 04 24 a0 4b 10 f0 	movl   $0xf0104ba0,(%esp)
f01000bb:	e8 1e 33 00 00       	call   f01033de <cprintf>
	cprintf("\t\t!!                                                             !!\n");
f01000c0:	c7 04 24 00 4c 10 f0 	movl   $0xf0104c00,(%esp)
f01000c7:	e8 12 33 00 00       	call   f01033de <cprintf>
	cprintf("\t\t!!                   !! FCIS says HELLO !!                     !!\n");
f01000cc:	c7 04 24 60 4c 10 f0 	movl   $0xf0104c60,(%esp)
f01000d3:	e8 06 33 00 00       	call   f01033de <cprintf>
	cprintf("\t\t!!                                                             !!\n");
f01000d8:	c7 04 24 00 4c 10 f0 	movl   $0xf0104c00,(%esp)
f01000df:	e8 fa 32 00 00       	call   f01033de <cprintf>
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000e4:	c7 04 24 a0 4b 10 f0 	movl   $0xf0104ba0,(%esp)
f01000eb:	e8 ee 32 00 00       	call   f01033de <cprintf>
	cprintf("\n\n\n\n");	
f01000f0:	c7 04 24 a5 4c 10 f0 	movl   $0xf0104ca5,(%esp)
f01000f7:	e8 e2 32 00 00       	call   f01033de <cprintf>
}
f01000fc:	c9                   	leave  
f01000fd:	c3                   	ret    

f01000fe <_panic>:


/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
static const char *panicstr;

/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel command prompt.
 */
void _panic(const char *file, int line, const char *fmt,...)
{
f01000fe:	55                   	push   %ebp
f01000ff:	89 e5                	mov    %esp,%ebp
f0100101:	53                   	push   %ebx
f0100102:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100105:	83 3d a0 de 19 f0 00 	cmpl   $0x0,0xf019dea0
f010010c:	75 39                	jne    f0100147 <_panic+0x49>
		goto dead;
	panicstr = fmt;
f010010e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100111:	a3 a0 de 19 f0       	mov    %eax,0xf019dea0

	va_start(ap, fmt);
f0100116:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100119:	83 ec 04             	sub    $0x4,%esp
f010011c:	ff 75 0c             	pushl  0xc(%ebp)
f010011f:	ff 75 08             	pushl  0x8(%ebp)
f0100122:	68 aa 4c 10 f0       	push   $0xf0104caa
f0100127:	e8 b2 32 00 00       	call   f01033de <cprintf>
	vcprintf(fmt, ap);
f010012c:	83 c4 08             	add    $0x8,%esp
f010012f:	53                   	push   %ebx
f0100130:	ff 75 10             	pushl  0x10(%ebp)
f0100133:	e8 80 32 00 00       	call   f01033b8 <vcprintf>
	cprintf("\n");
f0100138:	c7 04 24 a8 4c 10 f0 	movl   $0xf0104ca8,(%esp)
f010013f:	e8 9a 32 00 00       	call   f01033de <cprintf>
	va_end(ap);
f0100144:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel command prompt */
	while (1==1)
		run_command_prompt();
f0100147:	e8 48 05 00 00       	call   f0100694 <run_command_prompt>
f010014c:	eb f9                	jmp    f0100147 <_panic+0x49>

f010014e <_warn>:
}

/* like panic, but don't enters the kernel command prompt*/
void _warn(const char *file, int line, const char *fmt,...)
{
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	53                   	push   %ebx
f0100152:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100155:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100158:	ff 75 0c             	pushl  0xc(%ebp)
f010015b:	ff 75 08             	pushl  0x8(%ebp)
f010015e:	68 c2 4c 10 f0       	push   $0xf0104cc2
f0100163:	e8 76 32 00 00       	call   f01033de <cprintf>
	vcprintf(fmt, ap);
f0100168:	83 c4 08             	add    $0x8,%esp
f010016b:	53                   	push   %ebx
f010016c:	ff 75 10             	pushl  0x10(%ebp)
f010016f:	e8 44 32 00 00       	call   f01033b8 <vcprintf>
	cprintf("\n");
f0100174:	c7 04 24 a8 4c 10 f0 	movl   $0xf0104ca8,(%esp)
f010017b:	e8 5e 32 00 00       	call   f01033de <cprintf>
	va_end(ap);
}
f0100180:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100183:	c9                   	leave  
f0100184:	c3                   	ret    
f0100185:	00 00                	add    %al,(%eax)
	...

f0100188 <serial_proc_data>:
static bool serial_exists;

int
serial_proc_data(void)
{
f0100188:	55                   	push   %ebp
f0100189:	89 e5                	mov    %esp,%ebp
}

static __inline uint8
inb(int port)
{
f010018b:	ba fd 03 00 00       	mov    $0x3fd,%edx
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100190:	ec                   	in     (%dx),%al
f0100191:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100196:	a8 01                	test   $0x1,%al
f0100198:	74 0d                	je     f01001a7 <serial_proc_data+0x1f>
f010019a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010019f:	ec                   	in     (%dx),%al
f01001a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01001a5:	88 c2                	mov    %al,%dl
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
	return inb(COM1+COM_RX);
}
f01001a7:	89 d0                	mov    %edx,%eax
f01001a9:	5d                   	pop    %ebp
f01001aa:	c3                   	ret    

f01001ab <serial_intr>:

void
serial_intr(void)
{
f01001ab:	55                   	push   %ebp
f01001ac:	89 e5                	mov    %esp,%ebp
f01001ae:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01001b1:	83 3d c4 de 19 f0 00 	cmpl   $0x0,0xf019dec4
f01001b8:	74 10                	je     f01001ca <serial_intr+0x1f>
		cons_intr(serial_proc_data);
f01001ba:	83 ec 0c             	sub    $0xc,%esp
f01001bd:	68 88 01 10 f0       	push   $0xf0100188
f01001c2:	e8 ca 03 00 00       	call   f0100591 <cons_intr>
f01001c7:	83 c4 10             	add    $0x10,%esp
}
f01001ca:	c9                   	leave  
f01001cb:	c3                   	ret    

f01001cc <serial_init>:

void
serial_init(void)
{
f01001cc:	55                   	push   %ebp
f01001cd:	89 e5                	mov    %esp,%ebp
f01001cf:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8 data)
{
f01001d0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001d5:	b0 00                	mov    $0x0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d7:	89 da                	mov    %ebx,%edx
f01001d9:	ee                   	out    %al,(%dx)
f01001da:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01001df:	b0 80                	mov    $0x80,%al
f01001e1:	ee                   	out    %al,(%dx)
f01001e2:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001e7:	b0 0c                	mov    $0xc,%al
f01001e9:	89 ca                	mov    %ecx,%edx
f01001eb:	ee                   	out    %al,(%dx)
f01001ec:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01001f1:	b0 00                	mov    $0x0,%al
f01001f3:	ee                   	out    %al,(%dx)
f01001f4:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01001f9:	b0 03                	mov    $0x3,%al
f01001fb:	ee                   	out    %al,(%dx)
f01001fc:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100201:	b0 00                	mov    $0x0,%al
f0100203:	ee                   	out    %al,(%dx)
f0100204:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100209:	b0 01                	mov    $0x1,%al
f010020b:	ee                   	out    %al,(%dx)
f010020c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100211:	ec                   	in     (%dx),%al
f0100212:	3c ff                	cmp    $0xff,%al
f0100214:	0f 95 c0             	setne  %al
f0100217:	25 ff 00 00 00       	and    $0xff,%eax
f010021c:	a3 c4 de 19 f0       	mov    %eax,0xf019dec4
f0100221:	89 da                	mov    %ebx,%edx
f0100223:	ec                   	in     (%dx),%al
f0100224:	89 ca                	mov    %ecx,%edx
f0100226:	ec                   	in     (%dx),%al
	// Turn off the FIFO
	outb(COM1+COM_FCR, 0);
	
	// Set speed; requires DLAB latch
	outb(COM1+COM_LCR, COM_LCR_DLAB);
	outb(COM1+COM_DLL, (uint8) (115200 / 9600));
	outb(COM1+COM_DLM, 0);

	// 8 data bits, 1 stop bit, parity off; turn off DLAB latch
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);

	// No modem controls
	outb(COM1+COM_MCR, 0);
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100227:	5b                   	pop    %ebx
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <delay>:



/***** Parallel port output code *****/
// For information on PC parallel port programming, see the class References
// page.

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
}

static __inline uint8
inb(int port)
{
f010022d:	ba 84 00 00 00       	mov    $0x84,%edx
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100232:	ec                   	in     (%dx),%al
f0100233:	ec                   	in     (%dx),%al
f0100234:	ec                   	in     (%dx),%al
f0100235:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100236:	5d                   	pop    %ebp
f0100237:	c3                   	ret    

f0100238 <lpt_putc>:

static void
lpt_putc(int c)
{
f0100238:	55                   	push   %ebp
f0100239:	89 e5                	mov    %esp,%ebp
f010023b:	56                   	push   %esi
f010023c:	53                   	push   %ebx
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 2800; i++) //12800
f010023d:	bb 00 00 00 00       	mov    $0x0,%ebx
}

static __inline uint8
inb(int port)
{
f0100242:	ba 79 03 00 00       	mov    $0x379,%edx
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100247:	ec                   	in     (%dx),%al
f0100248:	84 c0                	test   %al,%al
f010024a:	78 1a                	js     f0100266 <lpt_putc+0x2e>
f010024c:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100251:	e8 d4 ff ff ff       	call   f010022a <delay>
f0100256:	43                   	inc    %ebx
static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100257:	89 f2                	mov    %esi,%edx
f0100259:	ec                   	in     (%dx),%al
f010025a:	84 c0                	test   %al,%al
f010025c:	78 08                	js     f0100266 <lpt_putc+0x2e>
f010025e:	81 fb ef 0a 00 00    	cmp    $0xaef,%ebx
f0100264:	7e eb                	jle    f0100251 <lpt_putc+0x19>
	return data;
}

static __inline void
insb(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsb"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline uint16
inw(int port)
{
	uint16 data;
	__asm __volatile("inw %w1,%0" : "=a" (data) : "d" (port));
	return data;
}

static __inline void
insw(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsw"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline uint32
inl(int port)
{
	uint32 data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
	return data;
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
			 "=D" (addr), "=c" (cnt)		:
			 "d" (port), "0" (addr), "1" (cnt)	:
			 "memory", "cc");
}

static __inline void
outb(int port, uint8 data)
{
f0100266:	ba 78 03 00 00       	mov    $0x378,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026b:	8a 45 08             	mov    0x8(%ebp),%al
f010026e:	ee                   	out    %al,(%dx)
f010026f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100274:	b0 0d                	mov    $0xd,%al
f0100276:	ee                   	out    %al,(%dx)
f0100277:	b0 08                	mov    $0x8,%al
f0100279:	ee                   	out    %al,(%dx)
	outb(0x378+0, c);
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f010027a:	5b                   	pop    %ebx
f010027b:	5e                   	pop    %esi
f010027c:	5d                   	pop    %ebp
f010027d:	c3                   	ret    

f010027e <cga_init>:




/***** Text-mode CGA/VGA display output *****/

static unsigned addr_6845;
static uint16 *crt_buf;
static uint16 crt_pos;

void
cga_init(void)
{
f010027e:	55                   	push   %ebp
f010027f:	89 e5                	mov    %esp,%ebp
f0100281:	57                   	push   %edi
f0100282:	56                   	push   %esi
f0100283:	53                   	push   %ebx
	volatile uint16 *cp;
	uint16 was;
	unsigned pos;

	cp = (uint16*) (KERNEL_BASE + CGA_BUF);
f0100284:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	was = *cp;
f0100289:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16) 0xA55A;
f0100290:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100297:	5a a5 
	if (*cp != 0xA55A) {
f0100299:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010029f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01002a3:	74 11                	je     f01002b6 <cga_init+0x38>
		cp = (uint16*) (KERNEL_BASE + MONO_BUF);
f01002a5:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
		addr_6845 = MONO_BASE;
f01002aa:	c7 05 c8 de 19 f0 b4 	movl   $0x3b4,0xf019dec8
f01002b1:	03 00 00 
f01002b4:	eb 0d                	jmp    f01002c3 <cga_init+0x45>
	} else {
		*cp = was;
f01002b6:	66 89 16             	mov    %dx,(%esi)
		addr_6845 = CGA_BASE;
f01002b9:	c7 05 c8 de 19 f0 d4 	movl   $0x3d4,0xf019dec8
f01002c0:	03 00 00 
}

static __inline void
outb(int port, uint8 data)
{
f01002c3:	8b 0d c8 de 19 f0    	mov    0xf019dec8,%ecx
f01002c9:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cb:	89 ca                	mov    %ecx,%edx
f01002cd:	ee                   	out    %al,(%dx)
f01002ce:	8d 79 01             	lea    0x1(%ecx),%edi
f01002d1:	89 fa                	mov    %edi,%edx
f01002d3:	ec                   	in     (%dx),%al
f01002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002d9:	88 c3                	mov    %al,%bl
f01002db:	c1 e3 08             	shl    $0x8,%ebx
f01002de:	b0 0f                	mov    $0xf,%al
f01002e0:	89 ca                	mov    %ecx,%edx
f01002e2:	ee                   	out    %al,(%dx)
f01002e3:	89 fa                	mov    %edi,%edx
f01002e5:	ec                   	in     (%dx),%al
f01002e6:	25 ff 00 00 00       	and    $0xff,%eax
f01002eb:	09 c3                	or     %eax,%ebx
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16*) cp;
f01002ed:	89 35 cc de 19 f0    	mov    %esi,0xf019decc
	crt_pos = pos;
f01002f3:	66 89 1d d0 de 19 f0 	mov    %bx,0xf019ded0
}
f01002fa:	5b                   	pop    %ebx
f01002fb:	5e                   	pop    %esi
f01002fc:	5f                   	pop    %edi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    

f01002ff <cga_putc>:



void
cga_putc(int c)
{
f01002ff:	55                   	push   %ebp
f0100300:	89 e5                	mov    %esp,%ebp
f0100302:	53                   	push   %ebx
f0100303:	83 ec 04             	sub    $0x4,%esp
f0100306:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100309:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f010030f:	75 03                	jne    f0100314 <cga_putc+0x15>
		c |= 0x0700;
f0100311:	80 cd 07             	or     $0x7,%ch

	switch (c & 0xff) {
f0100314:	0f b6 c1             	movzbl %cl,%eax
f0100317:	83 f8 09             	cmp    $0x9,%eax
f010031a:	74 7f                	je     f010039b <cga_putc+0x9c>
f010031c:	83 f8 09             	cmp    $0x9,%eax
f010031f:	7f 0a                	jg     f010032b <cga_putc+0x2c>
f0100321:	83 f8 08             	cmp    $0x8,%eax
f0100324:	74 14                	je     f010033a <cga_putc+0x3b>
f0100326:	e9 af 00 00 00       	jmp    f01003da <cga_putc+0xdb>
f010032b:	83 f8 0a             	cmp    $0xa,%eax
f010032e:	74 40                	je     f0100370 <cga_putc+0x71>
f0100330:	83 f8 0d             	cmp    $0xd,%eax
f0100333:	74 43                	je     f0100378 <cga_putc+0x79>
f0100335:	e9 a0 00 00 00       	jmp    f01003da <cga_putc+0xdb>
	case '\b':
		if (crt_pos > 0) {
f010033a:	66 83 3d d0 de 19 f0 	cmpw   $0x0,0xf019ded0
f0100341:	00 
f0100342:	0f 84 ae 00 00 00    	je     f01003f6 <cga_putc+0xf7>
			crt_pos--;
f0100348:	66 a1 d0 de 19 f0    	mov    0xf019ded0,%ax
f010034e:	48                   	dec    %eax
f010034f:	66 a3 d0 de 19 f0    	mov    %ax,0xf019ded0
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100355:	25 ff ff 00 00       	and    $0xffff,%eax
f010035a:	89 ca                	mov    %ecx,%edx
f010035c:	b2 00                	mov    $0x0,%dl
f010035e:	83 ca 20             	or     $0x20,%edx
f0100361:	8b 0d cc de 19 f0    	mov    0xf019decc,%ecx
f0100367:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
		}
		break;
f010036b:	e9 86 00 00 00       	jmp    f01003f6 <cga_putc+0xf7>
	case '\n':
		crt_pos += CRT_COLS;
f0100370:	66 83 05 d0 de 19 f0 	addw   $0x50,0xf019ded0
f0100377:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100378:	66 8b 1d d0 de 19 f0 	mov    0xf019ded0,%bx
f010037f:	b9 50 00 00 00       	mov    $0x50,%ecx
f0100384:	ba 00 00 00 00       	mov    $0x0,%edx
f0100389:	89 d8                	mov    %ebx,%eax
f010038b:	66 f7 f1             	div    %cx
f010038e:	89 d8                	mov    %ebx,%eax
f0100390:	66 29 d0             	sub    %dx,%ax
f0100393:	66 a3 d0 de 19 f0    	mov    %ax,0xf019ded0
		break;
f0100399:	eb 5b                	jmp    f01003f6 <cga_putc+0xf7>
	case '\t':
		cons_putc(' ');
f010039b:	83 ec 0c             	sub    $0xc,%esp
f010039e:	6a 20                	push   $0x20
f01003a0:	e8 75 02 00 00       	call   f010061a <cons_putc>
		cons_putc(' ');
f01003a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003ac:	e8 69 02 00 00       	call   f010061a <cons_putc>
		cons_putc(' ');
f01003b1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003b8:	e8 5d 02 00 00       	call   f010061a <cons_putc>
		cons_putc(' ');
f01003bd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003c4:	e8 51 02 00 00       	call   f010061a <cons_putc>
		cons_putc(' ');
f01003c9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01003d0:	e8 45 02 00 00       	call   f010061a <cons_putc>
		break;
f01003d5:	83 c4 10             	add    $0x10,%esp
f01003d8:	eb 1c                	jmp    f01003f6 <cga_putc+0xf7>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003da:	66 a1 d0 de 19 f0    	mov    0xf019ded0,%ax
f01003e0:	25 ff ff 00 00       	and    $0xffff,%eax
f01003e5:	8b 15 cc de 19 f0    	mov    0xf019decc,%edx
f01003eb:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01003ef:	66 ff 05 d0 de 19 f0 	incw   0xf019ded0
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003f6:	66 81 3d d0 de 19 f0 	cmpw   $0x7cf,0xf019ded0
f01003fd:	cf 07 
f01003ff:	76 3f                	jbe    f0100440 <cga_putc+0x141>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
f0100401:	83 ec 04             	sub    $0x4,%esp
f0100404:	68 00 0f 00 00       	push   $0xf00
f0100409:	8b 15 cc de 19 f0    	mov    0xf019decc,%edx
f010040f:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100415:	50                   	push   %eax
f0100416:	52                   	push   %edx
f0100417:	e8 90 40 00 00       	call   f01044ac <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010041c:	ba 80 07 00 00       	mov    $0x780,%edx
f0100421:	83 c4 10             	add    $0x10,%esp
			crt_buf[i] = 0x0700 | ' ';
f0100424:	a1 cc de 19 f0       	mov    0xf019decc,%eax
f0100429:	66 c7 04 50 20 07    	movw   $0x720,(%eax,%edx,2)
f010042f:	42                   	inc    %edx
f0100430:	81 fa cf 07 00 00    	cmp    $0x7cf,%edx
f0100436:	7e ec                	jle    f0100424 <cga_putc+0x125>
		crt_pos -= CRT_COLS;
f0100438:	66 83 2d d0 de 19 f0 	subw   $0x50,0xf019ded0
f010043f:	50 
}

static __inline void
outb(int port, uint8 data)
{
f0100440:	8b 1d c8 de 19 f0    	mov    0xf019dec8,%ebx
f0100446:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100448:	89 da                	mov    %ebx,%edx
f010044a:	ee                   	out    %al,(%dx)
f010044b:	8d 4b 01             	lea    0x1(%ebx),%ecx
f010044e:	a0 d1 de 19 f0       	mov    0xf019ded1,%al
f0100453:	89 ca                	mov    %ecx,%edx
f0100455:	ee                   	out    %al,(%dx)
f0100456:	b0 0f                	mov    $0xf,%al
f0100458:	89 da                	mov    %ebx,%edx
f010045a:	ee                   	out    %al,(%dx)
f010045b:	a0 d0 de 19 f0       	mov    0xf019ded0,%al
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
	outb(addr_6845 + 1, crt_pos >> 8);
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100463:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100466:	c9                   	leave  
f0100467:	c3                   	ret    

f0100468 <kbd_proc_data>:


/***** Keyboard input code *****/

#define NO		0

#define SHIFT		(1<<0)
#define CTL		(1<<1)
#define ALT		(1<<2)

#define CAPSLOCK	(1<<3)
#define NUMLOCK		(1<<4)
#define SCROLLLOCK	(1<<5)

#define E0ESC		(1<<6)

static uint8 shiftcode[256] = 
{
	[0x1D] CTL,
	[0x2A] SHIFT,
	[0x36] SHIFT,
	[0x38] ALT,
	[0x9D] CTL,
	[0xB8] ALT
};

static uint8 togglecode[256] = 
{
	[0x3A] CAPSLOCK,
	[0x45] NUMLOCK,
	[0x46] SCROLLLOCK
};

static uint8 normalmap[256] =
{
	NO,   0x1B, '1',  '2',  '3',  '4',  '5',  '6',	// 0x00
	'7',  '8',  '9',  '0',  '-',  '=',  '\b', '\t',
	'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',	// 0x10
	'o',  'p',  '[',  ']',  '\n', NO,   'a',  's',
	'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';',	// 0x20
	'\'', '`',  NO,   '\\', 'z',  'x',  'c',  'v',
	'b',  'n',  'm',  ',',  '.',  '/',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0x97] KEY_HOME,	[0x9C] '\n' /*KP_Enter*/,
	[0xB5] '/' /*KP_Div*/,	[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

static uint8 shiftmap[256] = 
{
	NO,   033,  '!',  '@',  '#',  '$',  '%',  '^',	// 0x00
	'&',  '*',  '(',  ')',  '_',  '+',  '\b', '\t',
	'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',	// 0x10
	'O',  'P',  '{',  '}',  '\n', NO,   'A',  'S',
	'D',  'F',  'G',  'H',  'J',  'K',  'L',  ':',	// 0x20
	'"',  '~',  NO,   '|',  'Z',  'X',  'C',  'V',
	'B',  'N',  'M',  '<',  '>',  '?',  NO,   '*',	// 0x30
	NO,   ' ',  NO,   NO,   NO,   NO,   NO,   NO,
	NO,   NO,   NO,   NO,   NO,   NO,   NO,   '7',	// 0x40
	'8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',
	'2',  '3',  '0',  '.',  NO,   NO,   NO,   NO,	// 0x50
	[0x97] KEY_HOME,	[0x9C] '\n' /*KP_Enter*/,
	[0xB5] '/' /*KP_Div*/,	[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

#define C(x) (x - '@')

static uint8 ctlmap[256] = 
{
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	NO,      NO,      NO,      NO,      NO,      NO,      NO,      NO, 
	C('Q'),  C('W'),  C('E'),  C('R'),  C('T'),  C('Y'),  C('U'),  C('I'),
	C('O'),  C('P'),  NO,      NO,      '\r',    NO,      C('A'),  C('S'),
	C('D'),  C('F'),  C('G'),  C('H'),  C('J'),  C('K'),  C('L'),  NO, 
	NO,      NO,      NO,      C('\\'), C('Z'),  C('X'),  C('C'),  C('V'),
	C('B'),  C('N'),  C('M'),  NO,      NO,      C('/'),  NO,      NO,
	[0x97] KEY_HOME,
	[0xB5] C('/'),		[0xC8] KEY_UP,
	[0xC9] KEY_PGUP,	[0xCB] KEY_LF,
	[0xCD] KEY_RT,		[0xCF] KEY_END,
	[0xD0] KEY_DN,		[0xD1] KEY_PGDN,
	[0xD2] KEY_INS,		[0xD3] KEY_DEL
};

static uint8 *charcode[4] = {
	normalmap,
	shiftmap,
	ctlmap,
	ctlmap
};

/*
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100468:	55                   	push   %ebp
f0100469:	89 e5                	mov    %esp,%ebp
f010046b:	53                   	push   %ebx
f010046c:	83 ec 04             	sub    $0x4,%esp
}

static __inline uint8
inb(int port)
{
f010046f:	ba 64 00 00 00       	mov    $0x64,%edx
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100474:	ec                   	in     (%dx),%al
f0100475:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010047a:	a8 01                	test   $0x1,%al
f010047c:	0f 84 f1 00 00 00    	je     f0100573 <kbd_proc_data+0x10b>
f0100482:	ba 60 00 00 00       	mov    $0x60,%edx
f0100487:	ec                   	in     (%dx),%al
f0100488:	88 c2                	mov    %al,%dl
	int c;
	uint8 data;
	static uint32 shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010048a:	3c e0                	cmp    $0xe0,%al
f010048c:	75 09                	jne    f0100497 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010048e:	83 0d c0 de 19 f0 40 	orl    $0x40,0xf019dec0
		return 0;
f0100495:	eb 2d                	jmp    f01004c4 <kbd_proc_data+0x5c>
	} else if (data & 0x80) {
f0100497:	84 c0                	test   %al,%al
f0100499:	79 33                	jns    f01004ce <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010049b:	f6 05 c0 de 19 f0 40 	testb  $0x40,0xf019dec0
f01004a2:	75 03                	jne    f01004a7 <kbd_proc_data+0x3f>
f01004a4:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01004a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ac:	88 d0                	mov    %dl,%al
f01004ae:	8a 80 20 e0 11 f0    	mov    0xf011e020(%eax),%al
f01004b4:	83 c8 40             	or     $0x40,%eax
f01004b7:	25 ff 00 00 00       	and    $0xff,%eax
f01004bc:	f7 d0                	not    %eax
f01004be:	21 05 c0 de 19 f0    	and    %eax,0xf019dec0
		return 0;
f01004c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01004c9:	e9 a5 00 00 00       	jmp    f0100573 <kbd_proc_data+0x10b>
	} else if (shift & E0ESC) {
f01004ce:	a1 c0 de 19 f0       	mov    0xf019dec0,%eax
f01004d3:	a8 40                	test   $0x40,%al
f01004d5:	74 0b                	je     f01004e2 <kbd_proc_data+0x7a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004d7:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01004da:	83 e0 bf             	and    $0xffffffbf,%eax
f01004dd:	a3 c0 de 19 f0       	mov    %eax,0xf019dec0
	}

	shift |= shiftcode[data];
f01004e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004e7:	88 d1                	mov    %dl,%cl
f01004e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ee:	8a 81 20 e0 11 f0    	mov    0xf011e020(%ecx),%al
f01004f4:	0b 05 c0 de 19 f0    	or     0xf019dec0,%eax
	shift ^= togglecode[data];
f01004fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01004ff:	8a 91 20 e1 11 f0    	mov    0xf011e120(%ecx),%dl
f0100505:	31 c2                	xor    %eax,%edx
f0100507:	89 15 c0 de 19 f0    	mov    %edx,0xf019dec0

	c = charcode[shift & (CTL | SHIFT)][data];
f010050d:	89 d0                	mov    %edx,%eax
f010050f:	83 e0 03             	and    $0x3,%eax
f0100512:	8b 04 85 20 e5 11 f0 	mov    0xf011e520(,%eax,4),%eax
f0100519:	bb 00 00 00 00       	mov    $0x0,%ebx
f010051e:	8a 1c 01             	mov    (%ecx,%eax,1),%bl
	if (shift & CAPSLOCK) {
f0100521:	f6 c2 08             	test   $0x8,%dl
f0100524:	74 18                	je     f010053e <kbd_proc_data+0xd6>
		if ('a' <= c && c <= 'z')
f0100526:	8d 43 9f             	lea    0xffffff9f(%ebx),%eax
f0100529:	83 f8 19             	cmp    $0x19,%eax
f010052c:	77 05                	ja     f0100533 <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f010052e:	83 eb 20             	sub    $0x20,%ebx
f0100531:	eb 0b                	jmp    f010053e <kbd_proc_data+0xd6>
		else if ('A' <= c && c <= 'Z')
f0100533:	8d 43 bf             	lea    0xffffffbf(%ebx),%eax
f0100536:	83 f8 19             	cmp    $0x19,%eax
f0100539:	77 03                	ja     f010053e <kbd_proc_data+0xd6>
			c += 'a' - 'A';
f010053b:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010053e:	a1 c0 de 19 f0       	mov    0xf019dec0,%eax
f0100543:	f7 d0                	not    %eax
f0100545:	a8 06                	test   $0x6,%al
f0100547:	0f 94 c2             	sete   %dl
f010054a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100550:	0f 94 c0             	sete   %al
f0100553:	21 d0                	and    %edx,%eax
f0100555:	a8 01                	test   $0x1,%al
f0100557:	74 18                	je     f0100571 <kbd_proc_data+0x109>
		cprintf("Rebooting!\n");
f0100559:	83 ec 0c             	sub    $0xc,%esp
f010055c:	68 dc 4c 10 f0       	push   $0xf0104cdc
f0100561:	e8 78 2e 00 00       	call   f01033de <cprintf>
}

static __inline void
outb(int port, uint8 data)
{
f0100566:	83 c4 10             	add    $0x10,%esp
f0100569:	ba 92 00 00 00       	mov    $0x92,%edx
f010056e:	b0 03                	mov    $0x3,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100570:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100571:	89 da                	mov    %ebx,%edx
}
f0100573:	89 d0                	mov    %edx,%eax
f0100575:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100578:	c9                   	leave  
f0100579:	c3                   	ret    

f010057a <kbd_intr>:

void
kbd_intr(void)
{
f010057a:	55                   	push   %ebp
f010057b:	89 e5                	mov    %esp,%ebp
f010057d:	83 ec 14             	sub    $0x14,%esp
	cons_intr(kbd_proc_data);
f0100580:	68 68 04 10 f0       	push   $0xf0100468
f0100585:	e8 07 00 00 00       	call   f0100591 <cons_intr>
}
f010058a:	c9                   	leave  
f010058b:	c3                   	ret    

f010058c <kbd_init>:

void
kbd_init(void)
{
f010058c:	55                   	push   %ebp
f010058d:	89 e5                	mov    %esp,%ebp
f010058f:	5d                   	pop    %ebp
f0100590:	c3                   	ret    

f0100591 <cons_intr>:
}



/***** General device-independent console code *****/
// Here we manage the console input buffer,
// where we stash characters received from the keyboard or serial port
// whenever the corresponding interrupt occurs.

#define CONSBUFSIZE 512

static struct {
	uint8 buf[CONSBUFSIZE];
	uint32 rpos;
	uint32 wpos;
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f0100591:	55                   	push   %ebp
f0100592:	89 e5                	mov    %esp,%ebp
f0100594:	53                   	push   %ebx
f0100595:	83 ec 04             	sub    $0x4,%esp
f0100598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010059b:	eb 26                	jmp    f01005c3 <cons_intr+0x32>
		if (c == 0)
f010059d:	85 d2                	test   %edx,%edx
f010059f:	74 22                	je     f01005c3 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f01005a1:	a1 e4 e0 19 f0       	mov    0xf019e0e4,%eax
f01005a6:	88 90 e0 de 19 f0    	mov    %dl,0xf019dee0(%eax)
f01005ac:	40                   	inc    %eax
f01005ad:	a3 e4 e0 19 f0       	mov    %eax,0xf019e0e4
		if (cons.wpos == CONSBUFSIZE)
f01005b2:	3d 00 02 00 00       	cmp    $0x200,%eax
f01005b7:	75 0a                	jne    f01005c3 <cons_intr+0x32>
			cons.wpos = 0;
f01005b9:	c7 05 e4 e0 19 f0 00 	movl   $0x0,0xf019e0e4
f01005c0:	00 00 00 
f01005c3:	ff d3                	call   *%ebx
f01005c5:	89 c2                	mov    %eax,%edx
f01005c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01005ca:	75 d1                	jne    f010059d <cons_intr+0xc>
	}
}
f01005cc:	83 c4 04             	add    $0x4,%esp
f01005cf:	5b                   	pop    %ebx
f01005d0:	5d                   	pop    %ebp
f01005d1:	c3                   	ret    

f01005d2 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005d2:	55                   	push   %ebp
f01005d3:	89 e5                	mov    %esp,%ebp
f01005d5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005d8:	e8 ce fb ff ff       	call   f01001ab <serial_intr>
	kbd_intr();
f01005dd:	e8 98 ff ff ff       	call   f010057a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005e2:	a1 e0 e0 19 f0       	mov    0xf019e0e0,%eax
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01005e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01005ec:	3b 05 e4 e0 19 f0    	cmp    0xf019e0e4,%eax
f01005f2:	74 22                	je     f0100616 <cons_getc+0x44>
f01005f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01005f9:	8a 90 e0 de 19 f0    	mov    0xf019dee0(%eax),%dl
f01005ff:	40                   	inc    %eax
f0100600:	a3 e0 e0 19 f0       	mov    %eax,0xf019e0e0
f0100605:	3d 00 02 00 00       	cmp    $0x200,%eax
f010060a:	75 0a                	jne    f0100616 <cons_getc+0x44>
f010060c:	c7 05 e0 e0 19 f0 00 	movl   $0x0,0xf019e0e0
f0100613:	00 00 00 
}
f0100616:	89 d0                	mov    %edx,%eax
f0100618:	c9                   	leave  
f0100619:	c3                   	ret    

f010061a <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f010061a:	55                   	push   %ebp
f010061b:	89 e5                	mov    %esp,%ebp
f010061d:	53                   	push   %ebx
f010061e:	83 ec 10             	sub    $0x10,%esp
f0100621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	lpt_putc(c);
f0100624:	53                   	push   %ebx
f0100625:	e8 0e fc ff ff       	call   f0100238 <lpt_putc>
	cga_putc(c);
f010062a:	89 1c 24             	mov    %ebx,(%esp)
f010062d:	e8 cd fc ff ff       	call   f01002ff <cga_putc>
}
f0100632:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100635:	c9                   	leave  
f0100636:	c3                   	ret    

f0100637 <console_initialize>:

// initialize the console devices
void
console_initialize(void)
{
f0100637:	55                   	push   %ebp
f0100638:	89 e5                	mov    %esp,%ebp
f010063a:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f010063d:	e8 3c fc ff ff       	call   f010027e <cga_init>
	kbd_init();
f0100642:	e8 45 ff ff ff       	call   f010058c <kbd_init>
	serial_init();
f0100647:	e8 80 fb ff ff       	call   f01001cc <serial_init>

	if (!serial_exists)
f010064c:	83 3d c4 de 19 f0 00 	cmpl   $0x0,0xf019dec4
f0100653:	75 10                	jne    f0100665 <console_initialize+0x2e>
		cprintf("Serial port does not exist!\n");
f0100655:	83 ec 0c             	sub    $0xc,%esp
f0100658:	68 e8 4c 10 f0       	push   $0xf0104ce8
f010065d:	e8 7c 2d 00 00       	call   f01033de <cprintf>
f0100662:	83 c4 10             	add    $0x10,%esp
}
f0100665:	c9                   	leave  
f0100666:	c3                   	ret    

f0100667 <cputchar>:


// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100667:	55                   	push   %ebp
f0100668:	89 e5                	mov    %esp,%ebp
f010066a:	83 ec 14             	sub    $0x14,%esp
	cons_putc(c);
f010066d:	ff 75 08             	pushl  0x8(%ebp)
f0100670:	e8 a5 ff ff ff       	call   f010061a <cons_putc>
}
f0100675:	c9                   	leave  
f0100676:	c3                   	ret    

f0100677 <getchar>:

int
getchar(void)
{
f0100677:	55                   	push   %ebp
f0100678:	89 e5                	mov    %esp,%ebp
f010067a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010067d:	e8 50 ff ff ff       	call   f01005d2 <cons_getc>
f0100682:	85 c0                	test   %eax,%eax
f0100684:	74 f7                	je     f010067d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100686:	c9                   	leave  
f0100687:	c3                   	ret    

f0100688 <iscons>:

int
iscons(int fdnum)
{
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010068b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100690:	5d                   	pop    %ebp
f0100691:	c3                   	ret    
	...

f0100694 <run_command_prompt>:

unsigned read_eip();

//invoke the command prompt
void run_command_prompt() {
f0100694:	55                   	push   %ebp
f0100695:	89 e5                	mov    %esp,%ebp
f0100697:	53                   	push   %ebx
f0100698:	81 ec 04 04 00 00    	sub    $0x404,%esp
	char command_line[1024];

	while (1 == 1) {
f010069e:	8d 9d f8 fb ff ff    	lea    0xfffffbf8(%ebp),%ebx
		//get command line
		readline("FOS> ", command_line);
f01006a4:	83 ec 08             	sub    $0x8,%esp
f01006a7:	53                   	push   %ebx
f01006a8:	68 25 4e 10 f0       	push   $0xf0104e25
f01006ad:	e8 7a 3b 00 00       	call   f010422c <readline>

		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
f01006b2:	89 1c 24             	mov    %ebx,(%esp)
f01006b5:	e8 0c 00 00 00       	call   f01006c6 <execute_command>
f01006ba:	83 c4 10             	add    $0x10,%esp
f01006bd:	85 c0                	test   %eax,%eax
f01006bf:	79 e3                	jns    f01006a4 <run_command_prompt+0x10>
				break;
	}
}
f01006c1:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01006c4:	c9                   	leave  
f01006c5:	c3                   	ret    

f01006c6 <execute_command>:

/***** Kernel command prompt command interpreter *****/

//define the white-space symbols
#define WHITESPACE "\t\r\n "

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string) {
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	56                   	push   %esi
f01006ca:	53                   	push   %ebx
f01006cb:	83 ec 50             	sub    $0x50,%esp
	// Split the command string into whitespace-separated arguments
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];

	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments);
f01006ce:	8d 45 b4             	lea    0xffffffb4(%ebp),%eax
f01006d1:	50                   	push   %eax
f01006d2:	8d 45 b8             	lea    0xffffffb8(%ebp),%eax
f01006d5:	50                   	push   %eax
f01006d6:	68 2b 4e 10 f0       	push   $0xf0104e2b
f01006db:	ff 75 08             	pushl  0x8(%ebp)
f01006de:	e8 79 40 00 00       	call   f010475c <strsplit>
	if (number_of_arguments == 0)
f01006e3:	83 c4 10             	add    $0x10,%esp
f01006e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006eb:	83 7d b4 00          	cmpl   $0x0,0xffffffb4(%ebp)
f01006ef:	74 66                	je     f0100757 <execute_command+0x91>
f01006f1:	eb 07                	jmp    f01006fa <execute_command+0x34>
		return 0;

	// Lookup in the commands array and execute the command
	int command_found = 0;
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++) {
		if (strcmp(arguments[0], commands[i].name) == 0) {
			command_found = 1;
f01006f3:	be 01 00 00 00       	mov    $0x1,%esi
			break;
f01006f8:	eb 2d                	jmp    f0100727 <execute_command+0x61>
f01006fa:	be 00 00 00 00       	mov    $0x0,%esi
f01006ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100704:	83 ec 08             	sub    $0x8,%esp
f0100707:	89 d8                	mov    %ebx,%eax
f0100709:	c1 e0 04             	shl    $0x4,%eax
f010070c:	ff b0 40 e5 11 f0    	pushl  0xf011e540(%eax)
f0100712:	ff 75 b8             	pushl  0xffffffb8(%ebp)
f0100715:	e8 ba 3c 00 00       	call   f01043d4 <strcmp>
f010071a:	83 c4 10             	add    $0x10,%esp
f010071d:	85 c0                	test   %eax,%eax
f010071f:	74 d2                	je     f01006f3 <execute_command+0x2d>
f0100721:	43                   	inc    %ebx
f0100722:	83 fb 19             	cmp    $0x19,%ebx
f0100725:	76 dd                	jbe    f0100704 <execute_command+0x3e>
		}
	}

	if (command_found) {
f0100727:	85 f6                	test   %esi,%esi
f0100729:	74 17                	je     f0100742 <execute_command+0x7c>
		int return_value;
		return_value = commands[i].function_to_execute(number_of_arguments,
f010072b:	83 ec 08             	sub    $0x8,%esp
f010072e:	89 da                	mov    %ebx,%edx
f0100730:	c1 e2 04             	shl    $0x4,%edx
f0100733:	8d 45 b8             	lea    0xffffffb8(%ebp),%eax
f0100736:	50                   	push   %eax
f0100737:	ff 75 b4             	pushl  0xffffffb4(%ebp)
f010073a:	ff 92 48 e5 11 f0    	call   *0xf011e548(%edx)
				arguments);
		return return_value;
f0100740:	eb 15                	jmp    f0100757 <execute_command+0x91>
	} else {
		//if not found, then it's unknown command
		cprintf("Unknown command '%s'\n", arguments[0]);
f0100742:	83 ec 08             	sub    $0x8,%esp
f0100745:	ff 75 b8             	pushl  0xffffffb8(%ebp)
f0100748:	68 30 4e 10 f0       	push   $0xf0104e30
f010074d:	e8 8c 2c 00 00       	call   f01033de <cprintf>
		return 0;
f0100752:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0100757:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010075a:	5b                   	pop    %ebx
f010075b:	5e                   	pop    %esi
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <command_help>:

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments) {
f010075e:	55                   	push   %ebp
f010075f:	89 e5                	mov    %esp,%ebp
f0100761:	53                   	push   %ebx
f0100762:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100765:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
f010076a:	83 ec 04             	sub    $0x4,%esp
f010076d:	89 d8                	mov    %ebx,%eax
f010076f:	c1 e0 04             	shl    $0x4,%eax
f0100772:	ff b0 44 e5 11 f0    	pushl  0xf011e544(%eax)
f0100778:	ff b0 40 e5 11 f0    	pushl  0xf011e540(%eax)
f010077e:	68 46 4e 10 f0       	push   $0xf0104e46
f0100783:	e8 56 2c 00 00       	call   f01033de <cprintf>
f0100788:	83 c4 10             	add    $0x10,%esp
f010078b:	43                   	inc    %ebx
f010078c:	83 fb 19             	cmp    $0x19,%ebx
f010078f:	76 d9                	jbe    f010076a <command_help+0xc>

	cprintf("-------------------\n");
f0100791:	83 ec 0c             	sub    $0xc,%esp
f0100794:	68 4f 4e 10 f0       	push   $0xf0104e4f
f0100799:	e8 40 2c 00 00       	call   f01033de <cprintf>

	return 0;
}
f010079e:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a3:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01007a6:	c9                   	leave  
f01007a7:	c3                   	ret    

f01007a8 <command_kernel_info>:

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments) {
f01007a8:	55                   	push   %ebp
f01007a9:	89 e5                	mov    %esp,%ebp
f01007ab:	83 ec 14             	sub    $0x14,%esp
	extern char start_of_kernel[], end_of_kernel_code_section[],
	start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
f01007ae:	68 64 4e 10 f0       	push   $0xf0104e64
f01007b3:	e8 26 2c 00 00       	call   f01033de <cprintf>
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n",
f01007b8:	83 c4 0c             	add    $0xc,%esp
f01007bb:	68 0c 00 10 00       	push   $0x10000c
f01007c0:	68 0c 00 10 f0       	push   $0xf010000c
f01007c5:	68 c0 51 10 f0       	push   $0xf01051c0
f01007ca:	e8 0f 2c 00 00       	call   f01033de <cprintf>
			start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n",
f01007cf:	83 c4 0c             	add    $0xc,%esp
f01007d2:	68 20 4b 10 00       	push   $0x104b20
f01007d7:	68 20 4b 10 f0       	push   $0xf0104b20
f01007dc:	68 00 52 10 f0       	push   $0xf0105200
f01007e1:	e8 f8 2b 00 00       	call   f01033de <cprintf>
			end_of_kernel_code_section, end_of_kernel_code_section
			- KERNEL_BASE);
	cprintf(
f01007e6:	83 c4 0c             	add    $0xc,%esp
f01007e9:	68 86 de 19 00       	push   $0x19de86
f01007ee:	68 86 de 19 f0       	push   $0xf019de86
f01007f3:	68 40 52 10 f0       	push   $0xf0105240
f01007f8:	e8 e1 2b 00 00       	call   f01033de <cprintf>
			"  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n",
			start_of_uninitialized_data_section,
			start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n",
f01007fd:	83 c4 0c             	add    $0xc,%esp
f0100800:	68 90 e9 19 00       	push   $0x19e990
f0100805:	68 90 e9 19 f0       	push   $0xf019e990
f010080a:	68 a0 52 10 f0       	push   $0xf01052a0
f010080f:	e8 ca 2b 00 00       	call   f01033de <cprintf>
			end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n", (end_of_kernel
f0100814:	83 c4 08             	add    $0x8,%esp
f0100817:	b8 8f ed 19 f0       	mov    $0xf019ed8f,%eax
f010081c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100821:	79 05                	jns    f0100828 <command_kernel_info+0x80>
f0100823:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100828:	c1 f8 0a             	sar    $0xa,%eax
f010082b:	50                   	push   %eax
f010082c:	68 e0 52 10 f0       	push   $0xf01052e0
f0100831:	e8 a8 2b 00 00       	call   f01033de <cprintf>
			- start_of_kernel + 1023) / 1024);
	return 0;
}
f0100836:	b8 00 00 00 00       	mov    $0x0,%eax
f010083b:	c9                   	leave  
f010083c:	c3                   	ret    

f010083d <command_writemem>:

int command_writemem(int number_of_arguments, char **arguments) {
f010083d:	55                   	push   %ebp
f010083e:	89 e5                	mov    %esp,%ebp
f0100840:	57                   	push   %edi
f0100841:	56                   	push   %esi
f0100842:	53                   	push   %ebx
f0100843:	83 ec 10             	sub    $0x10,%esp
f0100846:	8b 75 0c             	mov    0xc(%ebp),%esi
	char* user_program_name = arguments[1];
f0100849:	8b 5e 04             	mov    0x4(%esi),%ebx
	int address = strtol(arguments[3], NULL, 16);
f010084c:	6a 10                	push   $0x10
f010084e:	6a 00                	push   $0x0
f0100850:	ff 76 0c             	pushl  0xc(%esi)
f0100853:	e8 2a 3d 00 00       	call   f0104582 <strtol>
f0100858:	89 c7                	mov    %eax,%edi

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
f010085a:	89 1c 24             	mov    %ebx,(%esp)
f010085d:	e8 41 29 00 00       	call   f01031a3 <get_user_program_info>
			user_program_name);
	if (ptr_user_program_info == NULL)
f0100862:	83 c4 10             	add    $0x10,%esp
f0100865:	ba 00 00 00 00       	mov    $0x0,%edx
f010086a:	85 c0                	test   %eax,%eax
f010086c:	74 3c                	je     f01008aa <command_writemem+0x6d>
}

static __inline uint32
rcr3(void)
{
f010086e:	0f 20 da             	mov    %cr3,%edx
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f0100871:	8b 40 0c             	mov    0xc(%eax),%eax
f0100874:	8b 40 5c             	mov    0x5c(%eax),%eax
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
	return val;
}
f0100877:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010087c:	77 15                	ja     f0100893 <command_writemem+0x56>
f010087e:	50                   	push   %eax
f010087f:	68 20 53 10 f0       	push   $0xf0105320
f0100884:	68 b8 00 00 00       	push   $0xb8
f0100889:	68 7d 4e 10 f0       	push   $0xf0104e7d
f010088e:	e8 6b f8 ff ff       	call   f01000fe <_panic>
f0100893:	05 00 00 00 10       	add    $0x10000000,%eax

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100898:	0f 22 d8             	mov    %eax,%cr3

	unsigned char *ptr = (unsigned char *) (address);

	//Write the given Character
	*ptr = arguments[2][0];
f010089b:	8b 46 08             	mov    0x8(%esi),%eax
f010089e:	8a 00                	mov    (%eax),%al
f01008a0:	88 07                	mov    %al,(%edi)

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01008a2:	0f 22 da             	mov    %edx,%cr3
	lcr3(oldDir);

	return 0;
f01008a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01008aa:	89 d0                	mov    %edx,%eax
f01008ac:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01008af:	5b                   	pop    %ebx
f01008b0:	5e                   	pop    %esi
f01008b1:	5f                   	pop    %edi
f01008b2:	5d                   	pop    %ebp
f01008b3:	c3                   	ret    

f01008b4 <command_readmem>:

int command_readmem(int number_of_arguments, char **arguments) {
f01008b4:	55                   	push   %ebp
f01008b5:	89 e5                	mov    %esp,%ebp
f01008b7:	56                   	push   %esi
f01008b8:	53                   	push   %ebx
f01008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	char* user_program_name = arguments[1];
f01008bc:	8b 58 04             	mov    0x4(%eax),%ebx
	int address = strtol(arguments[2], NULL, 16);
f01008bf:	83 ec 04             	sub    $0x4,%esp
f01008c2:	6a 10                	push   $0x10
f01008c4:	6a 00                	push   $0x0
f01008c6:	ff 70 08             	pushl  0x8(%eax)
f01008c9:	e8 b4 3c 00 00       	call   f0104582 <strtol>
f01008ce:	89 c6                	mov    %eax,%esi

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
f01008d0:	89 1c 24             	mov    %ebx,(%esp)
f01008d3:	e8 cb 28 00 00       	call   f01031a3 <get_user_program_info>
			user_program_name);
	if (ptr_user_program_info == NULL)
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	ba 00 00 00 00       	mov    $0x0,%edx
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	74 4e                	je     f0100932 <command_readmem+0x7e>
}

static __inline uint32
rcr3(void)
{
f01008e4:	0f 20 db             	mov    %cr3,%ebx
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f01008e7:	8b 40 0c             	mov    0xc(%eax),%eax
f01008ea:	8b 40 5c             	mov    0x5c(%eax),%eax
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
}

static __inline uint32
f01008ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01008f2:	77 15                	ja     f0100909 <command_readmem+0x55>
f01008f4:	50                   	push   %eax
f01008f5:	68 20 53 10 f0       	push   $0xf0105320
f01008fa:	68 ce 00 00 00       	push   $0xce
f01008ff:	68 7d 4e 10 f0       	push   $0xf0104e7d
f0100904:	e8 f5 f7 ff ff       	call   f01000fe <_panic>
f0100909:	05 00 00 00 10       	add    $0x10000000,%eax
f010090e:	0f 22 d8             	mov    %eax,%cr3

	unsigned char *ptr = (unsigned char *) (address);

	//Write the given Character
	cprintf("value at address %x = %c\n", address, *ptr);
f0100911:	83 ec 04             	sub    $0x4,%esp
f0100914:	b8 00 00 00 00       	mov    $0x0,%eax
f0100919:	8a 06                	mov    (%esi),%al
f010091b:	50                   	push   %eax
f010091c:	56                   	push   %esi
f010091d:	68 93 4e 10 f0       	push   $0xf0104e93
f0100922:	e8 b7 2a 00 00       	call   f01033de <cprintf>
}

static __inline void
lcr3(uint32 val)
{
f0100927:	83 c4 10             	add    $0x10,%esp
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010092a:	0f 22 db             	mov    %ebx,%cr3

	lcr3(oldDir);
	return 0;
f010092d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100932:	89 d0                	mov    %edx,%eax
f0100934:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100937:	5b                   	pop    %ebx
f0100938:	5e                   	pop    %esi
f0100939:	5d                   	pop    %ebp
f010093a:	c3                   	ret    

f010093b <command_readblock>:

int command_readblock(int number_of_arguments, char **arguments) {
f010093b:	55                   	push   %ebp
f010093c:	89 e5                	mov    %esp,%ebp
f010093e:	57                   	push   %edi
f010093f:	56                   	push   %esi
f0100940:	53                   	push   %ebx
f0100941:	83 ec 10             	sub    $0x10,%esp
f0100944:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char* user_program_name = arguments[1];
f0100947:	8b 43 04             	mov    0x4(%ebx),%eax
f010094a:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	int address = strtol(arguments[2], NULL, 16);
f010094d:	6a 10                	push   $0x10
f010094f:	6a 00                	push   $0x0
f0100951:	ff 73 08             	pushl  0x8(%ebx)
f0100954:	e8 29 3c 00 00       	call   f0104582 <strtol>
f0100959:	89 c6                	mov    %eax,%esi
	int nBytes = strtol(arguments[3], NULL, 10);
f010095b:	83 c4 0c             	add    $0xc,%esp
f010095e:	6a 0a                	push   $0xa
f0100960:	6a 00                	push   $0x0
f0100962:	ff 73 0c             	pushl  0xc(%ebx)
f0100965:	e8 18 3c 00 00       	call   f0104582 <strtol>
f010096a:	89 c7                	mov    %eax,%edi

	unsigned char *ptr = (unsigned char *) (address);
f010096c:	89 f3                	mov    %esi,%ebx
	//Write the given Character

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
f010096e:	83 c4 04             	add    $0x4,%esp
f0100971:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0100974:	e8 2a 28 00 00       	call   f01031a3 <get_user_program_info>
			user_program_name);
	if (ptr_user_program_info == NULL)
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100981:	85 c0                	test   %eax,%eax
f0100983:	74 68                	je     f01009ed <command_readblock+0xb2>
}

static __inline uint32
rcr3(void)
{
f0100985:	0f 20 da             	mov    %cr3,%edx
f0100988:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f010098b:	8b 40 0c             	mov    0xc(%eax),%eax
f010098e:	8b 40 5c             	mov    0x5c(%eax),%eax
}

static __inline void
write_eflags(uint32 eflags)
{
f0100991:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100996:	77 15                	ja     f01009ad <command_readblock+0x72>
f0100998:	50                   	push   %eax
f0100999:	68 20 53 10 f0       	push   $0xf0105320
f010099e:	68 e8 00 00 00       	push   $0xe8
f01009a3:	68 7d 4e 10 f0       	push   $0xf0104e7d
f01009a8:	e8 51 f7 ff ff       	call   f01000fe <_panic>
f01009ad:	05 00 00 00 10       	add    $0x10000000,%eax
f01009b2:	0f 22 d8             	mov    %eax,%cr3

	int i;
	for (i = 0; i < nBytes; i++) {
f01009b5:	be 00 00 00 00       	mov    $0x0,%esi
f01009ba:	39 fe                	cmp    %edi,%esi
f01009bc:	7d 24                	jge    f01009e2 <command_readblock+0xa7>
		cprintf("%08x : %02x  %c\n", ptr, *ptr, *ptr);
f01009be:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c3:	8a 03                	mov    (%ebx),%al
f01009c5:	50                   	push   %eax
f01009c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009cb:	8a 03                	mov    (%ebx),%al
f01009cd:	50                   	push   %eax
f01009ce:	53                   	push   %ebx
f01009cf:	68 ad 4e 10 f0       	push   $0xf0104ead
f01009d4:	e8 05 2a 00 00       	call   f01033de <cprintf>
		ptr++;
f01009d9:	43                   	inc    %ebx
f01009da:	83 c4 10             	add    $0x10,%esp
f01009dd:	46                   	inc    %esi
f01009de:	39 fe                	cmp    %edi,%esi
f01009e0:	7c dc                	jl     f01009be <command_readblock+0x83>

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01009e2:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01009e5:	0f 22 d8             	mov    %eax,%cr3
	}
	lcr3(oldDir);

	return 0;
f01009e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01009ed:	89 d0                	mov    %edx,%eax
f01009ef:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01009f2:	5b                   	pop    %ebx
f01009f3:	5e                   	pop    %esi
f01009f4:	5f                   	pop    %edi
f01009f5:	5d                   	pop    %ebp
f01009f6:	c3                   	ret    

f01009f7 <command_allocpage>:

int command_allocpage(int number_of_arguments, char **arguments) {
f01009f7:	55                   	push   %ebp
f01009f8:	89 e5                	mov    %esp,%ebp
f01009fa:	53                   	push   %ebx
f01009fb:	83 ec 08             	sub    $0x8,%esp
	unsigned int address = strtol(arguments[1], NULL, 16);
f01009fe:	6a 10                	push   $0x10
f0100a00:	6a 00                	push   $0x0
f0100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a05:	ff 70 04             	pushl  0x4(%eax)
f0100a08:	e8 75 3b 00 00       	call   f0104582 <strtol>
f0100a0d:	89 c3                	mov    %eax,%ebx
	unsigned char *ptr = (unsigned char *) (address);

	struct Frame_Info * ptr_frame_info;
	allocate_frame(&ptr_frame_info);
f0100a0f:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0100a12:	89 04 24             	mov    %eax,(%esp)
f0100a15:	e8 f4 1b 00 00       	call   f010260e <allocate_frame>

	map_frame(ptr_page_directory, ptr_frame_info, ptr, PERM_WRITEABLE
f0100a1a:	6a 06                	push   $0x6
f0100a1c:	53                   	push   %ebx
f0100a1d:	ff 75 f8             	pushl  0xfffffff8(%ebp)
f0100a20:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100a26:	e8 84 1d 00 00       	call   f01027af <map_frame>
			| PERM_USER);

	return 0;
}
f0100a2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a30:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100a33:	c9                   	leave  
f0100a34:	c3                   	ret    

f0100a35 <command_free_page>:

int command_free_page(int number_of_arguments, char **arguments) {
f0100a35:	55                   	push   %ebp
f0100a36:	89 e5                	mov    %esp,%ebp
f0100a38:	83 ec 0c             	sub    $0xc,%esp
	uint32 address = strtol(arguments[1], NULL, 16);
f0100a3b:	6a 10                	push   $0x10
f0100a3d:	6a 00                	push   $0x0
f0100a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a42:	ff 70 04             	pushl  0x4(%eax)
f0100a45:	e8 38 3b 00 00       	call   f0104582 <strtol>
	unsigned char *va = (unsigned char *) (address);
	// Un-map the page at this address
	unmap_frame(ptr_page_directory, va);
f0100a4a:	83 c4 08             	add    $0x8,%esp
f0100a4d:	50                   	push   %eax
f0100a4e:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100a54:	e8 83 1e 00 00       	call   f01028dc <unmap_frame>
	return 0;
}
f0100a59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a5e:	c9                   	leave  
f0100a5f:	c3                   	ret    

f0100a60 <command_free_table>:

int command_free_table(int number_of_arguments, char **arguments) {
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
f0100a63:	53                   	push   %ebx
f0100a64:	83 ec 08             	sub    $0x8,%esp
	uint32 address = strtol(arguments[1], NULL, 16);
f0100a67:	6a 10                	push   $0x10
f0100a69:	6a 00                	push   $0x0
f0100a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a6e:	ff 70 04             	pushl  0x4(%eax)
f0100a71:	e8 0c 3b 00 00       	call   f0104582 <strtol>
f0100a76:	89 c3                	mov    %eax,%ebx
	unsigned char *va = (unsigned char *) (address);
	uint32 * ptr_page_table;
	// get the page table of the given virtual address
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
f0100a78:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0100a7b:	50                   	push   %eax
f0100a7c:	6a 00                	push   $0x0
f0100a7e:	53                   	push   %ebx
f0100a7f:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100a85:	e8 11 1c 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table == NULL)
f0100a8a:	83 c4 20             	add    $0x20,%esp
f0100a8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a92:	83 7d f8 00          	cmpl   $0x0,0xfffffff8(%ebp)
f0100a96:	74 79                	je     f0100b11 <command_free_table+0xb1>
		return 0;
	// get the physical address and Frame_Info of the page table
	uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table);
f0100a98:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0100a9b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100aa0:	77 12                	ja     f0100ab4 <command_free_table+0x54>
f0100aa2:	50                   	push   %eax
f0100aa3:	68 20 53 10 f0       	push   $0xf0105320
f0100aa8:	68 12 01 00 00       	push   $0x112
f0100aad:	68 7d 4e 10 f0       	push   $0xf0104e7d
f0100ab2:	eb 22                	jmp    f0100ad6 <command_free_table+0x76>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0100ab4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	if (PPN(physical_address) >= number_of_frames)
f0100aba:	89 d0                	mov    %edx,%eax
f0100abc:	c1 e8 0c             	shr    $0xc,%eax
f0100abf:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f0100ac5:	72 14                	jb     f0100adb <command_free_table+0x7b>
		panic("to_frame_info called with invalid pa");
f0100ac7:	83 ec 04             	sub    $0x4,%esp
f0100aca:	68 60 53 10 f0       	push   $0xf0105360
f0100acf:	6a 39                	push   $0x39
f0100ad1:	68 be 4e 10 f0       	push   $0xf0104ebe
f0100ad6:	e8 23 f6 ff ff       	call   f01000fe <_panic>
f0100adb:	89 d0                	mov    %edx,%eax
f0100add:	c1 e8 0c             	shr    $0xc,%eax
f0100ae0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ae3:	8b 15 7c e9 19 f0    	mov    0xf019e97c,%edx
f0100ae9:	8d 04 82             	lea    (%edx,%eax,4),%eax
	struct Frame_Info *table_frame_info = to_frame_info(table_pa);
	// set references of the table frame to 0 then free it by adding
	// to the free frame list
	table_frame_info->references = 0;
f0100aec:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	free_frame(table_frame_info);
f0100af2:	83 ec 0c             	sub    $0xc,%esp
f0100af5:	50                   	push   %eax
f0100af6:	e8 56 1b 00 00       	call   f0102651 <free_frame>
	// set the corresponding entry in the directory to 0
	uint32 dir_index = PDX(va);
f0100afb:	89 da                	mov    %ebx,%edx
f0100afd:	c1 ea 16             	shr    $0x16,%edx
	ptr_page_directory[dir_index] = 0;
f0100b00:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0100b05:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	return 0;
f0100b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b11:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100b14:	c9                   	leave  
f0100b15:	c3                   	ret    

f0100b16 <command_readusermem>:

int command_readusermem(int number_of_arguments, char **arguments) {
f0100b16:	55                   	push   %ebp
f0100b17:	89 e5                	mov    %esp,%ebp
f0100b19:	83 ec 0c             	sub    $0xc,%esp
	unsigned int address = strtol(arguments[1], NULL, 16);
f0100b1c:	6a 10                	push   $0x10
f0100b1e:	6a 00                	push   $0x0
f0100b20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b23:	ff 70 04             	pushl  0x4(%eax)
f0100b26:	e8 57 3a 00 00       	call   f0104582 <strtol>
	unsigned char *ptr = (unsigned char *) (address);

	cprintf("value at address %x = %c\n", ptr, *ptr);
f0100b2b:	83 c4 0c             	add    $0xc,%esp
f0100b2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b33:	8a 10                	mov    (%eax),%dl
f0100b35:	52                   	push   %edx
f0100b36:	50                   	push   %eax
f0100b37:	68 93 4e 10 f0       	push   $0xf0104e93
f0100b3c:	e8 9d 28 00 00       	call   f01033de <cprintf>

	return 0;
}
f0100b41:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b46:	c9                   	leave  
f0100b47:	c3                   	ret    

f0100b48 <command_writeusermem>:

int command_writeusermem(int number_of_arguments, char **arguments) {
f0100b48:	55                   	push   %ebp
f0100b49:	89 e5                	mov    %esp,%ebp
f0100b4b:	53                   	push   %ebx
f0100b4c:	83 ec 08             	sub    $0x8,%esp
f0100b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int address = strtol(arguments[1], NULL, 16);
f0100b52:	6a 10                	push   $0x10
f0100b54:	6a 00                	push   $0x0
f0100b56:	ff 73 04             	pushl  0x4(%ebx)
f0100b59:	e8 24 3a 00 00       	call   f0104582 <strtol>
	unsigned char *ptr = (unsigned char *) (address);
	*ptr = arguments[2][0];
f0100b5e:	8b 53 08             	mov    0x8(%ebx),%edx
f0100b61:	8a 12                	mov    (%edx),%dl
f0100b63:	88 10                	mov    %dl,(%eax)

	return 0;
}
f0100b65:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b6a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100b6d:	c9                   	leave  
f0100b6e:	c3                   	ret    

f0100b6f <command_meminfo>:

int command_meminfo(int number_of_arguments, char **arguments) {
f0100b6f:	55                   	push   %ebp
f0100b70:	89 e5                	mov    %esp,%ebp
f0100b72:	53                   	push   %ebx
f0100b73:	83 ec 14             	sub    $0x14,%esp
	cprintf("Free frames = %d\n", calculate_free_frames());
f0100b76:	e8 e6 1d 00 00       	call   f0102961 <calculate_free_frames>
f0100b7b:	83 c4 08             	add    $0x8,%esp
f0100b7e:	50                   	push   %eax
f0100b7f:	68 d4 4e 10 f0       	push   $0xf0104ed4
f0100b84:	e8 55 28 00 00       	call   f01033de <cprintf>
	struct UserProgramInfo* temp = running;
f0100b89:	8b 1d ec e0 19 f0    	mov    0xf019e0ec,%ebx
	cprintf("Program Name\tEnv ID\tMain Size (KB)\tTables Size (KB)\n");
f0100b8f:	c7 04 24 a0 53 10 f0 	movl   $0xf01053a0,(%esp)
f0100b96:	e8 43 28 00 00       	call   f01033de <cprintf>
	while( temp != NULL )
f0100b9b:	83 c4 10             	add    $0x10,%esp
f0100b9e:	85 db                	test   %ebx,%ebx
f0100ba0:	74 22                	je     f0100bc4 <command_meminfo+0x55>
	{
		cprintf("%s\t%d\t%u\t%u\n",temp->name, temp->envID,temp->mainS, temp->tableS);
f0100ba2:	83 ec 0c             	sub    $0xc,%esp
f0100ba5:	ff 73 18             	pushl  0x18(%ebx)
f0100ba8:	ff 73 14             	pushl  0x14(%ebx)
f0100bab:	ff 73 20             	pushl  0x20(%ebx)
f0100bae:	ff 33                	pushl  (%ebx)
f0100bb0:	68 e6 4e 10 f0       	push   $0xf0104ee6
f0100bb5:	e8 24 28 00 00       	call   f01033de <cprintf>
		temp = temp->next;
f0100bba:	8b 5b 1c             	mov    0x1c(%ebx),%ebx
f0100bbd:	83 c4 20             	add    $0x20,%esp
f0100bc0:	85 db                	test   %ebx,%ebx
f0100bc2:	75 de                	jne    f0100ba2 <command_meminfo+0x33>
	}
	return 0;
}
f0100bc4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc9:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100bcc:	c9                   	leave  
f0100bcd:	c3                   	ret    

f0100bce <command_show_mapping>:

int command_show_mapping(int number_of_arguments, char **arguments) {
f0100bce:	55                   	push   %ebp
f0100bcf:	89 e5                	mov    %esp,%ebp
f0100bd1:	53                   	push   %ebx
f0100bd2:	83 ec 08             	sub    $0x8,%esp
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f0100bd5:	6a 10                	push   $0x10
f0100bd7:	6a 00                	push   $0x0
f0100bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdc:	ff 70 04             	pushl  0x4(%eax)
f0100bdf:	e8 9e 39 00 00       	call   f0104582 <strtol>
f0100be4:	89 c3                	mov    %eax,%ebx
	uint32 *ptr_page_table = NULL;
f0100be6:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
f0100bed:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f0100bf0:	50                   	push   %eax
f0100bf1:	6a 00                	push   $0x0
f0100bf3:	53                   	push   %ebx
f0100bf4:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100bfa:	e8 9c 1a 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table != NULL) {
f0100bff:	83 c4 20             	add    $0x20,%esp
f0100c02:	83 7d f8 00          	cmpl   $0x0,0xfffffff8(%ebp)
f0100c06:	74 29                	je     f0100c31 <command_show_mapping+0x63>
		int dir_index = PDX(va);
f0100c08:	89 d9                	mov    %ebx,%ecx
f0100c0a:	c1 e9 16             	shr    $0x16,%ecx
		int table_index = PTX(va);
f0100c0d:	89 da                	mov    %ebx,%edx
f0100c0f:	c1 ea 0c             	shr    $0xc,%edx
f0100c12:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
		uint32 fn = ptr_page_table[table_index] >> 12;
f0100c18:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f0100c1b:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100c1e:	c1 e8 0c             	shr    $0xc,%eax
		cprintf("DIR Index = %d\nTable Index = %d\nFrame Number = %0d\n",
f0100c21:	50                   	push   %eax
f0100c22:	52                   	push   %edx
f0100c23:	51                   	push   %ecx
f0100c24:	68 e0 53 10 f0       	push   $0xf01053e0
f0100c29:	e8 b0 27 00 00       	call   f01033de <cprintf>
f0100c2e:	83 c4 10             	add    $0x10,%esp
				dir_index, table_index, fn);

	}
	return 0;
}
f0100c31:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c36:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100c39:	c9                   	leave  
f0100c3a:	c3                   	ret    

f0100c3b <command_set_permission>:
int command_set_permission(int number_of_arguments, char **arguments) {
f0100c3b:	55                   	push   %ebp
f0100c3c:	89 e5                	mov    %esp,%ebp
f0100c3e:	56                   	push   %esi
f0100c3f:	53                   	push   %ebx
f0100c40:	83 ec 14             	sub    $0x14,%esp
f0100c43:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f0100c46:	6a 10                	push   $0x10
f0100c48:	6a 00                	push   $0x0
f0100c4a:	ff 76 04             	pushl  0x4(%esi)
f0100c4d:	e8 30 39 00 00       	call   f0104582 <strtol>
f0100c52:	89 c3                	mov    %eax,%ebx
	uint32 *ptr_page_table = NULL;
f0100c54:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
f0100c5b:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	6a 00                	push   $0x0
f0100c61:	53                   	push   %ebx
f0100c62:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100c68:	e8 2e 1a 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table != NULL) {
f0100c6d:	83 c4 20             	add    $0x20,%esp
f0100c70:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100c74:	74 55                	je     f0100ccb <command_set_permission+0x90>
		char perm = arguments[2][0];
f0100c76:	8b 46 08             	mov    0x8(%esi),%eax
f0100c79:	8a 00                	mov    (%eax),%al
		int table_index = PTX(va);
f0100c7b:	c1 eb 0c             	shr    $0xc,%ebx
f0100c7e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx

		if (perm == 'r') {
f0100c84:	3c 72                	cmp    $0x72,%al
f0100c86:	75 09                	jne    f0100c91 <command_set_permission+0x56>
			ptr_page_table[table_index] &= (~PERM_WRITEABLE);
f0100c88:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100c8b:	83 24 98 fd          	andl   $0xfffffffd,(%eax,%ebx,4)
f0100c8f:	eb 34                	jmp    f0100cc5 <command_set_permission+0x8a>
		} else if (perm == 'w') {
f0100c91:	3c 77                	cmp    $0x77,%al
f0100c93:	75 30                	jne    f0100cc5 <command_set_permission+0x8a>
			cprintf("%x\n", ptr_page_table[table_index]);
f0100c95:	83 ec 08             	sub    $0x8,%esp
f0100c98:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100c9b:	ff 34 98             	pushl  (%eax,%ebx,4)
f0100c9e:	68 f3 4e 10 f0       	push   $0xf0104ef3
f0100ca3:	e8 36 27 00 00       	call   f01033de <cprintf>
			ptr_page_table[table_index] |= (PERM_WRITEABLE);
f0100ca8:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100cab:	83 0c 98 02          	orl    $0x2,(%eax,%ebx,4)
			cprintf("%x\n", ptr_page_table[table_index]);
f0100caf:	83 c4 08             	add    $0x8,%esp
f0100cb2:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100cb5:	ff 34 98             	pushl  (%eax,%ebx,4)
f0100cb8:	68 f3 4e 10 f0       	push   $0xf0104ef3
f0100cbd:	e8 1c 27 00 00       	call   f01033de <cprintf>
f0100cc2:	83 c4 10             	add    $0x10,%esp
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f0100cc5:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0100cc8:	0f 22 d8             	mov    %eax,%cr3
		}
		//tlb_invalidate(ptr_page_directory, va); // delete the cache of the given address
		tlbflush(); // delete the whole cache
	}

	return 0;
}
f0100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cd0:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100cd3:	5b                   	pop    %ebx
f0100cd4:	5e                   	pop    %esi
f0100cd5:	5d                   	pop    %ebp
f0100cd6:	c3                   	ret    

f0100cd7 <command_share_pa>:

int command_share_pa(int number_of_arguments, char **arguments) {
f0100cd7:	55                   	push   %ebp
f0100cd8:	89 e5                	mov    %esp,%ebp
f0100cda:	56                   	push   %esi
f0100cdb:	53                   	push   %ebx
f0100cdc:	83 ec 14             	sub    $0x14,%esp
f0100cdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
f0100ce2:	6a 10                	push   $0x10
f0100ce4:	6a 00                	push   $0x0
f0100ce6:	ff 73 04             	pushl  0x4(%ebx)
f0100ce9:	e8 94 38 00 00       	call   f0104582 <strtol>
f0100cee:	89 c6                	mov    %eax,%esi
	uint32 *ptr_page_table1 = NULL;
f0100cf0:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
f0100cf7:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100cfa:	50                   	push   %eax
f0100cfb:	6a 00                	push   $0x0
f0100cfd:	56                   	push   %esi
f0100cfe:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100d04:	e8 92 19 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table1 != NULL) {
f0100d09:	83 c4 20             	add    $0x20,%esp
f0100d0c:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100d10:	74 50                	je     f0100d62 <command_share_pa+0x8b>
		uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
f0100d12:	83 ec 04             	sub    $0x4,%esp
f0100d15:	6a 10                	push   $0x10
f0100d17:	6a 00                	push   $0x0
f0100d19:	ff 73 08             	pushl  0x8(%ebx)
f0100d1c:	e8 61 38 00 00       	call   f0104582 <strtol>
f0100d21:	89 c3                	mov    %eax,%ebx
		uint32 *ptr_page_table2 = NULL;
f0100d23:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
f0100d2a:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100d2d:	50                   	push   %eax
f0100d2e:	6a 01                	push   $0x1
f0100d30:	53                   	push   %ebx
f0100d31:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100d37:	e8 5f 19 00 00       	call   f010269b <get_page_table>
		ptr_page_table2[PTX(va2)] = ptr_page_table1[PTX(va1)];
f0100d3c:	89 d8                	mov    %ebx,%eax
f0100d3e:	c1 e8 0c             	shr    $0xc,%eax
f0100d41:	89 c1                	mov    %eax,%ecx
f0100d43:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0100d49:	89 f0                	mov    %esi,%eax
f0100d4b:	c1 e8 0c             	shr    $0xc,%eax
f0100d4e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100d53:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0100d56:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0100d59:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100d5c:	89 14 88             	mov    %edx,(%eax,%ecx,4)
f0100d5f:	83 c4 20             	add    $0x20,%esp
	}
	return 0;
}
f0100d62:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d67:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100d6a:	5b                   	pop    %ebx
f0100d6b:	5e                   	pop    %esi
f0100d6c:	5d                   	pop    %ebp
f0100d6d:	c3                   	ret    

f0100d6e <connect_va>:
int connect_va(int number_of_arguments, char **arguments) {
f0100d6e:	55                   	push   %ebp
f0100d6f:	89 e5                	mov    %esp,%ebp
f0100d71:	57                   	push   %edi
f0100d72:	56                   	push   %esi
f0100d73:	53                   	push   %ebx
f0100d74:	83 ec 10             	sub    $0x10,%esp
f0100d77:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f0100d7a:	6a 10                	push   $0x10
f0100d7c:	6a 00                	push   $0x0
f0100d7e:	ff 76 04             	pushl  0x4(%esi)
f0100d81:	e8 fc 37 00 00       	call   f0104582 <strtol>
f0100d86:	89 c3                	mov    %eax,%ebx
	uint32 pa = strtoul(arguments[2], NULL, 16);
f0100d88:	83 c4 0c             	add    $0xc,%esp
f0100d8b:	6a 10                	push   $0x10
f0100d8d:	6a 00                	push   $0x0
f0100d8f:	ff 76 08             	pushl  0x8(%esi)
f0100d92:	e8 d8 38 00 00       	call   f010466f <strtoul>
f0100d97:	89 c7                	mov    %eax,%edi
	uint32 *ptr_page_table = NULL;
f0100d99:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	get_page_table(ptr_page_directory, va, 1, &ptr_page_table);
f0100da0:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100da3:	50                   	push   %eax
f0100da4:	6a 01                	push   $0x1
f0100da6:	53                   	push   %ebx
f0100da7:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100dad:	e8 e9 18 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table != NULL) {
f0100db2:	83 c4 20             	add    $0x20,%esp
f0100db5:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0100db9:	74 3a                	je     f0100df5 <connect_va+0x87>
		ptr_page_table[PTX(va)] = pa;
f0100dbb:	89 d8                	mov    %ebx,%eax
f0100dbd:	c1 e8 0c             	shr    $0xc,%eax
f0100dc0:	89 c2                	mov    %eax,%edx
f0100dc2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100dc8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100dcb:	89 3c 90             	mov    %edi,(%eax,%edx,4)
		char c = arguments[3][0];
f0100dce:	8b 46 0c             	mov    0xc(%esi),%eax
f0100dd1:	8a 00                	mov    (%eax),%al
		if (c == 'r')
f0100dd3:	3c 72                	cmp    $0x72,%al
f0100dd5:	75 09                	jne    f0100de0 <connect_va+0x72>
			ptr_page_table[PTX(va)] &= (~PERM_WRITEABLE);
f0100dd7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100dda:	83 24 90 fd          	andl   $0xfffffffd,(%eax,%edx,4)
f0100dde:	eb 15                	jmp    f0100df5 <connect_va+0x87>
		else if (c == 'w')
f0100de0:	3c 77                	cmp    $0x77,%al
f0100de2:	75 11                	jne    f0100df5 <connect_va+0x87>
			ptr_page_table[PTX(va)] |= (PERM_WRITEABLE);
f0100de4:	89 d8                	mov    %ebx,%eax
f0100de6:	c1 e8 0c             	shr    $0xc,%eax
f0100de9:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100dee:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0100df1:	83 0c 82 02          	orl    $0x2,(%edx,%eax,4)
	}
	ptr_page_table[PTX(va)] |= PERM_PRESENT;
f0100df5:	89 d8                	mov    %ebx,%eax
f0100df7:	c1 e8 0c             	shr    $0xc,%eax
f0100dfa:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100dff:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0100e02:	83 0c 82 01          	orl    $0x1,(%edx,%eax,4)
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f0100e06:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0100e09:	0f 22 d8             	mov    %eax,%cr3
	tlbflush();
	return 0;
}
f0100e0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e11:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100e14:	5b                   	pop    %ebx
f0100e15:	5e                   	pop    %esi
f0100e16:	5f                   	pop    %edi
f0100e17:	5d                   	pop    %ebp
f0100e18:	c3                   	ret    

f0100e19 <show_mappings>:

int show_mappings(int number_of_arguments, char **arguments) {
f0100e19:	55                   	push   %ebp
f0100e1a:	89 e5                	mov    %esp,%ebp
f0100e1c:	57                   	push   %edi
f0100e1d:	56                   	push   %esi
f0100e1e:	53                   	push   %ebx
f0100e1f:	83 ec 10             	sub    $0x10,%esp
f0100e22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 i = strtoul(arguments[1], NULL, 16);
f0100e25:	6a 10                	push   $0x10
f0100e27:	6a 00                	push   $0x0
f0100e29:	ff 73 04             	pushl  0x4(%ebx)
f0100e2c:	e8 3e 38 00 00       	call   f010466f <strtoul>
f0100e31:	89 c6                	mov    %eax,%esi
	uint32 j = strtoul(arguments[2], NULL, 16);
f0100e33:	83 c4 0c             	add    $0xc,%esp
f0100e36:	6a 10                	push   $0x10
f0100e38:	6a 00                	push   $0x0
f0100e3a:	ff 73 08             	pushl  0x8(%ebx)
f0100e3d:	e8 2d 38 00 00       	call   f010466f <strtoul>
f0100e42:	89 c7                	mov    %eax,%edi
	cprintf("%u %u\n", i, j);
f0100e44:	83 c4 0c             	add    $0xc,%esp
f0100e47:	50                   	push   %eax
f0100e48:	56                   	push   %esi
f0100e49:	68 f7 4e 10 f0       	push   $0xf0104ef7
f0100e4e:	e8 8b 25 00 00       	call   f01033de <cprintf>
	cprintf("DIR Index\tPAGE Table Index\tPhysical Address\tModified\n");
f0100e53:	c7 04 24 20 54 10 f0 	movl   $0xf0105420,(%esp)
f0100e5a:	e8 7f 25 00 00       	call   f01033de <cprintf>
	for (; i <= j; i += 4096) {
f0100e5f:	83 c4 10             	add    $0x10,%esp
f0100e62:	39 fe                	cmp    %edi,%esi
f0100e64:	77 7a                	ja     f0100ee0 <show_mappings+0xc7>
		uint32 *va = (uint32*) i;
		uint32 *ptr_page_table = NULL;
f0100e66:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
f0100e6d:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100e70:	50                   	push   %eax
f0100e71:	6a 00                	push   $0x0
f0100e73:	56                   	push   %esi
f0100e74:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100e7a:	e8 1c 18 00 00       	call   f010269b <get_page_table>
		if (ptr_page_table != NULL) {
f0100e7f:	83 c4 10             	add    $0x10,%esp
f0100e82:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0100e86:	74 4e                	je     f0100ed6 <show_mappings+0xbd>
			int dir_index = PDX(va);
f0100e88:	89 f1                	mov    %esi,%ecx
f0100e8a:	c1 e9 16             	shr    $0x16,%ecx
			int table_index = PTX(va);
f0100e8d:	89 f2                	mov    %esi,%edx
f0100e8f:	c1 ea 0c             	shr    $0xc,%edx
f0100e92:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
			uint32 check = ptr_page_table[table_index];
f0100e98:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100e9b:	8b 04 90             	mov    (%eax,%edx,4),%eax
			uint32 ccheck = ptr_page_table[table_index] & PERM_MODIFIED;
f0100e9e:	89 c3                	mov    %eax,%ebx
f0100ea0:	83 e3 40             	and    $0x40,%ebx
			//cprintf("%u\n", check);
			check = check >> 12;
			//cprintf("%u\n", check);
			check = check << 12;
f0100ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
			//cprintf("%u\n", check);
			cprintf("%d \t %d\t %x\t", dir_index, table_index, check);
f0100ea8:	50                   	push   %eax
f0100ea9:	52                   	push   %edx
f0100eaa:	51                   	push   %ecx
f0100eab:	68 fe 4e 10 f0       	push   $0xf0104efe
f0100eb0:	e8 29 25 00 00       	call   f01033de <cprintf>
			if (ccheck == 0)
f0100eb5:	83 c4 10             	add    $0x10,%esp
f0100eb8:	85 db                	test   %ebx,%ebx
f0100eba:	75 0a                	jne    f0100ec6 <show_mappings+0xad>
				cprintf("No\n");
f0100ebc:	83 ec 0c             	sub    $0xc,%esp
f0100ebf:	68 0b 4f 10 f0       	push   $0xf0104f0b
f0100ec4:	eb 08                	jmp    f0100ece <show_mappings+0xb5>
			else
				cprintf("Yes\n");
f0100ec6:	83 ec 0c             	sub    $0xc,%esp
f0100ec9:	68 0f 4f 10 f0       	push   $0xf0104f0f
f0100ece:	e8 0b 25 00 00       	call   f01033de <cprintf>
f0100ed3:	83 c4 10             	add    $0x10,%esp
f0100ed6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100edc:	39 fe                	cmp    %edi,%esi
f0100ede:	76 86                	jbe    f0100e66 <show_mappings+0x4d>

		}
	}
	return 0;
}
f0100ee0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee5:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100ee8:	5b                   	pop    %ebx
f0100ee9:	5e                   	pop    %esi
f0100eea:	5f                   	pop    %edi
f0100eeb:	5d                   	pop    %ebp
f0100eec:	c3                   	ret    

f0100eed <cut_paste_page>:

int cut_paste_page(int number_of_arguments, char **arguments) {
f0100eed:	55                   	push   %ebp
f0100eee:	89 e5                	mov    %esp,%ebp
f0100ef0:	56                   	push   %esi
f0100ef1:	53                   	push   %ebx
f0100ef2:	83 ec 14             	sub    $0x14,%esp
f0100ef5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
f0100ef8:	6a 10                	push   $0x10
f0100efa:	6a 00                	push   $0x0
f0100efc:	ff 73 04             	pushl  0x4(%ebx)
f0100eff:	e8 7e 36 00 00       	call   f0104582 <strtol>
f0100f04:	89 c6                	mov    %eax,%esi
	uint32 *ptr_page_table1 = NULL;
f0100f06:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
f0100f0d:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100f10:	50                   	push   %eax
f0100f11:	6a 00                	push   $0x0
f0100f13:	56                   	push   %esi
f0100f14:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100f1a:	e8 7c 17 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table1 != NULL) {
f0100f1f:	83 c4 20             	add    $0x20,%esp
f0100f22:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100f26:	74 5b                	je     f0100f83 <cut_paste_page+0x96>
		uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
f0100f28:	83 ec 04             	sub    $0x4,%esp
f0100f2b:	6a 10                	push   $0x10
f0100f2d:	6a 00                	push   $0x0
f0100f2f:	ff 73 08             	pushl  0x8(%ebx)
f0100f32:	e8 4b 36 00 00       	call   f0104582 <strtol>
f0100f37:	89 c3                	mov    %eax,%ebx
		uint32 *ptr_page_table2 = NULL;
f0100f39:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
f0100f40:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100f43:	50                   	push   %eax
f0100f44:	6a 01                	push   $0x1
f0100f46:	53                   	push   %ebx
f0100f47:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100f4d:	e8 49 17 00 00       	call   f010269b <get_page_table>
		ptr_page_table2[PTX(va2)] = ptr_page_table1[PTX(va1)];
f0100f52:	89 d8                	mov    %ebx,%eax
f0100f54:	c1 e8 0c             	shr    $0xc,%eax
f0100f57:	89 c3                	mov    %eax,%ebx
f0100f59:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100f5f:	89 f2                	mov    %esi,%edx
f0100f61:	c1 ea 0c             	shr    $0xc,%edx
f0100f64:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f6a:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100f6d:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
f0100f70:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0100f73:	89 0c 98             	mov    %ecx,(%eax,%ebx,4)
		ptr_page_table1[PTX(va1)] = (uint32) NULL;
f0100f76:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0100f79:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
f0100f80:	83 c4 20             	add    $0x20,%esp
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f0100f83:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0100f86:	0f 22 d8             	mov    %eax,%cr3
		//ptr_page_table1[PTX(va1)] &= ( ~PERM_PRESENT);
	}
	tlbflush();
	return 0;
}
f0100f89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8e:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100f91:	5b                   	pop    %ebx
f0100f92:	5e                   	pop    %esi
f0100f93:	5d                   	pop    %ebp
f0100f94:	c3                   	ret    

f0100f95 <share_4M_readonly>:

int share_4M_readonly(int number_of_arguments, char **arguments) {
f0100f95:	55                   	push   %ebp
f0100f96:	89 e5                	mov    %esp,%ebp
f0100f98:	56                   	push   %esi
f0100f99:	53                   	push   %ebx
f0100f9a:	83 ec 14             	sub    $0x14,%esp
f0100f9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
f0100fa0:	6a 10                	push   $0x10
f0100fa2:	6a 00                	push   $0x0
f0100fa4:	ff 73 04             	pushl  0x4(%ebx)
f0100fa7:	e8 d6 35 00 00       	call   f0104582 <strtol>
f0100fac:	89 c6                	mov    %eax,%esi
	uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
f0100fae:	83 c4 0c             	add    $0xc,%esp
f0100fb1:	6a 10                	push   $0x10
f0100fb3:	6a 00                	push   $0x0
f0100fb5:	ff 73 08             	pushl  0x8(%ebx)
f0100fb8:	e8 c5 35 00 00       	call   f0104582 <strtol>
f0100fbd:	89 c3                	mov    %eax,%ebx
	uint32 *ptr_page_table1 = NULL;
f0100fbf:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
f0100fc6:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0100fc9:	50                   	push   %eax
f0100fca:	6a 00                	push   $0x0
f0100fcc:	56                   	push   %esi
f0100fcd:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100fd3:	e8 c3 16 00 00       	call   f010269b <get_page_table>
	uint32 *ptr_page_table2 = NULL;
f0100fd8:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
f0100fdf:	83 c4 20             	add    $0x20,%esp
f0100fe2:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0100fe5:	50                   	push   %eax
f0100fe6:	6a 01                	push   $0x1
f0100fe8:	53                   	push   %ebx
f0100fe9:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0100fef:	e8 a7 16 00 00       	call   f010269b <get_page_table>
	if (ptr_page_table1 != NULL) {
f0100ff4:	83 c4 10             	add    $0x10,%esp
f0100ff7:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0100ffb:	74 1d                	je     f010101a <share_4M_readonly+0x85>
		int i = 0;
f0100ffd:	b9 00 00 00 00       	mov    $0x0,%ecx
		for (i = 0; i <= 1024; i++)
			ptr_page_table2[i] = ptr_page_table1[i] & (~PERM_WRITEABLE);
f0101002:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101005:	8b 14 88             	mov    (%eax,%ecx,4),%edx
f0101008:	83 e2 fd             	and    $0xfffffffd,%edx
f010100b:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010100e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
f0101011:	41                   	inc    %ecx
f0101012:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0101018:	7e e8                	jle    f0101002 <share_4M_readonly+0x6d>
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f010101a:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f010101d:	0f 22 d8             	mov    %eax,%cr3
	}
	//ptr_page_directory[PDX(va2)] = ptr_page_directory[PDX(va1)];
	tlbflush();
	return 0;
}
f0101020:	b8 00 00 00 00       	mov    $0x0,%eax
f0101025:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0101028:	5b                   	pop    %ebx
f0101029:	5e                   	pop    %esi
f010102a:	5d                   	pop    %ebp
f010102b:	c3                   	ret    

f010102c <remove_table>:

int remove_table(int number_of_arguments, char **arguments) {
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	53                   	push   %ebx
f0101030:	83 ec 08             	sub    $0x8,%esp
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f0101033:	6a 10                	push   $0x10
f0101035:	6a 00                	push   $0x0
f0101037:	8b 45 0c             	mov    0xc(%ebp),%eax
f010103a:	ff 70 04             	pushl  0x4(%eax)
f010103d:	e8 40 35 00 00       	call   f0104582 <strtol>
f0101042:	89 c3                	mov    %eax,%ebx
	cprintf("%x\n", PDX(va));
f0101044:	83 c4 08             	add    $0x8,%esp
f0101047:	c1 eb 16             	shr    $0x16,%ebx
f010104a:	53                   	push   %ebx
f010104b:	68 f3 4e 10 f0       	push   $0xf0104ef3
f0101050:	e8 89 23 00 00       	call   f01033de <cprintf>
	ptr_page_directory[PDX(va)] = (uint32) NULL;
f0101055:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f010105a:	c7 04 98 00 00 00 00 	movl   $0x0,(%eax,%ebx,4)
}

static __inline void
tlbflush(void)
{
f0101061:	83 c4 10             	add    $0x10,%esp
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f0101064:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0101067:	0f 22 d8             	mov    %eax,%cr3
	tlbflush();
	return 0;
}
f010106a:	b8 00 00 00 00       	mov    $0x0,%eax
f010106f:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0101072:	c9                   	leave  
f0101073:	c3                   	ret    

f0101074 <alloc_user_mem>:

int alloc_user_mem(int number_of_arguments, char **arguments) {
f0101074:	55                   	push   %ebp
f0101075:	89 e5                	mov    %esp,%ebp
f0101077:	57                   	push   %edi
f0101078:	56                   	push   %esi
f0101079:	53                   	push   %ebx
f010107a:	83 ec 10             	sub    $0x10,%esp
f010107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 count = strtoul(arguments[1], NULL, 10);
f0101080:	6a 0a                	push   $0xa
f0101082:	6a 00                	push   $0x0
f0101084:	ff 73 04             	pushl  0x4(%ebx)
f0101087:	e8 e3 35 00 00       	call   f010466f <strtoul>
f010108c:	89 c6                	mov    %eax,%esi
	if (arguments[2][0] == 'k')
f010108e:	8b 43 08             	mov    0x8(%ebx),%eax
f0101091:	83 c4 10             	add    $0x10,%esp
f0101094:	80 38 6b             	cmpb   $0x6b,(%eax)
f0101097:	75 05                	jne    f010109e <alloc_user_mem+0x2a>
		count *= 1024;
f0101099:	c1 e6 0a             	shl    $0xa,%esi
f010109c:	eb 03                	jmp    f01010a1 <alloc_user_mem+0x2d>
	else
		count *= 1024 * 1024;
f010109e:	c1 e6 14             	shl    $0x14,%esi
	//cprintf("%u\n", count);
	struct Frame_Info *ptr_frame_info;
	uint32 i;
	uint32 l = ROUNDDOWN(va_start, PAGE_SIZE);
	uint32 s = ROUNDUP( count+va_start, PAGE_SIZE);
f01010a1:	89 f0                	mov    %esi,%eax
f01010a3:	03 05 e8 e0 19 f0    	add    0xf019e0e8,%eax
f01010a9:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01010af:	89 c7                	mov    %eax,%edi
f01010b1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = l; i < s; i += PAGE_SIZE) {
f01010b7:	8b 1d e8 e0 19 f0    	mov    0xf019e0e8,%ebx
f01010bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01010c3:	39 fb                	cmp    %edi,%ebx
f01010c5:	73 61                	jae    f0101128 <alloc_user_mem+0xb4>
		uint32 *pge_table;
		struct Frame_Info *pt = get_frame_info(ptr_page_directory, (void*) i,
f01010c7:	83 ec 04             	sub    $0x4,%esp
f01010ca:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01010cd:	50                   	push   %eax
f01010ce:	53                   	push   %ebx
f01010cf:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01010d5:	e8 83 17 00 00       	call   f010285d <get_frame_info>
				&pge_table);
		if (pt != NULL)
f01010da:	83 c4 10             	add    $0x10,%esp
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	75 3d                	jne    f010111e <alloc_user_mem+0xaa>
			continue;
		int ret = allocate_frame(&ptr_frame_info);
f01010e1:	83 ec 0c             	sub    $0xc,%esp
f01010e4:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01010e7:	50                   	push   %eax
f01010e8:	e8 21 15 00 00       	call   f010260e <allocate_frame>
		//cprintf("%d\n", to_frame_number(ptr_frame_info));
		if (ret != E_NO_MEM) {
f01010ed:	83 c4 10             	add    $0x10,%esp
f01010f0:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01010f3:	74 19                	je     f010110e <alloc_user_mem+0x9a>
			//uint32 physical_address = to_physical_address(ptr_frame_info);
			int m = map_frame(ptr_page_directory, ptr_frame_info, (void *) i,
f01010f5:	6a 07                	push   $0x7
f01010f7:	53                   	push   %ebx
f01010f8:	ff 75 ec             	pushl  0xffffffec(%ebp)
f01010fb:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101101:	e8 a9 16 00 00       	call   f01027af <map_frame>
					PERM_WRITEABLE | PERM_USER | PERM_PRESENT);
			if (m == E_NO_MEM)
f0101106:	83 c4 10             	add    $0x10,%esp
f0101109:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010110c:	75 10                	jne    f010111e <alloc_user_mem+0xaa>
				cprintf("Error: no physical memory available\n");
		} else {
			cprintf("Error: no physical memory available\n");
f010110e:	83 ec 0c             	sub    $0xc,%esp
f0101111:	68 60 54 10 f0       	push   $0xf0105460
f0101116:	e8 c3 22 00 00       	call   f01033de <cprintf>
f010111b:	83 c4 10             	add    $0x10,%esp
f010111e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101124:	39 fb                	cmp    %edi,%ebx
f0101126:	72 9f                	jb     f01010c7 <alloc_user_mem+0x53>
		}
	}
	va_start += count;
f0101128:	01 35 e8 e0 19 f0    	add    %esi,0xf019e0e8
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f010112e:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0101131:	0f 22 d8             	mov    %eax,%cr3
	tlbflush();
	return 0;
}
f0101134:	b8 00 00 00 00       	mov    $0x0,%eax
f0101139:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010113c:	5b                   	pop    %ebx
f010113d:	5e                   	pop    %esi
f010113e:	5f                   	pop    %edi
f010113f:	5d                   	pop    %ebp
f0101140:	c3                   	ret    

f0101141 <copy_page>:

int copy_page(int number_of_arguments, char **arguments) {
f0101141:	55                   	push   %ebp
f0101142:	89 e5                	mov    %esp,%ebp
f0101144:	56                   	push   %esi
f0101145:	53                   	push   %ebx
f0101146:	83 ec 14             	sub    $0x14,%esp
f0101149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
f010114c:	6a 10                	push   $0x10
f010114e:	6a 00                	push   $0x0
f0101150:	ff 73 04             	pushl  0x4(%ebx)
f0101153:	e8 2a 34 00 00       	call   f0104582 <strtol>
f0101158:	89 c6                	mov    %eax,%esi
	uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
f010115a:	83 c4 0c             	add    $0xc,%esp
f010115d:	6a 10                	push   $0x10
f010115f:	6a 00                	push   $0x0
f0101161:	ff 73 08             	pushl  0x8(%ebx)
f0101164:	e8 19 34 00 00       	call   f0104582 <strtol>
f0101169:	89 c3                	mov    %eax,%ebx
	uint32 *ptr_page_table1 = NULL;
f010116b:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
f0101172:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0101175:	50                   	push   %eax
f0101176:	6a 00                	push   $0x0
f0101178:	56                   	push   %esi
f0101179:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010117f:	e8 17 15 00 00       	call   f010269b <get_page_table>
	uint32 *ptr_page_table2 = NULL;
f0101184:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	get_page_table(ptr_page_directory, va2, 0, &ptr_page_table2);
f010118b:	83 c4 20             	add    $0x20,%esp
f010118e:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101191:	50                   	push   %eax
f0101192:	6a 00                	push   $0x0
f0101194:	53                   	push   %ebx
f0101195:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010119b:	e8 fb 14 00 00       	call   f010269b <get_page_table>
	struct Frame_Info *ptr_frame_info = get_frame_info(ptr_page_directory,
f01011a0:	83 c4 0c             	add    $0xc,%esp
f01011a3:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01011a6:	50                   	push   %eax
f01011a7:	53                   	push   %ebx
f01011a8:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01011ae:	e8 aa 16 00 00       	call   f010285d <get_frame_info>
			(void*) va2, &ptr_page_table2);
	if (ptr_frame_info == NULL) {
f01011b3:	83 c4 10             	add    $0x10,%esp
f01011b6:	85 c0                	test   %eax,%eax
f01011b8:	75 3d                	jne    f01011f7 <copy_page+0xb6>
		struct Frame_Info *ptr_frame_info;
		int ret = allocate_frame(&ptr_frame_info);
f01011ba:	83 ec 0c             	sub    $0xc,%esp
f01011bd:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01011c0:	50                   	push   %eax
f01011c1:	e8 48 14 00 00       	call   f010260e <allocate_frame>
		if (ret != E_NO_MEM) {
f01011c6:	83 c4 10             	add    $0x10,%esp
f01011c9:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01011cc:	74 19                	je     f01011e7 <copy_page+0xa6>
			int m = map_frame(ptr_page_directory, ptr_frame_info, (void *) va2,
f01011ce:	6a 07                	push   $0x7
f01011d0:	53                   	push   %ebx
f01011d1:	ff 75 ec             	pushl  0xffffffec(%ebp)
f01011d4:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01011da:	e8 d0 15 00 00       	call   f01027af <map_frame>
					PERM_WRITEABLE | PERM_USER | PERM_PRESENT);
			if (m == E_NO_MEM)
f01011df:	83 c4 10             	add    $0x10,%esp
f01011e2:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01011e5:	75 10                	jne    f01011f7 <copy_page+0xb6>
				cprintf("Error: no physical memory available\n");
		} else {
			cprintf("Error: no physical memory available\n");
f01011e7:	83 ec 0c             	sub    $0xc,%esp
f01011ea:	68 60 54 10 f0       	push   $0xf0105460
f01011ef:	e8 ea 21 00 00       	call   f01033de <cprintf>
f01011f4:	83 c4 10             	add    $0x10,%esp
		}
	}
	uint32 k = (uint32) va1, j = (uint32) va2, count = (4 * 1024)
f01011f7:	89 f2                	mov    %esi,%edx
f01011f9:	89 d9                	mov    %ebx,%ecx
f01011fb:	8d 9e 00 10 00 00    	lea    0x1000(%esi),%ebx
															+ (uint32) va1;
	while (k < count) {
f0101201:	39 de                	cmp    %ebx,%esi
f0101203:	73 0a                	jae    f010120f <copy_page+0xce>
		unsigned char *ptr1 = (unsigned char *) (k);
		unsigned char *ptr2 = (unsigned char *) (j);
		*ptr2 = *ptr1;
f0101205:	8a 02                	mov    (%edx),%al
f0101207:	88 01                	mov    %al,(%ecx)
		k++;
f0101209:	42                   	inc    %edx
		j++;
f010120a:	41                   	inc    %ecx
f010120b:	39 da                	cmp    %ebx,%edx
f010120d:	72 f6                	jb     f0101205 <copy_page+0xc4>
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f010120f:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f0101212:	0f 22 d8             	mov    %eax,%cr3
	}
	tlbflush();
	return 0;
}
f0101215:	b8 00 00 00 00       	mov    $0x0,%eax
f010121a:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010121d:	5b                   	pop    %ebx
f010121e:	5e                   	pop    %esi
f010121f:	5d                   	pop    %ebp
f0101220:	c3                   	ret    

f0101221 <num_pages_in_table>:

int num_pages_in_table(int number_of_arguments, char **arguments) {
f0101221:	55                   	push   %ebp
f0101222:	89 e5                	mov    %esp,%ebp
f0101224:	53                   	push   %ebx
f0101225:	83 ec 08             	sub    $0x8,%esp

	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
f0101228:	6a 10                	push   $0x10
f010122a:	6a 00                	push   $0x0
f010122c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122f:	ff 70 04             	pushl  0x4(%eax)
f0101232:	e8 4b 33 00 00       	call   f0104582 <strtol>
	uint32 *ptr_page_table1 = NULL;
f0101237:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
f010123e:	8d 55 f8             	lea    0xfffffff8(%ebp),%edx
f0101241:	52                   	push   %edx
f0101242:	6a 00                	push   $0x0
f0101244:	50                   	push   %eax
f0101245:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010124b:	e8 4b 14 00 00       	call   f010269b <get_page_table>
	//struct Frame_Info * f = get_frame_info(ptr_page_directory,va1, *ptr_page_table1 );
	if (ptr_page_table1 == NULL)
f0101250:	83 c4 20             	add    $0x20,%esp
f0101253:	83 7d f8 00          	cmpl   $0x0,0xfffffff8(%ebp)
f0101257:	75 0a                	jne    f0101263 <num_pages_in_table+0x42>
		cprintf("Table doesn't exist\n");
f0101259:	83 ec 0c             	sub    $0xc,%esp
f010125c:	68 14 4f 10 f0       	push   $0xf0104f14
f0101261:	eb 2d                	jmp    f0101290 <num_pages_in_table+0x6f>
	else {
		int ans = 0;
f0101263:	b9 00 00 00 00       	mov    $0x0,%ecx
		int i;
		for (i = 0; i < 1024; i++) {
f0101268:	ba 00 00 00 00       	mov    $0x0,%edx
f010126d:	8b 5d f8             	mov    0xfffffff8(%ebp),%ebx
			int a = ptr_page_table1[i] & PERM_PRESENT;
			if (a != 0)
f0101270:	f6 04 93 01          	testb  $0x1,(%ebx,%edx,4)
f0101274:	0f 95 c0             	setne  %al
f0101277:	25 ff 00 00 00       	and    $0xff,%eax
f010127c:	01 c1                	add    %eax,%ecx
f010127e:	42                   	inc    %edx
f010127f:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0101285:	7e e9                	jle    f0101270 <num_pages_in_table+0x4f>
				ans++;
		}
		cprintf("number of pages = %d\n", ans);
f0101287:	83 ec 08             	sub    $0x8,%esp
f010128a:	51                   	push   %ecx
f010128b:	68 29 4f 10 f0       	push   $0xf0104f29
f0101290:	e8 49 21 00 00       	call   f01033de <cprintf>
f0101295:	83 c4 10             	add    $0x10,%esp
	}

	//tlbflush();
	return 0;
}
f0101298:	b8 00 00 00 00       	mov    $0x0,%eax
f010129d:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01012a0:	c9                   	leave  
f01012a1:	c3                   	ret    

f01012a2 <free_chunck>:

int free_chunck(int number_of_arguments, char **arguments) {
f01012a2:	55                   	push   %ebp
f01012a3:	89 e5                	mov    %esp,%ebp
f01012a5:	57                   	push   %edi
f01012a6:	56                   	push   %esi
f01012a7:	53                   	push   %ebx
f01012a8:	83 ec 10             	sub    $0x10,%esp
f01012ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 count = strtoul(arguments[2], NULL, 10);
f01012ae:	6a 0a                	push   $0xa
f01012b0:	6a 00                	push   $0x0
f01012b2:	ff 73 08             	pushl  0x8(%ebx)
f01012b5:	e8 b5 33 00 00       	call   f010466f <strtoul>
f01012ba:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f01012bd:	83 c4 0c             	add    $0xc,%esp
f01012c0:	6a 10                	push   $0x10
f01012c2:	6a 00                	push   $0x0
f01012c4:	ff 73 04             	pushl  0x4(%ebx)
f01012c7:	e8 b6 32 00 00       	call   f0104582 <strtol>
f01012cc:	89 c6                	mov    %eax,%esi
	if (arguments[3][0] == 'k')
f01012ce:	8b 43 0c             	mov    0xc(%ebx),%eax
f01012d1:	83 c4 10             	add    $0x10,%esp
f01012d4:	80 38 6b             	cmpb   $0x6b,(%eax)
f01012d7:	75 06                	jne    f01012df <free_chunck+0x3d>
		count *= 1024;
f01012d9:	c1 65 ec 0a          	shll   $0xa,0xffffffec(%ebp)
f01012dd:	eb 04                	jmp    f01012e3 <free_chunck+0x41>
	else
		count *= 1024 * 1024;
f01012df:	c1 65 ec 14          	shll   $0x14,0xffffffec(%ebp)
	struct Frame_Info *ptr_frame_info;
	uint32 i;
	uint32 l = ROUNDDOWN((uint32)va, PAGE_SIZE);
f01012e3:	89 f0                	mov    %esi,%eax
f01012e5:	25 ff 0f 00 00       	and    $0xfff,%eax
	uint32 s = ROUNDUP( count+(uint32)va, PAGE_SIZE);
f01012ea:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f01012ed:	8d 94 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%edx
f01012f4:	89 d1                	mov    %edx,%ecx
f01012f6:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
f01012fc:	89 d7                	mov    %edx,%edi
f01012fe:	29 cf                	sub    %ecx,%edi
	for (i = l; i < s; i += PAGE_SIZE) {
f0101300:	89 f3                	mov    %esi,%ebx
f0101302:	29 c3                	sub    %eax,%ebx
f0101304:	39 fb                	cmp    %edi,%ebx
f0101306:	73 1c                	jae    f0101324 <free_chunck+0x82>
		unsigned char *vaa = (unsigned char *) (i);
		// Un-map the page at this address
		unmap_frame(ptr_page_directory, vaa);
f0101308:	83 ec 08             	sub    $0x8,%esp
f010130b:	53                   	push   %ebx
f010130c:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101312:	e8 c5 15 00 00       	call   f01028dc <unmap_frame>
f0101317:	83 c4 10             	add    $0x10,%esp
f010131a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101320:	39 fb                	cmp    %edi,%ebx
f0101322:	72 e4                	jb     f0101308 <free_chunck+0x66>
	}
	l = ROUNDDOWN((uint32)va, PTSIZE);
f0101324:	89 f0                	mov    %esi,%eax
f0101326:	25 ff ff 3f 00       	and    $0x3fffff,%eax
	s = ROUNDUP( count+(uint32)va, PTSIZE);
f010132b:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f010132e:	8d 94 0e ff ff 3f 00 	lea    0x3fffff(%esi,%ecx,1),%edx
f0101335:	89 d1                	mov    %edx,%ecx
f0101337:	81 e1 ff ff 3f 00    	and    $0x3fffff,%ecx
f010133d:	89 d7                	mov    %edx,%edi
f010133f:	29 cf                	sub    %ecx,%edi
	for (i = l; i < s; i += PTSIZE) {
f0101341:	89 f3                	mov    %esi,%ebx
f0101343:	29 c3                	sub    %eax,%ebx
f0101345:	39 fb                	cmp    %edi,%ebx
f0101347:	0f 83 d1 00 00 00    	jae    f010141e <free_chunck+0x17c>
		uint32 b = ROUNDDOWN(i, PTSIZE);
		uint32 *ptr_page_table1 = NULL;
f010134d:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		get_page_table(ptr_page_directory, (uint32*) i, 0, &ptr_page_table1);
f0101354:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101357:	50                   	push   %eax
f0101358:	6a 00                	push   $0x0
f010135a:	53                   	push   %ebx
f010135b:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101361:	e8 35 13 00 00       	call   f010269b <get_page_table>
		int check = 0;
f0101366:	b9 00 00 00 00       	mov    $0x0,%ecx
		int j;
		for (j = 0; j < 1024; j += 1) {
f010136b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101370:	83 c4 10             	add    $0x10,%esp
f0101373:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
			//struct Frame_Info *ptr_frame_info = get_frame_info(
			//ptr_page_directory, (void*) b + j, &ptr_page_table1);
			int c = ptr_page_table1[j] & PERM_PRESENT;
			if( c != 0)
f0101376:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f010137a:	75 32                	jne    f01013ae <free_chunck+0x10c>
f010137c:	40                   	inc    %eax
f010137d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0101382:	7e f2                	jle    f0101376 <free_chunck+0xd4>
			{
				check = 1;
				break;
			}
			/*if (ptr_frame_info != NULL) {
				check = 1;
				break;
			}*/
		}
		if (check == 0 && ptr_page_table1 != NULL) {
f0101384:	85 c9                	test   %ecx,%ecx
f0101386:	0f 85 84 00 00 00    	jne    f0101410 <free_chunck+0x16e>
f010138c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0101390:	74 7e                	je     f0101410 <free_chunck+0x16e>
			uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table1);
f0101392:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101395:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010139a:	77 19                	ja     f01013b5 <free_chunck+0x113>
f010139c:	50                   	push   %eax
f010139d:	68 20 53 10 f0       	push   $0xf0105320
f01013a2:	68 46 02 00 00       	push   $0x246
f01013a7:	68 7d 4e 10 f0       	push   $0xf0104e7d
f01013ac:	eb 29                	jmp    f01013d7 <free_chunck+0x135>
f01013ae:	b9 01 00 00 00       	mov    $0x1,%ecx
f01013b3:	eb cf                	jmp    f0101384 <free_chunck+0xe2>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f01013b5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	if (PPN(physical_address) >= number_of_frames)
f01013bb:	89 d0                	mov    %edx,%eax
f01013bd:	c1 e8 0c             	shr    $0xc,%eax
f01013c0:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f01013c6:	72 14                	jb     f01013dc <free_chunck+0x13a>
		panic("to_frame_info called with invalid pa");
f01013c8:	83 ec 04             	sub    $0x4,%esp
f01013cb:	68 60 53 10 f0       	push   $0xf0105360
f01013d0:	6a 39                	push   $0x39
f01013d2:	68 be 4e 10 f0       	push   $0xf0104ebe
f01013d7:	e8 22 ed ff ff       	call   f01000fe <_panic>
f01013dc:	89 d0                	mov    %edx,%eax
f01013de:	c1 e8 0c             	shr    $0xc,%eax
f01013e1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013e4:	8b 15 7c e9 19 f0    	mov    0xf019e97c,%edx
f01013ea:	8d 04 82             	lea    (%edx,%eax,4),%eax
			struct Frame_Info *table_frame_info = to_frame_info(table_pa);
			table_frame_info->references = 0;
f01013ed:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
			free_frame(table_frame_info);
f01013f3:	83 ec 0c             	sub    $0xc,%esp
f01013f6:	50                   	push   %eax
f01013f7:	e8 55 12 00 00       	call   f0102651 <free_frame>
			uint32 dir_index = PDX((uint32*)i);
f01013fc:	89 da                	mov    %ebx,%edx
f01013fe:	c1 ea 16             	shr    $0x16,%edx
			ptr_page_directory[dir_index] = 0;
f0101401:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0101406:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
f010140d:	83 c4 10             	add    $0x10,%esp
f0101410:	81 c3 00 00 40 00    	add    $0x400000,%ebx
f0101416:	39 fb                	cmp    %edi,%ebx
f0101418:	0f 82 2f ff ff ff    	jb     f010134d <free_chunck+0xab>
		}
	}
	va_start -= count;
f010141e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101421:	29 05 e8 e0 19 f0    	sub    %eax,0xf019e0e8
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f0101427:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f010142a:	0f 22 d8             	mov    %eax,%cr3
	tlbflush();
	return 0;
}
f010142d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101432:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0101435:	5b                   	pop    %ebx
f0101436:	5e                   	pop    %esi
f0101437:	5f                   	pop    %edi
f0101438:	5d                   	pop    %ebp
f0101439:	c3                   	ret    

f010143a <create_tables_only>:
int create_tables_only(int number_of_arguments, char **arguments) {
f010143a:	55                   	push   %ebp
f010143b:	89 e5                	mov    %esp,%ebp
f010143d:	57                   	push   %edi
f010143e:	56                   	push   %esi
f010143f:	53                   	push   %ebx
f0101440:	83 ec 10             	sub    $0x10,%esp
f0101443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 count = strtoul(arguments[2], NULL, 10);
f0101446:	6a 0a                	push   $0xa
f0101448:	6a 00                	push   $0x0
f010144a:	ff 73 08             	pushl  0x8(%ebx)
f010144d:	e8 1d 32 00 00       	call   f010466f <strtoul>
f0101452:	89 c7                	mov    %eax,%edi
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
f0101454:	83 c4 0c             	add    $0xc,%esp
f0101457:	6a 10                	push   $0x10
f0101459:	6a 00                	push   $0x0
f010145b:	ff 73 04             	pushl  0x4(%ebx)
f010145e:	e8 1f 31 00 00       	call   f0104582 <strtol>
f0101463:	89 c6                	mov    %eax,%esi
	if (arguments[3][0] == 'k')
f0101465:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101468:	83 c4 10             	add    $0x10,%esp
f010146b:	80 38 6b             	cmpb   $0x6b,(%eax)
f010146e:	75 05                	jne    f0101475 <create_tables_only+0x3b>
		count *= 1024;
f0101470:	c1 e7 0a             	shl    $0xa,%edi
f0101473:	eb 03                	jmp    f0101478 <create_tables_only+0x3e>
	else
		count *= 1024 * 1024;
f0101475:	c1 e7 14             	shl    $0x14,%edi
	uint32 l = ROUNDDOWN((uint32)va, PTSIZE);
f0101478:	89 f0                	mov    %esi,%eax
f010147a:	25 ff ff 3f 00       	and    $0x3fffff,%eax
	uint32 s = ROUNDUP( count+(uint32)va, PTSIZE);
f010147f:	8d 94 3e ff ff 3f 00 	lea    0x3fffff(%esi,%edi,1),%edx
f0101486:	89 d1                	mov    %edx,%ecx
f0101488:	81 e1 ff ff 3f 00    	and    $0x3fffff,%ecx
f010148e:	89 d7                	mov    %edx,%edi
f0101490:	29 cf                	sub    %ecx,%edi
	int i;
	for (i = l; i < s; i += PTSIZE) {
f0101492:	89 f3                	mov    %esi,%ebx
f0101494:	29 c3                	sub    %eax,%ebx
f0101496:	39 fb                	cmp    %edi,%ebx
f0101498:	73 26                	jae    f01014c0 <create_tables_only+0x86>
f010149a:	8d 75 f0             	lea    0xfffffff0(%ebp),%esi
		uint32 *ptr_page_table1 = NULL;
f010149d:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
		get_page_table(ptr_page_directory, (uint32*) i, 1, &ptr_page_table1);
f01014a4:	56                   	push   %esi
f01014a5:	6a 01                	push   $0x1
f01014a7:	53                   	push   %ebx
f01014a8:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01014ae:	e8 e8 11 00 00       	call   f010269b <get_page_table>
f01014b3:	83 c4 10             	add    $0x10,%esp
f01014b6:	81 c3 00 00 40 00    	add    $0x400000,%ebx
f01014bc:	39 fb                	cmp    %edi,%ebx
f01014be:	72 dd                	jb     f010149d <create_tables_only+0x63>
static __inline void
tlbflush(void)
{
	uint32 cr3;
	__asm __volatile("movl %%cr3,%0" : "=r" (cr3));
f01014c0:	0f 20 d8             	mov    %cr3,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
f01014c3:	0f 22 d8             	mov    %eax,%cr3
	}
	tlbflush();
	return 0;
}
f01014c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014cb:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01014ce:	5b                   	pop    %ebx
f01014cf:	5e                   	pop    %esi
f01014d0:	5f                   	pop    %edi
f01014d1:	5d                   	pop    %ebp
f01014d2:	c3                   	ret    

f01014d3 <command_run>:

//============ lab 6 hands on ==============

int command_run(int number_of_arguments, char **arguments) {
f01014d3:	55                   	push   %ebp
f01014d4:	89 e5                	mov    %esp,%ebp
f01014d6:	83 ec 14             	sub    $0x14,%esp
	//[1] Create and initialize a new environment for the program to be run
	struct UserProgramInfo* ptr_program_info = env_create(arguments[1]);
f01014d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014dc:	ff 70 04             	pushl  0x4(%eax)
f01014df:	e8 77 15 00 00       	call   f0102a5b <env_create>
	if (ptr_program_info == 0)
f01014e4:	83 c4 10             	add    $0x10,%esp
f01014e7:	85 c0                	test   %eax,%eax
f01014e9:	74 33                	je     f010151e <command_run+0x4b>
		return 0;
	if( running == NULL )
f01014eb:	83 3d ec e0 19 f0 00 	cmpl   $0x0,0xf019e0ec
f01014f2:	75 07                	jne    f01014fb <command_run+0x28>
		running = ptr_program_info;
f01014f4:	a3 ec e0 19 f0       	mov    %eax,0xf019e0ec
f01014f9:	eb 18                	jmp    f0101513 <command_run+0x40>
	else
	{
		struct UserProgramInfo* temp = running;
f01014fb:	8b 15 ec e0 19 f0    	mov    0xf019e0ec,%edx
		while( temp->next != NULL)
f0101501:	83 7a 1c 00          	cmpl   $0x0,0x1c(%edx)
f0101505:	74 09                	je     f0101510 <command_run+0x3d>
			temp = temp->next;
f0101507:	8b 52 1c             	mov    0x1c(%edx),%edx
f010150a:	83 7a 1c 00          	cmpl   $0x0,0x1c(%edx)
f010150e:	75 f7                	jne    f0101507 <command_run+0x34>
		temp->next = ptr_program_info;
f0101510:	89 42 1c             	mov    %eax,0x1c(%edx)
	}
	//[2] Run the created environment using "env_run" function
	env_run(ptr_program_info->environment);
f0101513:	83 ec 0c             	sub    $0xc,%esp
f0101516:	ff 70 0c             	pushl  0xc(%eax)
f0101519:	e8 02 18 00 00       	call   f0102d20 <env_run>
	return 0;
}
f010151e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101523:	c9                   	leave  
f0101524:	c3                   	ret    

f0101525 <command_kill>:

int command_kill(int number_of_arguments, char **arguments) {
f0101525:	55                   	push   %ebp
f0101526:	89 e5                	mov    %esp,%ebp
f0101528:	53                   	push   %ebx
f0101529:	83 ec 10             	sub    $0x10,%esp
	//[1] Get the user program info of the program (by searching in the "userPrograms" array
	struct UserProgramInfo* ptr_program_info = get_user_program_info(
f010152c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010152f:	ff 70 04             	pushl  0x4(%eax)
f0101532:	e8 6c 1c 00 00       	call   f01031a3 <get_user_program_info>
f0101537:	89 c3                	mov    %eax,%ebx
			arguments[1]);
	if (ptr_program_info == 0)
f0101539:	83 c4 10             	add    $0x10,%esp
f010153c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101541:	85 db                	test   %ebx,%ebx
f0101543:	74 50                	je     f0101595 <command_kill+0x70>
		return 0;
	struct UserProgramInfo* temp = running;
f0101545:	8b 15 ec e0 19 f0    	mov    0xf019e0ec,%edx
	if( temp != NULL && temp->name == ptr_program_info->name)
f010154b:	85 d2                	test   %edx,%edx
f010154d:	74 18                	je     f0101567 <command_kill+0x42>
f010154f:	8b 02                	mov    (%edx),%eax
f0101551:	3b 03                	cmp    (%ebx),%eax
f0101553:	75 12                	jne    f0101567 <command_kill+0x42>
		running = running->next;
f0101555:	8b 42 1c             	mov    0x1c(%edx),%eax
f0101558:	a3 ec e0 19 f0       	mov    %eax,0xf019e0ec
f010155d:	eb 1f                	jmp    f010157e <command_kill+0x59>
	else
	{
		while( temp->next != NULL )
		{
			if( temp->next->name == ptr_program_info->name)
			{
				temp->next = temp->next->next;
f010155f:	8b 41 1c             	mov    0x1c(%ecx),%eax
f0101562:	89 42 1c             	mov    %eax,0x1c(%edx)
				//delete temp1;
				break;
f0101565:	eb 17                	jmp    f010157e <command_kill+0x59>
f0101567:	83 7a 1c 00          	cmpl   $0x0,0x1c(%edx)
f010156b:	74 11                	je     f010157e <command_kill+0x59>
f010156d:	8b 4a 1c             	mov    0x1c(%edx),%ecx
f0101570:	8b 01                	mov    (%ecx),%eax
f0101572:	3b 03                	cmp    (%ebx),%eax
f0101574:	74 e9                	je     f010155f <command_kill+0x3a>
			}
			else
				temp = temp->next;
f0101576:	89 ca                	mov    %ecx,%edx
f0101578:	83 79 1c 00          	cmpl   $0x0,0x1c(%ecx)
f010157c:	75 ef                	jne    f010156d <command_kill+0x48>
		}
	}
	//[2] Kill its environment using "env_free" function
	env_free(ptr_program_info->environment);
f010157e:	83 ec 0c             	sub    $0xc,%esp
f0101581:	ff 73 0c             	pushl  0xc(%ebx)
f0101584:	e8 c9 17 00 00       	call   f0102d52 <env_free>
	ptr_program_info->environment = NULL;
f0101589:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	return 0;
f0101590:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101595:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0101598:	c9                   	leave  
f0101599:	c3                   	ret    
	...

f010159c <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

int nvram_read(int r)
{	
f010159c:	55                   	push   %ebp
f010159d:	89 e5                	mov    %esp,%ebp
f010159f:	56                   	push   %esi
f01015a0:	53                   	push   %ebx
f01015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01015a4:	83 ec 0c             	sub    $0xc,%esp
f01015a7:	53                   	push   %ebx
f01015a8:	e8 cb 1d 00 00       	call   f0103378 <mc146818_read>
f01015ad:	89 c6                	mov    %eax,%esi
f01015af:	43                   	inc    %ebx
f01015b0:	89 1c 24             	mov    %ebx,(%esp)
f01015b3:	e8 c0 1d 00 00       	call   f0103378 <mc146818_read>
f01015b8:	c1 e0 08             	shl    $0x8,%eax
f01015bb:	09 c6                	or     %eax,%esi
}
f01015bd:	89 f0                	mov    %esi,%eax
f01015bf:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01015c2:	5b                   	pop    %ebx
f01015c3:	5e                   	pop    %esi
f01015c4:	5d                   	pop    %ebp
f01015c5:	c3                   	ret    

f01015c6 <detect_memory>:
	
void detect_memory()
{
f01015c6:	55                   	push   %ebp
f01015c7:	89 e5                	mov    %esp,%ebp
f01015c9:	83 ec 14             	sub    $0x14,%esp
	// CMOS tells us how many kilobytes there are
	size_of_base_mem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PAGE_SIZE);
f01015cc:	6a 15                	push   $0x15
f01015ce:	e8 c9 ff ff ff       	call   f010159c <nvram_read>
f01015d3:	c1 e0 0a             	shl    $0xa,%eax
f01015d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01015db:	a3 74 e9 19 f0       	mov    %eax,0xf019e974
	size_of_extended_mem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PAGE_SIZE);
f01015e0:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01015e7:	e8 b0 ff ff ff       	call   f010159c <nvram_read>
f01015ec:	83 c4 10             	add    $0x10,%esp
f01015ef:	c1 e0 0a             	shl    $0xa,%eax
f01015f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01015f7:	a3 6c e9 19 f0       	mov    %eax,0xf019e96c

	// Calculate the maxmium physical address based on whether
	// or not there is any extended memory.  See comment in ../inc/mmu.h.
	if (size_of_extended_mem)
f01015fc:	85 c0                	test   %eax,%eax
f01015fe:	74 07                	je     f0101607 <detect_memory+0x41>
		maxpa = PHYS_EXTENDED_MEM + size_of_extended_mem;
f0101600:	05 00 00 10 00       	add    $0x100000,%eax
f0101605:	eb 05                	jmp    f010160c <detect_memory+0x46>
	else
		maxpa = size_of_extended_mem;
f0101607:	a1 6c e9 19 f0       	mov    0xf019e96c,%eax
f010160c:	a3 70 e9 19 f0       	mov    %eax,0xf019e970

	number_of_frames = maxpa / PAGE_SIZE;
f0101611:	a1 70 e9 19 f0       	mov    0xf019e970,%eax
f0101616:	89 c2                	mov    %eax,%edx
f0101618:	c1 ea 0c             	shr    $0xc,%edx
f010161b:	89 15 68 e9 19 f0    	mov    %edx,0xf019e968

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0101621:	83 ec 08             	sub    $0x8,%esp
f0101624:	c1 e8 0a             	shr    $0xa,%eax
f0101627:	50                   	push   %eax
f0101628:	68 a0 54 10 f0       	push   $0xf01054a0
f010162d:	e8 ac 1d 00 00       	call   f01033de <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(size_of_base_mem/1024), (int)(size_of_extended_mem/1024));
f0101632:	83 c4 0c             	add    $0xc,%esp
f0101635:	a1 6c e9 19 f0       	mov    0xf019e96c,%eax
f010163a:	c1 e8 0a             	shr    $0xa,%eax
f010163d:	50                   	push   %eax
f010163e:	a1 74 e9 19 f0       	mov    0xf019e974,%eax
f0101643:	c1 e8 0a             	shr    $0xa,%eax
f0101646:	50                   	push   %eax
f0101647:	68 a6 5a 10 f0       	push   $0xf0105aa6
f010164c:	e8 8d 1d 00 00       	call   f01033de <cprintf>
}
f0101651:	c9                   	leave  
f0101652:	c3                   	ret    

f0101653 <check_boot_pgdir>:

// --------------------------------------------------------------
// Set up initial memory mappings and turn on MMU.
// --------------------------------------------------------------

void check_boot_pgdir();

//
// Checks that the kernel part of virtual address space
// has been setup roughly correctly(by initialize_kernel_VM()).
//
// This function doesn't test every corner case,
// in fact it doesn't test the permission bits at all,
// but it is a pretty good check.
//
uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va);

void check_boot_pgdir()
{
f0101653:	55                   	push   %ebp
f0101654:	89 e5                	mov    %esp,%ebp
f0101656:	56                   	push   %esi
f0101657:	53                   	push   %ebx
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
f0101658:	a1 68 e9 19 f0       	mov    0xf019e968,%eax
f010165d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101660:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
f0101667:	89 c2                	mov    %eax,%edx
f0101669:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f010166f:	89 c6                	mov    %eax,%esi
f0101671:	29 d6                	sub    %edx,%esi
	for (i = 0; i < n; i += PAGE_SIZE)
f0101673:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101678:	39 f3                	cmp    %esi,%ebx
f010167a:	73 54                	jae    f01016d0 <check_boot_pgdir+0x7d>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);
f010167c:	83 ec 08             	sub    $0x8,%esp
f010167f:	8d 83 00 00 00 ef    	lea    0xef000000(%ebx),%eax
f0101685:	50                   	push   %eax
f0101686:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010168c:	e8 66 01 00 00       	call   f01017f7 <check_va2pa>
f0101691:	89 c2                	mov    %eax,%edx
f0101693:	83 c4 10             	add    $0x10,%esp
f0101696:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f010169b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016a0:	77 08                	ja     f01016aa <check_boot_pgdir+0x57>
f01016a2:	50                   	push   %eax
f01016a3:	68 20 53 10 f0       	push   $0xf0105320
f01016a8:	eb 15                	jmp    f01016bf <check_boot_pgdir+0x6c>
f01016aa:	8d 84 03 00 00 00 10 	lea    0x10000000(%ebx,%eax,1),%eax
f01016b1:	39 c2                	cmp    %eax,%edx
f01016b3:	74 11                	je     f01016c6 <check_boot_pgdir+0x73>
f01016b5:	68 e0 54 10 f0       	push   $0xf01054e0
f01016ba:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01016bf:	6a 5e                	push   $0x5e
f01016c1:	e9 0a 01 00 00       	jmp    f01017d0 <check_boot_pgdir+0x17d>
f01016c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016cc:	39 f3                	cmp    %esi,%ebx
f01016ce:	72 ac                	jb     f010167c <check_boot_pgdir+0x29>

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f01016d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);
f01016d5:	83 ec 08             	sub    $0x8,%esp
f01016d8:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f01016de:	50                   	push   %eax
f01016df:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01016e5:	e8 0d 01 00 00       	call   f01017f7 <check_va2pa>
f01016ea:	83 c4 10             	add    $0x10,%esp
f01016ed:	39 d8                	cmp    %ebx,%eax
f01016ef:	74 11                	je     f0101702 <check_boot_pgdir+0xaf>
f01016f1:	68 60 55 10 f0       	push   $0xf0105560
f01016f6:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01016fb:	6a 62                	push   $0x62
f01016fd:	e9 ce 00 00 00       	jmp    f01017d0 <check_boot_pgdir+0x17d>
f0101702:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101708:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
f010170e:	75 c5                	jne    f01016d5 <check_boot_pgdir+0x82>

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0101710:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101715:	be 00 60 11 f0       	mov    $0xf0116000,%esi
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);
f010171a:	83 ec 08             	sub    $0x8,%esp
f010171d:	8d 83 00 80 bf ef    	lea    0xefbf8000(%ebx),%eax
f0101723:	50                   	push   %eax
f0101724:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010172a:	e8 c8 00 00 00       	call   f01017f7 <check_va2pa>
f010172f:	89 c2                	mov    %eax,%edx
f0101731:	83 c4 10             	add    $0x10,%esp
f0101734:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010173a:	77 0c                	ja     f0101748 <check_boot_pgdir+0xf5>
f010173c:	68 00 60 11 f0       	push   $0xf0116000
f0101741:	68 20 53 10 f0       	push   $0xf0105320
f0101746:	eb 15                	jmp    f010175d <check_boot_pgdir+0x10a>
f0101748:	8d 84 33 00 00 00 10 	lea    0x10000000(%ebx,%esi,1),%eax
f010174f:	39 c2                	cmp    %eax,%edx
f0101751:	74 0e                	je     f0101761 <check_boot_pgdir+0x10e>
f0101753:	68 a0 55 10 f0       	push   $0xf01055a0
f0101758:	68 c2 5a 10 f0       	push   $0xf0105ac2
f010175d:	6a 66                	push   $0x66
f010175f:	eb 6f                	jmp    f01017d0 <check_boot_pgdir+0x17d>
f0101761:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101767:	81 fb ff 7f 00 00    	cmp    $0x7fff,%ebx
f010176d:	76 ab                	jbe    f010171a <check_boot_pgdir+0xc7>

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f010176f:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (i) {
f0101774:	8d 83 45 fc ff ff    	lea    0xfffffc45(%ebx),%eax
f010177a:	83 f8 04             	cmp    $0x4,%eax
f010177d:	77 19                	ja     f0101798 <check_boot_pgdir+0x145>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
f010177f:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0101784:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f0101788:	75 50                	jne    f01017da <check_boot_pgdir+0x187>
f010178a:	68 d7 5a 10 f0       	push   $0xf0105ad7
f010178f:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101794:	6a 70                	push   $0x70
f0101796:	eb 38                	jmp    f01017d0 <check_boot_pgdir+0x17d>
			break;
		default:
			if (i >= PDX(KERNEL_BASE))
f0101798:	81 fb bf 03 00 00    	cmp    $0x3bf,%ebx
f010179e:	76 19                	jbe    f01017b9 <check_boot_pgdir+0x166>
				assert(ptr_page_directory[i]);
f01017a0:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f01017a5:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f01017a9:	75 2f                	jne    f01017da <check_boot_pgdir+0x187>
f01017ab:	68 d7 5a 10 f0       	push   $0xf0105ad7
f01017b0:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01017b5:	6a 74                	push   $0x74
f01017b7:	eb 17                	jmp    f01017d0 <check_boot_pgdir+0x17d>
			else				
				assert(ptr_page_directory[i] == 0);
f01017b9:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f01017be:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f01017c2:	74 16                	je     f01017da <check_boot_pgdir+0x187>
f01017c4:	68 ed 5a 10 f0       	push   $0xf0105aed
f01017c9:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01017ce:	6a 76                	push   $0x76
f01017d0:	68 08 5b 10 f0       	push   $0xf0105b08
f01017d5:	e8 24 e9 ff ff       	call   f01000fe <_panic>
f01017da:	43                   	inc    %ebx
f01017db:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f01017e1:	76 91                	jbe    f0101774 <check_boot_pgdir+0x121>
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f01017e3:	83 ec 0c             	sub    $0xc,%esp
f01017e6:	68 20 56 10 f0       	push   $0xf0105620
f01017eb:	e8 ee 1b 00 00       	call   f01033de <cprintf>
}
f01017f0:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01017f3:	5b                   	pop    %ebx
f01017f4:	5e                   	pop    %esi
f01017f5:	5d                   	pop    %ebp
f01017f6:	c3                   	ret    

f01017f7 <check_va2pa>:

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'ptr_page_directory'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va)
{
f01017f7:	55                   	push   %ebp
f01017f8:	89 e5                	mov    %esp,%ebp
f01017fa:	53                   	push   %ebx
f01017fb:	83 ec 04             	sub    $0x4,%esp
f01017fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	uint32 *p;

	ptr_page_directory = &ptr_page_directory[PDX(va)];
f0101801:	89 c8                	mov    %ecx,%eax
f0101803:	c1 e8 16             	shr    $0x16,%eax
f0101806:	c1 e0 02             	shl    $0x2,%eax
f0101809:	03 45 08             	add    0x8(%ebp),%eax
	if (!(*ptr_page_directory & PERM_PRESENT))
f010180c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0101811:	f6 00 01             	testb  $0x1,(%eax)
f0101814:	74 58                	je     f010186e <check_va2pa+0x77>
		return ~0;
	p = (uint32*) K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(*ptr_page_directory));
f0101816:	8b 10                	mov    (%eax),%edx
f0101818:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010181e:	89 d0                	mov    %edx,%eax
f0101820:	c1 e8 0c             	shr    $0xc,%eax
f0101823:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f0101829:	72 15                	jb     f0101840 <check_va2pa+0x49>
f010182b:	52                   	push   %edx
f010182c:	68 40 56 10 f0       	push   $0xf0105640
f0101831:	68 89 00 00 00       	push   $0x89
f0101836:	68 08 5b 10 f0       	push   $0xf0105b08
f010183b:	e8 be e8 ff ff       	call   f01000fe <_panic>
f0101840:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	if (!(p[PTX(va)] & PERM_PRESENT))
f0101846:	89 c8                	mov    %ecx,%eax
f0101848:	c1 e8 0c             	shr    $0xc,%eax
f010184b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101850:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0101855:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0101859:	74 13                	je     f010186e <check_va2pa+0x77>
		return ~0;
	return EXTRACT_ADDRESS(p[PTX(va)]);
f010185b:	89 c8                	mov    %ecx,%eax
f010185d:	c1 e8 0c             	shr    $0xc,%eax
f0101860:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101865:	8b 1c 82             	mov    (%edx,%eax,4),%ebx
f0101868:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
}
f010186e:	89 d8                	mov    %ebx,%eax
f0101870:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0101873:	c9                   	leave  
f0101874:	c3                   	ret    

f0101875 <tlb_invalidate>:
		
void tlb_invalidate(uint32 *ptr_page_directory, void *virtual_address)
{
f0101875:	55                   	push   %ebp
f0101876:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
f0101878:	8b 45 0c             	mov    0xc(%ebp),%eax
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010187b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(virtual_address);
}
f010187e:	5d                   	pop    %ebp
f010187f:	c3                   	ret    

f0101880 <page_check>:

void page_check()
{
f0101880:	55                   	push   %ebp
f0101881:	89 e5                	mov    %esp,%ebp
f0101883:	56                   	push   %esi
f0101884:	53                   	push   %ebx
f0101885:	83 ec 1c             	sub    $0x1c,%esp
	struct Frame_Info *pp, *pp0, *pp1, *pp2;
	struct Linked_List fl;

	// should be able to allocate three frames_info
	pp0 = pp1 = pp2 = 0;
f0101888:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f010188f:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0101896:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	assert(allocate_frame(&pp0) == 0);
f010189d:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f01018a0:	50                   	push   %eax
f01018a1:	e8 68 0d 00 00       	call   f010260e <allocate_frame>
f01018a6:	83 c4 10             	add    $0x10,%esp
f01018a9:	85 c0                	test   %eax,%eax
f01018ab:	74 14                	je     f01018c1 <page_check+0x41>
f01018ad:	68 17 5b 10 f0       	push   $0xf0105b17
f01018b2:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01018b7:	68 9d 00 00 00       	push   $0x9d
f01018bc:	e9 80 07 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(allocate_frame(&pp1) == 0);
f01018c1:	83 ec 0c             	sub    $0xc,%esp
f01018c4:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01018c7:	50                   	push   %eax
f01018c8:	e8 41 0d 00 00       	call   f010260e <allocate_frame>
f01018cd:	83 c4 10             	add    $0x10,%esp
f01018d0:	85 c0                	test   %eax,%eax
f01018d2:	74 14                	je     f01018e8 <page_check+0x68>
f01018d4:	68 31 5b 10 f0       	push   $0xf0105b31
f01018d9:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01018de:	68 9e 00 00 00       	push   $0x9e
f01018e3:	e9 59 07 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(allocate_frame(&pp2) == 0);
f01018e8:	83 ec 0c             	sub    $0xc,%esp
f01018eb:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01018ee:	50                   	push   %eax
f01018ef:	e8 1a 0d 00 00       	call   f010260e <allocate_frame>
f01018f4:	83 c4 10             	add    $0x10,%esp
f01018f7:	85 c0                	test   %eax,%eax
f01018f9:	74 14                	je     f010190f <page_check+0x8f>
f01018fb:	68 4b 5b 10 f0       	push   $0xf0105b4b
f0101900:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101905:	68 9f 00 00 00       	push   $0x9f
f010190a:	e9 32 07 00 00       	jmp    f0102041 <page_check+0x7c1>

	assert(pp0);
f010190f:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0101913:	75 14                	jne    f0101929 <page_check+0xa9>
f0101915:	68 73 5b 10 f0       	push   $0xf0105b73
f010191a:	68 c2 5a 10 f0       	push   $0xf0105ac2
f010191f:	68 a1 00 00 00       	push   $0xa1
f0101924:	e9 18 07 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp1 && pp1 != pp0);
f0101929:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010192d:	74 08                	je     f0101937 <page_check+0xb7>
f010192f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101932:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f0101935:	75 14                	jne    f010194b <page_check+0xcb>
f0101937:	68 65 5b 10 f0       	push   $0xf0105b65
f010193c:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101941:	68 a2 00 00 00       	push   $0xa2
f0101946:	e9 f6 06 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010194b:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f010194f:	74 0d                	je     f010195e <page_check+0xde>
f0101951:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101954:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f0101957:	74 05                	je     f010195e <page_check+0xde>
f0101959:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f010195c:	75 14                	jne    f0101972 <page_check+0xf2>
f010195e:	68 80 56 10 f0       	push   $0xf0105680
f0101963:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101968:	68 a3 00 00 00       	push   $0xa3
f010196d:	e9 cf 06 00 00       	jmp    f0102041 <page_check+0x7c1>

	// temporarily steal the rest of the free frames_info
	fl = free_frame_list;
f0101972:	8b 35 78 e9 19 f0    	mov    0xf019e978,%esi
	LIST_INIT(&free_frame_list);
f0101978:	c7 05 78 e9 19 f0 00 	movl   $0x0,0xf019e978
f010197f:	00 00 00 

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101982:	83 ec 0c             	sub    $0xc,%esp
f0101985:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101988:	50                   	push   %eax
f0101989:	e8 80 0c 00 00       	call   f010260e <allocate_frame>
f010198e:	83 c4 10             	add    $0x10,%esp
f0101991:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101994:	74 14                	je     f01019aa <page_check+0x12a>
f0101996:	68 a0 56 10 f0       	push   $0xf01056a0
f010199b:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01019a0:	68 aa 00 00 00       	push   $0xaa
f01019a5:	e9 97 06 00 00       	jmp    f0102041 <page_check+0x7c1>

	// there is no free memory, so we can't allocate a page table 
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) < 0);
f01019aa:	6a 00                	push   $0x0
f01019ac:	6a 00                	push   $0x0
f01019ae:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f01019b1:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01019b7:	e8 f3 0d 00 00       	call   f01027af <map_frame>
f01019bc:	83 c4 10             	add    $0x10,%esp
f01019bf:	85 c0                	test   %eax,%eax
f01019c1:	78 14                	js     f01019d7 <page_check+0x157>
f01019c3:	68 c0 56 10 f0       	push   $0xf01056c0
f01019c8:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01019cd:	68 ad 00 00 00       	push   $0xad
f01019d2:	e9 6a 06 00 00       	jmp    f0102041 <page_check+0x7c1>

	// free pp0 and try again: pp0 should be used for page table
	free_frame(pp0);
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f01019dd:	e8 6f 0c 00 00       	call   f0102651 <free_frame>
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) == 0);
f01019e2:	6a 00                	push   $0x0
f01019e4:	6a 00                	push   $0x0
f01019e6:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f01019e9:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01019ef:	e8 bb 0d 00 00       	call   f01027af <map_frame>
f01019f4:	83 c4 20             	add    $0x20,%esp
f01019f7:	85 c0                	test   %eax,%eax
f01019f9:	74 14                	je     f0101a0f <page_check+0x18f>
f01019fb:	68 00 57 10 f0       	push   $0xf0105700
f0101a00:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101a05:	68 b1 00 00 00       	push   $0xb1
f0101a0a:	e9 32 06 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101a0f:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0101a14:	8b 18                	mov    (%eax),%ebx
f0101a16:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0101a1c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0101a1f:	2b 15 7c e9 19 f0    	sub    0xf019e97c,%edx
f0101a25:	c1 fa 02             	sar    $0x2,%edx
f0101a28:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0101a2b:	89 c1                	mov    %eax,%ecx
f0101a2d:	c1 e1 04             	shl    $0x4,%ecx
f0101a30:	01 c8                	add    %ecx,%eax
f0101a32:	89 c1                	mov    %eax,%ecx
f0101a34:	c1 e1 08             	shl    $0x8,%ecx
f0101a37:	01 c8                	add    %ecx,%eax
f0101a39:	89 c1                	mov    %eax,%ecx
f0101a3b:	c1 e1 10             	shl    $0x10,%ecx
f0101a3e:	01 c8                	add    %ecx,%eax
f0101a40:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0101a43:	c1 e0 0c             	shl    $0xc,%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101a46:	39 c3                	cmp    %eax,%ebx
f0101a48:	74 14                	je     f0101a5e <page_check+0x1de>
f0101a4a:	68 40 57 10 f0       	push   $0xf0105740
f0101a4f:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101a54:	68 b2 00 00 00       	push   $0xb2
f0101a59:	e9 e3 05 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, 0x0) == to_physical_address(pp1));
f0101a5e:	83 ec 08             	sub    $0x8,%esp
f0101a61:	6a 00                	push   $0x0
f0101a63:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101a69:	e8 89 fd ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101a6e:	83 c4 10             	add    $0x10,%esp
f0101a71:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101a74:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101a7a:	c1 f9 02             	sar    $0x2,%ecx
f0101a7d:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101a80:	89 d3                	mov    %edx,%ebx
f0101a82:	c1 e3 04             	shl    $0x4,%ebx
f0101a85:	01 da                	add    %ebx,%edx
f0101a87:	89 d3                	mov    %edx,%ebx
f0101a89:	c1 e3 08             	shl    $0x8,%ebx
f0101a8c:	01 da                	add    %ebx,%edx
f0101a8e:	89 d3                	mov    %edx,%ebx
f0101a90:	c1 e3 10             	shl    $0x10,%ebx
f0101a93:	01 da                	add    %ebx,%edx
f0101a95:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101a98:	c1 e2 0c             	shl    $0xc,%edx
f0101a9b:	39 d0                	cmp    %edx,%eax
f0101a9d:	74 14                	je     f0101ab3 <page_check+0x233>
f0101a9f:	68 a0 57 10 f0       	push   $0xf01057a0
f0101aa4:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101aa9:	68 b3 00 00 00       	push   $0xb3
f0101aae:	e9 8e 05 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp1->references == 1);
f0101ab3:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101ab6:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101abb:	74 14                	je     f0101ad1 <page_check+0x251>
f0101abd:	68 77 5b 10 f0       	push   $0xf0105b77
f0101ac2:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101ac7:	68 b4 00 00 00       	push   $0xb4
f0101acc:	e9 70 05 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp0->references == 1);
f0101ad1:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101ad4:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101ad9:	74 14                	je     f0101aef <page_check+0x26f>
f0101adb:	68 8c 5b 10 f0       	push   $0xf0105b8c
f0101ae0:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101ae5:	68 b5 00 00 00       	push   $0xb5
f0101aea:	e9 52 05 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should be able to map pp2 at PAGE_SIZE because pp0 is already allocated for page table
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101aef:	6a 00                	push   $0x0
f0101af1:	68 00 10 00 00       	push   $0x1000
f0101af6:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101af9:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101aff:	e8 ab 0c 00 00       	call   f01027af <map_frame>
f0101b04:	83 c4 10             	add    $0x10,%esp
f0101b07:	85 c0                	test   %eax,%eax
f0101b09:	74 14                	je     f0101b1f <page_check+0x29f>
f0101b0b:	68 00 58 10 f0       	push   $0xf0105800
f0101b10:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101b15:	68 b8 00 00 00       	push   $0xb8
f0101b1a:	e9 22 05 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f0101b1f:	83 ec 08             	sub    $0x8,%esp
f0101b22:	68 00 10 00 00       	push   $0x1000
f0101b27:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101b2d:	e8 c5 fc ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101b32:	83 c4 10             	add    $0x10,%esp
f0101b35:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101b38:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101b3e:	c1 f9 02             	sar    $0x2,%ecx
f0101b41:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101b44:	89 d3                	mov    %edx,%ebx
f0101b46:	c1 e3 04             	shl    $0x4,%ebx
f0101b49:	01 da                	add    %ebx,%edx
f0101b4b:	89 d3                	mov    %edx,%ebx
f0101b4d:	c1 e3 08             	shl    $0x8,%ebx
f0101b50:	01 da                	add    %ebx,%edx
f0101b52:	89 d3                	mov    %edx,%ebx
f0101b54:	c1 e3 10             	shl    $0x10,%ebx
f0101b57:	01 da                	add    %ebx,%edx
f0101b59:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101b5c:	c1 e2 0c             	shl    $0xc,%edx
f0101b5f:	39 d0                	cmp    %edx,%eax
f0101b61:	74 14                	je     f0101b77 <page_check+0x2f7>
f0101b63:	68 40 58 10 f0       	push   $0xf0105840
f0101b68:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101b6d:	68 b9 00 00 00       	push   $0xb9
f0101b72:	e9 ca 04 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2->references == 1);
f0101b77:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101b7a:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101b7f:	74 14                	je     f0101b95 <page_check+0x315>
f0101b81:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0101b86:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101b8b:	68 ba 00 00 00       	push   $0xba
f0101b90:	e9 ac 04 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101b95:	83 ec 0c             	sub    $0xc,%esp
f0101b98:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101b9b:	50                   	push   %eax
f0101b9c:	e8 6d 0a 00 00       	call   f010260e <allocate_frame>
f0101ba1:	83 c4 10             	add    $0x10,%esp
f0101ba4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101ba7:	74 14                	je     f0101bbd <page_check+0x33d>
f0101ba9:	68 a0 56 10 f0       	push   $0xf01056a0
f0101bae:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101bb3:	68 bd 00 00 00       	push   $0xbd
f0101bb8:	e9 84 04 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should be able to map pp2 at PAGE_SIZE because it's already there
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101bbd:	6a 00                	push   $0x0
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101bc7:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101bcd:	e8 dd 0b 00 00       	call   f01027af <map_frame>
f0101bd2:	83 c4 10             	add    $0x10,%esp
f0101bd5:	85 c0                	test   %eax,%eax
f0101bd7:	74 14                	je     f0101bed <page_check+0x36d>
f0101bd9:	68 00 58 10 f0       	push   $0xf0105800
f0101bde:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101be3:	68 c0 00 00 00       	push   $0xc0
f0101be8:	e9 54 04 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f0101bed:	83 ec 08             	sub    $0x8,%esp
f0101bf0:	68 00 10 00 00       	push   $0x1000
f0101bf5:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101bfb:	e8 f7 fb ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101c00:	83 c4 10             	add    $0x10,%esp
f0101c03:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101c06:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101c0c:	c1 f9 02             	sar    $0x2,%ecx
f0101c0f:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101c12:	89 d3                	mov    %edx,%ebx
f0101c14:	c1 e3 04             	shl    $0x4,%ebx
f0101c17:	01 da                	add    %ebx,%edx
f0101c19:	89 d3                	mov    %edx,%ebx
f0101c1b:	c1 e3 08             	shl    $0x8,%ebx
f0101c1e:	01 da                	add    %ebx,%edx
f0101c20:	89 d3                	mov    %edx,%ebx
f0101c22:	c1 e3 10             	shl    $0x10,%ebx
f0101c25:	01 da                	add    %ebx,%edx
f0101c27:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101c2a:	c1 e2 0c             	shl    $0xc,%edx
f0101c2d:	39 d0                	cmp    %edx,%eax
f0101c2f:	74 14                	je     f0101c45 <page_check+0x3c5>
f0101c31:	68 40 58 10 f0       	push   $0xf0105840
f0101c36:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101c3b:	68 c1 00 00 00       	push   $0xc1
f0101c40:	e9 fc 03 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2->references == 1);
f0101c45:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101c48:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101c4d:	74 14                	je     f0101c63 <page_check+0x3e3>
f0101c4f:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0101c54:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101c59:	68 c2 00 00 00       	push   $0xc2
f0101c5e:	e9 de 03 00 00       	jmp    f0102041 <page_check+0x7c1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in map_frame
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101c63:	83 ec 0c             	sub    $0xc,%esp
f0101c66:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101c69:	50                   	push   %eax
f0101c6a:	e8 9f 09 00 00       	call   f010260e <allocate_frame>
f0101c6f:	83 c4 10             	add    $0x10,%esp
f0101c72:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101c75:	74 14                	je     f0101c8b <page_check+0x40b>
f0101c77:	68 a0 56 10 f0       	push   $0xf01056a0
f0101c7c:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101c81:	68 c6 00 00 00       	push   $0xc6
f0101c86:	e9 b6 03 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should not be able to map at PTSIZE because need free frame for page table
	assert(map_frame(ptr_page_directory, pp0, (void*) PTSIZE, 0) < 0);
f0101c8b:	6a 00                	push   $0x0
f0101c8d:	68 00 00 40 00       	push   $0x400000
f0101c92:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101c95:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101c9b:	e8 0f 0b 00 00       	call   f01027af <map_frame>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	85 c0                	test   %eax,%eax
f0101ca5:	78 14                	js     f0101cbb <page_check+0x43b>
f0101ca7:	68 a0 58 10 f0       	push   $0xf01058a0
f0101cac:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101cb1:	68 c9 00 00 00       	push   $0xc9
f0101cb6:	e9 86 03 00 00       	jmp    f0102041 <page_check+0x7c1>

	// insert pp1 at PAGE_SIZE (replacing pp2)
	assert(map_frame(ptr_page_directory, pp1, (void*) PAGE_SIZE, 0) == 0);
f0101cbb:	6a 00                	push   $0x0
f0101cbd:	68 00 10 00 00       	push   $0x1000
f0101cc2:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101cc5:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101ccb:	e8 df 0a 00 00       	call   f01027af <map_frame>
f0101cd0:	83 c4 10             	add    $0x10,%esp
f0101cd3:	85 c0                	test   %eax,%eax
f0101cd5:	74 14                	je     f0101ceb <page_check+0x46b>
f0101cd7:	68 e0 58 10 f0       	push   $0xf01058e0
f0101cdc:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101ce1:	68 cc 00 00 00       	push   $0xcc
f0101ce6:	e9 56 03 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should have pp1 at both 0 and PAGE_SIZE, pp2 nowhere, ...
	assert(check_va2pa(ptr_page_directory, 0) == to_physical_address(pp1));
f0101ceb:	83 ec 08             	sub    $0x8,%esp
f0101cee:	6a 00                	push   $0x0
f0101cf0:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101cf6:	e8 fc fa ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101cfb:	83 c4 10             	add    $0x10,%esp
f0101cfe:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101d01:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101d07:	c1 f9 02             	sar    $0x2,%ecx
f0101d0a:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101d0d:	89 d3                	mov    %edx,%ebx
f0101d0f:	c1 e3 04             	shl    $0x4,%ebx
f0101d12:	01 da                	add    %ebx,%edx
f0101d14:	89 d3                	mov    %edx,%ebx
f0101d16:	c1 e3 08             	shl    $0x8,%ebx
f0101d19:	01 da                	add    %ebx,%edx
f0101d1b:	89 d3                	mov    %edx,%ebx
f0101d1d:	c1 e3 10             	shl    $0x10,%ebx
f0101d20:	01 da                	add    %ebx,%edx
f0101d22:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101d25:	c1 e2 0c             	shl    $0xc,%edx
f0101d28:	39 d0                	cmp    %edx,%eax
f0101d2a:	74 14                	je     f0101d40 <page_check+0x4c0>
f0101d2c:	68 20 59 10 f0       	push   $0xf0105920
f0101d31:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101d36:	68 cf 00 00 00       	push   $0xcf
f0101d3b:	e9 01 03 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101d40:	83 ec 08             	sub    $0x8,%esp
f0101d43:	68 00 10 00 00       	push   $0x1000
f0101d48:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101d4e:	e8 a4 fa ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101d59:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101d5f:	c1 f9 02             	sar    $0x2,%ecx
f0101d62:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101d65:	89 d3                	mov    %edx,%ebx
f0101d67:	c1 e3 04             	shl    $0x4,%ebx
f0101d6a:	01 da                	add    %ebx,%edx
f0101d6c:	89 d3                	mov    %edx,%ebx
f0101d6e:	c1 e3 08             	shl    $0x8,%ebx
f0101d71:	01 da                	add    %ebx,%edx
f0101d73:	89 d3                	mov    %edx,%ebx
f0101d75:	c1 e3 10             	shl    $0x10,%ebx
f0101d78:	01 da                	add    %ebx,%edx
f0101d7a:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101d7d:	c1 e2 0c             	shl    $0xc,%edx
f0101d80:	39 d0                	cmp    %edx,%eax
f0101d82:	74 14                	je     f0101d98 <page_check+0x518>
f0101d84:	68 60 59 10 f0       	push   $0xf0105960
f0101d89:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101d8e:	68 d0 00 00 00       	push   $0xd0
f0101d93:	e9 a9 02 00 00       	jmp    f0102041 <page_check+0x7c1>
	// ... and ref counts should reflect this
	assert(pp1->references == 2);
f0101d98:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101d9b:	66 83 78 08 02       	cmpw   $0x2,0x8(%eax)
f0101da0:	74 14                	je     f0101db6 <page_check+0x536>
f0101da2:	68 b6 5b 10 f0       	push   $0xf0105bb6
f0101da7:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101dac:	68 d2 00 00 00       	push   $0xd2
f0101db1:	e9 8b 02 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101db6:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101db9:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101dbe:	74 14                	je     f0101dd4 <page_check+0x554>
f0101dc0:	68 cb 5b 10 f0       	push   $0xf0105bcb
f0101dc5:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101dca:	68 d3 00 00 00       	push   $0xd3
f0101dcf:	e9 6d 02 00 00       	jmp    f0102041 <page_check+0x7c1>

	// pp2 should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp2);
f0101dd4:	83 ec 0c             	sub    $0xc,%esp
f0101dd7:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101dda:	50                   	push   %eax
f0101ddb:	e8 2e 08 00 00       	call   f010260e <allocate_frame>
f0101de0:	83 c4 10             	add    $0x10,%esp
f0101de3:	85 c0                	test   %eax,%eax
f0101de5:	75 08                	jne    f0101def <page_check+0x56f>
f0101de7:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101dea:	3b 45 ec             	cmp    0xffffffec(%ebp),%eax
f0101ded:	74 14                	je     f0101e03 <page_check+0x583>
f0101def:	68 c0 59 10 f0       	push   $0xf01059c0
f0101df4:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101df9:	68 d6 00 00 00       	push   $0xd6
f0101dfe:	e9 3e 02 00 00       	jmp    f0102041 <page_check+0x7c1>

	// unmapping pp1 at 0 should keep pp1 at PAGE_SIZE
	unmap_frame(ptr_page_directory, 0x0);
f0101e03:	83 ec 08             	sub    $0x8,%esp
f0101e06:	6a 00                	push   $0x0
f0101e08:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101e0e:	e8 c9 0a 00 00       	call   f01028dc <unmap_frame>
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101e13:	83 c4 08             	add    $0x8,%esp
f0101e16:	6a 00                	push   $0x0
f0101e18:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101e1e:	e8 d4 f9 ff ff       	call   f01017f7 <check_va2pa>
f0101e23:	83 c4 10             	add    $0x10,%esp
f0101e26:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e29:	74 14                	je     f0101e3f <page_check+0x5bf>
f0101e2b:	68 00 5a 10 f0       	push   $0xf0105a00
f0101e30:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101e35:	68 da 00 00 00       	push   $0xda
f0101e3a:	e9 02 02 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101e3f:	83 ec 08             	sub    $0x8,%esp
f0101e42:	68 00 10 00 00       	push   $0x1000
f0101e47:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101e4d:	e8 a5 f9 ff ff       	call   f01017f7 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101e52:	83 c4 10             	add    $0x10,%esp
f0101e55:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101e58:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f0101e5e:	c1 f9 02             	sar    $0x2,%ecx
f0101e61:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101e64:	89 d3                	mov    %edx,%ebx
f0101e66:	c1 e3 04             	shl    $0x4,%ebx
f0101e69:	01 da                	add    %ebx,%edx
f0101e6b:	89 d3                	mov    %edx,%ebx
f0101e6d:	c1 e3 08             	shl    $0x8,%ebx
f0101e70:	01 da                	add    %ebx,%edx
f0101e72:	89 d3                	mov    %edx,%ebx
f0101e74:	c1 e3 10             	shl    $0x10,%ebx
f0101e77:	01 da                	add    %ebx,%edx
f0101e79:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101e7c:	c1 e2 0c             	shl    $0xc,%edx
f0101e7f:	39 d0                	cmp    %edx,%eax
f0101e81:	74 14                	je     f0101e97 <page_check+0x617>
f0101e83:	68 60 59 10 f0       	push   $0xf0105960
f0101e88:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101e8d:	68 db 00 00 00       	push   $0xdb
f0101e92:	e9 aa 01 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp1->references == 1);
f0101e97:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101e9a:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101e9f:	74 14                	je     f0101eb5 <page_check+0x635>
f0101ea1:	68 77 5b 10 f0       	push   $0xf0105b77
f0101ea6:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101eab:	68 dc 00 00 00       	push   $0xdc
f0101eb0:	e9 8c 01 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101eb5:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101eb8:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101ebd:	74 14                	je     f0101ed3 <page_check+0x653>
f0101ebf:	68 cb 5b 10 f0       	push   $0xf0105bcb
f0101ec4:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101ec9:	68 dd 00 00 00       	push   $0xdd
f0101ece:	e9 6e 01 00 00       	jmp    f0102041 <page_check+0x7c1>

	// unmapping pp1 at PAGE_SIZE should free it
	unmap_frame(ptr_page_directory, (void*) PAGE_SIZE);
f0101ed3:	83 ec 08             	sub    $0x8,%esp
f0101ed6:	68 00 10 00 00       	push   $0x1000
f0101edb:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101ee1:	e8 f6 09 00 00       	call   f01028dc <unmap_frame>
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101ee6:	83 c4 08             	add    $0x8,%esp
f0101ee9:	6a 00                	push   $0x0
f0101eeb:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101ef1:	e8 01 f9 ff ff       	call   f01017f7 <check_va2pa>
f0101ef6:	83 c4 10             	add    $0x10,%esp
f0101ef9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101efc:	74 14                	je     f0101f12 <page_check+0x692>
f0101efe:	68 00 5a 10 f0       	push   $0xf0105a00
f0101f03:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101f08:	68 e1 00 00 00       	push   $0xe1
f0101f0d:	e9 2f 01 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == ~0);
f0101f12:	83 ec 08             	sub    $0x8,%esp
f0101f15:	68 00 10 00 00       	push   $0x1000
f0101f1a:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0101f20:	e8 d2 f8 ff ff       	call   f01017f7 <check_va2pa>
f0101f25:	83 c4 10             	add    $0x10,%esp
f0101f28:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f2b:	74 14                	je     f0101f41 <page_check+0x6c1>
f0101f2d:	68 40 5a 10 f0       	push   $0xf0105a40
f0101f32:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101f37:	68 e2 00 00 00       	push   $0xe2
f0101f3c:	e9 00 01 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp1->references == 0);
f0101f41:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101f44:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f49:	74 14                	je     f0101f5f <page_check+0x6df>
f0101f4b:	68 e0 5b 10 f0       	push   $0xf0105be0
f0101f50:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101f55:	68 e3 00 00 00       	push   $0xe3
f0101f5a:	e9 e2 00 00 00       	jmp    f0102041 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101f5f:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101f62:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f67:	74 14                	je     f0101f7d <page_check+0x6fd>
f0101f69:	68 cb 5b 10 f0       	push   $0xf0105bcb
f0101f6e:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101f73:	68 e4 00 00 00       	push   $0xe4
f0101f78:	e9 c4 00 00 00       	jmp    f0102041 <page_check+0x7c1>

	// so it should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp1);
f0101f7d:	83 ec 0c             	sub    $0xc,%esp
f0101f80:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101f83:	50                   	push   %eax
f0101f84:	e8 85 06 00 00       	call   f010260e <allocate_frame>
f0101f89:	83 c4 10             	add    $0x10,%esp
f0101f8c:	85 c0                	test   %eax,%eax
f0101f8e:	75 08                	jne    f0101f98 <page_check+0x718>
f0101f90:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101f93:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f0101f96:	74 14                	je     f0101fac <page_check+0x72c>
f0101f98:	68 80 5a 10 f0       	push   $0xf0105a80
f0101f9d:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101fa2:	68 e7 00 00 00       	push   $0xe7
f0101fa7:	e9 95 00 00 00       	jmp    f0102041 <page_check+0x7c1>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101fac:	83 ec 0c             	sub    $0xc,%esp
f0101faf:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101fb2:	50                   	push   %eax
f0101fb3:	e8 56 06 00 00       	call   f010260e <allocate_frame>
f0101fb8:	83 c4 10             	add    $0x10,%esp
f0101fbb:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101fbe:	74 11                	je     f0101fd1 <page_check+0x751>
f0101fc0:	68 a0 56 10 f0       	push   $0xf01056a0
f0101fc5:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0101fca:	68 ea 00 00 00       	push   $0xea
f0101fcf:	eb 70                	jmp    f0102041 <page_check+0x7c1>

	// forcibly take pp0 back
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101fd1:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0101fd6:	8b 18                	mov    (%eax),%ebx
f0101fd8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0101fde:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0101fe1:	2b 15 7c e9 19 f0    	sub    0xf019e97c,%edx
f0101fe7:	c1 fa 02             	sar    $0x2,%edx
f0101fea:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0101fed:	89 c1                	mov    %eax,%ecx
f0101fef:	c1 e1 04             	shl    $0x4,%ecx
f0101ff2:	01 c8                	add    %ecx,%eax
f0101ff4:	89 c1                	mov    %eax,%ecx
f0101ff6:	c1 e1 08             	shl    $0x8,%ecx
f0101ff9:	01 c8                	add    %ecx,%eax
f0101ffb:	89 c1                	mov    %eax,%ecx
f0101ffd:	c1 e1 10             	shl    $0x10,%ecx
f0102000:	01 c8                	add    %ecx,%eax
f0102002:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0102005:	c1 e0 0c             	shl    $0xc,%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0102008:	39 c3                	cmp    %eax,%ebx
f010200a:	74 11                	je     f010201d <page_check+0x79d>
f010200c:	68 40 57 10 f0       	push   $0xf0105740
f0102011:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0102016:	68 ed 00 00 00       	push   $0xed
f010201b:	eb 24                	jmp    f0102041 <page_check+0x7c1>
	ptr_page_directory[0] = 0;
f010201d:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0102022:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->references == 1);
f0102028:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f010202b:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102030:	74 19                	je     f010204b <page_check+0x7cb>
f0102032:	68 8c 5b 10 f0       	push   $0xf0105b8c
f0102037:	68 c2 5a 10 f0       	push   $0xf0105ac2
f010203c:	68 ef 00 00 00       	push   $0xef
f0102041:	68 08 5b 10 f0       	push   $0xf0105b08
f0102046:	e8 b3 e0 ff ff       	call   f01000fe <_panic>
	pp0->references = 0;
f010204b:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f010204e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	free_frame_list = fl;
f0102054:	89 35 78 e9 19 f0    	mov    %esi,0xf019e978

	// free the frames_info we took
	free_frame(pp0);
f010205a:	83 ec 0c             	sub    $0xc,%esp
f010205d:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0102060:	e8 ec 05 00 00       	call   f0102651 <free_frame>
	free_frame(pp1);
f0102065:	83 c4 04             	add    $0x4,%esp
f0102068:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f010206b:	e8 e1 05 00 00       	call   f0102651 <free_frame>
	free_frame(pp2);
f0102070:	83 c4 04             	add    $0x4,%esp
f0102073:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0102076:	e8 d6 05 00 00       	call   f0102651 <free_frame>

	cprintf("page_check() succeeded!\n");
f010207b:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0102082:	e8 57 13 00 00       	call   f01033de <cprintf>
}
f0102087:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f010208a:	5b                   	pop    %ebx
f010208b:	5e                   	pop    %esi
f010208c:	5d                   	pop    %ebp
f010208d:	c3                   	ret    

f010208e <turn_on_paging>:

void turn_on_paging()
{
f010208e:	55                   	push   %ebp
f010208f:	89 e5                	mov    %esp,%ebp
	//////////////////////////////////////////////////////////////////////
	// On x86, segmentation maps a VA to a LA (linear addr) and
	// paging maps the LA to a PA.  I.e. VA => LA => PA.  If paging is
	// turned off the LA is used as the PA.  Note: there is no way to
	// turn off segmentation.  The closest thing is to set the base
	// address to 0, so the VA => LA mapping is the identity.

	// Current mapping: VA (KERNEL_BASE+x) => PA (x).
	//     (segmentation base = -KERNEL_BASE and paging is off)

	// From here on down we must maintain this VA (KERNEL_BASE + x) => PA (x)
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA (KERNEL_BASE), i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	ptr_page_directory[0] = ptr_page_directory[PDX(KERNEL_BASE)];
f0102091:	8b 15 84 e9 19 f0    	mov    0xf019e984,%edx
f0102097:	8b 82 00 0f 00 00    	mov    0xf00(%edx),%eax
f010209d:	89 02                	mov    %eax,(%edx)
}

static __inline void
lcr3(uint32 val)
{
f010209f:	a1 88 e9 19 f0       	mov    0xf019e988,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01020a4:	0f 22 d8             	mov    %eax,%cr3
f01020a7:	0f 20 c0             	mov    %cr0,%eax

	// Install page table.
	lcr3(phys_page_directory);

	// Turn on paging.
	uint32 cr0;
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f01020aa:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32 val)
{
f01020af:	83 e0 f3             	and    $0xfffffff3,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01020b2:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Current mapping: KERNEL_BASE+x => x => x.
	// (x < 4MB so uses paging ptr_page_directory[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f01020b5:	0f 01 15 10 e7 11 f0 	lgdtl  0xf011e710
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01020bc:	b8 23 00 00 00       	mov    $0x23,%eax
f01020c1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01020c3:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01020c5:	b8 10 00 00 00       	mov    $0x10,%eax
f01020ca:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01020cc:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01020ce:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f01020d0:	ea d7 20 10 f0 08 00 	ljmp   $0x8,$0xf01020d7
	asm volatile("lldt %%ax" :: "a" (0));
f01020d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01020dc:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNEL_BASE + x => KERNEL_BASE + x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	ptr_page_directory[0] = 0;
f01020df:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f01020e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
lcr3(uint32 val)
{
f01020ea:	a1 88 e9 19 f0       	mov    0xf019e988,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01020ef:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the ptr_page_directory[0] mapping.
	lcr3(phys_page_directory);
}
f01020f2:	5d                   	pop    %ebp
f01020f3:	c3                   	ret    

f01020f4 <setup_listing_to_all_page_tables_entries>:

void setup_listing_to_all_page_tables_entries()
{
f01020f4:	55                   	push   %ebp
f01020f5:	89 e5                	mov    %esp,%ebp
f01020f7:	83 ec 08             	sub    $0x8,%esp
	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.

	// Permissions: kernel RW, user NONE
	uint32 phys_frame_address = K_PHYSICAL_ADDRESS(ptr_page_directory);
f01020fa:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f01020ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102104:	77 0d                	ja     f0102113 <setup_listing_to_all_page_tables_entries+0x1f>
f0102106:	50                   	push   %eax
f0102107:	68 20 53 10 f0       	push   $0xf0105320
f010210c:	68 39 01 00 00       	push   $0x139
f0102111:	eb 2f                	jmp    f0102142 <setup_listing_to_all_page_tables_entries+0x4e>
f0102113:	05 00 00 00 10       	add    $0x10000000,%eax
	ptr_page_directory[PDX(VPT)] = CONSTRUCT_ENTRY(phys_frame_address , PERM_PRESENT | PERM_WRITEABLE);
f0102118:	83 c8 03             	or     $0x3,%eax
f010211b:	8b 15 84 e9 19 f0    	mov    0xf019e984,%edx
f0102121:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)

	// same for UVPT
	//Permissions: kernel R, user R
	ptr_page_directory[PDX(UVPT)] = K_PHYSICAL_ADDRESS(ptr_page_directory)|PERM_USER|PERM_PRESENT;
f0102127:	8b 15 84 e9 19 f0    	mov    0xf019e984,%edx
f010212d:	89 d0                	mov    %edx,%eax
f010212f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102135:	77 15                	ja     f010214c <setup_listing_to_all_page_tables_entries+0x58>
f0102137:	52                   	push   %edx
f0102138:	68 20 53 10 f0       	push   $0xf0105320
f010213d:	68 3e 01 00 00       	push   $0x13e
f0102142:	68 08 5b 10 f0       	push   $0xf0105b08
f0102147:	e8 b2 df ff ff       	call   f01000fe <_panic>
f010214c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102151:	83 c8 05             	or     $0x5,%eax
f0102154:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)

}
f010215a:	c9                   	leave  
f010215b:	c3                   	ret    

f010215c <envid2env>:

//
// Converts an envid to an env pointer.
//
// RETURNS
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int envid2env(int32  envid, struct Env **env_store, bool checkperm)
{
f010215c:	55                   	push   %ebp
f010215d:	89 e5                	mov    %esp,%ebp
f010215f:	56                   	push   %esi
f0102160:	53                   	push   %ebx
f0102161:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0102164:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102167:	85 db                	test   %ebx,%ebx
f0102169:	75 09                	jne    f0102174 <envid2env+0x18>
		*env_store = curenv;
f010216b:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0102170:	89 06                	mov    %eax,(%esi)
		return 0;
f0102172:	eb 4b                	jmp    f01021bf <envid2env+0x63>
	}

	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102174:	89 d8                	mov    %ebx,%eax
f0102176:	25 ff 03 00 00       	and    $0x3ff,%eax
f010217b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010217e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102181:	8b 15 f0 e0 19 f0    	mov    0xf019e0f0,%edx
f0102187:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010218a:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f010218e:	74 20                	je     f01021b0 <envid2env+0x54>
f0102190:	39 59 4c             	cmp    %ebx,0x4c(%ecx)
f0102193:	75 1b                	jne    f01021b0 <envid2env+0x54>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102195:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102199:	74 22                	je     f01021bd <envid2env+0x61>
f010219b:	3b 0d f4 e0 19 f0    	cmp    0xf019e0f4,%ecx
f01021a1:	74 1a                	je     f01021bd <envid2env+0x61>
f01021a3:	8b 51 50             	mov    0x50(%ecx),%edx
f01021a6:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01021ab:	3b 50 4c             	cmp    0x4c(%eax),%edx
f01021ae:	74 0d                	je     f01021bd <envid2env+0x61>
		*env_store = 0;
f01021b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01021b6:	b8 02 00 00 00       	mov    $0x2,%eax
f01021bb:	eb 07                	jmp    f01021c4 <envid2env+0x68>
	}

	*env_store = e;
f01021bd:	89 0e                	mov    %ecx,(%esi)
	return 0;
f01021bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01021c4:	5b                   	pop    %ebx
f01021c5:	5e                   	pop    %esi
f01021c6:	5d                   	pop    %ebp
f01021c7:	c3                   	ret    

f01021c8 <initialize_kernel_VM>:
// From USER_TOP to USER_LIMIT, the user is allowed to read but not write.
// Above USER_LIMIT the user cannot read (or write).

void initialize_kernel_VM()
{
f01021c8:	55                   	push   %ebp
f01021c9:	89 e5                	mov    %esp,%ebp
f01021cb:	53                   	push   %ebx
f01021cc:	83 ec 0c             	sub    $0xc,%esp
	// Remove this line when you're ready to test this function.
	//panic("initialize_kernel_VM: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	ptr_page_directory = boot_allocate_space(PAGE_SIZE, PAGE_SIZE);
f01021cf:	68 00 10 00 00       	push   $0x1000
f01021d4:	68 00 10 00 00       	push   $0x1000
f01021d9:	e8 5b 01 00 00       	call   f0102339 <boot_allocate_space>
f01021de:	a3 84 e9 19 f0       	mov    %eax,0xf019e984
	memset(ptr_page_directory, 0, PAGE_SIZE);
f01021e3:	83 c4 0c             	add    $0xc,%esp
f01021e6:	68 00 10 00 00       	push   $0x1000
f01021eb:	6a 00                	push   $0x0
f01021ed:	50                   	push   %eax
f01021ee:	e8 9c 22 00 00       	call   f010448f <memset>
	phys_page_directory = K_PHYSICAL_ADDRESS(ptr_page_directory);
f01021f3:	83 c4 10             	add    $0x10,%esp
f01021f6:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f01021fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102200:	77 0d                	ja     f010220f <initialize_kernel_VM+0x47>
f0102202:	50                   	push   %eax
f0102203:	68 20 53 10 f0       	push   $0xf0105320
f0102208:	6a 3c                	push   $0x3c
f010220a:	e9 e2 00 00 00       	jmp    f01022f1 <initialize_kernel_VM+0x129>
f010220f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102214:	a3 88 e9 19 f0       	mov    %eax,0xf019e988

	//////////////////////////////////////////////////////////////////////
	// Map the kernel stack with VA range :
	//  [KERNEL_STACK_TOP-KERNEL_STACK_SIZE, KERNEL_STACK_TOP), 
	// to physical address : "phys_stack_bottom".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_range(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE, K_PHYSICAL_ADDRESS(ptr_stack_bottom), PERM_WRITEABLE) ;
f0102219:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010221e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102223:	77 0d                	ja     f0102232 <initialize_kernel_VM+0x6a>
f0102225:	50                   	push   %eax
f0102226:	68 20 53 10 f0       	push   $0xf0105320
f010222b:	6a 44                	push   $0x44
f010222d:	e9 bf 00 00 00       	jmp    f01022f1 <initialize_kernel_VM+0x129>
f0102232:	05 00 00 00 10       	add    $0x10000000,%eax
f0102237:	83 ec 0c             	sub    $0xc,%esp
f010223a:	6a 02                	push   $0x2
f010223c:	50                   	push   %eax
f010223d:	68 00 80 00 00       	push   $0x8000
f0102242:	68 00 80 bf ef       	push   $0xefbf8000
f0102247:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f010224d:	e8 19 01 00 00       	call   f010236b <boot_map_range>

	//////////////////////////////////////////////////////////////////////
	// Map all of physical memory at KERNEL_BASE.
	// i.e.  the VA range [KERNEL_BASE, 2^32) should map to
	//      the PA range [0, 2^32 - KERNEL_BASE)
	// We might not have 2^32 - KERNEL_BASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_range(ptr_page_directory, KERNEL_BASE, 0xFFFFFFFF - KERNEL_BASE, 0, PERM_WRITEABLE) ;
f0102252:	83 c4 14             	add    $0x14,%esp
f0102255:	6a 02                	push   $0x2
f0102257:	6a 00                	push   $0x0
f0102259:	68 ff ff ff 0f       	push   $0xfffffff
f010225e:	68 00 00 00 f0       	push   $0xf0000000
f0102263:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0102269:	e8 fd 00 00 00       	call   f010236b <boot_map_range>

	//////////////////////////////////////////////////////////////////////
	// Make 'frames_info' point to an array of size 'number_of_frames' of 'struct Frame_Info'.
	// The kernel uses this structure to keep track of physical frames;
	// 'number_of_frames' equals the number of physical frames in memory.  User-level
	// programs get read-only access to the array as well.
	// You must allocate the array yourself.
	// Map this array read-only by the user at virtual address READ_ONLY_FRAMES_INFO
	// (ie. perm = PERM_USER | PERM_PRESENT)
	// Permissions:
	//    - frames_info -- kernel RW, user NONE
	//    - the image mapped at READ_ONLY_FRAMES_INFO  -- kernel R, user R
	// Your code goes here:
	uint32 array_size;
	array_size = number_of_frames * sizeof(struct Frame_Info) ;
f010226e:	a1 68 e9 19 f0       	mov    0xf019e968,%eax
f0102273:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102276:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
	frames_info = boot_allocate_space(array_size, PAGE_SIZE);
f010227d:	83 c4 18             	add    $0x18,%esp
f0102280:	68 00 10 00 00       	push   $0x1000
f0102285:	53                   	push   %ebx
f0102286:	e8 ae 00 00 00       	call   f0102339 <boot_allocate_space>
f010228b:	a3 7c e9 19 f0       	mov    %eax,0xf019e97c
	boot_map_range(ptr_page_directory, READ_ONLY_FRAMES_INFO, array_size, K_PHYSICAL_ADDRESS(frames_info), PERM_USER) ;
f0102290:	83 c4 10             	add    $0x10,%esp
f0102293:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102298:	77 0a                	ja     f01022a4 <initialize_kernel_VM+0xdc>
f010229a:	50                   	push   %eax
f010229b:	68 20 53 10 f0       	push   $0xf0105320
f01022a0:	6a 5f                	push   $0x5f
f01022a2:	eb 4d                	jmp    f01022f1 <initialize_kernel_VM+0x129>
f01022a4:	05 00 00 00 10       	add    $0x10000000,%eax
f01022a9:	83 ec 0c             	sub    $0xc,%esp
f01022ac:	6a 04                	push   $0x4
f01022ae:	50                   	push   %eax
f01022af:	53                   	push   %ebx
f01022b0:	68 00 00 00 ef       	push   $0xef000000
f01022b5:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f01022bb:	e8 ab 00 00 00       	call   f010236b <boot_map_range>


	// This allows the kernel & user to access any page table entry using a
	// specified VA for each: VPT for kernel and UVPT for User.
	setup_listing_to_all_page_tables_entries();
f01022c0:	83 c4 20             	add    $0x20,%esp
f01022c3:	e8 2c fe ff ff       	call   f01020f4 <setup_listing_to_all_page_tables_entries>

        //////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// Map this array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	
	// LAB 3: Your code here.
	int envs_size = NENV * sizeof(struct Env) ;

	//allocate space for "envs" array aligned on 4KB boundary
	envs = boot_allocate_space(envs_size, PAGE_SIZE);
f01022c8:	83 ec 08             	sub    $0x8,%esp
f01022cb:	68 00 10 00 00       	push   $0x1000
f01022d0:	68 00 90 01 00       	push   $0x19000
f01022d5:	e8 5f 00 00 00       	call   f0102339 <boot_allocate_space>
f01022da:	a3 f0 e0 19 f0       	mov    %eax,0xf019e0f0

	//make the user to access this array by mapping it to UPAGES linear address (UPAGES is in User/Kernel space)
	boot_map_range(ptr_page_directory, UENVS, envs_size, K_PHYSICAL_ADDRESS(envs), PERM_USER) ;
f01022df:	83 c4 10             	add    $0x10,%esp
f01022e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022e7:	77 12                	ja     f01022fb <initialize_kernel_VM+0x133>
f01022e9:	50                   	push   %eax
f01022ea:	68 20 53 10 f0       	push   $0xf0105320
f01022ef:	6a 75                	push   $0x75
f01022f1:	68 c6 5c 10 f0       	push   $0xf0105cc6
f01022f6:	e8 03 de ff ff       	call   f01000fe <_panic>
f01022fb:	05 00 00 00 10       	add    $0x10000000,%eax
f0102300:	83 ec 0c             	sub    $0xc,%esp
f0102303:	6a 04                	push   $0x4
f0102305:	50                   	push   %eax
f0102306:	68 00 90 01 00       	push   $0x19000
f010230b:	68 00 00 c0 ee       	push   $0xeec00000
f0102310:	ff 35 84 e9 19 f0    	pushl  0xf019e984
f0102316:	e8 50 00 00 00       	call   f010236b <boot_map_range>

	//update permissions of the corresponding entry in page directory to make it USER with PERMISSION read only
	ptr_page_directory[PDX(UENVS)] = ptr_page_directory[PDX(UENVS)]|(PERM_USER|(PERM_PRESENT & (~PERM_WRITEABLE)));
f010231b:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0102320:	83 88 ec 0e 00 00 05 	orl    $0x5,0xeec(%eax)


	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();
f0102327:	83 c4 20             	add    $0x20,%esp
f010232a:	e8 24 f3 ff ff       	call   f0101653 <check_boot_pgdir>
	
	// NOW: Turn off the segmentation by setting the segments' base to 0, and
	// turn on the paging by setting the corresponding flags in control register 0 (cr0)
	turn_on_paging() ;
f010232f:	e8 5a fd ff ff       	call   f010208e <turn_on_paging>
}
f0102334:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102337:	c9                   	leave  
f0102338:	c3                   	ret    

f0102339 <boot_allocate_space>:

//
// Allocate "size" bytes of physical memory aligned on an
// "align"-byte boundary.  Align must be a power of two.
// Return the start kernel virtual address of the allocated space.
// Returned memory is uninitialized.
//
// If we're out of memory, boot_allocate_space should panic.
// It's too early to run out of memory.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
// 
void* boot_allocate_space(uint32 size, uint32 align)
{
f0102339:	55                   	push   %ebp
f010233a:	89 e5                	mov    %esp,%ebp
	extern char end_of_kernel[];	

	// Initialize ptr_free_mem if this is the first time.
	// 'end_of_kernel' is a symbol automatically generated by the linker,
	// which points to the end of the kernel-
	// i.e., the first virtual address that the linker
	// did not assign to any kernel code or global variables.
	if (ptr_free_mem == 0)
f010233c:	83 3d 80 e9 19 f0 00 	cmpl   $0x0,0xf019e980
f0102343:	75 0a                	jne    f010234f <boot_allocate_space+0x16>
		ptr_free_mem = end_of_kernel;
f0102345:	c7 05 80 e9 19 f0 90 	movl   $0xf019e990,0xf019e980
f010234c:	e9 19 f0 

	// Your code here:
	//	Step 1: round ptr_free_mem up to be aligned properly
	ptr_free_mem = ROUNDUP(ptr_free_mem, PAGE_SIZE) ;
f010234f:	a1 80 e9 19 f0       	mov    0xf019e980,%eax
f0102354:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102359:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	
	//	Step 2: save current value of ptr_free_mem as allocated space
	void *ptr_allocated_mem;
	ptr_allocated_mem = ptr_free_mem ;

	//	Step 3: increase ptr_free_mem to record allocation
	ptr_free_mem += size ;
f010235e:	8b 55 08             	mov    0x8(%ebp),%edx
f0102361:	01 c2                	add    %eax,%edx
f0102363:	89 15 80 e9 19 f0    	mov    %edx,0xf019e980

	//	Step 4: return allocated space
	return ptr_allocated_mem ;

}
f0102369:	5d                   	pop    %ebp
f010236a:	c3                   	ret    

f010236b <boot_map_range>:

//
// Map [virtual_address, virtual_address+size) of virtual address space to
// physical [physical_address, physical_address+size)
// in the page table rooted at ptr_page_directory.
// "size" is a multiple of PAGE_SIZE.
// Use permission bits perm|PERM_PRESENT for the entries.
//
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
f010236b:	55                   	push   %ebp
f010236c:	89 e5                	mov    %esp,%ebp
f010236e:	57                   	push   %edi
f010236f:	56                   	push   %esi
f0102370:	53                   	push   %ebx
f0102371:	83 ec 0c             	sub    $0xc,%esp
f0102374:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i = 0 ;
f0102377:	bf 00 00 00 00       	mov    $0x0,%edi
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
f010237c:	8b 45 14             	mov    0x14(%ebp),%eax
f010237f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102384:	89 c3                	mov    %eax,%ebx
f0102386:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f010238c:	3b 7d 10             	cmp    0x10(%ebp),%edi
f010238f:	73 3e                	jae    f01023cf <boot_map_range+0x64>
	{
		uint32 *ptr_page_table = boot_get_page_table(ptr_page_directory, virtual_address, 1) ;
f0102391:	83 ec 04             	sub    $0x4,%esp
f0102394:	6a 01                	push   $0x1
f0102396:	56                   	push   %esi
f0102397:	ff 75 08             	pushl  0x8(%ebp)
f010239a:	e8 38 00 00 00       	call   f01023d7 <boot_get_page_table>
		uint32 index_page_table = PTX(virtual_address);
f010239f:	89 f1                	mov    %esi,%ecx
f01023a1:	c1 e9 0c             	shr    $0xc,%ecx
f01023a4:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
f01023aa:	8b 55 18             	mov    0x18(%ebp),%edx
f01023ad:	09 da                	or     %ebx,%edx
f01023af:	83 ca 01             	or     $0x1,%edx
f01023b2:	89 14 88             	mov    %edx,(%eax,%ecx,4)
		physical_address += PAGE_SIZE ;
f01023b5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		virtual_address += PAGE_SIZE ;
f01023bb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023c1:	83 c4 10             	add    $0x10,%esp
f01023c4:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01023ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
f01023cd:	72 c2                	jb     f0102391 <boot_map_range+0x26>
	}
}
f01023cf:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01023d2:	5b                   	pop    %ebx
f01023d3:	5e                   	pop    %esi
f01023d4:	5f                   	pop    %edi
f01023d5:	5d                   	pop    %ebp
f01023d6:	c3                   	ret    

f01023d7 <boot_get_page_table>:

//
// Given ptr_page_directory, a pointer to a page directory,
// traverse the 2-level page table structure to find
// the page table for "virtual_address".
// Return a pointer to the table.
//
// If the relevant page table doesn't exist in the page directory:
//	- If create == 0, return 0.
//	- Otherwise allocate a new page table, install it into ptr_page_directory,
//	  and return a pointer into it.
//        (Questions: What data should the new page table contain?
//	  And what permissions should the new ptr_page_directory entry have?)
//
// This function allocates new page tables as needed.
// 
// boot_get_page_table cannot fail.  It's too early to fail.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
uint32* boot_get_page_table(uint32 *ptr_page_directory, uint32 virtual_address, int create)
{
f01023d7:	55                   	push   %ebp
f01023d8:	89 e5                	mov    %esp,%ebp
f01023da:	56                   	push   %esi
f01023db:	53                   	push   %ebx
f01023dc:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32 index_page_directory = PDX(virtual_address);
f01023df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01023e2:	89 c3                	mov    %eax,%ebx
f01023e4:	c1 eb 16             	shr    $0x16,%ebx
	uint32 page_directory_entry = ptr_page_directory[index_page_directory];
	
	uint32 phys_page_table = EXTRACT_ADDRESS(page_directory_entry);
f01023e7:	8b 14 9e             	mov    (%esi,%ebx,4),%edx
f01023ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	uint32 *ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table);
f01023f0:	89 d1                	mov    %edx,%ecx
f01023f2:	89 d0                	mov    %edx,%eax
f01023f4:	c1 e8 0c             	shr    $0xc,%eax
f01023f7:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f01023fd:	72 0d                	jb     f010240c <boot_get_page_table+0x35>
f01023ff:	52                   	push   %edx
f0102400:	68 40 56 10 f0       	push   $0xf0105640
f0102405:	68 db 00 00 00       	push   $0xdb
f010240a:	eb 40                	jmp    f010244c <boot_get_page_table+0x75>
f010240c:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
	if (phys_page_table == 0)
	{
		if (create)
		{
			ptr_page_table = boot_allocate_space(PAGE_SIZE, PAGE_SIZE) ;
			phys_page_table = K_PHYSICAL_ADDRESS(ptr_page_table);
			ptr_page_directory[index_page_directory] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_WRITEABLE);
			return ptr_page_table ;
		}
		else
			return 0 ;
	}
	return ptr_page_table ;
f0102412:	89 c8                	mov    %ecx,%eax
f0102414:	85 d2                	test   %edx,%edx
f0102416:	75 4e                	jne    f0102466 <boot_get_page_table+0x8f>
f0102418:	b8 00 00 00 00       	mov    $0x0,%eax
f010241d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102421:	74 43                	je     f0102466 <boot_get_page_table+0x8f>
f0102423:	83 ec 08             	sub    $0x8,%esp
f0102426:	68 00 10 00 00       	push   $0x1000
f010242b:	68 00 10 00 00       	push   $0x1000
f0102430:	e8 04 ff ff ff       	call   f0102339 <boot_allocate_space>
f0102435:	89 c1                	mov    %eax,%ecx
f0102437:	83 c4 10             	add    $0x10,%esp
f010243a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010243f:	77 15                	ja     f0102456 <boot_get_page_table+0x7f>
f0102441:	50                   	push   %eax
f0102442:	68 20 53 10 f0       	push   $0xf0105320
f0102447:	68 e1 00 00 00       	push   $0xe1
f010244c:	68 c6 5c 10 f0       	push   $0xf0105cc6
f0102451:	e8 a8 dc ff ff       	call   f01000fe <_panic>
f0102456:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010245c:	89 d0                	mov    %edx,%eax
f010245e:	83 c8 03             	or     $0x3,%eax
f0102461:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
f0102464:	89 c8                	mov    %ecx,%eax
}
f0102466:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102469:	5b                   	pop    %ebx
f010246a:	5e                   	pop    %esi
f010246b:	5d                   	pop    %ebp
f010246c:	c3                   	ret    

f010246d <initialize_paging>:

//==================== END of MAPPING KERNEL SPACE ==============================




//========================== MAPPING USER SPACE ==============================

// --------------------------------------------------------------
// Tracking of physical frames.
// The 'frames_info' array has one 'struct Frame_Info' entry per physical frame.
// frames_info are reference counted, and free frames are kept on a linked list.
// --------------------------------------------------------------

// Initialize paging structure and free_frame_list.
// After this point, ONLY use the functions below
// to allocate and deallocate physical memory via the free_frame_list,
// and NEVER use boot_allocate_space() or the related boot-time functions above.
//
void initialize_paging()
{
f010246d:	55                   	push   %ebp
f010246e:	89 e5                	mov    %esp,%ebp
f0102470:	56                   	push   %esi
f0102471:	53                   	push   %ebx
	// The example code here marks all frames_info as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark frame 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	//  2) Mark the rest of base memory as free.
	//  3) Then comes the IO hole [PHYS_IO_MEM, PHYS_EXTENDED_MEM).
	//     Mark it as in use so that it can never be allocated.      
	//  4) Then extended memory [PHYS_EXTENDED_MEM, ...).
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which frames are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&free_frame_list);
f0102472:	c7 05 78 e9 19 f0 00 	movl   $0x0,0xf019e978
f0102479:	00 00 00 
	
	frames_info[0].references = 1;
f010247c:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f0102481:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
f0102487:	be 00 00 0a 00       	mov    $0xa0000,%esi
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f010248c:	bb 01 00 00 00       	mov    $0x1,%ebx
f0102491:	eb 56                	jmp    f01024e9 <initialize_paging+0x7c>
	{
		frames_info[i].references = 0;
f0102493:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102496:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f010249d:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f01024a2:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f01024a9:	8b 15 78 e9 19 f0    	mov    0xf019e978,%edx
f01024af:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f01024b4:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f01024b7:	85 d2                	test   %edx,%edx
f01024b9:	74 10                	je     f01024cb <initialize_paging+0x5e>
f01024bb:	89 ca                	mov    %ecx,%edx
f01024bd:	03 15 7c e9 19 f0    	add    0xf019e97c,%edx
f01024c3:	a1 78 e9 19 f0       	mov    0xf019e978,%eax
f01024c8:	89 50 04             	mov    %edx,0x4(%eax)
f01024cb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01024ce:	c1 e0 02             	shl    $0x2,%eax
f01024d1:	8b 0d 7c e9 19 f0    	mov    0xf019e97c,%ecx
f01024d7:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01024da:	89 15 78 e9 19 f0    	mov    %edx,0xf019e978
f01024e0:	c7 44 01 04 78 e9 19 	movl   $0xf019e978,0x4(%ecx,%eax,1)
f01024e7:	f0 
f01024e8:	43                   	inc    %ebx
f01024e9:	89 f0                	mov    %esi,%eax
f01024eb:	85 f6                	test   %esi,%esi
f01024ed:	79 06                	jns    f01024f5 <initialize_paging+0x88>
f01024ef:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01024f5:	c1 f8 0c             	sar    $0xc,%eax
f01024f8:	39 c3                	cmp    %eax,%ebx
f01024fa:	7c 97                	jl     f0102493 <initialize_paging+0x26>
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f01024fc:	bb a0 00 00 00       	mov    $0xa0,%ebx
	{
		frames_info[i].references = 1;
f0102501:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f0102504:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f0102509:	66 c7 44 90 08 01 00 	movw   $0x1,0x8(%eax,%edx,4)
f0102510:	43                   	inc    %ebx
f0102511:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0102517:	7e e8                	jle    f0102501 <initialize_paging+0x94>
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
f0102519:	ba 00 10 00 00       	mov    $0x1000,%edx
f010251e:	a1 80 e9 19 f0       	mov    0xf019e980,%eax
f0102523:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102528:	77 15                	ja     f010253f <initialize_paging+0xd2>
f010252a:	50                   	push   %eax
f010252b:	68 20 53 10 f0       	push   $0xf0105320
f0102530:	68 1e 01 00 00       	push   $0x11e
f0102535:	68 c6 5c 10 f0       	push   $0xf0105cc6
f010253a:	e8 bf db ff ff       	call   f01000fe <_panic>
f010253f:	8d b4 02 ff ff ff 0f 	lea    0xfffffff(%edx,%eax,1),%esi
f0102546:	89 f0                	mov    %esi,%eax
f0102548:	89 d3                	mov    %edx,%ebx
f010254a:	ba 00 00 00 00       	mov    $0x0,%edx
f010254f:	f7 f3                	div    %ebx
f0102551:	29 d6                	sub    %edx,%esi
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f0102553:	bb 00 01 00 00       	mov    $0x100,%ebx
f0102558:	eb 10                	jmp    f010256a <initialize_paging+0xfd>
	{
		frames_info[i].references = 1;
f010255a:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f010255d:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f0102562:	66 c7 44 90 08 01 00 	movw   $0x1,0x8(%eax,%edx,4)
f0102569:	43                   	inc    %ebx
f010256a:	89 f0                	mov    %esi,%eax
f010256c:	85 f6                	test   %esi,%esi
f010256e:	79 06                	jns    f0102576 <initialize_paging+0x109>
f0102570:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0102576:	c1 f8 0c             	sar    $0xc,%eax
f0102579:	39 c3                	cmp    %eax,%ebx
f010257b:	7c dd                	jl     f010255a <initialize_paging+0xed>
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f010257d:	89 f0                	mov    %esi,%eax
f010257f:	85 f6                	test   %esi,%esi
f0102581:	79 05                	jns    f0102588 <initialize_paging+0x11b>
f0102583:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102588:	89 c3                	mov    %eax,%ebx
f010258a:	c1 fb 0c             	sar    $0xc,%ebx
f010258d:	3b 1d 68 e9 19 f0    	cmp    0xf019e968,%ebx
f0102593:	73 5e                	jae    f01025f3 <initialize_paging+0x186>
	{
		frames_info[i].references = 0;
f0102595:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102598:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f010259f:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f01025a4:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f01025ab:	8b 15 78 e9 19 f0    	mov    0xf019e978,%edx
f01025b1:	a1 7c e9 19 f0       	mov    0xf019e97c,%eax
f01025b6:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f01025b9:	85 d2                	test   %edx,%edx
f01025bb:	74 10                	je     f01025cd <initialize_paging+0x160>
f01025bd:	89 ca                	mov    %ecx,%edx
f01025bf:	03 15 7c e9 19 f0    	add    0xf019e97c,%edx
f01025c5:	a1 78 e9 19 f0       	mov    0xf019e978,%eax
f01025ca:	89 50 04             	mov    %edx,0x4(%eax)
f01025cd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01025d0:	c1 e0 02             	shl    $0x2,%eax
f01025d3:	8b 0d 7c e9 19 f0    	mov    0xf019e97c,%ecx
f01025d9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01025dc:	89 15 78 e9 19 f0    	mov    %edx,0xf019e978
f01025e2:	c7 44 01 04 78 e9 19 	movl   $0xf019e978,0x4(%ecx,%eax,1)
f01025e9:	f0 
f01025ea:	43                   	inc    %ebx
f01025eb:	3b 1d 68 e9 19 f0    	cmp    0xf019e968,%ebx
f01025f1:	72 a2                	jb     f0102595 <initialize_paging+0x128>
	}
}
f01025f3:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01025f6:	5b                   	pop    %ebx
f01025f7:	5e                   	pop    %esi
f01025f8:	5d                   	pop    %ebp
f01025f9:	c3                   	ret    

f01025fa <initialize_frame_info>:

//
// Initialize a Frame_Info structure.
// The result has null links and 0 references.
// Note that the corresponding physical frame is NOT initialized!
//
void initialize_frame_info(struct Frame_Info *ptr_frame_info)
{
f01025fa:	55                   	push   %ebp
f01025fb:	89 e5                	mov    %esp,%ebp
f01025fd:	83 ec 0c             	sub    $0xc,%esp
	memset(ptr_frame_info, 0, sizeof(*ptr_frame_info));
f0102600:	6a 0c                	push   $0xc
f0102602:	6a 00                	push   $0x0
f0102604:	ff 75 08             	pushl  0x8(%ebp)
f0102607:	e8 83 1e 00 00       	call   f010448f <memset>
}
f010260c:	c9                   	leave  
f010260d:	c3                   	ret    

f010260e <allocate_frame>:

//
// Allocates a physical frame.
// Does NOT set the contents of the physical frame to zero -
// the caller must do that if necessary.
//
// *ptr_frame_info -- is set to point to the Frame_Info struct of the
// newly allocated frame
//
// RETURNS 
//   0 -- on success
//   E_NO_MEM -- otherwise
//
// Hint: use LIST_FIRST, LIST_REMOVE, and initialize_frame_info
// Hint: references should not be incremented
int allocate_frame(struct Frame_Info **ptr_frame_info)
{
f010260e:	55                   	push   %ebp
f010260f:	89 e5                	mov    %esp,%ebp
f0102611:	83 ec 08             	sub    $0x8,%esp
f0102614:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Fill this function in	
	*ptr_frame_info = LIST_FIRST(&free_frame_list);
f0102617:	a1 78 e9 19 f0       	mov    0xf019e978,%eax
f010261c:	89 01                	mov    %eax,(%ecx)
	if(*ptr_frame_info == NULL)
f010261e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102623:	83 39 00             	cmpl   $0x0,(%ecx)
f0102626:	74 27                	je     f010264f <allocate_frame+0x41>
		return E_NO_MEM;
	
	LIST_REMOVE(*ptr_frame_info);
f0102628:	8b 01                	mov    (%ecx),%eax
f010262a:	83 38 00             	cmpl   $0x0,(%eax)
f010262d:	74 08                	je     f0102637 <allocate_frame+0x29>
f010262f:	8b 10                	mov    (%eax),%edx
f0102631:	8b 40 04             	mov    0x4(%eax),%eax
f0102634:	89 42 04             	mov    %eax,0x4(%edx)
f0102637:	8b 01                	mov    (%ecx),%eax
f0102639:	8b 50 04             	mov    0x4(%eax),%edx
f010263c:	8b 00                	mov    (%eax),%eax
f010263e:	89 02                	mov    %eax,(%edx)
	initialize_frame_info(*ptr_frame_info);
f0102640:	83 ec 0c             	sub    $0xc,%esp
f0102643:	ff 31                	pushl  (%ecx)
f0102645:	e8 b0 ff ff ff       	call   f01025fa <initialize_frame_info>
	return 0;
f010264a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010264f:	c9                   	leave  
f0102650:	c3                   	ret    

f0102651 <free_frame>:

//
// Return a frame to the free_frame_list.
// (This function should only be called when ptr_frame_info->references reaches 0.)
//
void free_frame(struct Frame_Info *ptr_frame_info)
{
f0102651:	55                   	push   %ebp
f0102652:	89 e5                	mov    %esp,%ebp
f0102654:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	LIST_INSERT_HEAD(&free_frame_list, ptr_frame_info);
f0102657:	a1 78 e9 19 f0       	mov    0xf019e978,%eax
f010265c:	89 02                	mov    %eax,(%edx)
f010265e:	85 c0                	test   %eax,%eax
f0102660:	74 08                	je     f010266a <free_frame+0x19>
f0102662:	a1 78 e9 19 f0       	mov    0xf019e978,%eax
f0102667:	89 50 04             	mov    %edx,0x4(%eax)
f010266a:	89 15 78 e9 19 f0    	mov    %edx,0xf019e978
f0102670:	c7 42 04 78 e9 19 f0 	movl   $0xf019e978,0x4(%edx)
}
f0102677:	5d                   	pop    %ebp
f0102678:	c3                   	ret    

f0102679 <decrement_references>:

//
// Decrement the reference count on a frame
// freeing it if there are no more references.
//
void decrement_references(struct Frame_Info* ptr_frame_info)
{
f0102679:	55                   	push   %ebp
f010267a:	89 e5                	mov    %esp,%ebp
f010267c:	83 ec 08             	sub    $0x8,%esp
f010267f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--(ptr_frame_info->references) == 0)
f0102682:	66 ff 48 08          	decw   0x8(%eax)
f0102686:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010268b:	75 0c                	jne    f0102699 <decrement_references+0x20>
		free_frame(ptr_frame_info);
f010268d:	83 ec 0c             	sub    $0xc,%esp
f0102690:	50                   	push   %eax
f0102691:	e8 bb ff ff ff       	call   f0102651 <free_frame>
f0102696:	83 c4 10             	add    $0x10,%esp
}
f0102699:	c9                   	leave  
f010269a:	c3                   	ret    

f010269b <get_page_table>:

//
// This is like "boot_get_page_table()" with a different allocate function:
// namely, it should use allocate_frame() instead of boot_allocate_space().
// Unlike boot_get_page_table(), get_page_table() can fail, so we have to
// return "ptr_page_table" via a pointer parameter.
//
// Stores address of page table entry in *ptr_page_table .
// Stores 0 if there is no such entry or on error.
// 
// RETURNS: 
//   0 on success
//   E_NO_MEM, if page table couldn't be allocated
//
// Hint: you can use "to_physical_address()" to turn a Frame_Info*
// into the physical address of the frame it refers to. 

int get_page_table(uint32 *ptr_page_directory, const void *virtual_address, int create, uint32 **ptr_page_table)
{
f010269b:	55                   	push   %ebp
f010269c:	89 e5                	mov    %esp,%ebp
f010269e:	57                   	push   %edi
f010269f:	56                   	push   %esi
f01026a0:	53                   	push   %ebx
f01026a1:	83 ec 0c             	sub    $0xc,%esp
f01026a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01026a7:	8b 75 14             	mov    0x14(%ebp),%esi
	// Fill this function in
	uint32 page_directory_entry = ptr_page_directory[PDX(virtual_address)];
f01026aa:	89 f8                	mov    %edi,%eax
f01026ac:	c1 e8 16             	shr    $0x16,%eax
f01026af:	8b 55 08             	mov    0x8(%ebp),%edx
f01026b2:	8b 0c 82             	mov    (%edx,%eax,4),%ecx

	*ptr_page_table = K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(page_directory_entry)) ;
f01026b5:	89 ca                	mov    %ecx,%edx
f01026b7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026bd:	89 d0                	mov    %edx,%eax
f01026bf:	c1 e8 0c             	shr    $0xc,%eax
f01026c2:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f01026c8:	72 10                	jb     f01026da <get_page_table+0x3f>
f01026ca:	52                   	push   %edx
f01026cb:	68 40 56 10 f0       	push   $0xf0105640
f01026d0:	68 79 01 00 00       	push   $0x179
f01026d5:	e9 82 00 00 00       	jmp    f010275c <get_page_table+0xc1>
f01026da:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f01026e0:	89 06                	mov    %eax,(%esi)
	
	if (page_directory_entry == 0)
f01026e2:	85 c9                	test   %ecx,%ecx
f01026e4:	0f 85 b8 00 00 00    	jne    f01027a2 <get_page_table+0x107>
	{
		if (create)
f01026ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01026ee:	0f 84 a8 00 00 00    	je     f010279c <get_page_table+0x101>
		{
			struct Frame_Info* ptr_frame_info;
			int err = allocate_frame(&ptr_frame_info) ;
f01026f4:	83 ec 0c             	sub    $0xc,%esp
f01026f7:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01026fa:	50                   	push   %eax
f01026fb:	e8 0e ff ff ff       	call   f010260e <allocate_frame>
			if(err == E_NO_MEM)
f0102700:	83 c4 10             	add    $0x10,%esp
f0102703:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102706:	75 10                	jne    f0102718 <get_page_table+0x7d>
			{
				*ptr_page_table = 0;
f0102708:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
				return E_NO_MEM;
f010270e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102713:	e9 8f 00 00 00       	jmp    f01027a7 <get_page_table+0x10c>
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0102718:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f010271b:	2b 15 7c e9 19 f0    	sub    0xf019e97c,%edx
f0102721:	c1 fa 02             	sar    $0x2,%edx
f0102724:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102727:	89 c1                	mov    %eax,%ecx
f0102729:	c1 e1 04             	shl    $0x4,%ecx
f010272c:	01 c8                	add    %ecx,%eax
f010272e:	89 c1                	mov    %eax,%ecx
f0102730:	c1 e1 08             	shl    $0x8,%ecx
f0102733:	01 c8                	add    %ecx,%eax
f0102735:	89 c1                	mov    %eax,%ecx
f0102737:	c1 e1 10             	shl    $0x10,%ecx
f010273a:	01 c8                	add    %ecx,%eax
f010273c:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f010273f:	89 c3                	mov    %eax,%ebx
f0102741:	c1 e3 0c             	shl    $0xc,%ebx
			}

			uint32 phys_page_table = to_physical_address(ptr_frame_info);
			*ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table) ;
f0102744:	89 d8                	mov    %ebx,%eax
f0102746:	c1 e8 0c             	shr    $0xc,%eax
f0102749:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f010274f:	72 15                	jb     f0102766 <get_page_table+0xcb>
f0102751:	53                   	push   %ebx
f0102752:	68 40 56 10 f0       	push   $0xf0105640
f0102757:	68 88 01 00 00       	push   $0x188
f010275c:	68 c6 5c 10 f0       	push   $0xf0105cc6
f0102761:	e8 98 d9 ff ff       	call   f01000fe <_panic>
f0102766:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f010276c:	89 06                	mov    %eax,(%esi)
			
			//initialize new page table by 0's
			memset(*ptr_page_table , 0, PAGE_SIZE);
f010276e:	83 ec 04             	sub    $0x4,%esp
f0102771:	68 00 10 00 00       	push   $0x1000
f0102776:	6a 00                	push   $0x0
f0102778:	50                   	push   %eax
f0102779:	e8 11 1d 00 00       	call   f010448f <memset>

			ptr_frame_info->references = 1;
f010277e:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0102781:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
			ptr_page_directory[PDX(virtual_address)] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_USER | PERM_WRITEABLE);
f0102787:	89 fa                	mov    %edi,%edx
f0102789:	c1 ea 16             	shr    $0x16,%edx
f010278c:	89 d8                	mov    %ebx,%eax
f010278e:	83 c8 07             	or     $0x7,%eax
f0102791:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102794:	89 04 91             	mov    %eax,(%ecx,%edx,4)
f0102797:	83 c4 10             	add    $0x10,%esp
f010279a:	eb 06                	jmp    f01027a2 <get_page_table+0x107>
		}
		else
		{
			*ptr_page_table = 0;
f010279c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
			return 0;
		}
	}	
	return 0;
f01027a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01027a7:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01027aa:	5b                   	pop    %ebx
f01027ab:	5e                   	pop    %esi
f01027ac:	5f                   	pop    %edi
f01027ad:	5d                   	pop    %ebp
f01027ae:	c3                   	ret    

f01027af <map_frame>:

//
// Map the physical frame 'ptr_frame_info' at 'virtual_address'.
// The permissions (the low 12 bits) of the page table
//  entry should be set to 'perm|PERM_PRESENT'.
//
// Details
//   - If there is already a frame mapped at 'virtual_address', it should be unmaped
// using unmap_frame().
//   - If necesary, on demand, allocates a page table and inserts it into 'ptr_page_directory'.
//   - ptr_frame_info->references should be incremented if the insertion succeeds
//
// RETURNS: 
//   0 on success
//   E_NO_MEM, if page table couldn't be allocated
//
// Hint: implement using get_page_table() and unmap_frame().
//
int map_frame(uint32 *ptr_page_directory, struct Frame_Info *ptr_frame_info, void *virtual_address, int perm)
{
f01027af:	55                   	push   %ebp
f01027b0:	89 e5                	mov    %esp,%ebp
f01027b2:	57                   	push   %edi
f01027b3:	56                   	push   %esi
f01027b4:	53                   	push   %ebx
f01027b5:	83 ec 0c             	sub    $0xc,%esp
f01027b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01027bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f01027be:	89 f9                	mov    %edi,%ecx
f01027c0:	2b 0d 7c e9 19 f0    	sub    0xf019e97c,%ecx
f01027c6:	c1 f9 02             	sar    $0x2,%ecx
f01027c9:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f01027cc:	89 c2                	mov    %eax,%edx
f01027ce:	c1 e2 04             	shl    $0x4,%edx
f01027d1:	01 d0                	add    %edx,%eax
f01027d3:	89 c2                	mov    %eax,%edx
f01027d5:	c1 e2 08             	shl    $0x8,%edx
f01027d8:	01 d0                	add    %edx,%eax
f01027da:	89 c2                	mov    %eax,%edx
f01027dc:	c1 e2 10             	shl    $0x10,%edx
f01027df:	01 d0                	add    %edx,%eax
f01027e1:	8d 04 41             	lea    (%ecx,%eax,2),%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f01027e4:	89 c6                	mov    %eax,%esi
f01027e6:	c1 e6 0c             	shl    $0xc,%esi
	// Fill this function in
	uint32 physical_address = to_physical_address(ptr_frame_info);
	uint32 *ptr_page_table;
	if( get_page_table(ptr_page_directory, virtual_address, 1, &ptr_page_table) == 0)
f01027e9:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01027ec:	50                   	push   %eax
f01027ed:	6a 01                	push   $0x1
f01027ef:	53                   	push   %ebx
f01027f0:	ff 75 08             	pushl  0x8(%ebp)
f01027f3:	e8 a3 fe ff ff       	call   f010269b <get_page_table>
f01027f8:	83 c4 10             	add    $0x10,%esp
	{
		uint32 page_table_entry = ptr_page_table[PTX(virtual_address)];
		
		
		if( EXTRACT_ADDRESS(page_table_entry) != physical_address)
		{
			if( page_table_entry != 0)
			{				
				unmap_frame(ptr_page_directory , virtual_address);
			}
			ptr_frame_info->references++;
			ptr_page_table[PTX(virtual_address)] = CONSTRUCT_ENTRY(physical_address , perm | PERM_PRESENT);
			
		}		
		return 0;
	}	
	return E_NO_MEM;
f01027fb:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102800:	85 c0                	test   %eax,%eax
f0102802:	75 4f                	jne    f0102853 <map_frame+0xa4>
f0102804:	89 d8                	mov    %ebx,%eax
f0102806:	c1 e8 0c             	shr    $0xc,%eax
f0102809:	25 ff 03 00 00       	and    $0x3ff,%eax
f010280e:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0102811:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0102814:	89 d0                	mov    %edx,%eax
f0102816:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010281b:	39 f0                	cmp    %esi,%eax
f010281d:	74 2f                	je     f010284e <map_frame+0x9f>
f010281f:	85 d2                	test   %edx,%edx
f0102821:	74 0f                	je     f0102832 <map_frame+0x83>
f0102823:	83 ec 08             	sub    $0x8,%esp
f0102826:	53                   	push   %ebx
f0102827:	ff 75 08             	pushl  0x8(%ebp)
f010282a:	e8 ad 00 00 00       	call   f01028dc <unmap_frame>
f010282f:	83 c4 10             	add    $0x10,%esp
f0102832:	66 ff 47 08          	incw   0x8(%edi)
f0102836:	89 d8                	mov    %ebx,%eax
f0102838:	c1 e8 0c             	shr    $0xc,%eax
f010283b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102840:	89 f2                	mov    %esi,%edx
f0102842:	0b 55 14             	or     0x14(%ebp),%edx
f0102845:	83 ca 01             	or     $0x1,%edx
f0102848:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f010284b:	89 14 81             	mov    %edx,(%ecx,%eax,4)
f010284e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102853:	89 d0                	mov    %edx,%eax
f0102855:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102858:	5b                   	pop    %ebx
f0102859:	5e                   	pop    %esi
f010285a:	5f                   	pop    %edi
f010285b:	5d                   	pop    %ebp
f010285c:	c3                   	ret    

f010285d <get_frame_info>:

//
// Return the frame mapped at 'virtual_address'.
// If the page table entry corresponding to 'virtual_address' exists, then we store a pointer to the table in 'ptr_page_table'
// This is used by 'unmap_frame()'
// but should not be used by other callers.
//
// Return 0 if there is no frame mapped at virtual_address.
//
// Hint: implement using get_page_table() and get_frame_info().
//
struct Frame_Info * get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table)
{
f010285d:	55                   	push   %ebp
f010285e:	89 e5                	mov    %esp,%ebp
f0102860:	56                   	push   %esi
f0102861:	53                   	push   %ebx
f0102862:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102865:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in	
	uint32 ret =  get_page_table(ptr_page_directory, virtual_address, 0, ptr_page_table) ;
f0102868:	53                   	push   %ebx
f0102869:	6a 00                	push   $0x0
f010286b:	56                   	push   %esi
f010286c:	ff 75 08             	pushl  0x8(%ebp)
f010286f:	e8 27 fe ff ff       	call   f010269b <get_page_table>
	if((*ptr_page_table) != 0)
f0102874:	83 c4 10             	add    $0x10,%esp
	{	
		uint32 index_page_table = PTX(virtual_address);
		uint32 page_table_entry = (*ptr_page_table)[index_page_table];
		if( page_table_entry != 0)	
			return to_frame_info( EXTRACT_ADDRESS ( page_table_entry ) );
		return 0;
	}
	return 0;
f0102877:	ba 00 00 00 00       	mov    $0x0,%edx
f010287c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010287f:	74 52                	je     f01028d3 <get_frame_info+0x76>
f0102881:	89 f0                	mov    %esi,%eax
f0102883:	c1 e8 0c             	shr    $0xc,%eax
f0102886:	25 ff 03 00 00       	and    $0x3ff,%eax
f010288b:	8b 13                	mov    (%ebx),%edx
f010288d:	8b 04 82             	mov    (%edx,%eax,4),%eax
f0102890:	ba 00 00 00 00       	mov    $0x0,%edx
f0102895:	85 c0                	test   %eax,%eax
f0102897:	74 3a                	je     f01028d3 <get_frame_info+0x76>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0102899:	89 c2                	mov    %eax,%edx
f010289b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PPN(physical_address) >= number_of_frames)
f01028a1:	89 d0                	mov    %edx,%eax
f01028a3:	c1 e8 0c             	shr    $0xc,%eax
f01028a6:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f01028ac:	72 14                	jb     f01028c2 <get_frame_info+0x65>
		panic("to_frame_info called with invalid pa");
f01028ae:	83 ec 04             	sub    $0x4,%esp
f01028b1:	68 60 53 10 f0       	push   $0xf0105360
f01028b6:	6a 39                	push   $0x39
f01028b8:	68 be 4e 10 f0       	push   $0xf0104ebe
f01028bd:	e8 3c d8 ff ff       	call   f01000fe <_panic>
f01028c2:	89 d0                	mov    %edx,%eax
f01028c4:	c1 e8 0c             	shr    $0xc,%eax
f01028c7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01028ca:	8b 15 7c e9 19 f0    	mov    0xf019e97c,%edx
f01028d0:	8d 14 82             	lea    (%edx,%eax,4),%edx
}
f01028d3:	89 d0                	mov    %edx,%eax
f01028d5:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01028d8:	5b                   	pop    %ebx
f01028d9:	5e                   	pop    %esi
f01028da:	5d                   	pop    %ebp
f01028db:	c3                   	ret    

f01028dc <unmap_frame>:

//
// Unmaps the physical frame at 'virtual_address'.
//
// Details:
//   - The references count on the physical frame should decrement.
//   - The physical frame should be freed if the 'references' reaches 0.
//   - The page table entry corresponding to 'virtual_address' should be set to 0.
//     (if such a page table exists)
//   - The TLB must be invalidated if you remove an entry from
//	   the page directory/page table.
//
// Hint: implement using get_frame_info(),
// 	tlb_invalidate(), and decrement_references().
//
void unmap_frame(uint32 *ptr_page_directory, void *virtual_address)
{
f01028dc:	55                   	push   %ebp
f01028dd:	89 e5                	mov    %esp,%ebp
f01028df:	56                   	push   %esi
f01028e0:	53                   	push   %ebx
f01028e1:	83 ec 14             	sub    $0x14,%esp
f01028e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01028e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	uint32 *ptr_page_table;
	struct Frame_Info* ptr_frame_info = get_frame_info(ptr_page_directory, virtual_address, &ptr_page_table);
f01028ea:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f01028ed:	50                   	push   %eax
f01028ee:	53                   	push   %ebx
f01028ef:	56                   	push   %esi
f01028f0:	e8 68 ff ff ff       	call   f010285d <get_frame_info>
	if( ptr_frame_info != 0 )
f01028f5:	83 c4 10             	add    $0x10,%esp
f01028f8:	85 c0                	test   %eax,%eax
f01028fa:	74 2a                	je     f0102926 <unmap_frame+0x4a>
	{
		decrement_references(ptr_frame_info);
f01028fc:	83 ec 0c             	sub    $0xc,%esp
f01028ff:	50                   	push   %eax
f0102900:	e8 74 fd ff ff       	call   f0102679 <decrement_references>
		ptr_page_table[PTX(virtual_address)] = 0;
f0102905:	89 d8                	mov    %ebx,%eax
f0102907:	c1 e8 0c             	shr    $0xc,%eax
f010290a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010290f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0102912:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
		tlb_invalidate(ptr_page_directory, virtual_address);
f0102919:	83 c4 08             	add    $0x8,%esp
f010291c:	53                   	push   %ebx
f010291d:	56                   	push   %esi
f010291e:	e8 52 ef ff ff       	call   f0101875 <tlb_invalidate>
f0102923:	83 c4 10             	add    $0x10,%esp
	}	
}
f0102926:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102929:	5b                   	pop    %ebx
f010292a:	5e                   	pop    %esi
f010292b:	5d                   	pop    %ebp
f010292c:	c3                   	ret    

f010292d <get_page>:

//========================== END OF MAPPING USER SPACE ==============================
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================




//======================================================
// functions used as helpers for malloc() and freeHeap()
//======================================================
//[1] get_page: 
//	it should allocate one frame and map it to the given virtual address
//	if the virtual address is already mapped, then it return 0
// 	Return 0 on success, < 0 on error.  Errors are:
//		E_INVAL if virtual_address >= USER_TOP.
//		E_INVAL if perm is not containing PERM_USER.
//		E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
// 	HINT: 	remember to free the allocated frame if there is no space 
//		for the necessary page tables

int get_page(uint32* ptr_page_directory, void *virtual_address, int perm)
{
f010292d:	55                   	push   %ebp
f010292e:	89 e5                	mov    %esp,%ebp
f0102930:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("get_page function is not completed yet") ;
f0102933:	68 20 5c 10 f0       	push   $0xf0105c20
f0102938:	68 12 02 00 00       	push   $0x212
f010293d:	68 c6 5c 10 f0       	push   $0xf0105cc6
f0102942:	e8 b7 d7 ff ff       	call   f01000fe <_panic>

f0102947 <calculate_required_frames>:

	//[1] check virtual address to be < USER_TOP
	// return E_INVAL if not
	
	//[2] check the value of perm to contain PERM_USER 
	// return E_INVAL if not
	
	//[3] check if the page containing the "virtual_address" is already mapped or not
	// return 0 if the page is already mapped
	// else:
	//	Allocate a frame from the physical memory, 
	//	Map the page to the allocated frame
	//	if there is no free space , return E_NO_MEM
	//	else return 0				 
	
	return 0 ;
}

//[2] calculate_required_frames: 
uint32 calculate_required_frames(uint32* ptr_page_directory, uint32 start_virtual_address, uint32 size)
{
f0102947:	55                   	push   %ebp
f0102948:	89 e5                	mov    %esp,%ebp
f010294a:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("calculate_required_frames function is not completed yet") ;
f010294d:	68 60 5c 10 f0       	push   $0xf0105c60
f0102952:	68 29 02 00 00       	push   $0x229
f0102957:	68 c6 5c 10 f0       	push   $0xf0105cc6
f010295c:	e8 9d d7 ff ff       	call   f01000fe <_panic>

f0102961 <calculate_free_frames>:
	
	//calculate the required page tables	
	

	//calc the required page frames
	
	//return total number of frames  
	return 0; 
}


//[3] calculate_free_frames:

uint32 calculate_free_frames()
{
f0102961:	55                   	push   %ebp
f0102962:	89 e5                	mov    %esp,%ebp
	// PROJECT 2008: Your code here.
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
f0102964:	b8 00 00 00 00       	mov    $0x0,%eax
	LIST_FOREACH(ptr, &free_frame_list)
f0102969:	8b 15 78 e9 19 f0    	mov    0xf019e978,%edx
f010296f:	85 d2                	test   %edx,%edx
f0102971:	74 07                	je     f010297a <calculate_free_frames+0x19>
	{
		cnt++ ;
f0102973:	40                   	inc    %eax
f0102974:	8b 12                	mov    (%edx),%edx
f0102976:	85 d2                	test   %edx,%edx
f0102978:	75 f9                	jne    f0102973 <calculate_free_frames+0x12>
	}
	return cnt;
}
f010297a:	5d                   	pop    %ebp
f010297b:	c3                   	ret    

f010297c <freeMem>:

//[4] freeMem: 
//	This function is used to frees all pages and page tables that are mapped on
//	range [ virtual_address, virtual_address + size ]
//	Steps:
//		1) Unmap all mapped pages in the range [virtual_address, virtual_address + size ]
//		2) Free all mapped page tables in this range

void freeMem(uint32* ptr_page_directory, void *virtual_address, uint32 size)
{
f010297c:	55                   	push   %ebp
f010297d:	89 e5                	mov    %esp,%ebp
f010297f:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("freeMem function is not completed yet") ;
f0102982:	68 a0 5c 10 f0       	push   $0xf0105ca0
f0102987:	68 50 02 00 00       	push   $0x250
f010298c:	68 c6 5c 10 f0       	push   $0xf0105cc6
f0102991:	e8 68 d7 ff ff       	call   f01000fe <_panic>
	...

f0102998 <allocate_environment>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	E_NO_FREE_ENV if all NENVS environments are allocated
//
int allocate_environment(struct Env** e)
{	
f0102998:	55                   	push   %ebp
f0102999:	89 e5                	mov    %esp,%ebp
	if (!(*e = LIST_FIRST(&env_free_list)))
f010299b:	8b 15 f8 e0 19 f0    	mov    0xf019e0f8,%edx
f01029a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01029a4:	89 10                	mov    %edx,(%eax)
f01029a6:	83 fa 01             	cmp    $0x1,%edx
f01029a9:	19 c0                	sbb    %eax,%eax
f01029ab:	83 e0 fb             	and    $0xfffffffb,%eax
		return E_NO_FREE_ENV;
	return 0;
}
f01029ae:	5d                   	pop    %ebp
f01029af:	c3                   	ret    

f01029b0 <free_environment>:

// Free the given environment "e", simply by adding it to the free environment list.
void free_environment(struct Env* e)
{
f01029b0:	55                   	push   %ebp
f01029b1:	89 e5                	mov    %esp,%ebp
f01029b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	curenv = NULL;	
f01029b6:	c7 05 f4 e0 19 f0 00 	movl   $0x0,0xf019e0f4
f01029bd:	00 00 00 
	// return the environment to the free list
	e->env_status = ENV_FREE;
f01029c0:	c7 41 54 00 00 00 00 	movl   $0x0,0x54(%ecx)
	LIST_INSERT_HEAD(&env_free_list, e);
f01029c7:	a1 f8 e0 19 f0       	mov    0xf019e0f8,%eax
f01029cc:	89 41 44             	mov    %eax,0x44(%ecx)
f01029cf:	85 c0                	test   %eax,%eax
f01029d1:	74 0b                	je     f01029de <free_environment+0x2e>
f01029d3:	8d 51 44             	lea    0x44(%ecx),%edx
f01029d6:	a1 f8 e0 19 f0       	mov    0xf019e0f8,%eax
f01029db:	89 50 48             	mov    %edx,0x48(%eax)
f01029de:	89 0d f8 e0 19 f0    	mov    %ecx,0xf019e0f8
f01029e4:	c7 41 48 f8 e0 19 f0 	movl   $0xf019e0f8,0x48(%ecx)
}
f01029eb:	5d                   	pop    %ebp
f01029ec:	c3                   	ret    

f01029ed <program_segment_alloc_map>:



//
// Allocate length bytes of physical memory for environment e,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
//
// if the allocation failed, return E_NO_MEM 
// otherwise return 0
//
static int program_segment_alloc_map(struct Env *e, void *va, uint32 length)
{
f01029ed:	55                   	push   %ebp
f01029ee:	89 e5                	mov    %esp,%ebp
f01029f0:	57                   	push   %edi
f01029f1:	56                   	push   %esi
f01029f2:	53                   	push   %ebx
f01029f3:	83 ec 0c             	sub    $0xc,%esp
f01029f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	//You should round round "va + length" up, and "va" down.
	//Hands on 2:
	//your code here ...
	uint32 startVA = (uint32) va;
f01029f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32 endVA = (uint32) va + length;
f01029fc:	89 de                	mov    %ebx,%esi
f01029fe:	03 75 10             	add    0x10(%ebp),%esi
	//remove the offset from the startVA so that it starts at the first address of its page
	startVA = ROUNDDOWN(startVA, PAGE_SIZE);
f0102a01:	89 d8                	mov    %ebx,%eax
f0102a03:	25 ff 0f 00 00       	and    $0xfff,%eax
f0102a08:	29 c3                	sub    %eax,%ebx
	for(; startVA<endVA; startVA+=PAGE_SIZE)
f0102a0a:	39 f3                	cmp    %esi,%ebx
f0102a0c:	73 3e                	jae    f0102a4c <program_segment_alloc_map+0x5f>
	{
		struct Frame_Info* ptr_frame;
		int ret = allocate_frame(&ptr_frame) ;
f0102a0e:	83 ec 0c             	sub    $0xc,%esp
f0102a11:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102a14:	50                   	push   %eax
f0102a15:	e8 f4 fb ff ff       	call   f010260e <allocate_frame>
		if(ret == E_NO_MEM)
f0102a1a:	83 c4 10             	add    $0x10,%esp
f0102a1d:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102a22:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102a25:	74 2a                	je     f0102a51 <program_segment_alloc_map+0x64>
		{
			return E_NO_MEM;
		}
		ret = map_frame(e->env_pgdir, ptr_frame, (void*)startVA, PERM_USER|PERM_WRITEABLE);
f0102a27:	6a 06                	push   $0x6
f0102a29:	53                   	push   %ebx
f0102a2a:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0102a2d:	ff 77 5c             	pushl  0x5c(%edi)
f0102a30:	e8 7a fd ff ff       	call   f01027af <map_frame>
		if(ret == E_NO_MEM)
f0102a35:	83 c4 10             	add    $0x10,%esp
f0102a38:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102a3d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102a40:	74 0f                	je     f0102a51 <program_segment_alloc_map+0x64>
f0102a42:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a48:	39 f3                	cmp    %esi,%ebx
f0102a4a:	72 c2                	jb     f0102a0e <program_segment_alloc_map+0x21>
		{
			return E_NO_MEM;
		}
	}
	return 0;
f0102a4c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102a51:	89 d0                	mov    %edx,%eax
f0102a53:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102a56:	5b                   	pop    %ebx
f0102a57:	5e                   	pop    %esi
f0102a58:	5f                   	pop    %edi
f0102a59:	5d                   	pop    %ebp
f0102a5a:	c3                   	ret    

f0102a5b <env_create>:

//
// Allocates a new env and loads the named user program into it.
struct UserProgramInfo* env_create(char* user_program_name)
																		{
f0102a5b:	55                   	push   %ebp
f0102a5c:	89 e5                	mov    %esp,%ebp
f0102a5e:	57                   	push   %edi
f0102a5f:	56                   	push   %esi
f0102a60:	53                   	push   %ebx
f0102a61:	83 ec 58             	sub    $0x58,%esp
	//[1] get pointer to the start of the "user_program_name" program in memory
	// Hint: use "get_user_program_info" function, 
	// you should set the following "ptr_program_start" by the start address of the user program 
	uint8* ptr_program_start = 0; 

	struct UserProgramInfo* ptr_user_program_info =get_user_program_info(user_program_name);
f0102a64:	ff 75 08             	pushl  0x8(%ebp)
f0102a67:	e8 37 07 00 00       	call   f01031a3 <get_user_program_info>
f0102a6c:	89 c6                	mov    %eax,%esi

	if (ptr_user_program_info == 0)
f0102a6e:	83 c4 10             	add    $0x10,%esp
f0102a71:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a76:	85 c0                	test   %eax,%eax
f0102a78:	0f 84 98 02 00 00    	je     f0102d16 <env_create+0x2bb>
		return NULL ;

	ptr_program_start = ptr_user_program_info->ptr_start ;
f0102a7e:	8b 40 08             	mov    0x8(%eax),%eax
f0102a81:	89 45 b4             	mov    %eax,0xffffffb4(%ebp)
	ptr_user_program_info->mainS = ptr_user_program_info->tableS = 0;
f0102a84:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
f0102a8b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	//[2] allocate new environment, (from the free environment list)
	//if there's no one, return NULL
	// Hint: use "allocate_environment" function
	struct Env* e = NULL;
f0102a92:	c7 45 c4 00 00 00 00 	movl   $0x0,0xffffffc4(%ebp)
	if(allocate_environment(&e) == E_NO_FREE_ENV)
f0102a99:	83 ec 0c             	sub    $0xc,%esp
f0102a9c:	8d 45 c4             	lea    0xffffffc4(%ebp),%eax
f0102a9f:	50                   	push   %eax
f0102aa0:	e8 f3 fe ff ff       	call   f0102998 <allocate_environment>
f0102aa5:	83 c4 10             	add    $0x10,%esp
f0102aa8:	ba 00 00 00 00       	mov    $0x0,%edx
f0102aad:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0102ab0:	0f 84 60 02 00 00    	je     f0102d16 <env_create+0x2bb>
	{
		return 0;
	}

	//=========================================================
	//Hands On 1:
	//[3] allocate a frame for the page directory, Don't forget to set the references of the allocated frame.
	//if there's no free space, return NULL
	//your code here . . .
	struct Frame_Info* ptr_new_dir_frame;
	if(allocate_frame(&ptr_new_dir_frame) == E_NO_MEM)
f0102ab6:	83 ec 0c             	sub    $0xc,%esp
f0102ab9:	8d 45 c0             	lea    0xffffffc0(%ebp),%eax
f0102abc:	50                   	push   %eax
f0102abd:	e8 4c fb ff ff       	call   f010260e <allocate_frame>
f0102ac2:	83 c4 10             	add    $0x10,%esp
f0102ac5:	ba 00 00 00 00       	mov    $0x0,%edx
f0102aca:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102acd:	0f 84 43 02 00 00    	je     f0102d16 <env_create+0x2bb>
	{
		return NULL;
	}
	ptr_new_dir_frame->references = 1;
f0102ad3:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f0102ad6:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0102adc:	8b 55 c0             	mov    0xffffffc0(%ebp),%edx
f0102adf:	2b 15 7c e9 19 f0    	sub    0xf019e97c,%edx
f0102ae5:	c1 fa 02             	sar    $0x2,%edx
f0102ae8:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102aeb:	89 c1                	mov    %eax,%ecx
f0102aed:	c1 e1 04             	shl    $0x4,%ecx
f0102af0:	01 c8                	add    %ecx,%eax
f0102af2:	89 c1                	mov    %eax,%ecx
f0102af4:	c1 e1 08             	shl    $0x8,%ecx
f0102af7:	01 c8                	add    %ecx,%eax
f0102af9:	89 c1                	mov    %eax,%ecx
f0102afb:	c1 e1 10             	shl    $0x10,%ecx
f0102afe:	01 c8                	add    %ecx,%eax
f0102b00:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0102b03:	89 c1                	mov    %eax,%ecx
f0102b05:	c1 e1 0c             	shl    $0xc,%ecx
	//[4] copy kernel directory into the new directory
	//your code here . . .
	uint32 phys_address_new_dir = to_physical_address(ptr_new_dir_frame);
	uint32* ptr_new_dir = K_VIRTUAL_ADDRESS(phys_address_new_dir);
f0102b08:	89 ca                	mov    %ecx,%edx
f0102b0a:	89 c8                	mov    %ecx,%eax
f0102b0c:	c1 e8 0c             	shr    $0xc,%eax
f0102b0f:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f0102b15:	72 31                	jb     f0102b48 <env_create+0xed>
f0102b17:	51                   	push   %ecx
f0102b18:	68 40 56 10 f0       	push   $0xf0105640
f0102b1d:	68 bb 00 00 00       	push   $0xbb
f0102b22:	68 18 5d 10 f0       	push   $0xf0105d18
f0102b27:	e8 d2 d5 ff ff       	call   f01000fe <_panic>
	//OR use this line:
	//uint32* ptr_new_dir = (uint32*)(phys_address_new_dir+KERNEL_BASE);

	int i;
	for(i=0;i<1024;i++)
	{
		ptr_new_dir[i] = ptr_page_directory[i];
	}

	//[5] set e->env_pgdir to page directory virtual address
	//and e->env_cr3 to page directory physical address.
	//your code here
	e->env_pgdir = ptr_new_dir;
	e->env_cr3 = phys_address_new_dir;
	//============================================================

	//Complete other environment initializations, (envID, status and most of registers)
	complete_environment_initialization(e);

	//[6] update the UserProgramInfo in userPrograms[] corresponding to this program
	ptr_user_program_info->environment = e;

	// We want to load the program into the user virtual space
	// each program is constructed from one or more segments,
	// each segment has the following information grouped in "struct ProgramSegment"
	//	1- uint8 *ptr_start: 	start address of this segment in memory 
	//	2- uint32 size_in_file: size occupied by this segment inside the program file, 
	//	3- uint32 size_in_memory: actual size required by this segment in memory
	// 	usually size_in_file < or = size_in_memory 
	//	4- uint8 *virtual_address: start virtual address that this segment should be copied to it  

	//switch to user page directory
	// rcr3() reads cr3, lcr3() loads cr3
	kern_phys_pgdir = rcr3() ;
	lcr3(e->env_cr3) ;

	//load each program segment into user virtual space
	struct ProgramSegment* seg = NULL;  //use inside PROGRAM_SEGMENT_FOREACH as current segment information	

	PROGRAM_SEGMENT_FOREACH(seg, ptr_program_start)
	{
		//============================================================
		//[7] allocate space for current program segment and map it at
		//seg->virtual_address
		// if program_segment_alloc_map() returns E_NO_MEM, call env_free() to     free all environment memory,
		// zero the UserProgramInfo* ptr->environment then return NULL

		//Hands On 2: implementation of function program_segment_alloc_map()
		int ret = program_segment_alloc_map(e, (void *)seg->virtual_address, seg->size_in_memory) ;
		if (ret == E_NO_MEM)
		{
			env_free(e);
			ptr_user_program_info->environment = NULL;
			return NULL;
		}
		//============================================================

		//[8] copy program segment from (seg->ptr_start) to
		//(seg->virtual_address) with size seg->size_in_file
		uint8 *src_ptr = (uint8 *)(seg->ptr_start) ;
		uint8 *dst_ptr = (uint8 *) seg->virtual_address;

		int i ;

		for(i = 0 ; i < seg->size_in_file; i++)
		{
			*dst_ptr = *src_ptr ;
			dst_ptr++ ;
			src_ptr++ ;
		}

		//Initialize the rest of the program segment the rest
		//(seg->size_in_memory - seg->size_in_file) bytes
		//By Zero
		for(i = seg->size_in_file ; i < seg->size_in_memory ; i++)
		{
			*dst_ptr = 0 ;
			dst_ptr++;
		}
	}

	//[9] now set the entry point of the environment
	set_environment_entry_point(ptr_user_program_info);


	//[10] Allocate and map one page for the program's initial stack
	// at virtual address USTACKTOP - PAGE_SIZE.
	// if there is no free memory, call env_free() to free all env. memory,
	// zero the UserProgramInfo* ptr->environment then return NULL
	int count = ptr_user_program_info->stack_pages;
	//cprintf("%d\n", count);
	int j;
	uint32 bb = USTACKTOP;
	for( j = 0 ; j<count ; j++ )
	{
		struct Frame_Info *pp = NULL;
		if (allocate_frame(&pp) == E_NO_MEM)
		{
			env_free(e);
			ptr_user_program_info->environment = NULL;
			return NULL;
		}

		// map the allocated page
		void* ptr_user_stack_bottom = (void *)(bb - PAGE_SIZE);
		bb -= PAGE_SIZE;
		int ret = map_frame(e->env_pgdir, pp, ptr_user_stack_bottom, PERM_USER|PERM_WRITEABLE);

		if (ret == E_NO_MEM)
		{
			env_free(e);
f0102b2c:	83 ec 0c             	sub    $0xc,%esp
f0102b2f:	ff 75 c4             	pushl  0xffffffc4(%ebp)
f0102b32:	e8 1b 02 00 00       	call   f0102d52 <env_free>
			ptr_user_program_info->environment = NULL;
f0102b37:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
			return NULL;
f0102b3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b43:	e9 ce 01 00 00       	jmp    f0102d16 <env_create+0x2bb>
f0102b48:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102b4e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b53:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f0102b58:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0102b5b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
f0102b5e:	43                   	inc    %ebx
f0102b5f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0102b65:	7e ec                	jle    f0102b53 <env_create+0xf8>
f0102b67:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102b6a:	89 50 5c             	mov    %edx,0x5c(%eax)
f0102b6d:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102b70:	89 48 60             	mov    %ecx,0x60(%eax)
f0102b73:	83 ec 0c             	sub    $0xc,%esp
f0102b76:	ff 75 c4             	pushl  0xffffffc4(%ebp)
f0102b79:	e8 c8 03 00 00       	call   f0102f46 <complete_environment_initialization>
f0102b7e:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102b81:	89 46 0c             	mov    %eax,0xc(%esi)
}

static __inline uint32
rcr3(void)
{
f0102b84:	83 c4 08             	add    $0x8,%esp
	uint32 val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0102b87:	0f 20 d8             	mov    %cr3,%eax
f0102b8a:	a3 8c e9 19 f0       	mov    %eax,0xf019e98c
f0102b8f:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102b92:	8b 40 60             	mov    0x60(%eax),%eax
f0102b95:	0f 22 d8             	mov    %eax,%cr3
f0102b98:	8d 5d c8             	lea    0xffffffc8(%ebp),%ebx
f0102b9b:	ff 75 b4             	pushl  0xffffffb4(%ebp)
f0102b9e:	53                   	push   %ebx
f0102b9f:	e8 0a 05 00 00       	call   f01030ae <PROGRAM_SEGMENT_FIRST>
f0102ba4:	83 c4 0c             	add    $0xc,%esp
f0102ba7:	83 7d d8 ff          	cmpl   $0xffffffff,0xffffffd8(%ebp)
f0102bab:	0f 95 c0             	setne  %al
f0102bae:	25 ff 00 00 00       	and    $0xff,%eax
f0102bb3:	f7 d8                	neg    %eax
f0102bb5:	21 c3                	and    %eax,%ebx
f0102bb7:	74 5f                	je     f0102c18 <env_create+0x1bd>
f0102bb9:	83 ec 04             	sub    $0x4,%esp
f0102bbc:	ff 73 08             	pushl  0x8(%ebx)
f0102bbf:	ff 73 0c             	pushl  0xc(%ebx)
f0102bc2:	ff 75 c4             	pushl  0xffffffc4(%ebp)
f0102bc5:	e8 23 fe ff ff       	call   f01029ed <program_segment_alloc_map>
f0102bca:	83 c4 10             	add    $0x10,%esp
f0102bcd:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102bd0:	0f 84 56 ff ff ff    	je     f0102b2c <env_create+0xd1>
f0102bd6:	8b 3b                	mov    (%ebx),%edi
f0102bd8:	8b 4b 0c             	mov    0xc(%ebx),%ecx
f0102bdb:	ba 00 00 00 00       	mov    $0x0,%edx
f0102be0:	3b 53 04             	cmp    0x4(%ebx),%edx
f0102be3:	73 0c                	jae    f0102bf1 <env_create+0x196>
f0102be5:	8a 07                	mov    (%edi),%al
f0102be7:	88 01                	mov    %al,(%ecx)
f0102be9:	41                   	inc    %ecx
f0102bea:	47                   	inc    %edi
f0102beb:	42                   	inc    %edx
f0102bec:	3b 53 04             	cmp    0x4(%ebx),%edx
f0102bef:	72 f4                	jb     f0102be5 <env_create+0x18a>
f0102bf1:	8b 53 04             	mov    0x4(%ebx),%edx
f0102bf4:	3b 53 08             	cmp    0x8(%ebx),%edx
f0102bf7:	73 0a                	jae    f0102c03 <env_create+0x1a8>
f0102bf9:	c6 01 00             	movb   $0x0,(%ecx)
f0102bfc:	41                   	inc    %ecx
f0102bfd:	42                   	inc    %edx
f0102bfe:	3b 53 08             	cmp    0x8(%ebx),%edx
f0102c01:	72 f6                	jb     f0102bf9 <env_create+0x19e>
f0102c03:	83 ec 08             	sub    $0x8,%esp
f0102c06:	ff 75 b4             	pushl  0xffffffb4(%ebp)
f0102c09:	53                   	push   %ebx
f0102c0a:	e8 eb 03 00 00       	call   f0102ffa <PROGRAM_SEGMENT_NEXT>
f0102c0f:	89 c3                	mov    %eax,%ebx
f0102c11:	83 c4 10             	add    $0x10,%esp
f0102c14:	85 c0                	test   %eax,%eax
f0102c16:	75 a1                	jne    f0102bb9 <env_create+0x15e>
f0102c18:	83 ec 0c             	sub    $0xc,%esp
f0102c1b:	56                   	push   %esi
f0102c1c:	e8 3d 06 00 00       	call   f010325e <set_environment_entry_point>
f0102c21:	8b 46 10             	mov    0x10(%esi),%eax
f0102c24:	89 45 b0             	mov    %eax,0xffffffb0(%ebp)
f0102c27:	c7 45 ac 00 e0 bf ee 	movl   $0xeebfe000,0xffffffac(%ebp)
f0102c2e:	bf 00 00 00 00       	mov    $0x0,%edi
f0102c33:	83 c4 10             	add    $0x10,%esp
f0102c36:	39 c7                	cmp    %eax,%edi
f0102c38:	7d 61                	jge    f0102c9b <env_create+0x240>
f0102c3a:	c7 45 bc 00 00 00 00 	movl   $0x0,0xffffffbc(%ebp)
f0102c41:	83 ec 0c             	sub    $0xc,%esp
f0102c44:	8d 45 bc             	lea    0xffffffbc(%ebp),%eax
f0102c47:	50                   	push   %eax
f0102c48:	e8 c1 f9 ff ff       	call   f010260e <allocate_frame>
f0102c4d:	83 c4 10             	add    $0x10,%esp
f0102c50:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102c53:	0f 84 d3 fe ff ff    	je     f0102b2c <env_create+0xd1>
f0102c59:	8b 5d ac             	mov    0xffffffac(%ebp),%ebx
f0102c5c:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f0102c62:	89 5d ac             	mov    %ebx,0xffffffac(%ebp)
f0102c65:	6a 06                	push   $0x6
f0102c67:	53                   	push   %ebx
f0102c68:	ff 75 bc             	pushl  0xffffffbc(%ebp)
f0102c6b:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102c6e:	ff 70 5c             	pushl  0x5c(%eax)
f0102c71:	e8 39 fb ff ff       	call   f01027af <map_frame>
f0102c76:	83 c4 10             	add    $0x10,%esp
f0102c79:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102c7c:	0f 84 aa fe ff ff    	je     f0102b2c <env_create+0xd1>
		}

		//initialize new page by 0's
		memset(ptr_user_stack_bottom, 0, PAGE_SIZE);
f0102c82:	83 ec 04             	sub    $0x4,%esp
f0102c85:	68 00 10 00 00       	push   $0x1000
f0102c8a:	6a 00                	push   $0x0
f0102c8c:	53                   	push   %ebx
f0102c8d:	e8 fd 17 00 00       	call   f010448f <memset>
f0102c92:	83 c4 10             	add    $0x10,%esp
f0102c95:	47                   	inc    %edi
f0102c96:	3b 7d b0             	cmp    0xffffffb0(%ebp),%edi
f0102c99:	7c 9f                	jl     f0102c3a <env_create+0x1df>
	}
	uint32 cd = 1024*4*1024;
	uint32 end = USER_TOP/(1024*PAGE_SIZE);
f0102c9b:	bf bb 03 00 00       	mov    $0x3bb,%edi
	for( i=0 ; i<end; i++ )
f0102ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((e->env_pgdir[i] & PERM_PRESENT) != 0) {
f0102ca5:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102ca8:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102cab:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0102caf:	74 3f                	je     f0102cf0 <env_create+0x295>
			{
				ptr_user_program_info->tableS++;
f0102cb1:	ff 46 18             	incl   0x18(%esi)
				uint32 *ptr_page_table = NULL;
f0102cb4:	c7 45 b8 00 00 00 00 	movl   $0x0,0xffffffb8(%ebp)
				get_page_table(e->env_pgdir, (void*) (i * cd), 0,
f0102cbb:	8d 45 b8             	lea    0xffffffb8(%ebp),%eax
f0102cbe:	50                   	push   %eax
f0102cbf:	6a 00                	push   $0x0
f0102cc1:	69 c3 00 00 40 00    	imul   $0x400000,%ebx,%eax
f0102cc7:	50                   	push   %eax
f0102cc8:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102ccb:	ff 70 5c             	pushl  0x5c(%eax)
f0102cce:	e8 c8 f9 ff ff       	call   f010269b <get_page_table>
						&ptr_page_table);
				int j;
				for (j = 0; j < 1024; j++) {
f0102cd3:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cd8:	83 c4 10             	add    $0x10,%esp
					if ((ptr_page_table[j] & PERM_PRESENT) != 0)
f0102cdb:	8b 45 b8             	mov    0xffffffb8(%ebp),%eax
f0102cde:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0102ce2:	74 03                	je     f0102ce7 <env_create+0x28c>
						ptr_user_program_info->mainS++;
f0102ce4:	ff 46 14             	incl   0x14(%esi)
f0102ce7:	42                   	inc    %edx
f0102ce8:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0102cee:	7e eb                	jle    f0102cdb <env_create+0x280>
f0102cf0:	43                   	inc    %ebx
f0102cf1:	39 fb                	cmp    %edi,%ebx
f0102cf3:	72 b0                	jb     f0102ca5 <env_create+0x24a>
				}
			}
		}
	ptr_user_program_info->tableS ++;
f0102cf5:	8b 46 18             	mov    0x18(%esi),%eax
f0102cf8:	40                   	inc    %eax
	ptr_user_program_info->tableS *= 4;
f0102cf9:	c1 e0 02             	shl    $0x2,%eax
f0102cfc:	89 46 18             	mov    %eax,0x18(%esi)
	ptr_user_program_info->mainS *= 4;
f0102cff:	c1 66 14 02          	shll   $0x2,0x14(%esi)
	ptr_user_program_info->envID = e->env_id;
f0102d03:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0102d06:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102d09:	89 46 20             	mov    %eax,0x20(%esi)
}

static __inline void
lcr3(uint32 val)
{
f0102d0c:	a1 8c e9 19 f0       	mov    0xf019e98c,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102d11:	0f 22 d8             	mov    %eax,%cr3
	//[11] switch back to the page directory exists before segment loading
	lcr3(kern_phys_pgdir) ;

	return ptr_user_program_info;
f0102d14:	89 f2                	mov    %esi,%edx
}
f0102d16:	89 d0                	mov    %edx,%eax
f0102d18:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102d1b:	5b                   	pop    %ebx
f0102d1c:	5e                   	pop    %esi
f0102d1d:	5f                   	pop    %edi
f0102d1e:	5d                   	pop    %ebp
f0102d1f:	c3                   	ret    

f0102d20 <env_run>:

// Used to run the given environment "e", simply by 
// context switch from curenv to env e.
//  (This function does not return.)
//
void env_run(struct Env *e)
{
f0102d20:	55                   	push   %ebp
f0102d21:	89 e5                	mov    %esp,%ebp
f0102d23:	83 ec 08             	sub    $0x8,%esp
f0102d26:	8b 45 08             	mov    0x8(%ebp),%eax
	if(curenv != e)
f0102d29:	39 05 f4 e0 19 f0    	cmp    %eax,0xf019e0f4
f0102d2f:	74 13                	je     f0102d44 <env_run+0x24>
	{		
		curenv = e ;
f0102d31:	a3 f4 e0 19 f0       	mov    %eax,0xf019e0f4
		curenv->env_runs++ ;
f0102d36:	ff 40 58             	incl   0x58(%eax)
}

static __inline void
lcr3(uint32 val)
{
f0102d39:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0102d3e:	8b 40 60             	mov    0x60(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102d41:	0f 22 d8             	mov    %eax,%cr3
		lcr3(curenv->env_cr3) ;	
	}	
	env_pop_tf(&(curenv->env_tf));
f0102d44:	83 ec 0c             	sub    $0xc,%esp
f0102d47:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f0102d4d:	e8 fd 05 00 00       	call   f010334f <env_pop_tf>

f0102d52 <env_free>:
}

//
// Frees environment "e" and all memory it uses.
// 
void env_free(struct Env *e)
{
f0102d52:	55                   	push   %ebp
f0102d53:	89 e5                	mov    %esp,%ebp
f0102d55:	57                   	push   %edi
f0102d56:	56                   	push   %esi
f0102d57:	53                   	push   %ebx
f0102d58:	83 ec 0c             	sub    $0xc,%esp
f0102d5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint32 cd = 1024*4*1024;
	uint32 i;
	for( i=0 ; i<1024 ; i++ )
f0102d5e:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	{
		if(  (e->env_pgdir[ i ] & PERM_PRESENT) != 0 && ((i*cd) < USER_TOP))
f0102d65:	8b 57 5c             	mov    0x5c(%edi),%edx
f0102d68:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0102d6b:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0102d6f:	0f 84 c9 00 00 00    	je     f0102e3e <env_free+0xec>
f0102d75:	69 c8 00 00 40 00    	imul   $0x400000,%eax,%ecx
f0102d7b:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0102d81:	0f 87 b7 00 00 00    	ja     f0102e3e <env_free+0xec>
		{
			uint32 *ptr_page_table = NULL;
f0102d87:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			get_page_table( e->env_pgdir, (void*)(i*cd), 0, &ptr_page_table);
f0102d8e:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0102d91:	50                   	push   %eax
f0102d92:	6a 00                	push   $0x0
f0102d94:	51                   	push   %ecx
f0102d95:	52                   	push   %edx
f0102d96:	e8 00 f9 ff ff       	call   f010269b <get_page_table>
			int j;
			for( j=0 ; j<1024 ; j++ )
f0102d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102da0:	83 c4 10             	add    $0x10,%esp
f0102da3:	69 75 ec 00 00 40 00 	imul   $0x400000,0xffffffec(%ebp),%esi
			{
				uint32 oo = ((i*cd)+(j*4*1024));
f0102daa:	89 d8                	mov    %ebx,%eax
f0102dac:	c1 e0 0c             	shl    $0xc,%eax
f0102daf:	8d 0c 30             	lea    (%eax,%esi,1),%ecx
				if( (ptr_page_table[ j ] &PERM_PRESENT) != 0 && ( oo< USER_TOP ))
f0102db2:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0102db8:	0f 96 c0             	setbe  %al
f0102dbb:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0102dbe:	23 04 9a             	and    (%edx,%ebx,4),%eax
f0102dc1:	a8 01                	test   $0x1,%al
f0102dc3:	74 0f                	je     f0102dd4 <env_free+0x82>
				{
					unsigned char *va = (unsigned char *) (oo);
					unmap_frame(e->env_pgdir, va);
f0102dc5:	83 ec 08             	sub    $0x8,%esp
f0102dc8:	51                   	push   %ecx
f0102dc9:	ff 77 5c             	pushl  0x5c(%edi)
f0102dcc:	e8 0b fb ff ff       	call   f01028dc <unmap_frame>
f0102dd1:	83 c4 10             	add    $0x10,%esp
f0102dd4:	43                   	inc    %ebx
f0102dd5:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0102ddb:	7e cd                	jle    f0102daa <env_free+0x58>
				}
			}
			uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table);
f0102ddd:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0102de0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102de5:	77 0d                	ja     f0102df4 <env_free+0xa2>
f0102de7:	50                   	push   %eax
f0102de8:	68 20 53 10 f0       	push   $0xf0105320
f0102ded:	68 72 01 00 00       	push   $0x172
f0102df2:	eb 6f                	jmp    f0102e63 <env_free+0x111>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0102df4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	if (PPN(physical_address) >= number_of_frames)
f0102dfa:	89 d0                	mov    %edx,%eax
f0102dfc:	c1 e8 0c             	shr    $0xc,%eax
f0102dff:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f0102e05:	73 76                	jae    f0102e7d <env_free+0x12b>
		panic("to_frame_info called with invalid pa");
f0102e07:	89 d0                	mov    %edx,%eax
f0102e09:	c1 e8 0c             	shr    $0xc,%eax
f0102e0c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e0f:	8b 15 7c e9 19 f0    	mov    0xf019e97c,%edx
f0102e15:	8d 04 82             	lea    (%edx,%eax,4),%eax
			struct Frame_Info *table_frame_info = to_frame_info(table_pa);
			table_frame_info->references = 0;
f0102e18:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
			free_frame(table_frame_info);
f0102e1e:	83 ec 0c             	sub    $0xc,%esp
f0102e21:	50                   	push   %eax
f0102e22:	e8 2a f8 ff ff       	call   f0102651 <free_frame>
			uint32 dir_index = PDX(i*cd);
f0102e27:	69 45 ec 00 00 40 00 	imul   $0x400000,0xffffffec(%ebp),%eax
f0102e2e:	c1 e8 16             	shr    $0x16,%eax
			e->env_pgdir[dir_index] = 0;
f0102e31:	8b 57 5c             	mov    0x5c(%edi),%edx
f0102e34:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
f0102e3b:	83 c4 10             	add    $0x10,%esp
f0102e3e:	ff 45 ec             	incl   0xffffffec(%ebp)
f0102e41:	81 7d ec ff 03 00 00 	cmpl   $0x3ff,0xffffffec(%ebp)
f0102e48:	0f 86 17 ff ff ff    	jbe    f0102d65 <env_free+0x13>
		}
	}

	//panic("env_free function is not completed yet") ;
	/*uint32 i;
	for ( i = 0 ; i<USER_TOP ; i+= PAGE_SIZE )
	{
		unsigned char *va = (unsigned char *) (i);
		// Un-map the page at this address
		unmap_frame(e->env_pgdir, va);
	}

	for( i = 0 ; i<USER_TOP ; i+= PTSIZE)
	{
		unsigned char *va = (unsigned char *) (i);
		uint32 * ptr_page_table;
		// get the page table of the given virtual address
		get_page_table(e->env_pgdir, va, 0, &ptr_page_table);
		if (ptr_page_table == NULL)
			continue;
		// get the physical address and Frame_Info of the page table
		uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table);
		struct Frame_Info *table_frame_info = to_frame_info(table_pa);
		// set references of the table frame to 0 then free it by adding
		// to the free frame list
		table_frame_info->references = 0;
		free_frame(table_frame_info);
		// set the corresponding entry in the directory to 0
		uint32 dir_index = PDX(va);
		e->env_pgdir[dir_index] = 0;
	}*/


	uint32 dir = K_PHYSICAL_ADDRESS(e->env_pgdir);
f0102e4e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e51:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e56:	77 12                	ja     f0102e6a <env_free+0x118>
f0102e58:	50                   	push   %eax
f0102e59:	68 20 53 10 f0       	push   $0xf0105320
f0102e5e:	68 99 01 00 00       	push   $0x199
f0102e63:	68 18 5d 10 f0       	push   $0xf0105d18
f0102e68:	eb 22                	jmp    f0102e8c <env_free+0x13a>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0102e6a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	if (PPN(physical_address) >= number_of_frames)
f0102e70:	89 d0                	mov    %edx,%eax
f0102e72:	c1 e8 0c             	shr    $0xc,%eax
f0102e75:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f0102e7b:	72 14                	jb     f0102e91 <env_free+0x13f>
		panic("to_frame_info called with invalid pa");
f0102e7d:	83 ec 04             	sub    $0x4,%esp
f0102e80:	68 60 53 10 f0       	push   $0xf0105360
f0102e85:	6a 39                	push   $0x39
f0102e87:	68 be 4e 10 f0       	push   $0xf0104ebe
f0102e8c:	e8 6d d2 ff ff       	call   f01000fe <_panic>
f0102e91:	89 d0                	mov    %edx,%eax
f0102e93:	c1 e8 0c             	shr    $0xc,%eax
f0102e96:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e99:	8b 15 7c e9 19 f0    	mov    0xf019e97c,%edx
f0102e9f:	8d 04 82             	lea    (%edx,%eax,4),%eax
	struct Frame_Info *table_frame_info = to_frame_info(dir);
	table_frame_info->references = 0;
f0102ea2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	free_frame(table_frame_info);
f0102ea8:	83 ec 0c             	sub    $0xc,%esp
f0102eab:	50                   	push   %eax
f0102eac:	e8 a0 f7 ff ff       	call   f0102651 <free_frame>
}

static __inline void
lcr3(uint32 val)
{
f0102eb1:	a1 8c e9 19 f0       	mov    0xf019e98c,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102eb6:	0f 22 d8             	mov    %eax,%cr3

	// [1] Unmap all mapped pages in the user portion of the environment (i.e. below USER_TOP)

	// [2] Free all mapped page tables in the user portion of the environment

	// [3] free the page directory of the environment

	// [4] switch back to the kernel page directory

	// [5] free the environment (return it back to the free environment list)
	// Hint: use free_environment()
	lcr3(kern_phys_pgdir) ;
	free_environment(e);
f0102eb9:	89 3c 24             	mov    %edi,(%esp)
f0102ebc:	e8 ef fa ff ff       	call   f01029b0 <free_environment>
}
f0102ec1:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102ec4:	5b                   	pop    %ebx
f0102ec5:	5e                   	pop    %esi
f0102ec6:	5f                   	pop    %edi
f0102ec7:	5d                   	pop    %ebp
f0102ec8:	c3                   	ret    

f0102ec9 <env_init>:


//====================================================================================
//====================================================================================
//====================================================================================
//====================================================================================
//====================================================================================


// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to allocate_environment()
// returns envs[0].
//
void
env_init(void)
{	
f0102ec9:	55                   	push   %ebp
f0102eca:	89 e5                	mov    %esp,%ebp
f0102ecc:	53                   	push   %ebx
	int iEnv = NENV-1;
f0102ecd:	bb ff 03 00 00       	mov    $0x3ff,%ebx
	for(; iEnv >= 0; iEnv--)
	{
		envs[iEnv].env_status = ENV_FREE;
f0102ed2:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f0102ed5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102ed8:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0102edf:	a1 f0 e0 19 f0       	mov    0xf019e0f0,%eax
f0102ee4:	c7 44 08 54 00 00 00 	movl   $0x0,0x54(%eax,%ecx,1)
f0102eeb:	00 
		envs[iEnv].env_id = 0;
f0102eec:	a1 f0 e0 19 f0       	mov    0xf019e0f0,%eax
f0102ef1:	c7 44 08 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ecx,1)
f0102ef8:	00 
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
f0102ef9:	8b 15 f8 e0 19 f0    	mov    0xf019e0f8,%edx
f0102eff:	a1 f0 e0 19 f0       	mov    0xf019e0f0,%eax
f0102f04:	89 54 08 44          	mov    %edx,0x44(%eax,%ecx,1)
f0102f08:	85 d2                	test   %edx,%edx
f0102f0a:	74 14                	je     f0102f20 <env_init+0x57>
f0102f0c:	89 c8                	mov    %ecx,%eax
f0102f0e:	03 05 f0 e0 19 f0    	add    0xf019e0f0,%eax
f0102f14:	83 c0 44             	add    $0x44,%eax
f0102f17:	8b 15 f8 e0 19 f0    	mov    0xf019e0f8,%edx
f0102f1d:	89 42 48             	mov    %eax,0x48(%edx)
f0102f20:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f0102f23:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102f26:	c1 e0 02             	shl    $0x2,%eax
f0102f29:	8b 0d f0 e0 19 f0    	mov    0xf019e0f0,%ecx
f0102f2f:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0102f32:	89 15 f8 e0 19 f0    	mov    %edx,0xf019e0f8
f0102f38:	c7 44 01 48 f8 e0 19 	movl   $0xf019e0f8,0x48(%ecx,%eax,1)
f0102f3f:	f0 
f0102f40:	4b                   	dec    %ebx
f0102f41:	79 8f                	jns    f0102ed2 <env_init+0x9>
	}
}
f0102f43:	5b                   	pop    %ebx
f0102f44:	5d                   	pop    %ebp
f0102f45:	c3                   	ret    

f0102f46 <complete_environment_initialization>:

void complete_environment_initialization(struct Env* e)
{	
f0102f46:	55                   	push   %ebp
f0102f47:	89 e5                	mov    %esp,%ebp
f0102f49:	53                   	push   %ebx
f0102f4a:	83 ec 04             	sub    $0x4,%esp
f0102f4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//VPT and UVPT map the env's own page table, with
	//different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PERM_PRESENT | PERM_WRITEABLE;
f0102f50:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102f53:	8b 43 60             	mov    0x60(%ebx),%eax
f0102f56:	83 c8 03             	or     $0x3,%eax
f0102f59:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PERM_PRESENT | PERM_USER;
f0102f5f:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102f62:	8b 43 60             	mov    0x60(%ebx),%eax
f0102f65:	83 c8 05             	or     $0x5,%eax
f0102f68:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)

	int32 generation;	
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102f6e:	8b 53 4c             	mov    0x4c(%ebx),%edx
f0102f71:	81 c2 00 10 00 00    	add    $0x1000,%edx
	if (generation <= 0)	// Don't create a negative env_id.
f0102f77:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f0102f7d:	7f 05                	jg     f0102f84 <complete_environment_initialization+0x3e>
		generation = 1 << ENVGENSHIFT;
f0102f7f:	ba 00 10 00 00       	mov    $0x1000,%edx
	e->env_id = generation | (e - envs);
f0102f84:	89 d8                	mov    %ebx,%eax
f0102f86:	2b 05 f0 e0 19 f0    	sub    0xf019e0f0,%eax
f0102f8c:	c1 f8 02             	sar    $0x2,%eax
f0102f8f:	69 c0 29 5c 8f c2    	imul   $0xc28f5c29,%eax,%eax
f0102f95:	09 d0                	or     %edx,%eax
f0102f97:	89 43 4c             	mov    %eax,0x4c(%ebx)

	// Set the basic status variables.
	e->env_parent_id = 0;//parent_id;
f0102f9a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102fa1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102fa8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102faf:	83 ec 04             	sub    $0x4,%esp
f0102fb2:	6a 44                	push   $0x44
f0102fb4:	6a 00                	push   $0x0
f0102fb6:	53                   	push   %ebx
f0102fb7:	e8 d3 14 00 00       	call   f010448f <memset>

	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.

	e->env_tf.tf_ds = GD_UD | 3;
f0102fbc:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102fc2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102fc8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102fce:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102fd5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e);	
f0102fdb:	83 c4 10             	add    $0x10,%esp
f0102fde:	83 7b 44 00          	cmpl   $0x0,0x44(%ebx)
f0102fe2:	74 09                	je     f0102fed <complete_environment_initialization+0xa7>
f0102fe4:	8b 53 44             	mov    0x44(%ebx),%edx
f0102fe7:	8b 43 48             	mov    0x48(%ebx),%eax
f0102fea:	89 42 48             	mov    %eax,0x48(%edx)
f0102fed:	8b 53 48             	mov    0x48(%ebx),%edx
f0102ff0:	8b 43 44             	mov    0x44(%ebx),%eax
f0102ff3:	89 02                	mov    %eax,(%edx)
	return ;
}
f0102ff5:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102ff8:	c9                   	leave  
f0102ff9:	c3                   	ret    

f0102ffa <PROGRAM_SEGMENT_NEXT>:

struct ProgramSegment* PROGRAM_SEGMENT_NEXT(struct ProgramSegment* seg, uint8* ptr_program_start)
																						{
f0102ffa:	55                   	push   %ebp
f0102ffb:	89 e5                	mov    %esp,%ebp
f0102ffd:	57                   	push   %edi
f0102ffe:	56                   	push   %esi
f0102fff:	53                   	push   %ebx
f0103000:	83 ec 0c             	sub    $0xc,%esp
f0103003:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103006:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int index = (*seg).segment_id++;
f0103009:	ff 41 10             	incl   0x10(%ecx)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f010300c:	89 fa                	mov    %edi,%edx
	if (pELFHDR->e_magic != ELF_MAGIC) 
f010300e:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103014:	74 17                	je     f010302d <PROGRAM_SEGMENT_NEXT+0x33>
		panic("Matafa2nash 3ala Keda"); 
f0103016:	83 ec 04             	sub    $0x4,%esp
f0103019:	68 30 5d 10 f0       	push   $0xf0105d30
f010301e:	68 f7 01 00 00       	push   $0x1f7
f0103023:	68 18 5d 10 f0       	push   $0xf0105d18
f0103028:	e8 d1 d0 ff ff       	call   f01000fe <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f010302d:	89 fe                	mov    %edi,%esi
f010302f:	03 77 1c             	add    0x1c(%edi),%esi

	while (ph[(*seg).segment_id].p_type != ELF_PROG_LOAD && ((*seg).segment_id < pELFHDR->e_phnum)) (*seg).segment_id++;	
f0103032:	8b 41 10             	mov    0x10(%ecx),%eax
f0103035:	89 c3                	mov    %eax,%ebx
f0103037:	c1 e0 05             	shl    $0x5,%eax
f010303a:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f010303e:	74 2b                	je     f010306b <PROGRAM_SEGMENT_NEXT+0x71>
f0103040:	66 8b 47 2c          	mov    0x2c(%edi),%ax
f0103044:	25 ff ff 00 00       	and    $0xffff,%eax
f0103049:	39 c3                	cmp    %eax,%ebx
f010304b:	73 1e                	jae    f010306b <PROGRAM_SEGMENT_NEXT+0x71>
f010304d:	8d 43 01             	lea    0x1(%ebx),%eax
f0103050:	89 41 10             	mov    %eax,0x10(%ecx)
f0103053:	89 c3                	mov    %eax,%ebx
f0103055:	c1 e0 05             	shl    $0x5,%eax
f0103058:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f010305c:	74 0d                	je     f010306b <PROGRAM_SEGMENT_NEXT+0x71>
f010305e:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0103062:	25 ff ff 00 00       	and    $0xffff,%eax
f0103067:	39 c3                	cmp    %eax,%ebx
f0103069:	72 e2                	jb     f010304d <PROGRAM_SEGMENT_NEXT+0x53>
	index = (*seg).segment_id;
f010306b:	8b 59 10             	mov    0x10(%ecx),%ebx

	if(index < pELFHDR->e_phnum)
f010306e:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0103072:	25 ff ff 00 00       	and    $0xffff,%eax
	{
		(*seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
		(*seg).size_in_memory =  ph[index].p_memsz;
		(*seg).size_in_file = ph[index].p_filesz;
		(*seg).virtual_address = (uint8*)ph[index].p_va;
		return seg;
	}
	return 0;
f0103077:	ba 00 00 00 00       	mov    $0x0,%edx
f010307c:	39 c3                	cmp    %eax,%ebx
f010307e:	7d 24                	jge    f01030a4 <PROGRAM_SEGMENT_NEXT+0xaa>
f0103080:	89 da                	mov    %ebx,%edx
f0103082:	c1 e2 05             	shl    $0x5,%edx
f0103085:	89 f8                	mov    %edi,%eax
f0103087:	03 44 16 04          	add    0x4(%esi,%edx,1),%eax
f010308b:	89 01                	mov    %eax,(%ecx)
f010308d:	8b 44 16 14          	mov    0x14(%esi,%edx,1),%eax
f0103091:	89 41 08             	mov    %eax,0x8(%ecx)
f0103094:	8b 44 16 10          	mov    0x10(%esi,%edx,1),%eax
f0103098:	89 41 04             	mov    %eax,0x4(%ecx)
f010309b:	8b 44 16 08          	mov    0x8(%esi,%edx,1),%eax
f010309f:	89 41 0c             	mov    %eax,0xc(%ecx)
f01030a2:	89 ca                	mov    %ecx,%edx
																						}
f01030a4:	89 d0                	mov    %edx,%eax
f01030a6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01030a9:	5b                   	pop    %ebx
f01030aa:	5e                   	pop    %esi
f01030ab:	5f                   	pop    %edi
f01030ac:	5d                   	pop    %ebp
f01030ad:	c3                   	ret    

f01030ae <PROGRAM_SEGMENT_FIRST>:

struct ProgramSegment PROGRAM_SEGMENT_FIRST( uint8* ptr_program_start)
{
f01030ae:	55                   	push   %ebp
f01030af:	89 e5                	mov    %esp,%ebp
f01030b1:	57                   	push   %edi
f01030b2:	56                   	push   %esi
f01030b3:	53                   	push   %ebx
f01030b4:	83 ec 3c             	sub    $0x3c,%esp
f01030b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct ProgramSegment seg;
	seg.segment_id = 0;
f01030ba:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f01030c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030c4:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f01030c7:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01030cd:	74 17                	je     f01030e6 <PROGRAM_SEGMENT_FIRST+0x38>
		panic("Matafa2nash 3ala Keda"); 
f01030cf:	83 ec 04             	sub    $0x4,%esp
f01030d2:	68 30 5d 10 f0       	push   $0xf0105d30
f01030d7:	68 10 02 00 00       	push   $0x210
f01030dc:	68 18 5d 10 f0       	push   $0xf0105d18
f01030e1:	e8 18 d0 ff ff       	call   f01000fe <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f01030e6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01030e9:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f01030ec:	03 72 1c             	add    0x1c(%edx),%esi
	while (ph[(seg).segment_id].p_type != ELF_PROG_LOAD && ((seg).segment_id < pELFHDR->e_phnum)) (seg).segment_id++;
f01030ef:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01030f2:	89 c1                	mov    %eax,%ecx
f01030f4:	c1 e0 05             	shl    $0x5,%eax
f01030f7:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f01030fb:	74 26                	je     f0103123 <PROGRAM_SEGMENT_FIRST+0x75>
f01030fd:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0103101:	25 ff ff 00 00       	and    $0xffff,%eax
f0103106:	39 c1                	cmp    %eax,%ecx
f0103108:	73 19                	jae    f0103123 <PROGRAM_SEGMENT_FIRST+0x75>
f010310a:	89 c3                	mov    %eax,%ebx
f010310c:	8d 51 01             	lea    0x1(%ecx),%edx
f010310f:	89 d1                	mov    %edx,%ecx
f0103111:	89 d0                	mov    %edx,%eax
f0103113:	c1 e0 05             	shl    $0x5,%eax
f0103116:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f010311a:	74 04                	je     f0103120 <PROGRAM_SEGMENT_FIRST+0x72>
f010311c:	39 da                	cmp    %ebx,%edx
f010311e:	72 ec                	jb     f010310c <PROGRAM_SEGMENT_FIRST+0x5e>
f0103120:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
	int index = (seg).segment_id;
f0103123:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0103126:	89 45 c0             	mov    %eax,0xffffffc0(%ebp)

	if(index < pELFHDR->e_phnum)
f0103129:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f010312c:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0103130:	25 ff ff 00 00       	and    $0xffff,%eax
f0103135:	39 45 c0             	cmp    %eax,0xffffffc0(%ebp)
f0103138:	7d 38                	jge    f0103172 <PROGRAM_SEGMENT_FIRST+0xc4>
	{	
		(seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f010313a:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f010313d:	c1 e0 05             	shl    $0x5,%eax
f0103140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103143:	03 4c 06 04          	add    0x4(%esi,%eax,1),%ecx
f0103147:	89 4d c8             	mov    %ecx,0xffffffc8(%ebp)
		(seg).size_in_memory =  ph[index].p_memsz;
f010314a:	8b 5c 06 14          	mov    0x14(%esi,%eax,1),%ebx
f010314e:	89 5d d0             	mov    %ebx,0xffffffd0(%ebp)
		(seg).size_in_file = ph[index].p_filesz;
f0103151:	8b 54 06 10          	mov    0x10(%esi,%eax,1),%edx
f0103155:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
		(seg).virtual_address = (uint8*)ph[index].p_va;
f0103158:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f010315c:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
		return seg;
f010315f:	89 0f                	mov    %ecx,(%edi)
f0103161:	89 57 04             	mov    %edx,0x4(%edi)
f0103164:	89 5f 08             	mov    %ebx,0x8(%edi)
f0103167:	89 47 0c             	mov    %eax,0xc(%edi)
f010316a:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f010316d:	89 47 10             	mov    %eax,0x10(%edi)
f0103170:	eb 25                	jmp    f0103197 <PROGRAM_SEGMENT_FIRST+0xe9>
	}
	seg.segment_id = -1;
f0103172:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,0xffffffd8(%ebp)
	return seg;
f0103179:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
f010317c:	89 07                	mov    %eax,(%edi)
f010317e:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0103181:	89 47 04             	mov    %eax,0x4(%edi)
f0103184:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f0103187:	89 47 08             	mov    %eax,0x8(%edi)
f010318a:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f010318d:	89 47 0c             	mov    %eax,0xc(%edi)
f0103190:	c7 47 10 ff ff ff ff 	movl   $0xffffffff,0x10(%edi)
}
f0103197:	89 f8                	mov    %edi,%eax
f0103199:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010319c:	5b                   	pop    %ebx
f010319d:	5e                   	pop    %esi
f010319e:	5f                   	pop    %edi
f010319f:	5d                   	pop    %ebp
f01031a0:	c2 04 00             	ret    $0x4

f01031a3 <get_user_program_info>:

struct UserProgramInfo* get_user_program_info(char* user_program_name)
																						{
f01031a3:	55                   	push   %ebp
f01031a4:	89 e5                	mov    %esp,%ebp
f01031a6:	56                   	push   %esi
f01031a7:	53                   	push   %ebx
f01031a8:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f01031ab:	bb 00 00 00 00       	mov    $0x0,%ebx
f01031b0:	3b 1d fc e7 11 f0    	cmp    0xf011e7fc,%ebx
f01031b6:	7d 23                	jge    f01031db <get_user_program_info+0x38>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
f01031b8:	83 ec 08             	sub    $0x8,%esp
f01031bb:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
f01031be:	ff 34 85 20 e7 11 f0 	pushl  0xf011e720(,%eax,4)
f01031c5:	56                   	push   %esi
f01031c6:	e8 09 12 00 00       	call   f01043d4 <strcmp>
f01031cb:	83 c4 10             	add    $0x10,%esp
f01031ce:	85 c0                	test   %eax,%eax
f01031d0:	74 09                	je     f01031db <get_user_program_info+0x38>
f01031d2:	43                   	inc    %ebx
f01031d3:	3b 1d fc e7 11 f0    	cmp    0xf011e7fc,%ebx
f01031d9:	7c dd                	jl     f01031b8 <get_user_program_info+0x15>
			break;
	}
	if(i==NUM_USER_PROGS) 
	{
		cprintf("Unknown user program '%s'\n", user_program_name);
		return 0;
	}

	return &userPrograms[i];
f01031db:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
f01031de:	8d 04 85 20 e7 11 f0 	lea    0xf011e720(,%eax,4),%eax
f01031e5:	3b 1d fc e7 11 f0    	cmp    0xf011e7fc,%ebx
f01031eb:	75 13                	jne    f0103200 <get_user_program_info+0x5d>
f01031ed:	83 ec 08             	sub    $0x8,%esp
f01031f0:	56                   	push   %esi
f01031f1:	68 46 5d 10 f0       	push   $0xf0105d46
f01031f6:	e8 e3 01 00 00       	call   f01033de <cprintf>
f01031fb:	b8 00 00 00 00       	mov    $0x0,%eax
																						}
f0103200:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0103203:	5b                   	pop    %ebx
f0103204:	5e                   	pop    %esi
f0103205:	5d                   	pop    %ebp
f0103206:	c3                   	ret    

f0103207 <get_user_program_info_by_env>:

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
																						{
f0103207:	55                   	push   %ebp
f0103208:	89 e5                	mov    %esp,%ebp
f010320a:	53                   	push   %ebx
f010320b:	83 ec 04             	sub    $0x4,%esp
f010320e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0103211:	ba 00 00 00 00       	mov    $0x0,%edx
f0103216:	3b 15 fc e7 11 f0    	cmp    0xf011e7fc,%edx
f010321c:	7d 17                	jge    f0103235 <get_user_program_info_by_env+0x2e>
f010321e:	8b 0d fc e7 11 f0    	mov    0xf011e7fc,%ecx
		if (e== userPrograms[i].environment)
f0103224:	8d 04 d2             	lea    (%edx,%edx,8),%eax
f0103227:	3b 1c 85 2c e7 11 f0 	cmp    0xf011e72c(,%eax,4),%ebx
f010322e:	74 05                	je     f0103235 <get_user_program_info_by_env+0x2e>
f0103230:	42                   	inc    %edx
f0103231:	39 ca                	cmp    %ecx,%edx
f0103233:	7c ef                	jl     f0103224 <get_user_program_info_by_env+0x1d>
			break;
	}
	if(i==NUM_USER_PROGS) 
	{
		cprintf("Unknown user program \n");
		return 0;
	}

	return &userPrograms[i];
f0103235:	8d 04 d2             	lea    (%edx,%edx,8),%eax
f0103238:	8d 04 85 20 e7 11 f0 	lea    0xf011e720(,%eax,4),%eax
f010323f:	3b 15 fc e7 11 f0    	cmp    0xf011e7fc,%edx
f0103245:	75 12                	jne    f0103259 <get_user_program_info_by_env+0x52>
f0103247:	83 ec 0c             	sub    $0xc,%esp
f010324a:	68 61 5d 10 f0       	push   $0xf0105d61
f010324f:	e8 8a 01 00 00       	call   f01033de <cprintf>
f0103254:	b8 00 00 00 00       	mov    $0x0,%eax
																						}
f0103259:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010325c:	c9                   	leave  
f010325d:	c3                   	ret    

f010325e <set_environment_entry_point>:

void set_environment_entry_point(struct UserProgramInfo* ptr_user_program)
{
f010325e:	55                   	push   %ebp
f010325f:	89 e5                	mov    %esp,%ebp
f0103261:	83 ec 08             	sub    $0x8,%esp
f0103264:	8b 45 08             	mov    0x8(%ebp),%eax
	uint8* ptr_program_start=ptr_user_program->ptr_start;
	struct Env* e = ptr_user_program->environment;
f0103267:	8b 50 0c             	mov    0xc(%eax),%edx

	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f010326a:	8b 40 08             	mov    0x8(%eax),%eax
	if (pELFHDR->e_magic != ELF_MAGIC) 
f010326d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103273:	74 17                	je     f010328c <set_environment_entry_point+0x2e>
		panic("Matafa2nash 3ala Keda"); 
f0103275:	83 ec 04             	sub    $0x4,%esp
f0103278:	68 30 5d 10 f0       	push   $0xf0105d30
f010327d:	68 48 02 00 00       	push   $0x248
f0103282:	68 18 5d 10 f0       	push   $0xf0105d18
f0103287:	e8 72 ce ff ff       	call   f01000fe <_panic>
	e->env_tf.tf_eip = (uint32*)pELFHDR->e_entry ;
f010328c:	8b 40 18             	mov    0x18(%eax),%eax
f010328f:	89 42 30             	mov    %eax,0x30(%edx)
}
f0103292:	c9                   	leave  
f0103293:	c3                   	ret    

f0103294 <env_destroy>:



//
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0103294:	55                   	push   %ebp
f0103295:	89 e5                	mov    %esp,%ebp
f0103297:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f010329a:	ff 75 08             	pushl  0x8(%ebp)
f010329d:	e8 b0 fa ff ff       	call   f0102d52 <env_free>

	//cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
f01032a2:	83 c4 10             	add    $0x10,%esp
		run_command_prompt();
f01032a5:	e8 ea d3 ff ff       	call   f0100694 <run_command_prompt>
f01032aa:	eb f9                	jmp    f01032a5 <env_destroy+0x11>

f01032ac <env_run_cmd_prmpt>:
}

void env_run_cmd_prmpt()
{
f01032ac:	55                   	push   %ebp
f01032ad:	89 e5                	mov    %esp,%ebp
f01032af:	53                   	push   %ebx
f01032b0:	83 ec 10             	sub    $0x10,%esp
	struct UserProgramInfo* upi= get_user_program_info_by_env(curenv);	
f01032b3:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f01032b9:	e8 49 ff ff ff       	call   f0103207 <get_user_program_info_by_env>
f01032be:	89 c3                	mov    %eax,%ebx
	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&curenv->env_tf, 0, sizeof(curenv->env_tf));
f01032c0:	83 c4 0c             	add    $0xc,%esp
f01032c3:	6a 44                	push   $0x44
f01032c5:	6a 00                	push   $0x0
f01032c7:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f01032cd:	e8 bd 11 00 00       	call   f010448f <memset>

	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.

	curenv->env_tf.tf_ds = GD_UD | 3;
f01032d2:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01032d7:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	curenv->env_tf.tf_es = GD_UD | 3;
f01032dd:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01032e2:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	curenv->env_tf.tf_ss = GD_UD | 3;
f01032e8:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01032ed:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	curenv->env_tf.tf_esp = (uint32*)USTACKTOP;
f01032f3:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01032f8:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	curenv->env_tf.tf_cs = GD_UT | 3;
f01032ff:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103304:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	set_environment_entry_point(upi);
f010330a:	89 1c 24             	mov    %ebx,(%esp)
f010330d:	e8 4c ff ff ff       	call   f010325e <set_environment_entry_point>
}

static __inline void
lcr3(uint32 val)
{
f0103312:	83 c4 10             	add    $0x10,%esp

	lcr3(K_PHYSICAL_ADDRESS(ptr_page_directory));
f0103315:	a1 84 e9 19 f0       	mov    0xf019e984,%eax
f010331a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010331f:	77 15                	ja     f0103336 <env_run_cmd_prmpt+0x8a>
f0103321:	50                   	push   %eax
f0103322:	68 20 53 10 f0       	push   $0xf0105320
f0103327:	68 73 02 00 00       	push   $0x273
f010332c:	68 18 5d 10 f0       	push   $0xf0105d18
f0103331:	e8 c8 cd ff ff       	call   f01000fe <_panic>
f0103336:	05 00 00 00 10       	add    $0x10000000,%eax

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010333b:	0f 22 d8             	mov    %eax,%cr3

	curenv = NULL;
f010333e:	c7 05 f4 e0 19 f0 00 	movl   $0x0,0xf019e0f4
f0103345:	00 00 00 

	while (1)
		run_command_prompt();
f0103348:	e8 47 d3 ff ff       	call   f0100694 <run_command_prompt>
f010334d:	eb f9                	jmp    f0103348 <env_run_cmd_prmpt+0x9c>

f010334f <env_pop_tf>:
}

//
// Restores the register values in the Trapframe with the 'iret' instruction.
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010334f:	55                   	push   %ebp
f0103350:	89 e5                	mov    %esp,%ebp
f0103352:	83 ec 0c             	sub    $0xc,%esp
f0103355:	8b 45 08             	mov    0x8(%ebp),%eax
	__asm __volatile("movl %0,%%esp\n"
f0103358:	89 c4                	mov    %eax,%esp
f010335a:	61                   	popa   
f010335b:	07                   	pop    %es
f010335c:	1f                   	pop    %ds
f010335d:	83 c4 08             	add    $0x8,%esp
f0103360:	cf                   	iret   
			"\tpopal\n"
			"\tpopl %%es\n"
			"\tpopl %%ds\n"
			"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
			"\tiret"
			: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103361:	68 78 5d 10 f0       	push   $0xf0105d78
f0103366:	68 8a 02 00 00       	push   $0x28a
f010336b:	68 18 5d 10 f0       	push   $0xf0105d18
f0103370:	e8 89 cd ff ff       	call   f01000fe <_panic>
}
f0103375:	00 00                	add    %al,(%eax)
	...

f0103378 <mc146818_read>:


unsigned
mc146818_read(unsigned reg)
{
f0103378:	55                   	push   %ebp
f0103379:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8 data)
{
f010337b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103380:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103383:	ee                   	out    %al,(%dx)
f0103384:	ba 71 00 00 00       	mov    $0x71,%edx
f0103389:	ec                   	in     (%dx),%al
f010338a:	25 ff 00 00 00       	and    $0xff,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f010338f:	5d                   	pop    %ebp
f0103390:	c3                   	ret    

f0103391 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103391:	55                   	push   %ebp
f0103392:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8 data)
{
f0103394:	ba 70 00 00 00       	mov    $0x70,%edx
f0103399:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010339c:	ee                   	out    %al,(%dx)
f010339d:	ba 71 00 00 00       	mov    $0x71,%edx
f01033a2:	8a 45 0c             	mov    0xc(%ebp),%al
f01033a5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01033a6:	5d                   	pop    %ebp
f01033a7:	c3                   	ret    

f01033a8 <putch>:


static void
putch(int ch, int *cnt)
{
f01033a8:	55                   	push   %ebp
f01033a9:	89 e5                	mov    %esp,%ebp
f01033ab:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01033ae:	ff 75 08             	pushl  0x8(%ebp)
f01033b1:	e8 b1 d2 ff ff       	call   f0100667 <cputchar>
	*cnt++;
}
f01033b6:	c9                   	leave  
f01033b7:	c3                   	ret    

f01033b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01033b8:	55                   	push   %ebp
f01033b9:	89 e5                	mov    %esp,%ebp
f01033bb:	83 ec 08             	sub    $0x8,%esp
	int cnt = 0;
f01033be:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01033c5:	ff 75 0c             	pushl  0xc(%ebp)
f01033c8:	ff 75 08             	pushl  0x8(%ebp)
f01033cb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f01033ce:	50                   	push   %eax
f01033cf:	68 a8 33 10 f0       	push   $0xf01033a8
f01033d4:	e8 bb 0a 00 00       	call   f0103e94 <vprintfmt>
	return cnt;
f01033d9:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
f01033dc:	c9                   	leave  
f01033dd:	c3                   	ret    

f01033de <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01033de:	55                   	push   %ebp
f01033df:	89 e5                	mov    %esp,%ebp
f01033e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01033e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01033e7:	50                   	push   %eax
f01033e8:	ff 75 08             	pushl  0x8(%ebp)
f01033eb:	e8 c8 ff ff ff       	call   f01033b8 <vcprintf>
	va_end(ap);

	return cnt;
}
f01033f0:	c9                   	leave  
f01033f1:	c3                   	ret    
	...

f01033f4 <trapname>:
extern  void (*PAGE_FAULT)();
extern  void (*SYSCALL_HANDLER)();

static const char *trapname(int trapno)
{
f01033f4:	55                   	push   %ebp
f01033f5:	89 e5                	mov    %esp,%ebp
f01033f7:	8b 55 08             	mov    0x8(%ebp),%edx
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Falt",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01033fa:	83 fa 13             	cmp    $0x13,%edx
f01033fd:	77 09                	ja     f0103408 <trapname+0x14>
		return excnames[trapno];
f01033ff:	8b 04 95 80 60 10 f0 	mov    0xf0106080(,%edx,4),%eax
f0103406:	eb 0f                	jmp    f0103417 <trapname+0x23>
	if (trapno == T_SYSCALL)
f0103408:	b8 16 5f 10 f0       	mov    $0xf0105f16,%eax
f010340d:	83 fa 30             	cmp    $0x30,%edx
f0103410:	74 05                	je     f0103417 <trapname+0x23>
		return "System call";
	return "(unknown trap)";
f0103412:	b8 ae 5e 10 f0       	mov    $0xf0105eae,%eax
}
f0103417:	5d                   	pop    %ebp
f0103418:	c3                   	ret    

f0103419 <idt_init>:


void
idt_init(void)
{
f0103419:	55                   	push   %ebp
f010341a:	89 e5                	mov    %esp,%ebp
f010341c:	53                   	push   %ebx
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	//initialize idt
	SETGATE(idt[T_PGFLT], 0, GD_KT , &PAGE_FAULT, 0) ;
f010341d:	b8 bc 37 10 f0       	mov    $0xf01037bc,%eax
f0103422:	66 a3 70 e1 19 f0    	mov    %ax,0xf019e170
f0103428:	66 c7 05 72 e1 19 f0 	movw   $0x8,0xf019e172
f010342f:	08 00 
f0103431:	c6 05 74 e1 19 f0 00 	movb   $0x0,0xf019e174
f0103438:	c6 05 75 e1 19 f0 8e 	movb   $0x8e,0xf019e175
f010343f:	c1 e8 10             	shr    $0x10,%eax
f0103442:	66 a3 76 e1 19 f0    	mov    %ax,0xf019e176
	SETGATE(idt[T_SYSCALL], 0, GD_KT , &SYSCALL_HANDLER, 3) ;
f0103448:	b8 c0 37 10 f0       	mov    $0xf01037c0,%eax
f010344d:	66 a3 80 e2 19 f0    	mov    %ax,0xf019e280
f0103453:	66 c7 05 82 e2 19 f0 	movw   $0x8,0xf019e282
f010345a:	08 00 
f010345c:	c6 05 84 e2 19 f0 00 	movb   $0x0,0xf019e284
f0103463:	c6 05 85 e2 19 f0 ee 	movb   $0xee,0xf019e285
f010346a:	c1 e8 10             	shr    $0x10,%eax
f010346d:	66 a3 86 e2 19 f0    	mov    %ax,0xf019e286

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KERNEL_STACK_TOP;
f0103473:	c7 05 04 e9 19 f0 00 	movl   $0xefc00000,0xf019e904
f010347a:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010347d:	66 c7 05 08 e9 19 f0 	movw   $0x10,0xf019e908
f0103484:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32) (&ts),
					sizeof(struct Taskstate), 0);
f0103486:	66 b8 68 00          	mov    $0x68,%ax
f010348a:	bb 00 e9 19 f0       	mov    $0xf019e900,%ebx
f010348f:	89 d9                	mov    %ebx,%ecx
f0103491:	c1 e1 10             	shl    $0x10,%ecx
f0103494:	25 ff ff 00 00       	and    $0xffff,%eax
f0103499:	09 c8                	or     %ecx,%eax
f010349b:	89 d9                	mov    %ebx,%ecx
f010349d:	c1 e9 10             	shr    $0x10,%ecx
f01034a0:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f01034a6:	88 ca                	mov    %cl,%dl
f01034a8:	80 e6 f0             	and    $0xf0,%dh
f01034ab:	80 ce 09             	or     $0x9,%dh
f01034ae:	80 ce 10             	or     $0x10,%dh
f01034b1:	80 e6 9f             	and    $0x9f,%dh
f01034b4:	80 ce 80             	or     $0x80,%dh
f01034b7:	81 e2 ff ff f0 ff    	and    $0xfff0ffff,%edx
f01034bd:	81 e2 ff ff ef ff    	and    $0xffefffff,%edx
f01034c3:	81 e2 ff ff df ff    	and    $0xffdfffff,%edx
f01034c9:	81 ca 00 00 40 00    	or     $0x400000,%edx
f01034cf:	81 e2 ff ff 7f ff    	and    $0xff7fffff,%edx
f01034d5:	81 e3 00 00 00 ff    	and    $0xff000000,%ebx
f01034db:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
f01034e1:	09 da                	or     %ebx,%edx
f01034e3:	a3 08 e7 11 f0       	mov    %eax,0xf011e708
f01034e8:	89 15 0c e7 11 f0    	mov    %edx,0xf011e70c
	gdt[GD_TSS >> 3].sd_s = 0;
f01034ee:	80 25 0d e7 11 f0 ef 	andb   $0xef,0xf011e70d
}

static __inline void
ltr(uint16 sel)
{
f01034f5:	b8 28 00 00 00       	mov    $0x28,%eax
	__asm __volatile("ltr %0" : : "r" (sel));
f01034fa:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f01034fd:	0f 01 1d 00 e8 11 f0 	lidtl  0xf011e800
}
f0103504:	5b                   	pop    %ebx
f0103505:	5d                   	pop    %ebp
f0103506:	c3                   	ret    

f0103507 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0103507:	55                   	push   %ebp
f0103508:	89 e5                	mov    %esp,%ebp
f010350a:	53                   	push   %ebx
f010350b:	83 ec 0c             	sub    $0xc,%esp
f010350e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103511:	53                   	push   %ebx
f0103512:	68 22 5f 10 f0       	push   $0xf0105f22
f0103517:	e8 c2 fe ff ff       	call   f01033de <cprintf>
	print_regs(&tf->tf_regs);
f010351c:	89 1c 24             	mov    %ebx,(%esp)
f010351f:	e8 bd 00 00 00       	call   f01035e1 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103524:	83 c4 08             	add    $0x8,%esp
f0103527:	66 8b 43 20          	mov    0x20(%ebx),%ax
f010352b:	25 ff ff 00 00       	and    $0xffff,%eax
f0103530:	50                   	push   %eax
f0103531:	68 34 5f 10 f0       	push   $0xf0105f34
f0103536:	e8 a3 fe ff ff       	call   f01033de <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010353b:	83 c4 08             	add    $0x8,%esp
f010353e:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0103542:	25 ff ff 00 00       	and    $0xffff,%eax
f0103547:	50                   	push   %eax
f0103548:	68 47 5f 10 f0       	push   $0xf0105f47
f010354d:	e8 8c fe ff ff       	call   f01033de <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103552:	83 c4 04             	add    $0x4,%esp
f0103555:	ff 73 28             	pushl  0x28(%ebx)
f0103558:	e8 97 fe ff ff       	call   f01033f4 <trapname>
f010355d:	83 c4 0c             	add    $0xc,%esp
f0103560:	50                   	push   %eax
f0103561:	ff 73 28             	pushl  0x28(%ebx)
f0103564:	68 5a 5f 10 f0       	push   $0xf0105f5a
f0103569:	e8 70 fe ff ff       	call   f01033de <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f010356e:	83 c4 08             	add    $0x8,%esp
f0103571:	ff 73 2c             	pushl  0x2c(%ebx)
f0103574:	68 6c 5f 10 f0       	push   $0xf0105f6c
f0103579:	e8 60 fe ff ff       	call   f01033de <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010357e:	83 c4 08             	add    $0x8,%esp
f0103581:	ff 73 30             	pushl  0x30(%ebx)
f0103584:	68 7b 5f 10 f0       	push   $0xf0105f7b
f0103589:	e8 50 fe ff ff       	call   f01033de <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010358e:	83 c4 08             	add    $0x8,%esp
f0103591:	66 8b 43 34          	mov    0x34(%ebx),%ax
f0103595:	25 ff ff 00 00       	and    $0xffff,%eax
f010359a:	50                   	push   %eax
f010359b:	68 8a 5f 10 f0       	push   $0xf0105f8a
f01035a0:	e8 39 fe ff ff       	call   f01033de <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01035a5:	83 c4 08             	add    $0x8,%esp
f01035a8:	ff 73 38             	pushl  0x38(%ebx)
f01035ab:	68 9d 5f 10 f0       	push   $0xf0105f9d
f01035b0:	e8 29 fe ff ff       	call   f01033de <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f01035b5:	83 c4 08             	add    $0x8,%esp
f01035b8:	ff 73 3c             	pushl  0x3c(%ebx)
f01035bb:	68 ac 5f 10 f0       	push   $0xf0105fac
f01035c0:	e8 19 fe ff ff       	call   f01033de <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01035c5:	83 c4 08             	add    $0x8,%esp
f01035c8:	66 8b 43 40          	mov    0x40(%ebx),%ax
f01035cc:	25 ff ff 00 00       	and    $0xffff,%eax
f01035d1:	50                   	push   %eax
f01035d2:	68 bb 5f 10 f0       	push   $0xf0105fbb
f01035d7:	e8 02 fe ff ff       	call   f01033de <cprintf>
}
f01035dc:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01035df:	c9                   	leave  
f01035e0:	c3                   	ret    

f01035e1 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f01035e1:	55                   	push   %ebp
f01035e2:	89 e5                	mov    %esp,%ebp
f01035e4:	53                   	push   %ebx
f01035e5:	83 ec 0c             	sub    $0xc,%esp
f01035e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01035eb:	ff 33                	pushl  (%ebx)
f01035ed:	68 ce 5f 10 f0       	push   $0xf0105fce
f01035f2:	e8 e7 fd ff ff       	call   f01033de <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01035f7:	83 c4 08             	add    $0x8,%esp
f01035fa:	ff 73 04             	pushl  0x4(%ebx)
f01035fd:	68 dd 5f 10 f0       	push   $0xf0105fdd
f0103602:	e8 d7 fd ff ff       	call   f01033de <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103607:	83 c4 08             	add    $0x8,%esp
f010360a:	ff 73 08             	pushl  0x8(%ebx)
f010360d:	68 ec 5f 10 f0       	push   $0xf0105fec
f0103612:	e8 c7 fd ff ff       	call   f01033de <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103617:	83 c4 08             	add    $0x8,%esp
f010361a:	ff 73 0c             	pushl  0xc(%ebx)
f010361d:	68 fb 5f 10 f0       	push   $0xf0105ffb
f0103622:	e8 b7 fd ff ff       	call   f01033de <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103627:	83 c4 08             	add    $0x8,%esp
f010362a:	ff 73 10             	pushl  0x10(%ebx)
f010362d:	68 0a 60 10 f0       	push   $0xf010600a
f0103632:	e8 a7 fd ff ff       	call   f01033de <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103637:	83 c4 08             	add    $0x8,%esp
f010363a:	ff 73 14             	pushl  0x14(%ebx)
f010363d:	68 19 60 10 f0       	push   $0xf0106019
f0103642:	e8 97 fd ff ff       	call   f01033de <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103647:	83 c4 08             	add    $0x8,%esp
f010364a:	ff 73 18             	pushl  0x18(%ebx)
f010364d:	68 28 60 10 f0       	push   $0xf0106028
f0103652:	e8 87 fd ff ff       	call   f01033de <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103657:	83 c4 08             	add    $0x8,%esp
f010365a:	ff 73 1c             	pushl  0x1c(%ebx)
f010365d:	68 37 60 10 f0       	push   $0xf0106037
f0103662:	e8 77 fd ff ff       	call   f01033de <cprintf>
}
f0103667:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010366a:	c9                   	leave  
f010366b:	c3                   	ret    

f010366c <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f010366c:	55                   	push   %ebp
f010366d:	89 e5                	mov    %esp,%ebp
f010366f:	53                   	push   %ebx
f0103670:	83 ec 04             	sub    $0x4,%esp
f0103673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if(tf->tf_trapno == T_PGFLT)
f0103676:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010367a:	75 0e                	jne    f010368a <trap_dispatch+0x1e>
	{
		page_fault_handler(tf);
f010367c:	83 ec 0c             	sub    $0xc,%esp
f010367f:	53                   	push   %ebx
f0103680:	e8 f9 00 00 00       	call   f010377e <page_fault_handler>
f0103685:	83 c4 10             	add    $0x10,%esp
f0103688:	eb 5f                	jmp    f01036e9 <trap_dispatch+0x7d>
	}
	else if (tf->tf_trapno == T_SYSCALL)
f010368a:	83 7b 28 30          	cmpl   $0x30,0x28(%ebx)
f010368e:	75 21                	jne    f01036b1 <trap_dispatch+0x45>
	{
		uint32 ret = syscall(tf->tf_regs.reg_eax
f0103690:	83 ec 08             	sub    $0x8,%esp
f0103693:	ff 73 04             	pushl  0x4(%ebx)
f0103696:	ff 33                	pushl  (%ebx)
f0103698:	ff 73 10             	pushl  0x10(%ebx)
f010369b:	ff 73 18             	pushl  0x18(%ebx)
f010369e:	ff 73 14             	pushl  0x14(%ebx)
f01036a1:	ff 73 1c             	pushl  0x1c(%ebx)
f01036a4:	e8 63 03 00 00       	call   f0103a0c <syscall>
			,tf->tf_regs.reg_edx
			,tf->tf_regs.reg_ecx
			,tf->tf_regs.reg_ebx
			,tf->tf_regs.reg_edi
					,tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f01036a9:	89 43 1c             	mov    %eax,0x1c(%ebx)
f01036ac:	83 c4 20             	add    $0x20,%esp
f01036af:	eb 38                	jmp    f01036e9 <trap_dispatch+0x7d>
	}
	else
	{
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f01036b1:	83 ec 0c             	sub    $0xc,%esp
f01036b4:	53                   	push   %ebx
f01036b5:	e8 4d fe ff ff       	call   f0103507 <print_trapframe>
		if (tf->tf_cs == GD_KT)
f01036ba:	83 c4 10             	add    $0x10,%esp
f01036bd:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01036c2:	75 17                	jne    f01036db <trap_dispatch+0x6f>
			panic("unhandled trap in kernel");
f01036c4:	83 ec 04             	sub    $0x4,%esp
f01036c7:	68 46 60 10 f0       	push   $0xf0106046
f01036cc:	68 8a 00 00 00       	push   $0x8a
f01036d1:	68 5f 60 10 f0       	push   $0xf010605f
f01036d6:	e8 23 ca ff ff       	call   f01000fe <_panic>
		else {
			env_destroy(curenv);
f01036db:	83 ec 0c             	sub    $0xc,%esp
f01036de:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f01036e4:	e8 ab fb ff ff       	call   f0103294 <env_destroy>
			return;	
		}
	}
	return;
}
f01036e9:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01036ec:	c9                   	leave  
f01036ed:	c3                   	ret    

f01036ee <trap>:

void
trap(struct Trapframe *tf)
{
f01036ee:	55                   	push   %ebp
f01036ef:	89 e5                	mov    %esp,%ebp
f01036f1:	83 ec 08             	sub    $0x8,%esp
f01036f4:	8b 55 08             	mov    0x8(%ebp),%edx
	//cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
f01036f7:	66 8b 42 34          	mov    0x34(%edx),%ax
f01036fb:	83 e0 03             	and    $0x3,%eax
f01036fe:	83 f8 03             	cmp    $0x3,%eax
f0103701:	75 34                	jne    f0103737 <trap+0x49>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103703:	83 3d f4 e0 19 f0 00 	cmpl   $0x0,0xf019e0f4
f010370a:	75 11                	jne    f010371d <trap+0x2f>
f010370c:	68 6b 60 10 f0       	push   $0xf010606b
f0103711:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0103716:	68 9d 00 00 00       	push   $0x9d
f010371b:	eb 49                	jmp    f0103766 <trap+0x78>
		curenv->env_tf = *tf;
f010371d:	83 ec 04             	sub    $0x4,%esp
f0103720:	6a 44                	push   $0x44
f0103722:	52                   	push   %edx
f0103723:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f0103729:	e8 7e 0d 00 00       	call   f01044ac <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010372e:	8b 15 f4 e0 19 f0    	mov    0xf019e0f4,%edx
f0103734:	83 c4 10             	add    $0x10,%esp
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f0103737:	83 ec 0c             	sub    $0xc,%esp
f010373a:	52                   	push   %edx
f010373b:	e8 2c ff ff ff       	call   f010366c <trap_dispatch>

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f0103740:	83 c4 10             	add    $0x10,%esp
f0103743:	83 3d f4 e0 19 f0 00 	cmpl   $0x0,0xf019e0f4
f010374a:	74 0b                	je     f0103757 <trap+0x69>
f010374c:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103751:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103755:	74 19                	je     f0103770 <trap+0x82>
f0103757:	68 e0 60 10 f0       	push   $0xf01060e0
f010375c:	68 c2 5a 10 f0       	push   $0xf0105ac2
f0103761:	68 a7 00 00 00       	push   $0xa7
f0103766:	68 5f 60 10 f0       	push   $0xf010605f
f010376b:	e8 8e c9 ff ff       	call   f01000fe <_panic>
        env_run(curenv);
f0103770:	83 ec 0c             	sub    $0xc,%esp
f0103773:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f0103779:	e8 a2 f5 ff ff       	call   f0102d20 <env_run>

f010377e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010377e:	55                   	push   %ebp
f010377f:	89 e5                	mov    %esp,%ebp
f0103781:	53                   	push   %ebx
f0103782:	83 ec 04             	sub    $0x4,%esp
f0103785:	8b 5d 08             	mov    0x8(%ebp),%ebx
static __inline uint32
rcr2(void)
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103788:	0f 20 d0             	mov    %cr2,%eax
	uint32 fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack, or the exception stack overflows,
	// then destroy the environment that caused the fault.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010378b:	ff 73 30             	pushl  0x30(%ebx)
f010378e:	50                   	push   %eax
f010378f:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103794:	ff 70 4c             	pushl  0x4c(%eax)
f0103797:	68 20 61 10 f0       	push   $0xf0106120
f010379c:	e8 3d fc ff ff       	call   f01033de <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01037a1:	89 1c 24             	mov    %ebx,(%esp)
f01037a4:	e8 5e fd ff ff       	call   f0103507 <print_trapframe>
	env_destroy(curenv);
f01037a9:	83 c4 04             	add    $0x4,%esp
f01037ac:	ff 35 f4 e0 19 f0    	pushl  0xf019e0f4
f01037b2:	e8 dd fa ff ff       	call   f0103294 <env_destroy>
	
}
f01037b7:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01037ba:	c9                   	leave  
f01037bb:	c3                   	ret    

f01037bc <PAGE_FAULT>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER(PAGE_FAULT, T_PGFLT)		
f01037bc:	6a 0e                	push   $0xe
f01037be:	eb 06                	jmp    f01037c6 <_alltraps>

f01037c0 <SYSCALL_HANDLER>:

TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL)
f01037c0:	6a 00                	push   $0x0
f01037c2:	6a 30                	push   $0x30
f01037c4:	eb 00                	jmp    f01037c6 <_alltraps>

f01037c6 <_alltraps>:
	

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:

push %ds 
f01037c6:	1e                   	push   %ds
push %es 
f01037c7:	06                   	push   %es
pushal 	
f01037c8:	60                   	pusha  

mov $(GD_KD), %ax 
f01037c9:	66 b8 10 00          	mov    $0x10,%ax
mov %ax,%ds
f01037cd:	8e d8                	mov    %eax,%ds
mov %ax,%es
f01037cf:	8e c0                	mov    %eax,%es

push %esp
f01037d1:	54                   	push   %esp

call trap
f01037d2:	e8 17 ff ff ff       	call   f01036ee <trap>

pop %ecx /* poping the pointer to the tf from the stack so that the stack top is at the values of the registers posuhed by pusha*/
f01037d7:	59                   	pop    %ecx
popal 	
f01037d8:	61                   	popa   
pop %es 
f01037d9:	07                   	pop    %es
pop %ds    
f01037da:	1f                   	pop    %ds

/*skipping the trap_no and the error code so that the stack top is at the old eip value*/
add $(8),%esp
f01037db:	83 c4 08             	add    $0x8,%esp

iret
f01037de:	cf                   	iret   
	...

f01037e0 <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void sys_cputs(const char *s, uint32 len)
{
f01037e0:	55                   	push   %ebp
f01037e1:	89 e5                	mov    %esp,%ebp
f01037e3:	83 ec 0c             	sub    $0xc,%esp
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01037e6:	ff 75 08             	pushl  0x8(%ebp)
f01037e9:	ff 75 0c             	pushl  0xc(%ebp)
f01037ec:	68 43 61 10 f0       	push   $0xf0106143
f01037f1:	e8 e8 fb ff ff       	call   f01033de <cprintf>
}
f01037f6:	c9                   	leave  
f01037f7:	c3                   	ret    

f01037f8 <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f01037f8:	55                   	push   %ebp
f01037f9:	89 e5                	mov    %esp,%ebp
f01037fb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f01037fe:	e8 cf cd ff ff       	call   f01005d2 <cons_getc>
f0103803:	85 c0                	test   %eax,%eax
f0103805:	74 f7                	je     f01037fe <sys_cgetc+0x6>
		/* do nothing */;

	return c;
}
f0103807:	c9                   	leave  
f0103808:	c3                   	ret    

f0103809 <sys_getenvid>:

// Returns the current environment's envid.
static int32 sys_getenvid(void)
{
f0103809:	55                   	push   %ebp
f010380a:	89 e5                	mov    %esp,%ebp
	return curenv->env_id;
f010380c:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103811:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f0103814:	5d                   	pop    %ebp
f0103815:	c3                   	ret    

f0103816 <sys_env_destroy>:

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int sys_env_destroy(int32  envid)
{
f0103816:	55                   	push   %ebp
f0103817:	89 e5                	mov    %esp,%ebp
f0103819:	83 ec 0c             	sub    $0xc,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010381c:	6a 01                	push   $0x1
f010381e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0103821:	50                   	push   %eax
f0103822:	ff 75 08             	pushl  0x8(%ebp)
f0103825:	e8 32 e9 ff ff       	call   f010215c <envid2env>
f010382a:	83 c4 10             	add    $0x10,%esp
f010382d:	89 c2                	mov    %eax,%edx
f010382f:	85 c0                	test   %eax,%eax
f0103831:	78 43                	js     f0103876 <sys_env_destroy+0x60>
		return r;
	if (e == curenv)
f0103833:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103836:	3b 05 f4 e0 19 f0    	cmp    0xf019e0f4,%eax
f010383c:	75 0d                	jne    f010384b <sys_env_destroy+0x35>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010383e:	83 ec 08             	sub    $0x8,%esp
f0103841:	ff 70 4c             	pushl  0x4c(%eax)
f0103844:	68 48 61 10 f0       	push   $0xf0106148
f0103849:	eb 16                	jmp    f0103861 <sys_env_destroy+0x4b>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010384b:	83 ec 04             	sub    $0x4,%esp
f010384e:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103851:	ff 70 4c             	pushl  0x4c(%eax)
f0103854:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103859:	ff 70 4c             	pushl  0x4c(%eax)
f010385c:	68 63 61 10 f0       	push   $0xf0106163
f0103861:	e8 78 fb ff ff       	call   f01033de <cprintf>
f0103866:	83 c4 04             	add    $0x4,%esp
	env_destroy(e);
f0103869:	ff 75 fc             	pushl  0xfffffffc(%ebp)
f010386c:	e8 23 fa ff ff       	call   f0103294 <env_destroy>
	return 0;
f0103871:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103876:	89 d0                	mov    %edx,%eax
f0103878:	c9                   	leave  
f0103879:	c3                   	ret    

f010387a <sys_env_sleep>:

static void sys_env_sleep()
{
f010387a:	55                   	push   %ebp
f010387b:	89 e5                	mov    %esp,%ebp
f010387d:	83 ec 08             	sub    $0x8,%esp
	env_run_cmd_prmpt();
f0103880:	e8 27 fa ff ff       	call   f01032ac <env_run_cmd_prmpt>
}
f0103885:	c9                   	leave  
f0103886:	c3                   	ret    

f0103887 <sys_allocate_page>:
	

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.
//
// Return 0 on success, < 0 on error.  Errors are:
//	E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_allocate_page(void *va, int perm)
{
f0103887:	55                   	push   %ebp
f0103888:	89 e5                	mov    %esp,%ebp
f010388a:	57                   	push   %edi
f010388b:	56                   	push   %esi
f010388c:	53                   	push   %ebx
f010388d:	83 ec 18             	sub    $0x18,%esp
f0103890:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103893:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	int r;
	struct Env *e = curenv;
f0103896:	8b 35 f4 e0 19 f0    	mov    0xf019e0f4,%esi

	//if ((r = envid2env(envid, &e, 1)) < 0)
		//return r;
	
	struct Frame_Info *ptr_frame_info ;
	r = allocate_frame(&ptr_frame_info) ;
f010389c:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010389f:	50                   	push   %eax
f01038a0:	e8 69 ed ff ff       	call   f010260e <allocate_frame>
	if (r == E_NO_MEM)
f01038a5:	83 c4 10             	add    $0x10,%esp
f01038a8:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f01038ad:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01038b0:	0f 84 ba 00 00 00    	je     f0103970 <sys_allocate_page+0xe9>
		return r ;
	
	//check virtual address to be paged_aligned and < USER_TOP
	if ((uint32)va >= USER_TOP || (uint32)va % PAGE_SIZE != 0)
f01038b6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01038bc:	77 08                	ja     f01038c6 <sys_allocate_page+0x3f>
f01038be:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01038c4:	74 0a                	je     f01038d0 <sys_allocate_page+0x49>
		return E_INVAL;
f01038c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01038cb:	e9 a0 00 00 00       	jmp    f0103970 <sys_allocate_page+0xe9>
	
	//check permissions to be appropriatess
	if ((perm & (~PERM_AVAILABLE & ~PERM_WRITEABLE)) != (PERM_USER))
f01038d0:	89 f8                	mov    %edi,%eax
f01038d2:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01038d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01038dc:	83 f8 04             	cmp    $0x4,%eax
f01038df:	0f 85 8b 00 00 00    	jne    f0103970 <sys_allocate_page+0xe9>
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f01038e5:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f01038e8:	2b 15 7c e9 19 f0    	sub    0xf019e97c,%edx
f01038ee:	c1 fa 02             	sar    $0x2,%edx
f01038f1:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01038f4:	89 c1                	mov    %eax,%ecx
f01038f6:	c1 e1 04             	shl    $0x4,%ecx
f01038f9:	01 c8                	add    %ecx,%eax
f01038fb:	89 c1                	mov    %eax,%ecx
f01038fd:	c1 e1 08             	shl    $0x8,%ecx
f0103900:	01 c8                	add    %ecx,%eax
f0103902:	89 c1                	mov    %eax,%ecx
f0103904:	c1 e1 10             	shl    $0x10,%ecx
f0103907:	01 c8                	add    %ecx,%eax
f0103909:	8d 04 42             	lea    (%edx,%eax,2),%eax
		return E_INVAL;
	
			
	uint32 physical_address = to_physical_address(ptr_frame_info) ;
	
	memset(K_VIRTUAL_ADDRESS(physical_address), 0, PAGE_SIZE);
f010390c:	89 c2                	mov    %eax,%edx
f010390e:	c1 e2 0c             	shl    $0xc,%edx
f0103911:	89 d0                	mov    %edx,%eax
f0103913:	c1 e8 0c             	shr    $0xc,%eax
f0103916:	3b 05 68 e9 19 f0    	cmp    0xf019e968,%eax
f010391c:	72 12                	jb     f0103930 <sys_allocate_page+0xa9>
f010391e:	52                   	push   %edx
f010391f:	68 40 56 10 f0       	push   $0xf0105640
f0103924:	6a 7a                	push   $0x7a
f0103926:	68 7b 61 10 f0       	push   $0xf010617b
f010392b:	e8 ce c7 ff ff       	call   f01000fe <_panic>
f0103930:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0103936:	83 ec 04             	sub    $0x4,%esp
f0103939:	68 00 10 00 00       	push   $0x1000
f010393e:	6a 00                	push   $0x0
f0103940:	50                   	push   %eax
f0103941:	e8 49 0b 00 00       	call   f010448f <memset>
		
	r = map_frame(e->env_pgdir, ptr_frame_info, va, perm) ;
f0103946:	57                   	push   %edi
f0103947:	53                   	push   %ebx
f0103948:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f010394b:	ff 76 5c             	pushl  0x5c(%esi)
f010394e:	e8 5c ee ff ff       	call   f01027af <map_frame>
	if (r == E_NO_MEM)
f0103953:	83 c4 20             	add    $0x20,%esp
	{
		decrement_references(ptr_frame_info);
		return r;
	}
	return 0 ;
f0103956:	ba 00 00 00 00       	mov    $0x0,%edx
f010395b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010395e:	75 10                	jne    f0103970 <sys_allocate_page+0xe9>
f0103960:	83 ec 0c             	sub    $0xc,%esp
f0103963:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0103966:	e8 0e ed ff ff       	call   f0102679 <decrement_references>
f010396b:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
}
f0103970:	89 d0                	mov    %edx,%eax
f0103972:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103975:	5b                   	pop    %ebx
f0103976:	5e                   	pop    %esi
f0103977:	5f                   	pop    %edi
f0103978:	5d                   	pop    %ebp
f0103979:	c3                   	ret    

f010397a <sys_get_page>:

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that function does nothing
//
// Return 0 on success, < 0 on error.  Errors are:
//	E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_get_page(void *va, int perm)
{
f010397a:	55                   	push   %ebp
f010397b:	89 e5                	mov    %esp,%ebp
f010397d:	83 ec 0c             	sub    $0xc,%esp
	return get_page(curenv->env_pgdir, va, perm) ;
f0103980:	ff 75 0c             	pushl  0xc(%ebp)
f0103983:	ff 75 08             	pushl  0x8(%ebp)
f0103986:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f010398b:	ff 70 5c             	pushl  0x5c(%eax)
f010398e:	e8 9a ef ff ff       	call   f010292d <get_page>
}
f0103993:	c9                   	leave  
f0103994:	c3                   	ret    

f0103995 <sys_map_frame>:

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_map_frame(int32 srcenvid, void *srcva, int32 dstenvid, void *dstva, int perm)
{
f0103995:	55                   	push   %ebp
f0103996:	89 e5                	mov    %esp,%ebp
f0103998:	83 ec 0c             	sub    $0xc,%esp
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	panic("sys_map_frame not implemented");
f010399b:	68 8a 61 10 f0       	push   $0xf010618a
f01039a0:	68 b1 00 00 00       	push   $0xb1
f01039a5:	68 7b 61 10 f0       	push   $0xf010617b
f01039aa:	e8 4f c7 ff ff       	call   f01000fe <_panic>

f01039af <sys_unmap_frame>:
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int sys_unmap_frame(int32 envid, void *va)
{
f01039af:	55                   	push   %ebp
f01039b0:	89 e5                	mov    %esp,%ebp
f01039b2:	83 ec 0c             	sub    $0xc,%esp
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	panic("sys_page_unmap not implemented");
f01039b5:	68 c0 61 10 f0       	push   $0xf01061c0
f01039ba:	68 c0 00 00 00       	push   $0xc0
f01039bf:	68 7b 61 10 f0       	push   $0xf010617b
f01039c4:	e8 35 c7 ff ff       	call   f01000fe <_panic>

f01039c9 <sys_calculate_required_frames>:
}

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
f01039c9:	55                   	push   %ebp
f01039ca:	89 e5                	mov    %esp,%ebp
f01039cc:	83 ec 0c             	sub    $0xc,%esp
	return calculate_required_frames(curenv->env_pgdir, start_virtual_address, size); 
f01039cf:	ff 75 0c             	pushl  0xc(%ebp)
f01039d2:	ff 75 08             	pushl  0x8(%ebp)
f01039d5:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f01039da:	ff 70 5c             	pushl  0x5c(%eax)
f01039dd:	e8 65 ef ff ff       	call   f0102947 <calculate_required_frames>
}
f01039e2:	c9                   	leave  
f01039e3:	c3                   	ret    

f01039e4 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
f01039e4:	55                   	push   %ebp
f01039e5:	89 e5                	mov    %esp,%ebp
f01039e7:	83 ec 08             	sub    $0x8,%esp
	return calculate_free_frames();
f01039ea:	e8 72 ef ff ff       	call   f0102961 <calculate_free_frames>
}
f01039ef:	c9                   	leave  
f01039f0:	c3                   	ret    

f01039f1 <sys_freeMem>:
void sys_freeMem(void* start_virtual_address, uint32 size)
{
f01039f1:	55                   	push   %ebp
f01039f2:	89 e5                	mov    %esp,%ebp
f01039f4:	83 ec 0c             	sub    $0xc,%esp
	freeMem((uint32*)curenv->env_pgdir, (void*)start_virtual_address, size);
f01039f7:	ff 75 0c             	pushl  0xc(%ebp)
f01039fa:	ff 75 08             	pushl  0x8(%ebp)
f01039fd:	a1 f4 e0 19 f0       	mov    0xf019e0f4,%eax
f0103a02:	ff 70 5c             	pushl  0x5c(%eax)
f0103a05:	e8 72 ef ff ff       	call   f010297c <freeMem>
	return;
}
f0103a0a:	c9                   	leave  
f0103a0b:	c3                   	ret    

f0103a0c <syscall>:
// Dispatches to the correct kernel function, passing the arguments.
uint32
syscall(uint32 syscallno, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
f0103a0c:	55                   	push   %ebp
f0103a0d:	89 e5                	mov    %esp,%ebp
f0103a0f:	53                   	push   %ebx
f0103a10:	83 ec 04             	sub    $0x4,%esp
f0103a13:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno)
	{
		case SYS_cputs:
			sys_cputs((const char*)a1,a2);
			return 0;
			break;
		case SYS_cgetc:
			return sys_cgetc();
			break;
		case SYS_getenvid:
			return sys_getenvid();
			break;
		case SYS_env_destroy:
			return sys_env_destroy(a1);
			break;
		case SYS_env_sleep:
			sys_env_sleep();
			return 0;
			break;
		case SYS_calc_req_frames:
			return sys_calculate_required_frames(a1, a2);			
			break;
		case SYS_calc_free_frames:
			return sys_calculate_free_frames();			
			break;
		case SYS_freeMem:
			sys_freeMem((void*)a1, a2);
			return 0;			
			break;
		//======================
		
		case SYS_allocate_page:
			sys_allocate_page((void*)a1, a2);
			return 0;
			break;
		case SYS_get_page:
			sys_get_page((void*)a1, a2);
			return 0;
		break;case SYS_map_frame:
			sys_map_frame(a1, (void*)a2, a3, (void*)a4, a5);
			return 0;
			break;
		case SYS_unmap_frame:
			sys_unmap_frame(a1, (void*)a2);
			return 0;
			break;
		case NSYSCALLS:	
			return 	-E_INVAL;
			break;
	}
	//panic("syscall not implemented");
	return -E_INVAL;
f0103a1c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a21:	83 fa 0c             	cmp    $0xc,%edx
f0103a24:	0f 87 95 00 00 00    	ja     f0103abf <syscall+0xb3>
f0103a2a:	ff 24 95 e0 61 10 f0 	jmp    *0xf01061e0(,%edx,4)
f0103a31:	83 ec 08             	sub    $0x8,%esp
f0103a34:	51                   	push   %ecx
f0103a35:	53                   	push   %ebx
f0103a36:	e8 a5 fd ff ff       	call   f01037e0 <sys_cputs>
f0103a3b:	eb 76                	jmp    f0103ab3 <syscall+0xa7>
f0103a3d:	e8 b6 fd ff ff       	call   f01037f8 <sys_cgetc>
f0103a42:	eb 7b                	jmp    f0103abf <syscall+0xb3>
f0103a44:	e8 c0 fd ff ff       	call   f0103809 <sys_getenvid>
f0103a49:	eb 74                	jmp    f0103abf <syscall+0xb3>
f0103a4b:	83 ec 0c             	sub    $0xc,%esp
f0103a4e:	53                   	push   %ebx
f0103a4f:	e8 c2 fd ff ff       	call   f0103816 <sys_env_destroy>
f0103a54:	eb 69                	jmp    f0103abf <syscall+0xb3>
f0103a56:	e8 1f fe ff ff       	call   f010387a <sys_env_sleep>
f0103a5b:	eb 56                	jmp    f0103ab3 <syscall+0xa7>
f0103a5d:	83 ec 08             	sub    $0x8,%esp
f0103a60:	51                   	push   %ecx
f0103a61:	53                   	push   %ebx
f0103a62:	e8 62 ff ff ff       	call   f01039c9 <sys_calculate_required_frames>
f0103a67:	eb 56                	jmp    f0103abf <syscall+0xb3>
f0103a69:	e8 76 ff ff ff       	call   f01039e4 <sys_calculate_free_frames>
f0103a6e:	eb 4f                	jmp    f0103abf <syscall+0xb3>
f0103a70:	83 ec 08             	sub    $0x8,%esp
f0103a73:	51                   	push   %ecx
f0103a74:	53                   	push   %ebx
f0103a75:	e8 77 ff ff ff       	call   f01039f1 <sys_freeMem>
f0103a7a:	eb 37                	jmp    f0103ab3 <syscall+0xa7>
f0103a7c:	83 ec 08             	sub    $0x8,%esp
f0103a7f:	51                   	push   %ecx
f0103a80:	53                   	push   %ebx
f0103a81:	e8 01 fe ff ff       	call   f0103887 <sys_allocate_page>
f0103a86:	eb 2b                	jmp    f0103ab3 <syscall+0xa7>
f0103a88:	83 ec 08             	sub    $0x8,%esp
f0103a8b:	51                   	push   %ecx
f0103a8c:	53                   	push   %ebx
f0103a8d:	e8 e8 fe ff ff       	call   f010397a <sys_get_page>
f0103a92:	eb 1f                	jmp    f0103ab3 <syscall+0xa7>
f0103a94:	83 ec 0c             	sub    $0xc,%esp
f0103a97:	ff 75 1c             	pushl  0x1c(%ebp)
f0103a9a:	ff 75 18             	pushl  0x18(%ebp)
f0103a9d:	ff 75 14             	pushl  0x14(%ebp)
f0103aa0:	51                   	push   %ecx
f0103aa1:	53                   	push   %ebx
f0103aa2:	e8 ee fe ff ff       	call   f0103995 <sys_map_frame>
f0103aa7:	eb 0a                	jmp    f0103ab3 <syscall+0xa7>
f0103aa9:	83 ec 08             	sub    $0x8,%esp
f0103aac:	51                   	push   %ecx
f0103aad:	53                   	push   %ebx
f0103aae:	e8 fc fe ff ff       	call   f01039af <sys_unmap_frame>
f0103ab3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ab8:	eb 05                	jmp    f0103abf <syscall+0xb3>
f0103aba:	b8 03 00 00 00       	mov    $0x3,%eax
}
f0103abf:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0103ac2:	c9                   	leave  
f0103ac3:	c3                   	ret    

f0103ac4 <stab_binsearch>:
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
f0103ac4:	55                   	push   %ebp
f0103ac5:	89 e5                	mov    %esp,%ebp
f0103ac7:	57                   	push   %edi
f0103ac8:	56                   	push   %esi
f0103ac9:	53                   	push   %ebx
f0103aca:	83 ec 0c             	sub    $0xc,%esp
f0103acd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad3:	8b 08                	mov    (%eax),%ecx
f0103ad5:	8b 55 10             	mov    0x10(%ebp),%edx
f0103ad8:	8b 12                	mov    (%edx),%edx
f0103ada:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0103add:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	
	while (l <= r) {
f0103ae4:	39 d1                	cmp    %edx,%ecx
f0103ae6:	0f 8f 8c 00 00 00    	jg     f0103b78 <stab_binsearch+0xb4>
		int true_m = (l + r) / 2, m = true_m;
f0103aec:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
f0103aef:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax
f0103af2:	89 c2                	mov    %eax,%edx
f0103af4:	c1 ea 1f             	shr    $0x1f,%edx
f0103af7:	01 d0                	add    %edx,%eax
f0103af9:	89 c3                	mov    %eax,%ebx
f0103afb:	d1 fb                	sar    %ebx
f0103afd:	89 da                	mov    %ebx,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103aff:	39 cb                	cmp    %ecx,%ebx
f0103b01:	7c 43                	jl     f0103b46 <stab_binsearch+0x82>
f0103b03:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103b06:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f0103b0a:	25 ff 00 00 00       	and    $0xff,%eax
f0103b0f:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103b12:	74 16                	je     f0103b2a <stab_binsearch+0x66>
			m--;
f0103b14:	4a                   	dec    %edx
f0103b15:	39 ca                	cmp    %ecx,%edx
f0103b17:	7c 2d                	jl     f0103b46 <stab_binsearch+0x82>
f0103b19:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103b1c:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f0103b20:	25 ff 00 00 00       	and    $0xff,%eax
f0103b25:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103b28:	75 ea                	jne    f0103b14 <stab_binsearch+0x50>
		if (m < l) {	// no match in [l, m]
f0103b2a:	39 ca                	cmp    %ecx,%edx
f0103b2c:	7c 18                	jl     f0103b46 <stab_binsearch+0x82>
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103b2e:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
		if (stabs[m].n_value < addr) {
f0103b35:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0103b38:	8b 45 18             	mov    0x18(%ebp),%eax
f0103b3b:	39 44 b7 08          	cmp    %eax,0x8(%edi,%esi,4)
f0103b3f:	73 0a                	jae    f0103b4b <stab_binsearch+0x87>
			*region_left = m;
f0103b41:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b44:	89 16                	mov    %edx,(%esi)
			l = true_m + 1;
f0103b46:	8d 4b 01             	lea    0x1(%ebx),%ecx
f0103b49:	eb 24                	jmp    f0103b6f <stab_binsearch+0xab>
		} else if (stabs[m].n_value > addr) {
f0103b4b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103b4e:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0103b51:	39 5c 87 08          	cmp    %ebx,0x8(%edi,%eax,4)
f0103b55:	76 0d                	jbe    f0103b64 <stab_binsearch+0xa0>
			*region_right = m - 1;
f0103b57:	8d 42 ff             	lea    0xffffffff(%edx),%eax
f0103b5a:	8b 75 10             	mov    0x10(%ebp),%esi
f0103b5d:	89 06                	mov    %eax,(%esi)
			r = m - 1;
f0103b5f:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0103b62:	eb 0b                	jmp    f0103b6f <stab_binsearch+0xab>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103b64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b67:	89 10                	mov    %edx,(%eax)
			l = m;
f0103b69:	89 d1                	mov    %edx,%ecx
			addr++;
f0103b6b:	83 45 18 04          	addl   $0x4,0x18(%ebp)
f0103b6f:	3b 4d e8             	cmp    0xffffffe8(%ebp),%ecx
f0103b72:	0f 8e 74 ff ff ff    	jle    f0103aec <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f0103b78:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103b7c:	75 0d                	jne    f0103b8b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b81:	8b 02                	mov    (%edx),%eax
f0103b83:	48                   	dec    %eax
f0103b84:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103b87:	89 03                	mov    %eax,(%ebx)
f0103b89:	eb 3b                	jmp    f0103bc6 <stab_binsearch+0x102>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103b8b:	8b 75 10             	mov    0x10(%ebp),%esi
f0103b8e:	8b 0e                	mov    (%esi),%ecx
f0103b90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b93:	3b 08                	cmp    (%eax),%ecx
f0103b95:	7e 2a                	jle    f0103bc1 <stab_binsearch+0xfd>
f0103b97:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0103b9a:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f0103b9e:	25 ff 00 00 00       	and    $0xff,%eax
f0103ba3:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103ba6:	74 19                	je     f0103bc1 <stab_binsearch+0xfd>
f0103ba8:	49                   	dec    %ecx
f0103ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bac:	3b 0a                	cmp    (%edx),%ecx
f0103bae:	7e 11                	jle    f0103bc1 <stab_binsearch+0xfd>
f0103bb0:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0103bb3:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f0103bb7:	25 ff 00 00 00       	and    $0xff,%eax
f0103bbc:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103bbf:	75 e7                	jne    f0103ba8 <stab_binsearch+0xe4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0103bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bc4:	89 0b                	mov    %ecx,(%ebx)
	}
}
f0103bc6:	83 c4 0c             	add    $0xc,%esp
f0103bc9:	5b                   	pop    %ebx
f0103bca:	5e                   	pop    %esi
f0103bcb:	5f                   	pop    %edi
f0103bcc:	5d                   	pop    %ebp
f0103bcd:	c3                   	ret    

f0103bce <debuginfo_eip>:


// debuginfo_eip(addr, info)
//
//	Fill in the 'info' structure with information about the specified
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uint32*  addr, struct Eipdebuginfo *info)
{
f0103bce:	55                   	push   %ebp
f0103bcf:	89 e5                	mov    %esp,%ebp
f0103bd1:	57                   	push   %edi
f0103bd2:	56                   	push   %esi
f0103bd3:	53                   	push   %ebx
f0103bd4:	83 ec 1c             	sub    $0x1c,%esp
f0103bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103bda:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103bdd:	c7 07 14 62 10 f0    	movl   $0xf0106214,(%edi)
	info->eip_line = 0;
f0103be3:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0103bea:	c7 47 08 14 62 10 f0 	movl   $0xf0106214,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103bf1:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103bf8:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0103bfb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if ((uint32)addr >= USER_LIMIT) {
f0103c02:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103c08:	76 1a                	jbe    f0103c24 <debuginfo_eip+0x56>
		stabs = __STAB_BEGIN__;
f0103c0a:	be 48 64 10 f0       	mov    $0xf0106448,%esi
		stab_end = __STAB_END__;
f0103c0f:	b8 00 1b 11 f0       	mov    $0xf0111b00,%eax
		stabstr = __STABSTR_BEGIN__;
f0103c14:	c7 45 e0 01 1b 11 f0 	movl   $0xf0111b01,0xffffffe0(%ebp)
		stabstr_end = __STABSTR_END__;
f0103c1b:	c7 45 dc 98 5b 11 f0 	movl   $0xf0115b98,0xffffffdc(%ebp)
f0103c22:	eb 1d                	jmp    f0103c41 <debuginfo_eip+0x73>
	} else {
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0103c24:	8b 35 00 00 20 00    	mov    0x200000,%esi
		stab_end = usd->stab_end;
f0103c2a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103c2f:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103c35:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c38:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103c3e:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103c41:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f0103c44:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
f0103c47:	76 09                	jbe    f0103c52 <debuginfo_eip+0x84>
f0103c49:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0103c4c:	80 7a ff 00          	cmpb   $0x0,0xffffffff(%edx)
f0103c50:	74 0a                	je     f0103c5c <debuginfo_eip+0x8e>
		return -1;
f0103c52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c57:	e9 33 01 00 00       	jmp    f0103d8f <debuginfo_eip+0x1c1>

	// Now we find the right stabs that define the function containing
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103c5c:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103c63:	89 c1                	mov    %eax,%ecx
f0103c65:	29 f1                	sub    %esi,%ecx
f0103c67:	c1 f9 02             	sar    $0x2,%ecx
f0103c6a:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f0103c6d:	89 c2                	mov    %eax,%edx
f0103c6f:	c1 e2 04             	shl    $0x4,%edx
f0103c72:	01 d0                	add    %edx,%eax
f0103c74:	89 c2                	mov    %eax,%edx
f0103c76:	c1 e2 08             	shl    $0x8,%edx
f0103c79:	01 d0                	add    %edx,%eax
f0103c7b:	89 c2                	mov    %eax,%edx
f0103c7d:	c1 e2 10             	shl    $0x10,%edx
f0103c80:	01 d0                	add    %edx,%eax
f0103c82:	8d 44 41 ff          	lea    0xffffffff(%ecx,%eax,2),%eax
f0103c86:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103c89:	83 ec 0c             	sub    $0xc,%esp
f0103c8c:	53                   	push   %ebx
f0103c8d:	6a 64                	push   $0x64
f0103c8f:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0103c92:	50                   	push   %eax
f0103c93:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f0103c96:	50                   	push   %eax
f0103c97:	56                   	push   %esi
f0103c98:	e8 27 fe ff ff       	call   f0103ac4 <stab_binsearch>
	if (lfile == 0)
f0103c9d:	83 c4 20             	add    $0x20,%esp
f0103ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ca5:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0103ca9:	0f 84 e0 00 00 00    	je     f0103d8f <debuginfo_eip+0x1c1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103caf:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0103cb2:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
	rfun = rfile;
f0103cb5:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0103cb8:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103cbb:	83 ec 0c             	sub    $0xc,%esp
f0103cbe:	53                   	push   %ebx
f0103cbf:	6a 24                	push   $0x24
f0103cc1:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0103cc4:	50                   	push   %eax
f0103cc5:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f0103cc8:	50                   	push   %eax
f0103cc9:	56                   	push   %esi
f0103cca:	e8 f5 fd ff ff       	call   f0103ac4 <stab_binsearch>

	if (lfun <= rfun) {
f0103ccf:	83 c4 20             	add    $0x20,%esp
f0103cd2:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0103cd5:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f0103cd8:	7f 2f                	jg     f0103d09 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103cda:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103cdd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103ce4:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0103ce7:	2b 45 e0             	sub    0xffffffe0(%ebp),%eax
f0103cea:	39 04 16             	cmp    %eax,(%esi,%edx,1)
f0103ced:	73 09                	jae    f0103cf8 <debuginfo_eip+0x12a>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103cef:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0103cf2:	03 04 16             	add    (%esi,%edx,1),%eax
f0103cf5:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = (uint32*) stabs[lfun].n_value;
f0103cf8:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f0103cfb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cfe:	8b 54 96 08          	mov    0x8(%esi,%edx,4),%edx
f0103d02:	89 57 10             	mov    %edx,0x10(%edi)
		addr = (uint32*)(addr - (info->eip_fn_addr));
		// Search within the function definition for the line number.
		lline = lfun;
f0103d05:	89 c3                	mov    %eax,%ebx
		rline = rfun;
f0103d07:	eb 06                	jmp    f0103d0f <debuginfo_eip+0x141>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103d09:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0103d0c:	8b 5d ec             	mov    0xffffffec(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103d0f:	83 ec 08             	sub    $0x8,%esp
f0103d12:	6a 3a                	push   $0x3a
f0103d14:	ff 77 08             	pushl  0x8(%edi)
f0103d17:	e8 59 07 00 00       	call   f0104475 <strfind>
f0103d1c:	2b 47 08             	sub    0x8(%edi),%eax
f0103d1f:	89 47 0c             	mov    %eax,0xc(%edi)

	
	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103d22:	83 c4 10             	add    $0x10,%esp
f0103d25:	3b 5d ec             	cmp    0xffffffec(%ebp),%ebx
f0103d28:	7c 60                	jl     f0103d8a <debuginfo_eip+0x1bc>
f0103d2a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103d2d:	c1 e0 02             	shl    $0x2,%eax
f0103d30:	80 7c 06 04 84       	cmpb   $0x84,0x4(%esi,%eax,1)
f0103d35:	74 31                	je     f0103d68 <debuginfo_eip+0x19a>
f0103d37:	80 7c 06 04 64       	cmpb   $0x64,0x4(%esi,%eax,1)
f0103d3c:	75 07                	jne    f0103d45 <debuginfo_eip+0x177>
f0103d3e:	83 7c 06 08 00       	cmpl   $0x0,0x8(%esi,%eax,1)
f0103d43:	75 23                	jne    f0103d68 <debuginfo_eip+0x19a>
f0103d45:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103d48:	4b                   	dec    %ebx
f0103d49:	39 d3                	cmp    %edx,%ebx
f0103d4b:	7c 1b                	jl     f0103d68 <debuginfo_eip+0x19a>
f0103d4d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103d50:	c1 e0 02             	shl    $0x2,%eax
f0103d53:	80 7c 06 04 84       	cmpb   $0x84,0x4(%esi,%eax,1)
f0103d58:	74 0e                	je     f0103d68 <debuginfo_eip+0x19a>
f0103d5a:	80 7c 06 04 64       	cmpb   $0x64,0x4(%esi,%eax,1)
f0103d5f:	75 e7                	jne    f0103d48 <debuginfo_eip+0x17a>
f0103d61:	83 7c 06 08 00       	cmpl   $0x0,0x8(%esi,%eax,1)
f0103d66:	74 e0                	je     f0103d48 <debuginfo_eip+0x17a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103d68:	3b 5d ec             	cmp    0xffffffec(%ebp),%ebx
f0103d6b:	7c 1d                	jl     f0103d8a <debuginfo_eip+0x1bc>
f0103d6d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103d70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103d77:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0103d7a:	2b 45 e0             	sub    0xffffffe0(%ebp),%eax
f0103d7d:	39 04 16             	cmp    %eax,(%esi,%edx,1)
f0103d80:	73 08                	jae    f0103d8a <debuginfo_eip+0x1bc>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103d82:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0103d85:	03 04 16             	add    (%esi,%edx,1),%eax
f0103d88:	89 07                	mov    %eax,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f0103d8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d8f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103d92:	5b                   	pop    %ebx
f0103d93:	5e                   	pop    %esi
f0103d94:	5f                   	pop    %edi
f0103d95:	5d                   	pop    %ebp
f0103d96:	c3                   	ret    
	...

f0103d98 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103d98:	55                   	push   %ebp
f0103d99:	89 e5                	mov    %esp,%ebp
f0103d9b:	57                   	push   %edi
f0103d9c:	56                   	push   %esi
f0103d9d:	53                   	push   %ebx
f0103d9e:	83 ec 0c             	sub    $0xc,%esp
f0103da1:	8b 75 10             	mov    0x10(%ebp),%esi
f0103da4:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103da7:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103daa:	8b 45 18             	mov    0x18(%ebp),%eax
f0103dad:	ba 00 00 00 00       	mov    $0x0,%edx
f0103db2:	39 d7                	cmp    %edx,%edi
f0103db4:	72 39                	jb     f0103def <printnum+0x57>
f0103db6:	77 04                	ja     f0103dbc <printnum+0x24>
f0103db8:	39 c6                	cmp    %eax,%esi
f0103dba:	72 33                	jb     f0103def <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103dbc:	83 ec 04             	sub    $0x4,%esp
f0103dbf:	ff 75 20             	pushl  0x20(%ebp)
f0103dc2:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
f0103dc5:	50                   	push   %eax
f0103dc6:	ff 75 18             	pushl  0x18(%ebp)
f0103dc9:	8b 45 18             	mov    0x18(%ebp),%eax
f0103dcc:	ba 00 00 00 00       	mov    $0x0,%edx
f0103dd1:	52                   	push   %edx
f0103dd2:	50                   	push   %eax
f0103dd3:	57                   	push   %edi
f0103dd4:	56                   	push   %esi
f0103dd5:	e8 16 0a 00 00       	call   f01047f0 <__udivdi3>
f0103dda:	83 c4 10             	add    $0x10,%esp
f0103ddd:	52                   	push   %edx
f0103dde:	50                   	push   %eax
f0103ddf:	ff 75 0c             	pushl  0xc(%ebp)
f0103de2:	ff 75 08             	pushl  0x8(%ebp)
f0103de5:	e8 ae ff ff ff       	call   f0103d98 <printnum>
f0103dea:	83 c4 20             	add    $0x20,%esp
f0103ded:	eb 19                	jmp    f0103e08 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103def:	4b                   	dec    %ebx
f0103df0:	85 db                	test   %ebx,%ebx
f0103df2:	7e 14                	jle    f0103e08 <printnum+0x70>
			putch(padc, putdat);
f0103df4:	83 ec 08             	sub    $0x8,%esp
f0103df7:	ff 75 0c             	pushl  0xc(%ebp)
f0103dfa:	ff 75 20             	pushl  0x20(%ebp)
f0103dfd:	ff 55 08             	call   *0x8(%ebp)
f0103e00:	83 c4 10             	add    $0x10,%esp
f0103e03:	4b                   	dec    %ebx
f0103e04:	85 db                	test   %ebx,%ebx
f0103e06:	7f ec                	jg     f0103df4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103e08:	83 ec 08             	sub    $0x8,%esp
f0103e0b:	ff 75 0c             	pushl  0xc(%ebp)
f0103e0e:	8b 45 18             	mov    0x18(%ebp),%eax
f0103e11:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e16:	83 ec 04             	sub    $0x4,%esp
f0103e19:	52                   	push   %edx
f0103e1a:	50                   	push   %eax
f0103e1b:	57                   	push   %edi
f0103e1c:	56                   	push   %esi
f0103e1d:	e8 0e 0b 00 00       	call   f0104930 <__umoddi3>
f0103e22:	83 c4 14             	add    $0x14,%esp
f0103e25:	0f be 80 87 62 10 f0 	movsbl 0xf0106287(%eax),%eax
f0103e2c:	50                   	push   %eax
f0103e2d:	ff 55 08             	call   *0x8(%ebp)
}
f0103e30:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103e33:	5b                   	pop    %ebx
f0103e34:	5e                   	pop    %esi
f0103e35:	5f                   	pop    %edi
f0103e36:	5d                   	pop    %ebp
f0103e37:	c3                   	ret    

f0103e38 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103e38:	55                   	push   %ebp
f0103e39:	89 e5                	mov    %esp,%ebp
f0103e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0103e41:	83 f8 01             	cmp    $0x1,%eax
f0103e44:	7e 0f                	jle    f0103e55 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f0103e46:	8b 01                	mov    (%ecx),%eax
f0103e48:	83 c0 08             	add    $0x8,%eax
f0103e4b:	89 01                	mov    %eax,(%ecx)
f0103e4d:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f0103e50:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f0103e53:	eb 0f                	jmp    f0103e64 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103e55:	8b 01                	mov    (%ecx),%eax
f0103e57:	83 c0 04             	add    $0x4,%eax
f0103e5a:	89 01                	mov    %eax,(%ecx)
f0103e5c:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f0103e5f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103e64:	5d                   	pop    %ebp
f0103e65:	c3                   	ret    

f0103e66 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103e66:	55                   	push   %ebp
f0103e67:	89 e5                	mov    %esp,%ebp
f0103e69:	8b 55 08             	mov    0x8(%ebp),%edx
f0103e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0103e6f:	83 f8 01             	cmp    $0x1,%eax
f0103e72:	7e 0f                	jle    f0103e83 <getint+0x1d>
		return va_arg(*ap, long long);
f0103e74:	8b 02                	mov    (%edx),%eax
f0103e76:	83 c0 08             	add    $0x8,%eax
f0103e79:	89 02                	mov    %eax,(%edx)
f0103e7b:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f0103e7e:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f0103e81:	eb 0f                	jmp    f0103e92 <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f0103e83:	8b 02                	mov    (%edx),%eax
f0103e85:	83 c0 04             	add    $0x4,%eax
f0103e88:	89 02                	mov    %eax,(%edx)
f0103e8a:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f0103e8d:	89 c2                	mov    %eax,%edx
f0103e8f:	c1 fa 1f             	sar    $0x1f,%edx
}
f0103e92:	5d                   	pop    %ebp
f0103e93:	c3                   	ret    

f0103e94 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103e94:	55                   	push   %ebp
f0103e95:	89 e5                	mov    %esp,%ebp
f0103e97:	57                   	push   %edi
f0103e98:	56                   	push   %esi
f0103e99:	53                   	push   %ebx
f0103e9a:	83 ec 1c             	sub    $0x1c,%esp
f0103e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103ea0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ea5:	8a 13                	mov    (%ebx),%dl
f0103ea7:	43                   	inc    %ebx
f0103ea8:	83 fa 25             	cmp    $0x25,%edx
f0103eab:	74 22                	je     f0103ecf <vprintfmt+0x3b>
			if (ch == '\0')
f0103ead:	85 d2                	test   %edx,%edx
f0103eaf:	0f 84 cd 02 00 00    	je     f0104182 <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
f0103eb5:	83 ec 08             	sub    $0x8,%esp
f0103eb8:	ff 75 0c             	pushl  0xc(%ebp)
f0103ebb:	52                   	push   %edx
f0103ebc:	ff 55 08             	call   *0x8(%ebp)
f0103ebf:	83 c4 10             	add    $0x10,%esp
f0103ec2:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ec7:	8a 13                	mov    (%ebx),%dl
f0103ec9:	43                   	inc    %ebx
f0103eca:	83 fa 25             	cmp    $0x25,%edx
f0103ecd:	75 de                	jne    f0103ead <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
f0103ecf:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
f0103ed3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
f0103eda:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
f0103edf:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
f0103ee4:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eeb:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ef0:	8a 13                	mov    (%ebx),%dl
f0103ef2:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
f0103ef5:	43                   	inc    %ebx
f0103ef6:	83 f8 55             	cmp    $0x55,%eax
f0103ef9:	0f 87 5e 02 00 00    	ja     f010415d <vprintfmt+0x2c9>
f0103eff:	ff 24 85 e0 62 10 f0 	jmp    *0xf01062e0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
f0103f06:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
f0103f0a:	eb df                	jmp    f0103eeb <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103f0c:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
f0103f10:	eb d9                	jmp    f0103eeb <vprintfmt+0x57>

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
f0103f12:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
f0103f17:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0103f1a:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
f0103f1e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103f21:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f0103f24:	83 f8 09             	cmp    $0x9,%eax
f0103f27:	77 27                	ja     f0103f50 <vprintfmt+0xbc>
f0103f29:	43                   	inc    %ebx
f0103f2a:	eb eb                	jmp    f0103f17 <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103f2c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f30:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f33:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
f0103f36:	eb 18                	jmp    f0103f50 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
f0103f38:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103f3c:	79 ad                	jns    f0103eeb <vprintfmt+0x57>
				width = 0;
f0103f3e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
f0103f45:	eb a4                	jmp    f0103eeb <vprintfmt+0x57>

		case '#':
			altflag = 1;
f0103f47:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
f0103f4e:	eb 9b                	jmp    f0103eeb <vprintfmt+0x57>

		process_precision:
			if (width < 0)
f0103f50:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103f54:	79 95                	jns    f0103eeb <vprintfmt+0x57>
				width = precision, precision = -1;
f0103f56:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
f0103f59:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
f0103f5e:	eb 8b                	jmp    f0103eeb <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103f60:	41                   	inc    %ecx
			goto reswitch;
f0103f61:	eb 88                	jmp    f0103eeb <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103f63:	83 ec 08             	sub    $0x8,%esp
f0103f66:	ff 75 0c             	pushl  0xc(%ebp)
f0103f69:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f70:	ff 70 fc             	pushl  0xfffffffc(%eax)
f0103f73:	e9 da 01 00 00       	jmp    f0104152 <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f78:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f7f:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
f0103f82:	85 c0                	test   %eax,%eax
f0103f84:	79 02                	jns    f0103f88 <vprintfmt+0xf4>
				err = -err;
f0103f86:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103f88:	83 f8 07             	cmp    $0x7,%eax
f0103f8b:	7f 0b                	jg     f0103f98 <vprintfmt+0x104>
f0103f8d:	8b 3c 85 c0 62 10 f0 	mov    0xf01062c0(,%eax,4),%edi
f0103f94:	85 ff                	test   %edi,%edi
f0103f96:	75 08                	jne    f0103fa0 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
f0103f98:	50                   	push   %eax
f0103f99:	68 98 62 10 f0       	push   $0xf0106298
f0103f9e:	eb 06                	jmp    f0103fa6 <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
f0103fa0:	57                   	push   %edi
f0103fa1:	68 d4 5a 10 f0       	push   $0xf0105ad4
f0103fa6:	ff 75 0c             	pushl  0xc(%ebp)
f0103fa9:	ff 75 08             	pushl  0x8(%ebp)
f0103fac:	e8 d9 01 00 00       	call   f010418a <printfmt>
f0103fb1:	e9 9f 01 00 00       	jmp    f0104155 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103fb6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fbd:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
f0103fc0:	85 ff                	test   %edi,%edi
f0103fc2:	75 05                	jne    f0103fc9 <vprintfmt+0x135>
				p = "(null)";
f0103fc4:	bf a1 62 10 f0       	mov    $0xf01062a1,%edi
			if (width > 0 && padc != '-')
f0103fc9:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103fcd:	0f 9f c2             	setg   %dl
f0103fd0:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
f0103fd4:	0f 95 c0             	setne  %al
f0103fd7:	21 d0                	and    %edx,%eax
f0103fd9:	a8 01                	test   $0x1,%al
f0103fdb:	74 35                	je     f0104012 <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fdd:	83 ec 08             	sub    $0x8,%esp
f0103fe0:	56                   	push   %esi
f0103fe1:	57                   	push   %edi
f0103fe2:	e8 42 03 00 00       	call   f0104329 <strnlen>
f0103fe7:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
f0103fea:	83 c4 10             	add    $0x10,%esp
f0103fed:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103ff1:	7e 1f                	jle    f0104012 <vprintfmt+0x17e>
f0103ff3:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f0103ff7:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
f0103ffa:	83 ec 08             	sub    $0x8,%esp
f0103ffd:	ff 75 0c             	pushl  0xc(%ebp)
f0104000:	ff 75 e4             	pushl  0xffffffe4(%ebp)
f0104003:	ff 55 08             	call   *0x8(%ebp)
f0104006:	83 c4 10             	add    $0x10,%esp
f0104009:	ff 4d f0             	decl   0xfffffff0(%ebp)
f010400c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104010:	7f e8                	jg     f0103ffa <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104012:	0f be 17             	movsbl (%edi),%edx
f0104015:	47                   	inc    %edi
f0104016:	85 d2                	test   %edx,%edx
f0104018:	74 3e                	je     f0104058 <vprintfmt+0x1c4>
f010401a:	85 f6                	test   %esi,%esi
f010401c:	78 03                	js     f0104021 <vprintfmt+0x18d>
f010401e:	4e                   	dec    %esi
f010401f:	78 37                	js     f0104058 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
f0104021:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0104025:	74 12                	je     f0104039 <vprintfmt+0x1a5>
f0104027:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
f010402a:	83 f8 5e             	cmp    $0x5e,%eax
f010402d:	76 0a                	jbe    f0104039 <vprintfmt+0x1a5>
					putch('?', putdat);
f010402f:	83 ec 08             	sub    $0x8,%esp
f0104032:	ff 75 0c             	pushl  0xc(%ebp)
f0104035:	6a 3f                	push   $0x3f
f0104037:	eb 07                	jmp    f0104040 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
f0104039:	83 ec 08             	sub    $0x8,%esp
f010403c:	ff 75 0c             	pushl  0xc(%ebp)
f010403f:	52                   	push   %edx
f0104040:	ff 55 08             	call   *0x8(%ebp)
f0104043:	83 c4 10             	add    $0x10,%esp
f0104046:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0104049:	0f be 17             	movsbl (%edi),%edx
f010404c:	47                   	inc    %edi
f010404d:	85 d2                	test   %edx,%edx
f010404f:	74 07                	je     f0104058 <vprintfmt+0x1c4>
f0104051:	85 f6                	test   %esi,%esi
f0104053:	78 cc                	js     f0104021 <vprintfmt+0x18d>
f0104055:	4e                   	dec    %esi
f0104056:	79 c9                	jns    f0104021 <vprintfmt+0x18d>
			for (; width > 0; width--)
f0104058:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010405c:	0f 8e 3e fe ff ff    	jle    f0103ea0 <vprintfmt+0xc>
				putch(' ', putdat);
f0104062:	83 ec 08             	sub    $0x8,%esp
f0104065:	ff 75 0c             	pushl  0xc(%ebp)
f0104068:	6a 20                	push   $0x20
f010406a:	ff 55 08             	call   *0x8(%ebp)
f010406d:	83 c4 10             	add    $0x10,%esp
f0104070:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0104073:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104077:	7f e9                	jg     f0104062 <vprintfmt+0x1ce>
			break;
f0104079:	e9 22 fe ff ff       	jmp    f0103ea0 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010407e:	83 ec 08             	sub    $0x8,%esp
f0104081:	51                   	push   %ecx
f0104082:	8d 45 14             	lea    0x14(%ebp),%eax
f0104085:	50                   	push   %eax
f0104086:	e8 db fd ff ff       	call   f0103e66 <getint>
f010408b:	89 c6                	mov    %eax,%esi
f010408d:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f010408f:	83 c4 10             	add    $0x10,%esp
f0104092:	85 d2                	test   %edx,%edx
f0104094:	79 15                	jns    f01040ab <vprintfmt+0x217>
				putch('-', putdat);
f0104096:	83 ec 08             	sub    $0x8,%esp
f0104099:	ff 75 0c             	pushl  0xc(%ebp)
f010409c:	6a 2d                	push   $0x2d
f010409e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01040a1:	f7 de                	neg    %esi
f01040a3:	83 d7 00             	adc    $0x0,%edi
f01040a6:	f7 df                	neg    %edi
f01040a8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01040ab:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f01040b0:	eb 78                	jmp    f010412a <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01040b2:	83 ec 08             	sub    $0x8,%esp
f01040b5:	51                   	push   %ecx
f01040b6:	8d 45 14             	lea    0x14(%ebp),%eax
f01040b9:	50                   	push   %eax
f01040ba:	e8 79 fd ff ff       	call   f0103e38 <getuint>
f01040bf:	89 c6                	mov    %eax,%esi
f01040c1:	89 d7                	mov    %edx,%edi
			base = 10;
f01040c3:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f01040c8:	eb 5d                	jmp    f0104127 <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01040ca:	83 ec 08             	sub    $0x8,%esp
f01040cd:	ff 75 0c             	pushl  0xc(%ebp)
f01040d0:	6a 58                	push   $0x58
f01040d2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01040d5:	83 c4 08             	add    $0x8,%esp
f01040d8:	ff 75 0c             	pushl  0xc(%ebp)
f01040db:	6a 58                	push   $0x58
f01040dd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01040e0:	83 c4 08             	add    $0x8,%esp
f01040e3:	ff 75 0c             	pushl  0xc(%ebp)
f01040e6:	6a 58                	push   $0x58
f01040e8:	eb 68                	jmp    f0104152 <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01040ea:	83 ec 08             	sub    $0x8,%esp
f01040ed:	ff 75 0c             	pushl  0xc(%ebp)
f01040f0:	6a 30                	push   $0x30
f01040f2:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01040f5:	83 c4 08             	add    $0x8,%esp
f01040f8:	ff 75 0c             	pushl  0xc(%ebp)
f01040fb:	6a 78                	push   $0x78
f01040fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104100:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104104:	8b 45 14             	mov    0x14(%ebp),%eax
f0104107:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
f010410a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
f010410f:	eb 11                	jmp    f0104122 <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104111:	83 ec 08             	sub    $0x8,%esp
f0104114:	51                   	push   %ecx
f0104115:	8d 45 14             	lea    0x14(%ebp),%eax
f0104118:	50                   	push   %eax
f0104119:	e8 1a fd ff ff       	call   f0103e38 <getuint>
f010411e:	89 c6                	mov    %eax,%esi
f0104120:	89 d7                	mov    %edx,%edi
			base = 16;
f0104122:	ba 10 00 00 00       	mov    $0x10,%edx
f0104127:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
f010412a:	83 ec 04             	sub    $0x4,%esp
f010412d:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f0104131:	50                   	push   %eax
f0104132:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0104135:	52                   	push   %edx
f0104136:	57                   	push   %edi
f0104137:	56                   	push   %esi
f0104138:	ff 75 0c             	pushl  0xc(%ebp)
f010413b:	ff 75 08             	pushl  0x8(%ebp)
f010413e:	e8 55 fc ff ff       	call   f0103d98 <printnum>
			break;
f0104143:	83 c4 20             	add    $0x20,%esp
f0104146:	e9 55 fd ff ff       	jmp    f0103ea0 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010414b:	83 ec 08             	sub    $0x8,%esp
f010414e:	ff 75 0c             	pushl  0xc(%ebp)
f0104151:	52                   	push   %edx
f0104152:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104155:	83 c4 10             	add    $0x10,%esp
f0104158:	e9 43 fd ff ff       	jmp    f0103ea0 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010415d:	83 ec 08             	sub    $0x8,%esp
f0104160:	ff 75 0c             	pushl  0xc(%ebp)
f0104163:	6a 25                	push   $0x25
f0104165:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104168:	4b                   	dec    %ebx
f0104169:	83 c4 10             	add    $0x10,%esp
f010416c:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f0104170:	0f 84 2a fd ff ff    	je     f0103ea0 <vprintfmt+0xc>
f0104176:	4b                   	dec    %ebx
f0104177:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f010417b:	75 f9                	jne    f0104176 <vprintfmt+0x2e2>
				/* do nothing */;
			break;
f010417d:	e9 1e fd ff ff       	jmp    f0103ea0 <vprintfmt+0xc>
		}
	}
}
f0104182:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0104185:	5b                   	pop    %ebx
f0104186:	5e                   	pop    %esi
f0104187:	5f                   	pop    %edi
f0104188:	5d                   	pop    %ebp
f0104189:	c3                   	ret    

f010418a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010418a:	55                   	push   %ebp
f010418b:	89 e5                	mov    %esp,%ebp
f010418d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104190:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104193:	50                   	push   %eax
f0104194:	ff 75 10             	pushl  0x10(%ebp)
f0104197:	ff 75 0c             	pushl  0xc(%ebp)
f010419a:	ff 75 08             	pushl  0x8(%ebp)
f010419d:	e8 f2 fc ff ff       	call   f0103e94 <vprintfmt>
	va_end(ap);
}
f01041a2:	c9                   	leave  
f01041a3:	c3                   	ret    

f01041a4 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01041a4:	55                   	push   %ebp
f01041a5:	89 e5                	mov    %esp,%ebp
f01041a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f01041aa:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
f01041ad:	8b 0a                	mov    (%edx),%ecx
f01041af:	3b 4a 04             	cmp    0x4(%edx),%ecx
f01041b2:	73 07                	jae    f01041bb <sprintputch+0x17>
		*b->buf++ = ch;
f01041b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01041b7:	88 01                	mov    %al,(%ecx)
f01041b9:	ff 02                	incl   (%edx)
}
f01041bb:	5d                   	pop    %ebp
f01041bc:	c3                   	ret    

f01041bd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01041bd:	55                   	push   %ebp
f01041be:	89 e5                	mov    %esp,%ebp
f01041c0:	83 ec 18             	sub    $0x18,%esp
f01041c3:	8b 55 08             	mov    0x8(%ebp),%edx
f01041c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01041c9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f01041cc:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
f01041d0:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f01041d3:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
f01041da:	85 d2                	test   %edx,%edx
f01041dc:	0f 94 c2             	sete   %dl
f01041df:	85 c9                	test   %ecx,%ecx
f01041e1:	0f 9e c0             	setle  %al
f01041e4:	09 d0                	or     %edx,%eax
f01041e6:	ba 03 00 00 00       	mov    $0x3,%edx
f01041eb:	a8 01                	test   $0x1,%al
f01041ed:	75 1d                	jne    f010420c <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01041ef:	ff 75 14             	pushl  0x14(%ebp)
f01041f2:	ff 75 10             	pushl  0x10(%ebp)
f01041f5:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f01041f8:	50                   	push   %eax
f01041f9:	68 a4 41 10 f0       	push   $0xf01041a4
f01041fe:	e8 91 fc ff ff       	call   f0103e94 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104203:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0104206:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104209:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
f010420c:	89 d0                	mov    %edx,%eax
f010420e:	c9                   	leave  
f010420f:	c3                   	ret    

f0104210 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104210:	55                   	push   %ebp
f0104211:	89 e5                	mov    %esp,%ebp
f0104213:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104216:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104219:	50                   	push   %eax
f010421a:	ff 75 10             	pushl  0x10(%ebp)
f010421d:	ff 75 0c             	pushl  0xc(%ebp)
f0104220:	ff 75 08             	pushl  0x8(%ebp)
f0104223:	e8 95 ff ff ff       	call   f01041bd <vsnprintf>
	va_end(ap);

	return rc;
}
f0104228:	c9                   	leave  
f0104229:	c3                   	ret    
	...

f010422c <readline>:
#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
f010422c:	55                   	push   %ebp
f010422d:	89 e5                	mov    %esp,%ebp
f010422f:	57                   	push   %edi
f0104230:	56                   	push   %esi
f0104231:	53                   	push   %ebx
f0104232:	83 ec 0c             	sub    $0xc,%esp
f0104235:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;
	
	if (prompt != NULL)
f0104238:	85 c0                	test   %eax,%eax
f010423a:	74 11                	je     f010424d <readline+0x21>
		cprintf("%s", prompt);
f010423c:	83 ec 08             	sub    $0x8,%esp
f010423f:	50                   	push   %eax
f0104240:	68 d4 5a 10 f0       	push   $0xf0105ad4
f0104245:	e8 94 f1 ff ff       	call   f01033de <cprintf>
f010424a:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
f010424d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);	
f0104252:	83 ec 0c             	sub    $0xc,%esp
f0104255:	6a 00                	push   $0x0
f0104257:	e8 2c c4 ff ff       	call   f0100688 <iscons>
f010425c:	89 c7                	mov    %eax,%edi
	while (1) {
f010425e:	83 c4 10             	add    $0x10,%esp
		c = getchar();
f0104261:	e8 11 c4 ff ff       	call   f0100677 <getchar>
f0104266:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104268:	85 c0                	test   %eax,%eax
f010426a:	79 1c                	jns    f0104288 <readline+0x5c>
			if (c != -E_EOF)
f010426c:	83 f8 07             	cmp    $0x7,%eax
f010426f:	0f 84 92 00 00 00    	je     f0104307 <readline+0xdb>
				cprintf("read error: %e\n", c);			
f0104275:	83 ec 08             	sub    $0x8,%esp
f0104278:	50                   	push   %eax
f0104279:	68 38 64 10 f0       	push   $0xf0106438
f010427e:	e8 5b f1 ff ff       	call   f01033de <cprintf>
f0104283:	83 c4 10             	add    $0x10,%esp
			return;
f0104286:	eb 7f                	jmp    f0104307 <readline+0xdb>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104288:	83 f8 1f             	cmp    $0x1f,%eax
f010428b:	0f 9f c2             	setg   %dl
f010428e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104294:	0f 9e c0             	setle  %al
f0104297:	21 d0                	and    %edx,%eax
f0104299:	a8 01                	test   $0x1,%al
f010429b:	74 19                	je     f01042b6 <readline+0x8a>
			if (echoing)
f010429d:	85 ff                	test   %edi,%edi
f010429f:	74 0c                	je     f01042ad <readline+0x81>
				cputchar(c);
f01042a1:	83 ec 0c             	sub    $0xc,%esp
f01042a4:	53                   	push   %ebx
f01042a5:	e8 bd c3 ff ff       	call   f0100667 <cputchar>
f01042aa:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01042ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042b0:	88 1c 06             	mov    %bl,(%esi,%eax,1)
f01042b3:	46                   	inc    %esi
f01042b4:	eb ab                	jmp    f0104261 <readline+0x35>
		} else if (c == '\b' && i > 0) {
f01042b6:	83 fb 08             	cmp    $0x8,%ebx
f01042b9:	0f 94 c2             	sete   %dl
f01042bc:	85 f6                	test   %esi,%esi
f01042be:	0f 9f c0             	setg   %al
f01042c1:	21 d0                	and    %edx,%eax
f01042c3:	a8 01                	test   $0x1,%al
f01042c5:	74 13                	je     f01042da <readline+0xae>
			if (echoing)
f01042c7:	85 ff                	test   %edi,%edi
f01042c9:	74 0c                	je     f01042d7 <readline+0xab>
				cputchar(c);
f01042cb:	83 ec 0c             	sub    $0xc,%esp
f01042ce:	53                   	push   %ebx
f01042cf:	e8 93 c3 ff ff       	call   f0100667 <cputchar>
f01042d4:	83 c4 10             	add    $0x10,%esp
			i--;
f01042d7:	4e                   	dec    %esi
f01042d8:	eb 87                	jmp    f0104261 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01042da:	83 fb 0a             	cmp    $0xa,%ebx
f01042dd:	0f 94 c2             	sete   %dl
f01042e0:	83 fb 0d             	cmp    $0xd,%ebx
f01042e3:	0f 94 c0             	sete   %al
f01042e6:	09 d0                	or     %edx,%eax
f01042e8:	a8 01                	test   $0x1,%al
f01042ea:	0f 84 71 ff ff ff    	je     f0104261 <readline+0x35>
			if (echoing)
f01042f0:	85 ff                	test   %edi,%edi
f01042f2:	74 0c                	je     f0104300 <readline+0xd4>
				cputchar(c);
f01042f4:	83 ec 0c             	sub    $0xc,%esp
f01042f7:	53                   	push   %ebx
f01042f8:	e8 6a c3 ff ff       	call   f0100667 <cputchar>
f01042fd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
f0104300:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104303:	c6 04 16 00          	movb   $0x0,(%esi,%edx,1)
			return;		
		}
	}
}
f0104307:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010430a:	5b                   	pop    %ebx
f010430b:	5e                   	pop    %esi
f010430c:	5f                   	pop    %edi
f010430d:	5d                   	pop    %ebp
f010430e:	c3                   	ret    
	...

f0104310 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
f0104310:	55                   	push   %ebp
f0104311:	89 e5                	mov    %esp,%ebp
f0104313:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104316:	b8 00 00 00 00       	mov    $0x0,%eax
f010431b:	80 3a 00             	cmpb   $0x0,(%edx)
f010431e:	74 07                	je     f0104327 <strlen+0x17>
		n++;
f0104320:	40                   	inc    %eax
f0104321:	42                   	inc    %edx
f0104322:	80 3a 00             	cmpb   $0x0,(%edx)
f0104325:	75 f9                	jne    f0104320 <strlen+0x10>
	return n;
}
f0104327:	5d                   	pop    %ebp
f0104328:	c3                   	ret    

f0104329 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
f0104329:	55                   	push   %ebp
f010432a:	89 e5                	mov    %esp,%ebp
f010432c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010432f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104332:	b8 00 00 00 00       	mov    $0x0,%eax
f0104337:	85 d2                	test   %edx,%edx
f0104339:	74 0f                	je     f010434a <strnlen+0x21>
f010433b:	80 39 00             	cmpb   $0x0,(%ecx)
f010433e:	74 0a                	je     f010434a <strnlen+0x21>
		n++;
f0104340:	40                   	inc    %eax
f0104341:	41                   	inc    %ecx
f0104342:	4a                   	dec    %edx
f0104343:	74 05                	je     f010434a <strnlen+0x21>
f0104345:	80 39 00             	cmpb   $0x0,(%ecx)
f0104348:	75 f6                	jne    f0104340 <strnlen+0x17>
	return n;
}
f010434a:	5d                   	pop    %ebp
f010434b:	c3                   	ret    

f010434c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010434c:	55                   	push   %ebp
f010434d:	89 e5                	mov    %esp,%ebp
f010434f:	53                   	push   %ebx
f0104350:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104353:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
f0104356:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
f0104358:	8a 02                	mov    (%edx),%al
f010435a:	88 01                	mov    %al,(%ecx)
f010435c:	42                   	inc    %edx
f010435d:	41                   	inc    %ecx
f010435e:	84 c0                	test   %al,%al
f0104360:	75 f6                	jne    f0104358 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104362:	89 d8                	mov    %ebx,%eax
f0104364:	5b                   	pop    %ebx
f0104365:	5d                   	pop    %ebp
f0104366:	c3                   	ret    

f0104367 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
f0104367:	55                   	push   %ebp
f0104368:	89 e5                	mov    %esp,%ebp
f010436a:	57                   	push   %edi
f010436b:	56                   	push   %esi
f010436c:	53                   	push   %ebx
f010436d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104370:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104373:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
f0104376:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
f0104378:	bb 00 00 00 00       	mov    $0x0,%ebx
f010437d:	39 f3                	cmp    %esi,%ebx
f010437f:	73 17                	jae    f0104398 <strncpy+0x31>
		*dst++ = *src;
f0104381:	8a 02                	mov    (%edx),%al
f0104383:	88 01                	mov    %al,(%ecx)
f0104385:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0104386:	80 3a 00             	cmpb   $0x0,(%edx)
f0104389:	0f 95 c0             	setne  %al
f010438c:	25 ff 00 00 00       	and    $0xff,%eax
f0104391:	01 c2                	add    %eax,%edx
f0104393:	43                   	inc    %ebx
f0104394:	39 f3                	cmp    %esi,%ebx
f0104396:	72 e9                	jb     f0104381 <strncpy+0x1a>
			src++;
	}
	return ret;
}
f0104398:	89 f8                	mov    %edi,%eax
f010439a:	5b                   	pop    %ebx
f010439b:	5e                   	pop    %esi
f010439c:	5f                   	pop    %edi
f010439d:	5d                   	pop    %ebp
f010439e:	c3                   	ret    

f010439f <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
f010439f:	55                   	push   %ebp
f01043a0:	89 e5                	mov    %esp,%ebp
f01043a2:	56                   	push   %esi
f01043a3:	53                   	push   %ebx
f01043a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01043a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01043aa:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
f01043ad:	89 de                	mov    %ebx,%esi
	if (size > 0) {
f01043af:	85 d2                	test   %edx,%edx
f01043b1:	74 19                	je     f01043cc <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
f01043b3:	4a                   	dec    %edx
f01043b4:	74 13                	je     f01043c9 <strlcpy+0x2a>
f01043b6:	80 39 00             	cmpb   $0x0,(%ecx)
f01043b9:	74 0e                	je     f01043c9 <strlcpy+0x2a>
			*dst++ = *src++;
f01043bb:	8a 01                	mov    (%ecx),%al
f01043bd:	88 03                	mov    %al,(%ebx)
f01043bf:	41                   	inc    %ecx
f01043c0:	43                   	inc    %ebx
f01043c1:	4a                   	dec    %edx
f01043c2:	74 05                	je     f01043c9 <strlcpy+0x2a>
f01043c4:	80 39 00             	cmpb   $0x0,(%ecx)
f01043c7:	75 f2                	jne    f01043bb <strlcpy+0x1c>
		*dst = '\0';
f01043c9:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
f01043cc:	89 d8                	mov    %ebx,%eax
f01043ce:	29 f0                	sub    %esi,%eax
}
f01043d0:	5b                   	pop    %ebx
f01043d1:	5e                   	pop    %esi
f01043d2:	5d                   	pop    %ebp
f01043d3:	c3                   	ret    

f01043d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01043d4:	55                   	push   %ebp
f01043d5:	89 e5                	mov    %esp,%ebp
f01043d7:	8b 55 08             	mov    0x8(%ebp),%edx
f01043da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f01043dd:	80 3a 00             	cmpb   $0x0,(%edx)
f01043e0:	74 13                	je     f01043f5 <strcmp+0x21>
f01043e2:	8a 02                	mov    (%edx),%al
f01043e4:	3a 01                	cmp    (%ecx),%al
f01043e6:	75 0d                	jne    f01043f5 <strcmp+0x21>
		p++, q++;
f01043e8:	42                   	inc    %edx
f01043e9:	41                   	inc    %ecx
f01043ea:	80 3a 00             	cmpb   $0x0,(%edx)
f01043ed:	74 06                	je     f01043f5 <strcmp+0x21>
f01043ef:	8a 02                	mov    (%edx),%al
f01043f1:	3a 01                	cmp    (%ecx),%al
f01043f3:	74 f3                	je     f01043e8 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01043f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01043fa:	8a 02                	mov    (%edx),%al
f01043fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0104401:	8a 11                	mov    (%ecx),%dl
f0104403:	29 d0                	sub    %edx,%eax
}
f0104405:	5d                   	pop    %ebp
f0104406:	c3                   	ret    

f0104407 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
f0104407:	55                   	push   %ebp
f0104408:	89 e5                	mov    %esp,%ebp
f010440a:	53                   	push   %ebx
f010440b:	8b 55 08             	mov    0x8(%ebp),%edx
f010440e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104411:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
f0104414:	85 c9                	test   %ecx,%ecx
f0104416:	74 1f                	je     f0104437 <strncmp+0x30>
f0104418:	80 3a 00             	cmpb   $0x0,(%edx)
f010441b:	74 16                	je     f0104433 <strncmp+0x2c>
f010441d:	8a 02                	mov    (%edx),%al
f010441f:	3a 03                	cmp    (%ebx),%al
f0104421:	75 10                	jne    f0104433 <strncmp+0x2c>
		n--, p++, q++;
f0104423:	42                   	inc    %edx
f0104424:	43                   	inc    %ebx
f0104425:	49                   	dec    %ecx
f0104426:	74 0f                	je     f0104437 <strncmp+0x30>
f0104428:	80 3a 00             	cmpb   $0x0,(%edx)
f010442b:	74 06                	je     f0104433 <strncmp+0x2c>
f010442d:	8a 02                	mov    (%edx),%al
f010442f:	3a 03                	cmp    (%ebx),%al
f0104431:	74 f0                	je     f0104423 <strncmp+0x1c>
	if (n == 0)
f0104433:	85 c9                	test   %ecx,%ecx
f0104435:	75 07                	jne    f010443e <strncmp+0x37>
		return 0;
f0104437:	b8 00 00 00 00       	mov    $0x0,%eax
f010443c:	eb 13                	jmp    f0104451 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010443e:	8a 12                	mov    (%edx),%dl
f0104440:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0104446:	b8 00 00 00 00       	mov    $0x0,%eax
f010444b:	8a 03                	mov    (%ebx),%al
f010444d:	29 c2                	sub    %eax,%edx
f010444f:	89 d0                	mov    %edx,%eax
}
f0104451:	5b                   	pop    %ebx
f0104452:	5d                   	pop    %ebp
f0104453:	c3                   	ret    

f0104454 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104454:	55                   	push   %ebp
f0104455:	89 e5                	mov    %esp,%ebp
f0104457:	8b 55 08             	mov    0x8(%ebp),%edx
f010445a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010445d:	80 3a 00             	cmpb   $0x0,(%edx)
f0104460:	74 0c                	je     f010446e <strchr+0x1a>
		if (*s == c)
f0104462:	89 d0                	mov    %edx,%eax
f0104464:	38 0a                	cmp    %cl,(%edx)
f0104466:	74 0b                	je     f0104473 <strchr+0x1f>
f0104468:	42                   	inc    %edx
f0104469:	80 3a 00             	cmpb   $0x0,(%edx)
f010446c:	75 f4                	jne    f0104462 <strchr+0xe>
			return (char *) s;
	return 0;
f010446e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104473:	5d                   	pop    %ebp
f0104474:	c3                   	ret    

f0104475 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104475:	55                   	push   %ebp
f0104476:	89 e5                	mov    %esp,%ebp
f0104478:	8b 45 08             	mov    0x8(%ebp),%eax
f010447b:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f010447e:	80 38 00             	cmpb   $0x0,(%eax)
f0104481:	74 0a                	je     f010448d <strfind+0x18>
		if (*s == c)
f0104483:	38 10                	cmp    %dl,(%eax)
f0104485:	74 06                	je     f010448d <strfind+0x18>
f0104487:	40                   	inc    %eax
f0104488:	80 38 00             	cmpb   $0x0,(%eax)
f010448b:	75 f6                	jne    f0104483 <strfind+0xe>
			break;
	return (char *) s;
}
f010448d:	5d                   	pop    %ebp
f010448e:	c3                   	ret    

f010448f <memset>:


void *
memset(void *v, int c, uint32 n)
{
f010448f:	55                   	push   %ebp
f0104490:	89 e5                	mov    %esp,%ebp
f0104492:	53                   	push   %ebx
f0104493:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104496:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
f0104499:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
f010449b:	8b 55 10             	mov    0x10(%ebp),%edx
f010449e:	4a                   	dec    %edx
f010449f:	78 06                	js     f01044a7 <memset+0x18>
		*p++ = c;
f01044a1:	88 01                	mov    %al,(%ecx)
f01044a3:	41                   	inc    %ecx
f01044a4:	4a                   	dec    %edx
f01044a5:	79 fa                	jns    f01044a1 <memset+0x12>

	return v;
}
f01044a7:	89 d8                	mov    %ebx,%eax
f01044a9:	5b                   	pop    %ebx
f01044aa:	5d                   	pop    %ebp
f01044ab:	c3                   	ret    

f01044ac <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
f01044af:	56                   	push   %esi
f01044b0:	53                   	push   %ebx
f01044b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01044b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f01044b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
f01044ba:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
f01044bc:	89 c8                	mov    %ecx,%eax
f01044be:	49                   	dec    %ecx
f01044bf:	85 c0                	test   %eax,%eax
f01044c1:	74 0d                	je     f01044d0 <memcpy+0x24>
		*d++ = *s++;
f01044c3:	8a 03                	mov    (%ebx),%al
f01044c5:	88 02                	mov    %al,(%edx)
f01044c7:	43                   	inc    %ebx
f01044c8:	42                   	inc    %edx
f01044c9:	89 c8                	mov    %ecx,%eax
f01044cb:	49                   	dec    %ecx
f01044cc:	85 c0                	test   %eax,%eax
f01044ce:	75 f3                	jne    f01044c3 <memcpy+0x17>

	return dst;
}
f01044d0:	89 f0                	mov    %esi,%eax
f01044d2:	5b                   	pop    %ebx
f01044d3:	5e                   	pop    %esi
f01044d4:	5d                   	pop    %ebp
f01044d5:	c3                   	ret    

f01044d6 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
f01044d6:	55                   	push   %ebp
f01044d7:	89 e5                	mov    %esp,%ebp
f01044d9:	56                   	push   %esi
f01044da:	53                   	push   %ebx
f01044db:	8b 75 08             	mov    0x8(%ebp),%esi
f01044de:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
f01044e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
f01044e4:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
f01044e6:	39 f1                	cmp    %esi,%ecx
f01044e8:	73 22                	jae    f010450c <memmove+0x36>
f01044ea:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f01044ed:	39 f0                	cmp    %esi,%eax
f01044ef:	76 1b                	jbe    f010450c <memmove+0x36>
		s += n;
f01044f1:	89 c1                	mov    %eax,%ecx
		d += n;
f01044f3:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
f01044f6:	89 d0                	mov    %edx,%eax
f01044f8:	4a                   	dec    %edx
f01044f9:	85 c0                	test   %eax,%eax
f01044fb:	74 23                	je     f0104520 <memmove+0x4a>
			*--d = *--s;
f01044fd:	4b                   	dec    %ebx
f01044fe:	49                   	dec    %ecx
f01044ff:	8a 01                	mov    (%ecx),%al
f0104501:	88 03                	mov    %al,(%ebx)
f0104503:	89 d0                	mov    %edx,%eax
f0104505:	4a                   	dec    %edx
f0104506:	85 c0                	test   %eax,%eax
f0104508:	75 f3                	jne    f01044fd <memmove+0x27>
f010450a:	eb 14                	jmp    f0104520 <memmove+0x4a>
	} else
		while (n-- > 0)
f010450c:	89 d0                	mov    %edx,%eax
f010450e:	4a                   	dec    %edx
f010450f:	85 c0                	test   %eax,%eax
f0104511:	74 0d                	je     f0104520 <memmove+0x4a>
			*d++ = *s++;
f0104513:	8a 01                	mov    (%ecx),%al
f0104515:	88 03                	mov    %al,(%ebx)
f0104517:	41                   	inc    %ecx
f0104518:	43                   	inc    %ebx
f0104519:	89 d0                	mov    %edx,%eax
f010451b:	4a                   	dec    %edx
f010451c:	85 c0                	test   %eax,%eax
f010451e:	75 f3                	jne    f0104513 <memmove+0x3d>

	return dst;
}
f0104520:	89 f0                	mov    %esi,%eax
f0104522:	5b                   	pop    %ebx
f0104523:	5e                   	pop    %esi
f0104524:	5d                   	pop    %ebp
f0104525:	c3                   	ret    

f0104526 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
f0104526:	55                   	push   %ebp
f0104527:	89 e5                	mov    %esp,%ebp
f0104529:	53                   	push   %ebx
f010452a:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
f010452d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
f0104530:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
f0104533:	89 d0                	mov    %edx,%eax
f0104535:	4a                   	dec    %edx
f0104536:	85 c0                	test   %eax,%eax
f0104538:	74 23                	je     f010455d <memcmp+0x37>
		if (*s1 != *s2)
f010453a:	8a 01                	mov    (%ecx),%al
f010453c:	3a 03                	cmp    (%ebx),%al
f010453e:	74 14                	je     f0104554 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
f0104540:	ba 00 00 00 00       	mov    $0x0,%edx
f0104545:	8a 11                	mov    (%ecx),%dl
f0104547:	b8 00 00 00 00       	mov    $0x0,%eax
f010454c:	8a 03                	mov    (%ebx),%al
f010454e:	29 c2                	sub    %eax,%edx
f0104550:	89 d0                	mov    %edx,%eax
f0104552:	eb 0e                	jmp    f0104562 <memcmp+0x3c>
		s1++, s2++;
f0104554:	41                   	inc    %ecx
f0104555:	43                   	inc    %ebx
f0104556:	89 d0                	mov    %edx,%eax
f0104558:	4a                   	dec    %edx
f0104559:	85 c0                	test   %eax,%eax
f010455b:	75 dd                	jne    f010453a <memcmp+0x14>
	}

	return 0;
f010455d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104562:	5b                   	pop    %ebx
f0104563:	5d                   	pop    %ebp
f0104564:	c3                   	ret    

f0104565 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
f0104565:	55                   	push   %ebp
f0104566:	89 e5                	mov    %esp,%ebp
f0104568:	8b 45 08             	mov    0x8(%ebp),%eax
f010456b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010456e:	89 c2                	mov    %eax,%edx
f0104570:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104573:	39 d0                	cmp    %edx,%eax
f0104575:	73 09                	jae    f0104580 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104577:	38 08                	cmp    %cl,(%eax)
f0104579:	74 05                	je     f0104580 <memfind+0x1b>
f010457b:	40                   	inc    %eax
f010457c:	39 d0                	cmp    %edx,%eax
f010457e:	72 f7                	jb     f0104577 <memfind+0x12>
			break;
	return (void *) s;
}
f0104580:	5d                   	pop    %ebp
f0104581:	c3                   	ret    

f0104582 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104582:	55                   	push   %ebp
f0104583:	89 e5                	mov    %esp,%ebp
f0104585:	57                   	push   %edi
f0104586:	56                   	push   %esi
f0104587:	53                   	push   %ebx
f0104588:	83 ec 04             	sub    $0x4,%esp
f010458b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010458e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104591:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
f0104594:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
f010459b:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01045a0:	80 39 20             	cmpb   $0x20,(%ecx)
f01045a3:	0f 94 c2             	sete   %dl
f01045a6:	80 39 09             	cmpb   $0x9,(%ecx)
f01045a9:	0f 94 c0             	sete   %al
f01045ac:	09 d0                	or     %edx,%eax
f01045ae:	a8 01                	test   $0x1,%al
f01045b0:	74 13                	je     f01045c5 <strtol+0x43>
		s++;
f01045b2:	41                   	inc    %ecx
f01045b3:	80 39 20             	cmpb   $0x20,(%ecx)
f01045b6:	0f 94 c2             	sete   %dl
f01045b9:	80 39 09             	cmpb   $0x9,(%ecx)
f01045bc:	0f 94 c0             	sete   %al
f01045bf:	09 d0                	or     %edx,%eax
f01045c1:	a8 01                	test   $0x1,%al
f01045c3:	75 ed                	jne    f01045b2 <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
f01045c5:	80 39 2b             	cmpb   $0x2b,(%ecx)
f01045c8:	75 03                	jne    f01045cd <strtol+0x4b>
		s++;
f01045ca:	41                   	inc    %ecx
f01045cb:	eb 0d                	jmp    f01045da <strtol+0x58>
	else if (*s == '-')
f01045cd:	80 39 2d             	cmpb   $0x2d,(%ecx)
f01045d0:	75 08                	jne    f01045da <strtol+0x58>
		s++, neg = 1;
f01045d2:	41                   	inc    %ecx
f01045d3:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01045da:	85 db                	test   %ebx,%ebx
f01045dc:	0f 94 c2             	sete   %dl
f01045df:	83 fb 10             	cmp    $0x10,%ebx
f01045e2:	0f 94 c0             	sete   %al
f01045e5:	09 d0                	or     %edx,%eax
f01045e7:	a8 01                	test   $0x1,%al
f01045e9:	74 15                	je     f0104600 <strtol+0x7e>
f01045eb:	80 39 30             	cmpb   $0x30,(%ecx)
f01045ee:	75 10                	jne    f0104600 <strtol+0x7e>
f01045f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01045f4:	75 0a                	jne    f0104600 <strtol+0x7e>
		s += 2, base = 16;
f01045f6:	83 c1 02             	add    $0x2,%ecx
f01045f9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01045fe:	eb 1a                	jmp    f010461a <strtol+0x98>
	else if (base == 0 && s[0] == '0')
f0104600:	85 db                	test   %ebx,%ebx
f0104602:	75 16                	jne    f010461a <strtol+0x98>
f0104604:	80 39 30             	cmpb   $0x30,(%ecx)
f0104607:	75 08                	jne    f0104611 <strtol+0x8f>
		s++, base = 8;
f0104609:	41                   	inc    %ecx
f010460a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010460f:	eb 09                	jmp    f010461a <strtol+0x98>
	else if (base == 0)
f0104611:	85 db                	test   %ebx,%ebx
f0104613:	75 05                	jne    f010461a <strtol+0x98>
		base = 10;
f0104615:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010461a:	8a 01                	mov    (%ecx),%al
f010461c:	83 e8 30             	sub    $0x30,%eax
f010461f:	3c 09                	cmp    $0x9,%al
f0104621:	77 08                	ja     f010462b <strtol+0xa9>
			dig = *s - '0';
f0104623:	0f be 01             	movsbl (%ecx),%eax
f0104626:	83 e8 30             	sub    $0x30,%eax
f0104629:	eb 20                	jmp    f010464b <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
f010462b:	8a 01                	mov    (%ecx),%al
f010462d:	83 e8 61             	sub    $0x61,%eax
f0104630:	3c 19                	cmp    $0x19,%al
f0104632:	77 08                	ja     f010463c <strtol+0xba>
			dig = *s - 'a' + 10;
f0104634:	0f be 01             	movsbl (%ecx),%eax
f0104637:	83 e8 57             	sub    $0x57,%eax
f010463a:	eb 0f                	jmp    f010464b <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
f010463c:	8a 01                	mov    (%ecx),%al
f010463e:	83 e8 41             	sub    $0x41,%eax
f0104641:	3c 19                	cmp    $0x19,%al
f0104643:	77 12                	ja     f0104657 <strtol+0xd5>
			dig = *s - 'A' + 10;
f0104645:	0f be 01             	movsbl (%ecx),%eax
f0104648:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f010464b:	39 d8                	cmp    %ebx,%eax
f010464d:	7d 08                	jge    f0104657 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
f010464f:	41                   	inc    %ecx
f0104650:	0f af f3             	imul   %ebx,%esi
f0104653:	01 c6                	add    %eax,%esi
f0104655:	eb c3                	jmp    f010461a <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104657:	85 ff                	test   %edi,%edi
f0104659:	74 02                	je     f010465d <strtol+0xdb>
		*endptr = (char *) s;
f010465b:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
f010465d:	89 f0                	mov    %esi,%eax
f010465f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104663:	74 02                	je     f0104667 <strtol+0xe5>
f0104665:	f7 d8                	neg    %eax
}
f0104667:	83 c4 04             	add    $0x4,%esp
f010466a:	5b                   	pop    %ebx
f010466b:	5e                   	pop    %esi
f010466c:	5f                   	pop    %edi
f010466d:	5d                   	pop    %ebp
f010466e:	c3                   	ret    

f010466f <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
f010466f:	55                   	push   %ebp
f0104670:	89 e5                	mov    %esp,%ebp
f0104672:	57                   	push   %edi
f0104673:	56                   	push   %esi
f0104674:	53                   	push   %ebx
f0104675:	83 ec 04             	sub    $0x4,%esp
f0104678:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010467b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010467e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
f0104681:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
f0104688:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010468d:	80 39 20             	cmpb   $0x20,(%ecx)
f0104690:	0f 94 c2             	sete   %dl
f0104693:	80 39 09             	cmpb   $0x9,(%ecx)
f0104696:	0f 94 c0             	sete   %al
f0104699:	09 d0                	or     %edx,%eax
f010469b:	a8 01                	test   $0x1,%al
f010469d:	74 13                	je     f01046b2 <strtoul+0x43>
		s++;
f010469f:	41                   	inc    %ecx
f01046a0:	80 39 20             	cmpb   $0x20,(%ecx)
f01046a3:	0f 94 c2             	sete   %dl
f01046a6:	80 39 09             	cmpb   $0x9,(%ecx)
f01046a9:	0f 94 c0             	sete   %al
f01046ac:	09 d0                	or     %edx,%eax
f01046ae:	a8 01                	test   $0x1,%al
f01046b0:	75 ed                	jne    f010469f <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
f01046b2:	80 39 2b             	cmpb   $0x2b,(%ecx)
f01046b5:	75 03                	jne    f01046ba <strtoul+0x4b>
		s++;
f01046b7:	41                   	inc    %ecx
f01046b8:	eb 0d                	jmp    f01046c7 <strtoul+0x58>
	else if (*s == '-')
f01046ba:	80 39 2d             	cmpb   $0x2d,(%ecx)
f01046bd:	75 08                	jne    f01046c7 <strtoul+0x58>
		s++, neg = 1;
f01046bf:	41                   	inc    %ecx
f01046c0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01046c7:	85 db                	test   %ebx,%ebx
f01046c9:	0f 94 c2             	sete   %dl
f01046cc:	83 fb 10             	cmp    $0x10,%ebx
f01046cf:	0f 94 c0             	sete   %al
f01046d2:	09 d0                	or     %edx,%eax
f01046d4:	a8 01                	test   $0x1,%al
f01046d6:	74 15                	je     f01046ed <strtoul+0x7e>
f01046d8:	80 39 30             	cmpb   $0x30,(%ecx)
f01046db:	75 10                	jne    f01046ed <strtoul+0x7e>
f01046dd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01046e1:	75 0a                	jne    f01046ed <strtoul+0x7e>
		s += 2, base = 16;
f01046e3:	83 c1 02             	add    $0x2,%ecx
f01046e6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01046eb:	eb 1a                	jmp    f0104707 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
f01046ed:	85 db                	test   %ebx,%ebx
f01046ef:	75 16                	jne    f0104707 <strtoul+0x98>
f01046f1:	80 39 30             	cmpb   $0x30,(%ecx)
f01046f4:	75 08                	jne    f01046fe <strtoul+0x8f>
		s++, base = 8;
f01046f6:	41                   	inc    %ecx
f01046f7:	bb 08 00 00 00       	mov    $0x8,%ebx
f01046fc:	eb 09                	jmp    f0104707 <strtoul+0x98>
	else if (base == 0)
f01046fe:	85 db                	test   %ebx,%ebx
f0104700:	75 05                	jne    f0104707 <strtoul+0x98>
		base = 10;
f0104702:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104707:	8a 01                	mov    (%ecx),%al
f0104709:	83 e8 30             	sub    $0x30,%eax
f010470c:	3c 09                	cmp    $0x9,%al
f010470e:	77 08                	ja     f0104718 <strtoul+0xa9>
			dig = *s - '0';
f0104710:	0f be 01             	movsbl (%ecx),%eax
f0104713:	83 e8 30             	sub    $0x30,%eax
f0104716:	eb 20                	jmp    f0104738 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
f0104718:	8a 01                	mov    (%ecx),%al
f010471a:	83 e8 61             	sub    $0x61,%eax
f010471d:	3c 19                	cmp    $0x19,%al
f010471f:	77 08                	ja     f0104729 <strtoul+0xba>
			dig = *s - 'a' + 10;
f0104721:	0f be 01             	movsbl (%ecx),%eax
f0104724:	83 e8 57             	sub    $0x57,%eax
f0104727:	eb 0f                	jmp    f0104738 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
f0104729:	8a 01                	mov    (%ecx),%al
f010472b:	83 e8 41             	sub    $0x41,%eax
f010472e:	3c 19                	cmp    $0x19,%al
f0104730:	77 12                	ja     f0104744 <strtoul+0xd5>
			dig = *s - 'A' + 10;
f0104732:	0f be 01             	movsbl (%ecx),%eax
f0104735:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f0104738:	39 d8                	cmp    %ebx,%eax
f010473a:	7d 08                	jge    f0104744 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
f010473c:	41                   	inc    %ecx
f010473d:	0f af f3             	imul   %ebx,%esi
f0104740:	01 c6                	add    %eax,%esi
f0104742:	eb c3                	jmp    f0104707 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
f0104744:	85 ff                	test   %edi,%edi
f0104746:	74 02                	je     f010474a <strtoul+0xdb>
		*endptr = (char *) s;
f0104748:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
f010474a:	89 f0                	mov    %esi,%eax
f010474c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104750:	74 02                	je     f0104754 <strtoul+0xe5>
f0104752:	f7 d8                	neg    %eax
}
f0104754:	83 c4 04             	add    $0x4,%esp
f0104757:	5b                   	pop    %ebx
f0104758:	5e                   	pop    %esi
f0104759:	5f                   	pop    %edi
f010475a:	5d                   	pop    %ebp
f010475b:	c3                   	ret    

f010475c <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
f010475c:	55                   	push   %ebp
f010475d:	89 e5                	mov    %esp,%ebp
f010475f:	57                   	push   %edi
f0104760:	56                   	push   %esi
f0104761:	53                   	push   %ebx
f0104762:	83 ec 0c             	sub    $0xc,%esp
f0104765:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104768:	8b 75 0c             	mov    0xc(%ebp),%esi
f010476b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
f010476e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
f0104774:	8b 45 10             	mov    0x10(%ebp),%eax
f0104777:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f010477d:	eb 04                	jmp    f0104783 <strsplit+0x27>
			*string++ = 0;
f010477f:	c6 03 00             	movb   $0x0,(%ebx)
f0104782:	43                   	inc    %ebx
f0104783:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104786:	74 4b                	je     f01047d3 <strsplit+0x77>
f0104788:	83 ec 08             	sub    $0x8,%esp
f010478b:	0f be 03             	movsbl (%ebx),%eax
f010478e:	50                   	push   %eax
f010478f:	56                   	push   %esi
f0104790:	e8 bf fc ff ff       	call   f0104454 <strchr>
f0104795:	83 c4 10             	add    $0x10,%esp
f0104798:	85 c0                	test   %eax,%eax
f010479a:	75 e3                	jne    f010477f <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
f010479c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010479f:	74 32                	je     f01047d3 <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
f01047a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01047a6:	83 3f 0f             	cmpl   $0xf,(%edi)
f01047a9:	74 39                	je     f01047e4 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
f01047ab:	8b 07                	mov    (%edi),%eax
f01047ad:	8b 55 10             	mov    0x10(%ebp),%edx
f01047b0:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
f01047b3:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
f01047b5:	eb 01                	jmp    f01047b8 <strsplit+0x5c>
			string++;
f01047b7:	43                   	inc    %ebx
f01047b8:	80 3b 00             	cmpb   $0x0,(%ebx)
f01047bb:	74 16                	je     f01047d3 <strsplit+0x77>
f01047bd:	83 ec 08             	sub    $0x8,%esp
f01047c0:	0f be 03             	movsbl (%ebx),%eax
f01047c3:	50                   	push   %eax
f01047c4:	56                   	push   %esi
f01047c5:	e8 8a fc ff ff       	call   f0104454 <strchr>
f01047ca:	83 c4 10             	add    $0x10,%esp
f01047cd:	85 c0                	test   %eax,%eax
f01047cf:	74 e6                	je     f01047b7 <strsplit+0x5b>
f01047d1:	eb b0                	jmp    f0104783 <strsplit+0x27>
	}
	(argv)[*argc] = 0;
f01047d3:	8b 07                	mov    (%edi),%eax
f01047d5:	8b 55 10             	mov    0x10(%ebp),%edx
f01047d8:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
f01047df:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01047e4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01047e7:	5b                   	pop    %ebx
f01047e8:	5e                   	pop    %esi
f01047e9:	5f                   	pop    %edi
f01047ea:	5d                   	pop    %ebp
f01047eb:	c3                   	ret    
f01047ec:	00 00                	add    %al,(%eax)
	...

f01047f0 <__udivdi3>:
f01047f0:	55                   	push   %ebp
f01047f1:	89 e5                	mov    %esp,%ebp
f01047f3:	57                   	push   %edi
f01047f4:	56                   	push   %esi
f01047f5:	83 ec 20             	sub    $0x20,%esp
f01047f8:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f01047ff:	8b 75 08             	mov    0x8(%ebp),%esi
f0104802:	8b 55 14             	mov    0x14(%ebp),%edx
f0104805:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104808:	8b 45 10             	mov    0x10(%ebp),%eax
f010480b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
f010480e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0104815:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f0104818:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f010481b:	89 fe                	mov    %edi,%esi
f010481d:	85 d2                	test   %edx,%edx
f010481f:	75 2f                	jne    f0104850 <__udivdi3+0x60>
f0104821:	39 f8                	cmp    %edi,%eax
f0104823:	76 62                	jbe    f0104887 <__udivdi3+0x97>
f0104825:	89 fa                	mov    %edi,%edx
f0104827:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010482a:	f7 75 dc             	divl   0xffffffdc(%ebp)
f010482d:	89 c7                	mov    %eax,%edi
f010482f:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
f0104836:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0104839:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
f010483c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f010483f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104842:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0104845:	83 c4 20             	add    $0x20,%esp
f0104848:	5e                   	pop    %esi
f0104849:	5f                   	pop    %edi
f010484a:	5d                   	pop    %ebp
f010484b:	c3                   	ret    
f010484c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0104850:	31 ff                	xor    %edi,%edi
f0104852:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
f0104859:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
f010485c:	77 d8                	ja     f0104836 <__udivdi3+0x46>
f010485e:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
f0104862:	89 c7                	mov    %eax,%edi
f0104864:	83 f7 1f             	xor    $0x1f,%edi
f0104867:	75 5b                	jne    f01048c4 <__udivdi3+0xd4>
f0104869:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f010486c:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
f010486f:	0f 97 c2             	seta   %dl
f0104872:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
f0104875:	bf 01 00 00 00       	mov    $0x1,%edi
f010487a:	0f 93 c0             	setae  %al
f010487d:	09 d0                	or     %edx,%eax
f010487f:	a8 01                	test   $0x1,%al
f0104881:	75 ac                	jne    f010482f <__udivdi3+0x3f>
f0104883:	31 ff                	xor    %edi,%edi
f0104885:	eb a8                	jmp    f010482f <__udivdi3+0x3f>
f0104887:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010488a:	85 c0                	test   %eax,%eax
f010488c:	75 0e                	jne    f010489c <__udivdi3+0xac>
f010488e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104893:	31 c9                	xor    %ecx,%ecx
f0104895:	31 d2                	xor    %edx,%edx
f0104897:	f7 f1                	div    %ecx
f0104899:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f010489c:	89 f0                	mov    %esi,%eax
f010489e:	31 d2                	xor    %edx,%edx
f01048a0:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01048a3:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f01048a6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01048a9:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01048ac:	89 c7                	mov    %eax,%edi
f01048ae:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f01048b1:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
f01048b4:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f01048b7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01048ba:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01048bd:	83 c4 20             	add    $0x20,%esp
f01048c0:	5e                   	pop    %esi
f01048c1:	5f                   	pop    %edi
f01048c2:	5d                   	pop    %ebp
f01048c3:	c3                   	ret    
f01048c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01048c9:	89 f9                	mov    %edi,%ecx
f01048cb:	29 f8                	sub    %edi,%eax
f01048cd:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f01048d0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f01048d3:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f01048d6:	d3 e2                	shl    %cl,%edx
f01048d8:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f01048db:	d3 e8                	shr    %cl,%eax
f01048dd:	09 c2                	or     %eax,%edx
f01048df:	89 f9                	mov    %edi,%ecx
f01048e1:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
f01048e4:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f01048e7:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f01048ea:	89 f2                	mov    %esi,%edx
f01048ec:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01048ef:	d3 ea                	shr    %cl,%edx
f01048f1:	89 f9                	mov    %edi,%ecx
f01048f3:	d3 e6                	shl    %cl,%esi
f01048f5:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f01048f8:	d3 e8                	shr    %cl,%eax
f01048fa:	09 c6                	or     %eax,%esi
f01048fc:	89 f9                	mov    %edi,%ecx
f01048fe:	89 f0                	mov    %esi,%eax
f0104900:	f7 75 ec             	divl   0xffffffec(%ebp)
f0104903:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
f0104906:	89 d6                	mov    %edx,%esi
f0104908:	89 c7                	mov    %eax,%edi
f010490a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010490d:	f7 e7                	mul    %edi
f010490f:	39 f2                	cmp    %esi,%edx
f0104911:	77 15                	ja     f0104928 <__udivdi3+0x138>
f0104913:	39 f2                	cmp    %esi,%edx
f0104915:	0f 94 c2             	sete   %dl
f0104918:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f010491b:	0f 97 c0             	seta   %al
f010491e:	21 d0                	and    %edx,%eax
f0104920:	a8 01                	test   $0x1,%al
f0104922:	0f 84 07 ff ff ff    	je     f010482f <__udivdi3+0x3f>
f0104928:	4f                   	dec    %edi
f0104929:	e9 01 ff ff ff       	jmp    f010482f <__udivdi3+0x3f>
f010492e:	90                   	nop    
f010492f:	90                   	nop    

f0104930 <__umoddi3>:
f0104930:	55                   	push   %ebp
f0104931:	89 e5                	mov    %esp,%ebp
f0104933:	57                   	push   %edi
f0104934:	56                   	push   %esi
f0104935:	83 ec 38             	sub    $0x38,%esp
f0104938:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
f010493b:	8b 55 14             	mov    0x14(%ebp),%edx
f010493e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104941:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104944:	8b 45 10             	mov    0x10(%ebp),%eax
f0104947:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
f010494e:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f0104955:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f0104958:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
f010495b:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f010495e:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
f0104961:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
f0104964:	85 d2                	test   %edx,%edx
f0104966:	75 48                	jne    f01049b0 <__umoddi3+0x80>
f0104968:	39 f8                	cmp    %edi,%eax
f010496a:	0f 86 d0 00 00 00    	jbe    f0104a40 <__umoddi3+0x110>
f0104970:	89 f0                	mov    %esi,%eax
f0104972:	89 fa                	mov    %edi,%edx
f0104974:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104977:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
f010497a:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
f010497d:	85 f6                	test   %esi,%esi
f010497f:	74 49                	je     f01049ca <__umoddi3+0x9a>
f0104981:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104984:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f010498b:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f010498e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0104991:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f0104994:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f0104997:	89 10                	mov    %edx,(%eax)
f0104999:	89 48 04             	mov    %ecx,0x4(%eax)
f010499c:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f010499f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01049a2:	83 c4 38             	add    $0x38,%esp
f01049a5:	5e                   	pop    %esi
f01049a6:	5f                   	pop    %edi
f01049a7:	5d                   	pop    %ebp
f01049a8:	c3                   	ret    
f01049a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f01049b0:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f01049b3:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
f01049b6:	76 1f                	jbe    f01049d7 <__umoddi3+0xa7>
f01049b8:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
f01049bb:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f01049be:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01049c1:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f01049c4:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f01049c7:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f01049ca:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01049cd:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01049d0:	83 c4 38             	add    $0x38,%esp
f01049d3:	5e                   	pop    %esi
f01049d4:	5f                   	pop    %edi
f01049d5:	5d                   	pop    %ebp
f01049d6:	c3                   	ret    
f01049d7:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
f01049db:	83 f0 1f             	xor    $0x1f,%eax
f01049de:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
f01049e1:	0f 85 89 00 00 00    	jne    f0104a70 <__umoddi3+0x140>
f01049e7:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f01049ea:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f01049ed:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
f01049f0:	0f 97 c2             	seta   %dl
f01049f3:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
f01049f6:	0f 93 c0             	setae  %al
f01049f9:	09 d0                	or     %edx,%eax
f01049fb:	a8 01                	test   $0x1,%al
f01049fd:	74 11                	je     f0104a10 <__umoddi3+0xe0>
f01049ff:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104a02:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104a05:	29 c8                	sub    %ecx,%eax
f0104a07:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
f0104a0a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104a0d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0104a10:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0104a13:	85 c9                	test   %ecx,%ecx
f0104a15:	74 b3                	je     f01049ca <__umoddi3+0x9a>
f0104a17:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104a1a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104a1d:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0104a20:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0104a23:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f0104a26:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0104a29:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f0104a2c:	89 01                	mov    %eax,(%ecx)
f0104a2e:	89 51 04             	mov    %edx,0x4(%ecx)
f0104a31:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104a34:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0104a37:	83 c4 38             	add    $0x38,%esp
f0104a3a:	5e                   	pop    %esi
f0104a3b:	5f                   	pop    %edi
f0104a3c:	5d                   	pop    %ebp
f0104a3d:	c3                   	ret    
f0104a3e:	89 f6                	mov    %esi,%esi
f0104a40:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
f0104a43:	85 ff                	test   %edi,%edi
f0104a45:	75 0d                	jne    f0104a54 <__umoddi3+0x124>
f0104a47:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a4c:	31 d2                	xor    %edx,%edx
f0104a4e:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104a51:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
f0104a54:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0104a57:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0104a5a:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104a5d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104a60:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104a63:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104a66:	e9 0c ff ff ff       	jmp    f0104977 <__umoddi3+0x47>
f0104a6b:	90                   	nop    
f0104a6c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0104a70:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f0104a73:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a78:	29 d0                	sub    %edx,%eax
f0104a7a:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104a7d:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f0104a80:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f0104a83:	d3 e2                	shl    %cl,%edx
f0104a85:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f0104a88:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0104a8b:	d3 e8                	shr    %cl,%eax
f0104a8d:	09 c2                	or     %eax,%edx
f0104a8f:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104a92:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
f0104a95:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f0104a98:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0104a9b:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104a9e:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
f0104aa1:	d3 ea                	shr    %cl,%edx
f0104aa3:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104aa6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104aa9:	d3 e6                	shl    %cl,%esi
f0104aab:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0104aae:	d3 e8                	shr    %cl,%eax
f0104ab0:	09 c6                	or     %eax,%esi
f0104ab2:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104ab5:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
f0104ab8:	89 f0                	mov    %esi,%eax
f0104aba:	f7 75 dc             	divl   0xffffffdc(%ebp)
f0104abd:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
f0104ac0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104ac3:	f7 65 c4             	mull   0xffffffc4(%ebp)
f0104ac6:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f0104ac9:	89 d6                	mov    %edx,%esi
f0104acb:	89 c7                	mov    %eax,%edi
f0104acd:	77 12                	ja     f0104ae1 <__umoddi3+0x1b1>
f0104acf:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f0104ad2:	0f 94 c2             	sete   %dl
f0104ad5:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
f0104ad8:	0f 97 c0             	seta   %al
f0104adb:	21 d0                	and    %edx,%eax
f0104add:	a8 01                	test   $0x1,%al
f0104adf:	74 06                	je     f0104ae7 <__umoddi3+0x1b7>
f0104ae1:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
f0104ae4:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
f0104ae7:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0104aea:	85 c0                	test   %eax,%eax
f0104aec:	0f 84 d8 fe ff ff    	je     f01049ca <__umoddi3+0x9a>
f0104af2:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0104af5:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104af8:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104afb:	29 f8                	sub    %edi,%eax
f0104afd:	19 f2                	sbb    %esi,%edx
f0104aff:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104b02:	d3 e2                	shl    %cl,%edx
f0104b04:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104b07:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0104b0a:	d3 e8                	shr    %cl,%eax
f0104b0c:	09 c2                	or     %eax,%edx
f0104b0e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0104b11:	d3 e8                	shr    %cl,%eax
f0104b13:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
f0104b16:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0104b19:	e9 70 fe ff ff       	jmp    f010498e <__umoddi3+0x5e>
f0104b1e:	90                   	nop    
f0104b1f:	90                   	nop    
