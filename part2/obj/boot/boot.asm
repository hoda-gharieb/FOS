
obj/boot/boot.out:     file format elf32-i386

Disassembly of section .text:

00007c00 <start>:
###############################################################################
	
.globl start					# Entry point	
start:		.code16				# This runs in real mode
		cli				# Disable interrupts
    7c00:	fa                   	cli    
		cld				# String operations increment
    7c01:	fc                   	cld    

		# Set up the important data segment registers (DS, ES, SS).
		xorw	%ax,%ax			# Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
		movw	%ax,%ds			# -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
		movw	%ax,%es			# -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
		movw	%ax,%ss			# -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

		# Set up the stack pointer, growing downward from 0x7c00.
		movw	$start,%sp         	# Stack Pointer
    7c0a:	bc 00 7c e4 64       	mov    $0x64e47c00,%esp

00007c0d <seta20.1>:
	
# Enable A20:
#   For fascinating historical reasons (related to the fact that
#   the earliest 8086-based PCs could only address 1MB of physical memory
#   and subsequent 80286-based PCs wanted to retain maximum compatibility),
#   physical address line 20 is tied to low when the machine boots.
#   Obviously this a bit of a drag for us, especially when trying to
#   address memory above 1MB.  This code undoes this.
	
seta20.1:	inb	$0x64,%al		# Get status
    7c0d:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c0f:	a8 02                	test   $0x2,%al
		jnz	seta20.1		# Yes
    7c11:	75 fa                	jne    7c0d <seta20.1>
		movb	$0xd1,%al		# Command: Write
    7c13:	b0 d1                	mov    $0xd1,%al
		outb	%al,$0x64		#  output port
    7c15:	e6 64                	out    %al,$0x64

00007c17 <seta20.2>:
seta20.2:	inb	$0x64,%al		# Get status
    7c17:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c19:	a8 02                	test   $0x2,%al
		jnz	seta20.2		# Yes
    7c1b:	75 fa                	jne    7c17 <seta20.2>
		movb	$0xdf,%al		# Enable
    7c1d:	b0 df                	mov    $0xdf,%al
		outb	%al,$0x60		#  A20
    7c1f:	e6 60                	out    %al,$0x60

00007c21 <real_to_prot>:

# Switch from real to protected mode:
#   Up until now, there's been no protection, so we've gotten along perfectly
#   well without explicitly telling the processor how to translate addresses.
#   When we switch to protected mode, this is no longer true!
#   We need at least to set up some "segments" that tell the processor it's
#   OK to run code at any address, or write to any address.
#   The 'gdt' and 'gdtdesc' tables below define these segments.
#   This code loads them into the processor.
#   We need this setup to ensure the transition to protected mode is smooth.

real_to_prot:	cli			# Don't allow interrupts: mandatory,
    7c21:	fa                   	cli    
					# since we didn't set up an interrupt
					# descriptor table for handling them
		lgdt	gdtdesc		# load GDT: mandatory in protected mode
    7c22:	0f 01 16             	lgdtl  (%esi)
    7c25:	64                   	fs
    7c26:	7c 0f                	jl     7c37 <protcseg+0x1>
		movl	%cr0, %eax	# Turn on protected mode
    7c28:	20 c0                	and    %al,%al
		orl	$CR0_PE_ON, %eax
    7c2a:	66 83 c8 01          	or     $0x1,%ax
		movl	%eax, %cr0
    7c2e:	0f 22 c0             	mov    %eax,%cr0

	        # CPU magic: jump to relocation, flush prefetch queue, and
		# reload %cs.  Has the effect of just jmp to the next
		# instruction, but simultaneously loads CS with
		# $PROT_MODE_CSEG.
		ljmp	$PROT_MODE_CSEG, $protcseg
    7c31:	ea 36 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c36

00007c36 <protcseg>:
	
		# we've switched to 32-bit protected mode; tell the assembler
		# to generate code for that mode
protcseg:	.code32
		# Set up the protected-mode data segment registers
		movw	$PROT_MODE_DSEG, %ax	# Our data segment selector
    7c36:	66 b8 10 00          	mov    $0x10,%ax
		movw	%ax, %ds		# -> DS: Data Segment
    7c3a:	8e d8                	mov    %eax,%ds
		movw	%ax, %es		# -> ES: Extra Segment
    7c3c:	8e c0                	mov    %eax,%es
		movw	%ax, %fs		# -> FS
    7c3e:	8e e0                	mov    %eax,%fs
		movw	%ax, %gs		# -> GS
    7c40:	8e e8                	mov    %eax,%gs
		movw	%ax, %ss		# -> SS: Stack Segment
    7c42:	8e d0                	mov    %eax,%ss
	
		call cmain			# finish the boot load from C.
    7c44:	e8 23 00 00 00       	call   7c6c <cmain>

00007c49 <spin>:
						# cmain() should not return
spin:		jmp spin			# ..but in case it does, spin
    7c49:	eb fe                	jmp    7c49 <spin>
    7c4b:	90                   	nop    

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 89 e5    	add    %dl,0xe5895590(%eax)

00007c6c <cmain>:
void readseg(uint32, uint32, uint32);

void
cmain(void)
{
    7c6c:	55                   	push   %ebp
    7c6d:	89 e5                	mov    %esp,%ebp
    7c6f:	56                   	push   %esi
    7c70:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32) ELFHDR, SECTSIZE*8, 0);
    7c71:	6a 00                	push   $0x0
    7c73:	68 00 10 00 00       	push   $0x1000
    7c78:	68 00 00 01 00       	push   $0x10000
    7c7d:	e8 65 00 00 00       	call   7ce7 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7c82:	83 c4 0c             	add    $0xc,%esp
    7c85:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7c8c:	45 4c 46 
    7c8f:	75 41                	jne    7cd2 <cmain+0x66>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8 *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
    7c91:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7c98:	c1 e0 05             	shl    $0x5,%eax
    7c9b:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
    7ca1:	81 c3 00 00 01 00    	add    $0x10000,%ebx
    7ca7:	8d 34 18             	lea    (%eax,%ebx,1),%esi
	for (; ph < eph; ph++)
    7caa:	39 f3                	cmp    %esi,%ebx
    7cac:	73 18                	jae    7cc6 <cmain+0x5a>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7cae:	ff 73 04             	pushl  0x4(%ebx)
    7cb1:	ff 73 14             	pushl  0x14(%ebx)
    7cb4:	ff 73 08             	pushl  0x8(%ebx)
    7cb7:	83 c3 20             	add    $0x20,%ebx
    7cba:	e8 28 00 00 00       	call   7ce7 <readseg>
    7cbf:	83 c4 0c             	add    $0xc,%esp
    7cc2:	39 f3                	cmp    %esi,%ebx
    7cc4:	72 e8                	jb     7cae <cmain+0x42>

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry & 0xFFFFFF))();
    7cc6:	a1 18 00 01 00       	mov    0x10018,%eax
    7ccb:	25 ff ff ff 00       	and    $0xffffff,%eax
    7cd0:	ff d0                	call   *%eax
}

static __inline void
outw(int port, uint16 data)
{
    7cd2:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7cd7:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7cdc:	66 ef                	out    %ax,(%dx)
    7cde:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7ce3:	66 ef                	out    %ax,(%dx)

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
    7ce5:	eb fe                	jmp    7ce5 <cmain+0x79>

00007ce7 <readseg>:
		/* do nothing */;
}

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32 va, uint32 count, uint32 offset)
{
    7ce7:	55                   	push   %ebp
    7ce8:	89 e5                	mov    %esp,%ebp
    7cea:	57                   	push   %edi
    7ceb:	56                   	push   %esi
    7cec:	53                   	push   %ebx
	uint32 end_va;

	va &= 0xFFFFFF;
    7ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf0:	8b 45 10             	mov    0x10(%ebp),%eax
	end_va = va + count;
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf3:	c1 e8 09             	shr    $0x9,%eax
    7cf6:	81 e3 ff ff ff 00    	and    $0xffffff,%ebx
    7cfc:	89 df                	mov    %ebx,%edi
    7cfe:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
    7d04:	03 7d 0c             	add    0xc(%ebp),%edi
    7d07:	8d 70 01             	lea    0x1(%eax),%esi

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7d0a:	39 fb                	cmp    %edi,%ebx
    7d0c:	73 14                	jae    7d22 <readseg+0x3b>
		readsect((uint8*) va, offset);
    7d0e:	56                   	push   %esi
		va += SECTSIZE;
		offset++;
    7d0f:	46                   	inc    %esi
    7d10:	53                   	push   %ebx
    7d11:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d17:	e8 23 00 00 00       	call   7d3f <readsect>
    7d1c:	39 fb                	cmp    %edi,%ebx
    7d1e:	58                   	pop    %eax
    7d1f:	5a                   	pop    %edx
    7d20:	72 ec                	jb     7d0e <readseg+0x27>
	}
}
    7d22:	8d 65 f4             	lea    0xfffffff4(%ebp),%esp
    7d25:	5b                   	pop    %ebx
    7d26:	5e                   	pop    %esi
    7d27:	5f                   	pop    %edi
    7d28:	5d                   	pop    %ebp
    7d29:	c3                   	ret    

00007d2a <waitdisk>:

void
waitdisk(void)
{
    7d2a:	55                   	push   %ebp
    7d2b:	89 e5                	mov    %esp,%ebp
}

static __inline uint8
inb(int port)
{
    7d2d:	ba f7 01 00 00       	mov    $0x1f7,%edx
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7d32:	ec                   	in     (%dx),%al
    7d33:	25 c0 00 00 00       	and    $0xc0,%eax
    7d38:	83 f8 40             	cmp    $0x40,%eax
    7d3b:	75 f0                	jne    7d2d <waitdisk+0x3>
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}
    7d3d:	5d                   	pop    %ebp
    7d3e:	c3                   	ret    

00007d3f <readsect>:

void
readsect(void *dst, uint32 offset)
{
    7d3f:	55                   	push   %ebp
    7d40:	89 e5                	mov    %esp,%ebp
    7d42:	57                   	push   %edi
    7d43:	53                   	push   %ebx
    7d44:	8b 7d 08             	mov    0x8(%ebp),%edi
    7d47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// wait for disk to be ready
	waitdisk();
    7d4a:	e8 db ff ff ff       	call   7d2a <waitdisk>
}

static __inline void
outb(int port, uint8 data)
{
    7d4f:	b0 01                	mov    $0x1,%al
    7d51:	ba f2 01 00 00       	mov    $0x1f2,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7d56:	ee                   	out    %al,(%dx)
    7d57:	88 d8                	mov    %bl,%al
    7d59:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7d5e:	ee                   	out    %al,(%dx)
    7d5f:	89 d8                	mov    %ebx,%eax
    7d61:	c1 e8 08             	shr    $0x8,%eax
    7d64:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7d69:	ee                   	out    %al,(%dx)
    7d6a:	89 d8                	mov    %ebx,%eax
    7d6c:	c1 e8 10             	shr    $0x10,%eax
    7d6f:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7d74:	ee                   	out    %al,(%dx)
    7d75:	c1 eb 18             	shr    $0x18,%ebx
    7d78:	83 cb e0             	or     $0xffffffe0,%ebx
    7d7b:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7d80:	88 d8                	mov    %bl,%al
    7d82:	ee                   	out    %al,(%dx)
    7d83:	b0 20                	mov    $0x20,%al
    7d85:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d8a:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7d8b:	e8 9a ff ff ff       	call   7d2a <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
    7d90:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d95:	b9 80 00 00 00       	mov    $0x80,%ecx
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7d9a:	fc                   	cld    
    7d9b:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7d9d:	5b                   	pop    %ebx
    7d9e:	5f                   	pop    %edi
    7d9f:	5d                   	pop    %ebp
    7da0:	c3                   	ret    
