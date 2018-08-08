#include "screen.h"

void print(char *format)
{
	while (*format != '\0')
	{
		putchar(*format);
		format++;
	}
}