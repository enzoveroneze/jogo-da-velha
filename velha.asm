# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que serão usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N é o número de registradores não temporários que a função altera.

.data
char_X:         .byte   'X'
char_O:         .byte   'O'
char_vertical:  .byte   '|'
char_space:     .byte   ' '
str_separator:  .asciiz "\n---|---|---\n"

mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text 
.globl  main

.eqv    PRINT_INT   1
.eqv    PRINT_STR   4
.eqv    PRINT_CHAR  11
.eqv    READ_INT    5
.eqv    READ_STR    8
.eqv    READ_CHAR   12
.eqv    EXIT        17  
.eqv    SUCCESS     0
.eqv    FAILURE     1

main:
    #
    # $s0: byte[9] -> Vetor X
    # $s1: byte[9] -> Vetor O
    #

    subi $sp, $sp, 24
    la $fp, 24($sp)

    la, $s0, 0($fp)
    move $a0, $s0
    jal clear
    la, $s1, -12($fp)
    move $a0, $s1
    jal clear


    addi $a0, $0, SUCCESS
    j exit

    
# Encerra o programa
# $a0: Código de saída
exit:
    addi $v0, $0, EXIT
    syscall


# Limpa um vetor de 9 bytes para 0
# $a0: byte[9]
clear:
    #
    # $s0 -> i
    #
    # Prólogo
    subi $sp, $sp, 4
    sw $s0, 0($sp) 
    #
    addi $s0, $0, 0
    addi $t0, $0, 9
    l0:
        beq $s0, $t0, e0

        add $t1, $a0, $s0
        lb $t2, 0($t1)
        xor $t2, $t2, $t2
        sb $t2, 0($t1)

        addi $s0, $s0, 1
        j l0
    e0:
    # Epílogo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #
    jr $ra


# Desenha o estado atual do tabuleiro
# $a0 -> byte[9]
# $a1 -> byte[9]
draw_board:
    #
    # $s0 -> i
    #
    # Prólogo
    subi $sp, $sp, 4
    sw $s0, 0($sp)
    #


    # Epílogo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #

# Verifica se o jogador venceu a partida.
# $a0 -> byte[9]
# $v0 -> 1 se sim, 0 se não
check_winner:
    #
    # $s0 -> i
    # $s1 -> j
    #
    # Prólogo
    subi $sp, $sp, 4
    sw $s0, 0($sp)
    #
    addi $s0, $0, 0
    l1:
        if
    e1:



    f1:
    # Epílogo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #
