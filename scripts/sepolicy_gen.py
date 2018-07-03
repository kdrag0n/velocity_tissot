#!/usr/bin/env python
import re
import sys
f = open(sys.argv[1], 'r')
ln = f.read()
f.close()
pat = r'.+avc: denied { ([a-z ]+) } for .+ scontext=u:r:([a-z_]+):s0.+tcontext=u:object_r:([a-z_]+):s0.+tclass=([a-z_]+).+p'
while True:
    res = re.search(pat, ln)
    if not res: break
    ln = ln.replace(res.group(0), '')
    print(f'"allow {res.group(2)} {res.group(3)} {res.group(4)} {res.group(1)}"')
