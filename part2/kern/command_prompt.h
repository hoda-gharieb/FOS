#ifndef FOS_KERN_MONITOR_H
#define FOS_KERN_MONITOR_H
#ifndef FOS_KERNEL
# error "This is a FOS kernel header; user programs should not #include it"
#endif

// Function to activate the kernel command prompt
void run_command_prompt();

// Declaration of functions that implement command prompt commands.
int command_help(int , char **);
int command_kernel_info(int , char **);
int command_calc_space(int number_of_arguments, char **arguments);
int command_run_program(int argc, char **argv);
int command_allocpage(int , char **);
int command_free_page(int , char **);
int command_free_table(int , char **);
int command_writeusermem(int , char **);
int command_readusermem(int , char **);
int command_meminfo(int , char **);

//Lab4.Hands.On
//=============
int command_show_mapping(int number_of_arguments, char **arguments);
int command_set_permission(int number_of_arguments, char **arguments);
int command_share_pa(int number_of_arguments, char **arguments);

//Lab4.assignment
//=============
int connect_va(int number_of_arguments, char **arguments);
int show_mappings(int number_of_arguments, char **arguments);
int cut_paste_page(int number_of_arguments, char **arguments);
int remove_table(int number_of_arguments, char **arguments);
int share_4M_readonly(int number_of_arguments, char **arguments);
int alloc_user_mem(int number_of_arguments, char **arguments);
int copy_page(int number_of_arguments, char **arguments);
int num_pages_in_table(int number_of_arguments, char **arguments);
int free_chunck(int number_of_arguments, char **arguments);
int create_tables_only(int number_of_arguments, char **arguments);

//lab6 hands 0n
//============
//Lab6.Hands.On
//=============
int command_run(int , char **);
int command_kill(int , char **);
#endif	// !FOS_KERN_MONITOR_H
