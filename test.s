#	.set noreorder
	b initial
	nop

initial:
	#设置 $sp
	lui $sp, 0x800F
	li $s1, 0xFFFF
	addu $sp, $sp, $s1

	#设置 Base
	lui $s1, 0x8000
	addiu $s1, $s1, 0x1D4
	mtc0 $s1, $15

	#关中断
	li $s1, 0x2
	mtc0 $s1, $12

	#输出ok到终端
	lui $s0, 0xBFD0

	li $s1, 0x4F					#send 'o'
	jal wtest
	sw $s1, 0x3F8($s0)

	li $s1, 0x4B					#send 'k'
	jal wtest
	sw $s1, 0x3F8($s0)

	li $s1, 0x0A					#send '\r'
	jal wtest
	sw $s1, 0x3F8($s0)

	li $s1, 0x0D					#send '\n'
	jal wtest
	sw $s1, 0x3F8($s0)

begin:
	jal rtest
	lui $s0, 0xBFD0
	lw $s1, 0x3F8($s0)
	li $s2, 0xFF
	and $s1, $s1, $s2

	#R instruction
	li $s2, 0x0052
	beq $s1, $s2, showregs

	#D instruction
	li $s2, 0x0044
	beq $s1, $s2, showmem

	#A instruction
	li $s2, 0x0041
	beq $s1, $s2, assemble

	#U instruction
	li $s2, 0x0055
	beq $s1, $s2, showmem

	#G instruction
	li $s2, 0x0047
	beq $s1, $s2, execute

	#E del TLB instruction
	li $s2, 0x0045
	beq $s1, $s2, deltlb

	#T add TLB instruction
	li $s2, 0x0054
	beq $s1, $s2, addtlb

	b begin


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

#查看寄存器的值
showregs:

	lui $s0, 0xBFD0

	addu $s1, $zero, $t0
	jal shows1

	addu $s1, $zero, $t1
	jal shows1

	addu $s1, $zero, $t2
	jal shows1

	addu $s1, $zero, $t3
	jal shows1

	addu $s1, $zero, $t4
	jal shows1

	addu $s1, $zero, $t5
	jal shows1

	addu $s1, $zero, $t6
	jal shows1

	addu $s1, $zero, $t7
	jal shows1

	addu $s1, $zero, $t8
	jal shows1

	addu $s1, $zero, $t9
	jal shows1

	mfc0 $s1, $12	#SR
	jal shows1

	mfc0 $s1, $14	#EPC
	jal shows1

	mfc0 $s1, $13	#Cause
	jal shows1

	mfc0 $s1, $8  	#BadVAddr
	jal shows1

	mfc0 $s1, $10	#EntryHi
	jal shows1	

	mfc0 $s1, $2  	#EntryLo0
	jal shows1

	mfc0 $s1, $3 	#EntryLo1
	jal shows1

	mfc0 $s1, $0 	#index
	jal shows1

	mfc0 $s1, $15	#EBase
	jal shows1

	mfc0 $s1, $9 	#count
	jal shows1

	mfc0 $s1, $11 	#compare
	jal shows1

	b begin


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


#查看内存
showmem:
	#读入起始地址到$s4
	jal reads1
	addu $s4, $zero, $s1

	#读入需要查看的内存的字数到$s2
	jal reads1
	addu $s2, $zero, $s1

	li $s3, 0
loop:
	lw $s1, 0($s4)
	jal shows1
	addiu $s3, $s3, 1
	addiu $s4, $s4, 4 
	bne $s2, $s3, loop
	b begin

#写入指令到mem
assemble:
	#读入起始地址到$s4
	jal reads1
	addu $s2, $zero, $s1

	jal reads1
	sw $s1, 0($s2)

	jal wtest
	li $s1, 0
	sw $s1, 0x3F8($s0)

	b begin

#从指定地址执行程序
execute:
	#读入起始地址到$s1
	jal reads1
	jalr $s1

	lui $s0, 0xBFD0

	li $s1, 0x4					#send end of transmission
	jal wtest
	sw $s1, 0x3F8($s0)

	b begin

deltlb:
	jal rtest
	lui $s0, 0xBFD0
	lw $s1, 0x3F8($s0)
	li $s2, 0xFF
	and $s1, $s1, $s2

	mtc0 $s1, $0 	#CPR Index
	mtc0 $zero, $2 	#CPR EntryLo0
	mtc0 $zero, $3 	#CPR EntryLo1
	mtc0 $zero, $10 	#CPR EntryHi
	tlbwi
	b begin

addtlb:
	jal rtest
	lui $s0, 0xBFD0
	lw $s1, 0x3F8($s0)
	li $s2, 0xFF
	and $s1, $s1, $s2

	mtc0 $s1, $0 	#CPR Index

	nop
	jal reads1
	sll $s1, $s1, 13
	mtc0 $s1, $10	#CPR EntryHi

	jal reads1
	sll $s1, $s1, 6

	jal rtest
	lui $s0, 0xBFD0
	lw $s3, 0x3F8($s0)
	li $s2, 0xFF
	and $s3, $s3, $s2
	sll $s3, $s3, 1
	or $s1, $s1, $s3
	mtc0 $s1, $2 	#CPR EntryLo0

	jal reads1
	sll $s1, $s1, 6

	jal rtest
	lui $s0, 0xBFD0
	lw $s3, 0x3F8($s0)
	li $s2, 0xFF
	and $s3, $s3, $s2
	sll $s3, $s3, 1
	or $s1, $s1, $s3
	mtc0 $s1, $3	#CPR EntryLo1

	tlbwi

	b begin

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

	mfc0 $s1, $14
	addiu $s1, $s1, 4
	mtc0 $s1, $14


	mfc0 $s1, $13
	srl $s1, $s1, 2
	li $s2, 0x1F
	and $s1, $s1, $s2
	li $s2, 8
	bne $s1, $s2, nonesyscall	#非syscall异常

	lui $s0, 0xBFD0
	li $s1, 0x2					#send syscall flag
	jal wtest
	sw $s1, 0x3F8($s0)

	lui $s0, 0xBFD0
	jal wtest
	sw $v0, 0x3F8($s0)			#send syscall code


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
	beq $s1, $s2, begin			# alloc fail, halt immediately
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

	li $s1, 0x7					#send int flag
	jal wtest
	sw $s1, 0x3F8($s0)

	mfc0 $s1, $13				#CPR Casue
	jal shows1

	jal rtest					#recv int over flag
	lw $s1, 0x3F8($s0)

	mfc0 $s1, $13				# if tlb missing b begin
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
	