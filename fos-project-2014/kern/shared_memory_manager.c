#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/environment_definitions.h>

#include <kern/shared_memory_manager.h>
#include <kern/memory_manager.h>
#include <kern/syscall.h>

int getShareNumber(char* name) {
	int i = 0;
	for (; i < nShares; ++i) {
		if (strcmp(name, shares[i].name) == 0) {
			return i;
		}
	}
	return -1;
}

int createSharedObject(char* shareName, uint32 size, uint8 isWritable,
		void** returned_shared_address) {
	//TODO: [PROJECT 2014 - Shared] createSharedObject()
	// your code is here, remove the panic and write your code
	//panic("createSharedObject() is not implemented yet...!!");
	struct Env* myenv = curenv; //The calling environment

	// This function should create the shared object with the given size
	// in the SHARED area of the current environment
	// and return the start address of it by setting the "*returned_shared_address"
	int nofFrame = ROUNDUP(size , PAGE_SIZE ) / PAGE_SIZE, i;
	shares[nShares].nofFrame = nofFrame;
	// RETURN:
	//	a) 0 if success
	//	b) E_NO_MEM if the required size exceed the max shared area "USER_SHARED_MEM_MAX"
	if (myenv->shared_free_address + (nofFrame * PAGE_SIZE)
			>= USER_SHARED_MEM_MAX)
		return E_NO_MEM;
	//	c) E_SHARED_MEM_EXISTS if the shared object already exists
	if (getShareNumber(shareName) != -1)
		return E_SHARED_MEM_EXISTS;
	//	d) E_NO_SHARE if the number of shared objects reaches max "MAX_SHARES"
	if (nShares >= MAX_SHARES)
		return E_NO_SHARE;
	struct Frame_Info *ptr_frame_info;

	// Steps:
	for (i = 0; i < nofFrame; ++i) {
		//	1) Allocate the required space in the physical memory on a PAGE boundary
		int r = allocate_frame(&ptr_frame_info);

		//	2) Map the allocated space on the "shared_free_address" of current environment "curenv": object OWNER, with writable permissions
		int m = map_frame(myenv->env_pgdir, ptr_frame_info,
				(void *) myenv->shared_free_address, (PERM_PRESENT | PERM_USER
						| PERM_WRITEABLE));

		if (i == 0) {
			// 	6) Return the start address of the object by setting the "*returned_shared_address"
			*returned_shared_address = (uint32 *) myenv->shared_free_address;
		}
		//	3) Update the "shared_free_address" of the Current environment to be aligned on a PAGE boundary (i.e. 4 KB boundary)
		myenv->shared_free_address += PAGE_SIZE;
		//	4) Add all allocated frames to "frames_storage" of this shared object to keep track of them for later use
		//		(use: add_frame_to_storage())
		add_frame_to_storage((uint32 *) shares[nShares].framesStorage,
				ptr_frame_info, i);
	}

	//	5) Add the shared object to the end of the "shares" array (use "nShares"), remember to:
	//		a) Set the data members of the object with suitable values (name, size, ...)
	strcpy(shares[nShares].name, shareName);
	shares[nShares].size = size;
	//		b) Set references to 1 (as there's 1 user environment that use the object now - OWNER)
	shares[nShares].references = 1;
	//		c) Store the object's isWritable flag (0:ReadOnly, 1:Writable) for later use by getSharedObject()
	shares[nShares].isWritable = isWritable;
	//shares[nShares] = OpShare ;
	nShares++;
	return 0;
}

int getSharedObject(char* shareName, void** returned_shared_address) {
	//TODO: [PROJECT 2014 - Shared] getSharedObject()
	// your code is here, remove the panic and write your code
	//panic("getSharedObject() is not implemented yet...!!");

	struct Env* myenv = curenv; //The calling environment

	int sh = getShareNumber(shareName);

	// This function should share the required object in SHARED area of the current environment (with the specified permissions: read_only/writable)
	// and return the start address of it by setting the "*returned_shared_address"
	// RETURN:
	//	a) 0 if success
	//	b) E_SHARED_MEM_NOT_EXISTS if the shared object is not exists
	if (sh == -1)
		return E_SHARED_MEM_NOT_EXISTS;

	// Steps:
	//	1) Get the shared object from the "shares" array
	struct Frame_Info *ptr_frame_info;
	int i;
	for (i = 0; i < shares[sh].nofFrame; ++i) {
		//	2) Get its physical frames from the frames_storage
		//		(use: get_frame_from_storage())
		ptr_frame_info = get_frame_from_storage(shares[sh].framesStorage, i);

		//	3) Share these frames with the current environment "curenv" starting from its "shared_free_address"
		//  4) make sure that read-only object must be shared "read only", use the flag isWritable to make it either read-only or writable
		int m;
		if (shares[sh].isWritable)
			m = map_frame(myenv->env_pgdir, ptr_frame_info,
					(void *) myenv->shared_free_address, (PERM_PRESENT
							| PERM_USER | PERM_WRITEABLE));
		else
			m = map_frame(myenv->env_pgdir, ptr_frame_info,
					(void *) myenv->shared_free_address, (PERM_PRESENT
							| PERM_USER));

		// 	7) Return the start address of the shared object by setting the "*returned_shared_address"
		if (i == 0) {
			*returned_shared_address = (uint32 *) myenv->shared_free_address;
		}

		//	5) Update the "shared_free_address" of the current environment to be aligned on a PAGE boundary
		myenv->shared_free_address += PAGE_SIZE;

	}

	//	6) Update references
	shares[sh].references++;

	return 0;
}

//========================== BONUS ============================
// Free Shared Object

int freeSharedObject(char* shareName) {
	//TODO: [PROJECT 2014 - BONUS3] freeSharedObject()
	// your code is here, remove the panic and write your code
	//panic("freeSharedObject() is not implemented yet...!!");
	struct Env* myenv = curenv; //The calling environment

	// This function should free (delete) the shared object from the SHARED area of the current environment
	// If this is the last shared env, then the "frames_store" should be cleared and the shared object should be deleted
	// RETURN:
	//	a) 0 if success
	//	b) E_SHARED_MEM_NOT_EXISTS if the shared object is not exists
	int sh = getShareNumber(shareName);

	if (sh == -1)

		return E_SHARED_MEM_NOT_EXISTS;

	// Steps:

	//	1) Get the shared object from the "shares" array

	//	2) Find its start address in the current environment

	int i;
	struct Frame_Info *ptr_frame_info;
	for (i = 0; i < shares[sh].nofFrame; ++i)

	{
		ptr_frame_info = get_frame_from_storage(shares[sh].framesStorage, i);
		//	2) Unmap it from the current environment "curenv"
		unmap_frame(myenv->env_pgdir,(void*)ptr_frame_info->va);
		//	3) If one or more table becomes empty, remove it
		uint32 *ptr_page_table1 = NULL;
		get_page_table(myenv->env_pgdir, (uint32*) ptr_frame_info->va, &ptr_page_table1);
		int check = 0;
		int j;
		for (j = 0; j < 1024; j += 1) {
			int c = ptr_page_table1[j] & PERM_PRESENT;
			if (c != 0) {
				check = 1;
				break;
			}
		}
		if (check == 0 && ptr_page_table1 != NULL) {
			uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table1);
			struct Frame_Info *table_frame_info = to_frame_info(table_pa);
			table_frame_info->references = 0;
			free_frame(table_frame_info);
			uint32 dir_index = PDX((uint32*)ptr_frame_info->va);
			myenv->env_pgdir[dir_index] = 0;
			tlbflush();
		}
	}

	//	4) Update references
	shares[sh].references--;

	//	5) If this is the last share:

	if (shares[sh].references == 0)

	{

		//		a) clear the frames_storage of this shared object (use: clear_frames_storage())

		clear_frames_storage(shares[sh].framesStorage);

		//		b) clear all other data members of this object (name, size, ...)

		shares[sh].name[0] = '\0';

		shares[sh].nofFrame = 0;

		shares[sh].size = 0;

		shares[sh].isWritable = 0;

	}

	//	6) Flush the cache "tlbflush()"

	tlbflush();

	return 0;
}
