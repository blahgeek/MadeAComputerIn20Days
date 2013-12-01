#!/usr/bin/env python
# -*- coding: utf-8 -*-
# By i@BlahGeek.com

from bitstring import Bits

points = dict()
count = 0

def extend(n, length):
    while len(n) < length:
        n = '0' + n
    return n

def parse_register(s):
    ''' "$23" -> "10111" '''
    s = int(s.strip('$'))
    assert(s >= 0 and s < 32)
    return Bits(uint=s, length=5).bin

def parse_immediate(s, length, sign, branch=False):
    ''' "0x23" -> "00100011" '''
    global count
    if s[0] != '-' and not ('0' <= s[0] <= '9'):
        s = points[s] if not branch else (points[s]-1-count)
        return Bits(int=s, length=length).bin
    s = int(s, 16 if ('x' in s) else 10)
    if sign:
        return Bits(int=s, length=length).bin
    return Bits(uint=s, length=length).bin

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
    'lw': ('r i16 r', '100011 C A B'),
    'sw': ('r i16 r', '101011 C A B'),
    'beq': ('r r i16', '000100 A B C'),
    'bne': ('r r i16', '000101 A B C'),
    'slti': ('r r i16', '001010 B A C'),
    'sltiu': ('r r u16', '001011 B A C'),
    'j': ('u26', '000010 A'),
    'jal': ('u26', '000011 A'),
    'nop': ('', '0' * 32),
    'eret': ('', '010000 10000 00000 00000 00000 011000'),
    'syscall': ('', '0'*28 + '1100'),
    'mfc0': ('r r', '010000 00000 A B 00000 000000'),
    'mtc0': ('r r', '010000 00100 A B 00000 000000')
}

def parse_line(s):
    global count
    s = s.partition(';')[0].strip()  # comment
    if not len(s): return '';
    if s.endswith(':'):  # it's a mark
        points[s[:-1]] = count
        return ''
    inst, nouse, s = s.partition(' ')
    s = s.replace(',','').replace('\t','')
    parts = filter(lambda x: len(x), s.split(' '))
    format, code = INSTRUCTIONS[inst]
    for i, x in enumerate(filter(lambda t: len(t), format.split(' '))):
        parts[i] = parts[i].strip()
        if x == 'r':
            ret = parse_register(parts[i])
        elif x[0] == 'u':
            ret = parse_immediate(parts[i], int(x[1:]), False, inst.startswith('b'))
        elif x[0] == 'i':
            ret = parse_immediate(parts[i], int(x[1:]), True, inst.startswith('b'))
        code = code.replace(chr(ord('A')+i), ret)
    count += 1
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

