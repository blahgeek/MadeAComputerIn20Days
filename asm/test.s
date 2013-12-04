
    lui $t1, 0xbfd0
    li $t2, 0
    li $t3, 0xf
    lui $t8, 0xf
begin:
    or $t9, $zero, $zero
loop:
    addiu $t9, $t9, 1
    bne $t9, $t8, loop
    nop
    sw $t2, 0($t1)
    addiu $t2, $t2, 1
    bne $t2, $t3, begin
    nop
    jr $ra
    nop
