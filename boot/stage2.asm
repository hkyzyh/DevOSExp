[org 0x10000]
[bits 32]

section .text

stage2_main:

    cli

    mov edi, 0x1000
    xor eax, eax
    mov ecx, (4096 * 3) / 4
    rep stosd


    mov edi, 0x1000
    mov eax, 0x2000 | 0x3
    mov dword [edi], eax

    mov edi, 0x2000
    mov eax, 0x3000 | 0x3
    mov dword [edi], eax

    mov edi, 0x3000
    mov eax, 0x00000000 | 0x83
    mov dword [edi], eax

    mov eax, 0x1000
    mov cr3, eax

    mov eax, cr4
    or  eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or  eax, 1 << 8
    wrmsr

    mov eax, cr0
    or  eax, 1 << 31
    mov cr0, eax

    lgdt [gdt64_ptr]

    jmp 0x08:long_mode_entry


[bits 64]

long_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov rsp, 0x90000

.hang:
    hlt
    jmp .hang

section .data
align 16

gdt64:
    dq 0x0000000000000000

.code64:
    dq 0x00209A0000000000

.data64:
    dq 0x0000920000000000

gdt64_ptr:
    dw $ - gdt64 - 1                    ; GDT 限长（16 位）
    dq gdt64                            ; GDT 基址（64 位，注意是 dq）