#!/bin/env python
import click

@click.command()
@click.option('--invcf')
@click.option('--outvcf')

def main(invcf,outvcf):
    file_outvcf=open(outvcf,'w')
    with open(invcf) as file_invcf:
        for line in file_invcf:
            Line=line.strip().split()
            if Line[0].startswith('#'):
                file_outvcf.write(line)
            else:
                format=Line[8].split(':')
                hjm=Line[9].split(':')
                pos=format.index('DP')
                hjm_dp=int(hjm[pos])
                if hjm_dp >=15 and hjm_dp <=100:
                    file_outvcf.write(line)
if __name__=='__main__':
    main()

