
	li $v0, 0x3
	syscall

	add $a1, $zero, $v0
	or $a0, $zero, $zero
	lui $a3, 0x1f

loop0:
	or $a2, $zero, $zero
loop1:
	addiu $a2, $a2, 0x1
	bne $a2, $a3, loop1
	nop
	addiu $a0, $a0, 0x1
	li $v0, 0x5
	syscall
	lui $v0, 0xbfd0
	sw $a0, 0($v0)
	bne $a0, $a1, loop0
	nop
	jr $ra	
	nop