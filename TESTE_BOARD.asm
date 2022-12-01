.data
	tab:        .asciiz " 1 | 2 | 3 \n---|---|---\n 4 | 5 | 6\n---|---|---\n 7 | 8 | 9\n"
	char_X:     .byte 'X'
	char_O:     .byte 'O'
	array:		
				.align 2
				.space 36
				
.text

.globl main
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
	jal draw_board
	
draw_board:
	la $a0, tab
	#a1 -> indice
	li $a1, 1 
	li $t3, 10
	lb $t0, char_O 
	
	loop:
		bgt $s1, 10, out
		add $t1, $s0, $s1 # t1 -> tab[i] 
		sb $t0, ($t1) #tab[i] -> char
		addi $s1, $s1, 4
		j loop
		
	out:	
		move $s1, $zero
		li $t0, 56
		print_tab:
			li $v0, 4
			la $s0, tab
			syscall
			
		jr $ra
		
exit:
    addi $v0, $0, EXIT
    syscall 