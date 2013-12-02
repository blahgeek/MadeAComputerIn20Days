nop
mtc0 $0 $0
mtc0 $0 $10
ori $1 $0 0xffff
mtc0 $1 $2
tlbwi
sw $0 32($0)
lui $2 0xbfd0
sw $1 0($2)
nop