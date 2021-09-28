#!/bin/env python

### This program will produce a lst file which is 1-based.
### A 0-based maf file is needed as the input file


import click
def delimited(file, delimiter = '\n', bufsize = 10000):
    buf = ''
    while True:
        newbuf = file.read(bufsize)
        if not newbuf:
            yield buf
            return
        buf += newbuf
        lines = buf.split(delimiter)
        for line in lines[:-1]:
            yield line
        buf = lines[-1]

def get_pos(seq,start,strand,chr_len):
    seq_len=len(seq)
    POS=[]
    last_end=-1
    if strand=='+':
       last_end=-1
       start=start+1
       for i in range(seq_len):
           if seq[i]!='-':
              last_end=last_end+1
              pos=start+last_end

           else:
              pos='-'
           POS.append(pos)
    
    if strand=='-':
       start=chr_len-start
       last_end=-1
       for i in range(seq_len):
           if seq[i]!='-':
              last_end=last_end+1
              pos=start-last_end
           else:
              pos='-'
           POS.append(pos)
    return POS

@click.command()
@click.option('--maf')
@click.option('--lst')

def main(maf,lst):
    file_lst=open(lst,'w')
    with open(maf) as file_maf:
        lines = delimited(file_maf,'a score')
        for line in lines:
            Line=line.strip().split('\n')
            if Line[0].startswith('='):
               ref_Line=Line[1].split()
               query_Line=Line[2].split()

               ref_chr=ref_Line[1].split('.')[1]
               ref_start=int(ref_Line[2])
               ref_align_size=int(ref_Line[3])
               ref_strand=ref_Line[4]
               ref_size=int(ref_Line[5])
               ref_seq=ref_Line[6]
               ref_POS=get_pos(ref_seq,ref_start,ref_strand,ref_size)

               query_chr=query_Line[1].split('.')[1]
               query_start=int(query_Line[2])
               query_align_size=int(query_Line[3])
               query_strand=query_Line[4]
               query_size=int(query_Line[5])
               query_seq=query_Line[6]
               query_POS=get_pos(query_seq,query_start,query_strand,query_size)

               for i in range(len(ref_seq)):
                   ref_base=ref_seq[i]
                   ref_pos=ref_POS[i]
                   query_base=query_seq[i]
                   query_pos=query_POS[i]
                   out_line=ref_chr+'\t'+str(ref_pos)+'\t'+ref_base+'\t'+ref_strand+'\t'+query_chr+'\t'+str(query_pos)+'\t'+query_base+'\t'+query_strand+'\n'
                   file_lst.write(out_line)
               continue
if __name__=='__main__':
    main()

               
