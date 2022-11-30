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
    # fp
    # $s0 -> i
    #
    # Prólogo
    subi $sp, $sp, 8
    sw $fp, 8($sp)
    sw $s0, 4($sp) 
    la $fp, 8($sp) 
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
    addi $sp, $sp, 8
    #
    jr $ra

