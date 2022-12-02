# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que ser?o usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N ? o n?mero de registradores n?o tempor?rios que a fun??o altera.

.data
char_X:         .byte   'X'
char_O:         .byte   'O'
char_dash:      .byte   '-'
char_vertical:  .byte   '|'
char_space:     .byte   ' '
str_separator:  .asciiz "\n---|---|---\n"
str_moves:      .asciiz "\nInsira linha e coluna para jogada: "
str_fail:       .asciiz "\nN?meros inv?lidos, insira novamente."

mask_1:         .byte   1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_2:         .byte   0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
mask_3:         .byte   0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
mask_4:         .byte   1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0
mask_5:         .byte   0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0
mask_6:         .byte   0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0
mask_7:         .byte   1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
mask_8:         .byte   0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0

.text 
.globl  main

.eqv    PRINT_INT   1
.eqv    PRINT_STR   4
.eqv    PRINT_CHAR  11
.eqv    READ_INT    5
.eqv    READ_STR    8
.eqv    READ_CHAR   12
.eqv    TIME        30
.eqv    SET_SEED    40
.eqv    RAND_INT    42
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
# $a0: C?digo de sa?da
exit:
    addi $v0, $0, EXIT
    syscall


# Limpa um vetor de 12 bytes para 0
# $a0: byte[12]
clear:
    #
    # $s0 -> i
    #
    # Pr?logo
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
    # Ep?logo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #
    jr $ra


# Desenha o estado atual do tabuleiro
# $a0 -> byte[9]
# $a1 -> byte[9]
draw_board:
    #
    # $s0
    #
    # Pr?logo
    subi $sp, $sp, 4
    sw $s0, 0($sp)
    #
    #
    l3:           
        addi $a0, $t0, $zero  
        syscall
        li $t0, 4
        la $t0, char_space
        li $t1, 4
        la $t1, char_vertical
        #
	l4:
		bgt $s1, 12, l5
		addi $s1, $s1, 4
		j loop
		#
	l5:	
		move $s1, $zero
		li $t1, 56
		print:
			li $v0, 4
			la $s0, str_separator
			syscall
		#	
		jr $ra
    # $a3 = 0
    # desenha linha
    # desenha separador
    # a3 = 3
    # desenha linha
    # desenha separador
    # a3 = 6
    # desenha linha

    # (desenha linha deslocando pelo valor em $a3)
    #desenha linha:
        # la $v0, char_dash

    # Ep?logo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #


# Verifica se o jogador venceu a partida.
# $a0 -> byte[12]
# $v0 -> 1 se sim, 0 se n?o
check_winner:
    #
    # $s0 -> i
    # $s1 -> n
    # $ra
    #
    # Pr?logo
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
        # Pr?logo
            subi $sp, $sp, 4
            sw $s0, 0($sp)
        #

            addi $s0, $0, 0 
            addi $t0, $0, 4
            addi $v0, $0, 1
            l2:
                beq $s0, $t0, e2

                sll $t1, $s0, 2 # <- i * 4

                add $t2, $t1, $a0
                lw $t2, 0($t2) # <- Word vetor

                la $t3, 0($a1)
                add $t3, $t3, $t1
                lw $t3, 0($t3) # <- Word m?scara

                and $t1, $t2, $t3
                bne $t1, $t3, neq

                addi $s0, $s0, 1
                j l2

                neq:
                    addi $v0, $0, 0
                    j e2

            e2:
                # Ep?logo
                lw $s0, 0($sp)
                addi $sp, $sp, 4
                #
                jr $ra
    
    ret:
        # Ep?logo
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
 	# Pr?logo
	subi $sp, $sp, 4
   	sw $s0, 0($sp)
    #
    #t1 -> lin
    la $t0, str_fail
	addi $v0, $0, PRINT_STR
	addi $v0, $zero, READ_INT 
	syscall
	move $v0, $s1
	#t2 -> col
	addi $v0, $zero, READ_INT
	syscall
	move $v0, $s2
	sub $s1, $s1, 1    
	sub $s2, $s2, 1
	li $s3, 3
	bgt $s1, $s3, move_fail
	bgt $s2, $s3, move_fail
	
	mul $t3, $t1, $t3
	add $t3, $t3, $t2
		
	bne $a0($t3), $0, accept_move			
		
	move_fail: 
		la $t0, str_fail
		addi $v0, $0, PRINT_STR
		j move_player
			
	accept_move:
		lw $t3, 0($a0)      # $t3 = x[i], carregando o elemento do índice i      
		addi $t3, $zero, 1  # somando os elementos (x[i] = 0+ 1
		jr $ra
		
	#Epilogo
	lw $s0, 0($sp)
	addi $sp, $sp, 4


# Gera o movimento da intelig?ncia aritificial.
# a0: byte[9]
# a1: byte[9]
move_ai:
