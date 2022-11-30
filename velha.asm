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

    addi $a0, $0, SUCCESS
    j exit

    

# Encerra o programa
# $a0: Código de saída
exit:
    addi $v0, $0, EXIT
    syscall