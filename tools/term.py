#!/usr/bin/env python
# -*- coding: utf-8 -*-
# By i@BlahGeek.com

import serial
from bitstring import Bits

import sys
from os import path
sys.path.append(path.abspath(path.dirname(__file__)))

from ihex import IHex

ALLOC_NOW = 0x10000
ALLOC_END = 0x400000

def send4bit(ser, data):
    ''' little-endian (strange...= =) '''
    if isinstance(data, int) or isinstance(data, long):
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
        print '0x'+Bits(length=32, uint=addr+i*4).hex, ':',
        print '0x'+Bits(bytes=recv4bit(ser)).hex

def writemem(ser, addr, value):
    print 'Writing memory: Addr:', hex(addr), 'Data:', repr(value)
    ser.write(chr(0x41))
    send4bit(ser, addr)
    send4bit(ser, value)
    if ser.read(1) != chr(0):
        print '[ERROR] retry...'
        writemem(ser, addr, value)

def addtlb(ser, index, hi, lo1, lo2):
    ''' lo can be None'''
    ser.write(chr(0x54))
    ser.write(chr(index))
    for x in (hi, lo1, lo2):
        send4bit(ser, x)

def syscall(ser):
    global ALLOC_NOW
    code = ord(ser.read(1))
    print 'Syscall code: %d' % code,
    if code == 1:  # alloc
        size = Bits(bytes=recv4bit(ser)).uint
        if size + ALLOC_NOW < ALLOC_END:
            send4bit(ser, ALLOC_NOW)
            ALLOC_NOW += size
        else:
            send4bit(ser, 0x80000000)
        print 'Allocated %s byts, now at %s' % (hex(size), hex(ALLOC_NOW))
    elif code == 3: # read int
        print 'Enter a integer: ',
        value = raw_input().strip()
        value = int(value, 16 if 'x' in value else 10)
        send4bit(ser, value)
    elif code == 5:
        print 'Print a integer: ',
        value = Bits(bytes=recv4bit(ser)).int
        print hex(value)
    elif code == 8:
        print 'Halt'
        return True

def interrupt(ser):
    reason = {
        0: 'Interrupt',
        2: 'TLB missing in LOAD',
        3: 'TLB missing in STORE',
        1: 'TLB missing when fetching instuction',
    }
    cause = Bits(bytes=recv4bit(ser)).uint
    cause = (cause >> 2) & 0x1f
    print 'Cause: %d: %s' % (cause, reason.get(cause, 'Unknown'))
    ser.write(chr(4))

def execute(ser, addr):
    ser.write(chr(0x47))
    send4bit(ser, addr)
    while True:
        code = ord(ser.read(1))
        if code == 4:
            print 'Complete.'
            break
        elif code == 7:
            print 'Interrupt...'
            return interrupt(ser)
        elif code == 2:
            print 'Syscall...'
            if syscall(ser):
                break
        else:
            print 'Recieved unknown code: %d' % code

def writebin(ser, s, addr):
    assert(len(s)%4 == 0)
    for i in xrange(len(s)/4):
        writemem(ser, addr, s[i*4:i*4+4])
        addr += 4

def writeihex(ser, filename):
    h = IHex.read_file(filename)
    for addr in h.areas:
        data = h.areas[addr]
        for i in xrange(len(data)/4):
            writemem(ser, addr + i * 4 + 0x80000000, data[i*4:i*4+4])

if __name__ == '__main__':
    import sys
    parseint = lambda x: int(x, 16) if 'x' in x else int(x)
    ser = serial.Serial('/dev/ttyAMA0', 115200, timeout=1)
    if len(sys.argv) < 2:
        print 'Usage: ', sys.argv[0], 'showregs|showmem|addtlb|writebin|execute'
    elif sys.argv[1] == 'showregs':
        showregs(ser)
    elif sys.argv[1] == 'showmem':
        showmem(ser, parseint(sys.argv[2]), parseint(sys.argv[3]))
    elif sys.argv[1] == 'addtlb':
        addtlb(ser, parseint(sys.argv[2]), parseint(sys.argv[3]), 
               parseint(sys.argv[4]), parseint(sys.argv[5]))
    elif sys.argv[1] == 'writebin':
        writebin(ser, open(sys.argv[2], 'rb').read(), parseint(sys.argv[3]))
    elif sys.argv[1] == 'execute':
        execute(ser, parseint(sys.argv[2]))
    elif sys.argv[1] == 'writeihex':
        writeihex(ser, sys.argv[2])
    else:
        print 'Unknown command'
