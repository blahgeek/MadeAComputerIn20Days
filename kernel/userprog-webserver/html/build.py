#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by i@BlahGeek.com at 2014-06-05

import sys
import gzip
import cStringIO

CHUNK = 1000

HTTP_HEAD = ('HTTP/1.0 200 OK\r\n' + 
    'Server: FSS Web Server By BlahGeek!\r\n' + 
    'X-Hack: ' + 'BlahGeek' * 10 + '\r\n' +
    'Content-Encoding: gzip\r\n' +
    'Content-Type: text/html; charset=UTF-8\r\n' +
    'Content-Length: %d\r\n' +
    '\r\n')
html = open(sys.argv[1]).read()
zbuf = cStringIO.StringIO()
zfile = gzip.GzipFile(mode='wb', fileobj=zbuf, compresslevel=9)
zfile.write(html)
zfile.close()

data = HTTP_HEAD % len(html) + zbuf.getvalue()

# while (len(data)) % CHUNK != 0:
#     data += '\x00'

with open(sys.argv[2], 'wb') as f:
    for s in data:
        f.write('\x00' * 3 + s)
        # f.write(s)

print 'CHUNK:', CHUNK
print 'Length:', len(data)
