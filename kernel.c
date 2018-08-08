#include "print.h"
#include "screen.h"
#include "getch.h"

void main(void)
{
	char title[] = "\n>>> Hello World!\n";
    clear_screen();
    print(title);
    putchar(getch());
    for(;;);
}