#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-07-08


import sys
from bitstring import Bits

LENGTH = 2**12 * 4

def main(input_f, output_f):
    fin = open(input_f, 'rb')
    fout = open(output_f, 'w')
    data = fin.read()
    while len(data) < LENGTH:
        data += '\0'
    while True:
        fout.write(Bits(length=32, bytes=data[:4]).bin + '\n')
        data = data[4:]
        if not data:
            break
    fout.close()

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
