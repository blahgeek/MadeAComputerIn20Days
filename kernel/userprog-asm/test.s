
addiu $a0, $zero, 0xDEAD
lui $v0, 0x1
lui $v1, 0xBFD0

sw $zero, 0($v0)

sb $a0, 0($v0)
nop
nop
lw $a1, 0($v0)
sw $a1, 8($v1)
nop
nop
sw $a0, 8($v1)
