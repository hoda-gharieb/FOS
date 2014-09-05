// fib
#include <inc/lib.h>


int fib( int n)
{
	if( n == 0 || n == 1)
		return n;
	return fib(n-1)+fib(n-2);
}
void
_main(void)
{
	int n = 0;
	char c[10];
	while(  n != -1)
	{
		readline("Enter Fib Index (-1 for exit): ",c);
		n = strtol(c,NULL,10);
		if( n == -1 )
			break;
		//int *x = malloc(sizeof(int)*(n+2)) ;
		//int x[ 50 ];
		//cprintf("done");
		int i;
		//x[ 0 ]= 0; x[ 1 ] = 1;
		//for( i = 2 ; i<= n ; i++)
			//x[ i ] = x[ i -1 ] + x[ i-2 ];
		cprintf("Fib of %d = %d\n", n, fib(n));
	}
}
