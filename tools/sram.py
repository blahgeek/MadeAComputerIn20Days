#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# By i@BlahGeek.com at 10/31/2013

import serial
import random
import time

BLOCK_LEN = 2**13 * 4;

gendata = lambda l: ''.join([chr(random.randint(0,255)) for x in xrange(l)])

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
    ser = serial.Serial('/dev/cu.usbserial-ftDWBKKD',  115200)
    import sys
    if sys.argv[1] == 'write':
        data = open(sys.argv[2], 'rb').read()
        write(ser, 0x00, data)
        assert(read(ser, 0x00)[0:len(data)] == data)
