#!/usr/bin/env python
# -*- coding: utf-8 -*-
# By i@BlahGeek.com

def extend(n, length, sign=False):
    b = n[0]
    while len(n) < length:
        n = (b if sign else '0') + n
    return n

def parse_register(s):
    ''' "$23" -> "10111" '''
    s = int(s.strip('$'))
    assert(s >= 0 and s < 32)
    s = bin(int(s)).split('b')[1]
    return extend(s, 5)

def parse_immediate(s, length, sign=False):
    ''' "0x23" -> "00100011" '''
    s = int(s, 16 if ('x' in s) else 10)
    s = bin(s).split('b')[1]
    assert(len(s) <= length)
    return extend(s, length, sign)

INSTRUCTIONS = {
    'add': ('r r r', '000000 B C A 00000 100000'), 
    'addu': ('r r r', '000000 B C A 00000 100001'), 
    'sub': ('r r r', '000000 B C A 00000 100010'), 
    'subu': ('r r r', '000000 B C A 00000 100011'), 
    'and': ('r r r', '000000 B C A 00000 100100'), 
    'or': ('r r r', '000000 B C A 00000 100101'), 
    'xor': ('r r r', '000000 B C A 00000 100110'), 
    'nor': ('r r r', '000000 B C A 00000 100111'), 
    'slt': ('r r r', '000000 B C A 00000 101010'), 
    'sltu': ('r r r', '000000 B C A 00000 101011'), 
    'sll': ('r r u5', '000000 00000 B A C 000000'),
    'srl': ('r r u5', '000000 00000 B A C 000010'),
    'sra': ('r r u5', '000000 00000 B A C 000011'),
    'sllv': ('r r r', '000000 C B A 00000 000100'), 
    'srlv': ('r r r', '000000 C B A 00000 000110'), 
    'srav': ('r r r', '000000 C B A 00000 000111'), 
    'jr': ('r', '000000 A 00000 00000 00000 001000'),
    'addi': ('r r i16', '001000 B A C'),
    'addiu': ('r r u16', '001001 B A C'),
    'andi': ('r r u16', '001100 B A C'),
    'ori': ('r r u16', '001101 B A C'),
    'xori': ('r r u16', '001110 B A C'),
    'lui': ('r u16', '001111 00000 A B'),
    'lw': ('r i16 r', '100011 B C A'),
    'sw': ('r i16 r', '101011 B C A'),
    'beq': ('r r i16', '000100 A B C'),
    'bne': ('r r i16', '000101 A B C'),
    'slti': ('r r i16', '001010 B A C'),
    'sltiu': ('r r u16', '001011 B A C'),
    'j': ('u26', '000010 A'),
    'jal': ('u26', '000011 A'),
}

def parse_line(s):
    s = s.partition(';')[0].strip()  # comment
    inst, nouse, s = s.partition(' ')
    s = s.replace(',','').replace('\t','')
    parts = filter(lambda x: len(x), s.split(' '))
    format, code = INSTRUCTIONS[inst]
    for i, x in enumerate(format.split(' ')):
        parts[i] = parts[i].strip()
        if x == 'r':
            ret = parse_register(parts[i])
        elif x[0] == 'u':
            ret = parse_immediate(parts[i], int(x[1:]), False)
        elif x[0] == 'i':
            ret = parse_immediate(parts[i], int(x[1:]), True)
        code = code.replace(chr(ord('A')+i), ret)
    return code

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()
    ret = ''
    with open(args.input) as f:
        for line in f.readlines():
            ret += parse_line(line) + '\n'
    print ret
    ret = ret.replace(' ', '').replace('\n', '')
    assert(len(ret) % 8 == 0)
    with open(args.output, 'w') as f:
        for i in range(len(ret) / 8):
            f.write(chr(int(ret[i*8:i*8+8], 2)))

