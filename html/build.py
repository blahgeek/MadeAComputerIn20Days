#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-06-05

import sys

CHUNK = 64

HTTP_HEAD = ('HTTP/1.0 200 OK\r\n' + 
    'Content-Type: text/html; charset=UTF-8\r\n' +
    '\r\n')
html = open(sys.argv[1]).read()
data = HTTP_HEAD + html

while (len(data)) % CHUNK != 0:
    data += '\n'

with open(sys.argv[2], 'wb') as f:
    for s in data:
        f.write('\x00' * 3 + s)

print 'CHUNK:', CHUNK
print 'Length:', len(data)
print 'CHUNK_NUM:', len(data) / CHUNK
