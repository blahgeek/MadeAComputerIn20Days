#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-06-04

import socket
from bitstring import Bits

sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
sock.bind(('enp2s0', 0))
sock.send('\x11\x22\x33\x44\x55\x66' + '\x42'*6 + '\x08\x06\x42\x42')
