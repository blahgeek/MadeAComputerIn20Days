# put me on 0x80004000

int:
    lui $s1, 0xBFD0
    mfc0 $s2, $13  # cause
    srl $s2, $s2, 2
    sw $s2, 4($s1)  # put cause on NUM1
    eret