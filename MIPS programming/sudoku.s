.data
newline:.asciiz "\n"		# useful for printing commands
star:	.asciiz "*"
board1: .word 128 511 511 16 511 511 4 2 511 64 511 4 1 511 511 8 511 511 1 2 511 511 511 256 511 511 128 32 16 511 511 256 4 511 128 511 511 256 511 511 511 511 511 1 511 511 128 511 32 2 511 511 256 4 2 511 511 8 511 511 511 32 64 511 511 32 511 511 128 1 511 2 511 64 8 511 511 32 511 511 16
board2: .word 128 8 256 16 32 64 4 2 1 64 32 4 1 128 2 8 16 256 1 2 16 4 8 256 32 64 128 32 16 1 64 256 4 2 128 8 4 256 2 128 16 8 64 1 32 8 128 64 32 2 1 16 256 4 2 1 128 8 4 16 256 32 64 16 4 32 256 64 128 1 8 2 256 64 8 2 1 32 128 4 16
	
.text
# main function
main:
	sub  	$sp, $sp, 4
	sw   	$ra, 0($sp) # save $ra on stack

	# test singleton (true case)
	li	$a0, 0x010
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1

	# test singleton (false case)
	li	$a0, 0x10b
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# test get_singleton 
	li	$a0, 0x010
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 4

	# test get_singleton 
	li	$a0, 0x008
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 3

	# test board_done (true case)
	la	$a0, board2
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1
	
	# test board_done (false case)
	la	$a0, board1
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# print a newline
	li	$v0, 4
	la	$a0, newline
	syscall	

	# test print_board
	la	$a0, board1
	jal	print_board

	# should print the following:
	# 8**5**32*
	# 7*31**4**
	# 12***9**8
	# 65**93*8*
	# *9*****1*
	# *8*62**93
	# 2**4***67
	# **6**81*2
	# *74**6**5

	lw   	$ra, 0($sp) 	# restore $ra from stack
	add  	$sp, $sp, 4
	jr	$ra

print_int_and_space:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element

	li   	$a0, 32        	# print a black space (ASCII 32)
	li   	$v0, 11        	# load the syscall option for printing chars
	syscall              	# print the char
	
	jr      $ra          	# return to the calling procedure

print_newline:
	li	$v0, 4		# at the end of a line, print a newline char.
	la	$a0, newline
	syscall	    
	jr	$ra

print_star:
	li	$v0, 4		# print a "*"
	la	$a0, star
	syscall
	jr	$ra
	
	
# ALL your code goes below this line.
#
# We will delete EVERYTHING above the line; DO NOT delete 
# the line.
#
# ---------------------------------------------------------------------
	
## bool singleton(int value) {  // This function checks whether
##   return (value != 0) && !(value & (value - 1));
## }
singleton:
	li $v0, 0  #false = 0
	beq $a0, false_bool
	li $t2, 1
	sub $t0, $a0, $t2 
	and $t1, $t0, $a0 
	beqz $t1 , true_bool 
false_bool:
	j exit_bool
true_bool:
	addi $v0, $0, 1 #true = 1
exit_bool:
	
	jr	$ra


## int get_singleton(int value) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 if (value == (1<<i)) {
## 		return i;
## 	 }
##   }
##   return 0;
## }

get_singleton:
	li $t0, -1 
	li $t1, 1 
	li $t2, 9 #$t2 = GRID_ SQUARED[9]
	li $v0, 0 

loop_state: 
	add $t0, $t0, 1 #increment i
	sllv $t3, $t1, $t0 
	beq $a0, $t3, return_index
	beq $t0, $t2, exit_state
	j loop_state #jump 
return_index:
	add $v0, $0, $t0 
exit_state: jr	$ra


## bool
## board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		if (!singleton(board[i][j])) {
## 		  return false;
## 		}
## 	 }
##   }
##   return true;
## }

board_done:
	li $v0, 1 
	li $s0, -1 
	li $s1, 0 
	li $s2, 9 
	add $s3, $a0, $0 #Save add
	add $s4, $ra, $0 #Save return 

loop_j:

	beq  $s1, $s2, loop_i 
	mul $t2, $s2, $s0 # $t2 = 9i 
	add $t0, $0, $t2 
	add $t0, $t0, $s1 
	li $t3, 4
	mul $t0, $t0, $t3 
	add $t0, $s3, $t0 
	lw $a0, ($t0)
 
	jal singleton

	beqz $v0, boolean_body
	add $s1, $s1, 1 #j++
	j loop_j 


loop_i:

	add $s0, $s0, 1 #i++
	bgt $s0, $s2, exit_body 


boolean_body:

	add $v0, $0, $0 

exit_body:
	add $ra, $0, $s4 #Restore 
	jr	$ra
	
## void
## print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		int value = board[i][j];
## 		char c = '*';
## 		if (singleton(value)) {
## 		  c = get_singleton(value) + '1';
## 		}
## 		printf("%c", c);
## 	 }
## 	 printf("\n");
##   }
## }

print_board:
	li $v0, 1 #Return 
	li $s0, -1 
	li $s1, 0 
	li $s2, 9 
	add $s3, $a0, $0 
	add $s4, $ra, $0 

j_loop:

	beq $s1, $s2, i_loop 
	mul $t2, $s2, $s0 
	add $t0, $0, $t2 
	add $t0, $t0, $s1 
	li $t3, 4
	mul $t0, $t0, $t3 
	add $s5, $s3, $t0 
	lw $a0, ($s5) 
	jal singleton
	beqz $v0, print_pb
	lw $a0, ($s5) 
	jal get_singleton
	addi $a0, $v0, 1 
	jal print_int_and_space
	j loop_conditions 


i_loop:

	jal print_newline
	add $s0, $s0, 1 #i++
	beq $s0, $s2, exit_printboard 
	add $s1, $0, $0 #Reset j 

print_pb:

	jal print_star
	jal print_space

loop_conditions:

	add $s1, $s1, 1 #j++
	j j_loop #Jump 


exit_printboard:

	add $ra, $0, $s4 #Restore 
	jr	$ra

