lui $10 0x000f
ori $2 $0 0x00
lui $1 0x8000
ori $3 $0 0xff
here:
and $11 $0 $0
addi $2 $2 0x01
loop:
nop
addi $11 $11 0x01
nop
nop
bne $11 $10 loop
nop
nop
sw $2 0 $1
bne $2 $3 here
nop
nop