# $b0 - Multiplicand
	# $b1 - Multiplier
	# $v0 - Result
	# $t0 - The right bit
	# $t1 - The LSB of the multiplier

	li $v0, 0	# Initialize the result register
	li $t0, 1	# Initialize the mask 
	li $t1, 0	# Initialize the LSB result

	Multiplication_loop:
		beq $b1, $zero, Multiplication_end	# end if multiplier is 0
		and $t1, $t0, $b1			# Retrieve the LSB
		beq $t1, 1, Multiplication_add	# If the LSB is not zero add the multiplicand to the result
		beq $t1, 0, Multiplication_shift	# If the LSB is zero , shift

		Multiplication_add: 
			addu $v0, $v0, $b0		

		Multiplication_shift:
			sll $b0, $b0, 1			# Shift left  multiplicand
			srl $b1, $b1, 1			# Shift right  multiplier

		j Multiplication_loop			# jump back to loop

	Multiplication_end:
		jr $ra					# Return result in $v0 register