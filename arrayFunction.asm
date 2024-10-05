# arrayFunction.asm
       .data 
array: .word 8, 2, 1, 6, 9, 7, 3, 5, 0, 4
newl:  .asciiz "\n"

       .text
main:
	# Print the original content of array
	
	## setup the parameter(s)
	la $a0, array
	li $a1, 10

	## call the printArray function
	jal	printArray

	# Ask the user for two indices
	li   $v0, 5         	# System call code for read_int
	syscall           
	addi $t0, $v0, 0    	# first user input in $t0
 
	li   $v0, 5         	# System call code for read_int
	syscall           
	addi $t1, $v0, 0    	# second user input in $t1

	# Call the findMin function

	## setup the parameter(s)
	la $a0, array			# Just in case
	la $a1, array

	sll $t0, $t0, 2			# $t0 *= 4
	sll $t1, $t1, 2			# $t1 *= 4

	add $a0, $a0, $t0		# $a0 += $t0 ($a0 = &A[X])
	add $a1, $a1, $t1		# $a1 += $t1 ($a1 = &A[Y])

	## call the function
	jal	findMin

	# Print the min item

	## place the min item in $t3 for printing
	lw   $t3, 0($v0)	# $t3 is the current item
	addi $t7, $v0, 0	# Store address of min val in $t7 for later

	## Print an integer followed by a newline
	li   $v0, 1   		# system call code for print_int
    addi $a0, $t3, 0    # print $t3
    syscall       		# make system call

	li   $v0, 4   		# system call code for print_string
    la   $a0, newl    	# print "\n"
    syscall       		# print newline

	# Calculate and print the index of min item
	
	## Place the min index in $t3 for printing
	la $t6 array		# Store address of array in $t6

	sub $t7, $t7, $t6	# Get address diff

	srl $t3, $t7, 2	# $t3 = $t7 / 4

	## Print the min index

	### Print an integer followed by a newline
	li   $v0, 1   		# system call code for print_int
    addi $a0, $t3, 0    # print $t3
    syscall       		# make system call
	
	li   $v0, 4   		# system call code for print_string
    la   $a0, newl    	# 
    syscall       		# print newline
	
	# End of main, make a syscall to "exit"
	li   $v0, 10   		# system call code for exit
	syscall	       		# terminate program
	

#######################################################################
###   Function printArray   ### 
#Input: Array Address in $a0, Number of elements in $a1
#Output: None
#Purpose: Print array elements
#Registers used: $t0, $t1, $t2, $t3
#Assumption: Array element is word size (4-byte)
printArray:
	addi $t1, $a0, 0	# $t1 is the pointer to the item
	sll  $t2, $a1, 2	# $t2 is the offset beyond the last item
	add  $t2, $a0, $t2 	# $t2 is pointing beyond the last item
l1:	
	beq  $t1, $t2, e1
	lw   $t3, 0($t1)	# $t3 is the current item
	li   $v0, 1   		# system call code for print_int
    addi $a0, $t3, 0   	# integer to print
    syscall       		# print it
	addi $t1, $t1, 4
	j    l1				# Another iteration
e1:
	li   $v0, 4   		# system call code for print_string
    la   $a0, newl    	# 
    syscall       		# print newline
	jr   $ra			# return from this function


#######################################################################
###   Student Function findMin   ### 
#Input: Lower Array Pointer in $a0, Higher Array Pointer in $a1
#Output: $t4 contains the address of min item 
#Purpose: Find and return the minimum item between $a0 and $a1 (inclusive)
#Registers used: $t4, $t5, $t6 (shld be can use $t0 - $t3 but just in case)
#Assumption: Array element is word size (4-byte), $a0 <= $a1
findMin:
	li $t4, 2147483647		# Load INT_MAX into $t4

LoopStart:
	slt $t6, $a1, $a0		# $t6 = $a1 < $a0

	bne $t6, $0, LoopEnd	# Goto LoopEnd if $a1 < $a0 ($a0 > $a1)

	lw $t5, 0($a0)			# Load curr element of A into $t5

	slt $t6, $t5, $t4		# $t5 = $t5 < $t4

	beq $t6, $0, LoopUpdate

	addi $t4, $t5, 0		# $t4 = $t5 since $t5 contains new min val
	addi $v0, $a0, 0		# $v0 = $a0 since $a0 contains address of new min val

LoopUpdate:
	addi $a0, $a0, 4		# $a0 += 4

	j LoopStart				# LoopBack

LoopEnd:
	jr $ra					# return from this function