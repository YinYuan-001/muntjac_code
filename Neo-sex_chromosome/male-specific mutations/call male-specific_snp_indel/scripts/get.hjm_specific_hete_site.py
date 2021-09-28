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
                 gsj=Line[9]
                 mgn=Line[10]
                 hjf=Line[11]
                 hjf2=Line[12]
                 hjm=Line[13]
                 hjm2=Line[14]
                 if gsj=='.' and mgn=='.' and hjf=='.' and hjf2=='.' and (hjm.startswith('0/1') or hjm.startswith('0|1')) and (hjm2.startswith('0/1') or hjm2.startswith('0|1')):
                    file_outvcf.write(line)


if __name__=='__main__':
   main()
