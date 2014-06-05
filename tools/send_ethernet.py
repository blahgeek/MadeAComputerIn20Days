#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-06-04

import socket
from bitstring import Bits

sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
sock.bind(('enp2s0', 0))

DST = '\x11\x22\x33\x44\x55\x66'
# DST = '\xff' * 6

for i in xrange(10):
    sock.send( DST + 
        '\x42'*6 + '\x08' + chr(i))
    print hex(i)
