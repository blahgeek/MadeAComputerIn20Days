#!/usr/bin/env python
# -*- coding: utf-8 -*-
# By i@BlahGeek.com

import serial
from bitstring import Bits

def send4bit(ser, data):
    ''' little-endian (strange...= =) '''
    if isinstance(data, int):
        data = Bits(uint=data, length=32).bytes
    assert(len(data) == 4)
    ser.write(data[::-1])

def recv4bit(ser):
    ''' little-endian as well'''
    return ser.read(4)[::-1]

def showregs(ser):
    names = ['$t'+str(x) for x in xrange(10)]
    names = names + ["$SR", "$EPC", "$Cause", "$BadVAddr", 
                     "$EntryHi", "$EntryLo0", "$EntryLo1", "$Index", 
                     "$Ebase", "$Count", "$Compare"]
    ser.write(chr(0x52))
    for i in xrange(21):
        print names[i], '\t', '0x'+Bits(bytes=recv4bit(ser)).hex

def showmem(ser, addr, count):
    ser.write(chr(0x44))
    send4bit(ser, addr)
    send4bit(ser, count)
    for i in xrange(count):
        print '0x'+Bits(length=32, uint=addr+i).hex, ':',
        print '0x'+Bits(bytes=recv4bit(ser)).hex

def writemem(ser, addr, value):
    ser.write(chr(0x41))
    send4bit(ser, addr)
    send4bit(ser, value)
    assert(ser.read(1) == chr(0))

def addtlb(ser, index, hi, lo1, lo2):
    ser.write(chr(0x54))
    ser.write(chr(index))
    for x in (hi, lo1, lo2):
        send4bit(ser, x)

def execute(ser, addr):
    ser.write(chr(0x47))
    send4bit(ser, addr)
    while True:
        code = ord(ser.read(1))
        if code == 4:
            break
        else:
            print 'Recieved code: %d' % code

def writebin(ser, s, addr):
    assert(len(s)%4 == 0)
    for i in xrange(len(s)/4):
        writemem(ser, addr, s[i*4:i*4+4])
        addr += 4

if __name__ == '__main__':
    ser = serial.Serial('/dev/cu.usbserial-ftDWBKKD',  115200)
    writemem(ser, 0x80004000, 0xDEADBEEF)
    showmem(ser, 0x80004000, 10)
