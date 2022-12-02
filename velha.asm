# Prioridade em procedimentos:
# $a0 => Vetor X
# $a1 => Vetor O

# Stack pointer em procedimentos:
# Antes => Diminuir (4 * N) de $sp, salvar valor dos registradores que ser?o usados.
# Depois => Retornar $sp ao valor inicial, restaurar valor dos registradores.
# N é o número de registradores não temporários que a função altera.

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

    la, $s0, 0($sp)
    move $a0, $s0
    jal clear
    la, $s1, 12($sp)
    move $a1, $s1
    jal clear

    # mensagem inicial
    # contador de jogadas i = 0
    # loop:
        # se i == 9: carrega mensagem empate e vai pro fim
        # mostra tabuleiro
        # movimento do jogador
        # confere jogada
            # se venceu: carrega mensagem da vitoria X e vai pro fim
        # mostra tabuleiro
        # movimento ia
        # confere jogada
            # se venceu: carrega mesagem da vitoria O e vai pro fim
        # i++
        # jump loop
    # fim:
        # mostra mensagem do resultado
        # pergunta se quer jogar de novo
        # recebe resposta
        # se S:
            # chama clear nos vetores
            # i = 0
            # jump loop
        #deixa terminar o programa

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
    # $s0 -> a0
    # $s1 -> a1
    # $s2 -> Linha
    # ra
    #
    # Prólogo
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
        # Prólogo
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
        # Epílogo
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        #
        jr $ra

    ret2:
        # Epílogo
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $ra, 12($sp)
        addi $sp, $sp, 16
        #
        jr $ra


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
        # Prólogo
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
    
    ret1:
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
 	# Prólogo
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
		lw $t3, 0($a0)      # $t3 = x[i], carregando o elemento do �ndice i      
		addi $t3, $zero, 1  # somando os elementos (x[i] = 0+ 1
		jr $ra
		
	#Epílogo
	lw $s0, 0($sp)
	addi $sp, $sp, 4


# Gera o movimento da inteligência artificial.
# a0: byte[9]
# a1: byte[9]
move_ai:
