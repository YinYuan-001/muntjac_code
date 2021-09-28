#!/bin/env python
import click
@click.command()
@click.option('--filehuiwen')
@click.option('--filesize')
@click.option('--fileout')

def main(filehuiwen,filesize,fileout):
    file_out=open(fileout,'w')
    Size={}
    with open(filesize,'r') as file_size:
         for line in file_size:
             Line=line.strip().split()
             id=Line[0]
             size=int(Line[1])
             if id in Size:
                Size[id]=max(Size[id],size)
             else:
                 Size[id]=size
    with open(filehuiwen,'r') as file_huiwen:
         for line in file_huiwen:
             Line=line.strip().split()
             id=Line[0]
             start=Line[1]
             end=int(Line[2])
             if start == "1" :
                size=Size[id]
                if end != size:
                   file_out.write(line)
             else:
                 file_out.write(line)

if __name__=="__main__":
   main()
                   
