nop
lui $3 0x01
ori $2 $0 0x00
lui $10 0x0007
lui $1 0x8000
here:
and $11 $0 $0
sw $2 0 $3
loop:
nop
addi $11 $11 0x01
nop
nop
bne $11 $10 loop
nop
lw $2 0 $3
nop
nop
sw $2 0 $1
addi $2 $2 1
nop
j here
nop