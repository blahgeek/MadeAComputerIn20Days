	.file	1 "count.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.text
	.align	2
	.globl	f
	.set	nomips16
	.ent	f
	.type	f, @function
f:
	.frame	$fp,24,$31		# vars= 16, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$fp,20($sp)
	move	$fp,$sp
	li	$2,-1076887552			# 0xffffffffbfd00000
	sw	$2,8($fp)
	lw	$2,8($fp)
	addiu	$2,$2,4
	sw	$2,12($fp)
	sw	$0,0($fp)
	j	$L2
	nop

$L5:
	lw	$2,0($fp)
	andi	$3,$2,0xf
	lw	$2,8($fp)
	sw	$3,0($2)
	lw	$2,0($fp)
	sra	$2,$2,4
	andi	$3,$2,0xf
	lw	$2,12($fp)
	sw	$3,0($2)
	sw	$0,4($fp)
	j	$L3
	nop

$L4:
	lw	$2,4($fp)
	addiu	$2,$2,1
	sw	$2,4($fp)
$L3:
	lw	$3,4($fp)
	li	$2,131072			# 0x20000
	slt	$2,$3,$2
	bne	$2,$0,$L4
	nop

	lw	$2,0($fp)
	addiu	$2,$2,1
	sw	$2,0($fp)
$L2:
	lw	$2,0($fp)
	slt	$2,$2,31
	bne	$2,$0,$L5
	nop

	move	$sp,$fp
	lw	$fp,20($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	f
	.size	f, .-f
	.ident	"GCC: (GNU) 4.7.2"
