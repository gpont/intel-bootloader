OBJ_FILES = \
	kernel.o \
	common/print.o \
	common/screen.o \
	common/getch.o
CFLAGS    = -Iinclude -Wall -fno-builtin -nostdinc -nostdlib -masm=intel


all: system.bin disk.img boot.bin
	dd if=boot.bin of=disk.img conv=notrunc
	dd if=system.bin bs=512 seek=1 of=disk.img conv=notrunc

disk.img:
	dd if=/dev/zero of=disk.img bs=1024 count=1440

system.bin: $(OBJ_FILES) kernel_starter.o
	ld --oformat binary -Ttext 0x200000 -o system.bin kernel_starter.o $(OBJ_FILES)

kernel_starter.o: kernel_starter.asm
	nasm -felf -o kernel_starter.o kernel_starter.asm

boot.bin: boot.asm
	nasm -fbin -o boot.bin boot.asm

.c.o:
	gcc $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(OBJ_FILES) system.bin boot.bin kernel_starter.o

run:
	qemu -fda disk.img -boot a -no-reboot

start:
	clear
	make clean
	make
	make clean
	make run
	rm -rf disk.img
