#ifndef FOS_KERN_MONITOR_H
#define FOS_KERN_MONITOR_H
#ifndef FOS_KERNEL
#error "This is a FOS kernel header; user programs should not #include it"
#endif

// Function to activate the kernel command prompt
void run_command_prompt();
int execute_command(char *command_string);
void read_string(char *line);

// Declaration of functions that implement command prompt commands.
int command_help(int , char **);
int command_kernel_info(int , char **);
int comm_kernel_version (int , char **);
int comm_add (int , char **);
int command_rep (int , char **);
int command_like (int , char **);
int batch_create (int , char **);
int batch_execute (int , char **);


// 2nd lab
int command_wm(int , char **);
int command_rm(int , char **);
int command_readBlock(int, char **);
int command_createIntArr( int, char **);
int set_element_in_array( int, char **);
int find_in_array( int, char **);
int write_block(int, char**);
int new(unsigned char** , int );
int delete(unsigned char** );
int check_new_delete( int, char **);
int command_search( int, char **);
#endif	// !FOS_KERN_MONITOR_H
