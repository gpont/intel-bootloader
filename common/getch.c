char getch()
{
	char ret = 0;
	while (ret = 0)
	{
		asm("in ax, 10");
		asm("mov ret, ax");
	}
	return ret;
}