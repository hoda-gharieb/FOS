#include <inc/lib.h>

/*
 * Simple malloc()
 *
 * The address space for the dynamic allocation is 
 * from "USER_HEAP_START" to "USER_HEAP_MAX"-1
 * Pages are allocated ON 4KB ALIGMENT
 * On succeed, return void pointer to the allocated space
 * return NULL if
 *	-there's no suitable space for the required allocation
 */

// malloc()
//	This function use FIRST FIT strategy to allocate space in heap with the given size
//  and return void pointer to the start of the allocated space

//	To do this, we need to switch to the kernel, allocate the required space
//	in Main memory then switch back to the user again.
//
//	We can use sys_allocateMem(uint32 virtual_address, uint32 size); which
//		switches to the kernel mode, calls allocateMem(struct Env* e, uint32 virtual_address, uint32 size) in
//		"memory_manager.c", then switch back to the user mode here
//	the allocateMem function is empty, make sure to implement it.

//uint32 visted[131073];
uint32 visted[1500000];
void* malloc(uint32 size) {
	//TODO: [PROJECT 2014 - Heap] malloc()
	// your code is here, remove the panic and write your code
	//panic("malloc() is not implemented yet...!!");
	int sva = USER_HEAP_START, fva = USER_HEAP_MAX;
	int framnumber = ROUNDUP(size , (1024*4) ) / PAGE_SIZE;
	// Steps:
	//	1) search for FIRST FIT space in heap that is suitable for the required allocation size
	int i, BoolFram;
	for (i = 0; i < 131072; ++i) {
		if (visted[i] == 0) {
			BoolFram = 0;
			if (i + framnumber < 131072) {
				int j;
				for (j = 0; j < framnumber; j++) {
					if (visted[i + j] != 0) {
						BoolFram = 1;
						i += j;
						break;
					}
				}
			} else
				return NULL;

		}
		if (BoolFram == 0)
			break;

	}
	//	2) if no suitable space found, return NULL
	if (i == 131072) //262144)
		return NULL;

	//	 Else,
	//	3) Call sys_allocateMem to invoke the Kernel for allocation
	uint32 va = USER_HEAP_START + (i * PAGE_SIZE);
	// visted
	int j, k;
	for (j = 0, k = i; j < framnumber; ++j, ++k) {
		visted[k] = va;
	}

	sys_allocateMem(va, size);
	// 	4) Return pointer containing the virtual address of allocated space,
	//
	//This function should allocate ALL pages of the required range
	// ******** ON 4KB ALIGNMENT *******************

	return (void*) va;
}

void free(void* virtual_address) {
	//TODO: [PROJECT 2014 - Heap] free()
	// your code is here, remove the panic and write your code
	//panic("free() is not implemented yet...!!");
	//get the size of the given allocation using its address
	int i = ((int) virtual_address - USER_HEAP_START) / PAGE_SIZE;
	uint32 va = visted[i];
	int Framenumber = 0;
	while (visted[i] == va) {
		Framenumber++;
		visted[i] = 0;
		++i;
	}
	//you need to call sys_freeMem()
	uint32 size = Framenumber * PAGE_SIZE;
	sys_freeMem((uint32) virtual_address, size);
}

//================= [BONUS] =====================

// realloc():

//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, in which case the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to malloc().
//	A call with new_size = zero is equivalent to free().

//  Hint: you may need to use the sys_moveMem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
//		which switches to the kernel mode, calls moveMem(struct Env* e, uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
//		in "memory_manager.c", then switch back to the user mode here
//	the moveMem function is empty, make sure to implement it.

void *realloc(void *virtual_address, uint32 new_size) {

	// 2 cases stated by the dr
	if (virtual_address == NULL) {
		cprintf("malloc\n");
		return malloc(new_size);
	} else if (new_size == 0) {
		cprintf("free\n");
		free(virtual_address);
		return virtual_address;
	}

	int i = ((int) virtual_address - USER_HEAP_START) / PAGE_SIZE;
	uint32 vaa = visted[i];
	int Framenumber = 0;
	while (visted[i] == vaa) {
		Framenumber++;
		visted[i] = 0;
		++i;
	}
	//in case reallocation for a size smaller than original size
	uint32 size = Framenumber * PAGE_SIZE;
	if (new_size < size) {
		sys_freeMem((uint32) virtual_address + new_size, size - new_size);
		return virtual_address;
	}

	//check if it can expand the virtual address or not
	// if yes it will expand it
	// else it will allocate a new address
	void* new_expand = expand(virtual_address, new_size);
	if (new_expand != NULL) {
		cprintf("new expand\n");
		return new_expand;
	} else {
		//allocate new space
		void* va = malloc(new_size);
		if (va == NULL) {
			return virtual_address;
		}

		uint32 va1, va2;
		va1 = (uint32) ROUNDDOWN(virtual_address,PAGE_SIZE);
		va2 = (uint32) ROUNDDOWN(va,PAGE_SIZE);
		uint32 ccount = Framenumber * PAGE_SIZE;
		ccount += va1;
		//copy values in old addresses in new one
		while (va1 < ccount) {

			uint32 *ptr1 = (uint32 *) (va1);
			uint32 *ptr2 = (uint32 *) (va2);
			*ptr2 = *ptr1;
			va1++;
			va2++;
		}

		free(virtual_address);

		return va;
	}

}

void* expand(void* va, int new_size) {
	cprintf("expand\n");
	int i = ((int) va - USER_HEAP_START) / PAGE_SIZE;
	uint32 temp = visted[i];
	int Framenumber = 0;

	while (visted[i] == temp) {
		Framenumber++;
		++i;
	}

	uint32 size = Framenumber * PAGE_SIZE;
	int j, k;
	int framnumber = ROUNDUP(new_size - size , PAGE_SIZE) / PAGE_SIZE;
	int check = 0;
	cprintf("frame = %d\n", framnumber);
	for (j = 0, k = i; j < framnumber; ++j, ++k) {
		if (visted[k] != 0) {
			check = 1;
			break;
		}
	}
	if (check == 1)
		return NULL;
	cprintf("check = 0\n");
	for (j = 0, k = i; j < framnumber; ++j, ++k) {
		visted[k] = temp;
	}

	sys_allocateMem(((uint32) va) + size, new_size - size);
	return va;
}
