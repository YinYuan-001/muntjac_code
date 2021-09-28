#!/bin/env python
# -*- coding: utf-8 -*-  
import click
@click.command()
@click.option('--refsnp')
@click.option('--candsnp')
@click.option('--outsnp')

def main(refsnp,candsnp,outsnp):
    file_outsnp=open(outsnp,'w')
    pos=[]
    with open(refsnp,'r') as file_refsnp:
        for line in file_refsnp:
            Line=line.strip().split()
            pos.append(int(Line[1]))
    start=0
    end=len(pos)
    arrary=range(start,end)
    with open(candsnp,'r') as file_candsnp:
         for line in file_candsnp:
             Line=line.strip().split()
             pos_cand=int(Line[1])
             for i in arrary[start:end]:
                 if pos_cand ==pos[i]:
                    file_outsnp.write(line)
                    start=i
                    break
                 elif pos_cand < pos[i]:
                    start=i-1
                    break
                 else:
                     continue
    file_outsnp.close()
    file_refsnp.close()
    file_candsnp.close()
if __name__=='__main__':
    main()
