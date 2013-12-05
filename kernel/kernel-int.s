# put me on 0x8000

int:
    #保存用户现场
    subu $sp, $sp, 36
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)

    lui $s1, 0xBFD0
    li $s2, 0xE
    sw $s2, 0($s1)
    sw $s2, 4($s1)  # display "EE"

    mfc0 $s1, $14
    addiu $s1, $s1, 4
    mtc0 $s1, $14

    mfc0 $s1, $13
    srl $s1, $s1, 2
    li $s2, 0x1F
    and $s1, $s1, $s2
    li $s2, 8
    bne $s1, $s2, nonesyscall   #非syscall异常

    lui $s0, 0xBFD0
    li $s1, 0x2                 #send syscall flag
    jal wtest
    sw $s1, 0x3F8($s0)

    lui $s0, 0xBFD0
    jal wtest
    sw $v0, 0x3F8($s0)          #send syscall code


    li $s2, 1
    beq $s2, $v0, syscall_alloc

    li $s2, 2
    beq $s2, $v0, syscall_readline

    li $s2, 3
    beq $s2, $v0, syscall_readint

    li $s2, 4
    beq $s2, $v0, syscall_stringequal

    li $s2, 5
    beq $s2, $v0, syscall_printint

    li $s2, 6
    beq $s2, $v0, syscall_printstring

    li $s2, 7
    beq $s2, $v0, syscall_printint

    li $s2, 8
    beq $s2, $v0, syscall_halt

    b int_end               

syscall_alloc:

    move $s1, $a0
    jal shows1
    jal reads1
    lui $s2, 0x8000
    beq $s1, $s2, begin         # alloc fail, halt immediately
    move $v0, $s1
    b int_end

syscall_readline:
    lui $s0, 0xBFD0
    jal reads1
    move $v0, $s1
    move $s2, $s1
sr_loop:
    jal reads1
    sw $s1, 0($s2)
    addiu $s2, $s2, 4
    andi $s3, $s1, 0xFF
    beq $s3, $zero, int_end
    sra $s1, $s1, 8
    andi $s3, $s1, 0xFF
    beq $s3, $zero, int_end
    sra $s1, $s1, 8
    andi $s3, $s1, 0xFF
    beq $s3, $zero, int_end
    sra $s1, $s1, 8
    andi $s3, $s1, 0xFF
    beq $s3, $zero, int_end
    b sr_loop

syscall_readint:
    jal reads1
    move $v0, $s1
    b int_end

syscall_stringequal:
        lb $a1, 0($a0)              # load next 2 chars
        lb $a3, 0($a2)              #
        bne $a1, $a3, _SEnoMatch    # return false if chars don't match
        beqz $a1, _SEmatch          # return true if at null terminator
        addiu $a0, $a0, 1            # advance both by one
        addiu $a2, $a2, 1
        j syscall_stringequal
    _SEnoMatch:
        li $v0, 0
        b int_end
    _SEmatch:
        li $v0, 1
        b int_end


syscall_printint:
    move $s1, $a0
    jal shows1
    b int_end

syscall_printstring:
    move $s1, $a0
sp_loop:
    lbu $s2, 0($s1)
    lui $s0, 0xBFD0
    jal wtest
    sw $s2, 0x3F8($s0)
    addiu $s1, $s1, 1
    bne $s2, $zero, sp_loop
    b int_end

syscall_halt:
    b begin

nonesyscall:

    #输出中断信息到终端
    lui $s0, 0xBFD0

    li $s1, 0x7                 #send int flag
    jal wtest
    sw $s1, 0x3F8($s0)

    mfc0 $s1, $13               #CPR Casue
    jal shows1

    jal rtest                   #recv int over flag
    lw $s1, 0x3F8($s0)

    mfc0 $s1, $13               # if tlb missing b begin
    srl $s1, $s1, 2
    li $s2, 0x1F
    and $s1, $s1, $s2
    li $s2, 2
    beq $s1, $s2, begin
    li $s2, 3
    beq $s1, $s2, begin

int_end:
    #恢复用户现场
    addu $sp, $sp, 36
    lw $ra, -36($sp)
    lw $s0, -32($sp)
    lw $s1, -28($sp)
    lw $s2, -24($sp)
    lw $s3, -20($sp)
    lw $s4, -16($sp)
    lw $s5, -12($sp)
    lw $s6, -8($sp)
    lw $s7, -4($sp)

    eret
    nop

    #子程序 等待串口可读
rtest:
    lui $s0, 0xBFD0
    lw $s6, 0x3FC($s0)
    li $s7, 2
    and $s6, $s6, $s7
    bne $s6, $s7, rtest
    jr $ra

#子程序 等待串口可写
wtest:
    lui $s0, 0xBFD0
    lw $s6, 0x3FC($s0)
    li $s7, 1
    and $s6, $s6, $s7
    bne $s6, $s7, wtest
    jr $ra

#子程序 输出$s1的值
shows1:
    #push $ra
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    lui $s0, 0xBFD0
    jal wtest
    sw $s1, 0x3F8($s0)

    srl $s1, $s1, 8
    jal wtest
    sw $s1, 0x3F8($s0)

    srl $s1, $s1, 8
    jal wtest
    sw $s1, 0x3F8($s0)

    srl $s1, $s1, 8
    jal wtest
    sw $s1, 0x3F8($s0)

    #pop $ra
    addu $sp, $sp, 4
    lw $ra, -4($sp)
    
    jr $ra

#子程序 从串口读入32位数据入$s1
reads1:
    #push $ra $s2
    subu $sp, $sp, 8
    sw $ra, 0($sp)
    sw $s2, 4($sp)

    lui $s0, 0xBFD0
    li $s1, 0

    #7-0
    jal rtest
    lw $s2, 0x3F8($s0)
    andi $s2, $s2, 0xFF
    addu $s1, $s1, $s2

    #15-8
    jal rtest
    lw $s2, 0x3F8($s0)
    andi $s2, $s2, 0xFF
    sll $s2, $s2, 8
    addu $s1, $s1, $s2  

    #23-16
    jal rtest
    lw $s2, 0x3F8($s0)
    andi $s2, $s2, 0xFF
    sll $s2, $s2, 16
    addu $s1, $s1, $s2
    

    #31-23  
    jal rtest
    lw $s2, 0x3F8($s0)
    andi $s2, $s2, 0xFF
    sll $s2, $s2, 24
    addu $s1, $s1, $s2

    #pop $ra
    addu $sp, $sp, 8
    
    lw $s2, -4($sp)
    lw $ra, -8($sp)
    
    jr $ra

begin:
    lui $ra, 0x8000
    jr $ra