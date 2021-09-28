#!/bin/env python
import click
def read_size(filesize):
    Size={}
    with open(filesize,'r') as file_size:
         for line in file_size:
             Line=line.strip().split()
             id=Line[0]
             size=Line[1]
             if id not in Size:
                Size[id]=size
             else:
                 Size[id]=max(size,Size[id])
    return Size

def read_huiwen(filehuiwen):
    Huiwen={}
    with open(filehuiwen,'r') as file_huiwen:
         for line in file_huiwen:
             Line=line.strip().split()
             id=Line[0]
             length=int(Line[2])-int(Line[1])+1
             if id not in Huiwen:
                Huiwen[id]=0
             Huiwen[id]=Huiwen[id]+length
    return Huiwen

@click.command()
@click.option('--filesize')
@click.option('--filepattern')
@click.option('--filehuiwen')
@click.option('--fileout')

def main(filesize,filepattern,filehuiwen,fileout):
    file_out=open(fileout,'w')
    Size=read_size(filesize)
    Huiwen=read_huiwen(filehuiwen)
    with open(filepattern,'r') as file_pattern:
         for line in file_pattern:
             Line=line.strip().split()
             id=Line[0]
             if id in Size:
                size=Size[id]
             else:
                 size=0
             if id in Huiwen:
                huiwen_length=Huiwen[id]
             else:
                 huiwen_length=0
             out_line=line.strip()+'\t'+str(size)+'\t'+str(huiwen_length)+'\n'
             file_out.write(out_line)

if __name__=='__main__':
   main()


