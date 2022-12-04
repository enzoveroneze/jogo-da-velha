# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que serão usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N é o numero de registradores não temporários que a função altera.

.data
char_X:         .byte   'X'
char_O:         .byte   'O'
char_dash:      .byte   '-'
char_vertical:  .byte   '|'
char_space:     .byte   ' '
char_newline:   .byte   '\n'
str_separator:  .asciiz "\n---|---|---\n"
str_start:      .asciiz "\n\nBem vindo ao Jogo da Velha.\nDigite 1 para começar a jogar, 0 para sair. \n"
str_moves:      .asciiz "\nInsira linha e coluna para jogada: "
str_fail:       .asciiz "\nNúmeros inválidos, insira novamente."
str_tie:        .asciiz "\nPartida empatada."
str_win_X:      .asciiz "\nO jogador X venceu a partida.\n"
str_win_O:      .asciiz "\nO jogador O venceu a partida.\n"
str_end:        .asciiz "\nDeseja jogar novamente? Digite 1 para sim, 0 para não.\n\n"
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
   
    addi $s2, $0, 0
    addi $s3, $0, 9
   
    # mensagem inicial
	addi $v0, $0, PRINT_STR
	la $a0, str_start
	syscall
	
    rd1:
	addi $v0, $0, READ_INT
	syscall

    beq $v0, $0, exit
    addi $t0, $0, 1
    bne $v0, $t0, rd1

    la $a0, 0($s0)
    la $a1, 0($s1)
    jal draw_board
    
    loop:
        la $a0, 0($s0)
        la $a1, 0($s1)
		jal move_player # movimento do jogador

        la $a0, 0($s0)
		jal check_winner # confere jogada
		bne $v0, $0, win_X

        la $a0, 0($s0)
        la $a1, 0($s1)
        jal draw_board

		addi $s2, $0, 1 # i++
        beq $s2, $s3, tie_round # se i == 9: carrega mensagem empate e vai pro fim
		
        la $a0, 0($s0)
        la $a1, 0($s1)
        add $a2, $0, $s2
		jal move_ai # movimento ia

        la $a0, 0($s1)
		jal check_winner # confere jogada
        bne $v0, $0, win_O  # se venceu: carrega mesagem da vitoria O e vai pro fim

        la $a0, 0($s0)
        la $a1, 0($s1)
        jal draw_board

		addi $s2, $0, 1    # i++
        beq $s2, $s3, tie_round # se i == 9: carrega mensagem empate e vai pro fim
		
		j loop
		
		tie_round:
			addi $v0, $0, PRINT_STR
			la $a0, str_tie
			syscall

			j fim
		
		
		win_X:
			addi $v0, $0, PRINT_STR
			la $a0, str_win_X
			syscall
			j fim


        win_O:
        	addi $v0, $0, PRINT_STR
			la $a0, str_win_O
			syscall
			j fim

			
		fim:
            la $a0, 0($s0)
            la $a1, 0($s1)
            jal draw_board

			addi $v0, $0, PRINT_STR
			la $a0, str_end # pergunta se quer jogar de novo
            syscall

			addi $v0, $zero, READ_INT # recebe resposta
			syscall

         	bne $v0, $0, play_again # se t1 != 0
         	
         	addi $v0, $0, PRINT_STR
         	la $a0, str_exit

            addi $a0, $0, SUCCESS
         	j exit #deixa terminar o programa
        
         	
		play_again:
            la $a0, 0($s0)
			jal clear # chama clear nos vetores
            la $a0, 0($s1)
            jal clear

            la $a0, 0($s0)
            la $a1, 0($s1)
            jal draw_board

			addi $s2, $0, 0 # i = 0
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

    addi $v0, $0, PRINT_CHAR
    lb $a0, char_newline
    syscall
    syscall

    j ret2

    draw_line:
        .macro Put_Char (%imm)
            addi $t3, $s2, %imm

            lb $a0, char_space
            syscall

            lb $a0, char_dash
            add $t0, $s0, $t3
            lb $t0, 0($t0)
            beq $t0, $0, sk1
            jal set_X
            sk1:
            add $t0, $s1, $t3
            lb $t0, 0($t0)
            beq $t0, $0, sk2
            jal set_O
            sk2:
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

    la $a1, mask_1
    jal check
    bne $v0, $0, ret1
    la $a1, mask_2
    jal check
    bne $v0, $0, ret1
    la $a1, mask_3
    jal check
    bne $v0, $0, ret1
    la $a1, mask_4
    jal check
    bne $v0, $0, ret1
    la $a1, mask_5
    jal check
    bne $v0, $0, ret1
    la $a1, mask_6
    jal check
    bne $v0, $0, ret1
    la $a1, mask_7
    jal check
    bne $v0, $0, ret1
    la $a1, mask_8
    jal check
    bne $v0, $0, ret1
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
            addi $t0, $0, 9
            addi $v0, $0, 1
            l2:
                beq $s0, $t0, e2

                add $t2, $s0, $a0
                lb $t2, 0($t2) # <- Byte vetor

                add $t3, $s0, $a1
                lb $t3, 0($t3) # <- Byte máscara

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
    #
    # s0
    # s1
    # s2
    #
 	# Prologo
	subi $sp, $sp, 20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    #
    move $s3, $a0
    move $s4, $a1
    receive_move:
		addi $v0, $0, PRINT_STR
		la $a0, str_moves
		syscall

		addi $v0, $zero, READ_INT 
		syscall
		move $s0, $v0 #s0 -> lin

		addi $v0, $zero, READ_INT
		syscall
		move $s1, $v0 #s1 -> col

		subi $s0, $s0, 1    
		subi $s1, $s1, 1

		addi $s2, $0, 3
		bgt $s0, $s2, move_fail
		bgt $s1, $s2, move_fail
	#
		mul $s2, $s0, $s2
		add $s2, $s1, $s2
	#
		add $t0, $s2, $s3
        lb $t0, 0($t0)
        bne $t0, $0, move_fail

        add $t0, $s2, $s4
        lb $t0, 0($t0)
        bne $t0, $0, move_fail

        j accept_move
	#		
		move_fail: 
			la $a0, str_fail
			addi $v0, $0, PRINT_STR
			syscall
			j receive_move
	#		
		accept_move:
			add $t0, $s2, $s3
            addi $t1, $0, 1
            sb $t1, 0($t0)

            # Epílogo
            lw $s0, 0($sp)
            lw $s1, 4($sp)
            lw $s2, 8($sp)
            lw $s3, 12($sp)
            lw $s4, 16($sp)
            addi $sp, $sp, 20
            #
			jr $ra

# Gera o movimento da inteligência aritificial.
# a0: byte[9]
# a1: byte[9]
# a2: número da rodada
move_ai:
    #
    # $ra
    # $s0 -> $a0
    # $s1 -> $a1
    #
    # Pr�logo
    subi $sp, $sp, 36
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

    ## Gera jogada aleat�ria

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
            add $t0, $s1, $s4
            addi $t1, $0, 1
            sb $t1, 0($t0)
            j e4
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
        # Pr�logo
        subi $sp, $sp, 28
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
        addi $sp, $sp, 28
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
    addi $sp, $sp, 36
    #
    jr $ra