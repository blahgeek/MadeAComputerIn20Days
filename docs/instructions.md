# Instructions

(31 downto 26) = 010000:  Super Command!
    (5 downto 0) = 011000: eret
    (5 downto 0) = 000000: mfc0/mtc0
        (25 downto 21) = 00000: mfc0
        else: mtc0
    else: tlbwi

(31 downto 26) = 000000: R Type
    (15 downto 0) = x"0018" or x"0019":
        mult multu
    (5 downto 0) = 001100: syscall
    (5) = 1: 3 reg type, operator from (3 downto 0)
        add, addu, and, or, slt, sltu, sub, subu, xor, 
    else:
        (2) = 1: 3 reg type, <<, >>, >>>
        else:
            (3) = 0: not jr/jalr, immediant, <<, >>, >>>
            else: jr/jalr
                (0) = 1: jalr
                else: jr

(31 downto 26) = 000010/000011: J Type
    (27 downto 26) = 10: j
    else: jal

else: I Type
    (31 downto 30) = 10: lw/sw
        (29 downto 26) = 1000: sb
        (29 downto 26) = 0000: lb
        (29 downto 26) = 0011: lw
        else: sw
    (31 downto 26) = 001111: lui
    (31 downto 29) = 000: branch
        (28 downto 26) = 100: beq
        (28 downto 26) = 001: bgez
        (28 downto 26) = 111: bgtz
        (28 downto 26) = 110: blez
        (28 downto 26) = 001: bltz
        else: bne
    else: Other I Type
        addi, addiu, andi, ori, xori, slti, sltiu
