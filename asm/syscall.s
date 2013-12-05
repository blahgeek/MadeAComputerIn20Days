
    li $v0, 0x3
    syscall

    addu $a0, $v0, $v0
    li $v0, 0x5
    syscall
    
    jr $ra
