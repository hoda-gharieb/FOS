
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
f0100015:	0f 01 15 18 d0 11 00 	lgdtl  0x11d018

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
f0100033:	bc bc cf 11 f0       	mov    $0xf011cfbc,%esp

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
f0100046:	b8 d4 f5 1b f0       	mov    $0xf01bf5d4,%eax
f010004b:	2d 57 71 18 f0       	sub    $0xf0187157,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 57 71 18 f0       	push   $0xf0187157
f0100058:	e8 52 3f 00 00       	call   f0103faf <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	console_initialize();
f010005d:	e8 d5 05 00 00       	call   f0100637 <console_initialize>

	//print welcome message
	print_welcome_message();
f0100062:	e8 3d 00 00 00       	call   f01000a4 <print_welcome_message>

	// Lab 2 memory management initialization functions
	detect_memory();
f0100067:	e8 ba 14 00 00       	call   f0101526 <detect_memory>
	initialize_kernel_VM();
f010006c:	e8 b7 20 00 00       	call   f0102128 <initialize_kernel_VM>
	initialize_paging();
f0100071:	e8 57 23 00 00       	call   f01023cd <initialize_paging>
	page_check();
f0100076:	e8 65 17 00 00       	call   f01017e0 <page_check>

	
	// Lab 3 user environment initialization functions
	env_init();
f010007b:	e8 64 29 00 00       	call   f01029e4 <env_init>
	idt_init();
f0100080:	e8 b4 2e 00 00       	call   f0102f39 <idt_init>

	
	// start the kernel command prompt.
	while (1==1)
	{
		cprintf("\nWelcome to the FOS kernel command prompt!\n");
f0100085:	c7 04 24 40 46 10 f0 	movl   $0xf0104640,(%esp)
f010008c:	e8 6d 2e 00 00       	call   f0102efe <cprintf>
		cprintf("Type 'help' for a list of commands.\n");	
f0100091:	c7 04 24 80 46 10 f0 	movl   $0xf0104680,(%esp)
f0100098:	e8 61 2e 00 00       	call   f0102efe <cprintf>
		run_command_prompt();
f010009d:	e8 c1 08 00 00       	call   f0100963 <run_command_prompt>
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
f01000aa:	68 c6 47 10 f0       	push   $0xf01047c6
f01000af:	e8 4a 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000b4:	c7 04 24 c0 46 10 f0 	movl   $0xf01046c0,(%esp)
f01000bb:	e8 3e 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\t\t!!                                                             !!\n");
f01000c0:	c7 04 24 20 47 10 f0 	movl   $0xf0104720,(%esp)
f01000c7:	e8 32 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\t\t!!                   !! FCIS says HELLO !!                     !!\n");
f01000cc:	c7 04 24 80 47 10 f0 	movl   $0xf0104780,(%esp)
f01000d3:	e8 26 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\t\t!!                                                             !!\n");
f01000d8:	c7 04 24 20 47 10 f0 	movl   $0xf0104720,(%esp)
f01000df:	e8 1a 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000e4:	c7 04 24 c0 46 10 f0 	movl   $0xf01046c0,(%esp)
f01000eb:	e8 0e 2e 00 00       	call   f0102efe <cprintf>
	cprintf("\n\n\n\n");	
f01000f0:	c7 04 24 c5 47 10 f0 	movl   $0xf01047c5,(%esp)
f01000f7:	e8 02 2e 00 00       	call   f0102efe <cprintf>
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
f0100105:	83 3d 60 71 18 f0 00 	cmpl   $0x0,0xf0187160
f010010c:	75 39                	jne    f0100147 <_panic+0x49>
		goto dead;
	panicstr = fmt;
f010010e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100111:	a3 60 71 18 f0       	mov    %eax,0xf0187160

	va_start(ap, fmt);
f0100116:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100119:	83 ec 04             	sub    $0x4,%esp
f010011c:	ff 75 0c             	pushl  0xc(%ebp)
f010011f:	ff 75 08             	pushl  0x8(%ebp)
f0100122:	68 ca 47 10 f0       	push   $0xf01047ca
f0100127:	e8 d2 2d 00 00       	call   f0102efe <cprintf>
	vcprintf(fmt, ap);
f010012c:	83 c4 08             	add    $0x8,%esp
f010012f:	53                   	push   %ebx
f0100130:	ff 75 10             	pushl  0x10(%ebp)
f0100133:	e8 a0 2d 00 00       	call   f0102ed8 <vcprintf>
	cprintf("\n");
f0100138:	c7 04 24 c8 47 10 f0 	movl   $0xf01047c8,(%esp)
f010013f:	e8 ba 2d 00 00       	call   f0102efe <cprintf>
	va_end(ap);
f0100144:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel command prompt */
	while (1==1)
		run_command_prompt();
f0100147:	e8 17 08 00 00       	call   f0100963 <run_command_prompt>
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
f010015e:	68 e2 47 10 f0       	push   $0xf01047e2
f0100163:	e8 96 2d 00 00       	call   f0102efe <cprintf>
	vcprintf(fmt, ap);
f0100168:	83 c4 08             	add    $0x8,%esp
f010016b:	53                   	push   %ebx
f010016c:	ff 75 10             	pushl  0x10(%ebp)
f010016f:	e8 64 2d 00 00       	call   f0102ed8 <vcprintf>
	cprintf("\n");
f0100174:	c7 04 24 c8 47 10 f0 	movl   $0xf01047c8,(%esp)
f010017b:	e8 7e 2d 00 00       	call   f0102efe <cprintf>
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
f01001b1:	83 3d 84 71 18 f0 00 	cmpl   $0x0,0xf0187184
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
f010021c:	a3 84 71 18 f0       	mov    %eax,0xf0187184
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
f01002aa:	c7 05 88 71 18 f0 b4 	movl   $0x3b4,0xf0187188
f01002b1:	03 00 00 
f01002b4:	eb 0d                	jmp    f01002c3 <cga_init+0x45>
	} else {
		*cp = was;
f01002b6:	66 89 16             	mov    %dx,(%esi)
		addr_6845 = CGA_BASE;
f01002b9:	c7 05 88 71 18 f0 d4 	movl   $0x3d4,0xf0187188
f01002c0:	03 00 00 
}

static __inline void
outb(int port, uint8 data)
{
f01002c3:	8b 0d 88 71 18 f0    	mov    0xf0187188,%ecx
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
f01002ed:	89 35 8c 71 18 f0    	mov    %esi,0xf018718c
	crt_pos = pos;
f01002f3:	66 89 1d 90 71 18 f0 	mov    %bx,0xf0187190
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
f010033a:	66 83 3d 90 71 18 f0 	cmpw   $0x0,0xf0187190
f0100341:	00 
f0100342:	0f 84 ae 00 00 00    	je     f01003f6 <cga_putc+0xf7>
			crt_pos--;
f0100348:	66 a1 90 71 18 f0    	mov    0xf0187190,%ax
f010034e:	48                   	dec    %eax
f010034f:	66 a3 90 71 18 f0    	mov    %ax,0xf0187190
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100355:	25 ff ff 00 00       	and    $0xffff,%eax
f010035a:	89 ca                	mov    %ecx,%edx
f010035c:	b2 00                	mov    $0x0,%dl
f010035e:	83 ca 20             	or     $0x20,%edx
f0100361:	8b 0d 8c 71 18 f0    	mov    0xf018718c,%ecx
f0100367:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
		}
		break;
f010036b:	e9 86 00 00 00       	jmp    f01003f6 <cga_putc+0xf7>
	case '\n':
		crt_pos += CRT_COLS;
f0100370:	66 83 05 90 71 18 f0 	addw   $0x50,0xf0187190
f0100377:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100378:	66 8b 1d 90 71 18 f0 	mov    0xf0187190,%bx
f010037f:	b9 50 00 00 00       	mov    $0x50,%ecx
f0100384:	ba 00 00 00 00       	mov    $0x0,%edx
f0100389:	89 d8                	mov    %ebx,%eax
f010038b:	66 f7 f1             	div    %cx
f010038e:	89 d8                	mov    %ebx,%eax
f0100390:	66 29 d0             	sub    %dx,%ax
f0100393:	66 a3 90 71 18 f0    	mov    %ax,0xf0187190
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
f01003da:	66 a1 90 71 18 f0    	mov    0xf0187190,%ax
f01003e0:	25 ff ff 00 00       	and    $0xffff,%eax
f01003e5:	8b 15 8c 71 18 f0    	mov    0xf018718c,%edx
f01003eb:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01003ef:	66 ff 05 90 71 18 f0 	incw   0xf0187190
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003f6:	66 81 3d 90 71 18 f0 	cmpw   $0x7cf,0xf0187190
f01003fd:	cf 07 
f01003ff:	76 3f                	jbe    f0100440 <cga_putc+0x141>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
f0100401:	83 ec 04             	sub    $0x4,%esp
f0100404:	68 00 0f 00 00       	push   $0xf00
f0100409:	8b 15 8c 71 18 f0    	mov    0xf018718c,%edx
f010040f:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100415:	50                   	push   %eax
f0100416:	52                   	push   %edx
f0100417:	e8 b0 3b 00 00       	call   f0103fcc <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010041c:	ba 80 07 00 00       	mov    $0x780,%edx
f0100421:	83 c4 10             	add    $0x10,%esp
			crt_buf[i] = 0x0700 | ' ';
f0100424:	a1 8c 71 18 f0       	mov    0xf018718c,%eax
f0100429:	66 c7 04 50 20 07    	movw   $0x720,(%eax,%edx,2)
f010042f:	42                   	inc    %edx
f0100430:	81 fa cf 07 00 00    	cmp    $0x7cf,%edx
f0100436:	7e ec                	jle    f0100424 <cga_putc+0x125>
		crt_pos -= CRT_COLS;
f0100438:	66 83 2d 90 71 18 f0 	subw   $0x50,0xf0187190
f010043f:	50 
}

static __inline void
outb(int port, uint8 data)
{
f0100440:	8b 1d 88 71 18 f0    	mov    0xf0187188,%ebx
f0100446:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100448:	89 da                	mov    %ebx,%edx
f010044a:	ee                   	out    %al,(%dx)
f010044b:	8d 4b 01             	lea    0x1(%ebx),%ecx
f010044e:	a0 91 71 18 f0       	mov    0xf0187191,%al
f0100453:	89 ca                	mov    %ecx,%edx
f0100455:	ee                   	out    %al,(%dx)
f0100456:	b0 0f                	mov    $0xf,%al
f0100458:	89 da                	mov    %ebx,%edx
f010045a:	ee                   	out    %al,(%dx)
f010045b:	a0 90 71 18 f0       	mov    0xf0187190,%al
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
f010048e:	83 0d 80 71 18 f0 40 	orl    $0x40,0xf0187180
		return 0;
f0100495:	eb 2d                	jmp    f01004c4 <kbd_proc_data+0x5c>
	} else if (data & 0x80) {
f0100497:	84 c0                	test   %al,%al
f0100499:	79 33                	jns    f01004ce <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010049b:	f6 05 80 71 18 f0 40 	testb  $0x40,0xf0187180
f01004a2:	75 03                	jne    f01004a7 <kbd_proc_data+0x3f>
f01004a4:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01004a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ac:	88 d0                	mov    %dl,%al
f01004ae:	8a 80 20 d0 11 f0    	mov    0xf011d020(%eax),%al
f01004b4:	83 c8 40             	or     $0x40,%eax
f01004b7:	25 ff 00 00 00       	and    $0xff,%eax
f01004bc:	f7 d0                	not    %eax
f01004be:	21 05 80 71 18 f0    	and    %eax,0xf0187180
		return 0;
f01004c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01004c9:	e9 a5 00 00 00       	jmp    f0100573 <kbd_proc_data+0x10b>
	} else if (shift & E0ESC) {
f01004ce:	a1 80 71 18 f0       	mov    0xf0187180,%eax
f01004d3:	a8 40                	test   $0x40,%al
f01004d5:	74 0b                	je     f01004e2 <kbd_proc_data+0x7a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004d7:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01004da:	83 e0 bf             	and    $0xffffffbf,%eax
f01004dd:	a3 80 71 18 f0       	mov    %eax,0xf0187180
	}

	shift |= shiftcode[data];
f01004e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004e7:	88 d1                	mov    %dl,%cl
f01004e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ee:	8a 81 20 d0 11 f0    	mov    0xf011d020(%ecx),%al
f01004f4:	0b 05 80 71 18 f0    	or     0xf0187180,%eax
	shift ^= togglecode[data];
f01004fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01004ff:	8a 91 20 d1 11 f0    	mov    0xf011d120(%ecx),%dl
f0100505:	31 c2                	xor    %eax,%edx
f0100507:	89 15 80 71 18 f0    	mov    %edx,0xf0187180

	c = charcode[shift & (CTL | SHIFT)][data];
f010050d:	89 d0                	mov    %edx,%eax
f010050f:	83 e0 03             	and    $0x3,%eax
f0100512:	8b 04 85 20 d5 11 f0 	mov    0xf011d520(,%eax,4),%eax
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
f010053e:	a1 80 71 18 f0       	mov    0xf0187180,%eax
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
f010055c:	68 fc 47 10 f0       	push   $0xf01047fc
f0100561:	e8 98 29 00 00       	call   f0102efe <cprintf>
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
f01005a1:	a1 a4 73 18 f0       	mov    0xf01873a4,%eax
f01005a6:	88 90 a0 71 18 f0    	mov    %dl,0xf01871a0(%eax)
f01005ac:	40                   	inc    %eax
f01005ad:	a3 a4 73 18 f0       	mov    %eax,0xf01873a4
		if (cons.wpos == CONSBUFSIZE)
f01005b2:	3d 00 02 00 00       	cmp    $0x200,%eax
f01005b7:	75 0a                	jne    f01005c3 <cons_intr+0x32>
			cons.wpos = 0;
f01005b9:	c7 05 a4 73 18 f0 00 	movl   $0x0,0xf01873a4
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
f01005e2:	a1 a0 73 18 f0       	mov    0xf01873a0,%eax
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01005e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01005ec:	3b 05 a4 73 18 f0    	cmp    0xf01873a4,%eax
f01005f2:	74 22                	je     f0100616 <cons_getc+0x44>
f01005f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01005f9:	8a 90 a0 71 18 f0    	mov    0xf01871a0(%eax),%dl
f01005ff:	40                   	inc    %eax
f0100600:	a3 a0 73 18 f0       	mov    %eax,0xf01873a0
f0100605:	3d 00 02 00 00       	cmp    $0x200,%eax
f010060a:	75 0a                	jne    f0100616 <cons_getc+0x44>
f010060c:	c7 05 a0 73 18 f0 00 	movl   $0x0,0xf01873a0
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
f010064c:	83 3d 84 71 18 f0 00 	cmpl   $0x0,0xf0187184
f0100653:	75 10                	jne    f0100665 <console_initialize+0x2e>
		cprintf("Serial port does not exist!\n");
f0100655:	83 ec 0c             	sub    $0xc,%esp
f0100658:	68 08 48 10 f0       	push   $0xf0104808
f010065d:	e8 9c 28 00 00       	call   f0102efe <cprintf>
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

f0100694 <read_string>:
				"check new and delete", check_new_delete, 1 }, { "search",
				"search for a hexa value in memory", command_search, 3 }, };

//invoke the command prompt
void read_string(char *line) {
f0100694:	55                   	push   %ebp
f0100695:	89 e5                	mov    %esp,%ebp
f0100697:	57                   	push   %edi
f0100698:	56                   	push   %esi
f0100699:	53                   	push   %ebx
f010069a:	81 ec 18 04 00 00    	sub    $0x418,%esp
	char c;
	int i = 0;
f01006a0:	bf 00 00 00 00       	mov    $0x0,%edi
	cprintf("FOS> ");
f01006a5:	68 5c 49 10 f0       	push   $0xf010495c
f01006aa:	e8 4f 28 00 00       	call   f0102efe <cprintf>
	while ((c = getchar()) && c != '\n') {
f01006af:	83 c4 10             	add    $0x10,%esp
f01006b2:	e9 8a 02 00 00       	jmp    f0100941 <read_string+0x2ad>
		//cprintf("%c",c);
		if ((int) c == -30 || (int) c == -29) {
f01006b7:	8d 46 1e             	lea    0x1e(%esi),%eax
f01006ba:	3c 01                	cmp    $0x1,%al
f01006bc:	0f 87 d3 00 00 00    	ja     f0100795 <read_string+0x101>
			int k;
			for (k = 0; k < i; k++)
f01006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006c7:	39 fb                	cmp    %edi,%ebx
f01006c9:	7d 51                	jge    f010071c <read_string+0x88>
				cprintf("\b");
f01006cb:	83 ec 0c             	sub    $0xc,%esp
f01006ce:	68 62 49 10 f0       	push   $0xf0104962
f01006d3:	e8 26 28 00 00       	call   f0102efe <cprintf>
f01006d8:	83 c4 10             	add    $0x10,%esp
f01006db:	43                   	inc    %ebx
f01006dc:	39 fb                	cmp    %edi,%ebx
f01006de:	7c eb                	jl     f01006cb <read_string+0x37>
			for (k = 0; k < i; k++)
f01006e0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e5:	39 fb                	cmp    %edi,%ebx
f01006e7:	7d 33                	jge    f010071c <read_string+0x88>
				cprintf(" ");
f01006e9:	83 ec 0c             	sub    $0xc,%esp
f01006ec:	68 6c 49 10 f0       	push   $0xf010496c
f01006f1:	e8 08 28 00 00       	call   f0102efe <cprintf>
f01006f6:	83 c4 10             	add    $0x10,%esp
f01006f9:	43                   	inc    %ebx
f01006fa:	39 fb                	cmp    %edi,%ebx
f01006fc:	7c eb                	jl     f01006e9 <read_string+0x55>
			for (k = 0; k < i; k++)
f01006fe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100703:	39 fb                	cmp    %edi,%ebx
f0100705:	7d 15                	jge    f010071c <read_string+0x88>
				cprintf("\b");
f0100707:	83 ec 0c             	sub    $0xc,%esp
f010070a:	68 62 49 10 f0       	push   $0xf0104962
f010070f:	e8 ea 27 00 00       	call   f0102efe <cprintf>
f0100714:	83 c4 10             	add    $0x10,%esp
f0100717:	43                   	inc    %ebx
f0100718:	39 fb                	cmp    %edi,%ebx
f010071a:	7c eb                	jl     f0100707 <read_string+0x73>
			if ((int) c == -30) {
f010071c:	89 f0                	mov    %esi,%eax
f010071e:	3c e2                	cmp    $0xe2,%al
f0100720:	75 10                	jne    f0100732 <read_string+0x9e>

				if (Current_Command + 1 < Commands_count) {
f0100722:	a1 28 9d 1b f0       	mov    0xf01b9d28,%eax
f0100727:	40                   	inc    %eax
f0100728:	3b 05 2c 9d 1b f0    	cmp    0xf01b9d2c,%eax
f010072e:	7c 0a                	jl     f010073a <read_string+0xa6>
					Current_Command++;
					cprintf("%s", all_commands[Current_Command]);
f0100730:	eb 12                	jmp    f0100744 <read_string+0xb0>
				} else
					cprintf("%s", all_commands[Current_Command]);

			} else {
				if (Current_Command - 1 >= 0) {
f0100732:	a1 28 9d 1b f0       	mov    0xf01b9d28,%eax
f0100737:	48                   	dec    %eax
f0100738:	78 0a                	js     f0100744 <read_string+0xb0>
					Current_Command--;
f010073a:	a3 28 9d 1b f0       	mov    %eax,0xf01b9d28
					cprintf("%s", all_commands[Current_Command]);
f010073f:	83 ec 08             	sub    $0x8,%esp
f0100742:	eb 08                	jmp    f010074c <read_string+0xb8>
				} else
					cprintf("%s", all_commands[Current_Command]);
f0100744:	83 ec 08             	sub    $0x8,%esp
f0100747:	a1 28 9d 1b f0       	mov    0xf01b9d28,%eax
f010074c:	c1 e0 0a             	shl    $0xa,%eax
f010074f:	05 c0 a5 1b f0       	add    $0xf01ba5c0,%eax
f0100754:	50                   	push   %eax
f0100755:	68 b4 55 10 f0       	push   $0xf01055b4
f010075a:	e8 9f 27 00 00       	call   f0102efe <cprintf>
			}
			i = strlen(all_commands[Current_Command]);
f010075f:	a1 28 9d 1b f0       	mov    0xf01b9d28,%eax
f0100764:	c1 e0 0a             	shl    $0xa,%eax
f0100767:	05 c0 a5 1b f0       	add    $0xf01ba5c0,%eax
f010076c:	89 04 24             	mov    %eax,(%esp)
f010076f:	e8 bc 36 00 00       	call   f0103e30 <strlen>
f0100774:	89 c7                	mov    %eax,%edi
			i--;
f0100776:	4f                   	dec    %edi
			strcpy(line, all_commands[Current_Command]);
f0100777:	83 c4 08             	add    $0x8,%esp
f010077a:	a1 28 9d 1b f0       	mov    0xf01b9d28,%eax
f010077f:	c1 e0 0a             	shl    $0xa,%eax
f0100782:	05 c0 a5 1b f0       	add    $0xf01ba5c0,%eax
f0100787:	50                   	push   %eax
f0100788:	ff 75 08             	pushl  0x8(%ebp)
f010078b:	e8 dc 36 00 00       	call   f0103e6c <strcpy>
f0100790:	e9 a8 01 00 00       	jmp    f010093d <read_string+0x2a9>
		} else if ((int) c == 9) {
f0100795:	89 f2                	mov    %esi,%edx
f0100797:	80 fa 09             	cmp    $0x9,%dl
f010079a:	0f 85 46 01 00 00    	jne    f01008e6 <read_string+0x252>
			char arr[10][100];
			int j = 0;
f01007a0:	c7 85 f4 fb ff ff 00 	movl   $0x0,0xfffffbf4(%ebp)
f01007a7:	00 00 00 
			int n1, k, check;
			line[i] = '\0';
f01007aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ad:	c6 04 07 00          	movb   $0x0,(%edi,%eax,1)
			n1 = strlen(line);
f01007b1:	83 ec 0c             	sub    $0xc,%esp
f01007b4:	50                   	push   %eax
f01007b5:	e8 76 36 00 00       	call   f0103e30 <strlen>
f01007ba:	89 c7                	mov    %eax,%edi
			for (k = 0; k < n1; k++)
f01007bc:	be 00 00 00 00       	mov    $0x0,%esi
f01007c1:	83 c4 10             	add    $0x10,%esp
f01007c4:	39 85 f4 fb ff ff    	cmp    %eax,0xfffffbf4(%ebp)
f01007ca:	7d 51                	jge    f010081d <read_string+0x189>
				cprintf("\b");
f01007cc:	83 ec 0c             	sub    $0xc,%esp
f01007cf:	68 62 49 10 f0       	push   $0xf0104962
f01007d4:	e8 25 27 00 00       	call   f0102efe <cprintf>
f01007d9:	83 c4 10             	add    $0x10,%esp
f01007dc:	46                   	inc    %esi
f01007dd:	39 fe                	cmp    %edi,%esi
f01007df:	7c eb                	jl     f01007cc <read_string+0x138>
			for (k = 0; k < n1; k++)
f01007e1:	be 00 00 00 00       	mov    $0x0,%esi
f01007e6:	39 fe                	cmp    %edi,%esi
f01007e8:	7d 33                	jge    f010081d <read_string+0x189>
				cprintf(" ");
f01007ea:	83 ec 0c             	sub    $0xc,%esp
f01007ed:	68 6c 49 10 f0       	push   $0xf010496c
f01007f2:	e8 07 27 00 00       	call   f0102efe <cprintf>
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	46                   	inc    %esi
f01007fb:	39 fe                	cmp    %edi,%esi
f01007fd:	7c eb                	jl     f01007ea <read_string+0x156>
			for (k = 0; k < n1; k++)
f01007ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100804:	39 fe                	cmp    %edi,%esi
f0100806:	7d 15                	jge    f010081d <read_string+0x189>
				cprintf("\b");
f0100808:	83 ec 0c             	sub    $0xc,%esp
f010080b:	68 62 49 10 f0       	push   $0xf0104962
f0100810:	e8 e9 26 00 00       	call   f0102efe <cprintf>
f0100815:	83 c4 10             	add    $0x10,%esp
f0100818:	46                   	inc    %esi
f0100819:	39 fe                	cmp    %edi,%esi
f010081b:	7c eb                	jl     f0100808 <read_string+0x174>
			for (k = 0; k < NUM_OF_COMMANDS; k++) {
f010081d:	be 00 00 00 00       	mov    $0x0,%esi
				check = strncmp(commands[k].name, line, n1);
f0100822:	83 ec 04             	sub    $0x4,%esp
f0100825:	57                   	push   %edi
f0100826:	ff 75 08             	pushl  0x8(%ebp)
f0100829:	89 f3                	mov    %esi,%ebx
f010082b:	c1 e3 04             	shl    $0x4,%ebx
f010082e:	ff b3 60 d5 11 f0    	pushl  0xf011d560(%ebx)
f0100834:	e8 ee 36 00 00       	call   f0103f27 <strncmp>
				if (check == 0) {
f0100839:	83 c4 10             	add    $0x10,%esp
f010083c:	85 c0                	test   %eax,%eax
f010083e:	75 2b                	jne    f010086b <read_string+0x1d7>
					strcpy(arr[j], commands[k].name);
f0100840:	83 ec 08             	sub    $0x8,%esp
f0100843:	ff b3 60 d5 11 f0    	pushl  0xf011d560(%ebx)
f0100849:	8b 95 f4 fb ff ff    	mov    0xfffffbf4(%ebp),%edx
f010084f:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100852:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100855:	8d 84 85 f8 fb ff ff 	lea    0xfffffbf8(%ebp,%eax,4),%eax
f010085c:	50                   	push   %eax
f010085d:	e8 0a 36 00 00       	call   f0103e6c <strcpy>
					j++;
f0100862:	ff 85 f4 fb ff ff    	incl   0xfffffbf4(%ebp)
f0100868:	83 c4 10             	add    $0x10,%esp
f010086b:	46                   	inc    %esi
f010086c:	83 fe 10             	cmp    $0x10,%esi
f010086f:	76 b1                	jbe    f0100822 <read_string+0x18e>
				}
			}
			if (j > 1) {
f0100871:	83 bd f4 fb ff ff 01 	cmpl   $0x1,0xfffffbf4(%ebp)
f0100878:	7e 3f                	jle    f01008b9 <read_string+0x225>
				for (k = 0; k < j; k++)
f010087a:	be 00 00 00 00       	mov    $0x0,%esi
f010087f:	3b b5 f4 fb ff ff    	cmp    0xfffffbf4(%ebp),%esi
f0100885:	7d 27                	jge    f01008ae <read_string+0x21a>
					cprintf("%s\n", arr[k]);
f0100887:	83 ec 08             	sub    $0x8,%esp
f010088a:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f010088d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100890:	8d 84 85 f8 fb ff ff 	lea    0xfffffbf8(%ebp,%eax,4),%eax
f0100897:	50                   	push   %eax
f0100898:	68 a6 49 10 f0       	push   $0xf01049a6
f010089d:	e8 5c 26 00 00       	call   f0102efe <cprintf>
f01008a2:	83 c4 10             	add    $0x10,%esp
f01008a5:	46                   	inc    %esi
f01008a6:	3b b5 f4 fb ff ff    	cmp    0xfffffbf4(%ebp),%esi
f01008ac:	7c d9                	jl     f0100887 <read_string+0x1f3>
				line[0] = '\0';
f01008ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01008b1:	c6 00 00             	movb   $0x0,(%eax)
				return;
f01008b4:	e9 a2 00 00 00       	jmp    f010095b <read_string+0x2c7>
			} else {
					cprintf("%s", arr[0]);
f01008b9:	83 ec 08             	sub    $0x8,%esp
f01008bc:	8d 9d f8 fb ff ff    	lea    0xfffffbf8(%ebp),%ebx
f01008c2:	53                   	push   %ebx
f01008c3:	68 b4 55 10 f0       	push   $0xf01055b4
f01008c8:	e8 31 26 00 00       	call   f0102efe <cprintf>
				strcpy(line, arr[0]);
f01008cd:	83 c4 08             	add    $0x8,%esp
f01008d0:	53                   	push   %ebx
f01008d1:	ff 75 08             	pushl  0x8(%ebp)
f01008d4:	e8 93 35 00 00       	call   f0103e6c <strcpy>
				i = strlen(arr[0]) - 1;
f01008d9:	89 1c 24             	mov    %ebx,(%esp)
f01008dc:	e8 4f 35 00 00       	call   f0103e30 <strlen>
f01008e1:	89 c7                	mov    %eax,%edi
f01008e3:	4f                   	dec    %edi
f01008e4:	eb 57                	jmp    f010093d <read_string+0x2a9>
			}
		} else if (c == 8) {
f01008e6:	89 f2                	mov    %esi,%edx
f01008e8:	80 fa 08             	cmp    $0x8,%dl
f01008eb:	75 37                	jne    f0100924 <read_string+0x290>
			if (i - 1 >= 0) {
f01008ed:	89 f8                	mov    %edi,%eax
f01008ef:	48                   	dec    %eax
f01008f0:	78 4e                	js     f0100940 <read_string+0x2ac>
				cprintf("\b");
f01008f2:	83 ec 0c             	sub    $0xc,%esp
f01008f5:	68 62 49 10 f0       	push   $0xf0104962
f01008fa:	e8 ff 25 00 00       	call   f0102efe <cprintf>
				cprintf(" ");
f01008ff:	c7 04 24 6c 49 10 f0 	movl   $0xf010496c,(%esp)
f0100906:	e8 f3 25 00 00       	call   f0102efe <cprintf>
				cprintf("\b");
f010090b:	c7 04 24 62 49 10 f0 	movl   $0xf0104962,(%esp)
f0100912:	e8 e7 25 00 00       	call   f0102efe <cprintf>
				line[i - 1] = ' ';
f0100917:	8b 55 08             	mov    0x8(%ebp),%edx
f010091a:	c6 44 17 ff 20       	movb   $0x20,0xffffffff(%edi,%edx,1)
				i -= 2;
f010091f:	83 ef 02             	sub    $0x2,%edi
f0100922:	eb 19                	jmp    f010093d <read_string+0x2a9>
			}
		} else {
			line[i] = c;
f0100924:	89 f0                	mov    %esi,%eax
f0100926:	8b 55 08             	mov    0x8(%ebp),%edx
f0100929:	88 04 17             	mov    %al,(%edi,%edx,1)
			cprintf("%c", c);
f010092c:	83 ec 08             	sub    $0x8,%esp
f010092f:	0f be c0             	movsbl %al,%eax
f0100932:	50                   	push   %eax
f0100933:	68 64 49 10 f0       	push   $0xf0104964
f0100938:	e8 c1 25 00 00       	call   f0102efe <cprintf>
f010093d:	83 c4 10             	add    $0x10,%esp
		}
		i++;
f0100940:	47                   	inc    %edi
f0100941:	e8 31 fd ff ff       	call   f0100677 <getchar>
f0100946:	89 c6                	mov    %eax,%esi
f0100948:	84 c0                	test   %al,%al
f010094a:	74 08                	je     f0100954 <read_string+0x2c0>
f010094c:	3c 0a                	cmp    $0xa,%al
f010094e:	0f 85 63 fd ff ff    	jne    f01006b7 <read_string+0x23>
	}
	line[i] = '\0';
f0100954:	8b 45 08             	mov    0x8(%ebp),%eax
f0100957:	c6 04 07 00          	movb   $0x0,(%edi,%eax,1)
}
f010095b:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010095e:	5b                   	pop    %ebx
f010095f:	5e                   	pop    %esi
f0100960:	5f                   	pop    %edi
f0100961:	5d                   	pop    %ebp
f0100962:	c3                   	ret    

f0100963 <run_command_prompt>:

void run_command_prompt() {
f0100963:	55                   	push   %ebp
f0100964:	89 e5                	mov    %esp,%ebp
f0100966:	53                   	push   %ebx
f0100967:	81 ec 04 04 00 00    	sub    $0x404,%esp
	char command_line[1024];
	while (1 == 1) {
f010096d:	8d 9d f8 fb ff ff    	lea    0xfffffbf8(%ebp),%ebx
		read_string(command_line);
f0100973:	83 ec 0c             	sub    $0xc,%esp
f0100976:	53                   	push   %ebx
f0100977:	e8 18 fd ff ff       	call   f0100694 <read_string>
		cprintf("\n");
f010097c:	c7 04 24 c8 47 10 f0 	movl   $0xf01047c8,(%esp)
f0100983:	e8 76 25 00 00       	call   f0102efe <cprintf>
		//parse and execute the command
		if (command_line != NULL) {
f0100988:	83 c4 08             	add    $0x8,%esp
			strcpy(all_commands[Commands_count], command_line);
f010098b:	53                   	push   %ebx
f010098c:	a1 2c 9d 1b f0       	mov    0xf01b9d2c,%eax
f0100991:	c1 e0 0a             	shl    $0xa,%eax
f0100994:	05 c0 a5 1b f0       	add    $0xf01ba5c0,%eax
f0100999:	50                   	push   %eax
f010099a:	e8 cd 34 00 00       	call   f0103e6c <strcpy>
			Commands_count++;
f010099f:	a1 2c 9d 1b f0       	mov    0xf01b9d2c,%eax
f01009a4:	40                   	inc    %eax
f01009a5:	a3 2c 9d 1b f0       	mov    %eax,0xf01b9d2c
							Current_Command = Commands_count;
f01009aa:	a3 28 9d 1b f0       	mov    %eax,0xf01b9d28
			if (execute_command(command_line) < 0)
f01009af:	89 1c 24             	mov    %ebx,(%esp)
f01009b2:	e8 15 00 00 00       	call   f01009cc <execute_command>
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	78 09                	js     f01009c7 <run_command_prompt+0x64>
				break;
		}
		command_line[0] = '\0';
f01009be:	c6 85 f8 fb ff ff 00 	movb   $0x0,0xfffffbf8(%ebp)
f01009c5:	eb ac                	jmp    f0100973 <run_command_prompt+0x10>
	}
}
f01009c7:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01009ca:	c9                   	leave  
f01009cb:	c3                   	ret    

f01009cc <execute_command>:

/***** Kernel command prompt command interpreter *****/

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string) {
f01009cc:	55                   	push   %ebp
f01009cd:	89 e5                	mov    %esp,%ebp
f01009cf:	57                   	push   %edi
f01009d0:	56                   	push   %esi
f01009d1:	53                   	push   %ebx
f01009d2:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	// Split the command string into whitespace-separated arguments
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];
	int num_of_commands;
	char *all_commands[MAX_ARGUMENTS];

	strsplit(command_string, SPLIT, all_commands, &num_of_commands);
f01009d8:	8d 85 64 ff ff ff    	lea    0xffffff64(%ebp),%eax
f01009de:	50                   	push   %eax
f01009df:	8d 85 68 ff ff ff    	lea    0xffffff68(%ebp),%eax
f01009e5:	50                   	push   %eax
f01009e6:	68 67 49 10 f0       	push   $0xf0104967
f01009eb:	ff 75 08             	pushl  0x8(%ebp)
f01009ee:	e8 89 38 00 00       	call   f010427c <strsplit>
	int j;
	for (j = 0; j < num_of_commands; j++) {
f01009f3:	bf 00 00 00 00       	mov    $0x0,%edi
f01009f8:	83 c4 10             	add    $0x10,%esp
f01009fb:	3b bd 64 ff ff ff    	cmp    0xffffff64(%ebp),%edi
f0100a01:	0f 8d da 00 00 00    	jge    f0100ae1 <execute_command+0x115>
		strsplit(all_commands[j], WHITESPACE, arguments, &number_of_arguments);
f0100a07:	8d 85 60 ff ff ff    	lea    0xffffff60(%ebp),%eax
f0100a0d:	50                   	push   %eax
f0100a0e:	8d 45 a8             	lea    0xffffffa8(%ebp),%eax
f0100a11:	50                   	push   %eax
f0100a12:	68 69 49 10 f0       	push   $0xf0104969
f0100a17:	ff b4 bd 68 ff ff ff 	pushl  0xffffff68(%ebp,%edi,4)
f0100a1e:	e8 59 38 00 00       	call   f010427c <strsplit>
		if (number_of_arguments == 0)
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	83 bd 60 ff ff ff 00 	cmpl   $0x0,0xffffff60(%ebp)
f0100a2d:	0f 84 a1 00 00 00    	je     f0100ad4 <execute_command+0x108>
			continue; //return 0;

		// Lookup in the commands array and execute the command
		int command_found = 0;
f0100a33:	c7 85 5c ff ff ff 00 	movl   $0x0,0xffffff5c(%ebp)
f0100a3a:	00 00 00 
		int i;
		for (i = 0; i < NUM_OF_COMMANDS; i++) {
f0100a3d:	be 00 00 00 00       	mov    $0x0,%esi
			if (strcmp(arguments[0], commands[i].name) == 0) {
f0100a42:	83 ec 08             	sub    $0x8,%esp
f0100a45:	89 f3                	mov    %esi,%ebx
f0100a47:	c1 e3 04             	shl    $0x4,%ebx
f0100a4a:	ff b3 60 d5 11 f0    	pushl  0xf011d560(%ebx)
f0100a50:	ff 75 a8             	pushl  0xffffffa8(%ebp)
f0100a53:	e8 9c 34 00 00       	call   f0103ef4 <strcmp>
f0100a58:	83 c4 10             	add    $0x10,%esp
f0100a5b:	85 c0                	test   %eax,%eax
f0100a5d:	75 1a                	jne    f0100a79 <execute_command+0xad>
				if (number_of_arguments != commands[i].num_of_arguments)
f0100a5f:	c7 85 5c ff ff ff 01 	movl   $0x1,0xffffff5c(%ebp)
f0100a66:	00 00 00 
					command_found = 2;
				else
					command_found = 1;
				break;
f0100a69:	8b 85 60 ff ff ff    	mov    0xffffff60(%ebp),%eax
f0100a6f:	3b 83 6c d5 11 f0    	cmp    0xf011d56c(%ebx),%eax
f0100a75:	74 08                	je     f0100a7f <execute_command+0xb3>
f0100a77:	eb 29                	jmp    f0100aa2 <execute_command+0xd6>
f0100a79:	46                   	inc    %esi
f0100a7a:	83 fe 10             	cmp    $0x10,%esi
f0100a7d:	76 c3                	jbe    f0100a42 <execute_command+0x76>
			}
		}

		if (command_found == 1) {
f0100a7f:	83 bd 5c ff ff ff 01 	cmpl   $0x1,0xffffff5c(%ebp)
f0100a86:	75 26                	jne    f0100aae <execute_command+0xe2>
			int return_value;
			return_value = commands[i].function_to_execute(number_of_arguments,
f0100a88:	83 ec 08             	sub    $0x8,%esp
f0100a8b:	89 f0                	mov    %esi,%eax
f0100a8d:	c1 e0 04             	shl    $0x4,%eax
f0100a90:	8d 55 a8             	lea    0xffffffa8(%ebp),%edx
f0100a93:	52                   	push   %edx
f0100a94:	ff b5 60 ff ff ff    	pushl  0xffffff60(%ebp)
f0100a9a:	ff 90 68 d5 11 f0    	call   *0xf011d568(%eax)
f0100aa0:	eb 2f                	jmp    f0100ad1 <execute_command+0x105>
f0100aa2:	c7 85 5c ff ff ff 02 	movl   $0x2,0xffffff5c(%ebp)
f0100aa9:	00 00 00 
f0100aac:	eb d1                	jmp    f0100a7f <execute_command+0xb3>
					arguments);
			//return return_value;
		} else if (command_found == 2) {
f0100aae:	83 bd 5c ff ff ff 02 	cmpl   $0x2,0xffffff5c(%ebp)
f0100ab5:	75 0a                	jne    f0100ac1 <execute_command+0xf5>
			cprintf("Invalid number of arguments\n");
f0100ab7:	83 ec 0c             	sub    $0xc,%esp
f0100aba:	68 6e 49 10 f0       	push   $0xf010496e
f0100abf:	eb 0b                	jmp    f0100acc <execute_command+0x100>
			//return 0;
		} else {
			//if not found, then it's unknown command
			cprintf("Unknown command '%s'\n", arguments[0]);
f0100ac1:	83 ec 08             	sub    $0x8,%esp
f0100ac4:	ff 75 a8             	pushl  0xffffffa8(%ebp)
f0100ac7:	68 8b 49 10 f0       	push   $0xf010498b
f0100acc:	e8 2d 24 00 00       	call   f0102efe <cprintf>
f0100ad1:	83 c4 10             	add    $0x10,%esp
f0100ad4:	47                   	inc    %edi
f0100ad5:	3b bd 64 ff ff ff    	cmp    0xffffff64(%ebp),%edi
f0100adb:	0f 8c 26 ff ff ff    	jl     f0100a07 <execute_command+0x3b>
			//return 0;
		}
	}
	return 0;
}
f0100ae1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae6:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100ae9:	5b                   	pop    %ebx
f0100aea:	5e                   	pop    %esi
f0100aeb:	5f                   	pop    %edi
f0100aec:	5d                   	pop    %ebp
f0100aed:	c3                   	ret    

f0100aee <command_help>:

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments) {
f0100aee:	55                   	push   %ebp
f0100aef:	89 e5                	mov    %esp,%ebp
f0100af1:	53                   	push   %ebx
f0100af2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100af5:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
f0100afa:	83 ec 04             	sub    $0x4,%esp
f0100afd:	89 d8                	mov    %ebx,%eax
f0100aff:	c1 e0 04             	shl    $0x4,%eax
f0100b02:	ff b0 64 d5 11 f0    	pushl  0xf011d564(%eax)
f0100b08:	ff b0 60 d5 11 f0    	pushl  0xf011d560(%eax)
f0100b0e:	68 a1 49 10 f0       	push   $0xf01049a1
f0100b13:	e8 e6 23 00 00       	call   f0102efe <cprintf>
f0100b18:	83 c4 10             	add    $0x10,%esp
f0100b1b:	43                   	inc    %ebx
f0100b1c:	83 fb 10             	cmp    $0x10,%ebx
f0100b1f:	76 d9                	jbe    f0100afa <command_help+0xc>

	cprintf("-------------------\n");
f0100b21:	83 ec 0c             	sub    $0xc,%esp
f0100b24:	68 aa 49 10 f0       	push   $0xf01049aa
f0100b29:	e8 d0 23 00 00       	call   f0102efe <cprintf>

	return 0;
}
f0100b2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b33:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100b36:	c9                   	leave  
f0100b37:	c3                   	ret    

f0100b38 <command_kernel_info>:

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments) {
f0100b38:	55                   	push   %ebp
f0100b39:	89 e5                	mov    %esp,%ebp
f0100b3b:	83 ec 14             	sub    $0x14,%esp
	extern char start_of_kernel[], end_of_kernel_code_section[],
			start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
f0100b3e:	68 bf 49 10 f0       	push   $0xf01049bf
f0100b43:	e8 b6 23 00 00       	call   f0102efe <cprintf>
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n",
f0100b48:	83 c4 0c             	add    $0xc,%esp
f0100b4b:	68 0c 00 10 00       	push   $0x10000c
f0100b50:	68 0c 00 10 f0       	push   $0xf010000c
f0100b55:	68 40 4c 10 f0       	push   $0xf0104c40
f0100b5a:	e8 9f 23 00 00       	call   f0102efe <cprintf>
			start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n",
f0100b5f:	83 c4 0c             	add    $0xc,%esp
f0100b62:	68 40 46 10 00       	push   $0x104640
f0100b67:	68 40 46 10 f0       	push   $0xf0104640
f0100b6c:	68 80 4c 10 f0       	push   $0xf0104c80
f0100b71:	e8 88 23 00 00       	call   f0102efe <cprintf>
			end_of_kernel_code_section, end_of_kernel_code_section
					- KERNEL_BASE);
	cprintf(
f0100b76:	83 c4 0c             	add    $0xc,%esp
f0100b79:	68 57 71 18 00       	push   $0x187157
f0100b7e:	68 57 71 18 f0       	push   $0xf0187157
f0100b83:	68 c0 4c 10 f0       	push   $0xf0104cc0
f0100b88:	e8 71 23 00 00       	call   f0102efe <cprintf>
			"  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n",
			start_of_uninitialized_data_section,
			start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n",
f0100b8d:	83 c4 0c             	add    $0xc,%esp
f0100b90:	68 d4 f5 1b 00       	push   $0x1bf5d4
f0100b95:	68 d4 f5 1b f0       	push   $0xf01bf5d4
f0100b9a:	68 20 4d 10 f0       	push   $0xf0104d20
f0100b9f:	e8 5a 23 00 00       	call   f0102efe <cprintf>
			end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n", (end_of_kernel
f0100ba4:	83 c4 08             	add    $0x8,%esp
f0100ba7:	b8 d3 f9 1b f0       	mov    $0xf01bf9d3,%eax
f0100bac:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100bb1:	79 05                	jns    f0100bb8 <command_kernel_info+0x80>
f0100bb3:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100bb8:	c1 f8 0a             	sar    $0xa,%eax
f0100bbb:	50                   	push   %eax
f0100bbc:	68 60 4d 10 f0       	push   $0xf0104d60
f0100bc1:	e8 38 23 00 00       	call   f0102efe <cprintf>
			- start_of_kernel + 1023) / 1024);
	return 0;
}
f0100bc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bcb:	c9                   	leave  
f0100bcc:	c3                   	ret    

f0100bcd <comm_kernel_version>:

int comm_kernel_version(int number_of_arguments, char **arguments) {
f0100bcd:	55                   	push   %ebp
f0100bce:	89 e5                	mov    %esp,%ebp
f0100bd0:	83 ec 14             	sub    $0x14,%esp

	cprintf("FOS kernel version 0.1\n");
f0100bd3:	68 d8 49 10 f0       	push   $0xf01049d8
f0100bd8:	e8 21 23 00 00       	call   f0102efe <cprintf>

	return 0;
}
f0100bdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be2:	c9                   	leave  
f0100be3:	c3                   	ret    

f0100be4 <comm_add>:

int comm_add(int number_of_arguments, char **arguments) {
f0100be4:	55                   	push   %ebp
f0100be5:	89 e5                	mov    %esp,%ebp
f0100be7:	56                   	push   %esi
f0100be8:	53                   	push   %ebx
f0100be9:	83 ec 14             	sub    $0x14,%esp
f0100bec:	8b 75 0c             	mov    0xc(%ebp),%esi

	char mystr[] = "hoda";
f0100bef:	a1 f0 49 10 f0       	mov    0xf01049f0,%eax
f0100bf4:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0100bf7:	a0 f4 49 10 f0       	mov    0xf01049f4,%al
f0100bfc:	88 45 ec             	mov    %al,0xffffffec(%ebp)
	int n1, n2, res;
	n1 = strtol(arguments[1], NULL, 10);
f0100bff:	6a 0a                	push   $0xa
f0100c01:	6a 00                	push   $0x0
f0100c03:	ff 76 04             	pushl  0x4(%esi)
f0100c06:	e8 97 34 00 00       	call   f01040a2 <strtol>
f0100c0b:	89 c3                	mov    %eax,%ebx
	n2 = strtol(arguments[2], NULL, 10);
f0100c0d:	83 c4 0c             	add    $0xc,%esp
f0100c10:	6a 0a                	push   $0xa
f0100c12:	6a 00                	push   $0x0
f0100c14:	ff 76 08             	pushl  0x8(%esi)
f0100c17:	e8 86 34 00 00       	call   f01040a2 <strtol>
	res = n1 + n2;
f0100c1c:	8d 14 18             	lea    (%eax,%ebx,1),%edx
	cprintf("%d + %d = %d\n", n1, n2, res);
f0100c1f:	52                   	push   %edx
f0100c20:	50                   	push   %eax
f0100c21:	53                   	push   %ebx
f0100c22:	68 f5 49 10 f0       	push   $0xf01049f5
f0100c27:	e8 d2 22 00 00       	call   f0102efe <cprintf>

	return 0;
}
f0100c2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c31:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100c34:	5b                   	pop    %ebx
f0100c35:	5e                   	pop    %esi
f0100c36:	5d                   	pop    %ebp
f0100c37:	c3                   	ret    

f0100c38 <command_rep>:

int command_rep(int number_of_arguments, char **arguments) {
f0100c38:	55                   	push   %ebp
f0100c39:	89 e5                	mov    %esp,%ebp
f0100c3b:	57                   	push   %edi
f0100c3c:	56                   	push   %esi
f0100c3d:	53                   	push   %ebx
f0100c3e:	83 ec 10             	sub    $0x10,%esp
f0100c41:	8b 7d 0c             	mov    0xc(%ebp),%edi

	int n1, i;
	n1 = strtol(arguments[2], NULL, 10);
f0100c44:	6a 0a                	push   $0xa
f0100c46:	6a 00                	push   $0x0
f0100c48:	ff 77 08             	pushl  0x8(%edi)
f0100c4b:	e8 52 34 00 00       	call   f01040a2 <strtol>
f0100c50:	89 c6                	mov    %eax,%esi
	for (i = 0; i < n1; i++)
f0100c52:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c57:	83 c4 10             	add    $0x10,%esp
f0100c5a:	39 c3                	cmp    %eax,%ebx
f0100c5c:	7d 18                	jge    f0100c76 <command_rep+0x3e>
		cprintf("%s\n", arguments[1]);
f0100c5e:	83 ec 08             	sub    $0x8,%esp
f0100c61:	ff 77 04             	pushl  0x4(%edi)
f0100c64:	68 a6 49 10 f0       	push   $0xf01049a6
f0100c69:	e8 90 22 00 00       	call   f0102efe <cprintf>
f0100c6e:	83 c4 10             	add    $0x10,%esp
f0100c71:	43                   	inc    %ebx
f0100c72:	39 f3                	cmp    %esi,%ebx
f0100c74:	7c e8                	jl     f0100c5e <command_rep+0x26>

	return 0;
}
f0100c76:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7b:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100c7e:	5b                   	pop    %ebx
f0100c7f:	5e                   	pop    %esi
f0100c80:	5f                   	pop    %edi
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <command_like>:

int command_like(int number_of_arguments, char **arguments) {
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	57                   	push   %edi
f0100c87:	56                   	push   %esi
f0100c88:	53                   	push   %ebx
f0100c89:	83 ec 18             	sub    $0x18,%esp

	int n1, i, check;
	n1 = strlen(arguments[1]);
f0100c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c8f:	ff 70 04             	pushl  0x4(%eax)
f0100c92:	e8 99 31 00 00       	call   f0103e30 <strlen>
f0100c97:	89 c7                	mov    %eax,%edi
	for (i = 0; i < NUM_OF_COMMANDS; i++) {
f0100c99:	be 00 00 00 00       	mov    $0x0,%esi
f0100c9e:	83 c4 10             	add    $0x10,%esp
		check = strncmp(commands[i].name, arguments[1], n1);
f0100ca1:	83 ec 04             	sub    $0x4,%esp
f0100ca4:	57                   	push   %edi
f0100ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ca8:	ff 70 04             	pushl  0x4(%eax)
f0100cab:	89 f3                	mov    %esi,%ebx
f0100cad:	c1 e3 04             	shl    $0x4,%ebx
f0100cb0:	ff b3 60 d5 11 f0    	pushl  0xf011d560(%ebx)
f0100cb6:	e8 6c 32 00 00       	call   f0103f27 <strncmp>
		if (check == 0)
f0100cbb:	83 c4 10             	add    $0x10,%esp
f0100cbe:	85 c0                	test   %eax,%eax
f0100cc0:	75 28                	jne    f0100cea <command_like+0x67>
			cprintf("%s\n", commands[i]);
f0100cc2:	83 ec 0c             	sub    $0xc,%esp
f0100cc5:	ff b3 6c d5 11 f0    	pushl  0xf011d56c(%ebx)
f0100ccb:	ff b3 68 d5 11 f0    	pushl  0xf011d568(%ebx)
f0100cd1:	ff b3 64 d5 11 f0    	pushl  0xf011d564(%ebx)
f0100cd7:	ff b3 60 d5 11 f0    	pushl  0xf011d560(%ebx)
f0100cdd:	68 a6 49 10 f0       	push   $0xf01049a6
f0100ce2:	e8 17 22 00 00       	call   f0102efe <cprintf>
f0100ce7:	83 c4 20             	add    $0x20,%esp
f0100cea:	46                   	inc    %esi
f0100ceb:	83 fe 10             	cmp    $0x10,%esi
f0100cee:	76 b1                	jbe    f0100ca1 <command_like+0x1e>
	}

	return 0;
}
f0100cf0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf5:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100cf8:	5b                   	pop    %ebx
f0100cf9:	5e                   	pop    %esi
f0100cfa:	5f                   	pop    %edi
f0100cfb:	5d                   	pop    %ebp
f0100cfc:	c3                   	ret    

f0100cfd <batch_create>:

int batch_create(int number_of_arguments, char **arguments) {
f0100cfd:	55                   	push   %ebp
f0100cfe:	89 e5                	mov    %esp,%ebp
f0100d00:	56                   	push   %esi
f0100d01:	53                   	push   %ebx
f0100d02:	81 ec 18 04 00 00    	sub    $0x418,%esp
	strcpy(batches[num_of_batches].name, arguments[1]);
f0100d08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d0b:	ff 70 04             	pushl  0x4(%eax)
f0100d0e:	8b 15 24 9d 1b f0    	mov    0xf01b9d24,%edx
f0100d14:	8d 04 d2             	lea    (%edx,%edx,8),%eax
f0100d17:	8d 04 c0             	lea    (%eax,%eax,8),%eax
f0100d1a:	c1 e0 02             	shl    $0x2,%eax
f0100d1d:	29 d0                	sub    %edx,%eax
f0100d1f:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100d22:	8d 04 c5 c0 73 18 f0 	lea    0xf01873c0(,%eax,8),%eax
f0100d29:	50                   	push   %eax
f0100d2a:	e8 3d 31 00 00       	call   f0103e6c <strcpy>
	char end[] = "endBatch";
f0100d2f:	a1 03 4a 10 f0       	mov    0xf0104a03,%eax
f0100d34:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0100d37:	a1 07 4a 10 f0       	mov    0xf0104a07,%eax
f0100d3c:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0100d3f:	a0 0b 4a 10 f0       	mov    0xf0104a0b,%al
f0100d44:	88 45 f0             	mov    %al,0xfffffff0(%ebp)
	int n = 0;
f0100d47:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
f0100d4c:	83 c4 10             	add    $0x10,%esp
f0100d4f:	8d 9d e8 fb ff ff    	lea    0xfffffbe8(%ebp),%ebx
		char line[1024];
		readline("", line);
f0100d55:	83 ec 08             	sub    $0x8,%esp
f0100d58:	53                   	push   %ebx
f0100d59:	68 63 49 10 f0       	push   $0xf0104963
f0100d5e:	e8 e9 2f 00 00       	call   f0103d4c <readline>
		if (strcmp(end, line) == 0)
f0100d63:	83 c4 08             	add    $0x8,%esp
f0100d66:	53                   	push   %ebx
f0100d67:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0100d6a:	50                   	push   %eax
f0100d6b:	e8 84 31 00 00       	call   f0103ef4 <strcmp>
f0100d70:	83 c4 10             	add    $0x10,%esp
f0100d73:	85 c0                	test   %eax,%eax
f0100d75:	74 2f                	je     f0100da6 <batch_create+0xa9>
			break;
		int i;
		strcpy(batches[num_of_batches].commands[n], line);
f0100d77:	83 ec 08             	sub    $0x8,%esp
f0100d7a:	53                   	push   %ebx
f0100d7b:	a1 24 9d 1b f0       	mov    0xf01b9d24,%eax
f0100d80:	8d 14 c0             	lea    (%eax,%eax,8),%edx
f0100d83:	8d 14 d2             	lea    (%edx,%edx,8),%edx
f0100d86:	c1 e2 02             	shl    $0x2,%edx
f0100d89:	29 c2                	sub    %eax,%edx
f0100d8b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0100d8e:	89 f0                	mov    %esi,%eax
f0100d90:	c1 e0 0a             	shl    $0xa,%eax
f0100d93:	8d 94 d0 24 74 18 f0 	lea    0xf0187424(%eax,%edx,8),%edx
f0100d9a:	52                   	push   %edx
f0100d9b:	e8 cc 30 00 00       	call   f0103e6c <strcpy>
		n++;
f0100da0:	46                   	inc    %esi
f0100da1:	83 c4 10             	add    $0x10,%esp
f0100da4:	eb af                	jmp    f0100d55 <batch_create+0x58>
	}
	batches[num_of_batches].num_of_commands = n;
f0100da6:	8b 15 24 9d 1b f0    	mov    0xf01b9d24,%edx
f0100dac:	8d 04 d2             	lea    (%edx,%edx,8),%eax
f0100daf:	8d 04 c0             	lea    (%eax,%eax,8),%eax
f0100db2:	c1 e0 02             	shl    $0x2,%eax
f0100db5:	29 d0                	sub    %edx,%eax
f0100db7:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100dba:	89 34 c5 24 9c 18 f0 	mov    %esi,0xf0189c24(,%eax,8)
	num_of_batches++;
f0100dc1:	42                   	inc    %edx
f0100dc2:	89 15 24 9d 1b f0    	mov    %edx,0xf01b9d24

	return 0;
}
f0100dc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dcd:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0100dd0:	5b                   	pop    %ebx
f0100dd1:	5e                   	pop    %esi
f0100dd2:	5d                   	pop    %ebp
f0100dd3:	c3                   	ret    

f0100dd4 <batch_execute>:

int batch_execute(int number_of_arguments, char **arguments) {
f0100dd4:	55                   	push   %ebp
f0100dd5:	89 e5                	mov    %esp,%ebp
f0100dd7:	57                   	push   %edi
f0100dd8:	56                   	push   %esi
f0100dd9:	53                   	push   %ebx
f0100dda:	83 ec 0c             	sub    $0xc,%esp
	int i;
	for (i = 0; i < num_of_batches; i++) {
f0100ddd:	bf 00 00 00 00       	mov    $0x0,%edi
f0100de2:	3b 3d 24 9d 1b f0    	cmp    0xf01b9d24,%edi
f0100de8:	7d 68                	jge    f0100e52 <batch_execute+0x7e>
		if (strcmp(arguments[1], batches[i].name) == 0) {
f0100dea:	83 ec 08             	sub    $0x8,%esp
f0100ded:	8d 04 ff             	lea    (%edi,%edi,8),%eax
f0100df0:	8d 04 c0             	lea    (%eax,%eax,8),%eax
f0100df3:	c1 e0 02             	shl    $0x2,%eax
f0100df6:	29 f8                	sub    %edi,%eax
f0100df8:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0100dfb:	8d 34 c5 00 00 00 00 	lea    0x0(,%eax,8),%esi
f0100e02:	8d 86 c0 73 18 f0    	lea    0xf01873c0(%esi),%eax
f0100e08:	50                   	push   %eax
f0100e09:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e0c:	ff 70 04             	pushl  0x4(%eax)
f0100e0f:	e8 e0 30 00 00       	call   f0103ef4 <strcmp>
f0100e14:	83 c4 10             	add    $0x10,%esp
f0100e17:	85 c0                	test   %eax,%eax
f0100e19:	75 2e                	jne    f0100e49 <batch_execute+0x75>
			int j, n;
			for (j = 0; j < batches[i].num_of_commands; j++)
f0100e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e20:	3b 9e 24 9c 18 f0    	cmp    0xf0189c24(%esi),%ebx
f0100e26:	7d 21                	jge    f0100e49 <batch_execute+0x75>
				n = execute_command(batches[i].commands[j]);
f0100e28:	83 ec 0c             	sub    $0xc,%esp
f0100e2b:	89 d8                	mov    %ebx,%eax
f0100e2d:	c1 e0 0a             	shl    $0xa,%eax
f0100e30:	8d 84 30 24 74 18 f0 	lea    0xf0187424(%eax,%esi,1),%eax
f0100e37:	50                   	push   %eax
f0100e38:	e8 8f fb ff ff       	call   f01009cc <execute_command>
f0100e3d:	83 c4 10             	add    $0x10,%esp
f0100e40:	43                   	inc    %ebx
f0100e41:	3b 9e 24 9c 18 f0    	cmp    0xf0189c24(%esi),%ebx
f0100e47:	7c df                	jl     f0100e28 <batch_execute+0x54>
f0100e49:	47                   	inc    %edi
f0100e4a:	3b 3d 24 9d 1b f0    	cmp    0xf01b9d24,%edi
f0100e50:	7c 98                	jl     f0100dea <batch_execute+0x16>
		}
	}

	return 0;
}
f0100e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e57:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100e5a:	5b                   	pop    %ebx
f0100e5b:	5e                   	pop    %esi
f0100e5c:	5f                   	pop    %edi
f0100e5d:	5d                   	pop    %ebp
f0100e5e:	c3                   	ret    

f0100e5f <command_wm>:

//2nd lab

int command_wm(int number_of_arguments, char **arguments) {
f0100e5f:	55                   	push   %ebp
f0100e60:	89 e5                	mov    %esp,%ebp
f0100e62:	53                   	push   %ebx
f0100e63:	83 ec 08             	sub    $0x8,%esp
f0100e66:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	int n1 = strtol(arguments[1], NULL, 10);
f0100e69:	6a 0a                	push   $0xa
f0100e6b:	6a 00                	push   $0x0
f0100e6d:	ff 73 04             	pushl  0x4(%ebx)
f0100e70:	e8 2d 32 00 00       	call   f01040a2 <strtol>
	char *ptr;
	ptr = (char*) (n1 + KERNEL_BASE);
	*ptr = arguments[2][0];
f0100e75:	8b 53 08             	mov    0x8(%ebx),%edx
f0100e78:	8a 12                	mov    (%edx),%dl
f0100e7a:	88 90 00 00 00 f0    	mov    %dl,0xf0000000(%eax)
	return 0;
}
f0100e80:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e85:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0100e88:	c9                   	leave  
f0100e89:	c3                   	ret    

f0100e8a <command_rm>:

int command_rm(int number_of_arguments, char **arguments) {
f0100e8a:	55                   	push   %ebp
f0100e8b:	89 e5                	mov    %esp,%ebp
f0100e8d:	83 ec 0c             	sub    $0xc,%esp

	int n1 = strtol(arguments[1], NULL, 10);
f0100e90:	6a 0a                	push   $0xa
f0100e92:	6a 00                	push   $0x0
f0100e94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e97:	ff 70 04             	pushl  0x4(%eax)
f0100e9a:	e8 03 32 00 00       	call   f01040a2 <strtol>
	char *ptr;
	ptr = (char*) (n1 + KERNEL_BASE);
	cprintf("Mem location at address %d = %c\n", n1, *ptr);
f0100e9f:	83 c4 0c             	add    $0xc,%esp
f0100ea2:	0f be 90 00 00 00 f0 	movsbl 0xf0000000(%eax),%edx
f0100ea9:	52                   	push   %edx
f0100eaa:	50                   	push   %eax
f0100eab:	68 a0 4d 10 f0       	push   $0xf0104da0
f0100eb0:	e8 49 20 00 00       	call   f0102efe <cprintf>
	return 0;
}
f0100eb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eba:	c9                   	leave  
f0100ebb:	c3                   	ret    

f0100ebc <command_readBlock>:

int command_readBlock(int number_of_arguments, char **arguments) {
f0100ebc:	55                   	push   %ebp
f0100ebd:	89 e5                	mov    %esp,%ebp
f0100ebf:	57                   	push   %edi
f0100ec0:	56                   	push   %esi
f0100ec1:	53                   	push   %ebx
f0100ec2:	83 ec 10             	sub    $0x10,%esp
f0100ec5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int phy_add = strtol(arguments[1], NULL, 10);
f0100ec8:	6a 0a                	push   $0xa
f0100eca:	6a 00                	push   $0x0
f0100ecc:	ff 73 04             	pushl  0x4(%ebx)
f0100ecf:	e8 ce 31 00 00       	call   f01040a2 <strtol>
	unsigned int vir_add = phy_add + KERNEL_BASE;
	char* ptr = (char*) vir_add;
f0100ed4:	8d b0 00 00 00 f0    	lea    0xf0000000(%eax),%esi
	int num = strtol(arguments[2], NULL, 10);
f0100eda:	83 c4 0c             	add    $0xc,%esp
f0100edd:	6a 0a                	push   $0xa
f0100edf:	6a 00                	push   $0x0
f0100ee1:	ff 73 08             	pushl  0x8(%ebx)
f0100ee4:	e8 b9 31 00 00       	call   f01040a2 <strtol>
f0100ee9:	89 c7                	mov    %eax,%edi
	int i;
	for (i = 0; i < num; i++) {
f0100eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ef0:	83 c4 10             	add    $0x10,%esp
f0100ef3:	39 c3                	cmp    %eax,%ebx
f0100ef5:	7d 1a                	jge    f0100f11 <command_readBlock+0x55>
		cprintf("%c\n", *ptr);
f0100ef7:	83 ec 08             	sub    $0x8,%esp
f0100efa:	0f be 06             	movsbl (%esi),%eax
f0100efd:	50                   	push   %eax
f0100efe:	68 0c 4a 10 f0       	push   $0xf0104a0c
f0100f03:	e8 f6 1f 00 00       	call   f0102efe <cprintf>
		ptr++;
f0100f08:	46                   	inc    %esi
f0100f09:	83 c4 10             	add    $0x10,%esp
f0100f0c:	43                   	inc    %ebx
f0100f0d:	39 fb                	cmp    %edi,%ebx
f0100f0f:	7c e6                	jl     f0100ef7 <command_readBlock+0x3b>
	}
	return 0;
}
f0100f11:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f16:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100f19:	5b                   	pop    %ebx
f0100f1a:	5e                   	pop    %esi
f0100f1b:	5f                   	pop    %edi
f0100f1c:	5d                   	pop    %ebp
f0100f1d:	c3                   	ret    

f0100f1e <command_createIntArr>:

int command_createIntArr(int number_of_arguments, char **arguments) {
f0100f1e:	55                   	push   %ebp
f0100f1f:	89 e5                	mov    %esp,%ebp
f0100f21:	57                   	push   %edi
f0100f22:	56                   	push   %esi
f0100f23:	53                   	push   %ebx
f0100f24:	83 ec 30             	sub    $0x30,%esp
	int num = strtol(arguments[1], NULL, 10);
f0100f27:	6a 0a                	push   $0xa
f0100f29:	6a 00                	push   $0x0
f0100f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f2e:	ff 70 04             	pushl  0x4(%eax)
f0100f31:	e8 6c 31 00 00       	call   f01040a2 <strtol>
f0100f36:	89 c7                	mov    %eax,%edi
	cprintf("The start virtual address of the allocated array is: %x\n",
f0100f38:	83 c4 08             	add    $0x8,%esp
f0100f3b:	ff 35 40 d5 11 f0    	pushl  0xf011d540
f0100f41:	68 e0 4d 10 f0       	push   $0xf0104de0
f0100f46:	e8 b3 1f 00 00       	call   f0102efe <cprintf>
			intArrAddress);
	int* ptr = (int*) intArrAddress;
f0100f4b:	8b 35 40 d5 11 f0    	mov    0xf011d540,%esi
	int i;
	for (i = 0; i < num; i++) {
f0100f51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f56:	83 c4 10             	add    $0x10,%esp
f0100f59:	39 f8                	cmp    %edi,%eax
f0100f5b:	7d 40                	jge    f0100f9d <command_createIntArr+0x7f>
		char Number[20];
		cprintf("Enter element %d\n", i + 1);
f0100f5d:	83 ec 08             	sub    $0x8,%esp
f0100f60:	8d 58 01             	lea    0x1(%eax),%ebx
f0100f63:	53                   	push   %ebx
f0100f64:	68 10 4a 10 f0       	push   $0xf0104a10
f0100f69:	e8 90 1f 00 00       	call   f0102efe <cprintf>
		readline("", Number);
f0100f6e:	83 c4 08             	add    $0x8,%esp
f0100f71:	8d 45 c8             	lea    0xffffffc8(%ebp),%eax
f0100f74:	50                   	push   %eax
f0100f75:	68 63 49 10 f0       	push   $0xf0104963
f0100f7a:	e8 cd 2d 00 00       	call   f0103d4c <readline>
		*ptr = strtol(Number, NULL, 10);
f0100f7f:	83 c4 0c             	add    $0xc,%esp
f0100f82:	6a 0a                	push   $0xa
f0100f84:	6a 00                	push   $0x0
f0100f86:	8d 45 c8             	lea    0xffffffc8(%ebp),%eax
f0100f89:	50                   	push   %eax
f0100f8a:	e8 13 31 00 00       	call   f01040a2 <strtol>
f0100f8f:	89 06                	mov    %eax,(%esi)
		ptr++;
f0100f91:	83 c6 04             	add    $0x4,%esi
f0100f94:	83 c4 10             	add    $0x10,%esp
f0100f97:	89 d8                	mov    %ebx,%eax
f0100f99:	39 fb                	cmp    %edi,%ebx
f0100f9b:	7c c0                	jl     f0100f5d <command_createIntArr+0x3f>
	}
	arr_Ind[arrsInd].add = intArrAddress;
f0100f9d:	a1 20 9d 1b f0       	mov    0xf01b9d20,%eax
f0100fa2:	89 c2                	mov    %eax,%edx
f0100fa4:	c1 e2 04             	shl    $0x4,%edx
f0100fa7:	8b 0d 40 d5 11 f0    	mov    0xf011d540,%ecx
f0100fad:	89 8a e0 9b 1b f0    	mov    %ecx,0xf01b9be0(%edx)
	arr_Ind[arrsInd].sz = num;
f0100fb3:	89 ba e4 9b 1b f0    	mov    %edi,0xf01b9be4(%edx)
	arr_Ind[arrsInd].type = 4;
f0100fb9:	c7 82 e8 9b 1b f0 04 	movl   $0x4,0xf01b9be8(%edx)
f0100fc0:	00 00 00 
	arrsInd++;
f0100fc3:	40                   	inc    %eax
f0100fc4:	a3 20 9d 1b f0       	mov    %eax,0xf01b9d20
	intArrAddress = (unsigned int) ptr;
f0100fc9:	89 35 40 d5 11 f0    	mov    %esi,0xf011d540
	return 0;
}
f0100fcf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0100fd7:	5b                   	pop    %ebx
f0100fd8:	5e                   	pop    %esi
f0100fd9:	5f                   	pop    %edi
f0100fda:	5d                   	pop    %ebp
f0100fdb:	c3                   	ret    

f0100fdc <set_element_in_array>:

int set_element_in_array(int number_of_arguments, char **arguments) {
f0100fdc:	55                   	push   %ebp
f0100fdd:	89 e5                	mov    %esp,%ebp
f0100fdf:	57                   	push   %edi
f0100fe0:	56                   	push   %esi
f0100fe1:	53                   	push   %ebx
f0100fe2:	83 ec 10             	sub    $0x10,%esp
f0100fe5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int ind_arr;
	ind_arr = strtoul(arguments[1], NULL, 16);
f0100fe8:	6a 10                	push   $0x10
f0100fea:	6a 00                	push   $0x0
f0100fec:	ff 73 04             	pushl  0x4(%ebx)
f0100fef:	e8 9b 31 00 00       	call   f010418f <strtoul>
f0100ff4:	89 c7                	mov    %eax,%edi
	int* ptr = (int*) ind_arr;

	int index = strtol(arguments[2], NULL, 10);
f0100ff6:	83 c4 0c             	add    $0xc,%esp
f0100ff9:	6a 0a                	push   $0xa
f0100ffb:	6a 00                	push   $0x0
f0100ffd:	ff 73 08             	pushl  0x8(%ebx)
f0101000:	e8 9d 30 00 00       	call   f01040a2 <strtol>
f0101005:	89 c6                	mov    %eax,%esi
	int element = strtol(arguments[3], NULL, 10);
f0101007:	83 c4 0c             	add    $0xc,%esp
f010100a:	6a 0a                	push   $0xa
f010100c:	6a 00                	push   $0x0
f010100e:	ff 73 0c             	pushl  0xc(%ebx)
f0101011:	e8 8c 30 00 00       	call   f01040a2 <strtol>

	ptr = index + ptr;
	*ptr = element;
f0101016:	89 04 b7             	mov    %eax,(%edi,%esi,4)
	return 0;
}
f0101019:	b8 00 00 00 00       	mov    $0x0,%eax
f010101e:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0101021:	5b                   	pop    %ebx
f0101022:	5e                   	pop    %esi
f0101023:	5f                   	pop    %edi
f0101024:	5d                   	pop    %ebp
f0101025:	c3                   	ret    

f0101026 <find_in_array>:

int find_in_array(int number_of_arguments, char **arguments) {
f0101026:	55                   	push   %ebp
f0101027:	89 e5                	mov    %esp,%ebp
f0101029:	57                   	push   %edi
f010102a:	56                   	push   %esi
f010102b:	53                   	push   %ebx
f010102c:	83 ec 10             	sub    $0x10,%esp
f010102f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int my_arr = strtoul(arguments[1], NULL, 16);
f0101032:	6a 10                	push   $0x10
f0101034:	6a 00                	push   $0x0
f0101036:	ff 73 04             	pushl  0x4(%ebx)
f0101039:	e8 51 31 00 00       	call   f010418f <strtoul>
f010103e:	89 c7                	mov    %eax,%edi
	int num = strtol(arguments[2], NULL, 10);
f0101040:	83 c4 0c             	add    $0xc,%esp
f0101043:	6a 0a                	push   $0xa
f0101045:	6a 00                	push   $0x0
f0101047:	ff 73 08             	pushl  0x8(%ebx)
f010104a:	e8 53 30 00 00       	call   f01040a2 <strtol>
f010104f:	89 c6                	mov    %eax,%esi
	int i;
	int j = 0;
f0101051:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	for (i = 0; i < arrsInd; i++) {
f0101058:	bb 00 00 00 00       	mov    $0x0,%ebx
f010105d:	83 c4 10             	add    $0x10,%esp
f0101060:	b8 00 00 00 00       	mov    $0x0,%eax
f0101065:	3b 05 20 9d 1b f0    	cmp    0xf01b9d20,%eax
f010106b:	7d 5b                	jge    f01010c8 <find_in_array+0xa2>
		if (my_arr == arr_Ind[i].add) {
f010106d:	89 da                	mov    %ebx,%edx
f010106f:	c1 e2 04             	shl    $0x4,%edx
f0101072:	3b ba e0 9b 1b f0    	cmp    0xf01b9be0(%edx),%edi
f0101078:	75 45                	jne    f01010bf <find_in_array+0x99>
			j = 1;
f010107a:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
			int* ptr = (int*) my_arr;
f0101081:	89 f8                	mov    %edi,%eax
			int k;
			for (k = 0; k < arr_Ind[i].sz; k++) {
f0101083:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101088:	3b 8a e4 9b 1b f0    	cmp    0xf01b9be4(%edx),%ecx
f010108e:	7d 2f                	jge    f01010bf <find_in_array+0x99>
f0101090:	89 da                	mov    %ebx,%edx
f0101092:	c1 e2 04             	shl    $0x4,%edx
				if (*ptr == num) {
f0101095:	39 30                	cmp    %esi,(%eax)
f0101097:	75 1a                	jne    f01010b3 <find_in_array+0x8d>
					j = 2;
f0101099:	c7 45 f0 02 00 00 00 	movl   $0x2,0xfffffff0(%ebp)
					cprintf("Element was found at index: %d\n", k);
f01010a0:	83 ec 08             	sub    $0x8,%esp
f01010a3:	51                   	push   %ecx
f01010a4:	68 20 4e 10 f0       	push   $0xf0104e20
f01010a9:	e8 50 1e 00 00       	call   f0102efe <cprintf>
					break;
f01010ae:	83 c4 10             	add    $0x10,%esp
f01010b1:	eb 0c                	jmp    f01010bf <find_in_array+0x99>
				}
				ptr++;
f01010b3:	83 c0 04             	add    $0x4,%eax
f01010b6:	41                   	inc    %ecx
f01010b7:	3b 8a e4 9b 1b f0    	cmp    0xf01b9be4(%edx),%ecx
f01010bd:	7c d6                	jl     f0101095 <find_in_array+0x6f>
f01010bf:	43                   	inc    %ebx
f01010c0:	3b 1d 20 9d 1b f0    	cmp    0xf01b9d20,%ebx
f01010c6:	7c a5                	jl     f010106d <find_in_array+0x47>
			}
		}
	}
	if (j == 0)
f01010c8:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f01010cc:	75 0a                	jne    f01010d8 <find_in_array+0xb2>
		cprintf("No array was created at this address.\n");
f01010ce:	83 ec 0c             	sub    $0xc,%esp
f01010d1:	68 40 4e 10 f0       	push   $0xf0104e40
f01010d6:	eb 0e                	jmp    f01010e6 <find_in_array+0xc0>
	else if (j == 1)
f01010d8:	83 7d f0 01          	cmpl   $0x1,0xfffffff0(%ebp)
f01010dc:	75 10                	jne    f01010ee <find_in_array+0xc8>
		cprintf("Element wasn't found\n");
f01010de:	83 ec 0c             	sub    $0xc,%esp
f01010e1:	68 22 4a 10 f0       	push   $0xf0104a22
f01010e6:	e8 13 1e 00 00       	call   f0102efe <cprintf>
f01010eb:	83 c4 10             	add    $0x10,%esp
	return 0;
}
f01010ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f3:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01010f6:	5b                   	pop    %ebx
f01010f7:	5e                   	pop    %esi
f01010f8:	5f                   	pop    %edi
f01010f9:	5d                   	pop    %ebp
f01010fa:	c3                   	ret    

f01010fb <write_block>:

int write_block(int number_of_arguments, char **arguments) {
f01010fb:	55                   	push   %ebp
f01010fc:	89 e5                	mov    %esp,%ebp
f01010fe:	57                   	push   %edi
f01010ff:	56                   	push   %esi
f0101100:	53                   	push   %ebx
f0101101:	81 ec 20 04 00 00    	sub    $0x420,%esp
f0101107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int arr = strtoul(arguments[1], NULL, 16);
f010110a:	6a 10                	push   $0x10
f010110c:	6a 00                	push   $0x0
f010110e:	ff 73 04             	pushl  0x4(%ebx)
f0101111:	e8 79 30 00 00       	call   f010418f <strtoul>
f0101116:	89 c6                	mov    %eax,%esi
	int maxi = strtol(arguments[2], NULL, 10);
f0101118:	83 c4 0c             	add    $0xc,%esp
f010111b:	6a 0a                	push   $0xa
f010111d:	6a 00                	push   $0x0
f010111f:	ff 73 08             	pushl  0x8(%ebx)
f0101122:	e8 7b 2f 00 00       	call   f01040a2 <strtol>
f0101127:	89 85 e4 fb ff ff    	mov    %eax,0xfffffbe4(%ebp)
	int count = 0;
f010112d:	bf 00 00 00 00       	mov    $0x0,%edi
	int check = 0;
f0101132:	c7 85 e0 fb ff ff 00 	movl   $0x0,0xfffffbe0(%ebp)
f0101139:	00 00 00 
	unsigned char* ptr = (unsigned char*) (arr + KERNEL_BASE);
f010113c:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	char line[1024];
	while (1) {
f0101142:	83 c4 10             	add    $0x10,%esp
		cprintf("%x : ", ptr);
f0101145:	83 ec 08             	sub    $0x8,%esp
f0101148:	56                   	push   %esi
f0101149:	68 38 4a 10 f0       	push   $0xf0104a38
f010114e:	e8 ab 1d 00 00       	call   f0102efe <cprintf>
		readline("", line);
f0101153:	83 c4 08             	add    $0x8,%esp
f0101156:	8d 85 e8 fb ff ff    	lea    0xfffffbe8(%ebp),%eax
f010115c:	50                   	push   %eax
f010115d:	68 63 49 10 f0       	push   $0xf0104963
f0101162:	e8 e5 2b 00 00       	call   f0103d4c <readline>
		int i;
		for (i = 0; i < strlen(line); i++) {
f0101167:	bb 00 00 00 00       	mov    $0x0,%ebx
f010116c:	83 c4 10             	add    $0x10,%esp
f010116f:	eb 32                	jmp    f01011a3 <write_block+0xa8>
			*ptr = line[i];
f0101171:	8a 84 2b e8 fb ff ff 	mov    0xfffffbe8(%ebx,%ebp,1),%al
f0101178:	88 06                	mov    %al,(%esi)
			ptr++;
f010117a:	46                   	inc    %esi
			count++;
f010117b:	47                   	inc    %edi
			if (line[i] == '$' || count == maxi) {
f010117c:	80 bc 2b e8 fb ff ff 	cmpb   $0x24,0xfffffbe8(%ebx,%ebp,1)
f0101183:	24 
f0101184:	0f 94 c2             	sete   %dl
f0101187:	3b bd e4 fb ff ff    	cmp    0xfffffbe4(%ebp),%edi
f010118d:	0f 94 c0             	sete   %al
f0101190:	09 d0                	or     %edx,%eax
f0101192:	a8 01                	test   $0x1,%al
f0101194:	74 0c                	je     f01011a2 <write_block+0xa7>
				check = 1;
f0101196:	c7 85 e0 fb ff ff 01 	movl   $0x1,0xfffffbe0(%ebp)
f010119d:	00 00 00 
				break;
f01011a0:	eb 17                	jmp    f01011b9 <write_block+0xbe>
f01011a2:	43                   	inc    %ebx
f01011a3:	83 ec 0c             	sub    $0xc,%esp
f01011a6:	8d 85 e8 fb ff ff    	lea    0xfffffbe8(%ebp),%eax
f01011ac:	50                   	push   %eax
f01011ad:	e8 7e 2c 00 00       	call   f0103e30 <strlen>
f01011b2:	83 c4 10             	add    $0x10,%esp
f01011b5:	39 c3                	cmp    %eax,%ebx
f01011b7:	7c b8                	jl     f0101171 <write_block+0x76>
			}
		}
		if (check == 1)
f01011b9:	83 bd e0 fb ff ff 01 	cmpl   $0x1,0xfffffbe0(%ebp)
f01011c0:	75 83                	jne    f0101145 <write_block+0x4a>
			break;
	}
	return 0;
}
f01011c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011c7:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01011ca:	5b                   	pop    %ebx
f01011cb:	5e                   	pop    %esi
f01011cc:	5f                   	pop    %edi
f01011cd:	5d                   	pop    %ebp
f01011ce:	c3                   	ret    

f01011cf <new>:
int new(unsigned char** start, int sze) {
f01011cf:	55                   	push   %ebp
f01011d0:	89 e5                	mov    %esp,%ebp
f01011d2:	57                   	push   %edi
f01011d3:	56                   	push   %esi
f01011d4:	53                   	push   %ebx
f01011d5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01011d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned char* ptr;
	*start = (unsigned char*) intArrAddress;
f01011db:	8b 1d 40 d5 11 f0    	mov    0xf011d540,%ebx
f01011e1:	89 1f                	mov    %ebx,(%edi)
	ptr = *start;
	ptr = ptr + sze;
f01011e3:	01 f3                	add    %esi,%ebx
	arr_Ind[arrsInd].add = intArrAddress;
f01011e5:	8b 0d 20 9d 1b f0    	mov    0xf01b9d20,%ecx
f01011eb:	89 c8                	mov    %ecx,%eax
f01011ed:	c1 e0 04             	shl    $0x4,%eax
f01011f0:	8b 15 40 d5 11 f0    	mov    0xf011d540,%edx
f01011f6:	89 90 e0 9b 1b f0    	mov    %edx,0xf01b9be0(%eax)
	arr_Ind[arrsInd].sz = sze;
f01011fc:	89 b0 e4 9b 1b f0    	mov    %esi,0xf01b9be4(%eax)
	arr_Ind[arrsInd].type = 1;
f0101202:	c7 80 e8 9b 1b f0 01 	movl   $0x1,0xf01b9be8(%eax)
f0101209:	00 00 00 
	arr_Ind[arrsInd].ptr_add = start;
f010120c:	89 b8 ec 9b 1b f0    	mov    %edi,0xf01b9bec(%eax)
	arrsInd++;
f0101212:	41                   	inc    %ecx
f0101213:	89 0d 20 9d 1b f0    	mov    %ecx,0xf01b9d20
	intArrAddress = (unsigned int) ptr;
f0101219:	89 1d 40 d5 11 f0    	mov    %ebx,0xf011d540
	return 0;
}
f010121f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101224:	5b                   	pop    %ebx
f0101225:	5e                   	pop    %esi
f0101226:	5f                   	pop    %edi
f0101227:	5d                   	pop    %ebp
f0101228:	c3                   	ret    

f0101229 <delete>:
int delete(unsigned char** arrr) {
f0101229:	55                   	push   %ebp
f010122a:	89 e5                	mov    %esp,%ebp
f010122c:	57                   	push   %edi
f010122d:	56                   	push   %esi
f010122e:	53                   	push   %ebx
f010122f:	83 ec 08             	sub    $0x8,%esp
f0101232:	8b 4d 08             	mov    0x8(%ebp),%ecx
	unsigned int start = (unsigned int) *arrr;
	//cprintf("%x\n",*arrr);
	int i;
	for (i = 0; i < arrsInd; i++) {
f0101235:	bf 00 00 00 00       	mov    $0x0,%edi
f010123a:	3b 3d 20 9d 1b f0    	cmp    0xf01b9d20,%edi
f0101240:	0f 8d db 00 00 00    	jge    f0101321 <delete+0xf8>
		if ((unsigned int) *arrr == arr_Ind[i].add) {
f0101246:	89 f8                	mov    %edi,%eax
f0101248:	c1 e0 04             	shl    $0x4,%eax
f010124b:	8b 11                	mov    (%ecx),%edx
f010124d:	3b 90 e0 9b 1b f0    	cmp    0xf01b9be0(%eax),%edx
f0101253:	0f 85 bb 00 00 00    	jne    f0101314 <delete+0xeb>
			unsigned int arrs = (unsigned int) *arrr;
f0101259:	89 55 f0             	mov    %edx,0xfffffff0(%ebp)
			int k = i + 1;
f010125c:	8d 47 01             	lea    0x1(%edi),%eax
f010125f:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
			for (; k < arrsInd; k++) {
f0101262:	3b 05 20 9d 1b f0    	cmp    0xf01b9d20,%eax
f0101268:	0f 8d b3 00 00 00    	jge    f0101321 <delete+0xf8>
				if (arr_Ind[k].type == 4) {
f010126e:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101271:	c1 e0 04             	shl    $0x4,%eax
f0101274:	89 c6                	mov    %eax,%esi
f0101276:	83 b8 e8 9b 1b f0 04 	cmpl   $0x4,0xf01b9be8(%eax)
f010127d:	75 2b                	jne    f01012aa <delete+0x81>
					int* ptr;
					int* pp;
					ptr = (int*) arrs;
f010127f:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
					pp = (int*) arr_Ind[k].add;
f0101282:	8b 90 e0 9b 1b f0    	mov    0xf01b9be0(%eax),%edx
					int l;
					for (l = 0; l < arr_Ind[k].sz; l++) {
f0101288:	bb 00 00 00 00       	mov    $0x0,%ebx
f010128d:	3b 98 e4 9b 1b f0    	cmp    0xf01b9be4(%eax),%ebx
f0101293:	7d 42                	jge    f01012d7 <delete+0xae>
						*ptr = *pp;
f0101295:	8b 02                	mov    (%edx),%eax
f0101297:	89 01                	mov    %eax,(%ecx)
						ptr++;
f0101299:	83 c1 04             	add    $0x4,%ecx
						pp++;
f010129c:	83 c2 04             	add    $0x4,%edx
f010129f:	43                   	inc    %ebx
f01012a0:	3b 9e e4 9b 1b f0    	cmp    0xf01b9be4(%esi),%ebx
f01012a6:	7c ed                	jl     f0101295 <delete+0x6c>
f01012a8:	eb 2d                	jmp    f01012d7 <delete+0xae>
					}
					*arr_Ind[k].ptr_add = (unsigned char*) arrs;
					arr_Ind[k].add = arrs;
					arrs = (unsigned int) ptr;
				} else {
					unsigned char* ptr;
					unsigned char* pp;
					ptr = (unsigned char*) arrs;
f01012aa:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
					pp = (unsigned char*) arr_Ind[k].add;
f01012ad:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01012b0:	c1 e0 04             	shl    $0x4,%eax
f01012b3:	89 c6                	mov    %eax,%esi
f01012b5:	8b 90 e0 9b 1b f0    	mov    0xf01b9be0(%eax),%edx
					int l;
					for (l = 0; l < arr_Ind[k].sz; l++) {
f01012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012c0:	3b 98 e4 9b 1b f0    	cmp    0xf01b9be4(%eax),%ebx
f01012c6:	7d 0f                	jge    f01012d7 <delete+0xae>
						*ptr = *pp;
f01012c8:	8a 02                	mov    (%edx),%al
f01012ca:	88 01                	mov    %al,(%ecx)
						ptr++;
f01012cc:	41                   	inc    %ecx
						pp++;
f01012cd:	42                   	inc    %edx
f01012ce:	43                   	inc    %ebx
f01012cf:	3b 9e e4 9b 1b f0    	cmp    0xf01b9be4(%esi),%ebx
f01012d5:	7c f1                	jl     f01012c8 <delete+0x9f>
					}
					*arr_Ind[k].ptr_add = (unsigned char*) arrs;
f01012d7:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f01012da:	c1 e2 04             	shl    $0x4,%edx
f01012dd:	8b 82 ec 9b 1b f0    	mov    0xf01b9bec(%edx),%eax
f01012e3:	8b 5d f0             	mov    0xfffffff0(%ebp),%ebx
f01012e6:	89 18                	mov    %ebx,(%eax)
					arr_Ind[k].add = arrs;
f01012e8:	89 9a e0 9b 1b f0    	mov    %ebx,0xf01b9be0(%edx)
					arrs = (unsigned int) ptr;
f01012ee:	89 4d f0             	mov    %ecx,0xfffffff0(%ebp)
				}
				arr_Ind[i].add = (unsigned int) NULL;
f01012f1:	89 f8                	mov    %edi,%eax
f01012f3:	c1 e0 04             	shl    $0x4,%eax
f01012f6:	c7 80 e0 9b 1b f0 00 	movl   $0x0,0xf01b9be0(%eax)
f01012fd:	00 00 00 
f0101300:	ff 45 ec             	incl   0xffffffec(%ebp)
f0101303:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101306:	3b 05 20 9d 1b f0    	cmp    0xf01b9d20,%eax
f010130c:	0f 8c 5c ff ff ff    	jl     f010126e <delete+0x45>

			}
			break;
f0101312:	eb 0d                	jmp    f0101321 <delete+0xf8>
f0101314:	47                   	inc    %edi
f0101315:	3b 3d 20 9d 1b f0    	cmp    0xf01b9d20,%edi
f010131b:	0f 8c 25 ff ff ff    	jl     f0101246 <delete+0x1d>
		}
	}
	return 0;
}
f0101321:	b8 00 00 00 00       	mov    $0x0,%eax
f0101326:	83 c4 08             	add    $0x8,%esp
f0101329:	5b                   	pop    %ebx
f010132a:	5e                   	pop    %esi
f010132b:	5f                   	pop    %edi
f010132c:	5d                   	pop    %ebp
f010132d:	c3                   	ret    

f010132e <check_new_delete>:

int check_new_delete(int number_of_arguments, char **arguments) {
f010132e:	55                   	push   %ebp
f010132f:	89 e5                	mov    %esp,%ebp
f0101331:	83 ec 20             	sub    $0x20,%esp
	unsigned char *array1 = NULL, *array2 = NULL, *array3 = NULL;
f0101334:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)
f010133b:	c7 45 f8 00 00 00 00 	movl   $0x0,0xfffffff8(%ebp)
f0101342:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	new(&array1, 10);
f0101349:	6a 0a                	push   $0xa
f010134b:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f010134e:	50                   	push   %eax
f010134f:	e8 7b fe ff ff       	call   f01011cf <new>
	cprintf("array1 address after new %x\n", array1);
f0101354:	83 c4 08             	add    $0x8,%esp
f0101357:	ff 75 fc             	pushl  0xfffffffc(%ebp)
f010135a:	68 3e 4a 10 f0       	push   $0xf0104a3e
f010135f:	e8 9a 1b 00 00       	call   f0102efe <cprintf>
	new(&array2, 20);
f0101364:	83 c4 08             	add    $0x8,%esp
f0101367:	6a 14                	push   $0x14
f0101369:	8d 45 f8             	lea    0xfffffff8(%ebp),%eax
f010136c:	50                   	push   %eax
f010136d:	e8 5d fe ff ff       	call   f01011cf <new>
	cprintf("array2 address after new %x\n", array2);
f0101372:	83 c4 08             	add    $0x8,%esp
f0101375:	ff 75 f8             	pushl  0xfffffff8(%ebp)
f0101378:	68 5b 4a 10 f0       	push   $0xf0104a5b
f010137d:	e8 7c 1b 00 00       	call   f0102efe <cprintf>
	new(&array3, 5);
f0101382:	83 c4 08             	add    $0x8,%esp
f0101385:	6a 05                	push   $0x5
f0101387:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f010138a:	50                   	push   %eax
f010138b:	e8 3f fe ff ff       	call   f01011cf <new>
	cprintf("array3 address after new %x\n", array3);
f0101390:	83 c4 08             	add    $0x8,%esp
f0101393:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101396:	68 78 4a 10 f0       	push   $0xf0104a78
f010139b:	e8 5e 1b 00 00       	call   f0102efe <cprintf>
	*(array2 + 10) = 'a';
f01013a0:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f01013a3:	c6 40 0a 61          	movb   $0x61,0xa(%eax)
	cprintf("The tenth element in array2 after new: %c\n", *(array2 + 10));
f01013a7:	83 c4 08             	add    $0x8,%esp
f01013aa:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f01013ad:	8a 40 0a             	mov    0xa(%eax),%al
f01013b0:	25 ff 00 00 00       	and    $0xff,%eax
f01013b5:	50                   	push   %eax
f01013b6:	68 80 4e 10 f0       	push   $0xf0104e80
f01013bb:	e8 3e 1b 00 00       	call   f0102efe <cprintf>
	delete(&array1);
f01013c0:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f01013c3:	89 04 24             	mov    %eax,(%esp)
f01013c6:	e8 5e fe ff ff       	call   f0101229 <delete>
	cprintf("array2 address after delete %x\n", array2);
f01013cb:	83 c4 08             	add    $0x8,%esp
f01013ce:	ff 75 f8             	pushl  0xfffffff8(%ebp)
f01013d1:	68 c0 4e 10 f0       	push   $0xf0104ec0
f01013d6:	e8 23 1b 00 00       	call   f0102efe <cprintf>
	cprintf("array3 address after delete %x\n", array3);
f01013db:	83 c4 08             	add    $0x8,%esp
f01013de:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f01013e1:	68 e0 4e 10 f0       	push   $0xf0104ee0
f01013e6:	e8 13 1b 00 00       	call   f0102efe <cprintf>
	cprintf("The tenth element in array2 after delete: %c\n", *(array2 + 10));
f01013eb:	83 c4 08             	add    $0x8,%esp
f01013ee:	8b 45 f8             	mov    0xfffffff8(%ebp),%eax
f01013f1:	8a 40 0a             	mov    0xa(%eax),%al
f01013f4:	25 ff 00 00 00       	and    $0xff,%eax
f01013f9:	50                   	push   %eax
f01013fa:	68 00 4f 10 f0       	push   $0xf0104f00
f01013ff:	e8 fa 1a 00 00       	call   f0102efe <cprintf>
	return 0;
}
f0101404:	b8 00 00 00 00       	mov    $0x0,%eax
f0101409:	c9                   	leave  
f010140a:	c3                   	ret    

f010140b <command_search>:

int command_search(int number_of_arguments, char **arguments) {
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	56                   	push   %esi
f010140f:	53                   	push   %ebx
f0101410:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int base = KERNEL_BASE;
f0101413:	bb 00 00 00 f0       	mov    $0xf0000000,%ebx
	int sz = strtol(arguments[2], NULL, 10);
f0101418:	83 ec 04             	sub    $0x4,%esp
f010141b:	6a 0a                	push   $0xa
f010141d:	6a 00                	push   $0x0
f010141f:	ff 76 08             	pushl  0x8(%esi)
f0101422:	e8 7b 2c 00 00       	call   f01040a2 <strtol>
	if (sz == 1) {
f0101427:	83 c4 10             	add    $0x10,%esp
f010142a:	83 f8 01             	cmp    $0x1,%eax
f010142d:	75 3d                	jne    f010146c <command_search+0x61>
		char* ptr;
		char check = (char) strtol(arguments[1], NULL, 16);
f010142f:	83 ec 04             	sub    $0x4,%esp
f0101432:	6a 10                	push   $0x10
f0101434:	6a 00                	push   $0x0
f0101436:	ff 76 04             	pushl  0x4(%esi)
f0101439:	e8 64 2c 00 00       	call   f01040a2 <strtol>
f010143e:	89 c6                	mov    %eax,%esi
		while (base != 0xf100000f) {
f0101440:	83 c4 10             	add    $0x10,%esp
			ptr = (char*) base;
			if (*ptr == check)
f0101443:	89 f0                	mov    %esi,%eax
f0101445:	38 03                	cmp    %al,(%ebx)
f0101447:	75 15                	jne    f010145e <command_search+0x53>
				cprintf("%c found at location %x\n", *ptr, ptr);
f0101449:	83 ec 04             	sub    $0x4,%esp
f010144c:	53                   	push   %ebx
f010144d:	0f be 03             	movsbl (%ebx),%eax
f0101450:	50                   	push   %eax
f0101451:	68 95 4a 10 f0       	push   $0xf0104a95
f0101456:	e8 a3 1a 00 00       	call   f0102efe <cprintf>
f010145b:	83 c4 10             	add    $0x10,%esp
			base++;
f010145e:	43                   	inc    %ebx
f010145f:	81 fb 0f 00 00 f1    	cmp    $0xf100000f,%ebx
f0101465:	75 dc                	jne    f0101443 <command_search+0x38>
f0101467:	e9 82 00 00 00       	jmp    f01014ee <command_search+0xe3>
		}
	} else if (sz == 2) {
f010146c:	83 f8 02             	cmp    $0x2,%eax
f010146f:	75 41                	jne    f01014b2 <command_search+0xa7>
		short* ptr;
		short check = (short) strtol(arguments[1], NULL, 16);
f0101471:	83 ec 04             	sub    $0x4,%esp
f0101474:	6a 10                	push   $0x10
f0101476:	6a 00                	push   $0x0
f0101478:	ff 76 04             	pushl  0x4(%esi)
f010147b:	e8 22 2c 00 00       	call   f01040a2 <strtol>
f0101480:	89 c6                	mov    %eax,%esi
		while (base != 0xf100000f) {
f0101482:	83 c4 10             	add    $0x10,%esp
f0101485:	81 fb 0f 00 00 f1    	cmp    $0xf100000f,%ebx
f010148b:	74 61                	je     f01014ee <command_search+0xe3>
			ptr = (short*) base;
			if (*ptr == check)
f010148d:	66 39 33             	cmp    %si,(%ebx)
f0101490:	75 15                	jne    f01014a7 <command_search+0x9c>
				cprintf("%d found at location %x\n", *ptr, ptr);
f0101492:	83 ec 04             	sub    $0x4,%esp
f0101495:	53                   	push   %ebx
f0101496:	0f bf 03             	movswl (%ebx),%eax
f0101499:	50                   	push   %eax
f010149a:	68 ae 4a 10 f0       	push   $0xf0104aae
f010149f:	e8 5a 1a 00 00       	call   f0102efe <cprintf>
f01014a4:	83 c4 10             	add    $0x10,%esp
			base++;
f01014a7:	43                   	inc    %ebx
f01014a8:	81 fb 0f 00 00 f1    	cmp    $0xf100000f,%ebx
f01014ae:	75 dd                	jne    f010148d <command_search+0x82>
f01014b0:	eb 3c                	jmp    f01014ee <command_search+0xe3>
		}
	} else {

		int* ptr;
		int check = (int) strtol(arguments[1], NULL, 16);
f01014b2:	83 ec 04             	sub    $0x4,%esp
f01014b5:	6a 10                	push   $0x10
f01014b7:	6a 00                	push   $0x0
f01014b9:	ff 76 04             	pushl  0x4(%esi)
f01014bc:	e8 e1 2b 00 00       	call   f01040a2 <strtol>
f01014c1:	89 c6                	mov    %eax,%esi
		while (base <= 0xf100000f) {
f01014c3:	83 c4 10             	add    $0x10,%esp
f01014c6:	81 fb 0f 00 00 f1    	cmp    $0xf100000f,%ebx
f01014cc:	77 20                	ja     f01014ee <command_search+0xe3>
			ptr = (int*) base;
			if (*ptr == check)
f01014ce:	39 33                	cmp    %esi,(%ebx)
f01014d0:	75 13                	jne    f01014e5 <command_search+0xda>
				cprintf("%d found at location %x\n", *ptr, ptr);
f01014d2:	83 ec 04             	sub    $0x4,%esp
f01014d5:	53                   	push   %ebx
f01014d6:	ff 33                	pushl  (%ebx)
f01014d8:	68 ae 4a 10 f0       	push   $0xf0104aae
f01014dd:	e8 1c 1a 00 00       	call   f0102efe <cprintf>
f01014e2:	83 c4 10             	add    $0x10,%esp
			base++;
f01014e5:	43                   	inc    %ebx
f01014e6:	81 fb 0f 00 00 f1    	cmp    $0xf100000f,%ebx
f01014ec:	76 e0                	jbe    f01014ce <command_search+0xc3>
		}
	}
	return 0;
}
f01014ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01014f3:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01014f6:	5b                   	pop    %ebx
f01014f7:	5e                   	pop    %esi
f01014f8:	5d                   	pop    %ebp
f01014f9:	c3                   	ret    
	...

f01014fc <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

int nvram_read(int r)
{	
f01014fc:	55                   	push   %ebp
f01014fd:	89 e5                	mov    %esp,%ebp
f01014ff:	56                   	push   %esi
f0101500:	53                   	push   %ebx
f0101501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101504:	83 ec 0c             	sub    $0xc,%esp
f0101507:	53                   	push   %ebx
f0101508:	e8 8b 19 00 00       	call   f0102e98 <mc146818_read>
f010150d:	89 c6                	mov    %eax,%esi
f010150f:	43                   	inc    %ebx
f0101510:	89 1c 24             	mov    %ebx,(%esp)
f0101513:	e8 80 19 00 00       	call   f0102e98 <mc146818_read>
f0101518:	c1 e0 08             	shl    $0x8,%eax
f010151b:	09 c6                	or     %eax,%esi
}
f010151d:	89 f0                	mov    %esi,%eax
f010151f:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0101522:	5b                   	pop    %ebx
f0101523:	5e                   	pop    %esi
f0101524:	5d                   	pop    %ebp
f0101525:	c3                   	ret    

f0101526 <detect_memory>:
	
void detect_memory()
{
f0101526:	55                   	push   %ebp
f0101527:	89 e5                	mov    %esp,%ebp
f0101529:	83 ec 14             	sub    $0x14,%esp
	// CMOS tells us how many kilobytes there are
	size_of_base_mem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PAGE_SIZE);
f010152c:	6a 15                	push   $0x15
f010152e:	e8 c9 ff ff ff       	call   f01014fc <nvram_read>
f0101533:	c1 e0 0a             	shl    $0xa,%eax
f0101536:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010153b:	a3 b4 a5 1b f0       	mov    %eax,0xf01ba5b4
	size_of_extended_mem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PAGE_SIZE);
f0101540:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101547:	e8 b0 ff ff ff       	call   f01014fc <nvram_read>
f010154c:	83 c4 10             	add    $0x10,%esp
f010154f:	c1 e0 0a             	shl    $0xa,%eax
f0101552:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101557:	a3 ac a5 1b f0       	mov    %eax,0xf01ba5ac

	// Calculate the maxmium physical address based on whether
	// or not there is any extended memory.  See comment in ../inc/mmu.h.
	if (size_of_extended_mem)
f010155c:	85 c0                	test   %eax,%eax
f010155e:	74 07                	je     f0101567 <detect_memory+0x41>
		maxpa = PHYS_EXTENDED_MEM + size_of_extended_mem;
f0101560:	05 00 00 10 00       	add    $0x100000,%eax
f0101565:	eb 05                	jmp    f010156c <detect_memory+0x46>
	else
		maxpa = size_of_extended_mem;
f0101567:	a1 ac a5 1b f0       	mov    0xf01ba5ac,%eax
f010156c:	a3 b0 a5 1b f0       	mov    %eax,0xf01ba5b0

	number_of_frames = maxpa / PAGE_SIZE;
f0101571:	a1 b0 a5 1b f0       	mov    0xf01ba5b0,%eax
f0101576:	89 c2                	mov    %eax,%edx
f0101578:	c1 ea 0c             	shr    $0xc,%edx
f010157b:	89 15 a8 a5 1b f0    	mov    %edx,0xf01ba5a8

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0101581:	83 ec 08             	sub    $0x8,%esp
f0101584:	c1 e8 0a             	shr    $0xa,%eax
f0101587:	50                   	push   %eax
f0101588:	68 40 4f 10 f0       	push   $0xf0104f40
f010158d:	e8 6c 19 00 00       	call   f0102efe <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(size_of_base_mem/1024), (int)(size_of_extended_mem/1024));
f0101592:	83 c4 0c             	add    $0xc,%esp
f0101595:	a1 ac a5 1b f0       	mov    0xf01ba5ac,%eax
f010159a:	c1 e8 0a             	shr    $0xa,%eax
f010159d:	50                   	push   %eax
f010159e:	a1 b4 a5 1b f0       	mov    0xf01ba5b4,%eax
f01015a3:	c1 e8 0a             	shr    $0xa,%eax
f01015a6:	50                   	push   %eax
f01015a7:	68 86 55 10 f0       	push   $0xf0105586
f01015ac:	e8 4d 19 00 00       	call   f0102efe <cprintf>
}
f01015b1:	c9                   	leave  
f01015b2:	c3                   	ret    

f01015b3 <check_boot_pgdir>:

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
f01015b3:	55                   	push   %ebp
f01015b4:	89 e5                	mov    %esp,%ebp
f01015b6:	56                   	push   %esi
f01015b7:	53                   	push   %ebx
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
f01015b8:	a1 a8 a5 1b f0       	mov    0xf01ba5a8,%eax
f01015bd:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01015c0:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
f01015c7:	89 c2                	mov    %eax,%edx
f01015c9:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01015cf:	89 c6                	mov    %eax,%esi
f01015d1:	29 d6                	sub    %edx,%esi
	for (i = 0; i < n; i += PAGE_SIZE)
f01015d3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015d8:	39 f3                	cmp    %esi,%ebx
f01015da:	73 54                	jae    f0101630 <check_boot_pgdir+0x7d>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);
f01015dc:	83 ec 08             	sub    $0x8,%esp
f01015df:	8d 83 00 00 00 ef    	lea    0xef000000(%ebx),%eax
f01015e5:	50                   	push   %eax
f01015e6:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f01015ec:	e8 66 01 00 00       	call   f0101757 <check_va2pa>
f01015f1:	89 c2                	mov    %eax,%edx
f01015f3:	83 c4 10             	add    $0x10,%esp
f01015f6:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f01015fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101600:	77 08                	ja     f010160a <check_boot_pgdir+0x57>
f0101602:	50                   	push   %eax
f0101603:	68 80 4f 10 f0       	push   $0xf0104f80
f0101608:	eb 15                	jmp    f010161f <check_boot_pgdir+0x6c>
f010160a:	8d 84 03 00 00 00 10 	lea    0x10000000(%ebx,%eax,1),%eax
f0101611:	39 c2                	cmp    %eax,%edx
f0101613:	74 11                	je     f0101626 <check_boot_pgdir+0x73>
f0101615:	68 c0 4f 10 f0       	push   $0xf0104fc0
f010161a:	68 a2 55 10 f0       	push   $0xf01055a2
f010161f:	6a 5e                	push   $0x5e
f0101621:	e9 0a 01 00 00       	jmp    f0101730 <check_boot_pgdir+0x17d>
f0101626:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010162c:	39 f3                	cmp    %esi,%ebx
f010162e:	72 ac                	jb     f01015dc <check_boot_pgdir+0x29>

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0101630:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);
f0101635:	83 ec 08             	sub    $0x8,%esp
f0101638:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f010163e:	50                   	push   %eax
f010163f:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101645:	e8 0d 01 00 00       	call   f0101757 <check_va2pa>
f010164a:	83 c4 10             	add    $0x10,%esp
f010164d:	39 d8                	cmp    %ebx,%eax
f010164f:	74 11                	je     f0101662 <check_boot_pgdir+0xaf>
f0101651:	68 40 50 10 f0       	push   $0xf0105040
f0101656:	68 a2 55 10 f0       	push   $0xf01055a2
f010165b:	6a 62                	push   $0x62
f010165d:	e9 ce 00 00 00       	jmp    f0101730 <check_boot_pgdir+0x17d>
f0101662:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101668:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
f010166e:	75 c5                	jne    f0101635 <check_boot_pgdir+0x82>

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0101670:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101675:	be 00 50 11 f0       	mov    $0xf0115000,%esi
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);
f010167a:	83 ec 08             	sub    $0x8,%esp
f010167d:	8d 83 00 80 bf ef    	lea    0xefbf8000(%ebx),%eax
f0101683:	50                   	push   %eax
f0101684:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f010168a:	e8 c8 00 00 00       	call   f0101757 <check_va2pa>
f010168f:	89 c2                	mov    %eax,%edx
f0101691:	83 c4 10             	add    $0x10,%esp
f0101694:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010169a:	77 0c                	ja     f01016a8 <check_boot_pgdir+0xf5>
f010169c:	68 00 50 11 f0       	push   $0xf0115000
f01016a1:	68 80 4f 10 f0       	push   $0xf0104f80
f01016a6:	eb 15                	jmp    f01016bd <check_boot_pgdir+0x10a>
f01016a8:	8d 84 33 00 00 00 10 	lea    0x10000000(%ebx,%esi,1),%eax
f01016af:	39 c2                	cmp    %eax,%edx
f01016b1:	74 0e                	je     f01016c1 <check_boot_pgdir+0x10e>
f01016b3:	68 80 50 10 f0       	push   $0xf0105080
f01016b8:	68 a2 55 10 f0       	push   $0xf01055a2
f01016bd:	6a 66                	push   $0x66
f01016bf:	eb 6f                	jmp    f0101730 <check_boot_pgdir+0x17d>
f01016c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016c7:	81 fb ff 7f 00 00    	cmp    $0x7fff,%ebx
f01016cd:	76 ab                	jbe    f010167a <check_boot_pgdir+0xc7>

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (i) {
f01016d4:	8d 83 45 fc ff ff    	lea    0xfffffc45(%ebx),%eax
f01016da:	83 f8 04             	cmp    $0x4,%eax
f01016dd:	77 19                	ja     f01016f8 <check_boot_pgdir+0x145>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
f01016df:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f01016e4:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f01016e8:	75 50                	jne    f010173a <check_boot_pgdir+0x187>
f01016ea:	68 b7 55 10 f0       	push   $0xf01055b7
f01016ef:	68 a2 55 10 f0       	push   $0xf01055a2
f01016f4:	6a 70                	push   $0x70
f01016f6:	eb 38                	jmp    f0101730 <check_boot_pgdir+0x17d>
			break;
		default:
			if (i >= PDX(KERNEL_BASE))
f01016f8:	81 fb bf 03 00 00    	cmp    $0x3bf,%ebx
f01016fe:	76 19                	jbe    f0101719 <check_boot_pgdir+0x166>
				assert(ptr_page_directory[i]);
f0101700:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0101705:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f0101709:	75 2f                	jne    f010173a <check_boot_pgdir+0x187>
f010170b:	68 b7 55 10 f0       	push   $0xf01055b7
f0101710:	68 a2 55 10 f0       	push   $0xf01055a2
f0101715:	6a 74                	push   $0x74
f0101717:	eb 17                	jmp    f0101730 <check_boot_pgdir+0x17d>
			else				
				assert(ptr_page_directory[i] == 0);
f0101719:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f010171e:	83 3c 98 00          	cmpl   $0x0,(%eax,%ebx,4)
f0101722:	74 16                	je     f010173a <check_boot_pgdir+0x187>
f0101724:	68 cd 55 10 f0       	push   $0xf01055cd
f0101729:	68 a2 55 10 f0       	push   $0xf01055a2
f010172e:	6a 76                	push   $0x76
f0101730:	68 e8 55 10 f0       	push   $0xf01055e8
f0101735:	e8 c4 e9 ff ff       	call   f01000fe <_panic>
f010173a:	43                   	inc    %ebx
f010173b:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0101741:	76 91                	jbe    f01016d4 <check_boot_pgdir+0x121>
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0101743:	83 ec 0c             	sub    $0xc,%esp
f0101746:	68 00 51 10 f0       	push   $0xf0105100
f010174b:	e8 ae 17 00 00       	call   f0102efe <cprintf>
}
f0101750:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0101753:	5b                   	pop    %ebx
f0101754:	5e                   	pop    %esi
f0101755:	5d                   	pop    %ebp
f0101756:	c3                   	ret    

f0101757 <check_va2pa>:

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'ptr_page_directory'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va)
{
f0101757:	55                   	push   %ebp
f0101758:	89 e5                	mov    %esp,%ebp
f010175a:	53                   	push   %ebx
f010175b:	83 ec 04             	sub    $0x4,%esp
f010175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	uint32 *p;

	ptr_page_directory = &ptr_page_directory[PDX(va)];
f0101761:	89 c8                	mov    %ecx,%eax
f0101763:	c1 e8 16             	shr    $0x16,%eax
f0101766:	c1 e0 02             	shl    $0x2,%eax
f0101769:	03 45 08             	add    0x8(%ebp),%eax
	if (!(*ptr_page_directory & PERM_PRESENT))
f010176c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0101771:	f6 00 01             	testb  $0x1,(%eax)
f0101774:	74 58                	je     f01017ce <check_va2pa+0x77>
		return ~0;
	p = (uint32*) K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(*ptr_page_directory));
f0101776:	8b 10                	mov    (%eax),%edx
f0101778:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010177e:	89 d0                	mov    %edx,%eax
f0101780:	c1 e8 0c             	shr    $0xc,%eax
f0101783:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f0101789:	72 15                	jb     f01017a0 <check_va2pa+0x49>
f010178b:	52                   	push   %edx
f010178c:	68 20 51 10 f0       	push   $0xf0105120
f0101791:	68 89 00 00 00       	push   $0x89
f0101796:	68 e8 55 10 f0       	push   $0xf01055e8
f010179b:	e8 5e e9 ff ff       	call   f01000fe <_panic>
f01017a0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	if (!(p[PTX(va)] & PERM_PRESENT))
f01017a6:	89 c8                	mov    %ecx,%eax
f01017a8:	c1 e8 0c             	shr    $0xc,%eax
f01017ab:	25 ff 03 00 00       	and    $0x3ff,%eax
f01017b0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01017b5:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f01017b9:	74 13                	je     f01017ce <check_va2pa+0x77>
		return ~0;
	return EXTRACT_ADDRESS(p[PTX(va)]);
f01017bb:	89 c8                	mov    %ecx,%eax
f01017bd:	c1 e8 0c             	shr    $0xc,%eax
f01017c0:	25 ff 03 00 00       	and    $0x3ff,%eax
f01017c5:	8b 1c 82             	mov    (%edx,%eax,4),%ebx
f01017c8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
}
f01017ce:	89 d8                	mov    %ebx,%eax
f01017d0:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01017d3:	c9                   	leave  
f01017d4:	c3                   	ret    

f01017d5 <tlb_invalidate>:
		
void tlb_invalidate(uint32 *ptr_page_directory, void *virtual_address)
{
f01017d5:	55                   	push   %ebp
f01017d6:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
f01017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01017db:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(virtual_address);
}
f01017de:	5d                   	pop    %ebp
f01017df:	c3                   	ret    

f01017e0 <page_check>:

void page_check()
{
f01017e0:	55                   	push   %ebp
f01017e1:	89 e5                	mov    %esp,%ebp
f01017e3:	56                   	push   %esi
f01017e4:	53                   	push   %ebx
f01017e5:	83 ec 1c             	sub    $0x1c,%esp
	struct Frame_Info *pp, *pp0, *pp1, *pp2;
	struct Linked_List fl;

	// should be able to allocate three frames_info
	pp0 = pp1 = pp2 = 0;
f01017e8:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
f01017ef:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f01017f6:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
	assert(allocate_frame(&pp0) == 0);
f01017fd:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f0101800:	50                   	push   %eax
f0101801:	e8 68 0d 00 00       	call   f010256e <allocate_frame>
f0101806:	83 c4 10             	add    $0x10,%esp
f0101809:	85 c0                	test   %eax,%eax
f010180b:	74 14                	je     f0101821 <page_check+0x41>
f010180d:	68 f7 55 10 f0       	push   $0xf01055f7
f0101812:	68 a2 55 10 f0       	push   $0xf01055a2
f0101817:	68 9d 00 00 00       	push   $0x9d
f010181c:	e9 80 07 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(allocate_frame(&pp1) == 0);
f0101821:	83 ec 0c             	sub    $0xc,%esp
f0101824:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f0101827:	50                   	push   %eax
f0101828:	e8 41 0d 00 00       	call   f010256e <allocate_frame>
f010182d:	83 c4 10             	add    $0x10,%esp
f0101830:	85 c0                	test   %eax,%eax
f0101832:	74 14                	je     f0101848 <page_check+0x68>
f0101834:	68 11 56 10 f0       	push   $0xf0105611
f0101839:	68 a2 55 10 f0       	push   $0xf01055a2
f010183e:	68 9e 00 00 00       	push   $0x9e
f0101843:	e9 59 07 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(allocate_frame(&pp2) == 0);
f0101848:	83 ec 0c             	sub    $0xc,%esp
f010184b:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f010184e:	50                   	push   %eax
f010184f:	e8 1a 0d 00 00       	call   f010256e <allocate_frame>
f0101854:	83 c4 10             	add    $0x10,%esp
f0101857:	85 c0                	test   %eax,%eax
f0101859:	74 14                	je     f010186f <page_check+0x8f>
f010185b:	68 2b 56 10 f0       	push   $0xf010562b
f0101860:	68 a2 55 10 f0       	push   $0xf01055a2
f0101865:	68 9f 00 00 00       	push   $0x9f
f010186a:	e9 32 07 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	assert(pp0);
f010186f:	83 7d f4 00          	cmpl   $0x0,0xfffffff4(%ebp)
f0101873:	75 14                	jne    f0101889 <page_check+0xa9>
f0101875:	68 53 56 10 f0       	push   $0xf0105653
f010187a:	68 a2 55 10 f0       	push   $0xf01055a2
f010187f:	68 a1 00 00 00       	push   $0xa1
f0101884:	e9 18 07 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp1 && pp1 != pp0);
f0101889:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010188d:	74 08                	je     f0101897 <page_check+0xb7>
f010188f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101892:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f0101895:	75 14                	jne    f01018ab <page_check+0xcb>
f0101897:	68 45 56 10 f0       	push   $0xf0105645
f010189c:	68 a2 55 10 f0       	push   $0xf01055a2
f01018a1:	68 a2 00 00 00       	push   $0xa2
f01018a6:	e9 f6 06 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018ab:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f01018af:	74 0d                	je     f01018be <page_check+0xde>
f01018b1:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01018b4:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f01018b7:	74 05                	je     f01018be <page_check+0xde>
f01018b9:	3b 45 f4             	cmp    0xfffffff4(%ebp),%eax
f01018bc:	75 14                	jne    f01018d2 <page_check+0xf2>
f01018be:	68 60 51 10 f0       	push   $0xf0105160
f01018c3:	68 a2 55 10 f0       	push   $0xf01055a2
f01018c8:	68 a3 00 00 00       	push   $0xa3
f01018cd:	e9 cf 06 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// temporarily steal the rest of the free frames_info
	fl = free_frame_list;
f01018d2:	8b 35 c0 f5 1b f0    	mov    0xf01bf5c0,%esi
	LIST_INIT(&free_frame_list);
f01018d8:	c7 05 c0 f5 1b f0 00 	movl   $0x0,0xf01bf5c0
f01018df:	00 00 00 

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f01018e2:	83 ec 0c             	sub    $0xc,%esp
f01018e5:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f01018e8:	50                   	push   %eax
f01018e9:	e8 80 0c 00 00       	call   f010256e <allocate_frame>
f01018ee:	83 c4 10             	add    $0x10,%esp
f01018f1:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01018f4:	74 14                	je     f010190a <page_check+0x12a>
f01018f6:	68 80 51 10 f0       	push   $0xf0105180
f01018fb:	68 a2 55 10 f0       	push   $0xf01055a2
f0101900:	68 aa 00 00 00       	push   $0xaa
f0101905:	e9 97 06 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// there is no free memory, so we can't allocate a page table 
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) < 0);
f010190a:	6a 00                	push   $0x0
f010190c:	6a 00                	push   $0x0
f010190e:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101911:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101917:	e8 f3 0d 00 00       	call   f010270f <map_frame>
f010191c:	83 c4 10             	add    $0x10,%esp
f010191f:	85 c0                	test   %eax,%eax
f0101921:	78 14                	js     f0101937 <page_check+0x157>
f0101923:	68 a0 51 10 f0       	push   $0xf01051a0
f0101928:	68 a2 55 10 f0       	push   $0xf01055a2
f010192d:	68 ad 00 00 00       	push   $0xad
f0101932:	e9 6a 06 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// free pp0 and try again: pp0 should be used for page table
	free_frame(pp0);
f0101937:	83 ec 0c             	sub    $0xc,%esp
f010193a:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f010193d:	e8 6f 0c 00 00       	call   f01025b1 <free_frame>
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) == 0);
f0101942:	6a 00                	push   $0x0
f0101944:	6a 00                	push   $0x0
f0101946:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101949:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f010194f:	e8 bb 0d 00 00       	call   f010270f <map_frame>
f0101954:	83 c4 20             	add    $0x20,%esp
f0101957:	85 c0                	test   %eax,%eax
f0101959:	74 14                	je     f010196f <page_check+0x18f>
f010195b:	68 e0 51 10 f0       	push   $0xf01051e0
f0101960:	68 a2 55 10 f0       	push   $0xf01055a2
f0101965:	68 b1 00 00 00       	push   $0xb1
f010196a:	e9 32 06 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f010196f:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0101974:	8b 18                	mov    (%eax),%ebx
f0101976:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f010197c:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f010197f:	2b 15 c4 f5 1b f0    	sub    0xf01bf5c4,%edx
f0101985:	c1 fa 02             	sar    $0x2,%edx
f0101988:	8d 04 92             	lea    (%edx,%edx,4),%eax
f010198b:	89 c1                	mov    %eax,%ecx
f010198d:	c1 e1 04             	shl    $0x4,%ecx
f0101990:	01 c8                	add    %ecx,%eax
f0101992:	89 c1                	mov    %eax,%ecx
f0101994:	c1 e1 08             	shl    $0x8,%ecx
f0101997:	01 c8                	add    %ecx,%eax
f0101999:	89 c1                	mov    %eax,%ecx
f010199b:	c1 e1 10             	shl    $0x10,%ecx
f010199e:	01 c8                	add    %ecx,%eax
f01019a0:	8d 04 42             	lea    (%edx,%eax,2),%eax
f01019a3:	c1 e0 0c             	shl    $0xc,%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f01019a6:	39 c3                	cmp    %eax,%ebx
f01019a8:	74 14                	je     f01019be <page_check+0x1de>
f01019aa:	68 20 52 10 f0       	push   $0xf0105220
f01019af:	68 a2 55 10 f0       	push   $0xf01055a2
f01019b4:	68 b2 00 00 00       	push   $0xb2
f01019b9:	e9 e3 05 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, 0x0) == to_physical_address(pp1));
f01019be:	83 ec 08             	sub    $0x8,%esp
f01019c1:	6a 00                	push   $0x0
f01019c3:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f01019c9:	e8 89 fd ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f01019ce:	83 c4 10             	add    $0x10,%esp
f01019d1:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f01019d4:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f01019da:	c1 f9 02             	sar    $0x2,%ecx
f01019dd:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f01019e0:	89 d3                	mov    %edx,%ebx
f01019e2:	c1 e3 04             	shl    $0x4,%ebx
f01019e5:	01 da                	add    %ebx,%edx
f01019e7:	89 d3                	mov    %edx,%ebx
f01019e9:	c1 e3 08             	shl    $0x8,%ebx
f01019ec:	01 da                	add    %ebx,%edx
f01019ee:	89 d3                	mov    %edx,%ebx
f01019f0:	c1 e3 10             	shl    $0x10,%ebx
f01019f3:	01 da                	add    %ebx,%edx
f01019f5:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f01019f8:	c1 e2 0c             	shl    $0xc,%edx
f01019fb:	39 d0                	cmp    %edx,%eax
f01019fd:	74 14                	je     f0101a13 <page_check+0x233>
f01019ff:	68 80 52 10 f0       	push   $0xf0105280
f0101a04:	68 a2 55 10 f0       	push   $0xf01055a2
f0101a09:	68 b3 00 00 00       	push   $0xb3
f0101a0e:	e9 8e 05 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp1->references == 1);
f0101a13:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101a16:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101a1b:	74 14                	je     f0101a31 <page_check+0x251>
f0101a1d:	68 57 56 10 f0       	push   $0xf0105657
f0101a22:	68 a2 55 10 f0       	push   $0xf01055a2
f0101a27:	68 b4 00 00 00       	push   $0xb4
f0101a2c:	e9 70 05 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp0->references == 1);
f0101a31:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101a34:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101a39:	74 14                	je     f0101a4f <page_check+0x26f>
f0101a3b:	68 6c 56 10 f0       	push   $0xf010566c
f0101a40:	68 a2 55 10 f0       	push   $0xf01055a2
f0101a45:	68 b5 00 00 00       	push   $0xb5
f0101a4a:	e9 52 05 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should be able to map pp2 at PAGE_SIZE because pp0 is already allocated for page table
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101a4f:	6a 00                	push   $0x0
f0101a51:	68 00 10 00 00       	push   $0x1000
f0101a56:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101a59:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101a5f:	e8 ab 0c 00 00       	call   f010270f <map_frame>
f0101a64:	83 c4 10             	add    $0x10,%esp
f0101a67:	85 c0                	test   %eax,%eax
f0101a69:	74 14                	je     f0101a7f <page_check+0x29f>
f0101a6b:	68 e0 52 10 f0       	push   $0xf01052e0
f0101a70:	68 a2 55 10 f0       	push   $0xf01055a2
f0101a75:	68 b8 00 00 00       	push   $0xb8
f0101a7a:	e9 22 05 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f0101a7f:	83 ec 08             	sub    $0x8,%esp
f0101a82:	68 00 10 00 00       	push   $0x1000
f0101a87:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101a8d:	e8 c5 fc ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101a92:	83 c4 10             	add    $0x10,%esp
f0101a95:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101a98:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0101a9e:	c1 f9 02             	sar    $0x2,%ecx
f0101aa1:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101aa4:	89 d3                	mov    %edx,%ebx
f0101aa6:	c1 e3 04             	shl    $0x4,%ebx
f0101aa9:	01 da                	add    %ebx,%edx
f0101aab:	89 d3                	mov    %edx,%ebx
f0101aad:	c1 e3 08             	shl    $0x8,%ebx
f0101ab0:	01 da                	add    %ebx,%edx
f0101ab2:	89 d3                	mov    %edx,%ebx
f0101ab4:	c1 e3 10             	shl    $0x10,%ebx
f0101ab7:	01 da                	add    %ebx,%edx
f0101ab9:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101abc:	c1 e2 0c             	shl    $0xc,%edx
f0101abf:	39 d0                	cmp    %edx,%eax
f0101ac1:	74 14                	je     f0101ad7 <page_check+0x2f7>
f0101ac3:	68 20 53 10 f0       	push   $0xf0105320
f0101ac8:	68 a2 55 10 f0       	push   $0xf01055a2
f0101acd:	68 b9 00 00 00       	push   $0xb9
f0101ad2:	e9 ca 04 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2->references == 1);
f0101ad7:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101ada:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101adf:	74 14                	je     f0101af5 <page_check+0x315>
f0101ae1:	68 81 56 10 f0       	push   $0xf0105681
f0101ae6:	68 a2 55 10 f0       	push   $0xf01055a2
f0101aeb:	68 ba 00 00 00       	push   $0xba
f0101af0:	e9 ac 04 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101af5:	83 ec 0c             	sub    $0xc,%esp
f0101af8:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101afb:	50                   	push   %eax
f0101afc:	e8 6d 0a 00 00       	call   f010256e <allocate_frame>
f0101b01:	83 c4 10             	add    $0x10,%esp
f0101b04:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b07:	74 14                	je     f0101b1d <page_check+0x33d>
f0101b09:	68 80 51 10 f0       	push   $0xf0105180
f0101b0e:	68 a2 55 10 f0       	push   $0xf01055a2
f0101b13:	68 bd 00 00 00       	push   $0xbd
f0101b18:	e9 84 04 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should be able to map pp2 at PAGE_SIZE because it's already there
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101b1d:	6a 00                	push   $0x0
f0101b1f:	68 00 10 00 00       	push   $0x1000
f0101b24:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101b27:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101b2d:	e8 dd 0b 00 00       	call   f010270f <map_frame>
f0101b32:	83 c4 10             	add    $0x10,%esp
f0101b35:	85 c0                	test   %eax,%eax
f0101b37:	74 14                	je     f0101b4d <page_check+0x36d>
f0101b39:	68 e0 52 10 f0       	push   $0xf01052e0
f0101b3e:	68 a2 55 10 f0       	push   $0xf01055a2
f0101b43:	68 c0 00 00 00       	push   $0xc0
f0101b48:	e9 54 04 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f0101b4d:	83 ec 08             	sub    $0x8,%esp
f0101b50:	68 00 10 00 00       	push   $0x1000
f0101b55:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101b5b:	e8 f7 fb ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101b60:	83 c4 10             	add    $0x10,%esp
f0101b63:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0101b66:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0101b6c:	c1 f9 02             	sar    $0x2,%ecx
f0101b6f:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101b72:	89 d3                	mov    %edx,%ebx
f0101b74:	c1 e3 04             	shl    $0x4,%ebx
f0101b77:	01 da                	add    %ebx,%edx
f0101b79:	89 d3                	mov    %edx,%ebx
f0101b7b:	c1 e3 08             	shl    $0x8,%ebx
f0101b7e:	01 da                	add    %ebx,%edx
f0101b80:	89 d3                	mov    %edx,%ebx
f0101b82:	c1 e3 10             	shl    $0x10,%ebx
f0101b85:	01 da                	add    %ebx,%edx
f0101b87:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101b8a:	c1 e2 0c             	shl    $0xc,%edx
f0101b8d:	39 d0                	cmp    %edx,%eax
f0101b8f:	74 14                	je     f0101ba5 <page_check+0x3c5>
f0101b91:	68 20 53 10 f0       	push   $0xf0105320
f0101b96:	68 a2 55 10 f0       	push   $0xf01055a2
f0101b9b:	68 c1 00 00 00       	push   $0xc1
f0101ba0:	e9 fc 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2->references == 1);
f0101ba5:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101ba8:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101bad:	74 14                	je     f0101bc3 <page_check+0x3e3>
f0101baf:	68 81 56 10 f0       	push   $0xf0105681
f0101bb4:	68 a2 55 10 f0       	push   $0xf01055a2
f0101bb9:	68 c2 00 00 00       	push   $0xc2
f0101bbe:	e9 de 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in map_frame
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101bc3:	83 ec 0c             	sub    $0xc,%esp
f0101bc6:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101bc9:	50                   	push   %eax
f0101bca:	e8 9f 09 00 00       	call   f010256e <allocate_frame>
f0101bcf:	83 c4 10             	add    $0x10,%esp
f0101bd2:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101bd5:	74 14                	je     f0101beb <page_check+0x40b>
f0101bd7:	68 80 51 10 f0       	push   $0xf0105180
f0101bdc:	68 a2 55 10 f0       	push   $0xf01055a2
f0101be1:	68 c6 00 00 00       	push   $0xc6
f0101be6:	e9 b6 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should not be able to map at PTSIZE because need free frame for page table
	assert(map_frame(ptr_page_directory, pp0, (void*) PTSIZE, 0) < 0);
f0101beb:	6a 00                	push   $0x0
f0101bed:	68 00 00 40 00       	push   $0x400000
f0101bf2:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101bf5:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101bfb:	e8 0f 0b 00 00       	call   f010270f <map_frame>
f0101c00:	83 c4 10             	add    $0x10,%esp
f0101c03:	85 c0                	test   %eax,%eax
f0101c05:	78 14                	js     f0101c1b <page_check+0x43b>
f0101c07:	68 80 53 10 f0       	push   $0xf0105380
f0101c0c:	68 a2 55 10 f0       	push   $0xf01055a2
f0101c11:	68 c9 00 00 00       	push   $0xc9
f0101c16:	e9 86 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// insert pp1 at PAGE_SIZE (replacing pp2)
	assert(map_frame(ptr_page_directory, pp1, (void*) PAGE_SIZE, 0) == 0);
f0101c1b:	6a 00                	push   $0x0
f0101c1d:	68 00 10 00 00       	push   $0x1000
f0101c22:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101c25:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101c2b:	e8 df 0a 00 00       	call   f010270f <map_frame>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 14                	je     f0101c4b <page_check+0x46b>
f0101c37:	68 c0 53 10 f0       	push   $0xf01053c0
f0101c3c:	68 a2 55 10 f0       	push   $0xf01055a2
f0101c41:	68 cc 00 00 00       	push   $0xcc
f0101c46:	e9 56 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should have pp1 at both 0 and PAGE_SIZE, pp2 nowhere, ...
	assert(check_va2pa(ptr_page_directory, 0) == to_physical_address(pp1));
f0101c4b:	83 ec 08             	sub    $0x8,%esp
f0101c4e:	6a 00                	push   $0x0
f0101c50:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101c56:	e8 fc fa ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101c5b:	83 c4 10             	add    $0x10,%esp
f0101c5e:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101c61:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0101c67:	c1 f9 02             	sar    $0x2,%ecx
f0101c6a:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101c6d:	89 d3                	mov    %edx,%ebx
f0101c6f:	c1 e3 04             	shl    $0x4,%ebx
f0101c72:	01 da                	add    %ebx,%edx
f0101c74:	89 d3                	mov    %edx,%ebx
f0101c76:	c1 e3 08             	shl    $0x8,%ebx
f0101c79:	01 da                	add    %ebx,%edx
f0101c7b:	89 d3                	mov    %edx,%ebx
f0101c7d:	c1 e3 10             	shl    $0x10,%ebx
f0101c80:	01 da                	add    %ebx,%edx
f0101c82:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101c85:	c1 e2 0c             	shl    $0xc,%edx
f0101c88:	39 d0                	cmp    %edx,%eax
f0101c8a:	74 14                	je     f0101ca0 <page_check+0x4c0>
f0101c8c:	68 00 54 10 f0       	push   $0xf0105400
f0101c91:	68 a2 55 10 f0       	push   $0xf01055a2
f0101c96:	68 cf 00 00 00       	push   $0xcf
f0101c9b:	e9 01 03 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101ca0:	83 ec 08             	sub    $0x8,%esp
f0101ca3:	68 00 10 00 00       	push   $0x1000
f0101ca8:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101cae:	e8 a4 fa ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101cb9:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0101cbf:	c1 f9 02             	sar    $0x2,%ecx
f0101cc2:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101cc5:	89 d3                	mov    %edx,%ebx
f0101cc7:	c1 e3 04             	shl    $0x4,%ebx
f0101cca:	01 da                	add    %ebx,%edx
f0101ccc:	89 d3                	mov    %edx,%ebx
f0101cce:	c1 e3 08             	shl    $0x8,%ebx
f0101cd1:	01 da                	add    %ebx,%edx
f0101cd3:	89 d3                	mov    %edx,%ebx
f0101cd5:	c1 e3 10             	shl    $0x10,%ebx
f0101cd8:	01 da                	add    %ebx,%edx
f0101cda:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101cdd:	c1 e2 0c             	shl    $0xc,%edx
f0101ce0:	39 d0                	cmp    %edx,%eax
f0101ce2:	74 14                	je     f0101cf8 <page_check+0x518>
f0101ce4:	68 40 54 10 f0       	push   $0xf0105440
f0101ce9:	68 a2 55 10 f0       	push   $0xf01055a2
f0101cee:	68 d0 00 00 00       	push   $0xd0
f0101cf3:	e9 a9 02 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	// ... and ref counts should reflect this
	assert(pp1->references == 2);
f0101cf8:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101cfb:	66 83 78 08 02       	cmpw   $0x2,0x8(%eax)
f0101d00:	74 14                	je     f0101d16 <page_check+0x536>
f0101d02:	68 96 56 10 f0       	push   $0xf0105696
f0101d07:	68 a2 55 10 f0       	push   $0xf01055a2
f0101d0c:	68 d2 00 00 00       	push   $0xd2
f0101d11:	e9 8b 02 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101d16:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101d19:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101d1e:	74 14                	je     f0101d34 <page_check+0x554>
f0101d20:	68 ab 56 10 f0       	push   $0xf01056ab
f0101d25:	68 a2 55 10 f0       	push   $0xf01055a2
f0101d2a:	68 d3 00 00 00       	push   $0xd3
f0101d2f:	e9 6d 02 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// pp2 should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp2);
f0101d34:	83 ec 0c             	sub    $0xc,%esp
f0101d37:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101d3a:	50                   	push   %eax
f0101d3b:	e8 2e 08 00 00       	call   f010256e <allocate_frame>
f0101d40:	83 c4 10             	add    $0x10,%esp
f0101d43:	85 c0                	test   %eax,%eax
f0101d45:	75 08                	jne    f0101d4f <page_check+0x56f>
f0101d47:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101d4a:	3b 45 ec             	cmp    0xffffffec(%ebp),%eax
f0101d4d:	74 14                	je     f0101d63 <page_check+0x583>
f0101d4f:	68 a0 54 10 f0       	push   $0xf01054a0
f0101d54:	68 a2 55 10 f0       	push   $0xf01055a2
f0101d59:	68 d6 00 00 00       	push   $0xd6
f0101d5e:	e9 3e 02 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// unmapping pp1 at 0 should keep pp1 at PAGE_SIZE
	unmap_frame(ptr_page_directory, 0x0);
f0101d63:	83 ec 08             	sub    $0x8,%esp
f0101d66:	6a 00                	push   $0x0
f0101d68:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101d6e:	e8 c9 0a 00 00       	call   f010283c <unmap_frame>
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101d73:	83 c4 08             	add    $0x8,%esp
f0101d76:	6a 00                	push   $0x0
f0101d78:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101d7e:	e8 d4 f9 ff ff       	call   f0101757 <check_va2pa>
f0101d83:	83 c4 10             	add    $0x10,%esp
f0101d86:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d89:	74 14                	je     f0101d9f <page_check+0x5bf>
f0101d8b:	68 e0 54 10 f0       	push   $0xf01054e0
f0101d90:	68 a2 55 10 f0       	push   $0xf01055a2
f0101d95:	68 da 00 00 00       	push   $0xda
f0101d9a:	e9 02 02 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101d9f:	83 ec 08             	sub    $0x8,%esp
f0101da2:	68 00 10 00 00       	push   $0x1000
f0101da7:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101dad:	e8 a5 f9 ff ff       	call   f0101757 <check_va2pa>
	return ptr_frame_info - frames_info;
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101db2:	83 c4 10             	add    $0x10,%esp
f0101db5:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f0101db8:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0101dbe:	c1 f9 02             	sar    $0x2,%ecx
f0101dc1:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
f0101dc4:	89 d3                	mov    %edx,%ebx
f0101dc6:	c1 e3 04             	shl    $0x4,%ebx
f0101dc9:	01 da                	add    %ebx,%edx
f0101dcb:	89 d3                	mov    %edx,%ebx
f0101dcd:	c1 e3 08             	shl    $0x8,%ebx
f0101dd0:	01 da                	add    %ebx,%edx
f0101dd2:	89 d3                	mov    %edx,%ebx
f0101dd4:	c1 e3 10             	shl    $0x10,%ebx
f0101dd7:	01 da                	add    %ebx,%edx
f0101dd9:	8d 14 51             	lea    (%ecx,%edx,2),%edx
f0101ddc:	c1 e2 0c             	shl    $0xc,%edx
f0101ddf:	39 d0                	cmp    %edx,%eax
f0101de1:	74 14                	je     f0101df7 <page_check+0x617>
f0101de3:	68 40 54 10 f0       	push   $0xf0105440
f0101de8:	68 a2 55 10 f0       	push   $0xf01055a2
f0101ded:	68 db 00 00 00       	push   $0xdb
f0101df2:	e9 aa 01 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp1->references == 1);
f0101df7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101dfa:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101dff:	74 14                	je     f0101e15 <page_check+0x635>
f0101e01:	68 57 56 10 f0       	push   $0xf0105657
f0101e06:	68 a2 55 10 f0       	push   $0xf01055a2
f0101e0b:	68 dc 00 00 00       	push   $0xdc
f0101e10:	e9 8c 01 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101e15:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101e18:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e1d:	74 14                	je     f0101e33 <page_check+0x653>
f0101e1f:	68 ab 56 10 f0       	push   $0xf01056ab
f0101e24:	68 a2 55 10 f0       	push   $0xf01055a2
f0101e29:	68 dd 00 00 00       	push   $0xdd
f0101e2e:	e9 6e 01 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// unmapping pp1 at PAGE_SIZE should free it
	unmap_frame(ptr_page_directory, (void*) PAGE_SIZE);
f0101e33:	83 ec 08             	sub    $0x8,%esp
f0101e36:	68 00 10 00 00       	push   $0x1000
f0101e3b:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101e41:	e8 f6 09 00 00       	call   f010283c <unmap_frame>
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101e46:	83 c4 08             	add    $0x8,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101e51:	e8 01 f9 ff ff       	call   f0101757 <check_va2pa>
f0101e56:	83 c4 10             	add    $0x10,%esp
f0101e59:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e5c:	74 14                	je     f0101e72 <page_check+0x692>
f0101e5e:	68 e0 54 10 f0       	push   $0xf01054e0
f0101e63:	68 a2 55 10 f0       	push   $0xf01055a2
f0101e68:	68 e1 00 00 00       	push   $0xe1
f0101e6d:	e9 2f 01 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == ~0);
f0101e72:	83 ec 08             	sub    $0x8,%esp
f0101e75:	68 00 10 00 00       	push   $0x1000
f0101e7a:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0101e80:	e8 d2 f8 ff ff       	call   f0101757 <check_va2pa>
f0101e85:	83 c4 10             	add    $0x10,%esp
f0101e88:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e8b:	74 14                	je     f0101ea1 <page_check+0x6c1>
f0101e8d:	68 20 55 10 f0       	push   $0xf0105520
f0101e92:	68 a2 55 10 f0       	push   $0xf01055a2
f0101e97:	68 e2 00 00 00       	push   $0xe2
f0101e9c:	e9 00 01 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp1->references == 0);
f0101ea1:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0101ea4:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101ea9:	74 14                	je     f0101ebf <page_check+0x6df>
f0101eab:	68 c0 56 10 f0       	push   $0xf01056c0
f0101eb0:	68 a2 55 10 f0       	push   $0xf01055a2
f0101eb5:	68 e3 00 00 00       	push   $0xe3
f0101eba:	e9 e2 00 00 00       	jmp    f0101fa1 <page_check+0x7c1>
	assert(pp2->references == 0);
f0101ebf:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f0101ec2:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101ec7:	74 14                	je     f0101edd <page_check+0x6fd>
f0101ec9:	68 ab 56 10 f0       	push   $0xf01056ab
f0101ece:	68 a2 55 10 f0       	push   $0xf01055a2
f0101ed3:	68 e4 00 00 00       	push   $0xe4
f0101ed8:	e9 c4 00 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// so it should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp1);
f0101edd:	83 ec 0c             	sub    $0xc,%esp
f0101ee0:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101ee3:	50                   	push   %eax
f0101ee4:	e8 85 06 00 00       	call   f010256e <allocate_frame>
f0101ee9:	83 c4 10             	add    $0x10,%esp
f0101eec:	85 c0                	test   %eax,%eax
f0101eee:	75 08                	jne    f0101ef8 <page_check+0x718>
f0101ef0:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0101ef3:	3b 45 f0             	cmp    0xfffffff0(%ebp),%eax
f0101ef6:	74 14                	je     f0101f0c <page_check+0x72c>
f0101ef8:	68 60 55 10 f0       	push   $0xf0105560
f0101efd:	68 a2 55 10 f0       	push   $0xf01055a2
f0101f02:	68 e7 00 00 00       	push   $0xe7
f0101f07:	e9 95 00 00 00       	jmp    f0101fa1 <page_check+0x7c1>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101f0c:	83 ec 0c             	sub    $0xc,%esp
f0101f0f:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0101f12:	50                   	push   %eax
f0101f13:	e8 56 06 00 00       	call   f010256e <allocate_frame>
f0101f18:	83 c4 10             	add    $0x10,%esp
f0101f1b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101f1e:	74 11                	je     f0101f31 <page_check+0x751>
f0101f20:	68 80 51 10 f0       	push   $0xf0105180
f0101f25:	68 a2 55 10 f0       	push   $0xf01055a2
f0101f2a:	68 ea 00 00 00       	push   $0xea
f0101f2f:	eb 70                	jmp    f0101fa1 <page_check+0x7c1>

	// forcibly take pp0 back
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101f31:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0101f36:	8b 18                	mov    (%eax),%ebx
f0101f38:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0101f3e:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0101f41:	2b 15 c4 f5 1b f0    	sub    0xf01bf5c4,%edx
f0101f47:	c1 fa 02             	sar    $0x2,%edx
f0101f4a:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0101f4d:	89 c1                	mov    %eax,%ecx
f0101f4f:	c1 e1 04             	shl    $0x4,%ecx
f0101f52:	01 c8                	add    %ecx,%eax
f0101f54:	89 c1                	mov    %eax,%ecx
f0101f56:	c1 e1 08             	shl    $0x8,%ecx
f0101f59:	01 c8                	add    %ecx,%eax
f0101f5b:	89 c1                	mov    %eax,%ecx
f0101f5d:	c1 e1 10             	shl    $0x10,%ecx
f0101f60:	01 c8                	add    %ecx,%eax
f0101f62:	8d 04 42             	lea    (%edx,%eax,2),%eax
f0101f65:	c1 e0 0c             	shl    $0xc,%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101f68:	39 c3                	cmp    %eax,%ebx
f0101f6a:	74 11                	je     f0101f7d <page_check+0x79d>
f0101f6c:	68 20 52 10 f0       	push   $0xf0105220
f0101f71:	68 a2 55 10 f0       	push   $0xf01055a2
f0101f76:	68 ed 00 00 00       	push   $0xed
f0101f7b:	eb 24                	jmp    f0101fa1 <page_check+0x7c1>
	ptr_page_directory[0] = 0;
f0101f7d:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0101f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->references == 1);
f0101f88:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101f8b:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101f90:	74 19                	je     f0101fab <page_check+0x7cb>
f0101f92:	68 6c 56 10 f0       	push   $0xf010566c
f0101f97:	68 a2 55 10 f0       	push   $0xf01055a2
f0101f9c:	68 ef 00 00 00       	push   $0xef
f0101fa1:	68 e8 55 10 f0       	push   $0xf01055e8
f0101fa6:	e8 53 e1 ff ff       	call   f01000fe <_panic>
	pp0->references = 0;
f0101fab:	8b 45 f4             	mov    0xfffffff4(%ebp),%eax
f0101fae:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	free_frame_list = fl;
f0101fb4:	89 35 c0 f5 1b f0    	mov    %esi,0xf01bf5c0

	// free the frames_info we took
	free_frame(pp0);
f0101fba:	83 ec 0c             	sub    $0xc,%esp
f0101fbd:	ff 75 f4             	pushl  0xfffffff4(%ebp)
f0101fc0:	e8 ec 05 00 00       	call   f01025b1 <free_frame>
	free_frame(pp1);
f0101fc5:	83 c4 04             	add    $0x4,%esp
f0101fc8:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0101fcb:	e8 e1 05 00 00       	call   f01025b1 <free_frame>
	free_frame(pp2);
f0101fd0:	83 c4 04             	add    $0x4,%esp
f0101fd3:	ff 75 ec             	pushl  0xffffffec(%ebp)
f0101fd6:	e8 d6 05 00 00       	call   f01025b1 <free_frame>

	cprintf("page_check() succeeded!\n");
f0101fdb:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f0101fe2:	e8 17 0f 00 00       	call   f0102efe <cprintf>
}
f0101fe7:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0101fea:	5b                   	pop    %ebx
f0101feb:	5e                   	pop    %esi
f0101fec:	5d                   	pop    %ebp
f0101fed:	c3                   	ret    

f0101fee <turn_on_paging>:

void turn_on_paging()
{
f0101fee:	55                   	push   %ebp
f0101fef:	89 e5                	mov    %esp,%ebp
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
f0101ff1:	8b 15 cc f5 1b f0    	mov    0xf01bf5cc,%edx
f0101ff7:	8b 82 00 0f 00 00    	mov    0xf00(%edx),%eax
f0101ffd:	89 02                	mov    %eax,(%edx)
}

static __inline void
lcr3(uint32 val)
{
f0101fff:	a1 d0 f5 1b f0       	mov    0xf01bf5d0,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102004:	0f 22 d8             	mov    %eax,%cr3
f0102007:	0f 20 c0             	mov    %cr0,%eax

	// Install page table.
	lcr3(phys_page_directory);

	// Turn on paging.
	uint32 cr0;
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f010200a:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32 val)
{
f010200f:	83 e0 f3             	and    $0xfffffff3,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102012:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Current mapping: KERNEL_BASE+x => x => x.
	// (x < 4MB so uses paging ptr_page_directory[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0102015:	0f 01 15 b0 d6 11 f0 	lgdtl  0xf011d6b0
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010201c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102021:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102023:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102025:	b8 10 00 00 00       	mov    $0x10,%eax
f010202a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010202c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010202e:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0102030:	ea 37 20 10 f0 08 00 	ljmp   $0x8,$0xf0102037
	asm volatile("lldt %%ax" :: "a" (0));
f0102037:	b8 00 00 00 00       	mov    $0x0,%eax
f010203c:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNEL_BASE + x => KERNEL_BASE + x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	ptr_page_directory[0] = 0;
f010203f:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0102044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
lcr3(uint32 val)
{
f010204a:	a1 d0 f5 1b f0       	mov    0xf01bf5d0,%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010204f:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the ptr_page_directory[0] mapping.
	lcr3(phys_page_directory);
}
f0102052:	5d                   	pop    %ebp
f0102053:	c3                   	ret    

f0102054 <setup_listing_to_all_page_tables_entries>:

void setup_listing_to_all_page_tables_entries()
{
f0102054:	55                   	push   %ebp
f0102055:	89 e5                	mov    %esp,%ebp
f0102057:	83 ec 08             	sub    $0x8,%esp
	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.

	// Permissions: kernel RW, user NONE
	uint32 phys_frame_address = K_PHYSICAL_ADDRESS(ptr_page_directory);
f010205a:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f010205f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102064:	77 0d                	ja     f0102073 <setup_listing_to_all_page_tables_entries+0x1f>
f0102066:	50                   	push   %eax
f0102067:	68 80 4f 10 f0       	push   $0xf0104f80
f010206c:	68 39 01 00 00       	push   $0x139
f0102071:	eb 2f                	jmp    f01020a2 <setup_listing_to_all_page_tables_entries+0x4e>
f0102073:	05 00 00 00 10       	add    $0x10000000,%eax
	ptr_page_directory[PDX(VPT)] = CONSTRUCT_ENTRY(phys_frame_address , PERM_PRESENT | PERM_WRITEABLE);
f0102078:	83 c8 03             	or     $0x3,%eax
f010207b:	8b 15 cc f5 1b f0    	mov    0xf01bf5cc,%edx
f0102081:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)

	// same for UVPT
	//Permissions: kernel R, user R
	ptr_page_directory[PDX(UVPT)] = K_PHYSICAL_ADDRESS(ptr_page_directory)|PERM_USER|PERM_PRESENT;
f0102087:	8b 15 cc f5 1b f0    	mov    0xf01bf5cc,%edx
f010208d:	89 d0                	mov    %edx,%eax
f010208f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102095:	77 15                	ja     f01020ac <setup_listing_to_all_page_tables_entries+0x58>
f0102097:	52                   	push   %edx
f0102098:	68 80 4f 10 f0       	push   $0xf0104f80
f010209d:	68 3e 01 00 00       	push   $0x13e
f01020a2:	68 e8 55 10 f0       	push   $0xf01055e8
f01020a7:	e8 52 e0 ff ff       	call   f01000fe <_panic>
f01020ac:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b1:	83 c8 05             	or     $0x5,%eax
f01020b4:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)

}
f01020ba:	c9                   	leave  
f01020bb:	c3                   	ret    

f01020bc <envid2env>:

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
f01020bc:	55                   	push   %ebp
f01020bd:	89 e5                	mov    %esp,%ebp
f01020bf:	56                   	push   %esi
f01020c0:	53                   	push   %ebx
f01020c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01020c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01020c7:	85 db                	test   %ebx,%ebx
f01020c9:	75 09                	jne    f01020d4 <envid2env+0x18>
		*env_store = curenv;
f01020cb:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f01020d0:	89 06                	mov    %eax,(%esi)
		return 0;
f01020d2:	eb 4b                	jmp    f010211f <envid2env+0x63>
	}

	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01020d4:	89 d8                	mov    %ebx,%eax
f01020d6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01020db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01020de:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01020e1:	8b 15 30 9d 1b f0    	mov    0xf01b9d30,%edx
f01020e7:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01020ea:	83 79 54 00          	cmpl   $0x0,0x54(%ecx)
f01020ee:	74 20                	je     f0102110 <envid2env+0x54>
f01020f0:	39 59 4c             	cmp    %ebx,0x4c(%ecx)
f01020f3:	75 1b                	jne    f0102110 <envid2env+0x54>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01020f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01020f9:	74 22                	je     f010211d <envid2env+0x61>
f01020fb:	3b 0d 34 9d 1b f0    	cmp    0xf01b9d34,%ecx
f0102101:	74 1a                	je     f010211d <envid2env+0x61>
f0102103:	8b 51 50             	mov    0x50(%ecx),%edx
f0102106:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f010210b:	3b 50 4c             	cmp    0x4c(%eax),%edx
f010210e:	74 0d                	je     f010211d <envid2env+0x61>
		*env_store = 0;
f0102110:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0102116:	b8 02 00 00 00       	mov    $0x2,%eax
f010211b:	eb 07                	jmp    f0102124 <envid2env+0x68>
	}

	*env_store = e;
f010211d:	89 0e                	mov    %ecx,(%esi)
	return 0;
f010211f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102124:	5b                   	pop    %ebx
f0102125:	5e                   	pop    %esi
f0102126:	5d                   	pop    %ebp
f0102127:	c3                   	ret    

f0102128 <initialize_kernel_VM>:
// From USER_TOP to USER_LIMIT, the user is allowed to read but not write.
// Above USER_LIMIT the user cannot read (or write).

void initialize_kernel_VM()
{
f0102128:	55                   	push   %ebp
f0102129:	89 e5                	mov    %esp,%ebp
f010212b:	53                   	push   %ebx
f010212c:	83 ec 0c             	sub    $0xc,%esp
	// Remove this line when you're ready to test this function.
	//panic("initialize_kernel_VM: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	ptr_page_directory = boot_allocate_space(PAGE_SIZE, PAGE_SIZE);
f010212f:	68 00 10 00 00       	push   $0x1000
f0102134:	68 00 10 00 00       	push   $0x1000
f0102139:	e8 5b 01 00 00       	call   f0102299 <boot_allocate_space>
f010213e:	a3 cc f5 1b f0       	mov    %eax,0xf01bf5cc
	memset(ptr_page_directory, 0, PAGE_SIZE);
f0102143:	83 c4 0c             	add    $0xc,%esp
f0102146:	68 00 10 00 00       	push   $0x1000
f010214b:	6a 00                	push   $0x0
f010214d:	50                   	push   %eax
f010214e:	e8 5c 1e 00 00       	call   f0103faf <memset>
	phys_page_directory = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0102153:	83 c4 10             	add    $0x10,%esp
f0102156:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f010215b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102160:	77 0d                	ja     f010216f <initialize_kernel_VM+0x47>
f0102162:	50                   	push   %eax
f0102163:	68 80 4f 10 f0       	push   $0xf0104f80
f0102168:	6a 3c                	push   $0x3c
f010216a:	e9 e2 00 00 00       	jmp    f0102251 <initialize_kernel_VM+0x129>
f010216f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102174:	a3 d0 f5 1b f0       	mov    %eax,0xf01bf5d0

	//////////////////////////////////////////////////////////////////////
	// Map the kernel stack with VA range :
	//  [KERNEL_STACK_TOP-KERNEL_STACK_SIZE, KERNEL_STACK_TOP), 
	// to physical address : "phys_stack_bottom".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_range(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE, K_PHYSICAL_ADDRESS(ptr_stack_bottom), PERM_WRITEABLE) ;
f0102179:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f010217e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102183:	77 0d                	ja     f0102192 <initialize_kernel_VM+0x6a>
f0102185:	50                   	push   %eax
f0102186:	68 80 4f 10 f0       	push   $0xf0104f80
f010218b:	6a 44                	push   $0x44
f010218d:	e9 bf 00 00 00       	jmp    f0102251 <initialize_kernel_VM+0x129>
f0102192:	05 00 00 00 10       	add    $0x10000000,%eax
f0102197:	83 ec 0c             	sub    $0xc,%esp
f010219a:	6a 02                	push   $0x2
f010219c:	50                   	push   %eax
f010219d:	68 00 80 00 00       	push   $0x8000
f01021a2:	68 00 80 bf ef       	push   $0xefbf8000
f01021a7:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f01021ad:	e8 19 01 00 00       	call   f01022cb <boot_map_range>

	//////////////////////////////////////////////////////////////////////
	// Map all of physical memory at KERNEL_BASE.
	// i.e.  the VA range [KERNEL_BASE, 2^32) should map to
	//      the PA range [0, 2^32 - KERNEL_BASE)
	// We might not have 2^32 - KERNEL_BASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_range(ptr_page_directory, KERNEL_BASE, 0xFFFFFFFF - KERNEL_BASE, 0, PERM_WRITEABLE) ;
f01021b2:	83 c4 14             	add    $0x14,%esp
f01021b5:	6a 02                	push   $0x2
f01021b7:	6a 00                	push   $0x0
f01021b9:	68 ff ff ff 0f       	push   $0xfffffff
f01021be:	68 00 00 00 f0       	push   $0xf0000000
f01021c3:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f01021c9:	e8 fd 00 00 00       	call   f01022cb <boot_map_range>

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
f01021ce:	a1 a8 a5 1b f0       	mov    0xf01ba5a8,%eax
f01021d3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01021d6:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
	frames_info = boot_allocate_space(array_size, PAGE_SIZE);
f01021dd:	83 c4 18             	add    $0x18,%esp
f01021e0:	68 00 10 00 00       	push   $0x1000
f01021e5:	53                   	push   %ebx
f01021e6:	e8 ae 00 00 00       	call   f0102299 <boot_allocate_space>
f01021eb:	a3 c4 f5 1b f0       	mov    %eax,0xf01bf5c4
	boot_map_range(ptr_page_directory, READ_ONLY_FRAMES_INFO, array_size, K_PHYSICAL_ADDRESS(frames_info), PERM_USER) ;
f01021f0:	83 c4 10             	add    $0x10,%esp
f01021f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021f8:	77 0a                	ja     f0102204 <initialize_kernel_VM+0xdc>
f01021fa:	50                   	push   %eax
f01021fb:	68 80 4f 10 f0       	push   $0xf0104f80
f0102200:	6a 5f                	push   $0x5f
f0102202:	eb 4d                	jmp    f0102251 <initialize_kernel_VM+0x129>
f0102204:	05 00 00 00 10       	add    $0x10000000,%eax
f0102209:	83 ec 0c             	sub    $0xc,%esp
f010220c:	6a 04                	push   $0x4
f010220e:	50                   	push   %eax
f010220f:	53                   	push   %ebx
f0102210:	68 00 00 00 ef       	push   $0xef000000
f0102215:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f010221b:	e8 ab 00 00 00       	call   f01022cb <boot_map_range>


	// This allows the kernel & user to access any page table entry using a
	// specified VA for each: VPT for kernel and UVPT for User.
	setup_listing_to_all_page_tables_entries();
f0102220:	83 c4 20             	add    $0x20,%esp
f0102223:	e8 2c fe ff ff       	call   f0102054 <setup_listing_to_all_page_tables_entries>

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
f0102228:	83 ec 08             	sub    $0x8,%esp
f010222b:	68 00 10 00 00       	push   $0x1000
f0102230:	68 00 90 01 00       	push   $0x19000
f0102235:	e8 5f 00 00 00       	call   f0102299 <boot_allocate_space>
f010223a:	a3 30 9d 1b f0       	mov    %eax,0xf01b9d30

	//make the user to access this array by mapping it to UPAGES linear address (UPAGES is in User/Kernel space)
	boot_map_range(ptr_page_directory, UENVS, envs_size, K_PHYSICAL_ADDRESS(envs), PERM_USER) ;
f010223f:	83 c4 10             	add    $0x10,%esp
f0102242:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102247:	77 12                	ja     f010225b <initialize_kernel_VM+0x133>
f0102249:	50                   	push   %eax
f010224a:	68 80 4f 10 f0       	push   $0xf0104f80
f010224f:	6a 75                	push   $0x75
f0102251:	68 e6 57 10 f0       	push   $0xf01057e6
f0102256:	e8 a3 de ff ff       	call   f01000fe <_panic>
f010225b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102260:	83 ec 0c             	sub    $0xc,%esp
f0102263:	6a 04                	push   $0x4
f0102265:	50                   	push   %eax
f0102266:	68 00 90 01 00       	push   $0x19000
f010226b:	68 00 00 c0 ee       	push   $0xeec00000
f0102270:	ff 35 cc f5 1b f0    	pushl  0xf01bf5cc
f0102276:	e8 50 00 00 00       	call   f01022cb <boot_map_range>

	//update permissions of the corresponding entry in page directory to make it USER with PERMISSION read only
	ptr_page_directory[PDX(UENVS)] = ptr_page_directory[PDX(UENVS)]|(PERM_USER|(PERM_PRESENT & (~PERM_WRITEABLE)));
f010227b:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0102280:	83 88 ec 0e 00 00 05 	orl    $0x5,0xeec(%eax)


	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();
f0102287:	83 c4 20             	add    $0x20,%esp
f010228a:	e8 24 f3 ff ff       	call   f01015b3 <check_boot_pgdir>
	
	// NOW: Turn off the segmentation by setting the segments' base to 0, and
	// turn on the paging by setting the corresponding flags in control register 0 (cr0)
	turn_on_paging() ;
f010228f:	e8 5a fd ff ff       	call   f0101fee <turn_on_paging>
}
f0102294:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102297:	c9                   	leave  
f0102298:	c3                   	ret    

f0102299 <boot_allocate_space>:

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
f0102299:	55                   	push   %ebp
f010229a:	89 e5                	mov    %esp,%ebp
	extern char end_of_kernel[];	

	// Initialize ptr_free_mem if this is the first time.
	// 'end_of_kernel' is a symbol automatically generated by the linker,
	// which points to the end of the kernel-
	// i.e., the first virtual address that the linker
	// did not assign to any kernel code or global variables.
	if (ptr_free_mem == 0)
f010229c:	83 3d c8 f5 1b f0 00 	cmpl   $0x0,0xf01bf5c8
f01022a3:	75 0a                	jne    f01022af <boot_allocate_space+0x16>
		ptr_free_mem = end_of_kernel;
f01022a5:	c7 05 c8 f5 1b f0 d4 	movl   $0xf01bf5d4,0xf01bf5c8
f01022ac:	f5 1b f0 

	// Your code here:
	//	Step 1: round ptr_free_mem up to be aligned properly
	ptr_free_mem = ROUNDUP(ptr_free_mem, PAGE_SIZE) ;
f01022af:	a1 c8 f5 1b f0       	mov    0xf01bf5c8,%eax
f01022b4:	05 ff 0f 00 00       	add    $0xfff,%eax
f01022b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	
	//	Step 2: save current value of ptr_free_mem as allocated space
	void *ptr_allocated_mem;
	ptr_allocated_mem = ptr_free_mem ;

	//	Step 3: increase ptr_free_mem to record allocation
	ptr_free_mem += size ;
f01022be:	8b 55 08             	mov    0x8(%ebp),%edx
f01022c1:	01 c2                	add    %eax,%edx
f01022c3:	89 15 c8 f5 1b f0    	mov    %edx,0xf01bf5c8

	//	Step 4: return allocated space
	return ptr_allocated_mem ;

}
f01022c9:	5d                   	pop    %ebp
f01022ca:	c3                   	ret    

f01022cb <boot_map_range>:

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
f01022cb:	55                   	push   %ebp
f01022cc:	89 e5                	mov    %esp,%ebp
f01022ce:	57                   	push   %edi
f01022cf:	56                   	push   %esi
f01022d0:	53                   	push   %ebx
f01022d1:	83 ec 0c             	sub    $0xc,%esp
f01022d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i = 0 ;
f01022d7:	bf 00 00 00 00       	mov    $0x0,%edi
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
f01022dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01022df:	05 ff 0f 00 00       	add    $0xfff,%eax
f01022e4:	89 c3                	mov    %eax,%ebx
f01022e6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f01022ec:	3b 7d 10             	cmp    0x10(%ebp),%edi
f01022ef:	73 3e                	jae    f010232f <boot_map_range+0x64>
	{
		uint32 *ptr_page_table = boot_get_page_table(ptr_page_directory, virtual_address, 1) ;
f01022f1:	83 ec 04             	sub    $0x4,%esp
f01022f4:	6a 01                	push   $0x1
f01022f6:	56                   	push   %esi
f01022f7:	ff 75 08             	pushl  0x8(%ebp)
f01022fa:	e8 38 00 00 00       	call   f0102337 <boot_get_page_table>
		uint32 index_page_table = PTX(virtual_address);
f01022ff:	89 f1                	mov    %esi,%ecx
f0102301:	c1 e9 0c             	shr    $0xc,%ecx
f0102304:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
f010230a:	8b 55 18             	mov    0x18(%ebp),%edx
f010230d:	09 da                	or     %ebx,%edx
f010230f:	83 ca 01             	or     $0x1,%edx
f0102312:	89 14 88             	mov    %edx,(%eax,%ecx,4)
		physical_address += PAGE_SIZE ;
f0102315:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		virtual_address += PAGE_SIZE ;
f010231b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102321:	83 c4 10             	add    $0x10,%esp
f0102324:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010232a:	3b 7d 10             	cmp    0x10(%ebp),%edi
f010232d:	72 c2                	jb     f01022f1 <boot_map_range+0x26>
	}
}
f010232f:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102332:	5b                   	pop    %ebx
f0102333:	5e                   	pop    %esi
f0102334:	5f                   	pop    %edi
f0102335:	5d                   	pop    %ebp
f0102336:	c3                   	ret    

f0102337 <boot_get_page_table>:

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
f0102337:	55                   	push   %ebp
f0102338:	89 e5                	mov    %esp,%ebp
f010233a:	56                   	push   %esi
f010233b:	53                   	push   %ebx
f010233c:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32 index_page_directory = PDX(virtual_address);
f010233f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102342:	89 c3                	mov    %eax,%ebx
f0102344:	c1 eb 16             	shr    $0x16,%ebx
	uint32 page_directory_entry = ptr_page_directory[index_page_directory];
	
	uint32 phys_page_table = EXTRACT_ADDRESS(page_directory_entry);
f0102347:	8b 14 9e             	mov    (%esi,%ebx,4),%edx
f010234a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	uint32 *ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table);
f0102350:	89 d1                	mov    %edx,%ecx
f0102352:	89 d0                	mov    %edx,%eax
f0102354:	c1 e8 0c             	shr    $0xc,%eax
f0102357:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f010235d:	72 0d                	jb     f010236c <boot_get_page_table+0x35>
f010235f:	52                   	push   %edx
f0102360:	68 20 51 10 f0       	push   $0xf0105120
f0102365:	68 db 00 00 00       	push   $0xdb
f010236a:	eb 40                	jmp    f01023ac <boot_get_page_table+0x75>
f010236c:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
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
f0102372:	89 c8                	mov    %ecx,%eax
f0102374:	85 d2                	test   %edx,%edx
f0102376:	75 4e                	jne    f01023c6 <boot_get_page_table+0x8f>
f0102378:	b8 00 00 00 00       	mov    $0x0,%eax
f010237d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102381:	74 43                	je     f01023c6 <boot_get_page_table+0x8f>
f0102383:	83 ec 08             	sub    $0x8,%esp
f0102386:	68 00 10 00 00       	push   $0x1000
f010238b:	68 00 10 00 00       	push   $0x1000
f0102390:	e8 04 ff ff ff       	call   f0102299 <boot_allocate_space>
f0102395:	89 c1                	mov    %eax,%ecx
f0102397:	83 c4 10             	add    $0x10,%esp
f010239a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010239f:	77 15                	ja     f01023b6 <boot_get_page_table+0x7f>
f01023a1:	50                   	push   %eax
f01023a2:	68 80 4f 10 f0       	push   $0xf0104f80
f01023a7:	68 e1 00 00 00       	push   $0xe1
f01023ac:	68 e6 57 10 f0       	push   $0xf01057e6
f01023b1:	e8 48 dd ff ff       	call   f01000fe <_panic>
f01023b6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01023bc:	89 d0                	mov    %edx,%eax
f01023be:	83 c8 03             	or     $0x3,%eax
f01023c1:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
f01023c4:	89 c8                	mov    %ecx,%eax
}
f01023c6:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f01023c9:	5b                   	pop    %ebx
f01023ca:	5e                   	pop    %esi
f01023cb:	5d                   	pop    %ebp
f01023cc:	c3                   	ret    

f01023cd <initialize_paging>:

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
f01023cd:	55                   	push   %ebp
f01023ce:	89 e5                	mov    %esp,%ebp
f01023d0:	56                   	push   %esi
f01023d1:	53                   	push   %ebx
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
f01023d2:	c7 05 c0 f5 1b f0 00 	movl   $0x0,0xf01bf5c0
f01023d9:	00 00 00 
	
	frames_info[0].references = 1;
f01023dc:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f01023e1:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
f01023e7:	be 00 00 0a 00       	mov    $0xa0000,%esi
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f01023ec:	bb 01 00 00 00       	mov    $0x1,%ebx
f01023f1:	eb 56                	jmp    f0102449 <initialize_paging+0x7c>
	{
		frames_info[i].references = 0;
f01023f3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01023f6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01023fd:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f0102402:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f0102409:	8b 15 c0 f5 1b f0    	mov    0xf01bf5c0,%edx
f010240f:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f0102414:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f0102417:	85 d2                	test   %edx,%edx
f0102419:	74 10                	je     f010242b <initialize_paging+0x5e>
f010241b:	89 ca                	mov    %ecx,%edx
f010241d:	03 15 c4 f5 1b f0    	add    0xf01bf5c4,%edx
f0102423:	a1 c0 f5 1b f0       	mov    0xf01bf5c0,%eax
f0102428:	89 50 04             	mov    %edx,0x4(%eax)
f010242b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010242e:	c1 e0 02             	shl    $0x2,%eax
f0102431:	8b 0d c4 f5 1b f0    	mov    0xf01bf5c4,%ecx
f0102437:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f010243a:	89 15 c0 f5 1b f0    	mov    %edx,0xf01bf5c0
f0102440:	c7 44 01 04 c0 f5 1b 	movl   $0xf01bf5c0,0x4(%ecx,%eax,1)
f0102447:	f0 
f0102448:	43                   	inc    %ebx
f0102449:	89 f0                	mov    %esi,%eax
f010244b:	85 f6                	test   %esi,%esi
f010244d:	79 06                	jns    f0102455 <initialize_paging+0x88>
f010244f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0102455:	c1 f8 0c             	sar    $0xc,%eax
f0102458:	39 c3                	cmp    %eax,%ebx
f010245a:	7c 97                	jl     f01023f3 <initialize_paging+0x26>
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f010245c:	bb a0 00 00 00       	mov    $0xa0,%ebx
	{
		frames_info[i].references = 1;
f0102461:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f0102464:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f0102469:	66 c7 44 90 08 01 00 	movw   $0x1,0x8(%eax,%edx,4)
f0102470:	43                   	inc    %ebx
f0102471:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0102477:	7e e8                	jle    f0102461 <initialize_paging+0x94>
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
f0102479:	ba 00 10 00 00       	mov    $0x1000,%edx
f010247e:	a1 c8 f5 1b f0       	mov    0xf01bf5c8,%eax
f0102483:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102488:	77 15                	ja     f010249f <initialize_paging+0xd2>
f010248a:	50                   	push   %eax
f010248b:	68 80 4f 10 f0       	push   $0xf0104f80
f0102490:	68 1e 01 00 00       	push   $0x11e
f0102495:	68 e6 57 10 f0       	push   $0xf01057e6
f010249a:	e8 5f dc ff ff       	call   f01000fe <_panic>
f010249f:	8d b4 02 ff ff ff 0f 	lea    0xfffffff(%edx,%eax,1),%esi
f01024a6:	89 f0                	mov    %esi,%eax
f01024a8:	89 d3                	mov    %edx,%ebx
f01024aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01024af:	f7 f3                	div    %ebx
f01024b1:	29 d6                	sub    %edx,%esi
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f01024b3:	bb 00 01 00 00       	mov    $0x100,%ebx
f01024b8:	eb 10                	jmp    f01024ca <initialize_paging+0xfd>
	{
		frames_info[i].references = 1;
f01024ba:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f01024bd:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f01024c2:	66 c7 44 90 08 01 00 	movw   $0x1,0x8(%eax,%edx,4)
f01024c9:	43                   	inc    %ebx
f01024ca:	89 f0                	mov    %esi,%eax
f01024cc:	85 f6                	test   %esi,%esi
f01024ce:	79 06                	jns    f01024d6 <initialize_paging+0x109>
f01024d0:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01024d6:	c1 f8 0c             	sar    $0xc,%eax
f01024d9:	39 c3                	cmp    %eax,%ebx
f01024db:	7c dd                	jl     f01024ba <initialize_paging+0xed>
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f01024dd:	89 f0                	mov    %esi,%eax
f01024df:	85 f6                	test   %esi,%esi
f01024e1:	79 05                	jns    f01024e8 <initialize_paging+0x11b>
f01024e3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01024e8:	89 c3                	mov    %eax,%ebx
f01024ea:	c1 fb 0c             	sar    $0xc,%ebx
f01024ed:	3b 1d a8 a5 1b f0    	cmp    0xf01ba5a8,%ebx
f01024f3:	73 5e                	jae    f0102553 <initialize_paging+0x186>
	{
		frames_info[i].references = 0;
f01024f5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01024f8:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01024ff:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f0102504:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f010250b:	8b 15 c0 f5 1b f0    	mov    0xf01bf5c0,%edx
f0102511:	a1 c4 f5 1b f0       	mov    0xf01bf5c4,%eax
f0102516:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f0102519:	85 d2                	test   %edx,%edx
f010251b:	74 10                	je     f010252d <initialize_paging+0x160>
f010251d:	89 ca                	mov    %ecx,%edx
f010251f:	03 15 c4 f5 1b f0    	add    0xf01bf5c4,%edx
f0102525:	a1 c0 f5 1b f0       	mov    0xf01bf5c0,%eax
f010252a:	89 50 04             	mov    %edx,0x4(%eax)
f010252d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102530:	c1 e0 02             	shl    $0x2,%eax
f0102533:	8b 0d c4 f5 1b f0    	mov    0xf01bf5c4,%ecx
f0102539:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f010253c:	89 15 c0 f5 1b f0    	mov    %edx,0xf01bf5c0
f0102542:	c7 44 01 04 c0 f5 1b 	movl   $0xf01bf5c0,0x4(%ecx,%eax,1)
f0102549:	f0 
f010254a:	43                   	inc    %ebx
f010254b:	3b 1d a8 a5 1b f0    	cmp    0xf01ba5a8,%ebx
f0102551:	72 a2                	jb     f01024f5 <initialize_paging+0x128>
	}
}
f0102553:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102556:	5b                   	pop    %ebx
f0102557:	5e                   	pop    %esi
f0102558:	5d                   	pop    %ebp
f0102559:	c3                   	ret    

f010255a <initialize_frame_info>:

//
// Initialize a Frame_Info structure.
// The result has null links and 0 references.
// Note that the corresponding physical frame is NOT initialized!
//
void initialize_frame_info(struct Frame_Info *ptr_frame_info)
{
f010255a:	55                   	push   %ebp
f010255b:	89 e5                	mov    %esp,%ebp
f010255d:	83 ec 0c             	sub    $0xc,%esp
	memset(ptr_frame_info, 0, sizeof(*ptr_frame_info));
f0102560:	6a 0c                	push   $0xc
f0102562:	6a 00                	push   $0x0
f0102564:	ff 75 08             	pushl  0x8(%ebp)
f0102567:	e8 43 1a 00 00       	call   f0103faf <memset>
}
f010256c:	c9                   	leave  
f010256d:	c3                   	ret    

f010256e <allocate_frame>:

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
f010256e:	55                   	push   %ebp
f010256f:	89 e5                	mov    %esp,%ebp
f0102571:	83 ec 08             	sub    $0x8,%esp
f0102574:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Fill this function in	
	*ptr_frame_info = LIST_FIRST(&free_frame_list);
f0102577:	a1 c0 f5 1b f0       	mov    0xf01bf5c0,%eax
f010257c:	89 01                	mov    %eax,(%ecx)
	if(*ptr_frame_info == NULL)
f010257e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102583:	83 39 00             	cmpl   $0x0,(%ecx)
f0102586:	74 27                	je     f01025af <allocate_frame+0x41>
		return E_NO_MEM;
	
	LIST_REMOVE(*ptr_frame_info);
f0102588:	8b 01                	mov    (%ecx),%eax
f010258a:	83 38 00             	cmpl   $0x0,(%eax)
f010258d:	74 08                	je     f0102597 <allocate_frame+0x29>
f010258f:	8b 10                	mov    (%eax),%edx
f0102591:	8b 40 04             	mov    0x4(%eax),%eax
f0102594:	89 42 04             	mov    %eax,0x4(%edx)
f0102597:	8b 01                	mov    (%ecx),%eax
f0102599:	8b 50 04             	mov    0x4(%eax),%edx
f010259c:	8b 00                	mov    (%eax),%eax
f010259e:	89 02                	mov    %eax,(%edx)
	initialize_frame_info(*ptr_frame_info);
f01025a0:	83 ec 0c             	sub    $0xc,%esp
f01025a3:	ff 31                	pushl  (%ecx)
f01025a5:	e8 b0 ff ff ff       	call   f010255a <initialize_frame_info>
	return 0;
f01025aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01025af:	c9                   	leave  
f01025b0:	c3                   	ret    

f01025b1 <free_frame>:

//
// Return a frame to the free_frame_list.
// (This function should only be called when ptr_frame_info->references reaches 0.)
//
void free_frame(struct Frame_Info *ptr_frame_info)
{
f01025b1:	55                   	push   %ebp
f01025b2:	89 e5                	mov    %esp,%ebp
f01025b4:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	LIST_INSERT_HEAD(&free_frame_list, ptr_frame_info);
f01025b7:	a1 c0 f5 1b f0       	mov    0xf01bf5c0,%eax
f01025bc:	89 02                	mov    %eax,(%edx)
f01025be:	85 c0                	test   %eax,%eax
f01025c0:	74 08                	je     f01025ca <free_frame+0x19>
f01025c2:	a1 c0 f5 1b f0       	mov    0xf01bf5c0,%eax
f01025c7:	89 50 04             	mov    %edx,0x4(%eax)
f01025ca:	89 15 c0 f5 1b f0    	mov    %edx,0xf01bf5c0
f01025d0:	c7 42 04 c0 f5 1b f0 	movl   $0xf01bf5c0,0x4(%edx)
}
f01025d7:	5d                   	pop    %ebp
f01025d8:	c3                   	ret    

f01025d9 <decrement_references>:

//
// Decrement the reference count on a frame
// freeing it if there are no more references.
//
void decrement_references(struct Frame_Info* ptr_frame_info)
{
f01025d9:	55                   	push   %ebp
f01025da:	89 e5                	mov    %esp,%ebp
f01025dc:	83 ec 08             	sub    $0x8,%esp
f01025df:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--(ptr_frame_info->references) == 0)
f01025e2:	66 ff 48 08          	decw   0x8(%eax)
f01025e6:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01025eb:	75 0c                	jne    f01025f9 <decrement_references+0x20>
		free_frame(ptr_frame_info);
f01025ed:	83 ec 0c             	sub    $0xc,%esp
f01025f0:	50                   	push   %eax
f01025f1:	e8 bb ff ff ff       	call   f01025b1 <free_frame>
f01025f6:	83 c4 10             	add    $0x10,%esp
}
f01025f9:	c9                   	leave  
f01025fa:	c3                   	ret    

f01025fb <get_page_table>:

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
f01025fb:	55                   	push   %ebp
f01025fc:	89 e5                	mov    %esp,%ebp
f01025fe:	57                   	push   %edi
f01025ff:	56                   	push   %esi
f0102600:	53                   	push   %ebx
f0102601:	83 ec 0c             	sub    $0xc,%esp
f0102604:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102607:	8b 75 14             	mov    0x14(%ebp),%esi
	// Fill this function in
	uint32 page_directory_entry = ptr_page_directory[PDX(virtual_address)];
f010260a:	89 f8                	mov    %edi,%eax
f010260c:	c1 e8 16             	shr    $0x16,%eax
f010260f:	8b 55 08             	mov    0x8(%ebp),%edx
f0102612:	8b 0c 82             	mov    (%edx,%eax,4),%ecx

	*ptr_page_table = K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(page_directory_entry)) ;
f0102615:	89 ca                	mov    %ecx,%edx
f0102617:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010261d:	89 d0                	mov    %edx,%eax
f010261f:	c1 e8 0c             	shr    $0xc,%eax
f0102622:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f0102628:	72 10                	jb     f010263a <get_page_table+0x3f>
f010262a:	52                   	push   %edx
f010262b:	68 20 51 10 f0       	push   $0xf0105120
f0102630:	68 79 01 00 00       	push   $0x179
f0102635:	e9 82 00 00 00       	jmp    f01026bc <get_page_table+0xc1>
f010263a:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0102640:	89 06                	mov    %eax,(%esi)
	
	if (page_directory_entry == 0)
f0102642:	85 c9                	test   %ecx,%ecx
f0102644:	0f 85 b8 00 00 00    	jne    f0102702 <get_page_table+0x107>
	{
		if (create)
f010264a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010264e:	0f 84 a8 00 00 00    	je     f01026fc <get_page_table+0x101>
		{
			struct Frame_Info* ptr_frame_info;
			int err = allocate_frame(&ptr_frame_info) ;
f0102654:	83 ec 0c             	sub    $0xc,%esp
f0102657:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010265a:	50                   	push   %eax
f010265b:	e8 0e ff ff ff       	call   f010256e <allocate_frame>
			if(err == E_NO_MEM)
f0102660:	83 c4 10             	add    $0x10,%esp
f0102663:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102666:	75 10                	jne    f0102678 <get_page_table+0x7d>
			{
				*ptr_page_table = 0;
f0102668:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
				return E_NO_MEM;
f010266e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102673:	e9 8f 00 00 00       	jmp    f0102707 <get_page_table+0x10c>
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0102678:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f010267b:	2b 15 c4 f5 1b f0    	sub    0xf01bf5c4,%edx
f0102681:	c1 fa 02             	sar    $0x2,%edx
f0102684:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102687:	89 c1                	mov    %eax,%ecx
f0102689:	c1 e1 04             	shl    $0x4,%ecx
f010268c:	01 c8                	add    %ecx,%eax
f010268e:	89 c1                	mov    %eax,%ecx
f0102690:	c1 e1 08             	shl    $0x8,%ecx
f0102693:	01 c8                	add    %ecx,%eax
f0102695:	89 c1                	mov    %eax,%ecx
f0102697:	c1 e1 10             	shl    $0x10,%ecx
f010269a:	01 c8                	add    %ecx,%eax
f010269c:	8d 04 42             	lea    (%edx,%eax,2),%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f010269f:	89 c3                	mov    %eax,%ebx
f01026a1:	c1 e3 0c             	shl    $0xc,%ebx
			}

			uint32 phys_page_table = to_physical_address(ptr_frame_info);
			*ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table) ;
f01026a4:	89 d8                	mov    %ebx,%eax
f01026a6:	c1 e8 0c             	shr    $0xc,%eax
f01026a9:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f01026af:	72 15                	jb     f01026c6 <get_page_table+0xcb>
f01026b1:	53                   	push   %ebx
f01026b2:	68 20 51 10 f0       	push   $0xf0105120
f01026b7:	68 88 01 00 00       	push   $0x188
f01026bc:	68 e6 57 10 f0       	push   $0xf01057e6
f01026c1:	e8 38 da ff ff       	call   f01000fe <_panic>
f01026c6:	8d 83 00 00 00 f0    	lea    0xf0000000(%ebx),%eax
f01026cc:	89 06                	mov    %eax,(%esi)
			
			//initialize new page table by 0's
			memset(*ptr_page_table , 0, PAGE_SIZE);
f01026ce:	83 ec 04             	sub    $0x4,%esp
f01026d1:	68 00 10 00 00       	push   $0x1000
f01026d6:	6a 00                	push   $0x0
f01026d8:	50                   	push   %eax
f01026d9:	e8 d1 18 00 00       	call   f0103faf <memset>

			ptr_frame_info->references = 1;
f01026de:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01026e1:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
			ptr_page_directory[PDX(virtual_address)] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_USER | PERM_WRITEABLE);
f01026e7:	89 fa                	mov    %edi,%edx
f01026e9:	c1 ea 16             	shr    $0x16,%edx
f01026ec:	89 d8                	mov    %ebx,%eax
f01026ee:	83 c8 07             	or     $0x7,%eax
f01026f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01026f4:	89 04 91             	mov    %eax,(%ecx,%edx,4)
f01026f7:	83 c4 10             	add    $0x10,%esp
f01026fa:	eb 06                	jmp    f0102702 <get_page_table+0x107>
		}
		else
		{
			*ptr_page_table = 0;
f01026fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
			return 0;
		}
	}	
	return 0;
f0102702:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102707:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f010270a:	5b                   	pop    %ebx
f010270b:	5e                   	pop    %esi
f010270c:	5f                   	pop    %edi
f010270d:	5d                   	pop    %ebp
f010270e:	c3                   	ret    

f010270f <map_frame>:

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
f010270f:	55                   	push   %ebp
f0102710:	89 e5                	mov    %esp,%ebp
f0102712:	57                   	push   %edi
f0102713:	56                   	push   %esi
f0102714:	53                   	push   %ebx
f0102715:	83 ec 0c             	sub    $0xc,%esp
f0102718:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010271b:	8b 5d 10             	mov    0x10(%ebp),%ebx
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f010271e:	89 f9                	mov    %edi,%ecx
f0102720:	2b 0d c4 f5 1b f0    	sub    0xf01bf5c4,%ecx
f0102726:	c1 f9 02             	sar    $0x2,%ecx
f0102729:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f010272c:	89 c2                	mov    %eax,%edx
f010272e:	c1 e2 04             	shl    $0x4,%edx
f0102731:	01 d0                	add    %edx,%eax
f0102733:	89 c2                	mov    %eax,%edx
f0102735:	c1 e2 08             	shl    $0x8,%edx
f0102738:	01 d0                	add    %edx,%eax
f010273a:	89 c2                	mov    %eax,%edx
f010273c:	c1 e2 10             	shl    $0x10,%edx
f010273f:	01 d0                	add    %edx,%eax
f0102741:	8d 04 41             	lea    (%ecx,%eax,2),%eax
}

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0102744:	89 c6                	mov    %eax,%esi
f0102746:	c1 e6 0c             	shl    $0xc,%esi
	// Fill this function in
	uint32 physical_address = to_physical_address(ptr_frame_info);
	uint32 *ptr_page_table;
	if( get_page_table(ptr_page_directory, virtual_address, 1, &ptr_page_table) == 0)
f0102749:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f010274c:	50                   	push   %eax
f010274d:	6a 01                	push   $0x1
f010274f:	53                   	push   %ebx
f0102750:	ff 75 08             	pushl  0x8(%ebp)
f0102753:	e8 a3 fe ff ff       	call   f01025fb <get_page_table>
f0102758:	83 c4 10             	add    $0x10,%esp
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
f010275b:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102760:	85 c0                	test   %eax,%eax
f0102762:	75 4f                	jne    f01027b3 <map_frame+0xa4>
f0102764:	89 d8                	mov    %ebx,%eax
f0102766:	c1 e8 0c             	shr    $0xc,%eax
f0102769:	25 ff 03 00 00       	and    $0x3ff,%eax
f010276e:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0102771:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0102774:	89 d0                	mov    %edx,%eax
f0102776:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010277b:	39 f0                	cmp    %esi,%eax
f010277d:	74 2f                	je     f01027ae <map_frame+0x9f>
f010277f:	85 d2                	test   %edx,%edx
f0102781:	74 0f                	je     f0102792 <map_frame+0x83>
f0102783:	83 ec 08             	sub    $0x8,%esp
f0102786:	53                   	push   %ebx
f0102787:	ff 75 08             	pushl  0x8(%ebp)
f010278a:	e8 ad 00 00 00       	call   f010283c <unmap_frame>
f010278f:	83 c4 10             	add    $0x10,%esp
f0102792:	66 ff 47 08          	incw   0x8(%edi)
f0102796:	89 d8                	mov    %ebx,%eax
f0102798:	c1 e8 0c             	shr    $0xc,%eax
f010279b:	25 ff 03 00 00       	and    $0x3ff,%eax
f01027a0:	89 f2                	mov    %esi,%edx
f01027a2:	0b 55 14             	or     0x14(%ebp),%edx
f01027a5:	83 ca 01             	or     $0x1,%edx
f01027a8:	8b 4d f0             	mov    0xfffffff0(%ebp),%ecx
f01027ab:	89 14 81             	mov    %edx,(%ecx,%eax,4)
f01027ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01027b3:	89 d0                	mov    %edx,%eax
f01027b5:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01027b8:	5b                   	pop    %ebx
f01027b9:	5e                   	pop    %esi
f01027ba:	5f                   	pop    %edi
f01027bb:	5d                   	pop    %ebp
f01027bc:	c3                   	ret    

f01027bd <get_frame_info>:

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
f01027bd:	55                   	push   %ebp
f01027be:	89 e5                	mov    %esp,%ebp
f01027c0:	56                   	push   %esi
f01027c1:	53                   	push   %ebx
f01027c2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01027c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in	
	uint32 ret =  get_page_table(ptr_page_directory, virtual_address, 0, ptr_page_table) ;
f01027c8:	53                   	push   %ebx
f01027c9:	6a 00                	push   $0x0
f01027cb:	56                   	push   %esi
f01027cc:	ff 75 08             	pushl  0x8(%ebp)
f01027cf:	e8 27 fe ff ff       	call   f01025fb <get_page_table>
	if((*ptr_page_table) != 0)
f01027d4:	83 c4 10             	add    $0x10,%esp
	{	
		uint32 index_page_table = PTX(virtual_address);
		uint32 page_table_entry = (*ptr_page_table)[index_page_table];
		if( page_table_entry != 0)	
			return to_frame_info( EXTRACT_ADDRESS ( page_table_entry ) );
		return 0;
	}
	return 0;
f01027d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01027dc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01027df:	74 52                	je     f0102833 <get_frame_info+0x76>
f01027e1:	89 f0                	mov    %esi,%eax
f01027e3:	c1 e8 0c             	shr    $0xc,%eax
f01027e6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01027eb:	8b 13                	mov    (%ebx),%edx
f01027ed:	8b 04 82             	mov    (%edx,%eax,4),%eax
f01027f0:	ba 00 00 00 00       	mov    $0x0,%edx
f01027f5:	85 c0                	test   %eax,%eax
f01027f7:	74 3a                	je     f0102833 <get_frame_info+0x76>
	return to_frame_number(ptr_frame_info) << PGSHIFT;
}

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f01027f9:	89 c2                	mov    %eax,%edx
f01027fb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PPN(physical_address) >= number_of_frames)
f0102801:	89 d0                	mov    %edx,%eax
f0102803:	c1 e8 0c             	shr    $0xc,%eax
f0102806:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f010280c:	72 14                	jb     f0102822 <get_frame_info+0x65>
		panic("to_frame_info called with invalid pa");
f010280e:	83 ec 04             	sub    $0x4,%esp
f0102811:	68 00 57 10 f0       	push   $0xf0105700
f0102816:	6a 39                	push   $0x39
f0102818:	68 fc 57 10 f0       	push   $0xf01057fc
f010281d:	e8 dc d8 ff ff       	call   f01000fe <_panic>
f0102822:	89 d0                	mov    %edx,%eax
f0102824:	c1 e8 0c             	shr    $0xc,%eax
f0102827:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010282a:	8b 15 c4 f5 1b f0    	mov    0xf01bf5c4,%edx
f0102830:	8d 14 82             	lea    (%edx,%eax,4),%edx
}
f0102833:	89 d0                	mov    %edx,%eax
f0102835:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102838:	5b                   	pop    %ebx
f0102839:	5e                   	pop    %esi
f010283a:	5d                   	pop    %ebp
f010283b:	c3                   	ret    

f010283c <unmap_frame>:

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
f010283c:	55                   	push   %ebp
f010283d:	89 e5                	mov    %esp,%ebp
f010283f:	56                   	push   %esi
f0102840:	53                   	push   %ebx
f0102841:	83 ec 14             	sub    $0x14,%esp
f0102844:	8b 75 08             	mov    0x8(%ebp),%esi
f0102847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	uint32 *ptr_page_table;
	struct Frame_Info* ptr_frame_info = get_frame_info(ptr_page_directory, virtual_address, &ptr_page_table);
f010284a:	8d 45 f4             	lea    0xfffffff4(%ebp),%eax
f010284d:	50                   	push   %eax
f010284e:	53                   	push   %ebx
f010284f:	56                   	push   %esi
f0102850:	e8 68 ff ff ff       	call   f01027bd <get_frame_info>
	if( ptr_frame_info != 0 )
f0102855:	83 c4 10             	add    $0x10,%esp
f0102858:	85 c0                	test   %eax,%eax
f010285a:	74 2a                	je     f0102886 <unmap_frame+0x4a>
	{
		decrement_references(ptr_frame_info);
f010285c:	83 ec 0c             	sub    $0xc,%esp
f010285f:	50                   	push   %eax
f0102860:	e8 74 fd ff ff       	call   f01025d9 <decrement_references>
		ptr_page_table[PTX(virtual_address)] = 0;
f0102865:	89 d8                	mov    %ebx,%eax
f0102867:	c1 e8 0c             	shr    $0xc,%eax
f010286a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010286f:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0102872:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
		tlb_invalidate(ptr_page_directory, virtual_address);
f0102879:	83 c4 08             	add    $0x8,%esp
f010287c:	53                   	push   %ebx
f010287d:	56                   	push   %esi
f010287e:	e8 52 ef ff ff       	call   f01017d5 <tlb_invalidate>
f0102883:	83 c4 10             	add    $0x10,%esp
	}	
}
f0102886:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102889:	5b                   	pop    %ebx
f010288a:	5e                   	pop    %esi
f010288b:	5d                   	pop    %ebp
f010288c:	c3                   	ret    

f010288d <get_page>:

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
f010288d:	55                   	push   %ebp
f010288e:	89 e5                	mov    %esp,%ebp
f0102890:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("get_page function is not completed yet") ;
f0102893:	68 40 57 10 f0       	push   $0xf0105740
f0102898:	68 12 02 00 00       	push   $0x212
f010289d:	68 e6 57 10 f0       	push   $0xf01057e6
f01028a2:	e8 57 d8 ff ff       	call   f01000fe <_panic>

f01028a7 <calculate_required_frames>:

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
f01028a7:	55                   	push   %ebp
f01028a8:	89 e5                	mov    %esp,%ebp
f01028aa:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("calculate_required_frames function is not completed yet") ;
f01028ad:	68 80 57 10 f0       	push   $0xf0105780
f01028b2:	68 29 02 00 00       	push   $0x229
f01028b7:	68 e6 57 10 f0       	push   $0xf01057e6
f01028bc:	e8 3d d8 ff ff       	call   f01000fe <_panic>

f01028c1 <calculate_free_frames>:
	
	//calculate the required page tables	
	

	//calc the required page frames
	
	//return total number of frames  
	return 0; 
}


//[3] calculate_free_frames:

uint32 calculate_free_frames()
{
f01028c1:	55                   	push   %ebp
f01028c2:	89 e5                	mov    %esp,%ebp
	// PROJECT 2008: Your code here.
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
f01028c4:	b8 00 00 00 00       	mov    $0x0,%eax
	LIST_FOREACH(ptr, &free_frame_list)
f01028c9:	8b 15 c0 f5 1b f0    	mov    0xf01bf5c0,%edx
f01028cf:	85 d2                	test   %edx,%edx
f01028d1:	74 07                	je     f01028da <calculate_free_frames+0x19>
	{
		cnt++ ;
f01028d3:	40                   	inc    %eax
f01028d4:	8b 12                	mov    (%edx),%edx
f01028d6:	85 d2                	test   %edx,%edx
f01028d8:	75 f9                	jne    f01028d3 <calculate_free_frames+0x12>
	}
	return cnt;
}
f01028da:	5d                   	pop    %ebp
f01028db:	c3                   	ret    

f01028dc <freeMem>:

//[4] freeMem: 
//	This function is used to frees all pages and page tables that are mapped on
//	range [ virtual_address, virtual_address + size ]
//	Steps:
//		1) Unmap all mapped pages in the range [virtual_address, virtual_address + size ]
//		2) Free all mapped page tables in this range

void freeMem(uint32* ptr_page_directory, void *virtual_address, uint32 size)
{
f01028dc:	55                   	push   %ebp
f01028dd:	89 e5                	mov    %esp,%ebp
f01028df:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("freeMem function is not completed yet") ;
f01028e2:	68 c0 57 10 f0       	push   $0xf01057c0
f01028e7:	68 50 02 00 00       	push   $0x250
f01028ec:	68 e6 57 10 f0       	push   $0xf01057e6
f01028f1:	e8 08 d8 ff ff       	call   f01000fe <_panic>
	...

f01028f8 <allocate_environment>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	E_NO_FREE_ENV if all NENVS environments are allocated
//
int allocate_environment(struct Env** e)
{	
f01028f8:	55                   	push   %ebp
f01028f9:	89 e5                	mov    %esp,%ebp
	if (!(*e = LIST_FIRST(&env_free_list)))
f01028fb:	8b 15 38 9d 1b f0    	mov    0xf01b9d38,%edx
f0102901:	8b 45 08             	mov    0x8(%ebp),%eax
f0102904:	89 10                	mov    %edx,(%eax)
f0102906:	83 fa 01             	cmp    $0x1,%edx
f0102909:	19 c0                	sbb    %eax,%eax
f010290b:	83 e0 fb             	and    $0xfffffffb,%eax
		return E_NO_FREE_ENV;
	return 0;
}
f010290e:	5d                   	pop    %ebp
f010290f:	c3                   	ret    

f0102910 <free_environment>:

// Free the given environment "e", simply by adding it to the free environment list.
void free_environment(struct Env* e)
{
f0102910:	55                   	push   %ebp
f0102911:	89 e5                	mov    %esp,%ebp
f0102913:	8b 4d 08             	mov    0x8(%ebp),%ecx
	curenv = NULL;	
f0102916:	c7 05 34 9d 1b f0 00 	movl   $0x0,0xf01b9d34
f010291d:	00 00 00 
	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102920:	c7 41 54 00 00 00 00 	movl   $0x0,0x54(%ecx)
	LIST_INSERT_HEAD(&env_free_list, e);
f0102927:	a1 38 9d 1b f0       	mov    0xf01b9d38,%eax
f010292c:	89 41 44             	mov    %eax,0x44(%ecx)
f010292f:	85 c0                	test   %eax,%eax
f0102931:	74 0b                	je     f010293e <free_environment+0x2e>
f0102933:	8d 51 44             	lea    0x44(%ecx),%edx
f0102936:	a1 38 9d 1b f0       	mov    0xf01b9d38,%eax
f010293b:	89 50 48             	mov    %edx,0x48(%eax)
f010293e:	89 0d 38 9d 1b f0    	mov    %ecx,0xf01b9d38
f0102944:	c7 41 48 38 9d 1b f0 	movl   $0xf01b9d38,0x48(%ecx)
}
f010294b:	5d                   	pop    %ebp
f010294c:	c3                   	ret    

f010294d <initialize_environment>:


//
// Initialize the kernel virtual memory layout for environment e.
// Given a pointer to an allocated page directory, set the e->env_pgdir and e->env_cr3 accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
void initialize_environment(struct Env* e, uint32* ptr_user_page_directory)
{	
f010294d:	55                   	push   %ebp
f010294e:	89 e5                	mov    %esp,%ebp
f0102950:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("initialize_environment function is not completed yet") ;
f0102953:	68 00 59 10 f0       	push   $0xf0105900
f0102958:	6a 77                	push   $0x77
f010295a:	68 46 58 10 f0       	push   $0xf0105846
f010295f:	e8 9a d7 ff ff       	call   f01000fe <_panic>

f0102964 <program_segment_alloc_map>:
	// [1] initialize the kernel portion of the new environment's address space.
	
	// [2] set e->env_pgdir and e->env_cr3 accordingly,	
	
	//Completes other environment initializations, (envID, status and most of registers)
	complete_environment_initialization(e);
}



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
f0102964:	55                   	push   %ebp
f0102965:	89 e5                	mov    %esp,%ebp
f0102967:	83 ec 0c             	sub    $0xc,%esp
	//PROJECT 2008: Your code here.	
	panic("program_segment_alloc_map function is not completed yet") ;
f010296a:	68 40 59 10 f0       	push   $0xf0105940
f010296f:	68 8e 00 00 00       	push   $0x8e
f0102974:	68 46 58 10 f0       	push   $0xf0105846
f0102979:	e8 80 d7 ff ff       	call   f01000fe <_panic>

f010297e <env_create>:
	// Hint: It is easier to use program_segment_alloc_map if the caller can pass
	//   'va' and 'length' values that are not page-aligned.
	//   You should round "va" down, and round "length" up.
}

//
// Allocates a new env and loads the named user program into it.
struct UserProgramInfo* env_create(char* user_program_name)
{
f010297e:	55                   	push   %ebp
f010297f:	89 e5                	mov    %esp,%ebp
f0102981:	83 ec 2c             	sub    $0x2c,%esp
	// PROJECT 2008: Your code here.
	panic("env_create function is not completed yet") ;
f0102984:	68 80 59 10 f0       	push   $0xf0105980
f0102989:	68 99 00 00 00       	push   $0x99
f010298e:	68 46 58 10 f0       	push   $0xf0105846
f0102993:	e8 66 d7 ff ff       	call   f01000fe <_panic>

f0102998 <env_run>:

	//[1] get pointer to the start of the "user_program_name" program in memory
	// Hint: use "get_user_program_info" function, 
	// you should set the following "ptr_program_start" by the start address of the user program 
	uint8* ptr_program_start = 0; 
	
	//[2] allocate new environment, (from the free environment list)
	//if there's no one, return NULL
	// Hint: use "allocate_environment" function
	

	//[3] allocate a frame for the page directory, Don't forget to set the references of the allocated frame.
	//if there's no free space, return NULL
	
	//[4] initialize the new environment by the virtual address of the page directory 
	// Hint: use "initialize_environment" function
	
	//[5] update the UserProgramInfo in userPrograms[] corresspnding to this program  	
	
	// We want to load the program into the user virtual space
	// each program is constructed from one or more segments,
	// each segment has the following information grouped in "struct ProgramSegment"
	//	1- uint8 *ptr_start: 	start address of this segment in memory 
	//	2- uint32 size_in_file: size occupied by this segment inside the program file, 
	//	3- uint32 size_in_memory: actual size required by this segment in memory
	// 	usually size_in_file < or = size_in_memory 
	//	4- uint8 *virtual_address: start virtual address that this segment should be copied to it  
	 
	//[6] switch to user page directory
	// Hint: use rcr3() and lcr3()	

	//[7] load each program segment into user virtual space
	struct ProgramSegment* seg = NULL;  //use inside PROGRAM_SEGMENT_FOREACH as current segment information	
	
	PROGRAM_SEGMENT_FOREACH(seg, ptr_program_start)
	{
		//allocate space seg->size_in_memory for current program segment and map it at seg->virtual_address	
		//Hint: use program_segment_alloc_map() 
		// if program_segment_alloc_map() returns E_NO_MEM, call env_free() to free all environment memory
		// zero the UserProgramInfo* ptr->environment then return NULL

		
		//copy program segment from (seg->ptr_start) to (seg->virtual_address)
		// with size seg->size_in_file 
		
			
		//Initialize the rest of the program segment (seg->size_in_memory - seg->size_in_file) bytes  
		//By Zero
	}
	
	//[8] now set the entry point of the environment
	//Hint: use set_environment_entry_point()
	

	//[9] Allocate and map one page for the program's initial stack at virtual address USTACKTOP - PAGE_SIZE
	//.and make sure to initialize the new page by 0's
	// if there is no free memory, call env_free() to free all environment memory, 
	// zero the UserProgramInfo* ptr->environment then return NULL	

	//[10] switch back to the page directory exists before segment loading	

	return NULL;	
}

// Used to run the given environment "e", simply by 
// context switch from curenv to env e.
//  (This function does not return.)
//
void env_run(struct Env *e)
{
f0102998:	55                   	push   %ebp
f0102999:	89 e5                	mov    %esp,%ebp
f010299b:	83 ec 08             	sub    $0x8,%esp
f010299e:	8b 45 08             	mov    0x8(%ebp),%eax
	if(curenv != e)
f01029a1:	39 05 34 9d 1b f0    	cmp    %eax,0xf01b9d34
f01029a7:	74 13                	je     f01029bc <env_run+0x24>
	{		
		curenv = e ;
f01029a9:	a3 34 9d 1b f0       	mov    %eax,0xf01b9d34
		curenv->env_runs++ ;
f01029ae:	ff 40 58             	incl   0x58(%eax)
}

static __inline void
lcr3(uint32 val)
{
f01029b1:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f01029b6:	8b 40 60             	mov    0x60(%eax),%eax
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029b9:	0f 22 d8             	mov    %eax,%cr3
		lcr3(curenv->env_cr3) ;	
	}	
	env_pop_tf(&(curenv->env_tf));
f01029bc:	83 ec 0c             	sub    $0xc,%esp
f01029bf:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f01029c5:	e8 a6 04 00 00       	call   f0102e70 <env_pop_tf>

f01029ca <env_free>:
}

//
// Frees environment "e" and all memory it uses.
// 
void env_free(struct Env *e)
{
f01029ca:	55                   	push   %ebp
f01029cb:	89 e5                	mov    %esp,%ebp
f01029cd:	83 ec 0c             	sub    $0xc,%esp
	// PROJECT 2008: Your code here.
	panic("env_free function is not completed yet") ;
f01029d0:	68 c0 59 10 f0       	push   $0xf01059c0
f01029d5:	68 ef 00 00 00       	push   $0xef
f01029da:	68 46 58 10 f0       	push   $0xf0105846
f01029df:	e8 1a d7 ff ff       	call   f01000fe <_panic>

f01029e4 <env_init>:

	// [1] Unmap all mapped pages in the user portion of the environment (i.e. below USER_TOP)
	
	// [2] Free all mapped page tables in the user portion of the environment

	// [3] free the page directory of the environment
		
	// [4] switch back to the kernel page directory
	
	// [5] free the environment (return it back to the free environment list)
	// Hint: use free_environment()
}


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
f01029e4:	55                   	push   %ebp
f01029e5:	89 e5                	mov    %esp,%ebp
f01029e7:	53                   	push   %ebx
	int iEnv = NENV-1;
f01029e8:	bb ff 03 00 00       	mov    $0x3ff,%ebx
	for(; iEnv >= 0; iEnv--)
	{
		envs[iEnv].env_status = ENV_FREE;
f01029ed:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f01029f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01029f3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01029fa:	a1 30 9d 1b f0       	mov    0xf01b9d30,%eax
f01029ff:	c7 44 08 54 00 00 00 	movl   $0x0,0x54(%eax,%ecx,1)
f0102a06:	00 
		envs[iEnv].env_id = 0;
f0102a07:	a1 30 9d 1b f0       	mov    0xf01b9d30,%eax
f0102a0c:	c7 44 08 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ecx,1)
f0102a13:	00 
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
f0102a14:	8b 15 38 9d 1b f0    	mov    0xf01b9d38,%edx
f0102a1a:	a1 30 9d 1b f0       	mov    0xf01b9d30,%eax
f0102a1f:	89 54 08 44          	mov    %edx,0x44(%eax,%ecx,1)
f0102a23:	85 d2                	test   %edx,%edx
f0102a25:	74 14                	je     f0102a3b <env_init+0x57>
f0102a27:	89 c8                	mov    %ecx,%eax
f0102a29:	03 05 30 9d 1b f0    	add    0xf01b9d30,%eax
f0102a2f:	83 c0 44             	add    $0x44,%eax
f0102a32:	8b 15 38 9d 1b f0    	mov    0xf01b9d38,%edx
f0102a38:	89 42 48             	mov    %eax,0x48(%edx)
f0102a3b:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f0102a3e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102a41:	c1 e0 02             	shl    $0x2,%eax
f0102a44:	8b 0d 30 9d 1b f0    	mov    0xf01b9d30,%ecx
f0102a4a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0102a4d:	89 15 38 9d 1b f0    	mov    %edx,0xf01b9d38
f0102a53:	c7 44 01 48 38 9d 1b 	movl   $0xf01b9d38,0x48(%ecx,%eax,1)
f0102a5a:	f0 
f0102a5b:	4b                   	dec    %ebx
f0102a5c:	79 8f                	jns    f01029ed <env_init+0x9>
	}
}
f0102a5e:	5b                   	pop    %ebx
f0102a5f:	5d                   	pop    %ebp
f0102a60:	c3                   	ret    

f0102a61 <complete_environment_initialization>:

void complete_environment_initialization(struct Env* e)
{	
f0102a61:	55                   	push   %ebp
f0102a62:	89 e5                	mov    %esp,%ebp
f0102a64:	53                   	push   %ebx
f0102a65:	83 ec 04             	sub    $0x4,%esp
f0102a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//VPT and UVPT map the env's own page table, with
	//different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PERM_PRESENT | PERM_WRITEABLE;
f0102a6b:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a6e:	8b 43 60             	mov    0x60(%ebx),%eax
f0102a71:	83 c8 03             	or     $0x3,%eax
f0102a74:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PERM_PRESENT | PERM_USER;
f0102a7a:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a7d:	8b 43 60             	mov    0x60(%ebx),%eax
f0102a80:	83 c8 05             	or     $0x5,%eax
f0102a83:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	
	int32 generation;	
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a89:	8b 53 4c             	mov    0x4c(%ebx),%edx
f0102a8c:	81 c2 00 10 00 00    	add    $0x1000,%edx
	if (generation <= 0)	// Don't create a negative env_id.
f0102a92:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f0102a98:	7f 05                	jg     f0102a9f <complete_environment_initialization+0x3e>
		generation = 1 << ENVGENSHIFT;
f0102a9a:	ba 00 10 00 00       	mov    $0x1000,%edx
	e->env_id = generation | (e - envs);
f0102a9f:	89 d8                	mov    %ebx,%eax
f0102aa1:	2b 05 30 9d 1b f0    	sub    0xf01b9d30,%eax
f0102aa7:	c1 f8 02             	sar    $0x2,%eax
f0102aaa:	69 c0 29 5c 8f c2    	imul   $0xc28f5c29,%eax,%eax
f0102ab0:	09 d0                	or     %edx,%eax
f0102ab2:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = 0;//parent_id;
f0102ab5:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102abc:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102ac3:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102aca:	83 ec 04             	sub    $0x4,%esp
f0102acd:	6a 44                	push   $0x44
f0102acf:	6a 00                	push   $0x0
f0102ad1:	53                   	push   %ebx
f0102ad2:	e8 d8 14 00 00       	call   f0103faf <memset>

	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	e->env_tf.tf_ds = GD_UD | 3;
f0102ad7:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102add:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102ae3:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102ae9:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102af0:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e);	
f0102af6:	83 c4 10             	add    $0x10,%esp
f0102af9:	83 7b 44 00          	cmpl   $0x0,0x44(%ebx)
f0102afd:	74 09                	je     f0102b08 <complete_environment_initialization+0xa7>
f0102aff:	8b 53 44             	mov    0x44(%ebx),%edx
f0102b02:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b05:	89 42 48             	mov    %eax,0x48(%edx)
f0102b08:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b0b:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b0e:	89 02                	mov    %eax,(%edx)
	return ;
}
f0102b10:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102b13:	c9                   	leave  
f0102b14:	c3                   	ret    

f0102b15 <PROGRAM_SEGMENT_NEXT>:

struct ProgramSegment* PROGRAM_SEGMENT_NEXT(struct ProgramSegment* seg, uint8* ptr_program_start)
{
f0102b15:	55                   	push   %ebp
f0102b16:	89 e5                	mov    %esp,%ebp
f0102b18:	57                   	push   %edi
f0102b19:	56                   	push   %esi
f0102b1a:	53                   	push   %ebx
f0102b1b:	83 ec 0c             	sub    $0xc,%esp
f0102b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102b21:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int index = (*seg).segment_id++;
f0102b24:	ff 41 10             	incl   0x10(%ecx)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102b27:	89 fa                	mov    %edi,%edx
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102b29:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b2f:	74 17                	je     f0102b48 <PROGRAM_SEGMENT_NEXT+0x33>
		panic("Matafa2nash 3ala Keda"); 
f0102b31:	83 ec 04             	sub    $0x4,%esp
f0102b34:	68 5e 58 10 f0       	push   $0xf010585e
f0102b39:	68 48 01 00 00       	push   $0x148
f0102b3e:	68 46 58 10 f0       	push   $0xf0105846
f0102b43:	e8 b6 d5 ff ff       	call   f01000fe <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102b48:	89 fe                	mov    %edi,%esi
f0102b4a:	03 77 1c             	add    0x1c(%edi),%esi
	
	while (ph[(*seg).segment_id].p_type != ELF_PROG_LOAD && ((*seg).segment_id < pELFHDR->e_phnum)) (*seg).segment_id++;	
f0102b4d:	8b 41 10             	mov    0x10(%ecx),%eax
f0102b50:	89 c3                	mov    %eax,%ebx
f0102b52:	c1 e0 05             	shl    $0x5,%eax
f0102b55:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f0102b59:	74 2b                	je     f0102b86 <PROGRAM_SEGMENT_NEXT+0x71>
f0102b5b:	66 8b 47 2c          	mov    0x2c(%edi),%ax
f0102b5f:	25 ff ff 00 00       	and    $0xffff,%eax
f0102b64:	39 c3                	cmp    %eax,%ebx
f0102b66:	73 1e                	jae    f0102b86 <PROGRAM_SEGMENT_NEXT+0x71>
f0102b68:	8d 43 01             	lea    0x1(%ebx),%eax
f0102b6b:	89 41 10             	mov    %eax,0x10(%ecx)
f0102b6e:	89 c3                	mov    %eax,%ebx
f0102b70:	c1 e0 05             	shl    $0x5,%eax
f0102b73:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f0102b77:	74 0d                	je     f0102b86 <PROGRAM_SEGMENT_NEXT+0x71>
f0102b79:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0102b7d:	25 ff ff 00 00       	and    $0xffff,%eax
f0102b82:	39 c3                	cmp    %eax,%ebx
f0102b84:	72 e2                	jb     f0102b68 <PROGRAM_SEGMENT_NEXT+0x53>
	index = (*seg).segment_id;
f0102b86:	8b 59 10             	mov    0x10(%ecx),%ebx

	if(index < pELFHDR->e_phnum)
f0102b89:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0102b8d:	25 ff ff 00 00       	and    $0xffff,%eax
	{
		(*seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
		(*seg).size_in_memory =  ph[index].p_memsz;
		(*seg).size_in_file = ph[index].p_filesz;
		(*seg).virtual_address = (uint8*)ph[index].p_va;
		return seg;
	}
	return 0;
f0102b92:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b97:	39 c3                	cmp    %eax,%ebx
f0102b99:	7d 24                	jge    f0102bbf <PROGRAM_SEGMENT_NEXT+0xaa>
f0102b9b:	89 da                	mov    %ebx,%edx
f0102b9d:	c1 e2 05             	shl    $0x5,%edx
f0102ba0:	89 f8                	mov    %edi,%eax
f0102ba2:	03 44 16 04          	add    0x4(%esi,%edx,1),%eax
f0102ba6:	89 01                	mov    %eax,(%ecx)
f0102ba8:	8b 44 16 14          	mov    0x14(%esi,%edx,1),%eax
f0102bac:	89 41 08             	mov    %eax,0x8(%ecx)
f0102baf:	8b 44 16 10          	mov    0x10(%esi,%edx,1),%eax
f0102bb3:	89 41 04             	mov    %eax,0x4(%ecx)
f0102bb6:	8b 44 16 08          	mov    0x8(%esi,%edx,1),%eax
f0102bba:	89 41 0c             	mov    %eax,0xc(%ecx)
f0102bbd:	89 ca                	mov    %ecx,%edx
}	
f0102bbf:	89 d0                	mov    %edx,%eax
f0102bc1:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102bc4:	5b                   	pop    %ebx
f0102bc5:	5e                   	pop    %esi
f0102bc6:	5f                   	pop    %edi
f0102bc7:	5d                   	pop    %ebp
f0102bc8:	c3                   	ret    

f0102bc9 <PROGRAM_SEGMENT_FIRST>:

struct ProgramSegment PROGRAM_SEGMENT_FIRST( uint8* ptr_program_start)
{
f0102bc9:	55                   	push   %ebp
f0102bca:	89 e5                	mov    %esp,%ebp
f0102bcc:	57                   	push   %edi
f0102bcd:	56                   	push   %esi
f0102bce:	53                   	push   %ebx
f0102bcf:	83 ec 3c             	sub    $0x3c,%esp
f0102bd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct ProgramSegment seg;
	seg.segment_id = 0;
f0102bd5:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bdf:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102be2:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0102be8:	74 17                	je     f0102c01 <PROGRAM_SEGMENT_FIRST+0x38>
		panic("Matafa2nash 3ala Keda"); 
f0102bea:	83 ec 04             	sub    $0x4,%esp
f0102bed:	68 5e 58 10 f0       	push   $0xf010585e
f0102bf2:	68 61 01 00 00       	push   $0x161
f0102bf7:	68 46 58 10 f0       	push   $0xf0105846
f0102bfc:	e8 fd d4 ff ff       	call   f01000fe <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102c01:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102c04:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f0102c07:	03 72 1c             	add    0x1c(%edx),%esi
	while (ph[(seg).segment_id].p_type != ELF_PROG_LOAD && ((seg).segment_id < pELFHDR->e_phnum)) (seg).segment_id++;
f0102c0a:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0102c0d:	89 c1                	mov    %eax,%ecx
f0102c0f:	c1 e0 05             	shl    $0x5,%eax
f0102c12:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f0102c16:	74 26                	je     f0102c3e <PROGRAM_SEGMENT_FIRST+0x75>
f0102c18:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0102c1c:	25 ff ff 00 00       	and    $0xffff,%eax
f0102c21:	39 c1                	cmp    %eax,%ecx
f0102c23:	73 19                	jae    f0102c3e <PROGRAM_SEGMENT_FIRST+0x75>
f0102c25:	89 c3                	mov    %eax,%ebx
f0102c27:	8d 51 01             	lea    0x1(%ecx),%edx
f0102c2a:	89 d1                	mov    %edx,%ecx
f0102c2c:	89 d0                	mov    %edx,%eax
f0102c2e:	c1 e0 05             	shl    $0x5,%eax
f0102c31:	83 3c 06 01          	cmpl   $0x1,(%esi,%eax,1)
f0102c35:	74 04                	je     f0102c3b <PROGRAM_SEGMENT_FIRST+0x72>
f0102c37:	39 da                	cmp    %ebx,%edx
f0102c39:	72 ec                	jb     f0102c27 <PROGRAM_SEGMENT_FIRST+0x5e>
f0102c3b:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
	int index = (seg).segment_id;
f0102c3e:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0102c41:	89 45 c0             	mov    %eax,0xffffffc0(%ebp)

	if(index < pELFHDR->e_phnum)
f0102c44:	8b 55 c4             	mov    0xffffffc4(%ebp),%edx
f0102c47:	66 8b 42 2c          	mov    0x2c(%edx),%ax
f0102c4b:	25 ff ff 00 00       	and    $0xffff,%eax
f0102c50:	39 45 c0             	cmp    %eax,0xffffffc0(%ebp)
f0102c53:	7d 38                	jge    f0102c8d <PROGRAM_SEGMENT_FIRST+0xc4>
	{	
		(seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f0102c55:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f0102c58:	c1 e0 05             	shl    $0x5,%eax
f0102c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102c5e:	03 4c 06 04          	add    0x4(%esi,%eax,1),%ecx
f0102c62:	89 4d c8             	mov    %ecx,0xffffffc8(%ebp)
		(seg).size_in_memory =  ph[index].p_memsz;
f0102c65:	8b 5c 06 14          	mov    0x14(%esi,%eax,1),%ebx
f0102c69:	89 5d d0             	mov    %ebx,0xffffffd0(%ebp)
		(seg).size_in_file = ph[index].p_filesz;
f0102c6c:	8b 54 06 10          	mov    0x10(%esi,%eax,1),%edx
f0102c70:	89 55 cc             	mov    %edx,0xffffffcc(%ebp)
		(seg).virtual_address = (uint8*)ph[index].p_va;
f0102c73:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f0102c77:	89 45 d4             	mov    %eax,0xffffffd4(%ebp)
		return seg;
f0102c7a:	89 0f                	mov    %ecx,(%edi)
f0102c7c:	89 57 04             	mov    %edx,0x4(%edi)
f0102c7f:	89 5f 08             	mov    %ebx,0x8(%edi)
f0102c82:	89 47 0c             	mov    %eax,0xc(%edi)
f0102c85:	8b 45 c0             	mov    0xffffffc0(%ebp),%eax
f0102c88:	89 47 10             	mov    %eax,0x10(%edi)
f0102c8b:	eb 25                	jmp    f0102cb2 <PROGRAM_SEGMENT_FIRST+0xe9>
	}
	seg.segment_id = -1;
f0102c8d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,0xffffffd8(%ebp)
	return seg;
f0102c94:	8b 45 c8             	mov    0xffffffc8(%ebp),%eax
f0102c97:	89 07                	mov    %eax,(%edi)
f0102c99:	8b 45 cc             	mov    0xffffffcc(%ebp),%eax
f0102c9c:	89 47 04             	mov    %eax,0x4(%edi)
f0102c9f:	8b 45 d0             	mov    0xffffffd0(%ebp),%eax
f0102ca2:	89 47 08             	mov    %eax,0x8(%edi)
f0102ca5:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0102ca8:	89 47 0c             	mov    %eax,0xc(%edi)
f0102cab:	c7 47 10 ff ff ff ff 	movl   $0xffffffff,0x10(%edi)
}
f0102cb2:	89 f8                	mov    %edi,%eax
f0102cb4:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0102cb7:	5b                   	pop    %ebx
f0102cb8:	5e                   	pop    %esi
f0102cb9:	5f                   	pop    %edi
f0102cba:	5d                   	pop    %ebp
f0102cbb:	c2 04 00             	ret    $0x4

f0102cbe <get_user_program_info>:

struct UserProgramInfo* get_user_program_info(char* user_program_name)
{
f0102cbe:	55                   	push   %ebp
f0102cbf:	89 e5                	mov    %esp,%ebp
f0102cc1:	56                   	push   %esi
f0102cc2:	53                   	push   %ebx
f0102cc3:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ccb:	3b 1d 14 d7 11 f0    	cmp    0xf011d714,%ebx
f0102cd1:	7d 24                	jge    f0102cf7 <get_user_program_info+0x39>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
f0102cd3:	83 ec 08             	sub    $0x8,%esp
f0102cd6:	89 d8                	mov    %ebx,%eax
f0102cd8:	c1 e0 04             	shl    $0x4,%eax
f0102cdb:	ff b0 c0 d6 11 f0    	pushl  0xf011d6c0(%eax)
f0102ce1:	56                   	push   %esi
f0102ce2:	e8 0d 12 00 00       	call   f0103ef4 <strcmp>
f0102ce7:	83 c4 10             	add    $0x10,%esp
f0102cea:	85 c0                	test   %eax,%eax
f0102cec:	74 09                	je     f0102cf7 <get_user_program_info+0x39>
f0102cee:	43                   	inc    %ebx
f0102cef:	3b 1d 14 d7 11 f0    	cmp    0xf011d714,%ebx
f0102cf5:	7c dc                	jl     f0102cd3 <get_user_program_info+0x15>
			break;
	}
	if(i==NUM_USER_PROGS) 
f0102cf7:	3b 1d 14 d7 11 f0    	cmp    0xf011d714,%ebx
f0102cfd:	75 15                	jne    f0102d14 <get_user_program_info+0x56>
	{
		cprintf("Unknown user program '%s'\n", user_program_name);
f0102cff:	83 ec 08             	sub    $0x8,%esp
f0102d02:	56                   	push   %esi
f0102d03:	68 74 58 10 f0       	push   $0xf0105874
f0102d08:	e8 f1 01 00 00       	call   f0102efe <cprintf>
		return 0;
f0102d0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d12:	eb 0a                	jmp    f0102d1e <get_user_program_info+0x60>
	}

	return &userPrograms[i];
f0102d14:	89 d8                	mov    %ebx,%eax
f0102d16:	c1 e0 04             	shl    $0x4,%eax
f0102d19:	05 c0 d6 11 f0       	add    $0xf011d6c0,%eax
}
f0102d1e:	8d 65 f8             	lea    0xfffffff8(%ebp),%esp
f0102d21:	5b                   	pop    %ebx
f0102d22:	5e                   	pop    %esi
f0102d23:	5d                   	pop    %ebp
f0102d24:	c3                   	ret    

f0102d25 <get_user_program_info_by_env>:

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
{
f0102d25:	55                   	push   %ebp
f0102d26:	89 e5                	mov    %esp,%ebp
f0102d28:	53                   	push   %ebx
f0102d29:	83 ec 04             	sub    $0x4,%esp
f0102d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102d2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d34:	3b 15 14 d7 11 f0    	cmp    0xf011d714,%edx
f0102d3a:	7d 18                	jge    f0102d54 <get_user_program_info_by_env+0x2f>
f0102d3c:	8b 0d 14 d7 11 f0    	mov    0xf011d714,%ecx
		if (e== userPrograms[i].environment)
f0102d42:	89 d0                	mov    %edx,%eax
f0102d44:	c1 e0 04             	shl    $0x4,%eax
f0102d47:	3b 98 cc d6 11 f0    	cmp    0xf011d6cc(%eax),%ebx
f0102d4d:	74 05                	je     f0102d54 <get_user_program_info_by_env+0x2f>
f0102d4f:	42                   	inc    %edx
f0102d50:	39 ca                	cmp    %ecx,%edx
f0102d52:	7c ee                	jl     f0102d42 <get_user_program_info_by_env+0x1d>
			break;
	}
	if(i==NUM_USER_PROGS) 
f0102d54:	3b 15 14 d7 11 f0    	cmp    0xf011d714,%edx
f0102d5a:	75 14                	jne    f0102d70 <get_user_program_info_by_env+0x4b>
	{
		cprintf("Unknown user program \n");
f0102d5c:	83 ec 0c             	sub    $0xc,%esp
f0102d5f:	68 8f 58 10 f0       	push   $0xf010588f
f0102d64:	e8 95 01 00 00       	call   f0102efe <cprintf>
		return 0;
f0102d69:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6e:	eb 0a                	jmp    f0102d7a <get_user_program_info_by_env+0x55>
	}

	return &userPrograms[i];
f0102d70:	89 d0                	mov    %edx,%eax
f0102d72:	c1 e0 04             	shl    $0x4,%eax
f0102d75:	05 c0 d6 11 f0       	add    $0xf011d6c0,%eax
}
f0102d7a:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f0102d7d:	c9                   	leave  
f0102d7e:	c3                   	ret    

f0102d7f <set_environment_entry_point>:

void set_environment_entry_point(struct UserProgramInfo* ptr_user_program)
{
f0102d7f:	55                   	push   %ebp
f0102d80:	89 e5                	mov    %esp,%ebp
f0102d82:	83 ec 08             	sub    $0x8,%esp
f0102d85:	8b 45 08             	mov    0x8(%ebp),%eax
	uint8* ptr_program_start=ptr_user_program->ptr_start;
	struct Env* e = ptr_user_program->environment;
f0102d88:	8b 50 0c             	mov    0xc(%eax),%edx

	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102d8b:	8b 40 08             	mov    0x8(%eax),%eax
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102d8e:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0102d94:	74 17                	je     f0102dad <set_environment_entry_point+0x2e>
		panic("Matafa2nash 3ala Keda"); 
f0102d96:	83 ec 04             	sub    $0x4,%esp
f0102d99:	68 5e 58 10 f0       	push   $0xf010585e
f0102d9e:	68 99 01 00 00       	push   $0x199
f0102da3:	68 46 58 10 f0       	push   $0xf0105846
f0102da8:	e8 51 d3 ff ff       	call   f01000fe <_panic>
	e->env_tf.tf_eip = (uint32*)pELFHDR->e_entry ;
f0102dad:	8b 40 18             	mov    0x18(%eax),%eax
f0102db0:	89 42 30             	mov    %eax,0x30(%edx)
}
f0102db3:	c9                   	leave  
f0102db4:	c3                   	ret    

f0102db5 <env_destroy>:



//
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102db5:	55                   	push   %ebp
f0102db6:	89 e5                	mov    %esp,%ebp
f0102db8:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102dbb:	ff 75 08             	pushl  0x8(%ebp)
f0102dbe:	e8 07 fc ff ff       	call   f01029ca <env_free>

	//cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
f0102dc3:	83 c4 10             	add    $0x10,%esp
		run_command_prompt();
f0102dc6:	e8 98 db ff ff       	call   f0100963 <run_command_prompt>
f0102dcb:	eb f9                	jmp    f0102dc6 <env_destroy+0x11>

f0102dcd <env_run_cmd_prmpt>:
}

void env_run_cmd_prmpt()
{
f0102dcd:	55                   	push   %ebp
f0102dce:	89 e5                	mov    %esp,%ebp
f0102dd0:	53                   	push   %ebx
f0102dd1:	83 ec 10             	sub    $0x10,%esp
	struct UserProgramInfo* upi= get_user_program_info_by_env(curenv);	
f0102dd4:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f0102dda:	e8 46 ff ff ff       	call   f0102d25 <get_user_program_info_by_env>
f0102ddf:	89 c3                	mov    %eax,%ebx
	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&curenv->env_tf, 0, sizeof(curenv->env_tf));
f0102de1:	83 c4 0c             	add    $0xc,%esp
f0102de4:	6a 44                	push   $0x44
f0102de6:	6a 00                	push   $0x0
f0102de8:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f0102dee:	e8 bc 11 00 00       	call   f0103faf <memset>

	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	curenv->env_tf.tf_ds = GD_UD | 3;
f0102df3:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0102df8:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	curenv->env_tf.tf_es = GD_UD | 3;
f0102dfe:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0102e03:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	curenv->env_tf.tf_ss = GD_UD | 3;
f0102e09:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0102e0e:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	curenv->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102e14:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0102e19:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	curenv->env_tf.tf_cs = GD_UT | 3;
f0102e20:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0102e25:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	set_environment_entry_point(upi);
f0102e2b:	89 1c 24             	mov    %ebx,(%esp)
f0102e2e:	e8 4c ff ff ff       	call   f0102d7f <set_environment_entry_point>
}

static __inline void
lcr3(uint32 val)
{
f0102e33:	83 c4 10             	add    $0x10,%esp
	
	lcr3(K_PHYSICAL_ADDRESS(ptr_page_directory));
f0102e36:	a1 cc f5 1b f0       	mov    0xf01bf5cc,%eax
f0102e3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e40:	77 15                	ja     f0102e57 <env_run_cmd_prmpt+0x8a>
f0102e42:	50                   	push   %eax
f0102e43:	68 80 4f 10 f0       	push   $0xf0104f80
f0102e48:	68 c4 01 00 00       	push   $0x1c4
f0102e4d:	68 46 58 10 f0       	push   $0xf0105846
f0102e52:	e8 a7 d2 ff ff       	call   f01000fe <_panic>
f0102e57:	05 00 00 00 10       	add    $0x10000000,%eax

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e5c:	0f 22 d8             	mov    %eax,%cr3
	
	curenv = NULL;
f0102e5f:	c7 05 34 9d 1b f0 00 	movl   $0x0,0xf01b9d34
f0102e66:	00 00 00 
	
	while (1)
		run_command_prompt();
f0102e69:	e8 f5 da ff ff       	call   f0100963 <run_command_prompt>
f0102e6e:	eb f9                	jmp    f0102e69 <env_run_cmd_prmpt+0x9c>

f0102e70 <env_pop_tf>:
}
		
//
// Restores the register values in the Trapframe with the 'iret' instruction.
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102e70:	55                   	push   %ebp
f0102e71:	89 e5                	mov    %esp,%ebp
f0102e73:	83 ec 0c             	sub    $0xc,%esp
f0102e76:	8b 45 08             	mov    0x8(%ebp),%eax
	__asm __volatile("movl %0,%%esp\n"
f0102e79:	89 c4                	mov    %eax,%esp
f0102e7b:	61                   	popa   
f0102e7c:	07                   	pop    %es
f0102e7d:	1f                   	pop    %ds
f0102e7e:	83 c4 08             	add    $0x8,%esp
f0102e81:	cf                   	iret   
		"\tpopal\n"
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e82:	68 a6 58 10 f0       	push   $0xf01058a6
f0102e87:	68 db 01 00 00       	push   $0x1db
f0102e8c:	68 46 58 10 f0       	push   $0xf0105846
f0102e91:	e8 68 d2 ff ff       	call   f01000fe <_panic>
	...

f0102e98 <mc146818_read>:


unsigned
mc146818_read(unsigned reg)
{
f0102e98:	55                   	push   %ebp
f0102e99:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8 data)
{
f0102e9b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ea0:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ea3:	ee                   	out    %al,(%dx)
f0102ea4:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ea9:	ec                   	in     (%dx),%al
f0102eaa:	25 ff 00 00 00       	and    $0xff,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0102eaf:	5d                   	pop    %ebp
f0102eb0:	c3                   	ret    

f0102eb1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102eb1:	55                   	push   %ebp
f0102eb2:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8 data)
{
f0102eb4:	ba 70 00 00 00       	mov    $0x70,%edx
f0102eb9:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ebc:	ee                   	out    %al,(%dx)
f0102ebd:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ec2:	8a 45 0c             	mov    0xc(%ebp),%al
f0102ec5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102ec6:	5d                   	pop    %ebp
f0102ec7:	c3                   	ret    

f0102ec8 <putch>:


static void
putch(int ch, int *cnt)
{
f0102ec8:	55                   	push   %ebp
f0102ec9:	89 e5                	mov    %esp,%ebp
f0102ecb:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102ece:	ff 75 08             	pushl  0x8(%ebp)
f0102ed1:	e8 91 d7 ff ff       	call   f0100667 <cputchar>
	*cnt++;
}
f0102ed6:	c9                   	leave  
f0102ed7:	c3                   	ret    

f0102ed8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102ed8:	55                   	push   %ebp
f0102ed9:	89 e5                	mov    %esp,%ebp
f0102edb:	83 ec 08             	sub    $0x8,%esp
	int cnt = 0;
f0102ede:	c7 45 fc 00 00 00 00 	movl   $0x0,0xfffffffc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102ee5:	ff 75 0c             	pushl  0xc(%ebp)
f0102ee8:	ff 75 08             	pushl  0x8(%ebp)
f0102eeb:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0102eee:	50                   	push   %eax
f0102eef:	68 c8 2e 10 f0       	push   $0xf0102ec8
f0102ef4:	e8 bb 0a 00 00       	call   f01039b4 <vprintfmt>
	return cnt;
f0102ef9:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
}
f0102efc:	c9                   	leave  
f0102efd:	c3                   	ret    

f0102efe <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102efe:	55                   	push   %ebp
f0102eff:	89 e5                	mov    %esp,%ebp
f0102f01:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f04:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f07:	50                   	push   %eax
f0102f08:	ff 75 08             	pushl  0x8(%ebp)
f0102f0b:	e8 c8 ff ff ff       	call   f0102ed8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f10:	c9                   	leave  
f0102f11:	c3                   	ret    
	...

f0102f14 <trapname>:
extern  void (*PAGE_FAULT)();
extern  void (*SYSCALL_HANDLER)();

static const char *trapname(int trapno)
{
f0102f14:	55                   	push   %ebp
f0102f15:	89 e5                	mov    %esp,%ebp
f0102f17:	8b 55 08             	mov    0x8(%ebp),%edx
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
f0102f1a:	83 fa 13             	cmp    $0x13,%edx
f0102f1d:	77 09                	ja     f0102f28 <trapname+0x14>
		return excnames[trapno];
f0102f1f:	8b 04 95 a0 5c 10 f0 	mov    0xf0105ca0(,%edx,4),%eax
f0102f26:	eb 0f                	jmp    f0102f37 <trapname+0x23>
	if (trapno == T_SYSCALL)
f0102f28:	b8 38 5b 10 f0       	mov    $0xf0105b38,%eax
f0102f2d:	83 fa 30             	cmp    $0x30,%edx
f0102f30:	74 05                	je     f0102f37 <trapname+0x23>
		return "System call";
	return "(unknown trap)";
f0102f32:	b8 d0 5a 10 f0       	mov    $0xf0105ad0,%eax
}
f0102f37:	5d                   	pop    %ebp
f0102f38:	c3                   	ret    

f0102f39 <idt_init>:


void
idt_init(void)
{
f0102f39:	55                   	push   %ebp
f0102f3a:	89 e5                	mov    %esp,%ebp
f0102f3c:	53                   	push   %ebx
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	//initialize idt
	SETGATE(idt[T_PGFLT], 0, GD_KT , &PAGE_FAULT, 0) ;
f0102f3d:	b8 dc 32 10 f0       	mov    $0xf01032dc,%eax
f0102f42:	66 a3 b0 9d 1b f0    	mov    %ax,0xf01b9db0
f0102f48:	66 c7 05 b2 9d 1b f0 	movw   $0x8,0xf01b9db2
f0102f4f:	08 00 
f0102f51:	c6 05 b4 9d 1b f0 00 	movb   $0x0,0xf01b9db4
f0102f58:	c6 05 b5 9d 1b f0 8e 	movb   $0x8e,0xf01b9db5
f0102f5f:	c1 e8 10             	shr    $0x10,%eax
f0102f62:	66 a3 b6 9d 1b f0    	mov    %ax,0xf01b9db6
	SETGATE(idt[T_SYSCALL], 0, GD_KT , &SYSCALL_HANDLER, 3) ;
f0102f68:	b8 e0 32 10 f0       	mov    $0xf01032e0,%eax
f0102f6d:	66 a3 c0 9e 1b f0    	mov    %ax,0xf01b9ec0
f0102f73:	66 c7 05 c2 9e 1b f0 	movw   $0x8,0xf01b9ec2
f0102f7a:	08 00 
f0102f7c:	c6 05 c4 9e 1b f0 00 	movb   $0x0,0xf01b9ec4
f0102f83:	c6 05 c5 9e 1b f0 ee 	movb   $0xee,0xf01b9ec5
f0102f8a:	c1 e8 10             	shr    $0x10,%eax
f0102f8d:	66 a3 c6 9e 1b f0    	mov    %ax,0xf01b9ec6

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KERNEL_STACK_TOP;
f0102f93:	c7 05 44 a5 1b f0 00 	movl   $0xefc00000,0xf01ba544
f0102f9a:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0102f9d:	66 c7 05 48 a5 1b f0 	movw   $0x10,0xf01ba548
f0102fa4:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32) (&ts),
					sizeof(struct Taskstate), 0);
f0102fa6:	66 b8 68 00          	mov    $0x68,%ax
f0102faa:	bb 40 a5 1b f0       	mov    $0xf01ba540,%ebx
f0102faf:	89 d9                	mov    %ebx,%ecx
f0102fb1:	c1 e1 10             	shl    $0x10,%ecx
f0102fb4:	25 ff ff 00 00       	and    $0xffff,%eax
f0102fb9:	09 c8                	or     %ecx,%eax
f0102fbb:	89 d9                	mov    %ebx,%ecx
f0102fbd:	c1 e9 10             	shr    $0x10,%ecx
f0102fc0:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0102fc6:	88 ca                	mov    %cl,%dl
f0102fc8:	80 e6 f0             	and    $0xf0,%dh
f0102fcb:	80 ce 09             	or     $0x9,%dh
f0102fce:	80 ce 10             	or     $0x10,%dh
f0102fd1:	80 e6 9f             	and    $0x9f,%dh
f0102fd4:	80 ce 80             	or     $0x80,%dh
f0102fd7:	81 e2 ff ff f0 ff    	and    $0xfff0ffff,%edx
f0102fdd:	81 e2 ff ff ef ff    	and    $0xffefffff,%edx
f0102fe3:	81 e2 ff ff df ff    	and    $0xffdfffff,%edx
f0102fe9:	81 ca 00 00 40 00    	or     $0x400000,%edx
f0102fef:	81 e2 ff ff 7f ff    	and    $0xff7fffff,%edx
f0102ff5:	81 e3 00 00 00 ff    	and    $0xff000000,%ebx
f0102ffb:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
f0103001:	09 da                	or     %ebx,%edx
f0103003:	a3 a8 d6 11 f0       	mov    %eax,0xf011d6a8
f0103008:	89 15 ac d6 11 f0    	mov    %edx,0xf011d6ac
	gdt[GD_TSS >> 3].sd_s = 0;
f010300e:	80 25 ad d6 11 f0 ef 	andb   $0xef,0xf011d6ad
}

static __inline void
ltr(uint16 sel)
{
f0103015:	b8 28 00 00 00       	mov    $0x28,%eax
	__asm __volatile("ltr %0" : : "r" (sel));
f010301a:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f010301d:	0f 01 1d 18 d7 11 f0 	lidtl  0xf011d718
}
f0103024:	5b                   	pop    %ebx
f0103025:	5d                   	pop    %ebp
f0103026:	c3                   	ret    

f0103027 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0103027:	55                   	push   %ebp
f0103028:	89 e5                	mov    %esp,%ebp
f010302a:	53                   	push   %ebx
f010302b:	83 ec 0c             	sub    $0xc,%esp
f010302e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103031:	53                   	push   %ebx
f0103032:	68 44 5b 10 f0       	push   $0xf0105b44
f0103037:	e8 c2 fe ff ff       	call   f0102efe <cprintf>
	print_regs(&tf->tf_regs);
f010303c:	89 1c 24             	mov    %ebx,(%esp)
f010303f:	e8 bd 00 00 00       	call   f0103101 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103044:	83 c4 08             	add    $0x8,%esp
f0103047:	66 8b 43 20          	mov    0x20(%ebx),%ax
f010304b:	25 ff ff 00 00       	and    $0xffff,%eax
f0103050:	50                   	push   %eax
f0103051:	68 56 5b 10 f0       	push   $0xf0105b56
f0103056:	e8 a3 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010305b:	83 c4 08             	add    $0x8,%esp
f010305e:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0103062:	25 ff ff 00 00       	and    $0xffff,%eax
f0103067:	50                   	push   %eax
f0103068:	68 69 5b 10 f0       	push   $0xf0105b69
f010306d:	e8 8c fe ff ff       	call   f0102efe <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103072:	83 c4 04             	add    $0x4,%esp
f0103075:	ff 73 28             	pushl  0x28(%ebx)
f0103078:	e8 97 fe ff ff       	call   f0102f14 <trapname>
f010307d:	83 c4 0c             	add    $0xc,%esp
f0103080:	50                   	push   %eax
f0103081:	ff 73 28             	pushl  0x28(%ebx)
f0103084:	68 7c 5b 10 f0       	push   $0xf0105b7c
f0103089:	e8 70 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f010308e:	83 c4 08             	add    $0x8,%esp
f0103091:	ff 73 2c             	pushl  0x2c(%ebx)
f0103094:	68 8e 5b 10 f0       	push   $0xf0105b8e
f0103099:	e8 60 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010309e:	83 c4 08             	add    $0x8,%esp
f01030a1:	ff 73 30             	pushl  0x30(%ebx)
f01030a4:	68 9d 5b 10 f0       	push   $0xf0105b9d
f01030a9:	e8 50 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01030ae:	83 c4 08             	add    $0x8,%esp
f01030b1:	66 8b 43 34          	mov    0x34(%ebx),%ax
f01030b5:	25 ff ff 00 00       	and    $0xffff,%eax
f01030ba:	50                   	push   %eax
f01030bb:	68 ac 5b 10 f0       	push   $0xf0105bac
f01030c0:	e8 39 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01030c5:	83 c4 08             	add    $0x8,%esp
f01030c8:	ff 73 38             	pushl  0x38(%ebx)
f01030cb:	68 bf 5b 10 f0       	push   $0xf0105bbf
f01030d0:	e8 29 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f01030d5:	83 c4 08             	add    $0x8,%esp
f01030d8:	ff 73 3c             	pushl  0x3c(%ebx)
f01030db:	68 ce 5b 10 f0       	push   $0xf0105bce
f01030e0:	e8 19 fe ff ff       	call   f0102efe <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01030e5:	83 c4 08             	add    $0x8,%esp
f01030e8:	66 8b 43 40          	mov    0x40(%ebx),%ax
f01030ec:	25 ff ff 00 00       	and    $0xffff,%eax
f01030f1:	50                   	push   %eax
f01030f2:	68 dd 5b 10 f0       	push   $0xf0105bdd
f01030f7:	e8 02 fe ff ff       	call   f0102efe <cprintf>
}
f01030fc:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01030ff:	c9                   	leave  
f0103100:	c3                   	ret    

f0103101 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f0103101:	55                   	push   %ebp
f0103102:	89 e5                	mov    %esp,%ebp
f0103104:	53                   	push   %ebx
f0103105:	83 ec 0c             	sub    $0xc,%esp
f0103108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010310b:	ff 33                	pushl  (%ebx)
f010310d:	68 f0 5b 10 f0       	push   $0xf0105bf0
f0103112:	e8 e7 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103117:	83 c4 08             	add    $0x8,%esp
f010311a:	ff 73 04             	pushl  0x4(%ebx)
f010311d:	68 ff 5b 10 f0       	push   $0xf0105bff
f0103122:	e8 d7 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103127:	83 c4 08             	add    $0x8,%esp
f010312a:	ff 73 08             	pushl  0x8(%ebx)
f010312d:	68 0e 5c 10 f0       	push   $0xf0105c0e
f0103132:	e8 c7 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103137:	83 c4 08             	add    $0x8,%esp
f010313a:	ff 73 0c             	pushl  0xc(%ebx)
f010313d:	68 1d 5c 10 f0       	push   $0xf0105c1d
f0103142:	e8 b7 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103147:	83 c4 08             	add    $0x8,%esp
f010314a:	ff 73 10             	pushl  0x10(%ebx)
f010314d:	68 2c 5c 10 f0       	push   $0xf0105c2c
f0103152:	e8 a7 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103157:	83 c4 08             	add    $0x8,%esp
f010315a:	ff 73 14             	pushl  0x14(%ebx)
f010315d:	68 3b 5c 10 f0       	push   $0xf0105c3b
f0103162:	e8 97 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103167:	83 c4 08             	add    $0x8,%esp
f010316a:	ff 73 18             	pushl  0x18(%ebx)
f010316d:	68 4a 5c 10 f0       	push   $0xf0105c4a
f0103172:	e8 87 fd ff ff       	call   f0102efe <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103177:	83 c4 08             	add    $0x8,%esp
f010317a:	ff 73 1c             	pushl  0x1c(%ebx)
f010317d:	68 59 5c 10 f0       	push   $0xf0105c59
f0103182:	e8 77 fd ff ff       	call   f0102efe <cprintf>
}
f0103187:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010318a:	c9                   	leave  
f010318b:	c3                   	ret    

f010318c <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f010318c:	55                   	push   %ebp
f010318d:	89 e5                	mov    %esp,%ebp
f010318f:	53                   	push   %ebx
f0103190:	83 ec 04             	sub    $0x4,%esp
f0103193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if(tf->tf_trapno == T_PGFLT)
f0103196:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010319a:	75 0e                	jne    f01031aa <trap_dispatch+0x1e>
	{
		page_fault_handler(tf);
f010319c:	83 ec 0c             	sub    $0xc,%esp
f010319f:	53                   	push   %ebx
f01031a0:	e8 f9 00 00 00       	call   f010329e <page_fault_handler>
f01031a5:	83 c4 10             	add    $0x10,%esp
f01031a8:	eb 5f                	jmp    f0103209 <trap_dispatch+0x7d>
	}
	else if (tf->tf_trapno == T_SYSCALL)
f01031aa:	83 7b 28 30          	cmpl   $0x30,0x28(%ebx)
f01031ae:	75 21                	jne    f01031d1 <trap_dispatch+0x45>
	{
		uint32 ret = syscall(tf->tf_regs.reg_eax
f01031b0:	83 ec 08             	sub    $0x8,%esp
f01031b3:	ff 73 04             	pushl  0x4(%ebx)
f01031b6:	ff 33                	pushl  (%ebx)
f01031b8:	ff 73 10             	pushl  0x10(%ebx)
f01031bb:	ff 73 18             	pushl  0x18(%ebx)
f01031be:	ff 73 14             	pushl  0x14(%ebx)
f01031c1:	ff 73 1c             	pushl  0x1c(%ebx)
f01031c4:	e8 63 03 00 00       	call   f010352c <syscall>
			,tf->tf_regs.reg_edx
			,tf->tf_regs.reg_ecx
			,tf->tf_regs.reg_ebx
			,tf->tf_regs.reg_edi
					,tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f01031c9:	89 43 1c             	mov    %eax,0x1c(%ebx)
f01031cc:	83 c4 20             	add    $0x20,%esp
f01031cf:	eb 38                	jmp    f0103209 <trap_dispatch+0x7d>
	}
	else
	{
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f01031d1:	83 ec 0c             	sub    $0xc,%esp
f01031d4:	53                   	push   %ebx
f01031d5:	e8 4d fe ff ff       	call   f0103027 <print_trapframe>
		if (tf->tf_cs == GD_KT)
f01031da:	83 c4 10             	add    $0x10,%esp
f01031dd:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01031e2:	75 17                	jne    f01031fb <trap_dispatch+0x6f>
			panic("unhandled trap in kernel");
f01031e4:	83 ec 04             	sub    $0x4,%esp
f01031e7:	68 68 5c 10 f0       	push   $0xf0105c68
f01031ec:	68 8a 00 00 00       	push   $0x8a
f01031f1:	68 81 5c 10 f0       	push   $0xf0105c81
f01031f6:	e8 03 cf ff ff       	call   f01000fe <_panic>
		else {
			env_destroy(curenv);
f01031fb:	83 ec 0c             	sub    $0xc,%esp
f01031fe:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f0103204:	e8 ac fb ff ff       	call   f0102db5 <env_destroy>
			return;	
		}
	}
	return;
}
f0103209:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f010320c:	c9                   	leave  
f010320d:	c3                   	ret    

f010320e <trap>:

void
trap(struct Trapframe *tf)
{
f010320e:	55                   	push   %ebp
f010320f:	89 e5                	mov    %esp,%ebp
f0103211:	83 ec 08             	sub    $0x8,%esp
f0103214:	8b 55 08             	mov    0x8(%ebp),%edx
	//cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
f0103217:	66 8b 42 34          	mov    0x34(%edx),%ax
f010321b:	83 e0 03             	and    $0x3,%eax
f010321e:	83 f8 03             	cmp    $0x3,%eax
f0103221:	75 34                	jne    f0103257 <trap+0x49>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103223:	83 3d 34 9d 1b f0 00 	cmpl   $0x0,0xf01b9d34
f010322a:	75 11                	jne    f010323d <trap+0x2f>
f010322c:	68 8d 5c 10 f0       	push   $0xf0105c8d
f0103231:	68 a2 55 10 f0       	push   $0xf01055a2
f0103236:	68 9d 00 00 00       	push   $0x9d
f010323b:	eb 49                	jmp    f0103286 <trap+0x78>
		curenv->env_tf = *tf;
f010323d:	83 ec 04             	sub    $0x4,%esp
f0103240:	6a 44                	push   $0x44
f0103242:	52                   	push   %edx
f0103243:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f0103249:	e8 7e 0d 00 00       	call   f0103fcc <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010324e:	8b 15 34 9d 1b f0    	mov    0xf01b9d34,%edx
f0103254:	83 c4 10             	add    $0x10,%esp
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f0103257:	83 ec 0c             	sub    $0xc,%esp
f010325a:	52                   	push   %edx
f010325b:	e8 2c ff ff ff       	call   f010318c <trap_dispatch>

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f0103260:	83 c4 10             	add    $0x10,%esp
f0103263:	83 3d 34 9d 1b f0 00 	cmpl   $0x0,0xf01b9d34
f010326a:	74 0b                	je     f0103277 <trap+0x69>
f010326c:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0103271:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103275:	74 19                	je     f0103290 <trap+0x82>
f0103277:	68 00 5d 10 f0       	push   $0xf0105d00
f010327c:	68 a2 55 10 f0       	push   $0xf01055a2
f0103281:	68 a7 00 00 00       	push   $0xa7
f0103286:	68 81 5c 10 f0       	push   $0xf0105c81
f010328b:	e8 6e ce ff ff       	call   f01000fe <_panic>
        env_run(curenv);
f0103290:	83 ec 0c             	sub    $0xc,%esp
f0103293:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f0103299:	e8 fa f6 ff ff       	call   f0102998 <env_run>

f010329e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010329e:	55                   	push   %ebp
f010329f:	89 e5                	mov    %esp,%ebp
f01032a1:	53                   	push   %ebx
f01032a2:	83 ec 04             	sub    $0x4,%esp
f01032a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
static __inline uint32
rcr2(void)
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01032a8:	0f 20 d0             	mov    %cr2,%eax
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
f01032ab:	ff 73 30             	pushl  0x30(%ebx)
f01032ae:	50                   	push   %eax
f01032af:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f01032b4:	ff 70 4c             	pushl  0x4c(%eax)
f01032b7:	68 40 5d 10 f0       	push   $0xf0105d40
f01032bc:	e8 3d fc ff ff       	call   f0102efe <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01032c1:	89 1c 24             	mov    %ebx,(%esp)
f01032c4:	e8 5e fd ff ff       	call   f0103027 <print_trapframe>
	env_destroy(curenv);
f01032c9:	83 c4 04             	add    $0x4,%esp
f01032cc:	ff 35 34 9d 1b f0    	pushl  0xf01b9d34
f01032d2:	e8 de fa ff ff       	call   f0102db5 <env_destroy>
	
}
f01032d7:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01032da:	c9                   	leave  
f01032db:	c3                   	ret    

f01032dc <PAGE_FAULT>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER(PAGE_FAULT, T_PGFLT)		
f01032dc:	6a 0e                	push   $0xe
f01032de:	eb 06                	jmp    f01032e6 <_alltraps>

f01032e0 <SYSCALL_HANDLER>:

TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL)
f01032e0:	6a 00                	push   $0x0
f01032e2:	6a 30                	push   $0x30
f01032e4:	eb 00                	jmp    f01032e6 <_alltraps>

f01032e6 <_alltraps>:
	

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:

push %ds 
f01032e6:	1e                   	push   %ds
push %es 
f01032e7:	06                   	push   %es
pushal 	
f01032e8:	60                   	pusha  

mov $(GD_KD), %ax 
f01032e9:	66 b8 10 00          	mov    $0x10,%ax
mov %ax,%ds
f01032ed:	8e d8                	mov    %eax,%ds
mov %ax,%es
f01032ef:	8e c0                	mov    %eax,%es

push %esp
f01032f1:	54                   	push   %esp

call trap
f01032f2:	e8 17 ff ff ff       	call   f010320e <trap>

pop %ecx /* poping the pointer to the tf from the stack so that the stack top is at the values of the registers posuhed by pusha*/
f01032f7:	59                   	pop    %ecx
popal 	
f01032f8:	61                   	popa   
pop %es 
f01032f9:	07                   	pop    %es
pop %ds    
f01032fa:	1f                   	pop    %ds

/*skipping the trap_no and the error code so that the stack top is at the old eip value*/
add $(8),%esp
f01032fb:	83 c4 08             	add    $0x8,%esp

iret
f01032fe:	cf                   	iret   
	...

f0103300 <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void sys_cputs(const char *s, uint32 len)
{
f0103300:	55                   	push   %ebp
f0103301:	89 e5                	mov    %esp,%ebp
f0103303:	83 ec 0c             	sub    $0xc,%esp
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103306:	ff 75 08             	pushl  0x8(%ebp)
f0103309:	ff 75 0c             	pushl  0xc(%ebp)
f010330c:	68 63 5d 10 f0       	push   $0xf0105d63
f0103311:	e8 e8 fb ff ff       	call   f0102efe <cprintf>
}
f0103316:	c9                   	leave  
f0103317:	c3                   	ret    

f0103318 <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f0103318:	55                   	push   %ebp
f0103319:	89 e5                	mov    %esp,%ebp
f010331b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f010331e:	e8 af d2 ff ff       	call   f01005d2 <cons_getc>
f0103323:	85 c0                	test   %eax,%eax
f0103325:	74 f7                	je     f010331e <sys_cgetc+0x6>
		/* do nothing */;

	return c;
}
f0103327:	c9                   	leave  
f0103328:	c3                   	ret    

f0103329 <sys_getenvid>:

// Returns the current environment's envid.
static int32 sys_getenvid(void)
{
f0103329:	55                   	push   %ebp
f010332a:	89 e5                	mov    %esp,%ebp
	return curenv->env_id;
f010332c:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0103331:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f0103334:	5d                   	pop    %ebp
f0103335:	c3                   	ret    

f0103336 <sys_env_destroy>:

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int sys_env_destroy(int32  envid)
{
f0103336:	55                   	push   %ebp
f0103337:	89 e5                	mov    %esp,%ebp
f0103339:	83 ec 0c             	sub    $0xc,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010333c:	6a 01                	push   $0x1
f010333e:	8d 45 fc             	lea    0xfffffffc(%ebp),%eax
f0103341:	50                   	push   %eax
f0103342:	ff 75 08             	pushl  0x8(%ebp)
f0103345:	e8 72 ed ff ff       	call   f01020bc <envid2env>
f010334a:	83 c4 10             	add    $0x10,%esp
f010334d:	89 c2                	mov    %eax,%edx
f010334f:	85 c0                	test   %eax,%eax
f0103351:	78 43                	js     f0103396 <sys_env_destroy+0x60>
		return r;
	if (e == curenv)
f0103353:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103356:	3b 05 34 9d 1b f0    	cmp    0xf01b9d34,%eax
f010335c:	75 0d                	jne    f010336b <sys_env_destroy+0x35>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010335e:	83 ec 08             	sub    $0x8,%esp
f0103361:	ff 70 4c             	pushl  0x4c(%eax)
f0103364:	68 68 5d 10 f0       	push   $0xf0105d68
f0103369:	eb 16                	jmp    f0103381 <sys_env_destroy+0x4b>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010336b:	83 ec 04             	sub    $0x4,%esp
f010336e:	8b 45 fc             	mov    0xfffffffc(%ebp),%eax
f0103371:	ff 70 4c             	pushl  0x4c(%eax)
f0103374:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0103379:	ff 70 4c             	pushl  0x4c(%eax)
f010337c:	68 83 5d 10 f0       	push   $0xf0105d83
f0103381:	e8 78 fb ff ff       	call   f0102efe <cprintf>
f0103386:	83 c4 04             	add    $0x4,%esp
	env_destroy(e);
f0103389:	ff 75 fc             	pushl  0xfffffffc(%ebp)
f010338c:	e8 24 fa ff ff       	call   f0102db5 <env_destroy>
	return 0;
f0103391:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103396:	89 d0                	mov    %edx,%eax
f0103398:	c9                   	leave  
f0103399:	c3                   	ret    

f010339a <sys_env_sleep>:

static void sys_env_sleep()
{
f010339a:	55                   	push   %ebp
f010339b:	89 e5                	mov    %esp,%ebp
f010339d:	83 ec 08             	sub    $0x8,%esp
	env_run_cmd_prmpt();
f01033a0:	e8 28 fa ff ff       	call   f0102dcd <env_run_cmd_prmpt>
}
f01033a5:	c9                   	leave  
f01033a6:	c3                   	ret    

f01033a7 <sys_allocate_page>:
	

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
f01033a7:	55                   	push   %ebp
f01033a8:	89 e5                	mov    %esp,%ebp
f01033aa:	57                   	push   %edi
f01033ab:	56                   	push   %esi
f01033ac:	53                   	push   %ebx
f01033ad:	83 ec 18             	sub    $0x18,%esp
f01033b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01033b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	int r;
	struct Env *e = curenv;
f01033b6:	8b 35 34 9d 1b f0    	mov    0xf01b9d34,%esi

	//if ((r = envid2env(envid, &e, 1)) < 0)
		//return r;
	
	struct Frame_Info *ptr_frame_info ;
	r = allocate_frame(&ptr_frame_info) ;
f01033bc:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01033bf:	50                   	push   %eax
f01033c0:	e8 a9 f1 ff ff       	call   f010256e <allocate_frame>
	if (r == E_NO_MEM)
f01033c5:	83 c4 10             	add    $0x10,%esp
f01033c8:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f01033cd:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01033d0:	0f 84 ba 00 00 00    	je     f0103490 <sys_allocate_page+0xe9>
		return r ;
	
	//check virtual address to be paged_aligned and < USER_TOP
	if ((uint32)va >= USER_TOP || (uint32)va % PAGE_SIZE != 0)
f01033d6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01033dc:	77 08                	ja     f01033e6 <sys_allocate_page+0x3f>
f01033de:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01033e4:	74 0a                	je     f01033f0 <sys_allocate_page+0x49>
		return E_INVAL;
f01033e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01033eb:	e9 a0 00 00 00       	jmp    f0103490 <sys_allocate_page+0xe9>
	
	//check permissions to be appropriatess
	if ((perm & (~PERM_AVAILABLE & ~PERM_WRITEABLE)) != (PERM_USER))
f01033f0:	89 f8                	mov    %edi,%eax
f01033f2:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01033f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01033fc:	83 f8 04             	cmp    $0x4,%eax
f01033ff:	0f 85 8b 00 00 00    	jne    f0103490 <sys_allocate_page+0xe9>
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
	return ptr_frame_info - frames_info;
f0103405:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
f0103408:	2b 15 c4 f5 1b f0    	sub    0xf01bf5c4,%edx
f010340e:	c1 fa 02             	sar    $0x2,%edx
f0103411:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103414:	89 c1                	mov    %eax,%ecx
f0103416:	c1 e1 04             	shl    $0x4,%ecx
f0103419:	01 c8                	add    %ecx,%eax
f010341b:	89 c1                	mov    %eax,%ecx
f010341d:	c1 e1 08             	shl    $0x8,%ecx
f0103420:	01 c8                	add    %ecx,%eax
f0103422:	89 c1                	mov    %eax,%ecx
f0103424:	c1 e1 10             	shl    $0x10,%ecx
f0103427:	01 c8                	add    %ecx,%eax
f0103429:	8d 04 42             	lea    (%edx,%eax,2),%eax
		return E_INVAL;
	
			
	uint32 physical_address = to_physical_address(ptr_frame_info) ;
	
	memset(K_VIRTUAL_ADDRESS(physical_address), 0, PAGE_SIZE);
f010342c:	89 c2                	mov    %eax,%edx
f010342e:	c1 e2 0c             	shl    $0xc,%edx
f0103431:	89 d0                	mov    %edx,%eax
f0103433:	c1 e8 0c             	shr    $0xc,%eax
f0103436:	3b 05 a8 a5 1b f0    	cmp    0xf01ba5a8,%eax
f010343c:	72 12                	jb     f0103450 <sys_allocate_page+0xa9>
f010343e:	52                   	push   %edx
f010343f:	68 20 51 10 f0       	push   $0xf0105120
f0103444:	6a 7a                	push   $0x7a
f0103446:	68 9b 5d 10 f0       	push   $0xf0105d9b
f010344b:	e8 ae cc ff ff       	call   f01000fe <_panic>
f0103450:	8d 82 00 00 00 f0    	lea    0xf0000000(%edx),%eax
f0103456:	83 ec 04             	sub    $0x4,%esp
f0103459:	68 00 10 00 00       	push   $0x1000
f010345e:	6a 00                	push   $0x0
f0103460:	50                   	push   %eax
f0103461:	e8 49 0b 00 00       	call   f0103faf <memset>
		
	r = map_frame(e->env_pgdir, ptr_frame_info, va, perm) ;
f0103466:	57                   	push   %edi
f0103467:	53                   	push   %ebx
f0103468:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f010346b:	ff 76 5c             	pushl  0x5c(%esi)
f010346e:	e8 9c f2 ff ff       	call   f010270f <map_frame>
	if (r == E_NO_MEM)
f0103473:	83 c4 20             	add    $0x20,%esp
	{
		decrement_references(ptr_frame_info);
		return r;
	}
	return 0 ;
f0103476:	ba 00 00 00 00       	mov    $0x0,%edx
f010347b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010347e:	75 10                	jne    f0103490 <sys_allocate_page+0xe9>
f0103480:	83 ec 0c             	sub    $0xc,%esp
f0103483:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0103486:	e8 4e f1 ff ff       	call   f01025d9 <decrement_references>
f010348b:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
}
f0103490:	89 d0                	mov    %edx,%eax
f0103492:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103495:	5b                   	pop    %ebx
f0103496:	5e                   	pop    %esi
f0103497:	5f                   	pop    %edi
f0103498:	5d                   	pop    %ebp
f0103499:	c3                   	ret    

f010349a <sys_get_page>:

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
f010349a:	55                   	push   %ebp
f010349b:	89 e5                	mov    %esp,%ebp
f010349d:	83 ec 0c             	sub    $0xc,%esp
	return get_page(curenv->env_pgdir, va, perm) ;
f01034a0:	ff 75 0c             	pushl  0xc(%ebp)
f01034a3:	ff 75 08             	pushl  0x8(%ebp)
f01034a6:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f01034ab:	ff 70 5c             	pushl  0x5c(%eax)
f01034ae:	e8 da f3 ff ff       	call   f010288d <get_page>
}
f01034b3:	c9                   	leave  
f01034b4:	c3                   	ret    

f01034b5 <sys_map_frame>:

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
f01034b5:	55                   	push   %ebp
f01034b6:	89 e5                	mov    %esp,%ebp
f01034b8:	83 ec 0c             	sub    $0xc,%esp
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	panic("sys_map_frame not implemented");
f01034bb:	68 aa 5d 10 f0       	push   $0xf0105daa
f01034c0:	68 b1 00 00 00       	push   $0xb1
f01034c5:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01034ca:	e8 2f cc ff ff       	call   f01000fe <_panic>

f01034cf <sys_unmap_frame>:
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
f01034cf:	55                   	push   %ebp
f01034d0:	89 e5                	mov    %esp,%ebp
f01034d2:	83 ec 0c             	sub    $0xc,%esp
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	panic("sys_page_unmap not implemented");
f01034d5:	68 e0 5d 10 f0       	push   $0xf0105de0
f01034da:	68 c0 00 00 00       	push   $0xc0
f01034df:	68 9b 5d 10 f0       	push   $0xf0105d9b
f01034e4:	e8 15 cc ff ff       	call   f01000fe <_panic>

f01034e9 <sys_calculate_required_frames>:
}

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
f01034e9:	55                   	push   %ebp
f01034ea:	89 e5                	mov    %esp,%ebp
f01034ec:	83 ec 0c             	sub    $0xc,%esp
	return calculate_required_frames(curenv->env_pgdir, start_virtual_address, size); 
f01034ef:	ff 75 0c             	pushl  0xc(%ebp)
f01034f2:	ff 75 08             	pushl  0x8(%ebp)
f01034f5:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f01034fa:	ff 70 5c             	pushl  0x5c(%eax)
f01034fd:	e8 a5 f3 ff ff       	call   f01028a7 <calculate_required_frames>
}
f0103502:	c9                   	leave  
f0103503:	c3                   	ret    

f0103504 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
f0103507:	83 ec 08             	sub    $0x8,%esp
	return calculate_free_frames();
f010350a:	e8 b2 f3 ff ff       	call   f01028c1 <calculate_free_frames>
}
f010350f:	c9                   	leave  
f0103510:	c3                   	ret    

f0103511 <sys_freeMem>:
void sys_freeMem(void* start_virtual_address, uint32 size)
{
f0103511:	55                   	push   %ebp
f0103512:	89 e5                	mov    %esp,%ebp
f0103514:	83 ec 0c             	sub    $0xc,%esp
	freeMem((uint32*)curenv->env_pgdir, (void*)start_virtual_address, size);
f0103517:	ff 75 0c             	pushl  0xc(%ebp)
f010351a:	ff 75 08             	pushl  0x8(%ebp)
f010351d:	a1 34 9d 1b f0       	mov    0xf01b9d34,%eax
f0103522:	ff 70 5c             	pushl  0x5c(%eax)
f0103525:	e8 b2 f3 ff ff       	call   f01028dc <freeMem>
	return;
}
f010352a:	c9                   	leave  
f010352b:	c3                   	ret    

f010352c <syscall>:
// Dispatches to the correct kernel function, passing the arguments.
uint32
syscall(uint32 syscallno, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
f010352c:	55                   	push   %ebp
f010352d:	89 e5                	mov    %esp,%ebp
f010352f:	53                   	push   %ebx
f0103530:	83 ec 04             	sub    $0x4,%esp
f0103533:	8b 55 08             	mov    0x8(%ebp),%edx
f0103536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103539:	8b 4d 10             	mov    0x10(%ebp),%ecx
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
f010353c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103541:	83 fa 0c             	cmp    $0xc,%edx
f0103544:	0f 87 95 00 00 00    	ja     f01035df <syscall+0xb3>
f010354a:	ff 24 95 00 5e 10 f0 	jmp    *0xf0105e00(,%edx,4)
f0103551:	83 ec 08             	sub    $0x8,%esp
f0103554:	51                   	push   %ecx
f0103555:	53                   	push   %ebx
f0103556:	e8 a5 fd ff ff       	call   f0103300 <sys_cputs>
f010355b:	eb 76                	jmp    f01035d3 <syscall+0xa7>
f010355d:	e8 b6 fd ff ff       	call   f0103318 <sys_cgetc>
f0103562:	eb 7b                	jmp    f01035df <syscall+0xb3>
f0103564:	e8 c0 fd ff ff       	call   f0103329 <sys_getenvid>
f0103569:	eb 74                	jmp    f01035df <syscall+0xb3>
f010356b:	83 ec 0c             	sub    $0xc,%esp
f010356e:	53                   	push   %ebx
f010356f:	e8 c2 fd ff ff       	call   f0103336 <sys_env_destroy>
f0103574:	eb 69                	jmp    f01035df <syscall+0xb3>
f0103576:	e8 1f fe ff ff       	call   f010339a <sys_env_sleep>
f010357b:	eb 56                	jmp    f01035d3 <syscall+0xa7>
f010357d:	83 ec 08             	sub    $0x8,%esp
f0103580:	51                   	push   %ecx
f0103581:	53                   	push   %ebx
f0103582:	e8 62 ff ff ff       	call   f01034e9 <sys_calculate_required_frames>
f0103587:	eb 56                	jmp    f01035df <syscall+0xb3>
f0103589:	e8 76 ff ff ff       	call   f0103504 <sys_calculate_free_frames>
f010358e:	eb 4f                	jmp    f01035df <syscall+0xb3>
f0103590:	83 ec 08             	sub    $0x8,%esp
f0103593:	51                   	push   %ecx
f0103594:	53                   	push   %ebx
f0103595:	e8 77 ff ff ff       	call   f0103511 <sys_freeMem>
f010359a:	eb 37                	jmp    f01035d3 <syscall+0xa7>
f010359c:	83 ec 08             	sub    $0x8,%esp
f010359f:	51                   	push   %ecx
f01035a0:	53                   	push   %ebx
f01035a1:	e8 01 fe ff ff       	call   f01033a7 <sys_allocate_page>
f01035a6:	eb 2b                	jmp    f01035d3 <syscall+0xa7>
f01035a8:	83 ec 08             	sub    $0x8,%esp
f01035ab:	51                   	push   %ecx
f01035ac:	53                   	push   %ebx
f01035ad:	e8 e8 fe ff ff       	call   f010349a <sys_get_page>
f01035b2:	eb 1f                	jmp    f01035d3 <syscall+0xa7>
f01035b4:	83 ec 0c             	sub    $0xc,%esp
f01035b7:	ff 75 1c             	pushl  0x1c(%ebp)
f01035ba:	ff 75 18             	pushl  0x18(%ebp)
f01035bd:	ff 75 14             	pushl  0x14(%ebp)
f01035c0:	51                   	push   %ecx
f01035c1:	53                   	push   %ebx
f01035c2:	e8 ee fe ff ff       	call   f01034b5 <sys_map_frame>
f01035c7:	eb 0a                	jmp    f01035d3 <syscall+0xa7>
f01035c9:	83 ec 08             	sub    $0x8,%esp
f01035cc:	51                   	push   %ecx
f01035cd:	53                   	push   %ebx
f01035ce:	e8 fc fe ff ff       	call   f01034cf <sys_unmap_frame>
f01035d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d8:	eb 05                	jmp    f01035df <syscall+0xb3>
f01035da:	b8 03 00 00 00       	mov    $0x3,%eax
}
f01035df:	8b 5d fc             	mov    0xfffffffc(%ebp),%ebx
f01035e2:	c9                   	leave  
f01035e3:	c3                   	ret    

f01035e4 <stab_binsearch>:
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
f01035e4:	55                   	push   %ebp
f01035e5:	89 e5                	mov    %esp,%ebp
f01035e7:	57                   	push   %edi
f01035e8:	56                   	push   %esi
f01035e9:	53                   	push   %ebx
f01035ea:	83 ec 0c             	sub    $0xc,%esp
f01035ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01035f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035f3:	8b 08                	mov    (%eax),%ecx
f01035f5:	8b 55 10             	mov    0x10(%ebp),%edx
f01035f8:	8b 12                	mov    (%edx),%edx
f01035fa:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f01035fd:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	
	while (l <= r) {
f0103604:	39 d1                	cmp    %edx,%ecx
f0103606:	0f 8f 8c 00 00 00    	jg     f0103698 <stab_binsearch+0xb4>
		int true_m = (l + r) / 2, m = true_m;
f010360c:	8b 5d e8             	mov    0xffffffe8(%ebp),%ebx
f010360f:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax
f0103612:	89 c2                	mov    %eax,%edx
f0103614:	c1 ea 1f             	shr    $0x1f,%edx
f0103617:	01 d0                	add    %edx,%eax
f0103619:	89 c3                	mov    %eax,%ebx
f010361b:	d1 fb                	sar    %ebx
f010361d:	89 da                	mov    %ebx,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010361f:	39 cb                	cmp    %ecx,%ebx
f0103621:	7c 43                	jl     f0103666 <stab_binsearch+0x82>
f0103623:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103626:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f010362a:	25 ff 00 00 00       	and    $0xff,%eax
f010362f:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103632:	74 16                	je     f010364a <stab_binsearch+0x66>
			m--;
f0103634:	4a                   	dec    %edx
f0103635:	39 ca                	cmp    %ecx,%edx
f0103637:	7c 2d                	jl     f0103666 <stab_binsearch+0x82>
f0103639:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010363c:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f0103640:	25 ff 00 00 00       	and    $0xff,%eax
f0103645:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103648:	75 ea                	jne    f0103634 <stab_binsearch+0x50>
		if (m < l) {	// no match in [l, m]
f010364a:	39 ca                	cmp    %ecx,%edx
f010364c:	7c 18                	jl     f0103666 <stab_binsearch+0x82>
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010364e:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)
		if (stabs[m].n_value < addr) {
f0103655:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0103658:	8b 45 18             	mov    0x18(%ebp),%eax
f010365b:	39 44 b7 08          	cmp    %eax,0x8(%edi,%esi,4)
f010365f:	73 0a                	jae    f010366b <stab_binsearch+0x87>
			*region_left = m;
f0103661:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103664:	89 16                	mov    %edx,(%esi)
			l = true_m + 1;
f0103666:	8d 4b 01             	lea    0x1(%ebx),%ecx
f0103669:	eb 24                	jmp    f010368f <stab_binsearch+0xab>
		} else if (stabs[m].n_value > addr) {
f010366b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010366e:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0103671:	39 5c 87 08          	cmp    %ebx,0x8(%edi,%eax,4)
f0103675:	76 0d                	jbe    f0103684 <stab_binsearch+0xa0>
			*region_right = m - 1;
f0103677:	8d 42 ff             	lea    0xffffffff(%edx),%eax
f010367a:	8b 75 10             	mov    0x10(%ebp),%esi
f010367d:	89 06                	mov    %eax,(%esi)
			r = m - 1;
f010367f:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
f0103682:	eb 0b                	jmp    f010368f <stab_binsearch+0xab>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103684:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103687:	89 10                	mov    %edx,(%eax)
			l = m;
f0103689:	89 d1                	mov    %edx,%ecx
			addr++;
f010368b:	83 45 18 04          	addl   $0x4,0x18(%ebp)
f010368f:	3b 4d e8             	cmp    0xffffffe8(%ebp),%ecx
f0103692:	0f 8e 74 ff ff ff    	jle    f010360c <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f0103698:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f010369c:	75 0d                	jne    f01036ab <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010369e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036a1:	8b 02                	mov    (%edx),%eax
f01036a3:	48                   	dec    %eax
f01036a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01036a7:	89 03                	mov    %eax,(%ebx)
f01036a9:	eb 3b                	jmp    f01036e6 <stab_binsearch+0x102>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01036ab:	8b 75 10             	mov    0x10(%ebp),%esi
f01036ae:	8b 0e                	mov    (%esi),%ecx
f01036b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036b3:	3b 08                	cmp    (%eax),%ecx
f01036b5:	7e 2a                	jle    f01036e1 <stab_binsearch+0xfd>
f01036b7:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01036ba:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f01036be:	25 ff 00 00 00       	and    $0xff,%eax
f01036c3:	3b 45 14             	cmp    0x14(%ebp),%eax
f01036c6:	74 19                	je     f01036e1 <stab_binsearch+0xfd>
f01036c8:	49                   	dec    %ecx
f01036c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036cc:	3b 0a                	cmp    (%edx),%ecx
f01036ce:	7e 11                	jle    f01036e1 <stab_binsearch+0xfd>
f01036d0:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01036d3:	8a 44 87 04          	mov    0x4(%edi,%eax,4),%al
f01036d7:	25 ff 00 00 00       	and    $0xff,%eax
f01036dc:	3b 45 14             	cmp    0x14(%ebp),%eax
f01036df:	75 e7                	jne    f01036c8 <stab_binsearch+0xe4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01036e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036e4:	89 0b                	mov    %ecx,(%ebx)
	}
}
f01036e6:	83 c4 0c             	add    $0xc,%esp
f01036e9:	5b                   	pop    %ebx
f01036ea:	5e                   	pop    %esi
f01036eb:	5f                   	pop    %edi
f01036ec:	5d                   	pop    %ebp
f01036ed:	c3                   	ret    

f01036ee <debuginfo_eip>:


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
f01036ee:	55                   	push   %ebp
f01036ef:	89 e5                	mov    %esp,%ebp
f01036f1:	57                   	push   %edi
f01036f2:	56                   	push   %esi
f01036f3:	53                   	push   %ebx
f01036f4:	83 ec 1c             	sub    $0x1c,%esp
f01036f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01036fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01036fd:	c7 07 34 5e 10 f0    	movl   $0xf0105e34,(%edi)
	info->eip_line = 0;
f0103703:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010370a:	c7 47 08 34 5e 10 f0 	movl   $0xf0105e34,0x8(%edi)
	info->eip_fn_namelen = 9;
f0103711:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0103718:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f010371b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if ((uint32)addr >= USER_LIMIT) {
f0103722:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103728:	76 1a                	jbe    f0103744 <debuginfo_eip+0x56>
		stabs = __STAB_BEGIN__;
f010372a:	be 68 60 10 f0       	mov    $0xf0106068,%esi
		stab_end = __STAB_END__;
f010372f:	b8 68 02 11 f0       	mov    $0xf0110268,%eax
		stabstr = __STABSTR_BEGIN__;
f0103734:	c7 45 e0 69 02 11 f0 	movl   $0xf0110269,0xffffffe0(%ebp)
		stabstr_end = __STABSTR_END__;
f010373b:	c7 45 dc 7f 41 11 f0 	movl   $0xf011417f,0xffffffdc(%ebp)
f0103742:	eb 1d                	jmp    f0103761 <debuginfo_eip+0x73>
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
f0103744:	8b 35 00 00 20 00    	mov    0x200000,%esi
		stab_end = usd->stab_end;
f010374a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010374f:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0103755:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
		stabstr_end = usd->stabstr_end;
f0103758:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010375e:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103761:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f0103764:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
f0103767:	76 09                	jbe    f0103772 <debuginfo_eip+0x84>
f0103769:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f010376c:	80 7a ff 00          	cmpb   $0x0,0xffffffff(%edx)
f0103770:	74 0a                	je     f010377c <debuginfo_eip+0x8e>
		return -1;
f0103772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103777:	e9 33 01 00 00       	jmp    f01038af <debuginfo_eip+0x1c1>

	// Now we find the right stabs that define the function containing
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010377c:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103783:	89 c1                	mov    %eax,%ecx
f0103785:	29 f1                	sub    %esi,%ecx
f0103787:	c1 f9 02             	sar    $0x2,%ecx
f010378a:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f010378d:	89 c2                	mov    %eax,%edx
f010378f:	c1 e2 04             	shl    $0x4,%edx
f0103792:	01 d0                	add    %edx,%eax
f0103794:	89 c2                	mov    %eax,%edx
f0103796:	c1 e2 08             	shl    $0x8,%edx
f0103799:	01 d0                	add    %edx,%eax
f010379b:	89 c2                	mov    %eax,%edx
f010379d:	c1 e2 10             	shl    $0x10,%edx
f01037a0:	01 d0                	add    %edx,%eax
f01037a2:	8d 44 41 ff          	lea    0xffffffff(%ecx,%eax,2),%eax
f01037a6:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01037a9:	83 ec 0c             	sub    $0xc,%esp
f01037ac:	53                   	push   %ebx
f01037ad:	6a 64                	push   $0x64
f01037af:	8d 45 f0             	lea    0xfffffff0(%ebp),%eax
f01037b2:	50                   	push   %eax
f01037b3:	8d 45 ec             	lea    0xffffffec(%ebp),%eax
f01037b6:	50                   	push   %eax
f01037b7:	56                   	push   %esi
f01037b8:	e8 27 fe ff ff       	call   f01035e4 <stab_binsearch>
	if (lfile == 0)
f01037bd:	83 c4 20             	add    $0x20,%esp
f01037c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037c5:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f01037c9:	0f 84 e0 00 00 00    	je     f01038af <debuginfo_eip+0x1c1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01037cf:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01037d2:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
	rfun = rfile;
f01037d5:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01037d8:	89 45 e8             	mov    %eax,0xffffffe8(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01037db:	83 ec 0c             	sub    $0xc,%esp
f01037de:	53                   	push   %ebx
f01037df:	6a 24                	push   $0x24
f01037e1:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f01037e4:	50                   	push   %eax
f01037e5:	8d 45 e4             	lea    0xffffffe4(%ebp),%eax
f01037e8:	50                   	push   %eax
f01037e9:	56                   	push   %esi
f01037ea:	e8 f5 fd ff ff       	call   f01035e4 <stab_binsearch>

	if (lfun <= rfun) {
f01037ef:	83 c4 20             	add    $0x20,%esp
f01037f2:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f01037f5:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f01037f8:	7f 2f                	jg     f0103829 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01037fa:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01037fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103804:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f0103807:	2b 45 e0             	sub    0xffffffe0(%ebp),%eax
f010380a:	39 04 16             	cmp    %eax,(%esi,%edx,1)
f010380d:	73 09                	jae    f0103818 <debuginfo_eip+0x12a>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010380f:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0103812:	03 04 16             	add    (%esi,%edx,1),%eax
f0103815:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = (uint32*) stabs[lfun].n_value;
f0103818:	8b 45 e4             	mov    0xffffffe4(%ebp),%eax
f010381b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010381e:	8b 54 96 08          	mov    0x8(%esi,%edx,4),%edx
f0103822:	89 57 10             	mov    %edx,0x10(%edi)
		addr = (uint32*)(addr - (info->eip_fn_addr));
		// Search within the function definition for the line number.
		lline = lfun;
f0103825:	89 c3                	mov    %eax,%ebx
		rline = rfun;
f0103827:	eb 06                	jmp    f010382f <debuginfo_eip+0x141>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103829:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f010382c:	8b 5d ec             	mov    0xffffffec(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010382f:	83 ec 08             	sub    $0x8,%esp
f0103832:	6a 3a                	push   $0x3a
f0103834:	ff 77 08             	pushl  0x8(%edi)
f0103837:	e8 59 07 00 00       	call   f0103f95 <strfind>
f010383c:	2b 47 08             	sub    0x8(%edi),%eax
f010383f:	89 47 0c             	mov    %eax,0xc(%edi)

	
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
f0103842:	83 c4 10             	add    $0x10,%esp
f0103845:	3b 5d ec             	cmp    0xffffffec(%ebp),%ebx
f0103848:	7c 60                	jl     f01038aa <debuginfo_eip+0x1bc>
f010384a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010384d:	c1 e0 02             	shl    $0x2,%eax
f0103850:	80 7c 06 04 84       	cmpb   $0x84,0x4(%esi,%eax,1)
f0103855:	74 31                	je     f0103888 <debuginfo_eip+0x19a>
f0103857:	80 7c 06 04 64       	cmpb   $0x64,0x4(%esi,%eax,1)
f010385c:	75 07                	jne    f0103865 <debuginfo_eip+0x177>
f010385e:	83 7c 06 08 00       	cmpl   $0x0,0x8(%esi,%eax,1)
f0103863:	75 23                	jne    f0103888 <debuginfo_eip+0x19a>
f0103865:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103868:	4b                   	dec    %ebx
f0103869:	39 d3                	cmp    %edx,%ebx
f010386b:	7c 1b                	jl     f0103888 <debuginfo_eip+0x19a>
f010386d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103870:	c1 e0 02             	shl    $0x2,%eax
f0103873:	80 7c 06 04 84       	cmpb   $0x84,0x4(%esi,%eax,1)
f0103878:	74 0e                	je     f0103888 <debuginfo_eip+0x19a>
f010387a:	80 7c 06 04 64       	cmpb   $0x64,0x4(%esi,%eax,1)
f010387f:	75 e7                	jne    f0103868 <debuginfo_eip+0x17a>
f0103881:	83 7c 06 08 00       	cmpl   $0x0,0x8(%esi,%eax,1)
f0103886:	74 e0                	je     f0103868 <debuginfo_eip+0x17a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103888:	3b 5d ec             	cmp    0xffffffec(%ebp),%ebx
f010388b:	7c 1d                	jl     f01038aa <debuginfo_eip+0x1bc>
f010388d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103890:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103897:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010389a:	2b 45 e0             	sub    0xffffffe0(%ebp),%eax
f010389d:	39 04 16             	cmp    %eax,(%esi,%edx,1)
f01038a0:	73 08                	jae    f01038aa <debuginfo_eip+0x1bc>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01038a2:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01038a5:	03 04 16             	add    (%esi,%edx,1),%eax
f01038a8:	89 07                	mov    %eax,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f01038aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038af:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f01038b2:	5b                   	pop    %ebx
f01038b3:	5e                   	pop    %esi
f01038b4:	5f                   	pop    %edi
f01038b5:	5d                   	pop    %ebp
f01038b6:	c3                   	ret    
	...

f01038b8 <printnum>:
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01038b8:	55                   	push   %ebp
f01038b9:	89 e5                	mov    %esp,%ebp
f01038bb:	57                   	push   %edi
f01038bc:	56                   	push   %esi
f01038bd:	53                   	push   %ebx
f01038be:	83 ec 0c             	sub    $0xc,%esp
f01038c1:	8b 75 10             	mov    0x10(%ebp),%esi
f01038c4:	8b 7d 14             	mov    0x14(%ebp),%edi
f01038c7:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01038ca:	8b 45 18             	mov    0x18(%ebp),%eax
f01038cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01038d2:	39 d7                	cmp    %edx,%edi
f01038d4:	72 39                	jb     f010390f <printnum+0x57>
f01038d6:	77 04                	ja     f01038dc <printnum+0x24>
f01038d8:	39 c6                	cmp    %eax,%esi
f01038da:	72 33                	jb     f010390f <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01038dc:	83 ec 04             	sub    $0x4,%esp
f01038df:	ff 75 20             	pushl  0x20(%ebp)
f01038e2:	8d 43 ff             	lea    0xffffffff(%ebx),%eax
f01038e5:	50                   	push   %eax
f01038e6:	ff 75 18             	pushl  0x18(%ebp)
f01038e9:	8b 45 18             	mov    0x18(%ebp),%eax
f01038ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01038f1:	52                   	push   %edx
f01038f2:	50                   	push   %eax
f01038f3:	57                   	push   %edi
f01038f4:	56                   	push   %esi
f01038f5:	e8 16 0a 00 00       	call   f0104310 <__udivdi3>
f01038fa:	83 c4 10             	add    $0x10,%esp
f01038fd:	52                   	push   %edx
f01038fe:	50                   	push   %eax
f01038ff:	ff 75 0c             	pushl  0xc(%ebp)
f0103902:	ff 75 08             	pushl  0x8(%ebp)
f0103905:	e8 ae ff ff ff       	call   f01038b8 <printnum>
f010390a:	83 c4 20             	add    $0x20,%esp
f010390d:	eb 19                	jmp    f0103928 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010390f:	4b                   	dec    %ebx
f0103910:	85 db                	test   %ebx,%ebx
f0103912:	7e 14                	jle    f0103928 <printnum+0x70>
			putch(padc, putdat);
f0103914:	83 ec 08             	sub    $0x8,%esp
f0103917:	ff 75 0c             	pushl  0xc(%ebp)
f010391a:	ff 75 20             	pushl  0x20(%ebp)
f010391d:	ff 55 08             	call   *0x8(%ebp)
f0103920:	83 c4 10             	add    $0x10,%esp
f0103923:	4b                   	dec    %ebx
f0103924:	85 db                	test   %ebx,%ebx
f0103926:	7f ec                	jg     f0103914 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103928:	83 ec 08             	sub    $0x8,%esp
f010392b:	ff 75 0c             	pushl  0xc(%ebp)
f010392e:	8b 45 18             	mov    0x18(%ebp),%eax
f0103931:	ba 00 00 00 00       	mov    $0x0,%edx
f0103936:	83 ec 04             	sub    $0x4,%esp
f0103939:	52                   	push   %edx
f010393a:	50                   	push   %eax
f010393b:	57                   	push   %edi
f010393c:	56                   	push   %esi
f010393d:	e8 0e 0b 00 00       	call   f0104450 <__umoddi3>
f0103942:	83 c4 14             	add    $0x14,%esp
f0103945:	0f be 80 a7 5e 10 f0 	movsbl 0xf0105ea7(%eax),%eax
f010394c:	50                   	push   %eax
f010394d:	ff 55 08             	call   *0x8(%ebp)
}
f0103950:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103953:	5b                   	pop    %ebx
f0103954:	5e                   	pop    %esi
f0103955:	5f                   	pop    %edi
f0103956:	5d                   	pop    %ebp
f0103957:	c3                   	ret    

f0103958 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103958:	55                   	push   %ebp
f0103959:	89 e5                	mov    %esp,%ebp
f010395b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010395e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0103961:	83 f8 01             	cmp    $0x1,%eax
f0103964:	7e 0f                	jle    f0103975 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f0103966:	8b 01                	mov    (%ecx),%eax
f0103968:	83 c0 08             	add    $0x8,%eax
f010396b:	89 01                	mov    %eax,(%ecx)
f010396d:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f0103970:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f0103973:	eb 0f                	jmp    f0103984 <getuint+0x2c>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103975:	8b 01                	mov    (%ecx),%eax
f0103977:	83 c0 04             	add    $0x4,%eax
f010397a:	89 01                	mov    %eax,(%ecx)
f010397c:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f010397f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103984:	5d                   	pop    %ebp
f0103985:	c3                   	ret    

f0103986 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103986:	55                   	push   %ebp
f0103987:	89 e5                	mov    %esp,%ebp
f0103989:	8b 55 08             	mov    0x8(%ebp),%edx
f010398c:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f010398f:	83 f8 01             	cmp    $0x1,%eax
f0103992:	7e 0f                	jle    f01039a3 <getint+0x1d>
		return va_arg(*ap, long long);
f0103994:	8b 02                	mov    (%edx),%eax
f0103996:	83 c0 08             	add    $0x8,%eax
f0103999:	89 02                	mov    %eax,(%edx)
f010399b:	8b 50 fc             	mov    0xfffffffc(%eax),%edx
f010399e:	8b 40 f8             	mov    0xfffffff8(%eax),%eax
f01039a1:	eb 0f                	jmp    f01039b2 <getint+0x2c>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f01039a3:	8b 02                	mov    (%edx),%eax
f01039a5:	83 c0 04             	add    $0x4,%eax
f01039a8:	89 02                	mov    %eax,(%edx)
f01039aa:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
f01039ad:	89 c2                	mov    %eax,%edx
f01039af:	c1 fa 1f             	sar    $0x1f,%edx
}
f01039b2:	5d                   	pop    %ebp
f01039b3:	c3                   	ret    

f01039b4 <vprintfmt>:


// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01039b4:	55                   	push   %ebp
f01039b5:	89 e5                	mov    %esp,%ebp
f01039b7:	57                   	push   %edi
f01039b8:	56                   	push   %esi
f01039b9:	53                   	push   %ebx
f01039ba:	83 ec 1c             	sub    $0x1c,%esp
f01039bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01039c5:	8a 13                	mov    (%ebx),%dl
f01039c7:	43                   	inc    %ebx
f01039c8:	83 fa 25             	cmp    $0x25,%edx
f01039cb:	74 22                	je     f01039ef <vprintfmt+0x3b>
			if (ch == '\0')
f01039cd:	85 d2                	test   %edx,%edx
f01039cf:	0f 84 cd 02 00 00    	je     f0103ca2 <vprintfmt+0x2ee>
				return;
			putch(ch, putdat);
f01039d5:	83 ec 08             	sub    $0x8,%esp
f01039d8:	ff 75 0c             	pushl  0xc(%ebp)
f01039db:	52                   	push   %edx
f01039dc:	ff 55 08             	call   *0x8(%ebp)
f01039df:	83 c4 10             	add    $0x10,%esp
f01039e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01039e7:	8a 13                	mov    (%ebx),%dl
f01039e9:	43                   	inc    %ebx
f01039ea:	83 fa 25             	cmp    $0x25,%edx
f01039ed:	75 de                	jne    f01039cd <vprintfmt+0x19>
		}

		// Process a %-escape sequence
		padc = ' ';
f01039ef:	c6 45 eb 20          	movb   $0x20,0xffffffeb(%ebp)
		width = -1;
f01039f3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,0xfffffff0(%ebp)
		precision = -1;
f01039fa:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
f01039ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		altflag = 0;
f0103a04:	c7 45 ec 00 00 00 00 	movl   $0x0,0xffffffec(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a10:	8a 13                	mov    (%ebx),%dl
f0103a12:	8d 42 dd             	lea    0xffffffdd(%edx),%eax
f0103a15:	43                   	inc    %ebx
f0103a16:	83 f8 55             	cmp    $0x55,%eax
f0103a19:	0f 87 5e 02 00 00    	ja     f0103c7d <vprintfmt+0x2c9>
f0103a1f:	ff 24 85 00 5f 10 f0 	jmp    *0xf0105f00(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
f0103a26:	c6 45 eb 2d          	movb   $0x2d,0xffffffeb(%ebp)
			goto reswitch;
f0103a2a:	eb df                	jmp    f0103a0b <vprintfmt+0x57>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103a2c:	c6 45 eb 30          	movb   $0x30,0xffffffeb(%ebp)
			goto reswitch;
f0103a30:	eb d9                	jmp    f0103a0b <vprintfmt+0x57>

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
f0103a32:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
f0103a37:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0103a3a:	8d 74 42 d0          	lea    0xffffffd0(%edx,%eax,2),%esi
				ch = *fmt;
f0103a3e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103a41:	8d 42 d0             	lea    0xffffffd0(%edx),%eax
f0103a44:	83 f8 09             	cmp    $0x9,%eax
f0103a47:	77 27                	ja     f0103a70 <vprintfmt+0xbc>
f0103a49:	43                   	inc    %ebx
f0103a4a:	eb eb                	jmp    f0103a37 <vprintfmt+0x83>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103a4c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103a50:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a53:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
			goto process_precision;
f0103a56:	eb 18                	jmp    f0103a70 <vprintfmt+0xbc>

		case '.':
			if (width < 0)
f0103a58:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103a5c:	79 ad                	jns    f0103a0b <vprintfmt+0x57>
				width = 0;
f0103a5e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
			goto reswitch;
f0103a65:	eb a4                	jmp    f0103a0b <vprintfmt+0x57>

		case '#':
			altflag = 1;
f0103a67:	c7 45 ec 01 00 00 00 	movl   $0x1,0xffffffec(%ebp)
			goto reswitch;
f0103a6e:	eb 9b                	jmp    f0103a0b <vprintfmt+0x57>

		process_precision:
			if (width < 0)
f0103a70:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103a74:	79 95                	jns    f0103a0b <vprintfmt+0x57>
				width = precision, precision = -1;
f0103a76:	89 75 f0             	mov    %esi,0xfffffff0(%ebp)
f0103a79:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
f0103a7e:	eb 8b                	jmp    f0103a0b <vprintfmt+0x57>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103a80:	41                   	inc    %ecx
			goto reswitch;
f0103a81:	eb 88                	jmp    f0103a0b <vprintfmt+0x57>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103a83:	83 ec 08             	sub    $0x8,%esp
f0103a86:	ff 75 0c             	pushl  0xc(%ebp)
f0103a89:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103a8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a90:	ff 70 fc             	pushl  0xfffffffc(%eax)
f0103a93:	e9 da 01 00 00       	jmp    f0103c72 <vprintfmt+0x2be>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103a98:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103a9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a9f:	8b 40 fc             	mov    0xfffffffc(%eax),%eax
			if (err < 0)
f0103aa2:	85 c0                	test   %eax,%eax
f0103aa4:	79 02                	jns    f0103aa8 <vprintfmt+0xf4>
				err = -err;
f0103aa6:	f7 d8                	neg    %eax
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103aa8:	83 f8 07             	cmp    $0x7,%eax
f0103aab:	7f 0b                	jg     f0103ab8 <vprintfmt+0x104>
f0103aad:	8b 3c 85 e0 5e 10 f0 	mov    0xf0105ee0(,%eax,4),%edi
f0103ab4:	85 ff                	test   %edi,%edi
f0103ab6:	75 08                	jne    f0103ac0 <vprintfmt+0x10c>
				printfmt(putch, putdat, "error %d", err);
f0103ab8:	50                   	push   %eax
f0103ab9:	68 b8 5e 10 f0       	push   $0xf0105eb8
f0103abe:	eb 06                	jmp    f0103ac6 <vprintfmt+0x112>
			else
				printfmt(putch, putdat, "%s", p);
f0103ac0:	57                   	push   %edi
f0103ac1:	68 b4 55 10 f0       	push   $0xf01055b4
f0103ac6:	ff 75 0c             	pushl  0xc(%ebp)
f0103ac9:	ff 75 08             	pushl  0x8(%ebp)
f0103acc:	e8 d9 01 00 00       	call   f0103caa <printfmt>
f0103ad1:	e9 9f 01 00 00       	jmp    f0103c75 <vprintfmt+0x2c1>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103ad6:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103ada:	8b 45 14             	mov    0x14(%ebp),%eax
f0103add:	8b 78 fc             	mov    0xfffffffc(%eax),%edi
f0103ae0:	85 ff                	test   %edi,%edi
f0103ae2:	75 05                	jne    f0103ae9 <vprintfmt+0x135>
				p = "(null)";
f0103ae4:	bf c1 5e 10 f0       	mov    $0xf0105ec1,%edi
			if (width > 0 && padc != '-')
f0103ae9:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103aed:	0f 9f c2             	setg   %dl
f0103af0:	80 7d eb 2d          	cmpb   $0x2d,0xffffffeb(%ebp)
f0103af4:	0f 95 c0             	setne  %al
f0103af7:	21 d0                	and    %edx,%eax
f0103af9:	a8 01                	test   $0x1,%al
f0103afb:	74 35                	je     f0103b32 <vprintfmt+0x17e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103afd:	83 ec 08             	sub    $0x8,%esp
f0103b00:	56                   	push   %esi
f0103b01:	57                   	push   %edi
f0103b02:	e8 42 03 00 00       	call   f0103e49 <strnlen>
f0103b07:	29 45 f0             	sub    %eax,0xfffffff0(%ebp)
f0103b0a:	83 c4 10             	add    $0x10,%esp
f0103b0d:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103b11:	7e 1f                	jle    f0103b32 <vprintfmt+0x17e>
f0103b13:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f0103b17:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
					putch(padc, putdat);
f0103b1a:	83 ec 08             	sub    $0x8,%esp
f0103b1d:	ff 75 0c             	pushl  0xc(%ebp)
f0103b20:	ff 75 e4             	pushl  0xffffffe4(%ebp)
f0103b23:	ff 55 08             	call   *0x8(%ebp)
f0103b26:	83 c4 10             	add    $0x10,%esp
f0103b29:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0103b2c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103b30:	7f e8                	jg     f0103b1a <vprintfmt+0x166>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b32:	0f be 17             	movsbl (%edi),%edx
f0103b35:	47                   	inc    %edi
f0103b36:	85 d2                	test   %edx,%edx
f0103b38:	74 3e                	je     f0103b78 <vprintfmt+0x1c4>
f0103b3a:	85 f6                	test   %esi,%esi
f0103b3c:	78 03                	js     f0103b41 <vprintfmt+0x18d>
f0103b3e:	4e                   	dec    %esi
f0103b3f:	78 37                	js     f0103b78 <vprintfmt+0x1c4>
				if (altflag && (ch < ' ' || ch > '~'))
f0103b41:	83 7d ec 00          	cmpl   $0x0,0xffffffec(%ebp)
f0103b45:	74 12                	je     f0103b59 <vprintfmt+0x1a5>
f0103b47:	8d 42 e0             	lea    0xffffffe0(%edx),%eax
f0103b4a:	83 f8 5e             	cmp    $0x5e,%eax
f0103b4d:	76 0a                	jbe    f0103b59 <vprintfmt+0x1a5>
					putch('?', putdat);
f0103b4f:	83 ec 08             	sub    $0x8,%esp
f0103b52:	ff 75 0c             	pushl  0xc(%ebp)
f0103b55:	6a 3f                	push   $0x3f
f0103b57:	eb 07                	jmp    f0103b60 <vprintfmt+0x1ac>
				else
					putch(ch, putdat);
f0103b59:	83 ec 08             	sub    $0x8,%esp
f0103b5c:	ff 75 0c             	pushl  0xc(%ebp)
f0103b5f:	52                   	push   %edx
f0103b60:	ff 55 08             	call   *0x8(%ebp)
f0103b63:	83 c4 10             	add    $0x10,%esp
f0103b66:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0103b69:	0f be 17             	movsbl (%edi),%edx
f0103b6c:	47                   	inc    %edi
f0103b6d:	85 d2                	test   %edx,%edx
f0103b6f:	74 07                	je     f0103b78 <vprintfmt+0x1c4>
f0103b71:	85 f6                	test   %esi,%esi
f0103b73:	78 cc                	js     f0103b41 <vprintfmt+0x18d>
f0103b75:	4e                   	dec    %esi
f0103b76:	79 c9                	jns    f0103b41 <vprintfmt+0x18d>
			for (; width > 0; width--)
f0103b78:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103b7c:	0f 8e 3e fe ff ff    	jle    f01039c0 <vprintfmt+0xc>
				putch(' ', putdat);
f0103b82:	83 ec 08             	sub    $0x8,%esp
f0103b85:	ff 75 0c             	pushl  0xc(%ebp)
f0103b88:	6a 20                	push   $0x20
f0103b8a:	ff 55 08             	call   *0x8(%ebp)
f0103b8d:	83 c4 10             	add    $0x10,%esp
f0103b90:	ff 4d f0             	decl   0xfffffff0(%ebp)
f0103b93:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0103b97:	7f e9                	jg     f0103b82 <vprintfmt+0x1ce>
			break;
f0103b99:	e9 22 fe ff ff       	jmp    f01039c0 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103b9e:	83 ec 08             	sub    $0x8,%esp
f0103ba1:	51                   	push   %ecx
f0103ba2:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ba5:	50                   	push   %eax
f0103ba6:	e8 db fd ff ff       	call   f0103986 <getint>
f0103bab:	89 c6                	mov    %eax,%esi
f0103bad:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f0103baf:	83 c4 10             	add    $0x10,%esp
f0103bb2:	85 d2                	test   %edx,%edx
f0103bb4:	79 15                	jns    f0103bcb <vprintfmt+0x217>
				putch('-', putdat);
f0103bb6:	83 ec 08             	sub    $0x8,%esp
f0103bb9:	ff 75 0c             	pushl  0xc(%ebp)
f0103bbc:	6a 2d                	push   $0x2d
f0103bbe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103bc1:	f7 de                	neg    %esi
f0103bc3:	83 d7 00             	adc    $0x0,%edi
f0103bc6:	f7 df                	neg    %edi
f0103bc8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103bcb:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f0103bd0:	eb 78                	jmp    f0103c4a <vprintfmt+0x296>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103bd2:	83 ec 08             	sub    $0x8,%esp
f0103bd5:	51                   	push   %ecx
f0103bd6:	8d 45 14             	lea    0x14(%ebp),%eax
f0103bd9:	50                   	push   %eax
f0103bda:	e8 79 fd ff ff       	call   f0103958 <getuint>
f0103bdf:	89 c6                	mov    %eax,%esi
f0103be1:	89 d7                	mov    %edx,%edi
			base = 10;
f0103be3:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f0103be8:	eb 5d                	jmp    f0103c47 <vprintfmt+0x293>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0103bea:	83 ec 08             	sub    $0x8,%esp
f0103bed:	ff 75 0c             	pushl  0xc(%ebp)
f0103bf0:	6a 58                	push   $0x58
f0103bf2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0103bf5:	83 c4 08             	add    $0x8,%esp
f0103bf8:	ff 75 0c             	pushl  0xc(%ebp)
f0103bfb:	6a 58                	push   $0x58
f0103bfd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0103c00:	83 c4 08             	add    $0x8,%esp
f0103c03:	ff 75 0c             	pushl  0xc(%ebp)
f0103c06:	6a 58                	push   $0x58
f0103c08:	eb 68                	jmp    f0103c72 <vprintfmt+0x2be>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103c0a:	83 ec 08             	sub    $0x8,%esp
f0103c0d:	ff 75 0c             	pushl  0xc(%ebp)
f0103c10:	6a 30                	push   $0x30
f0103c12:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103c15:	83 c4 08             	add    $0x8,%esp
f0103c18:	ff 75 0c             	pushl  0xc(%ebp)
f0103c1b:	6a 78                	push   $0x78
f0103c1d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0103c20:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103c24:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c27:	8b 70 fc             	mov    0xfffffffc(%eax),%esi
f0103c2a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uint32) va_arg(ap, void *);
			base = 16;
f0103c2f:	eb 11                	jmp    f0103c42 <vprintfmt+0x28e>
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103c31:	83 ec 08             	sub    $0x8,%esp
f0103c34:	51                   	push   %ecx
f0103c35:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c38:	50                   	push   %eax
f0103c39:	e8 1a fd ff ff       	call   f0103958 <getuint>
f0103c3e:	89 c6                	mov    %eax,%esi
f0103c40:	89 d7                	mov    %edx,%edi
			base = 16;
f0103c42:	ba 10 00 00 00       	mov    $0x10,%edx
f0103c47:	83 c4 10             	add    $0x10,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103c4a:	83 ec 04             	sub    $0x4,%esp
f0103c4d:	0f be 45 eb          	movsbl 0xffffffeb(%ebp),%eax
f0103c51:	50                   	push   %eax
f0103c52:	ff 75 f0             	pushl  0xfffffff0(%ebp)
f0103c55:	52                   	push   %edx
f0103c56:	57                   	push   %edi
f0103c57:	56                   	push   %esi
f0103c58:	ff 75 0c             	pushl  0xc(%ebp)
f0103c5b:	ff 75 08             	pushl  0x8(%ebp)
f0103c5e:	e8 55 fc ff ff       	call   f01038b8 <printnum>
			break;
f0103c63:	83 c4 20             	add    $0x20,%esp
f0103c66:	e9 55 fd ff ff       	jmp    f01039c0 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103c6b:	83 ec 08             	sub    $0x8,%esp
f0103c6e:	ff 75 0c             	pushl  0xc(%ebp)
f0103c71:	52                   	push   %edx
f0103c72:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103c75:	83 c4 10             	add    $0x10,%esp
f0103c78:	e9 43 fd ff ff       	jmp    f01039c0 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103c7d:	83 ec 08             	sub    $0x8,%esp
f0103c80:	ff 75 0c             	pushl  0xc(%ebp)
f0103c83:	6a 25                	push   $0x25
f0103c85:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103c88:	4b                   	dec    %ebx
f0103c89:	83 c4 10             	add    $0x10,%esp
f0103c8c:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f0103c90:	0f 84 2a fd ff ff    	je     f01039c0 <vprintfmt+0xc>
f0103c96:	4b                   	dec    %ebx
f0103c97:	80 7b ff 25          	cmpb   $0x25,0xffffffff(%ebx)
f0103c9b:	75 f9                	jne    f0103c96 <vprintfmt+0x2e2>
				/* do nothing */;
			break;
f0103c9d:	e9 1e fd ff ff       	jmp    f01039c0 <vprintfmt+0xc>
		}
	}
}
f0103ca2:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103ca5:	5b                   	pop    %ebx
f0103ca6:	5e                   	pop    %esi
f0103ca7:	5f                   	pop    %edi
f0103ca8:	5d                   	pop    %ebp
f0103ca9:	c3                   	ret    

f0103caa <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103caa:	55                   	push   %ebp
f0103cab:	89 e5                	mov    %esp,%ebp
f0103cad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103cb0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103cb3:	50                   	push   %eax
f0103cb4:	ff 75 10             	pushl  0x10(%ebp)
f0103cb7:	ff 75 0c             	pushl  0xc(%ebp)
f0103cba:	ff 75 08             	pushl  0x8(%ebp)
f0103cbd:	e8 f2 fc ff ff       	call   f01039b4 <vprintfmt>
	va_end(ap);
}
f0103cc2:	c9                   	leave  
f0103cc3:	c3                   	ret    

f0103cc4 <sprintputch>:

struct sprintbuf {
	char *buf;
	char *ebuf;
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103cc4:	55                   	push   %ebp
f0103cc5:	89 e5                	mov    %esp,%ebp
f0103cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0103cca:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
f0103ccd:	8b 0a                	mov    (%edx),%ecx
f0103ccf:	3b 4a 04             	cmp    0x4(%edx),%ecx
f0103cd2:	73 07                	jae    f0103cdb <sprintputch+0x17>
		*b->buf++ = ch;
f0103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd7:	88 01                	mov    %al,(%ecx)
f0103cd9:	ff 02                	incl   (%edx)
}
f0103cdb:	5d                   	pop    %ebp
f0103cdc:	c3                   	ret    

f0103cdd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103cdd:	55                   	push   %ebp
f0103cde:	89 e5                	mov    %esp,%ebp
f0103ce0:	83 ec 18             	sub    $0x18,%esp
f0103ce3:	8b 55 08             	mov    0x8(%ebp),%edx
f0103ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103ce9:	89 55 e8             	mov    %edx,0xffffffe8(%ebp)
f0103cec:	8d 44 11 ff          	lea    0xffffffff(%ecx,%edx,1),%eax
f0103cf0:	89 45 ec             	mov    %eax,0xffffffec(%ebp)
f0103cf3:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)

	if (buf == NULL || n < 1)
f0103cfa:	85 d2                	test   %edx,%edx
f0103cfc:	0f 94 c2             	sete   %dl
f0103cff:	85 c9                	test   %ecx,%ecx
f0103d01:	0f 9e c0             	setle  %al
f0103d04:	09 d0                	or     %edx,%eax
f0103d06:	ba 03 00 00 00       	mov    $0x3,%edx
f0103d0b:	a8 01                	test   $0x1,%al
f0103d0d:	75 1d                	jne    f0103d2c <vsnprintf+0x4f>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103d0f:	ff 75 14             	pushl  0x14(%ebp)
f0103d12:	ff 75 10             	pushl  0x10(%ebp)
f0103d15:	8d 45 e8             	lea    0xffffffe8(%ebp),%eax
f0103d18:	50                   	push   %eax
f0103d19:	68 c4 3c 10 f0       	push   $0xf0103cc4
f0103d1e:	e8 91 fc ff ff       	call   f01039b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103d23:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f0103d26:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103d29:	8b 55 f0             	mov    0xfffffff0(%ebp),%edx
}
f0103d2c:	89 d0                	mov    %edx,%eax
f0103d2e:	c9                   	leave  
f0103d2f:	c3                   	ret    

f0103d30 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103d30:	55                   	push   %ebp
f0103d31:	89 e5                	mov    %esp,%ebp
f0103d33:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103d36:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103d39:	50                   	push   %eax
f0103d3a:	ff 75 10             	pushl  0x10(%ebp)
f0103d3d:	ff 75 0c             	pushl  0xc(%ebp)
f0103d40:	ff 75 08             	pushl  0x8(%ebp)
f0103d43:	e8 95 ff ff ff       	call   f0103cdd <vsnprintf>
	va_end(ap);

	return rc;
}
f0103d48:	c9                   	leave  
f0103d49:	c3                   	ret    
	...

f0103d4c <readline>:
#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
f0103d4c:	55                   	push   %ebp
f0103d4d:	89 e5                	mov    %esp,%ebp
f0103d4f:	57                   	push   %edi
f0103d50:	56                   	push   %esi
f0103d51:	53                   	push   %ebx
f0103d52:	83 ec 0c             	sub    $0xc,%esp
f0103d55:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;
	
	if (prompt != NULL)
f0103d58:	85 c0                	test   %eax,%eax
f0103d5a:	74 11                	je     f0103d6d <readline+0x21>
		cprintf("%s", prompt);
f0103d5c:	83 ec 08             	sub    $0x8,%esp
f0103d5f:	50                   	push   %eax
f0103d60:	68 b4 55 10 f0       	push   $0xf01055b4
f0103d65:	e8 94 f1 ff ff       	call   f0102efe <cprintf>
f0103d6a:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
f0103d6d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);	
f0103d72:	83 ec 0c             	sub    $0xc,%esp
f0103d75:	6a 00                	push   $0x0
f0103d77:	e8 0c c9 ff ff       	call   f0100688 <iscons>
f0103d7c:	89 c7                	mov    %eax,%edi
	while (1) {
f0103d7e:	83 c4 10             	add    $0x10,%esp
		c = getchar();
f0103d81:	e8 f1 c8 ff ff       	call   f0100677 <getchar>
f0103d86:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103d88:	85 c0                	test   %eax,%eax
f0103d8a:	79 1c                	jns    f0103da8 <readline+0x5c>
			if (c != -E_EOF)
f0103d8c:	83 f8 07             	cmp    $0x7,%eax
f0103d8f:	0f 84 92 00 00 00    	je     f0103e27 <readline+0xdb>
				cprintf("read error: %e\n", c);			
f0103d95:	83 ec 08             	sub    $0x8,%esp
f0103d98:	50                   	push   %eax
f0103d99:	68 58 60 10 f0       	push   $0xf0106058
f0103d9e:	e8 5b f1 ff ff       	call   f0102efe <cprintf>
f0103da3:	83 c4 10             	add    $0x10,%esp
			return;
f0103da6:	eb 7f                	jmp    f0103e27 <readline+0xdb>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103da8:	83 f8 1f             	cmp    $0x1f,%eax
f0103dab:	0f 9f c2             	setg   %dl
f0103dae:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103db4:	0f 9e c0             	setle  %al
f0103db7:	21 d0                	and    %edx,%eax
f0103db9:	a8 01                	test   $0x1,%al
f0103dbb:	74 19                	je     f0103dd6 <readline+0x8a>
			if (echoing)
f0103dbd:	85 ff                	test   %edi,%edi
f0103dbf:	74 0c                	je     f0103dcd <readline+0x81>
				cputchar(c);
f0103dc1:	83 ec 0c             	sub    $0xc,%esp
f0103dc4:	53                   	push   %ebx
f0103dc5:	e8 9d c8 ff ff       	call   f0100667 <cputchar>
f0103dca:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103dd0:	88 1c 06             	mov    %bl,(%esi,%eax,1)
f0103dd3:	46                   	inc    %esi
f0103dd4:	eb ab                	jmp    f0103d81 <readline+0x35>
		} else if (c == '\b' && i > 0) {
f0103dd6:	83 fb 08             	cmp    $0x8,%ebx
f0103dd9:	0f 94 c2             	sete   %dl
f0103ddc:	85 f6                	test   %esi,%esi
f0103dde:	0f 9f c0             	setg   %al
f0103de1:	21 d0                	and    %edx,%eax
f0103de3:	a8 01                	test   $0x1,%al
f0103de5:	74 13                	je     f0103dfa <readline+0xae>
			if (echoing)
f0103de7:	85 ff                	test   %edi,%edi
f0103de9:	74 0c                	je     f0103df7 <readline+0xab>
				cputchar(c);
f0103deb:	83 ec 0c             	sub    $0xc,%esp
f0103dee:	53                   	push   %ebx
f0103def:	e8 73 c8 ff ff       	call   f0100667 <cputchar>
f0103df4:	83 c4 10             	add    $0x10,%esp
			i--;
f0103df7:	4e                   	dec    %esi
f0103df8:	eb 87                	jmp    f0103d81 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103dfa:	83 fb 0a             	cmp    $0xa,%ebx
f0103dfd:	0f 94 c2             	sete   %dl
f0103e00:	83 fb 0d             	cmp    $0xd,%ebx
f0103e03:	0f 94 c0             	sete   %al
f0103e06:	09 d0                	or     %edx,%eax
f0103e08:	a8 01                	test   $0x1,%al
f0103e0a:	0f 84 71 ff ff ff    	je     f0103d81 <readline+0x35>
			if (echoing)
f0103e10:	85 ff                	test   %edi,%edi
f0103e12:	74 0c                	je     f0103e20 <readline+0xd4>
				cputchar(c);
f0103e14:	83 ec 0c             	sub    $0xc,%esp
f0103e17:	53                   	push   %ebx
f0103e18:	e8 4a c8 ff ff       	call   f0100667 <cputchar>
f0103e1d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
f0103e20:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e23:	c6 04 16 00          	movb   $0x0,(%esi,%edx,1)
			return;		
		}
	}
}
f0103e27:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0103e2a:	5b                   	pop    %ebx
f0103e2b:	5e                   	pop    %esi
f0103e2c:	5f                   	pop    %edi
f0103e2d:	5d                   	pop    %ebp
f0103e2e:	c3                   	ret    
	...

f0103e30 <strlen>:
#include <inc/string.h>

int
strlen(const char *s)
{
f0103e30:	55                   	push   %ebp
f0103e31:	89 e5                	mov    %esp,%ebp
f0103e33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e36:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e3b:	80 3a 00             	cmpb   $0x0,(%edx)
f0103e3e:	74 07                	je     f0103e47 <strlen+0x17>
		n++;
f0103e40:	40                   	inc    %eax
f0103e41:	42                   	inc    %edx
f0103e42:	80 3a 00             	cmpb   $0x0,(%edx)
f0103e45:	75 f9                	jne    f0103e40 <strlen+0x10>
	return n;
}
f0103e47:	5d                   	pop    %ebp
f0103e48:	c3                   	ret    

f0103e49 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
f0103e49:	55                   	push   %ebp
f0103e4a:	89 e5                	mov    %esp,%ebp
f0103e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e57:	85 d2                	test   %edx,%edx
f0103e59:	74 0f                	je     f0103e6a <strnlen+0x21>
f0103e5b:	80 39 00             	cmpb   $0x0,(%ecx)
f0103e5e:	74 0a                	je     f0103e6a <strnlen+0x21>
		n++;
f0103e60:	40                   	inc    %eax
f0103e61:	41                   	inc    %ecx
f0103e62:	4a                   	dec    %edx
f0103e63:	74 05                	je     f0103e6a <strnlen+0x21>
f0103e65:	80 39 00             	cmpb   $0x0,(%ecx)
f0103e68:	75 f6                	jne    f0103e60 <strnlen+0x17>
	return n;
}
f0103e6a:	5d                   	pop    %ebp
f0103e6b:	c3                   	ret    

f0103e6c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103e6c:	55                   	push   %ebp
f0103e6d:	89 e5                	mov    %esp,%ebp
f0103e6f:	53                   	push   %ebx
f0103e70:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e73:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
f0103e76:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
f0103e78:	8a 02                	mov    (%edx),%al
f0103e7a:	88 01                	mov    %al,(%ecx)
f0103e7c:	42                   	inc    %edx
f0103e7d:	41                   	inc    %ecx
f0103e7e:	84 c0                	test   %al,%al
f0103e80:	75 f6                	jne    f0103e78 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103e82:	89 d8                	mov    %ebx,%eax
f0103e84:	5b                   	pop    %ebx
f0103e85:	5d                   	pop    %ebp
f0103e86:	c3                   	ret    

f0103e87 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
f0103e87:	55                   	push   %ebp
f0103e88:	89 e5                	mov    %esp,%ebp
f0103e8a:	57                   	push   %edi
f0103e8b:	56                   	push   %esi
f0103e8c:	53                   	push   %ebx
f0103e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e90:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e93:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32 i;
	char *ret;

	ret = dst;
f0103e96:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
f0103e98:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103e9d:	39 f3                	cmp    %esi,%ebx
f0103e9f:	73 17                	jae    f0103eb8 <strncpy+0x31>
		*dst++ = *src;
f0103ea1:	8a 02                	mov    (%edx),%al
f0103ea3:	88 01                	mov    %al,(%ecx)
f0103ea5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0103ea6:	80 3a 00             	cmpb   $0x0,(%edx)
f0103ea9:	0f 95 c0             	setne  %al
f0103eac:	25 ff 00 00 00       	and    $0xff,%eax
f0103eb1:	01 c2                	add    %eax,%edx
f0103eb3:	43                   	inc    %ebx
f0103eb4:	39 f3                	cmp    %esi,%ebx
f0103eb6:	72 e9                	jb     f0103ea1 <strncpy+0x1a>
			src++;
	}
	return ret;
}
f0103eb8:	89 f8                	mov    %edi,%eax
f0103eba:	5b                   	pop    %ebx
f0103ebb:	5e                   	pop    %esi
f0103ebc:	5f                   	pop    %edi
f0103ebd:	5d                   	pop    %ebp
f0103ebe:	c3                   	ret    

f0103ebf <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
f0103ebf:	55                   	push   %ebp
f0103ec0:	89 e5                	mov    %esp,%ebp
f0103ec2:	56                   	push   %esi
f0103ec3:	53                   	push   %ebx
f0103ec4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103eca:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
f0103ecd:	89 de                	mov    %ebx,%esi
	if (size > 0) {
f0103ecf:	85 d2                	test   %edx,%edx
f0103ed1:	74 19                	je     f0103eec <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
f0103ed3:	4a                   	dec    %edx
f0103ed4:	74 13                	je     f0103ee9 <strlcpy+0x2a>
f0103ed6:	80 39 00             	cmpb   $0x0,(%ecx)
f0103ed9:	74 0e                	je     f0103ee9 <strlcpy+0x2a>
			*dst++ = *src++;
f0103edb:	8a 01                	mov    (%ecx),%al
f0103edd:	88 03                	mov    %al,(%ebx)
f0103edf:	41                   	inc    %ecx
f0103ee0:	43                   	inc    %ebx
f0103ee1:	4a                   	dec    %edx
f0103ee2:	74 05                	je     f0103ee9 <strlcpy+0x2a>
f0103ee4:	80 39 00             	cmpb   $0x0,(%ecx)
f0103ee7:	75 f2                	jne    f0103edb <strlcpy+0x1c>
		*dst = '\0';
f0103ee9:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
f0103eec:	89 d8                	mov    %ebx,%eax
f0103eee:	29 f0                	sub    %esi,%eax
}
f0103ef0:	5b                   	pop    %ebx
f0103ef1:	5e                   	pop    %esi
f0103ef2:	5d                   	pop    %ebp
f0103ef3:	c3                   	ret    

f0103ef4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103ef4:	55                   	push   %ebp
f0103ef5:	89 e5                	mov    %esp,%ebp
f0103ef7:	8b 55 08             	mov    0x8(%ebp),%edx
f0103efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f0103efd:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f00:	74 13                	je     f0103f15 <strcmp+0x21>
f0103f02:	8a 02                	mov    (%edx),%al
f0103f04:	3a 01                	cmp    (%ecx),%al
f0103f06:	75 0d                	jne    f0103f15 <strcmp+0x21>
		p++, q++;
f0103f08:	42                   	inc    %edx
f0103f09:	41                   	inc    %ecx
f0103f0a:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f0d:	74 06                	je     f0103f15 <strcmp+0x21>
f0103f0f:	8a 02                	mov    (%edx),%al
f0103f11:	3a 01                	cmp    (%ecx),%al
f0103f13:	74 f3                	je     f0103f08 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f15:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f1a:	8a 02                	mov    (%edx),%al
f0103f1c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f21:	8a 11                	mov    (%ecx),%dl
f0103f23:	29 d0                	sub    %edx,%eax
}
f0103f25:	5d                   	pop    %ebp
f0103f26:	c3                   	ret    

f0103f27 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
f0103f27:	55                   	push   %ebp
f0103f28:	89 e5                	mov    %esp,%ebp
f0103f2a:	53                   	push   %ebx
f0103f2b:	8b 55 08             	mov    0x8(%ebp),%edx
f0103f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103f31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
f0103f34:	85 c9                	test   %ecx,%ecx
f0103f36:	74 1f                	je     f0103f57 <strncmp+0x30>
f0103f38:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f3b:	74 16                	je     f0103f53 <strncmp+0x2c>
f0103f3d:	8a 02                	mov    (%edx),%al
f0103f3f:	3a 03                	cmp    (%ebx),%al
f0103f41:	75 10                	jne    f0103f53 <strncmp+0x2c>
		n--, p++, q++;
f0103f43:	42                   	inc    %edx
f0103f44:	43                   	inc    %ebx
f0103f45:	49                   	dec    %ecx
f0103f46:	74 0f                	je     f0103f57 <strncmp+0x30>
f0103f48:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f4b:	74 06                	je     f0103f53 <strncmp+0x2c>
f0103f4d:	8a 02                	mov    (%edx),%al
f0103f4f:	3a 03                	cmp    (%ebx),%al
f0103f51:	74 f0                	je     f0103f43 <strncmp+0x1c>
	if (n == 0)
f0103f53:	85 c9                	test   %ecx,%ecx
f0103f55:	75 07                	jne    f0103f5e <strncmp+0x37>
		return 0;
f0103f57:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f5c:	eb 13                	jmp    f0103f71 <strncmp+0x4a>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f5e:	8a 12                	mov    (%edx),%dl
f0103f60:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0103f66:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f6b:	8a 03                	mov    (%ebx),%al
f0103f6d:	29 c2                	sub    %eax,%edx
f0103f6f:	89 d0                	mov    %edx,%eax
}
f0103f71:	5b                   	pop    %ebx
f0103f72:	5d                   	pop    %ebp
f0103f73:	c3                   	ret    

f0103f74 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103f74:	55                   	push   %ebp
f0103f75:	89 e5                	mov    %esp,%ebp
f0103f77:	8b 55 08             	mov    0x8(%ebp),%edx
f0103f7a:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103f7d:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f80:	74 0c                	je     f0103f8e <strchr+0x1a>
		if (*s == c)
f0103f82:	89 d0                	mov    %edx,%eax
f0103f84:	38 0a                	cmp    %cl,(%edx)
f0103f86:	74 0b                	je     f0103f93 <strchr+0x1f>
f0103f88:	42                   	inc    %edx
f0103f89:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f8c:	75 f4                	jne    f0103f82 <strchr+0xe>
			return (char *) s;
	return 0;
f0103f8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f93:	5d                   	pop    %ebp
f0103f94:	c3                   	ret    

f0103f95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103f95:	55                   	push   %ebp
f0103f96:	89 e5                	mov    %esp,%ebp
f0103f98:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9b:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f0103f9e:	80 38 00             	cmpb   $0x0,(%eax)
f0103fa1:	74 0a                	je     f0103fad <strfind+0x18>
		if (*s == c)
f0103fa3:	38 10                	cmp    %dl,(%eax)
f0103fa5:	74 06                	je     f0103fad <strfind+0x18>
f0103fa7:	40                   	inc    %eax
f0103fa8:	80 38 00             	cmpb   $0x0,(%eax)
f0103fab:	75 f6                	jne    f0103fa3 <strfind+0xe>
			break;
	return (char *) s;
}
f0103fad:	5d                   	pop    %ebp
f0103fae:	c3                   	ret    

f0103faf <memset>:


void *
memset(void *v, int c, uint32 n)
{
f0103faf:	55                   	push   %ebp
f0103fb0:	89 e5                	mov    %esp,%ebp
f0103fb2:	53                   	push   %ebx
f0103fb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
	char *p;
	int m;

	p = v;
f0103fb9:	89 d9                	mov    %ebx,%ecx
	m = n;
	while (--m >= 0)
f0103fbb:	8b 55 10             	mov    0x10(%ebp),%edx
f0103fbe:	4a                   	dec    %edx
f0103fbf:	78 06                	js     f0103fc7 <memset+0x18>
		*p++ = c;
f0103fc1:	88 01                	mov    %al,(%ecx)
f0103fc3:	41                   	inc    %ecx
f0103fc4:	4a                   	dec    %edx
f0103fc5:	79 fa                	jns    f0103fc1 <memset+0x12>

	return v;
}
f0103fc7:	89 d8                	mov    %ebx,%eax
f0103fc9:	5b                   	pop    %ebx
f0103fca:	5d                   	pop    %ebp
f0103fcb:	c3                   	ret    

f0103fcc <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
f0103fcc:	55                   	push   %ebp
f0103fcd:	89 e5                	mov    %esp,%ebp
f0103fcf:	56                   	push   %esi
f0103fd0:	53                   	push   %ebx
f0103fd1:	8b 75 08             	mov    0x8(%ebp),%esi
f0103fd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f0103fd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	d = dst;
f0103fda:	89 f2                	mov    %esi,%edx
	while (n-- > 0)
f0103fdc:	89 c8                	mov    %ecx,%eax
f0103fde:	49                   	dec    %ecx
f0103fdf:	85 c0                	test   %eax,%eax
f0103fe1:	74 0d                	je     f0103ff0 <memcpy+0x24>
		*d++ = *s++;
f0103fe3:	8a 03                	mov    (%ebx),%al
f0103fe5:	88 02                	mov    %al,(%edx)
f0103fe7:	43                   	inc    %ebx
f0103fe8:	42                   	inc    %edx
f0103fe9:	89 c8                	mov    %ecx,%eax
f0103feb:	49                   	dec    %ecx
f0103fec:	85 c0                	test   %eax,%eax
f0103fee:	75 f3                	jne    f0103fe3 <memcpy+0x17>

	return dst;
}
f0103ff0:	89 f0                	mov    %esi,%eax
f0103ff2:	5b                   	pop    %ebx
f0103ff3:	5e                   	pop    %esi
f0103ff4:	5d                   	pop    %ebp
f0103ff5:	c3                   	ret    

f0103ff6 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
f0103ff6:	55                   	push   %ebp
f0103ff7:	89 e5                	mov    %esp,%ebp
f0103ff9:	56                   	push   %esi
f0103ffa:	53                   	push   %ebx
f0103ffb:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ffe:	8b 55 10             	mov    0x10(%ebp),%edx
	const char *s;
	char *d;
	
	s = src;
f0104001:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	d = dst;
f0104004:	89 f3                	mov    %esi,%ebx
	if (s < d && s + n > d) {
f0104006:	39 f1                	cmp    %esi,%ecx
f0104008:	73 22                	jae    f010402c <memmove+0x36>
f010400a:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010400d:	39 f0                	cmp    %esi,%eax
f010400f:	76 1b                	jbe    f010402c <memmove+0x36>
		s += n;
f0104011:	89 c1                	mov    %eax,%ecx
		d += n;
f0104013:	8d 1c 32             	lea    (%edx,%esi,1),%ebx
		while (n-- > 0)
f0104016:	89 d0                	mov    %edx,%eax
f0104018:	4a                   	dec    %edx
f0104019:	85 c0                	test   %eax,%eax
f010401b:	74 23                	je     f0104040 <memmove+0x4a>
			*--d = *--s;
f010401d:	4b                   	dec    %ebx
f010401e:	49                   	dec    %ecx
f010401f:	8a 01                	mov    (%ecx),%al
f0104021:	88 03                	mov    %al,(%ebx)
f0104023:	89 d0                	mov    %edx,%eax
f0104025:	4a                   	dec    %edx
f0104026:	85 c0                	test   %eax,%eax
f0104028:	75 f3                	jne    f010401d <memmove+0x27>
f010402a:	eb 14                	jmp    f0104040 <memmove+0x4a>
	} else
		while (n-- > 0)
f010402c:	89 d0                	mov    %edx,%eax
f010402e:	4a                   	dec    %edx
f010402f:	85 c0                	test   %eax,%eax
f0104031:	74 0d                	je     f0104040 <memmove+0x4a>
			*d++ = *s++;
f0104033:	8a 01                	mov    (%ecx),%al
f0104035:	88 03                	mov    %al,(%ebx)
f0104037:	41                   	inc    %ecx
f0104038:	43                   	inc    %ebx
f0104039:	89 d0                	mov    %edx,%eax
f010403b:	4a                   	dec    %edx
f010403c:	85 c0                	test   %eax,%eax
f010403e:	75 f3                	jne    f0104033 <memmove+0x3d>

	return dst;
}
f0104040:	89 f0                	mov    %esi,%eax
f0104042:	5b                   	pop    %ebx
f0104043:	5e                   	pop    %esi
f0104044:	5d                   	pop    %ebp
f0104045:	c3                   	ret    

f0104046 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
f0104046:	55                   	push   %ebp
f0104047:	89 e5                	mov    %esp,%ebp
f0104049:	53                   	push   %ebx
f010404a:	8b 55 10             	mov    0x10(%ebp),%edx
	const uint8 *s1 = (const uint8 *) v1;
f010404d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8 *s2 = (const uint8 *) v2;
f0104050:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
f0104053:	89 d0                	mov    %edx,%eax
f0104055:	4a                   	dec    %edx
f0104056:	85 c0                	test   %eax,%eax
f0104058:	74 23                	je     f010407d <memcmp+0x37>
		if (*s1 != *s2)
f010405a:	8a 01                	mov    (%ecx),%al
f010405c:	3a 03                	cmp    (%ebx),%al
f010405e:	74 14                	je     f0104074 <memcmp+0x2e>
			return (int) *s1 - (int) *s2;
f0104060:	ba 00 00 00 00       	mov    $0x0,%edx
f0104065:	8a 11                	mov    (%ecx),%dl
f0104067:	b8 00 00 00 00       	mov    $0x0,%eax
f010406c:	8a 03                	mov    (%ebx),%al
f010406e:	29 c2                	sub    %eax,%edx
f0104070:	89 d0                	mov    %edx,%eax
f0104072:	eb 0e                	jmp    f0104082 <memcmp+0x3c>
		s1++, s2++;
f0104074:	41                   	inc    %ecx
f0104075:	43                   	inc    %ebx
f0104076:	89 d0                	mov    %edx,%eax
f0104078:	4a                   	dec    %edx
f0104079:	85 c0                	test   %eax,%eax
f010407b:	75 dd                	jne    f010405a <memcmp+0x14>
	}

	return 0;
f010407d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104082:	5b                   	pop    %ebx
f0104083:	5d                   	pop    %ebp
f0104084:	c3                   	ret    

f0104085 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
f0104085:	55                   	push   %ebp
f0104086:	89 e5                	mov    %esp,%ebp
f0104088:	8b 45 08             	mov    0x8(%ebp),%eax
f010408b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010408e:	89 c2                	mov    %eax,%edx
f0104090:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104093:	39 d0                	cmp    %edx,%eax
f0104095:	73 09                	jae    f01040a0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104097:	38 08                	cmp    %cl,(%eax)
f0104099:	74 05                	je     f01040a0 <memfind+0x1b>
f010409b:	40                   	inc    %eax
f010409c:	39 d0                	cmp    %edx,%eax
f010409e:	72 f7                	jb     f0104097 <memfind+0x12>
			break;
	return (void *) s;
}
f01040a0:	5d                   	pop    %ebp
f01040a1:	c3                   	ret    

f01040a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01040a2:	55                   	push   %ebp
f01040a3:	89 e5                	mov    %esp,%ebp
f01040a5:	57                   	push   %edi
f01040a6:	56                   	push   %esi
f01040a7:	53                   	push   %ebx
f01040a8:	83 ec 04             	sub    $0x4,%esp
f01040ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01040b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
f01040b4:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	long val = 0;
f01040bb:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01040c0:	80 39 20             	cmpb   $0x20,(%ecx)
f01040c3:	0f 94 c2             	sete   %dl
f01040c6:	80 39 09             	cmpb   $0x9,(%ecx)
f01040c9:	0f 94 c0             	sete   %al
f01040cc:	09 d0                	or     %edx,%eax
f01040ce:	a8 01                	test   $0x1,%al
f01040d0:	74 13                	je     f01040e5 <strtol+0x43>
		s++;
f01040d2:	41                   	inc    %ecx
f01040d3:	80 39 20             	cmpb   $0x20,(%ecx)
f01040d6:	0f 94 c2             	sete   %dl
f01040d9:	80 39 09             	cmpb   $0x9,(%ecx)
f01040dc:	0f 94 c0             	sete   %al
f01040df:	09 d0                	or     %edx,%eax
f01040e1:	a8 01                	test   $0x1,%al
f01040e3:	75 ed                	jne    f01040d2 <strtol+0x30>

	// plus/minus sign
	if (*s == '+')
f01040e5:	80 39 2b             	cmpb   $0x2b,(%ecx)
f01040e8:	75 03                	jne    f01040ed <strtol+0x4b>
		s++;
f01040ea:	41                   	inc    %ecx
f01040eb:	eb 0d                	jmp    f01040fa <strtol+0x58>
	else if (*s == '-')
f01040ed:	80 39 2d             	cmpb   $0x2d,(%ecx)
f01040f0:	75 08                	jne    f01040fa <strtol+0x58>
		s++, neg = 1;
f01040f2:	41                   	inc    %ecx
f01040f3:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01040fa:	85 db                	test   %ebx,%ebx
f01040fc:	0f 94 c2             	sete   %dl
f01040ff:	83 fb 10             	cmp    $0x10,%ebx
f0104102:	0f 94 c0             	sete   %al
f0104105:	09 d0                	or     %edx,%eax
f0104107:	a8 01                	test   $0x1,%al
f0104109:	74 15                	je     f0104120 <strtol+0x7e>
f010410b:	80 39 30             	cmpb   $0x30,(%ecx)
f010410e:	75 10                	jne    f0104120 <strtol+0x7e>
f0104110:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104114:	75 0a                	jne    f0104120 <strtol+0x7e>
		s += 2, base = 16;
f0104116:	83 c1 02             	add    $0x2,%ecx
f0104119:	bb 10 00 00 00       	mov    $0x10,%ebx
f010411e:	eb 1a                	jmp    f010413a <strtol+0x98>
	else if (base == 0 && s[0] == '0')
f0104120:	85 db                	test   %ebx,%ebx
f0104122:	75 16                	jne    f010413a <strtol+0x98>
f0104124:	80 39 30             	cmpb   $0x30,(%ecx)
f0104127:	75 08                	jne    f0104131 <strtol+0x8f>
		s++, base = 8;
f0104129:	41                   	inc    %ecx
f010412a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010412f:	eb 09                	jmp    f010413a <strtol+0x98>
	else if (base == 0)
f0104131:	85 db                	test   %ebx,%ebx
f0104133:	75 05                	jne    f010413a <strtol+0x98>
		base = 10;
f0104135:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010413a:	8a 01                	mov    (%ecx),%al
f010413c:	83 e8 30             	sub    $0x30,%eax
f010413f:	3c 09                	cmp    $0x9,%al
f0104141:	77 08                	ja     f010414b <strtol+0xa9>
			dig = *s - '0';
f0104143:	0f be 01             	movsbl (%ecx),%eax
f0104146:	83 e8 30             	sub    $0x30,%eax
f0104149:	eb 20                	jmp    f010416b <strtol+0xc9>
		else if (*s >= 'a' && *s <= 'z')
f010414b:	8a 01                	mov    (%ecx),%al
f010414d:	83 e8 61             	sub    $0x61,%eax
f0104150:	3c 19                	cmp    $0x19,%al
f0104152:	77 08                	ja     f010415c <strtol+0xba>
			dig = *s - 'a' + 10;
f0104154:	0f be 01             	movsbl (%ecx),%eax
f0104157:	83 e8 57             	sub    $0x57,%eax
f010415a:	eb 0f                	jmp    f010416b <strtol+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
f010415c:	8a 01                	mov    (%ecx),%al
f010415e:	83 e8 41             	sub    $0x41,%eax
f0104161:	3c 19                	cmp    $0x19,%al
f0104163:	77 12                	ja     f0104177 <strtol+0xd5>
			dig = *s - 'A' + 10;
f0104165:	0f be 01             	movsbl (%ecx),%eax
f0104168:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f010416b:	39 d8                	cmp    %ebx,%eax
f010416d:	7d 08                	jge    f0104177 <strtol+0xd5>
			break;
		s++, val = (val * base) + dig;
f010416f:	41                   	inc    %ecx
f0104170:	0f af f3             	imul   %ebx,%esi
f0104173:	01 c6                	add    %eax,%esi
f0104175:	eb c3                	jmp    f010413a <strtol+0x98>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104177:	85 ff                	test   %edi,%edi
f0104179:	74 02                	je     f010417d <strtol+0xdb>
		*endptr = (char *) s;
f010417b:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
f010417d:	89 f0                	mov    %esi,%eax
f010417f:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104183:	74 02                	je     f0104187 <strtol+0xe5>
f0104185:	f7 d8                	neg    %eax
}
f0104187:	83 c4 04             	add    $0x4,%esp
f010418a:	5b                   	pop    %ebx
f010418b:	5e                   	pop    %esi
f010418c:	5f                   	pop    %edi
f010418d:	5d                   	pop    %ebp
f010418e:	c3                   	ret    

f010418f <strtoul>:

unsigned int strtoul(const char *s, char **endptr, int base)
{
f010418f:	55                   	push   %ebp
f0104190:	89 e5                	mov    %esp,%ebp
f0104192:	57                   	push   %edi
f0104193:	56                   	push   %esi
f0104194:	53                   	push   %ebx
f0104195:	83 ec 04             	sub    $0x4,%esp
f0104198:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010419b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010419e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
f01041a1:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
	unsigned int val = 0;
f01041a8:	be 00 00 00 00       	mov    $0x0,%esi

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01041ad:	80 39 20             	cmpb   $0x20,(%ecx)
f01041b0:	0f 94 c2             	sete   %dl
f01041b3:	80 39 09             	cmpb   $0x9,(%ecx)
f01041b6:	0f 94 c0             	sete   %al
f01041b9:	09 d0                	or     %edx,%eax
f01041bb:	a8 01                	test   $0x1,%al
f01041bd:	74 13                	je     f01041d2 <strtoul+0x43>
		s++;
f01041bf:	41                   	inc    %ecx
f01041c0:	80 39 20             	cmpb   $0x20,(%ecx)
f01041c3:	0f 94 c2             	sete   %dl
f01041c6:	80 39 09             	cmpb   $0x9,(%ecx)
f01041c9:	0f 94 c0             	sete   %al
f01041cc:	09 d0                	or     %edx,%eax
f01041ce:	a8 01                	test   $0x1,%al
f01041d0:	75 ed                	jne    f01041bf <strtoul+0x30>

	// plus/minus sign
	if (*s == '+')
f01041d2:	80 39 2b             	cmpb   $0x2b,(%ecx)
f01041d5:	75 03                	jne    f01041da <strtoul+0x4b>
		s++;
f01041d7:	41                   	inc    %ecx
f01041d8:	eb 0d                	jmp    f01041e7 <strtoul+0x58>
	else if (*s == '-')
f01041da:	80 39 2d             	cmpb   $0x2d,(%ecx)
f01041dd:	75 08                	jne    f01041e7 <strtoul+0x58>
		s++, neg = 1;
f01041df:	41                   	inc    %ecx
f01041e0:	c7 45 f0 01 00 00 00 	movl   $0x1,0xfffffff0(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01041e7:	85 db                	test   %ebx,%ebx
f01041e9:	0f 94 c2             	sete   %dl
f01041ec:	83 fb 10             	cmp    $0x10,%ebx
f01041ef:	0f 94 c0             	sete   %al
f01041f2:	09 d0                	or     %edx,%eax
f01041f4:	a8 01                	test   $0x1,%al
f01041f6:	74 15                	je     f010420d <strtoul+0x7e>
f01041f8:	80 39 30             	cmpb   $0x30,(%ecx)
f01041fb:	75 10                	jne    f010420d <strtoul+0x7e>
f01041fd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104201:	75 0a                	jne    f010420d <strtoul+0x7e>
		s += 2, base = 16;
f0104203:	83 c1 02             	add    $0x2,%ecx
f0104206:	bb 10 00 00 00       	mov    $0x10,%ebx
f010420b:	eb 1a                	jmp    f0104227 <strtoul+0x98>
	else if (base == 0 && s[0] == '0')
f010420d:	85 db                	test   %ebx,%ebx
f010420f:	75 16                	jne    f0104227 <strtoul+0x98>
f0104211:	80 39 30             	cmpb   $0x30,(%ecx)
f0104214:	75 08                	jne    f010421e <strtoul+0x8f>
		s++, base = 8;
f0104216:	41                   	inc    %ecx
f0104217:	bb 08 00 00 00       	mov    $0x8,%ebx
f010421c:	eb 09                	jmp    f0104227 <strtoul+0x98>
	else if (base == 0)
f010421e:	85 db                	test   %ebx,%ebx
f0104220:	75 05                	jne    f0104227 <strtoul+0x98>
		base = 10;
f0104222:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104227:	8a 01                	mov    (%ecx),%al
f0104229:	83 e8 30             	sub    $0x30,%eax
f010422c:	3c 09                	cmp    $0x9,%al
f010422e:	77 08                	ja     f0104238 <strtoul+0xa9>
			dig = *s - '0';
f0104230:	0f be 01             	movsbl (%ecx),%eax
f0104233:	83 e8 30             	sub    $0x30,%eax
f0104236:	eb 20                	jmp    f0104258 <strtoul+0xc9>
		else if (*s >= 'a' && *s <= 'z')
f0104238:	8a 01                	mov    (%ecx),%al
f010423a:	83 e8 61             	sub    $0x61,%eax
f010423d:	3c 19                	cmp    $0x19,%al
f010423f:	77 08                	ja     f0104249 <strtoul+0xba>
			dig = *s - 'a' + 10;
f0104241:	0f be 01             	movsbl (%ecx),%eax
f0104244:	83 e8 57             	sub    $0x57,%eax
f0104247:	eb 0f                	jmp    f0104258 <strtoul+0xc9>
		else if (*s >= 'A' && *s <= 'Z')
f0104249:	8a 01                	mov    (%ecx),%al
f010424b:	83 e8 41             	sub    $0x41,%eax
f010424e:	3c 19                	cmp    $0x19,%al
f0104250:	77 12                	ja     f0104264 <strtoul+0xd5>
			dig = *s - 'A' + 10;
f0104252:	0f be 01             	movsbl (%ecx),%eax
f0104255:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f0104258:	39 d8                	cmp    %ebx,%eax
f010425a:	7d 08                	jge    f0104264 <strtoul+0xd5>
			break;
		s++, val = (val * base) + dig;
f010425c:	41                   	inc    %ecx
f010425d:	0f af f3             	imul   %ebx,%esi
f0104260:	01 c6                	add    %eax,%esi
f0104262:	eb c3                	jmp    f0104227 <strtoul+0x98>
				// we don't properly detect overflow!
	}
	if (endptr)
f0104264:	85 ff                	test   %edi,%edi
f0104266:	74 02                	je     f010426a <strtoul+0xdb>
		*endptr = (char *) s;
f0104268:	89 0f                	mov    %ecx,(%edi)
	return (neg ? -val : val);
f010426a:	89 f0                	mov    %esi,%eax
f010426c:	83 7d f0 00          	cmpl   $0x0,0xfffffff0(%ebp)
f0104270:	74 02                	je     f0104274 <strtoul+0xe5>
f0104272:	f7 d8                	neg    %eax
}
f0104274:	83 c4 04             	add    $0x4,%esp
f0104277:	5b                   	pop    %ebx
f0104278:	5e                   	pop    %esi
f0104279:	5f                   	pop    %edi
f010427a:	5d                   	pop    %ebp
f010427b:	c3                   	ret    

f010427c <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
f010427c:	55                   	push   %ebp
f010427d:	89 e5                	mov    %esp,%ebp
f010427f:	57                   	push   %edi
f0104280:	56                   	push   %esi
f0104281:	53                   	push   %ebx
f0104282:	83 ec 0c             	sub    $0xc,%esp
f0104285:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104288:	8b 75 0c             	mov    0xc(%ebp),%esi
f010428b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
f010428e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	(argv)[*argc] = 0;
f0104294:	8b 45 10             	mov    0x10(%ebp),%eax
f0104297:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f010429d:	eb 04                	jmp    f01042a3 <strsplit+0x27>
			*string++ = 0;
f010429f:	c6 03 00             	movb   $0x0,(%ebx)
f01042a2:	43                   	inc    %ebx
f01042a3:	80 3b 00             	cmpb   $0x0,(%ebx)
f01042a6:	74 4b                	je     f01042f3 <strsplit+0x77>
f01042a8:	83 ec 08             	sub    $0x8,%esp
f01042ab:	0f be 03             	movsbl (%ebx),%eax
f01042ae:	50                   	push   %eax
f01042af:	56                   	push   %esi
f01042b0:	e8 bf fc ff ff       	call   f0103f74 <strchr>
f01042b5:	83 c4 10             	add    $0x10,%esp
f01042b8:	85 c0                	test   %eax,%eax
f01042ba:	75 e3                	jne    f010429f <strsplit+0x23>
		
		//if the command string is finished, then break the loop
		if (*string == 0)
f01042bc:	80 3b 00             	cmpb   $0x0,(%ebx)
f01042bf:	74 32                	je     f01042f3 <strsplit+0x77>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
f01042c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01042c6:	83 3f 0f             	cmpl   $0xf,(%edi)
f01042c9:	74 39                	je     f0104304 <strsplit+0x88>
		{
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
f01042cb:	8b 07                	mov    (%edi),%eax
f01042cd:	8b 55 10             	mov    0x10(%ebp),%edx
f01042d0:	89 1c 82             	mov    %ebx,(%edx,%eax,4)
f01042d3:	ff 07                	incl   (%edi)
		while (*string && !strchr(SPLIT_CHARS, *string))
f01042d5:	eb 01                	jmp    f01042d8 <strsplit+0x5c>
			string++;
f01042d7:	43                   	inc    %ebx
f01042d8:	80 3b 00             	cmpb   $0x0,(%ebx)
f01042db:	74 16                	je     f01042f3 <strsplit+0x77>
f01042dd:	83 ec 08             	sub    $0x8,%esp
f01042e0:	0f be 03             	movsbl (%ebx),%eax
f01042e3:	50                   	push   %eax
f01042e4:	56                   	push   %esi
f01042e5:	e8 8a fc ff ff       	call   f0103f74 <strchr>
f01042ea:	83 c4 10             	add    $0x10,%esp
f01042ed:	85 c0                	test   %eax,%eax
f01042ef:	74 e6                	je     f01042d7 <strsplit+0x5b>
f01042f1:	eb b0                	jmp    f01042a3 <strsplit+0x27>
	}
	(argv)[*argc] = 0;
f01042f3:	8b 07                	mov    (%edi),%eax
f01042f5:	8b 55 10             	mov    0x10(%ebp),%edx
f01042f8:	c7 04 82 00 00 00 00 	movl   $0x0,(%edx,%eax,4)
	return 1 ;
f01042ff:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0104304:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
f0104307:	5b                   	pop    %ebx
f0104308:	5e                   	pop    %esi
f0104309:	5f                   	pop    %edi
f010430a:	5d                   	pop    %ebp
f010430b:	c3                   	ret    
f010430c:	00 00                	add    %al,(%eax)
	...

f0104310 <__udivdi3>:
f0104310:	55                   	push   %ebp
f0104311:	89 e5                	mov    %esp,%ebp
f0104313:	57                   	push   %edi
f0104314:	56                   	push   %esi
f0104315:	83 ec 20             	sub    $0x20,%esp
f0104318:	c7 45 f4 00 00 00 00 	movl   $0x0,0xfffffff4(%ebp)
f010431f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104322:	8b 55 14             	mov    0x14(%ebp),%edx
f0104325:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104328:	8b 45 10             	mov    0x10(%ebp),%eax
f010432b:	89 75 e8             	mov    %esi,0xffffffe8(%ebp)
f010432e:	c7 45 f0 00 00 00 00 	movl   $0x0,0xfffffff0(%ebp)
f0104335:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f0104338:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f010433b:	89 fe                	mov    %edi,%esi
f010433d:	85 d2                	test   %edx,%edx
f010433f:	75 2f                	jne    f0104370 <__udivdi3+0x60>
f0104341:	39 f8                	cmp    %edi,%eax
f0104343:	76 62                	jbe    f01043a7 <__udivdi3+0x97>
f0104345:	89 fa                	mov    %edi,%edx
f0104347:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010434a:	f7 75 dc             	divl   0xffffffdc(%ebp)
f010434d:	89 c7                	mov    %eax,%edi
f010434f:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
f0104356:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f0104359:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
f010435c:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f010435f:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104362:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0104365:	83 c4 20             	add    $0x20,%esp
f0104368:	5e                   	pop    %esi
f0104369:	5f                   	pop    %edi
f010436a:	5d                   	pop    %ebp
f010436b:	c3                   	ret    
f010436c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0104370:	31 ff                	xor    %edi,%edi
f0104372:	c7 45 d8 00 00 00 00 	movl   $0x0,0xffffffd8(%ebp)
f0104379:	39 75 ec             	cmp    %esi,0xffffffec(%ebp)
f010437c:	77 d8                	ja     f0104356 <__udivdi3+0x46>
f010437e:	0f bd 45 ec          	bsr    0xffffffec(%ebp),%eax
f0104382:	89 c7                	mov    %eax,%edi
f0104384:	83 f7 1f             	xor    $0x1f,%edi
f0104387:	75 5b                	jne    f01043e4 <__udivdi3+0xd4>
f0104389:	8b 4d dc             	mov    0xffffffdc(%ebp),%ecx
f010438c:	3b 75 ec             	cmp    0xffffffec(%ebp),%esi
f010438f:	0f 97 c2             	seta   %dl
f0104392:	39 4d e8             	cmp    %ecx,0xffffffe8(%ebp)
f0104395:	bf 01 00 00 00       	mov    $0x1,%edi
f010439a:	0f 93 c0             	setae  %al
f010439d:	09 d0                	or     %edx,%eax
f010439f:	a8 01                	test   $0x1,%al
f01043a1:	75 ac                	jne    f010434f <__udivdi3+0x3f>
f01043a3:	31 ff                	xor    %edi,%edi
f01043a5:	eb a8                	jmp    f010434f <__udivdi3+0x3f>
f01043a7:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f01043aa:	85 c0                	test   %eax,%eax
f01043ac:	75 0e                	jne    f01043bc <__udivdi3+0xac>
f01043ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01043b3:	31 c9                	xor    %ecx,%ecx
f01043b5:	31 d2                	xor    %edx,%edx
f01043b7:	f7 f1                	div    %ecx
f01043b9:	89 45 dc             	mov    %eax,0xffffffdc(%ebp)
f01043bc:	89 f0                	mov    %esi,%eax
f01043be:	31 d2                	xor    %edx,%edx
f01043c0:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01043c3:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f01043c6:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f01043c9:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01043cc:	89 c7                	mov    %eax,%edi
f01043ce:	8b 55 d8             	mov    0xffffffd8(%ebp),%edx
f01043d1:	89 7d f0             	mov    %edi,0xfffffff0(%ebp)
f01043d4:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f01043d7:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01043da:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01043dd:	83 c4 20             	add    $0x20,%esp
f01043e0:	5e                   	pop    %esi
f01043e1:	5f                   	pop    %edi
f01043e2:	5d                   	pop    %ebp
f01043e3:	c3                   	ret    
f01043e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01043e9:	89 f9                	mov    %edi,%ecx
f01043eb:	29 f8                	sub    %edi,%eax
f01043ed:	8b 55 ec             	mov    0xffffffec(%ebp),%edx
f01043f0:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f01043f3:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f01043f6:	d3 e2                	shl    %cl,%edx
f01043f8:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f01043fb:	d3 e8                	shr    %cl,%eax
f01043fd:	09 c2                	or     %eax,%edx
f01043ff:	89 f9                	mov    %edi,%ecx
f0104401:	d3 65 dc             	shll   %cl,0xffffffdc(%ebp)
f0104404:	89 55 ec             	mov    %edx,0xffffffec(%ebp)
f0104407:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f010440a:	89 f2                	mov    %esi,%edx
f010440c:	8b 45 e8             	mov    0xffffffe8(%ebp),%eax
f010440f:	d3 ea                	shr    %cl,%edx
f0104411:	89 f9                	mov    %edi,%ecx
f0104413:	d3 e6                	shl    %cl,%esi
f0104415:	8a 4d e4             	mov    0xffffffe4(%ebp),%cl
f0104418:	d3 e8                	shr    %cl,%eax
f010441a:	09 c6                	or     %eax,%esi
f010441c:	89 f9                	mov    %edi,%ecx
f010441e:	89 f0                	mov    %esi,%eax
f0104420:	f7 75 ec             	divl   0xffffffec(%ebp)
f0104423:	d3 65 e8             	shll   %cl,0xffffffe8(%ebp)
f0104426:	89 d6                	mov    %edx,%esi
f0104428:	89 c7                	mov    %eax,%edi
f010442a:	8b 45 dc             	mov    0xffffffdc(%ebp),%eax
f010442d:	f7 e7                	mul    %edi
f010442f:	39 f2                	cmp    %esi,%edx
f0104431:	77 15                	ja     f0104448 <__udivdi3+0x138>
f0104433:	39 f2                	cmp    %esi,%edx
f0104435:	0f 94 c2             	sete   %dl
f0104438:	3b 45 e8             	cmp    0xffffffe8(%ebp),%eax
f010443b:	0f 97 c0             	seta   %al
f010443e:	21 d0                	and    %edx,%eax
f0104440:	a8 01                	test   $0x1,%al
f0104442:	0f 84 07 ff ff ff    	je     f010434f <__udivdi3+0x3f>
f0104448:	4f                   	dec    %edi
f0104449:	e9 01 ff ff ff       	jmp    f010434f <__udivdi3+0x3f>
f010444e:	90                   	nop    
f010444f:	90                   	nop    

f0104450 <__umoddi3>:
f0104450:	55                   	push   %ebp
f0104451:	89 e5                	mov    %esp,%ebp
f0104453:	57                   	push   %edi
f0104454:	56                   	push   %esi
f0104455:	83 ec 38             	sub    $0x38,%esp
f0104458:	8d 4d f0             	lea    0xfffffff0(%ebp),%ecx
f010445b:	8b 55 14             	mov    0x14(%ebp),%edx
f010445e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104461:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104464:	8b 45 10             	mov    0x10(%ebp),%eax
f0104467:	c7 45 e0 00 00 00 00 	movl   $0x0,0xffffffe0(%ebp)
f010446e:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f0104475:	89 4d ec             	mov    %ecx,0xffffffec(%ebp)
f0104478:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
f010447b:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f010447e:	89 75 d8             	mov    %esi,0xffffffd8(%ebp)
f0104481:	89 7d d4             	mov    %edi,0xffffffd4(%ebp)
f0104484:	85 d2                	test   %edx,%edx
f0104486:	75 48                	jne    f01044d0 <__umoddi3+0x80>
f0104488:	39 f8                	cmp    %edi,%eax
f010448a:	0f 86 d0 00 00 00    	jbe    f0104560 <__umoddi3+0x110>
f0104490:	89 f0                	mov    %esi,%eax
f0104492:	89 fa                	mov    %edi,%edx
f0104494:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104497:	8b 75 ec             	mov    0xffffffec(%ebp),%esi
f010449a:	89 55 d8             	mov    %edx,0xffffffd8(%ebp)
f010449d:	85 f6                	test   %esi,%esi
f010449f:	74 49                	je     f01044ea <__umoddi3+0x9a>
f01044a1:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01044a4:	c7 45 e4 00 00 00 00 	movl   $0x0,0xffffffe4(%ebp)
f01044ab:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f01044ae:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f01044b1:	8b 55 e0             	mov    0xffffffe0(%ebp),%edx
f01044b4:	8b 4d e4             	mov    0xffffffe4(%ebp),%ecx
f01044b7:	89 10                	mov    %edx,(%eax)
f01044b9:	89 48 04             	mov    %ecx,0x4(%eax)
f01044bc:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01044bf:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01044c2:	83 c4 38             	add    $0x38,%esp
f01044c5:	5e                   	pop    %esi
f01044c6:	5f                   	pop    %edi
f01044c7:	5d                   	pop    %ebp
f01044c8:	c3                   	ret    
f01044c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi),%esi
f01044d0:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f01044d3:	39 55 dc             	cmp    %edx,0xffffffdc(%ebp)
f01044d6:	76 1f                	jbe    f01044f7 <__umoddi3+0xa7>
f01044d8:	89 75 e0             	mov    %esi,0xffffffe0(%ebp)
f01044db:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f01044de:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f01044e1:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f01044e4:	89 45 f0             	mov    %eax,0xfffffff0(%ebp)
f01044e7:	89 55 f4             	mov    %edx,0xfffffff4(%ebp)
f01044ea:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f01044ed:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f01044f0:	83 c4 38             	add    $0x38,%esp
f01044f3:	5e                   	pop    %esi
f01044f4:	5f                   	pop    %edi
f01044f5:	5d                   	pop    %ebp
f01044f6:	c3                   	ret    
f01044f7:	0f bd 45 dc          	bsr    0xffffffdc(%ebp),%eax
f01044fb:	83 f0 1f             	xor    $0x1f,%eax
f01044fe:	89 45 cc             	mov    %eax,0xffffffcc(%ebp)
f0104501:	0f 85 89 00 00 00    	jne    f0104590 <__umoddi3+0x140>
f0104507:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f010450a:	8b 4d c4             	mov    0xffffffc4(%ebp),%ecx
f010450d:	39 55 d4             	cmp    %edx,0xffffffd4(%ebp)
f0104510:	0f 97 c2             	seta   %dl
f0104513:	39 4d d8             	cmp    %ecx,0xffffffd8(%ebp)
f0104516:	0f 93 c0             	setae  %al
f0104519:	09 d0                	or     %edx,%eax
f010451b:	a8 01                	test   $0x1,%al
f010451d:	74 11                	je     f0104530 <__umoddi3+0xe0>
f010451f:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104522:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104525:	29 c8                	sub    %ecx,%eax
f0104527:	1b 55 dc             	sbb    0xffffffdc(%ebp),%edx
f010452a:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f010452d:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f0104530:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0104533:	85 c9                	test   %ecx,%ecx
f0104535:	74 b3                	je     f01044ea <__umoddi3+0x9a>
f0104537:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f010453a:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f010453d:	8b 4d ec             	mov    0xffffffec(%ebp),%ecx
f0104540:	89 45 e0             	mov    %eax,0xffffffe0(%ebp)
f0104543:	89 55 e4             	mov    %edx,0xffffffe4(%ebp)
f0104546:	8b 45 e0             	mov    0xffffffe0(%ebp),%eax
f0104549:	8b 55 e4             	mov    0xffffffe4(%ebp),%edx
f010454c:	89 01                	mov    %eax,(%ecx)
f010454e:	89 51 04             	mov    %edx,0x4(%ecx)
f0104551:	8b 45 f0             	mov    0xfffffff0(%ebp),%eax
f0104554:	8b 55 f4             	mov    0xfffffff4(%ebp),%edx
f0104557:	83 c4 38             	add    $0x38,%esp
f010455a:	5e                   	pop    %esi
f010455b:	5f                   	pop    %edi
f010455c:	5d                   	pop    %ebp
f010455d:	c3                   	ret    
f010455e:	89 f6                	mov    %esi,%esi
f0104560:	8b 7d c4             	mov    0xffffffc4(%ebp),%edi
f0104563:	85 ff                	test   %edi,%edi
f0104565:	75 0d                	jne    f0104574 <__umoddi3+0x124>
f0104567:	b8 01 00 00 00       	mov    $0x1,%eax
f010456c:	31 d2                	xor    %edx,%edx
f010456e:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104571:	89 45 c4             	mov    %eax,0xffffffc4(%ebp)
f0104574:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0104577:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f010457a:	f7 75 c4             	divl   0xffffffc4(%ebp)
f010457d:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f0104580:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104583:	f7 75 c4             	divl   0xffffffc4(%ebp)
f0104586:	e9 0c ff ff ff       	jmp    f0104497 <__umoddi3+0x47>
f010458b:	90                   	nop    
f010458c:	8d 74 26 00          	lea    0x0(%esi),%esi
f0104590:	8b 55 cc             	mov    0xffffffcc(%ebp),%edx
f0104593:	b8 20 00 00 00       	mov    $0x20,%eax
f0104598:	29 d0                	sub    %edx,%eax
f010459a:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f010459d:	89 45 d0             	mov    %eax,0xffffffd0(%ebp)
f01045a0:	8b 55 dc             	mov    0xffffffdc(%ebp),%edx
f01045a3:	d3 e2                	shl    %cl,%edx
f01045a5:	8b 45 c4             	mov    0xffffffc4(%ebp),%eax
f01045a8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f01045ab:	d3 e8                	shr    %cl,%eax
f01045ad:	09 c2                	or     %eax,%edx
f01045af:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f01045b2:	d3 65 c4             	shll   %cl,0xffffffc4(%ebp)
f01045b5:	89 55 dc             	mov    %edx,0xffffffdc(%ebp)
f01045b8:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f01045bb:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f01045be:	8b 75 d4             	mov    0xffffffd4(%ebp),%esi
f01045c1:	d3 ea                	shr    %cl,%edx
f01045c3:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f01045c6:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f01045c9:	d3 e6                	shl    %cl,%esi
f01045cb:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f01045ce:	d3 e8                	shr    %cl,%eax
f01045d0:	09 c6                	or     %eax,%esi
f01045d2:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f01045d5:	89 75 d4             	mov    %esi,0xffffffd4(%ebp)
f01045d8:	89 f0                	mov    %esi,%eax
f01045da:	f7 75 dc             	divl   0xffffffdc(%ebp)
f01045dd:	d3 65 d8             	shll   %cl,0xffffffd8(%ebp)
f01045e0:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f01045e3:	f7 65 c4             	mull   0xffffffc4(%ebp)
f01045e6:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f01045e9:	89 d6                	mov    %edx,%esi
f01045eb:	89 c7                	mov    %eax,%edi
f01045ed:	77 12                	ja     f0104601 <__umoddi3+0x1b1>
f01045ef:	3b 55 d4             	cmp    0xffffffd4(%ebp),%edx
f01045f2:	0f 94 c2             	sete   %dl
f01045f5:	3b 45 d8             	cmp    0xffffffd8(%ebp),%eax
f01045f8:	0f 97 c0             	seta   %al
f01045fb:	21 d0                	and    %edx,%eax
f01045fd:	a8 01                	test   $0x1,%al
f01045ff:	74 06                	je     f0104607 <__umoddi3+0x1b7>
f0104601:	2b 7d c4             	sub    0xffffffc4(%ebp),%edi
f0104604:	1b 75 dc             	sbb    0xffffffdc(%ebp),%esi
f0104607:	8b 45 ec             	mov    0xffffffec(%ebp),%eax
f010460a:	85 c0                	test   %eax,%eax
f010460c:	0f 84 d8 fe ff ff    	je     f01044ea <__umoddi3+0x9a>
f0104612:	8a 4d d0             	mov    0xffffffd0(%ebp),%cl
f0104615:	8b 55 d4             	mov    0xffffffd4(%ebp),%edx
f0104618:	8b 45 d8             	mov    0xffffffd8(%ebp),%eax
f010461b:	29 f8                	sub    %edi,%eax
f010461d:	19 f2                	sbb    %esi,%edx
f010461f:	89 55 d4             	mov    %edx,0xffffffd4(%ebp)
f0104622:	d3 e2                	shl    %cl,%edx
f0104624:	8a 4d cc             	mov    0xffffffcc(%ebp),%cl
f0104627:	89 45 d8             	mov    %eax,0xffffffd8(%ebp)
f010462a:	d3 e8                	shr    %cl,%eax
f010462c:	09 c2                	or     %eax,%edx
f010462e:	8b 45 d4             	mov    0xffffffd4(%ebp),%eax
f0104631:	d3 e8                	shr    %cl,%eax
f0104633:	89 55 e0             	mov    %edx,0xffffffe0(%ebp)
f0104636:	89 45 e4             	mov    %eax,0xffffffe4(%ebp)
f0104639:	e9 70 fe ff ff       	jmp    f01044ae <__umoddi3+0x5e>
f010463e:	90                   	nop    
f010463f:	90                   	nop    
