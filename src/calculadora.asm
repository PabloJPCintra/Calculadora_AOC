; ==============================================================================
; NOME DO PROJETO: Calculadora Didática em Assembly
; ARQUIVO: calculadora.asm
;
; AUTOR: Pablo José Pellegrino Cintra - Turma A
; DISCIPLINA: Infra de Hardware (AOC)
; PROFESSOR(A): Fernando Ferreira de Cavalho
;
; DESCRIÇÃO:
; O programa implementa uma calculadora didática com menu interativo para:
; 1. Conversão de Bases (10 -> 2, 8, 16, BCD) com visualização dos restos.
; 2. Complemento a 2 (16 bits) com visualização da inversão e soma.
; 3. Análise de Ponto Flutuante (IEEE 754) extraindo sinal, expoente e mantissa.
;
; ==============================================================================
; HISTÓRICO DE REVISÕES E ATUALIZAÇÕES
; ==============================================================================
; DATA       | HORA   | AUTOR      | DESCRIÇÃO DA MUDANÇA
; -----------|--------|------------|--------------------------------------------
; 11/11/2025 | 15:00  | PABLO | Criação da estrutura inicial (Main/Menu).
; 11/11/2025 | 15:15  | PABLO | Implementação da Parte 1 (Bases).
; 15/11/2025 | 23:30  | PABLO | Implementação da Parte 2 (Comp. a 2).
; 18/11/2025 | 20:00  | PABLO | Implementação da Parte 3 (Float/Double).
; ==============================================================================

section .data
    msg_menu        db 10, "=== CALCULADORA DIDATICA ASSEMBLY ===", 10
                    db "1. Conversao de Bases (10 -> 2, 8, 16, BCD)", 10
                    db "2. Complemento a 2 (16 bits)", 10
                    db "3. Ponto Flutuante (IEEE 754)", 10
                    db "0. Sair", 10
                    db "Escolha uma opcao: ", 0
    msg_invalid     db "Opcao invalida!", 10, 0
    fmt_int         db "%d", 0
    fmt_char        db "%c", 0
    msg_nl          db 10, 0

    p1_msg_in       db "Digite um numero inteiro (Base 10): ", 0
    p1_msg_bin      db 10, "--- Convertendo para Binario (Base 2) ---", 10, 0
    p1_msg_step     db "Dividindo %d por %d: Quociente = %d, Resto = %d", 10, 0
    p1_msg_oct      db 10, "--- Convertendo para Octal (Base 8) ---", 10, 0
    p1_msg_hex      db 10, "--- Convertendo para Hexadecimal (Base 16) ---", 10, 0
    p1_msg_bcd      db 10, "--- Convertendo para BCD ---", 10, 0
    p1_step_bcd     db "Digito: %d -> Binario: ", 0
    p1_hex_map      db "0123456789ABCDEF"

    p2_msg_in       db "Digite um numero (-32768 a 32767): ", 0
    p2_msg_pos      db "Positivo. Conversao direta:", 10, 0
    p2_msg_neg1     db "Negativo detectado.", 10, 0
    p2_msg_neg2     db "1. Valor absoluto binario.", 10, 0
    p2_msg_neg3     db "2. Inverter bits (NOT).", 10, 0
    p2_msg_neg4     db "3. Somar 1 (Resultado Final): ", 0
    p2_fmt_bit      db "%d", 0

    p3_msg_in       db "Digite um numero Real (ex: -12.5): ", 0
    p3_fmt_dbl      db "%lf", 0
    p3_tit_flt      db 10, "--- Float (32 bits) ---", 10, 0
    p3_tit_dbl      db 10, "--- Double (64 bits) ---", 10, 0
    p3_msg_sgn      db "Sinal: %d (%s)", 10, 0
    p3_msg_exp      db "Expoente Bruto: %d -> Com Vies: %d", 10, 0
    p3_msg_man      db "Mantissa: ", 0
    p3_pos          db "+", 0
    p3_neg          db "-", 0

section .bss
    op_menu     resd 1
    int_val     resd 1
    real_val    resq 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp

menu_loop:
    mov rdi, msg_menu
    xor rax, rax
    call printf

    mov rdi, fmt_int
    lea rsi, [op_menu]
    xor rax, rax
    call scanf

    mov eax, [op_menu]
    cmp eax, 0
    je sair_prog
    cmp eax, 1
    je call_p1
    cmp eax, 2
    je call_p2
    cmp eax, 3
    je call_p3
    
    mov rdi, msg_invalid
    xor rax, rax
    call printf
    jmp menu_loop

call_p1:
    call func_bases
    jmp menu_loop
call_p2:
    call func_comp2
    jmp menu_loop
call_p3:
    call func_float
    jmp menu_loop

sair_prog:
    leave
    ret

func_bases:
    push rbp
    mov rbp, rsp

    mov rdi, p1_msg_in
    xor rax, rax
    call printf
    mov rdi, fmt_int
    lea rsi, [int_val]
    xor rax, rax
    call scanf

    mov rdi, p1_msg_bin
    xor rax, rax
    call printf
    mov ebx, 2
    call sub_conv_base

    mov rdi, p1_msg_oct
    xor rax, rax
    call printf
    mov ebx, 8
    call sub_conv_base

    mov rdi, p1_msg_hex
    xor rax, rax
    call printf
    mov ebx, 16
    call sub_conv_base

    call sub_conv_bcd

    pop rbp
    ret

sub_conv_base:
    push rbp
    mov rbp, rsp
    mov eax, [int_val]
    xor rcx, rcx
p1_div_loop:
    xor edx, edx
    div ebx
    push rdx
    push rax
    push rdx
    push rcx
    push rax 
    mov rdi, p1_msg_step
    mov rsi, rax
    pop rax
    pop rcx
    inc rcx
    test eax, eax
    jnz p1_div_loop
p1_print_loop:
    pop rax
    cmp ebx, 16
    jl p1_pnum
    lea rsi, [p1_hex_map]
    add rsi, rax
    mov al, [rsi]
    mov rdi, fmt_char
    mov rsi, rax
    push rcx
    xor rax, rax
    call printf
    pop rcx
    jmp p1_cont
p1_pnum:
    mov rdi, fmt_int
    mov rsi, rax
    push rcx
    xor rax, rax
    call printf
    pop rcx
p1_cont:
    loop p1_print_loop
    mov rdi, msg_nl
    xor rax, rax
    call printf
    pop rbp
    ret

sub_conv_bcd:
    mov rdi, p1_msg_bcd
    xor rax, rax
    call printf
    mov eax, [int_val]
    xor rcx, rcx
    mov ebx, 10
p1_bcd_ext:
    xor edx, edx
    div ebx
    push rdx
    inc rcx
    test eax, eax
    jnz p1_bcd_ext
p1_bcd_prt:
    pop rdx
    push rcx
    push rdx
    mov rdi, p1_step_bcd
    mov rsi, rdx
    xor rax, rax
    call printf
    pop rdx
    mov rcx, 4
p1_bcd_bits:
    mov rax, rdx
    dec rcx
    bt rax, rcx
    jc p1_bset
    mov rsi, 0
    jmp p1_bprt
p1_bset:
    mov rsi, 1
p1_bprt:
    push rdx
    push rcx
    mov rdi, fmt_int
    xor rax, rax
    call printf
    pop rcx
    pop rdx
    inc rcx
    loop p1_bcd_bits
    mov rdi, msg_nl
    xor rax, rax
    call printf
    pop rcx
    dec rcx
    jnz p1_bcd_prt
    ret

    func_comp2:
    push rbp
    mov rbp, rsp

    mov rdi, p2_msg_in
    xor rax, rax
    call printf
    mov rdi, fmt_int
    lea rsi, [int_val]
    xor rax, rax
    call scanf

    mov ax, [int_val]
    test ax, ax
    js p2_negativo

    mov rdi, p2_msg_pos
    xor rax, rax
    call printf
    mov ax, [int_val]
    call sub_print_16
    jmp p2_fim

p2_negativo:
    mov rdi, p2_msg_neg1
    xor rax, rax
    call printf

    mov rdi, p2_msg_neg2
    xor rax, rax
    call printf
    mov ax, [int_val]
    neg ax
    call sub_print_16
    mov rdi, msg_nl
    xor rax, rax
    call printf

    mov rdi, p2_msg_neg3
    xor rax, rax
    call printf
    mov ax, [int_val]
    neg ax
    not ax
    call sub_print_16
    mov rdi, msg_nl
    xor rax, rax
    call printf

    mov rdi, p2_msg_neg4
    xor rax, rax
    call printf
    mov ax, [int_val]
    call sub_print_16

p2_fim:
    mov rdi, msg_nl
    xor rax, rax
    call printf
    pop rbp
    ret

sub_print_16:
    push rbp
    mov rbp, rsp
    push rbx
    mov bx, ax
    mov rcx, 16
p2_loop:
    mov ax, bx
    dec rcx
    bt ax, cx
    jc p2_one
    mov rsi, 0
    jmp p2_do
p2_one:
    mov rsi, 1
p2_do:
    push rcx
    push rbx
    mov rdi, p2_fmt_bit
    xor rax, rax
    call printf
    pop rbx
    pop rcx
    inc rcx
    loop p2_loop
    pop rbx
    pop rbp
    ret

    func_float:
    push rbp
    mov rbp, rsp

    mov rdi, p3_msg_in
    xor rax, rax
    call printf
    mov rdi, p3_fmt_dbl
    lea rsi, [real_val]
    xor rax, rax
    call scanf

    mov rdi, p3_tit_flt
    xor rax, rax
    call printf

    movsd xmm0, [real_val]
    cvtsd2ss xmm0, xmm0
    movd eax, xmm0

    mov ebx, eax
    shr ebx, 31
    mov rdi, p3_msg_sgn
    mov rsi, rbx
    cmp rbx, 1
    je p3_fneg
    lea rdx, [p3_pos]
    jmp p3_fprt
p3_fneg:
    lea rdx, [p3_neg]
p3_fprt:
    xor rax, rax
    call printf

    ; Expoente
    mov ebx, eax
    shr ebx, 23
    and ebx, 0xFF
    push rbx
    mov rdi, p3_msg_exp
    mov rsi, rbx
    pop rbx
    sub ebx, 127
    mov rdx, rbx
    xor rax, rax
    call printf

    ; Mantissa
    mov rdi, p3_msg_man
    xor rax, rax
    call printf
    mov ebx, eax
    and ebx, 0x7FFFFF
    mov rcx, 23
    call sub_bits_val
    mov rdi, msg_nl
    xor rax, rax
    call printf

    mov rdi, p3_tit_dbl
    xor rax, rax
    call printf
    mov rdx, [real_val]

    mov rbx, rdx
    shr rbx, 52
    and rbx, 0x7FF
    push rbx
    mov rdi, p3_msg_exp
    mov rsi, rbx
    pop rbx
    sub rbx, 1023
    mov rdx, rbx
    xor rax, rax
    call printf

    mov rdi, p3_msg_man
    xor rax, rax
    call printf
    mov rbx, rdx
    mov rax, 0xFFFFFFFFFFFFF
    and rbx, rax
    mov rcx, 52
    call sub_bits_val64
    mov rdi, msg_nl
    xor rax, rax
    call printf

    pop rbp
    ret

sub_bits_val:
    mov r8, rcx
p3_loop:
    mov rax, rbx
    mov rcx, r8
    dec rcx
    bt rax, rcx
    jc p3_bone
    mov rsi, 0
    jmp p3_bdo
p3_bone:
    mov rsi, 1
p3_bdo:
    push rbx
    push r8
    mov rdi, fmt_int
    xor rax, rax
    call printf
    pop r8
    pop rbx
    dec r8
    jnz p3_loop
    ret

sub_bits_val64:
    mov r8, rcx 
p3_l64:
    mov rax, rbx
    mov rcx, r8
    dec rcx
    bt rax, rcx
    jc p3_o64
    mov rsi, 0
    jmp p3_d64
p3_o64:
    mov rsi, 1
p3_d64:
    push rbx
    push r8
    mov rdi, fmt_int
    xor rax, rax
    call printf
    pop r8
    pop rbx
    dec r8
    jnz p3_l64
    ret