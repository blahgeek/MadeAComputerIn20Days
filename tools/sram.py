#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# By i@BlahGeek.com at 10/31/2013

import serial
import time
from ihex import IHex

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

def write_hex_file(ser, filename):
    ihex = IHex().read_file(filename)
    data = '\x3c\x1d\x00\x3f' + ihex.areas[0]
    write(ser, 0, data)
    readback = read(ser, 0x00)
    assert(readback[:len(data)] == data)

if __name__ == '__main__':
    ser = serial.Serial('/dev/cu.usbserial-ftDWBKKD',  115200)
    import sys
    if sys.argv[1] == 'write':
        data = open(sys.argv[2], 'rb').read()
        write(ser, 0x00, data)
        assert(read(ser, 0x00)[0:len(data)] == data)
    elif sys.argv[1] == 'writehex':
        write_hex_file(ser, sys.argv[2])
