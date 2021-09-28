#!/bin/env python
import click
import re
@click.command()
@click.option('--vcfin')
@click.option('--vcfout')

def main(vcfin,vcfout):
    file_vcfout=open(vcfout,'w')
    with open(vcfin,'r') as file_vcfin:
        for line in file_vcfin:
            Line=line.strip().split()
            info=Line[7]
            dp=re.search(r'.*DP4=(.*);MQ=',info)
            dp4=dp.group(1).split(',')
            dp4_1=[int(i) for i in dp4]
            total=sum(dp4_1)
            alt_dp=dp4_1[2]+dp4_1[3]
            por=float(alt_dp)/total
            if por >=0.85:
                file_vcfout.write(line)
    file_vcfout.close()
    file_vcfin.close()
if __name__=='__main__':
    main()


