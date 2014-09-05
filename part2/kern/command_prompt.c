/*	Simple command-line kernel prompt useful for
 controlling the kernel and exploring the system interactively.


 KEY WORDS
 ==========
 CONSTANTS:	WHITESPACE, NUM_OF_COMMANDS
 VARIABLES:	Command, commands, name, description, function_to_execute, number_of_arguments, arguments, command_string, command_line, command_found
 FUNCTIONS:	readline, cprintf, execute_command, run_command_prompt, command_kernel_info, command_help, strcmp, strsplit, start_of_kernel, start_of_uninitialized_data_section, end_of_kernel_code_section, end_of_kernel
 =====================================================================================================================================================================================================
 */

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/command_prompt.h>
#include <kern/memory_manager.h>
#include <kern/trap.h>
#include <kern/kdebug.h>
#include <kern/user_environment.h>

//Structure for each command
struct Command {
	char *name;
	char *description;
	// return -1 to force command prompt to exit
	int (*function_to_execute)(int number_of_arguments, char** arguments);
	int num_of_arguments;
};

//Functions Declaration
int execute_command(char *command_string);
int command_writemem(int number_of_arguments, char **arguments);
int command_readmem(int number_of_arguments, char **arguments);
int command_readblock(int number_of_arguments, char **arguments);

uint32 va_start = 0;
struct UserProgramInfo *running = NULL;

//Array of commands. (initialized)
struct Command commands[] = { { "help", "Display this list of commands",
		command_help }, { "kernel_info",
				"Display information about the kernel", command_kernel_info }, {
						"writemem",
						"writes one byte to specific location in given user program",
						command_writemem }, { "readmem",
								"reads one byte from specific location in given user program",
								command_readmem }, { "readblock",
										"reads block of bytes from specific location in given user program",
										command_readblock }, { "alloc_page",
												"allocate single page at the given user virtual address",
												command_allocpage }, { "free_table", "free table at va",
														command_free_table }, { "free_page", "free a va page",
																command_free_page }, { "rum",
																		"read single byte at the given user virtual address",
																		command_readusermem }, { "wum",
																				"write single byte at the given user virtual address",
																				command_writeusermem }, { "meminfo",
																						"show information about the physical memory", command_meminfo }, {
																								"sm", "Lab4.HandsOn", command_show_mapping }, { "setperm",
																										"Lab4.HandsOn", command_set_permission }, { "sharepa", "Lab4.HandsOn",
																												command_share_pa }, { "connect_va", "lab4.assignment 3", connect_va },
																												{ "showmappings", "lab4.assignment 3", show_mappings }, { "cpp",
																														"lab4.assignment 3", cut_paste_page }, { "share_4m_r",
																																"lab4.assignment 3", share_4M_readonly }, { "rt",
																																		"lab4.assignment 3", remove_table }, { "aum",
																																				"lab4.assignment 4", alloc_user_mem }, { "cp",
																																						"lab4.assignment 4", copy_page }, { "npit",
																																								"lab4.assignment 4", num_pages_in_table }, { "fc",
																																										"lab4.assignment 4", free_chunck }, { "cto",
																																												"lab4.assignment 4", create_tables_only }, { "run",
																																														"Lab6.HandsOn: Load and Run User Program", command_run }, {
																																																"kill", "Lab6.HandsOn: Kill User Program", command_kill }, };

//Number of commands = size of the array / size of command structure
#define NUM_OF_COMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

//invoke the command prompt
void run_command_prompt() {
	char command_line[1024];

	while (1 == 1) {
		//get command line
		readline("FOS> ", command_line);

		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
				break;
	}
}

/***** Kernel command prompt command interpreter *****/

//define the white-space symbols
#define WHITESPACE "\t\r\n "

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string) {
	// Split the command string into whitespace-separated arguments
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];

	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments);
	if (number_of_arguments == 0)
		return 0;

	// Lookup in the commands array and execute the command
	int command_found = 0;
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++) {
		if (strcmp(arguments[0], commands[i].name) == 0) {
			command_found = 1;
			break;
		}
	}

	if (command_found) {
		int return_value;
		return_value = commands[i].function_to_execute(number_of_arguments,
				arguments);
		return return_value;
	} else {
		//if not found, then it's unknown command
		cprintf("Unknown command '%s'\n", arguments[0]);
		return 0;
	}
}

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments) {
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].description);

	cprintf("-------------------\n");

	return 0;
}

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments) {
	extern char start_of_kernel[], end_of_kernel_code_section[],
	start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n",
			start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n",
			end_of_kernel_code_section, end_of_kernel_code_section
			- KERNEL_BASE);
	cprintf(
			"  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n",
			start_of_uninitialized_data_section,
			start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n",
			end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n", (end_of_kernel
			- start_of_kernel + 1023) / 1024);
	return 0;
}

int command_writemem(int number_of_arguments, char **arguments) {
	char* user_program_name = arguments[1];
	int address = strtol(arguments[3], NULL, 16);

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
			user_program_name);
	if (ptr_user_program_info == NULL)
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	unsigned char *ptr = (unsigned char *) (address);

	//Write the given Character
	*ptr = arguments[2][0];
	lcr3(oldDir);

	return 0;
}

int command_readmem(int number_of_arguments, char **arguments) {
	char* user_program_name = arguments[1];
	int address = strtol(arguments[2], NULL, 16);

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
			user_program_name);
	if (ptr_user_program_info == NULL)
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	unsigned char *ptr = (unsigned char *) (address);

	//Write the given Character
	cprintf("value at address %x = %c\n", address, *ptr);

	lcr3(oldDir);
	return 0;
}

int command_readblock(int number_of_arguments, char **arguments) {
	char* user_program_name = arguments[1];
	int address = strtol(arguments[2], NULL, 16);
	int nBytes = strtol(arguments[3], NULL, 10);

	unsigned char *ptr = (unsigned char *) (address);
	//Write the given Character

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(
			user_program_name);
	if (ptr_user_program_info == NULL)
		return 0;

	uint32 oldDir = rcr3();
	lcr3(
			(uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	int i;
	for (i = 0; i < nBytes; i++) {
		cprintf("%08x : %02x  %c\n", ptr, *ptr, *ptr);
		ptr++;
	}
	lcr3(oldDir);

	return 0;
}

int command_allocpage(int number_of_arguments, char **arguments) {
	unsigned int address = strtol(arguments[1], NULL, 16);
	unsigned char *ptr = (unsigned char *) (address);

	struct Frame_Info * ptr_frame_info;
	allocate_frame(&ptr_frame_info);

	map_frame(ptr_page_directory, ptr_frame_info, ptr, PERM_WRITEABLE
			| PERM_USER);

	return 0;
}

int command_free_page(int number_of_arguments, char **arguments) {
	uint32 address = strtol(arguments[1], NULL, 16);
	unsigned char *va = (unsigned char *) (address);
	// Un-map the page at this address
	unmap_frame(ptr_page_directory, va);
	return 0;
}

int command_free_table(int number_of_arguments, char **arguments) {
	uint32 address = strtol(arguments[1], NULL, 16);
	unsigned char *va = (unsigned char *) (address);
	uint32 * ptr_page_table;
	// get the page table of the given virtual address
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
	if (ptr_page_table == NULL)
		return 0;
	// get the physical address and Frame_Info of the page table
	uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table);
	struct Frame_Info *table_frame_info = to_frame_info(table_pa);
	// set references of the table frame to 0 then free it by adding
	// to the free frame list
	table_frame_info->references = 0;
	free_frame(table_frame_info);
	// set the corresponding entry in the directory to 0
	uint32 dir_index = PDX(va);
	ptr_page_directory[dir_index] = 0;
	return 0;
}

int command_readusermem(int number_of_arguments, char **arguments) {
	unsigned int address = strtol(arguments[1], NULL, 16);
	unsigned char *ptr = (unsigned char *) (address);

	cprintf("value at address %x = %c\n", ptr, *ptr);

	return 0;
}

int command_writeusermem(int number_of_arguments, char **arguments) {
	unsigned int address = strtol(arguments[1], NULL, 16);
	unsigned char *ptr = (unsigned char *) (address);
	*ptr = arguments[2][0];

	return 0;
}

int command_meminfo(int number_of_arguments, char **arguments) {
	cprintf("Free frames = %d\n", calculate_free_frames());
	struct UserProgramInfo* temp = running;
	cprintf("Program Name\tEnv ID\tMain Size (KB)\tTables Size (KB)\n");
	while( temp != NULL )
	{
		cprintf("%s\t%d\t%u\t%u\n",temp->name, temp->envID,temp->mainS, temp->tableS);
		temp = temp->next;
	}
	return 0;
}

int command_show_mapping(int number_of_arguments, char **arguments) {
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *ptr_page_table = NULL;
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
	if (ptr_page_table != NULL) {
		int dir_index = PDX(va);
		int table_index = PTX(va);
		uint32 fn = ptr_page_table[table_index] >> 12;
		cprintf("DIR Index = %d\nTable Index = %d\nFrame Number = %0d\n",
				dir_index, table_index, fn);

	}
	return 0;
}
int command_set_permission(int number_of_arguments, char **arguments) {
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *ptr_page_table = NULL;
	get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
	if (ptr_page_table != NULL) {
		char perm = arguments[2][0];
		int table_index = PTX(va);

		if (perm == 'r') {
			ptr_page_table[table_index] &= (~PERM_WRITEABLE);
		} else if (perm == 'w') {
			cprintf("%x\n", ptr_page_table[table_index]);
			ptr_page_table[table_index] |= (PERM_WRITEABLE);
			cprintf("%x\n", ptr_page_table[table_index]);
		}
		//tlb_invalidate(ptr_page_directory, va); // delete the cache of the given address
		tlbflush(); // delete the whole cache
	}

	return 0;
}

int command_share_pa(int number_of_arguments, char **arguments) {
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *ptr_page_table1 = NULL;
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
	if (ptr_page_table1 != NULL) {
		uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
		uint32 *ptr_page_table2 = NULL;
		get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
		ptr_page_table2[PTX(va2)] = ptr_page_table1[PTX(va1)];
	}
	return 0;
}
int connect_va(int number_of_arguments, char **arguments) {
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 pa = strtoul(arguments[2], NULL, 16);
	uint32 *ptr_page_table = NULL;
	get_page_table(ptr_page_directory, va, 1, &ptr_page_table);
	if (ptr_page_table != NULL) {
		ptr_page_table[PTX(va)] = pa;
		char c = arguments[3][0];
		if (c == 'r')
			ptr_page_table[PTX(va)] &= (~PERM_WRITEABLE);
		else if (c == 'w')
			ptr_page_table[PTX(va)] |= (PERM_WRITEABLE);
	}
	ptr_page_table[PTX(va)] |= PERM_PRESENT;
	tlbflush();
	return 0;
}

int show_mappings(int number_of_arguments, char **arguments) {
	uint32 i = strtoul(arguments[1], NULL, 16);
	uint32 j = strtoul(arguments[2], NULL, 16);
	cprintf("%u %u\n", i, j);
	cprintf("DIR Index\tPAGE Table Index\tPhysical Address\tModified\n");
	for (; i <= j; i += 4096) {
		uint32 *va = (uint32*) i;
		uint32 *ptr_page_table = NULL;
		get_page_table(ptr_page_directory, va, 0, &ptr_page_table);
		if (ptr_page_table != NULL) {
			int dir_index = PDX(va);
			int table_index = PTX(va);
			uint32 check = ptr_page_table[table_index];
			uint32 ccheck = ptr_page_table[table_index] & PERM_MODIFIED;
			//cprintf("%u\n", check);
			check = check >> 12;
			//cprintf("%u\n", check);
			check = check << 12;
			//cprintf("%u\n", check);
			cprintf("%d \t %d\t %x\t", dir_index, table_index, check);
			if (ccheck == 0)
				cprintf("No\n");
			else
				cprintf("Yes\n");

		}
	}
	return 0;
}

int cut_paste_page(int number_of_arguments, char **arguments) {
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *ptr_page_table1 = NULL;
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
	if (ptr_page_table1 != NULL) {
		uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
		uint32 *ptr_page_table2 = NULL;
		get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
		ptr_page_table2[PTX(va2)] = ptr_page_table1[PTX(va1)];
		ptr_page_table1[PTX(va1)] = (uint32) NULL;
		//ptr_page_table1[PTX(va1)] &= ( ~PERM_PRESENT);
	}
	tlbflush();
	return 0;
}

int share_4M_readonly(int number_of_arguments, char **arguments) {
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
	uint32 *ptr_page_table1 = NULL;
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
	uint32 *ptr_page_table2 = NULL;
	get_page_table(ptr_page_directory, va2, 1, &ptr_page_table2);
	if (ptr_page_table1 != NULL) {
		int i = 0;
		for (i = 0; i <= 1024; i++)
			ptr_page_table2[i] = ptr_page_table1[i] & (~PERM_WRITEABLE);
	}
	//ptr_page_directory[PDX(va2)] = ptr_page_directory[PDX(va1)];
	tlbflush();
	return 0;
}

int remove_table(int number_of_arguments, char **arguments) {
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	cprintf("%x\n", PDX(va));
	ptr_page_directory[PDX(va)] = (uint32) NULL;
	tlbflush();
	return 0;
}

int alloc_user_mem(int number_of_arguments, char **arguments) {
	uint32 count = strtoul(arguments[1], NULL, 10);
	if (arguments[2][0] == 'k')
		count *= 1024;
	else
		count *= 1024 * 1024;
	//cprintf("%u\n", count);
	struct Frame_Info *ptr_frame_info;
	uint32 i;
	uint32 l = ROUNDDOWN(va_start, PAGE_SIZE);
	uint32 s = ROUNDUP( count+va_start, PAGE_SIZE);
	for (i = l; i < s; i += PAGE_SIZE) {
		uint32 *pge_table;
		struct Frame_Info *pt = get_frame_info(ptr_page_directory, (void*) i,
				&pge_table);
		if (pt != NULL)
			continue;
		int ret = allocate_frame(&ptr_frame_info);
		//cprintf("%d\n", to_frame_number(ptr_frame_info));
		if (ret != E_NO_MEM) {
			//uint32 physical_address = to_physical_address(ptr_frame_info);
			int m = map_frame(ptr_page_directory, ptr_frame_info, (void *) i,
					PERM_WRITEABLE | PERM_USER | PERM_PRESENT);
			if (m == E_NO_MEM)
				cprintf("Error: no physical memory available\n");
		} else {
			cprintf("Error: no physical memory available\n");
		}
	}
	va_start += count;
	tlbflush();
	return 0;
}

int copy_page(int number_of_arguments, char **arguments) {
	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *va2 = (uint32 *) strtol(arguments[2], NULL, 16);
	uint32 *ptr_page_table1 = NULL;
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
	uint32 *ptr_page_table2 = NULL;
	get_page_table(ptr_page_directory, va2, 0, &ptr_page_table2);
	struct Frame_Info *ptr_frame_info = get_frame_info(ptr_page_directory,
			(void*) va2, &ptr_page_table2);
	if (ptr_frame_info == NULL) {
		struct Frame_Info *ptr_frame_info;
		int ret = allocate_frame(&ptr_frame_info);
		if (ret != E_NO_MEM) {
			int m = map_frame(ptr_page_directory, ptr_frame_info, (void *) va2,
					PERM_WRITEABLE | PERM_USER | PERM_PRESENT);
			if (m == E_NO_MEM)
				cprintf("Error: no physical memory available\n");
		} else {
			cprintf("Error: no physical memory available\n");
		}
	}
	uint32 k = (uint32) va1, j = (uint32) va2, count = (4 * 1024)
															+ (uint32) va1;
	while (k < count) {
		unsigned char *ptr1 = (unsigned char *) (k);
		unsigned char *ptr2 = (unsigned char *) (j);
		*ptr2 = *ptr1;
		k++;
		j++;
	}
	tlbflush();
	return 0;
}

int num_pages_in_table(int number_of_arguments, char **arguments) {

	uint32 *va1 = (uint32 *) strtol(arguments[1], NULL, 16);
	uint32 *ptr_page_table1 = NULL;
	get_page_table(ptr_page_directory, va1, 0, &ptr_page_table1);
	//struct Frame_Info * f = get_frame_info(ptr_page_directory,va1, *ptr_page_table1 );
	if (ptr_page_table1 == NULL)
		cprintf("Table doesn't exist\n");
	else {
		int ans = 0;
		int i;
		for (i = 0; i < 1024; i++) {
			int a = ptr_page_table1[i] & PERM_PRESENT;
			if (a != 0)
				ans++;
		}
		cprintf("number of pages = %d\n", ans);
	}

	//tlbflush();
	return 0;
}

int free_chunck(int number_of_arguments, char **arguments) {
	uint32 count = strtoul(arguments[2], NULL, 10);
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	if (arguments[3][0] == 'k')
		count *= 1024;
	else
		count *= 1024 * 1024;
	struct Frame_Info *ptr_frame_info;
	uint32 i;
	uint32 l = ROUNDDOWN((uint32)va, PAGE_SIZE);
	uint32 s = ROUNDUP( count+(uint32)va, PAGE_SIZE);
	for (i = l; i < s; i += PAGE_SIZE) {
		unsigned char *vaa = (unsigned char *) (i);
		// Un-map the page at this address
		unmap_frame(ptr_page_directory, vaa);
	}
	l = ROUNDDOWN((uint32)va, PTSIZE);
	s = ROUNDUP( count+(uint32)va, PTSIZE);
	for (i = l; i < s; i += PTSIZE) {
		uint32 b = ROUNDDOWN(i, PTSIZE);
		uint32 *ptr_page_table1 = NULL;
		get_page_table(ptr_page_directory, (uint32*) i, 0, &ptr_page_table1);
		int check = 0;
		int j;
		for (j = 0; j < 1024; j += 1) {
			//struct Frame_Info *ptr_frame_info = get_frame_info(
			//ptr_page_directory, (void*) b + j, &ptr_page_table1);
			int c = ptr_page_table1[j] & PERM_PRESENT;
			if( c != 0)
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
			uint32 table_pa = K_PHYSICAL_ADDRESS(ptr_page_table1);
			struct Frame_Info *table_frame_info = to_frame_info(table_pa);
			table_frame_info->references = 0;
			free_frame(table_frame_info);
			uint32 dir_index = PDX((uint32*)i);
			ptr_page_directory[dir_index] = 0;
		}
	}
	va_start -= count;
	tlbflush();
	return 0;
}
int create_tables_only(int number_of_arguments, char **arguments) {
	uint32 count = strtoul(arguments[2], NULL, 10);
	uint32 *va = (uint32 *) strtol(arguments[1], NULL, 16);
	if (arguments[3][0] == 'k')
		count *= 1024;
	else
		count *= 1024 * 1024;
	uint32 l = ROUNDDOWN((uint32)va, PTSIZE);
	uint32 s = ROUNDUP( count+(uint32)va, PTSIZE);
	int i;
	for (i = l; i < s; i += PTSIZE) {
		uint32 *ptr_page_table1 = NULL;
		get_page_table(ptr_page_directory, (uint32*) i, 1, &ptr_page_table1);
	}
	tlbflush();
	return 0;
}

//============ lab 6 hands on ==============

int command_run(int number_of_arguments, char **arguments) {
	//[1] Create and initialize a new environment for the program to be run
	struct UserProgramInfo* ptr_program_info = env_create(arguments[1]);
	if (ptr_program_info == 0)
		return 0;
	if( running == NULL )
		running = ptr_program_info;
	else
	{
		struct UserProgramInfo* temp = running;
		while( temp->next != NULL)
			temp = temp->next;
		temp->next = ptr_program_info;
	}
	//[2] Run the created environment using "env_run" function
	env_run(ptr_program_info->environment);
	return 0;
}

int command_kill(int number_of_arguments, char **arguments) {
	//[1] Get the user program info of the program (by searching in the "userPrograms" array
	struct UserProgramInfo* ptr_program_info = get_user_program_info(
			arguments[1]);
	if (ptr_program_info == 0)
		return 0;
	struct UserProgramInfo* temp = running;
	if( temp != NULL && temp->name == ptr_program_info->name)
		running = running->next;
	else
	{
		while( temp->next != NULL )
		{
			if( temp->next->name == ptr_program_info->name)
			{
				temp->next = temp->next->next;
				//delete temp1;
				break;
			}
			else
				temp = temp->next;
		}
	}
	//[2] Kill its environment using "env_free" function
	env_free(ptr_program_info->environment);
	ptr_program_info->environment = NULL;
	return 0;
}
//======================================================
