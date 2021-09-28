#!/bin/env python
import numpy as np
import click
import math

def get_mean_std(filein,cutoff):
    arry=[]
    with open(filein) as file_in:
         for line in file_in:
            Line=line.strip().split()
            if float(Line[3]) < 0:
                val=float(Line[3]) * -1
            else:
                val=float(Line[3])
            if val < float(cutoff):
               val=math.log(val,2)
               arry.append(val)
    arrys=np.asarray(arry)
    return arrys
@click.command()
@click.option('--filein')
@click.option('--fileout')
@click.option('--cutoff')

def main(filein,fileout,cutoff):
    #file_in=open(filein,'r')
    file_out=open(fileout,'w')
    arry=get_mean_std(filein,cutoff)
    max=np.max(arry)
    min=np.min(arry)
    mean=np.mean(arry)
    print(max,mean,min)
    with open(filein) as file_in:
        for line in file_in:
            Line=line.strip().split()
            if float(Line[3]) < 0:
                val=float(Line[3]) * -1
            else:
                val=float(Line[3])
            val=math.log(float(val),2)
            new_val=round((val-min)/(max-min),4)
            out_line=line.strip()+'\t'+str(new_val)+'\n'
            file_out.write(out_line)

if __name__=='__main__':
   main()

