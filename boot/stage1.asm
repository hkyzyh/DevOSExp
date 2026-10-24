[org 0x7c00]
[bits 16]

STAGE2_SEG equ 0x1000
STAGE2_OFF equ 0
STAGE2_LBA equ 1

_start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl

    mov ax, STAGE2_SEG
    mov es, ax
    mov bx, STAGE2_OFF

    sti

    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13

    cli

    jc  disk_error


    in al, 0x92
    or al, 2
    and al, 0xFE
    out 0x92, al

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword 0x08:protected_mode_entry

disk_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    jmp $

boot_drive: db 0

dap:
    db 0x10
    db 0
    dw 1
    dw STAGE2_OFF
    dw STAGE2_SEG
    dq STAGE2_LBA

[bits 32]
protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7C00

    jmp dword 0x08:0x10000

.hang:
    hlt
    jmp .hang

[bits 16]
gdt_start:

gdt_null:
    dq 0

gdt_code:
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

gdt_data:
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510 - ($ - $$) db 0
dw 0xAA55