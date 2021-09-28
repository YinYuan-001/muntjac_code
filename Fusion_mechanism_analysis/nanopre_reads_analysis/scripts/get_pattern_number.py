#!/bin/env python

import click
@click.command()
@click.option('--filein')
@click.option('--fileout')

def main(filein,fileout):
    file_out=open(fileout,'w')
    with open(filein,'r') as file_in:
        for line in file_in:
            Line=line.strip().split()
            if Line[0]!='id':
               
               id=Line[0]
               out_line=line.strip()+'\t'
               mon=int(Line[1])
               sal_I=int(Line[2])
               sal_II=int(Line[3])
               sal_IV=int(Line[4])
               telo=int(Line[5])
               #if mon+sal_I > 0 :
               if mon+sal_I>=30:
                  out_line=out_line+'1'
               else:
                   out_line=out_line+'0'
               #if sal_II > 0:
               if sal_II >=30:
                  out_line=out_line+'1'
               else:
                   out_line=out_line+'0'
               #if sal_IV > 0:
               if sal_IV>=30:
                  out_line=out_line+'1'
               else:
                   out_line=out_line+'0'
               if telo > 0:
                  out_line=out_line+'1'
               else:
                   out_line=out_line+'0'
               file_out.write(out_line+'\n')

if __name__=='__main__':
    main()
