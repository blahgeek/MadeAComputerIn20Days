nop
lui $1 0xbfd0
ori $10 $0 0x3
begin:
ori $11 $0 0
loop:
addiu $11 $11 1
bne $11 $10 loop
nop
addi $2 $2 1
sw $2 0($1)
j begin
nop