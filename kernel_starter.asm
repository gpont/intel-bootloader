BITS 32
EXTERN main
GLOBAL _start
_start:
	mov esp, 0x200000-4
	jmp main