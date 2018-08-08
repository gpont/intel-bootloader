; 16-битная адресация, пока мы находимся в реальном режиме
BITS 16
org 0x7c00
start:
  jmp 0x0000:entry       ; Теперь CS=0, IP=0x7c00
entry:
  mov ax, cs
  mov ds, ax
 
; Очистить экран
  mov ax, 0x0003
  int 0x10
 
; Открыть A20
  in  al, 0x92
  or  al, 2
  out 0x92, al

; Переключить видеорежим
  mov ah, 0
  mov al, 3
  int 10h

; Считать с дискеты ядро и загрузить его в память
  mov   di, kernel_boot  ; #SYSSEG = 0x100 - здесь ядро.
  mov   es, di
  xor   bx, bx
  mov   ch, 0            ; #START_TRACK - Дорожка, откуда начнем чтение.
  mov   cl, 2            ; #START_SECTOR - Сектор, начиная с которого будем считывать
  mov   dl, 0            ; #FLOPPY_ID - Идентификатор привода.
  mov   dh, 0            ; #START_HEAD - Головка привода, которою будем использовать.
  mov   ah, 2
  mov   al, 10           ; #SYSSIZE - Размер ядра в секторах (каждый сектор содержит 512 байт)
  int   0x13             ; Дисковый сервис BIOS

  jnc     next_work      ; Если во время чтения не произошло ничего плохого, то работаем дальше

  jmp $                  ; Зависаем

next_work:

; Загрузить адрес и размер GDT в GDTR
  lgdt  [gdtr]
; Запретить прерывания
  cli
; Запретить немаскируемые прерывания
  in  al, 0x70
  or  al, 0x80
  out 0x70, al

; Переключиться в защищенный режим
  mov  eax, cr0
  or   al, 1
  mov  cr0, eax

; Загрузить в CS:EIP точку входа в защищенный режим
  jmp 00001000b:pm_entry
 
; 32-битная адресация
BITS 32
; Точка входа в защищенный режим
pm_entry:

; Загрузить сегментные регистры (кроме SS)
  mov  ax, cs
  mov  ds, ax
  mov  es, ax

  jmp   kernel_boot
 
; Глобальная таблица дескрипторов.
; Нулевой дескриптор использовать нельзя!
gdt:
  db  0x00, 0x00, 0x00, 0x00, 0x00,      0x00,      0x00, 0x00 
  db  0xFF, 0xFF, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00
gdt_size  equ $ - gdt
 
; Данные, загружаемые в регистр GDTR
gdtr:
  dw  gdt_size - 1
  dd  gdt

finish:
times 0x1FE-finish+start db 0
db   0x55, 0xAA          ; Сигнатура загрузочного сектора

kernel_boot:

