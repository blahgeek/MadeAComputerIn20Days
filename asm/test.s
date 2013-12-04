_start:
    lui $s1, 0x8000
    addiu $s1, $s1, 0x8000
    mtc0 $s1, $15  # EBASE

    or $s1, $zero, $zero
    sw $zero, 0($s1)  # exception here

    lui $s1, 0xBFD0
    li $s2, 0xf
    sw $s2, 0($s1)
