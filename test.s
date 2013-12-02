nop
ori $1 $0 24
mtc0 $1 $15
here:
syscall
nop
j here
syscall_here:
addi $2 $2 1
eret
nop