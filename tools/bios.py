#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-07-08

import serial
import time
import sys
from bitstring import Bits


def send4byte(ser, data):
    if type(data) is not str:
        data = Bits(uint=data, length=32).bytes
    assert len(data) == 4
    for x in data:
        ser.write(x)


def checksum(data):
    ret = 0
    for i in range(0, 64, 4):
        ret ^= Bits(bytes=data[i:i+4]).uint
    return ret


def recv4byte(ser):
    ret = ''
    for i in range(4):
        ret += ser.read(1)
    return Bits(bytes=ret).uint


def write64byte(ser, addr, data):
    while len(data) < 64:
        data += '\0'
    ser.write(chr(0x42))
    send4byte(ser, addr)
    for i in range(0, 64, 4):
        send4byte(ser, data[i:i+4])
    if recv4byte(ser) != checksum(data):
        print 'Assert Fail! Retry...'
        write64byte(ser, addr, data)


if __name__ == '__main__':
    data = open(sys.argv[1], 'rb').read()
    ser = serial.Serial(sys.argv.pop(), 115200, timeout=0.1)
    try:
        addr = int(sys.argv[2], 16)
    except IndexError:
        addr = 0
    while True:
        print 'Write to ' + hex(addr)
        write64byte(ser, addr, data[:64])
        data = data[64:]
        if not data:
            break
        addr += 64
