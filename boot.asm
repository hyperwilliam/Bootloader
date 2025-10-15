org 0x7c00
bits 16

jmp short INIT
nop

OEMLabel		db "BOOT    "	; Disk label
BytesPerSector		dw 512		; Bytes per sector
SectorsPerCluster	db 1		; Sectors per cluster
ReservedForBoot		dw 1		; Reserved sectors for boot record
NumberOfFats		db 2		; Number of copies of the FAT
RootDirEntries		dw 224		; Number of entries in root dir
					; (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors		dw 2880		; Number of logical sectors
MediumByte		db 0F0h		; Medium descriptor byte
SectorsPerFat		dw 9		; Sectors per FAT
SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
Sides			dw 2		; Number of sides/heads
HiddenSectors		dd 0		; Number of hidden sectors
LargeSectors		dd 0		; Number of LBA sectors
DriveNo			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 for floppy
VolumeID		dd 00000000h	; Volume ID: any number
VolumeLabel		db "MyBOOT     "; Volume Label: any 11 chars
FileSystem		db "FAT12   "	; File system type: don't change!

INIT:
   xor ax, ax
   mov ds, ax
   cld
   mov ah, 00h
   mov al, 03h
   int 10h
   mov si, msg
   call bios_print
   in al, 0x92
   or al, 2
   out 0x92, al
   lgdt [gdt_descriptor]

   cli
   nop
   mov eax, cr0
   or eax, 1
   mov cr0, eax
   jmp CODE_SEG:halt


halt:
   jmp $

msg   db 'Bootloader Works, Very Good!', 13, 10, 0

; GDT, Taken From UntitledOS
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0
    
    ; Code segment descriptor
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10011010b ; Flags
    db 11001111b ; Flags + Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)
    
    ; Data segment descriptor
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
    
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                 ; GDT address

; Constants
CODE_SEG equ 0x08
DATA_SEG equ 0x10

bios_print:
   lodsb
   or al, al  ;zero=end of str
   jz done    ;GET OUT
   mov ah, 0x0E
   mov bh, 0
   int 0x10
   jmp bios_print
done:
   ret

   times 510-($-$$) db 0
   db 0x55
   db 0xAA
