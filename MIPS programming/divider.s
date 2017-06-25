# $b0 - dividend
	# $b1 - divisor
	# $v0 - Result
	# $t0 - The right bit
	# $t1 - The LSB of the divisor

	li $v0, 0	# Initialize the result register
	li $t0, 1	# Initialize the rsb mask 
	li $t1, 0	# Initialize the LSB result

	division_loop:
		beq $b1, $zero, Multiplication_end	# end if divisor is 0
		and $t0, $t1, $b1			# Retrieve the RSB
		beq $t0, 1, division_subtract	# If the RSB is not zero subtract the divisor from the result
		beq $t1, 0, division_shift	# If the LSB is zero , shift

		division_subtract: 
			subu $v0, $v0, $b0		

		division_shift:
			sll $b0, $b0, 1			# Shift left  dividend
			srl $b1, $b1, 1			# Shift right  divisior

		j division_loop			# jump back to loop

	division_end:
		jr $ra					# Return result in $v0 register