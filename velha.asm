# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que serão usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N é o número de registradores não temporários que a função altera.

.data


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

    subi $sp, $sp, 18
    lw $fp, 18($sp)

    la, $s0, 9($sp)
    move $a0, $s0
    jal clear
    la, $s1, 18($sp)
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

