#!/bin/env python
import sys
file_in=open(sys.argv[1],'r')
file_out=open(sys.argv[2],'w')
file_out.write('9 17178\n')
id=''
seq=''
for line in file_in:
    if line.startswith('>'):
       if id and seq:
          out_line=id+'\t'+seq+'\n'
          file_out.write(out_line)
       id=line.strip()[1:].split(' ')[0]
       seq=''
    else:
        seq=seq+line.strip()
out_line=id+'\t'+seq+'\n'
file_out.write(out_line)
