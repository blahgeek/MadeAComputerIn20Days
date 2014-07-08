#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# By i@BlahGeek.com at 10/31/2013

import serial
import time

BLOCK_ADDR_LEN = 13
BLOCK_LEN = 2**BLOCK_ADDR_LEN * 4;

def write(f, addr, data):
    addr |= 0x80;
    addr &= 0xff;
    if len(data) > BLOCK_LEN:
        data = data[:BLOCK_LEN]
        print 'Data too long, cut to %s byte' % str(BLOCK_LEN)
    if len(data) < BLOCK_LEN:
        data = data + chr(0) * (BLOCK_LEN - len(data))
        print 'Data too short, appent "\\0" to %s byte' % str(BLOCK_LEN)
    print 'Writing to %s' % hex(addr & 0x7f)
    start = time.time()
    f.write(chr(addr) + data)
    f.flush()
    print 'Write done, time = %s s' % str(time.time() - start)

def read(f, addr):
    addr &= 0x7f;
    print 'Reading %s' % hex(addr & 0x7f)
    start = time.time()
    f.write(chr(addr));
    ans = f.read(BLOCK_LEN)
    print 'Read done, time = %s s' % str(time.time() - start)
    return ans

if __name__ == '__main__':
    import sys
    ser = serial.Serial(sys.argv.pop(), 115200)
    print 'Now reset the FPGA and press enter to continue...', raw_input()
    if sys.argv[1] == 'write':
        data = open(sys.argv[2], 'rb').read()
        try:
            addr = int(sys.argv[3], 16)
            addr >>= (BLOCK_ADDR_LEN+2)
        except IndexError:
            addr = 0x00
        while True:
            chunk = data[:BLOCK_LEN]
            data = data[BLOCK_LEN:]
            if not chunk:
                break
            write(ser, addr, chunk)
            read_back = read(ser, addr)[0:len(chunk)]
            # with open('readback.bin', 'wb') as f:
            #     f.write(read_back)
            assert(read_back == chunk)
            addr += 1
