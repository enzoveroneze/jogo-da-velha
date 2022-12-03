# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que ser?o usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N eh o numero de registradores nao temporarios que a funcao altera.

.data
char_X:         .byte   'X'
char_O:         .byte   'O'
char_dash:      .byte   '-'
char_vertical:  .byte   '|'
char_space:     .byte   ' '
str_separator:  .asciiz "\n---|---|---\n"
str_start:      .asciiz "\n\nBem vindo ao jogo da velha.\nDigite 1 para começar a jogar. \n"
str_moves:      .asciiz "\nInsira linha e coluna para jogada: "
str_fail:       .asciiz "\nNumeros invalidos, insira novamente."
str_tie:        .asciiz "\nPartida empatada."
str_win:        .asciiz "\nO ultimo jogador venceu a partida."
str_end:        .asciiz "\nDeseja jogar novamente? Digite 1 para sim, 0 para nao.\n\n"
str_exit:       .asciiz "\nJogo finalizado."

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
    la, $s0, 0($sp)
    move $a0, $s0
    jal clear
    la, $s1, 12($sp)
    move $a1, $s1
    jal clear
   
   	li $s2, 0
    li $s3, 9
   
    # mensagem inicial
	addi $v0, $zero, PRINT_STR
	la $a0, str_start
	syscall
	
	addi $v0, $zero, READ_INT
	syscall

    jal draw_board
    
    loop:
    	beq $s2, $s3, tie_round # se i == 9: carrega mensagem empate e vai pro fim
		jal move_player # movimento do jogador
		jal check_winner # confere jogada
		bne $v0, $0, win
		addi $s2, $0, 1 # i++
		
		jal move_ai # movimento ia
		jal check_winner # confere jogada
		addi $s2, $0, 1    # i++
		bne $v0, $0, win  # se venceu: carrega mesagem da vitoria O e vai pro fim
		
		j loop
		
		tie_round:
			addi $v0, $0, PRINT_STR
			la $a0, str_tie
			syscall
			jal draw_board # mostra tabuleiro
			j fim
		
		
		win:
			addi $v0, $0, PRINT_STR
			la $a0, str_win
			syscall
			jal draw_board
			j fim
		
			
		fim:
			addi $v0, $0, PRINT_STR
			la $a0, str_end # pergunta se quer jogar de novo
			addi $v0, $zero, READ_INT # recebe resposta
			syscall
			move $t1, $v0 
			
         	bne $t1, $0, play_again # se t1 != 0
         	
         	addi $v0, $0, PRINT_STR
         	la $a0, str_exit
         	j exit #deixa terminar o programa
        
         	
		play_again:
			jal clear # chama clear nos vetores
			li $s2, 0 # i = 0
			j loop 
		
		
    addi $a0, $0, SUCCESS
    j exit

    
# Encerra o programa
# $a0: Codigo de saida
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
    # Epilogo
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    #
    jr $ra


# Desenha o estado atual do tabuleiro
# $a0 -> byte[9]
# $a1 -> byte[9]

draw_board:
    #
    # $s0 -> a0
    # $s1 -> a1
    # $s2 -> Linha
    # ra
    #
    # Prologo
    subi $sp, $sp, 16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    #

    addi $s2, $0, 0
    jal draw_line
    addi $v0, $0, PRINT_STR
    la $a0, str_separator
    syscall

    addi $s2, $0, 3
    jal draw_line
    addi $v0, $0, PRINT_STR
    la $a0, str_separator
    syscall

    addi $s2, $0, 6
    jal draw_line

    j ret2

    draw_line:
        .macro Put_Char (%imm)
            addi $t3, $s2, %imm

            lb $a0, char_space
            syscall

            lb $a0, char_dash
            add $t0, $s0, $t3
            lb $t0, 0($t0)
            bne $t0, $0, set_X
            add $t0, $s1, $t3
            lb $t0, 0($t0)
            bne $t0, $0, set_O
            syscall

            lb $a0, char_space
            syscall
        .end_macro
        #
        # ra
        #
        # Prologo
        subi $sp, $sp, 4
        sw $ra, 0($sp)
        #

        addi $v0, $0, PRINT_CHAR

        Put_Char(0)

        lb $a0, char_vertical
        syscall 

        Put_Char(1)

        lb $a0, char_vertical
        syscall

        Put_Char(2)

        j ret3

        set_X:
            lb $a0, char_X
            jr $ra

        set_O:
            lb $a0, char_O
            jr $ra

        ret3:
        # Epilogo
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        #
        jr $ra

    ret2:
    # Epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    #
    jr $ra

# Verifica se o jogador venceu a partida.
# $a0 -> byte[12]
# $v0 -> 1 se sim, 0 se nao
check_winner:
    #
    # $s0 -> i
    # $s1 -> n
    # $ra
    #
    # Prologo
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
      	bne $v0, $0, ret1

        addi $s0, $s0, 1
        j l1
    e1:
    j ret1

    # a0 -> byte[12]
    # a1 -> mask
    check:
        #
        # $s0 -> i
        #
        # Prologo
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
                lw $t3, 0($t3) # <- Word mascara

                and $t1, $t2, $t3
                bne $t1, $t3, neq

                addi $s0, $s0, 1
                j l2

                neq:
                    addi $v0, $0, 0
                    j e2

            e2:
                # Epilogo
                lw $s0, 0($sp)
                addi $sp, $sp, 4
                #
                jr $ra
    
    ret1:
        # Epilogo
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
 	# Prologo
	subi $sp, $sp, 4
   	sw $s0, 0($sp)
    #
    receive_move:
		addi $v0, $0, PRINT_STR
		la $t0, str_moves
		syscall
		addi $v0, $zero, READ_INT 
		syscall
		move $s1, $v0 #s1 -> lin
		addi $v0, $zero, READ_INT
		syscall
		move $s2, $v0 #s2 -> col
		subi $s1, $s1, 1    
		subi $s2, $s2, 1
		li $s3, 3 
		bgt $s1, $s3, move_fail
		bgt $s2, $s3, move_fail
	#
		mul $s3, $s1, $s3
		add $s3, $s3, $s2
	#
		bne $s3, $0, accept_move			
	#		
		move_fail: 
			la $a0, str_fail
			addi $v0, $0, PRINT_STR
			syscall
			j receive_move
	#		
		accept_move:
			#li 
			lb $s4, 0($s3)      # $s3 = x[i], carregando o elemento do ?ndice i      
			addi $s4, $zero, 1  # somando os elementos (x[i] = 0+ 1
			jr $ra
	#	
	#Epilogo
	lw $s0, 0($sp)
	addi $sp, $sp, 4

# Gera o movimento da intelig?ncia aritificial.
# a0: byte[9]
# a1: byte[9]
# a2: número da rodada
move_ai:
    #
    # $ra
    # $s0 -> $a0
    # $s1 -> $a1
    #
    # Prólogo
    subi $sp, $0, 36
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 12($sp)
    sw $s2, 16($sp)
    sw $s3, 20($sp)
    sw $s4, 24($sp)
    sw $s5, 28($sp)
    sw $s6, 32($sp)
    #
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    move $a2, $s1
    jal simulate
    bne $v0, $0, ret4

    move $a2, $s0
    jal simulate
    bne $v0 $0, ret4

    ## Gera jogada aleatória

    addi $v0, $0, TIME
    syscall
    move $t0, $a0

    addi $v0, $0, SET_SEED
    addi $a0, $0, 0
    move $a1, $t0
    syscall
    
    addi $t0, $0, 10
    sub $t0, $t0, $s2
    addi $v0, $0, RAND_INT
    addi $a0, $0, 0
    add $a1, $0, $t0
    syscall

    move $s3, $a0

    addi $s4, $0, 0 # <- i
    addi $s5, $0, 9
    addi $s6, $0, 0
    l4:
        beq $s4, $s5, e4
        add $t0, $s0, $s4
        lb $t0, 0($t0)
        bne $t0, $0, c4
        add $t0, $s1, $s4
        lb $t0, 0($t0)
        bne $t0, $0, c4

        beq $s6, $s3, rnd

        addi $s6, $s6, 1

        c4:
        addi $s4, $s4, 1
        j l4

        rnd:
            addi $t1, $0, 1
            sb $t1, 0($t0)
            j c4
    e4:
    j ret4


    # a0: byte[9] -> Vetor X
    # a1: byte[9] -> Vetor O
    # a2: byte[9] -> Vetor simula??o
    simulate:
        #
        # ra
        # $s0 -> a0
        # $s1 -> a1
        # $s2 -> a2
        # $s3 -> i
        # $s4 -> 9
        # $s5 -> a2 + i
        #
        # Prólogo
        subi $sp, $0, 28
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        #
        addi $s3, $0, 0
        addi $s4, $0, 9
        l3:
            beq $s3, $s4, e3
            add $t0, $s0, $s3
            bne $0, $t0, c3
            add $t0, $s1, $s3
            bne $0, $t0, c3

            add $s5, $s2, $s3
            addi $t0, $0, 1
            sb $t0, 0($s5)
            la $a0, ($s2)
            jal check_winner
            
            addi $t0, $0, 0
            sb $t0, 0($s5)
            
            beq $v0, $0, c3

            add $t0, $s1, $s3
            addi $t1, $0, 1
            sb $t1, 0($t0)
            j e3

            c3:
            addi $s3, $s3, 1
            j l3
        e3:
        addi $v0, $0, 1
        blt $s3, $s4, t3
        addi $v0, $0, 0
        t3:

        # Ep?logo
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        addi $sp, $0, 28
        #
        jr $ra

    ret4:
    # Ep?logo
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 12($sp)
    lw $s2, 16($sp)
    lw $s3, 20($sp)
    lw $s4, 24($sp)
    lw $s5, 28($sp)
    lw $s6, 32($sp)
    addi $sp, $0, 36
    #
    jr $ra
