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
char_dash:      .byte   '-'
char_vertical:  .byte   '|'
char_underline: .byte   '_'

mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_2:         .byte   0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
mask_3:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_4:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_5:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_6:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_7:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_8:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

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
    # $s0: byte[12] -> Vetor X
    # $s1: byte[12] -> Vetor O
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


# Limpa um vetor de 12 bytes para 0
# $a0: byte[12]
clear:
    #
    # $s0 -> i
    #
    # Prólogo
    subi $sp, $sp, 4
    sw $s0, 0($sp) 
    #
    addi $s0, $0, 0
    addi $t0, $0, 12
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
# $a0 -> byte[12]
# $v0 -> 1 se sim, 0 se não
check_winner:
    #
    # $s0 -> i
    # $s1 -> n
    # $ra
    #
    # Prólogo
    subi $sp, $sp, 12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    #

    addi $s0, $0, 0
    addi $s1, $0, 8
    l1:
        beq $s0, $s1, e1

        addi $t0, $0, 12
        mul $t0, $s0, $t0
        add $t0, $a0, $t0
        
        la $a1, 0($t0)
        jal check
        bne $v0, $0, ret

        addi $s0, $s0, 1
        j l1
    e1:
    j ret

    # a0 -> byte[12]
    # a1 -> mask
    check:
        #
        # $s0 -> i
        #
        # Prólogo
            subi $sp, $sp, 4
            sw $s0, 0($sp)
        #

            addi $s0, $0, 0 
            addi $t0, $0, 4
            addi $v0, $0, 1
            l2:
                beq $s0, $t0, e2

                addi $t1, $0, 4
                mult $t1, $t1, $s0 # <- i * 4

                addi $t2, $t1, $a0
                lw $t2, 0($t2) # <- Word vetor

                la $t3, 0($a1)
                add $t3, $t3, $t1
                lw $t3, 0($t3) # <- Word máscara

                and $t1, $t2, $t3
                bne $t1, $t3, neq

                addi $s0, $s0, 1
                j l2

                neq:
                    addi $v0, $0, 0
                    j e2

            e2:
                # Epílogo
                lw $s0, 0($sp)
                addi $sp, $sp, 4
                #
                jr $ra
    
    ret:
        # Epílogo
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $ra, 8($sp)
        addi $sp, $sp, 12
        #
        jr $ra


# Recebe e valida o movimento do jogador.
# a0: byte[9]
# a1: byte[9]
move_player:


# Gera o movimento da inteligência aritificial.
# a0: byte[9]
# a1: byte[9]
move_ai: