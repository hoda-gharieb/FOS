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
struct Batch {
	char name[100];
	char commands[10][1024];
	int num_of_commands;
};
struct Batch batches[20] = { };
struct arrInd {
	unsigned int add;
	int sz;
	int type;
	unsigned char** ptr_add;
};
struct arrInd arr_Ind[20] = { };
int arrsInd = 0;

// My int array start address variable
unsigned int intArrAddress = 0xf1000000;

//Number of commands = size of the array / size of command structure
#define NUM_OF_COMMANDS (sizeof(commands)/sizeof(commands[0]))
#define WHITESPACE "\t\r\n " //define the white-space symbols
#define SPLIT "|"

int num_of_batches = 0;
unsigned read_eip();
char all_commands[20][1024];
int Current_Command = 0;
int Commands_count = 0;

//Array of commands. (initialized)
struct Command commands[] = { { "help", "Display this list of commands",
		command_help, 1 }, { "kernel_info",
		"Display information about the kernel", command_kernel_info, 1 }, {
		"ver", "Display info about the kernel", comm_kernel_version, 1 }, {
		"add", "addition process", comm_add, 3 }, { "rep", "repeat a string",
		command_rep, 3 }, { "like", "fetch all commands with requested suffix",
		command_like, 2 },
		{ "batch_create", "create a batch", batch_create, 2 }, {
				"batch_execute", "execute a given batch", batch_execute, 2 }, {
				"wm", "put variable in memory", command_wm, 3 }, { "rm",
				"get variable memory", command_rm, 2 }, { "rb",
				"read a block of bytes from memory", command_readBlock, 3 }, {
				"cia", "create an integer array", command_createIntArr, 2 }, {
				"seia", "set value to an elemnt in array",
				set_element_in_array, 4 }, { "fia",
				"search for element in an array", find_in_array, 3 },

		{ "wb", "write block of chars in memory", write_block, 3 }, { "cnd",
				"check new and delete", check_new_delete, 1 }, { "search",
				"search for a hexa value in memory", command_search, 3 }, };

//invoke the command prompt
void read_string(char *line) {
	char c;
	int i = 0;
	cprintf("FOS> ");
	while ((c = getchar()) && c != '\n') {
		//cprintf("%c",c);
		if ((int) c == -30 || (int) c == -29) {
			int k;
			for (k = 0; k < i; k++)
				cprintf("\b");
			for (k = 0; k < i; k++)
				cprintf(" ");
			for (k = 0; k < i; k++)
				cprintf("\b");
			if ((int) c == -30) {

				if (Current_Command + 1 < Commands_count) {
					Current_Command++;
					cprintf("%s", all_commands[Current_Command]);
				} else
					cprintf("%s", all_commands[Current_Command]);

			} else {
				if (Current_Command - 1 >= 0) {
					Current_Command--;
					cprintf("%s", all_commands[Current_Command]);
				} else
					cprintf("%s", all_commands[Current_Command]);
			}
			i = strlen(all_commands[Current_Command]);
			i--;
			strcpy(line, all_commands[Current_Command]);
		} else if ((int) c == 9) {
			char arr[10][100];
			int j = 0;
			int n1, k, check;
			line[i] = '\0';
			n1 = strlen(line);
			for (k = 0; k < n1; k++)
				cprintf("\b");
			for (k = 0; k < n1; k++)
				cprintf(" ");
			for (k = 0; k < n1; k++)
				cprintf("\b");
			for (k = 0; k < NUM_OF_COMMANDS; k++) {
				check = strncmp(commands[k].name, line, n1);
				if (check == 0) {
					strcpy(arr[j], commands[k].name);
					j++;
				}
			}
			if (j > 1) {
				for (k = 0; k < j; k++)
					cprintf("%s\n", arr[k]);
				line[0] = '\0';
				return;
			} else {
					cprintf("%s", arr[0]);
				strcpy(line, arr[0]);
				i = strlen(arr[0]) - 1;
			}
		} else if (c == 8) {
			if (i - 1 >= 0) {
				cprintf("\b");
				cprintf(" ");
				cprintf("\b");
				line[i - 1] = ' ';
				i -= 2;
			}
		} else {
			line[i] = c;
			cprintf("%c", c);
		}
		i++;
	}
	line[i] = '\0';
}

void run_command_prompt() {
	char command_line[1024];
	while (1 == 1) {
		read_string(command_line);
		cprintf("\n");
		//parse and execute the command
		if (command_line != NULL) {
			strcpy(all_commands[Commands_count], command_line);
			Commands_count++;
							Current_Command = Commands_count;
			if (execute_command(command_line) < 0)
				break;
		}
		command_line[0] = '\0';
	}
}

/***** Kernel command prompt command interpreter *****/

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string) {
	// Split the command string into whitespace-separated arguments
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];
	int num_of_commands;
	char *all_commands[MAX_ARGUMENTS];

	strsplit(command_string, SPLIT, all_commands, &num_of_commands);
	int j;
	for (j = 0; j < num_of_commands; j++) {
		strsplit(all_commands[j], WHITESPACE, arguments, &number_of_arguments);
		if (number_of_arguments == 0)
			continue; //return 0;

		// Lookup in the commands array and execute the command
		int command_found = 0;
		int i;
		for (i = 0; i < NUM_OF_COMMANDS; i++) {
			if (strcmp(arguments[0], commands[i].name) == 0) {
				if (number_of_arguments != commands[i].num_of_arguments)
					command_found = 2;
				else
					command_found = 1;
				break;
			}
		}

		if (command_found == 1) {
			int return_value;
			return_value = commands[i].function_to_execute(number_of_arguments,
					arguments);
			//return return_value;
		} else if (command_found == 2) {
			cprintf("Invalid number of arguments\n");
			//return 0;
		} else {
			//if not found, then it's unknown command
			cprintf("Unknown command '%s'\n", arguments[0]);
			//return 0;
		}
	}
	return 0;
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

int comm_kernel_version(int number_of_arguments, char **arguments) {

	cprintf("FOS kernel version 0.1\n");

	return 0;
}

int comm_add(int number_of_arguments, char **arguments) {

	char mystr[] = "hoda";
	int n1, n2, res;
	n1 = strtol(arguments[1], NULL, 10);
	n2 = strtol(arguments[2], NULL, 10);
	res = n1 + n2;
	cprintf("%d + %d = %d\n", n1, n2, res);

	return 0;
}

int command_rep(int number_of_arguments, char **arguments) {

	int n1, i;
	n1 = strtol(arguments[2], NULL, 10);
	for (i = 0; i < n1; i++)
		cprintf("%s\n", arguments[1]);

	return 0;
}

int command_like(int number_of_arguments, char **arguments) {

	int n1, i, check;
	n1 = strlen(arguments[1]);
	for (i = 0; i < NUM_OF_COMMANDS; i++) {
		check = strncmp(commands[i].name, arguments[1], n1);
		if (check == 0)
			cprintf("%s\n", commands[i]);
	}

	return 0;
}

int batch_create(int number_of_arguments, char **arguments) {
	strcpy(batches[num_of_batches].name, arguments[1]);
	char end[] = "endBatch";
	int n = 0;
	while (1) {
		char line[1024];
		readline("", line);
		if (strcmp(end, line) == 0)
			break;
		int i;
		strcpy(batches[num_of_batches].commands[n], line);
		n++;
	}
	batches[num_of_batches].num_of_commands = n;
	num_of_batches++;

	return 0;
}

int batch_execute(int number_of_arguments, char **arguments) {
	int i;
	for (i = 0; i < num_of_batches; i++) {
		if (strcmp(arguments[1], batches[i].name) == 0) {
			int j, n;
			for (j = 0; j < batches[i].num_of_commands; j++)
				n = execute_command(batches[i].commands[j]);
		}
	}

	return 0;
}

//2nd lab

int command_wm(int number_of_arguments, char **arguments) {

	int n1 = strtol(arguments[1], NULL, 10);
	char *ptr;
	ptr = (char*) (n1 + KERNEL_BASE);
	*ptr = arguments[2][0];
	return 0;
}

int command_rm(int number_of_arguments, char **arguments) {

	int n1 = strtol(arguments[1], NULL, 10);
	char *ptr;
	ptr = (char*) (n1 + KERNEL_BASE);
	cprintf("Mem location at address %d = %c\n", n1, *ptr);
	return 0;
}

int command_readBlock(int number_of_arguments, char **arguments) {
	unsigned int phy_add = strtol(arguments[1], NULL, 10);
	unsigned int vir_add = phy_add + KERNEL_BASE;
	char* ptr = (char*) vir_add;
	int num = strtol(arguments[2], NULL, 10);
	int i;
	for (i = 0; i < num; i++) {
		cprintf("%c\n", *ptr);
		ptr++;
	}
	return 0;
}

int command_createIntArr(int number_of_arguments, char **arguments) {
	int num = strtol(arguments[1], NULL, 10);
	cprintf("The start virtual address of the allocated array is: %x\n",
			intArrAddress);
	int* ptr = (int*) intArrAddress;
	int i;
	for (i = 0; i < num; i++) {
		char Number[20];
		cprintf("Enter element %d\n", i + 1);
		readline("", Number);
		*ptr = strtol(Number, NULL, 10);
		ptr++;
	}
	arr_Ind[arrsInd].add = intArrAddress;
	arr_Ind[arrsInd].sz = num;
	arr_Ind[arrsInd].type = 4;
	arrsInd++;
	intArrAddress = (unsigned int) ptr;
	return 0;
}

int set_element_in_array(int number_of_arguments, char **arguments) {
	unsigned int ind_arr;
	ind_arr = strtoul(arguments[1], NULL, 16);
	int* ptr = (int*) ind_arr;

	int index = strtol(arguments[2], NULL, 10);
	int element = strtol(arguments[3], NULL, 10);

	ptr = index + ptr;
	*ptr = element;
	return 0;
}

int find_in_array(int number_of_arguments, char **arguments) {
	unsigned int my_arr = strtoul(arguments[1], NULL, 16);
	int num = strtol(arguments[2], NULL, 10);
	int i;
	int j = 0;
	for (i = 0; i < arrsInd; i++) {
		if (my_arr == arr_Ind[i].add) {
			j = 1;
			int* ptr = (int*) my_arr;
			int k;
			for (k = 0; k < arr_Ind[i].sz; k++) {
				if (*ptr == num) {
					j = 2;
					cprintf("Element was found at index: %d\n", k);
					break;
				}
				ptr++;
			}
		}
	}
	if (j == 0)
		cprintf("No array was created at this address.\n");
	else if (j == 1)
		cprintf("Element wasn't found\n");
	return 0;
}

int write_block(int number_of_arguments, char **arguments) {
	unsigned int arr = strtoul(arguments[1], NULL, 16);
	int maxi = strtol(arguments[2], NULL, 10);
	int count = 0;
	int check = 0;
	unsigned char* ptr = (unsigned char*) (arr + KERNEL_BASE);
	char line[1024];
	while (1) {
		cprintf("%x : ", ptr);
		readline("", line);
		int i;
		for (i = 0; i < strlen(line); i++) {
			*ptr = line[i];
			ptr++;
			count++;
			if (line[i] == '$' || count == maxi) {
				check = 1;
				break;
			}
		}
		if (check == 1)
			break;
	}
	return 0;
}
int new(unsigned char** start, int sze) {
	unsigned char* ptr;
	*start = (unsigned char*) intArrAddress;
	ptr = *start;
	ptr = ptr + sze;
	arr_Ind[arrsInd].add = intArrAddress;
	arr_Ind[arrsInd].sz = sze;
	arr_Ind[arrsInd].type = 1;
	arr_Ind[arrsInd].ptr_add = start;
	arrsInd++;
	intArrAddress = (unsigned int) ptr;
	return 0;
}
int delete(unsigned char** arrr) {
	unsigned int start = (unsigned int) *arrr;
	//cprintf("%x\n",*arrr);
	int i;
	for (i = 0; i < arrsInd; i++) {
		if ((unsigned int) *arrr == arr_Ind[i].add) {
			unsigned int arrs = (unsigned int) *arrr;
			int k = i + 1;
			for (; k < arrsInd; k++) {
				if (arr_Ind[k].type == 4) {
					int* ptr;
					int* pp;
					ptr = (int*) arrs;
					pp = (int*) arr_Ind[k].add;
					int l;
					for (l = 0; l < arr_Ind[k].sz; l++) {
						*ptr = *pp;
						ptr++;
						pp++;
					}
					*arr_Ind[k].ptr_add = (unsigned char*) arrs;
					arr_Ind[k].add = arrs;
					arrs = (unsigned int) ptr;
				} else {
					unsigned char* ptr;
					unsigned char* pp;
					ptr = (unsigned char*) arrs;
					pp = (unsigned char*) arr_Ind[k].add;
					int l;
					for (l = 0; l < arr_Ind[k].sz; l++) {
						*ptr = *pp;
						ptr++;
						pp++;
					}
					*arr_Ind[k].ptr_add = (unsigned char*) arrs;
					arr_Ind[k].add = arrs;
					arrs = (unsigned int) ptr;
				}
				arr_Ind[i].add = (unsigned int) NULL;

			}
			break;
		}
	}
	return 0;
}

int check_new_delete(int number_of_arguments, char **arguments) {
	unsigned char *array1 = NULL, *array2 = NULL, *array3 = NULL;
	new(&array1, 10);
	cprintf("array1 address after new %x\n", array1);
	new(&array2, 20);
	cprintf("array2 address after new %x\n", array2);
	new(&array3, 5);
	cprintf("array3 address after new %x\n", array3);
	*(array2 + 10) = 'a';
	cprintf("The tenth element in array2 after new: %c\n", *(array2 + 10));
	delete(&array1);
	cprintf("array2 address after delete %x\n", array2);
	cprintf("array3 address after delete %x\n", array3);
	cprintf("The tenth element in array2 after delete: %c\n", *(array2 + 10));
	return 0;
}

int command_search(int number_of_arguments, char **arguments) {
	unsigned int base = KERNEL_BASE;
	int sz = strtol(arguments[2], NULL, 10);
	if (sz == 1) {
		char* ptr;
		char check = (char) strtol(arguments[1], NULL, 16);
		while (base != 0xf100000f) {
			ptr = (char*) base;
			if (*ptr == check)
				cprintf("%c found at location %x\n", *ptr, ptr);
			base++;
		}
	} else if (sz == 2) {
		short* ptr;
		short check = (short) strtol(arguments[1], NULL, 16);
		while (base != 0xf100000f) {
			ptr = (short*) base;
			if (*ptr == check)
				cprintf("%d found at location %x\n", *ptr, ptr);
			base++;
		}
	} else {

		int* ptr;
		int check = (int) strtol(arguments[1], NULL, 16);
		while (base <= 0xf100000f) {
			ptr = (int*) base;
			if (*ptr == check)
				cprintf("%d found at location %x\n", *ptr, ptr);
			base++;
		}
	}
	return 0;
}
