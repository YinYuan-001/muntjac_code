#!/bin/env python

import click
import re

@click.command()
@click.option('--invcf')
@click.option('--rdlist')

def main(invcf,rdlist):
    file_rdlist=open(rdlist,'w')
    with open(invcf) as file_invcf:
        for line in file_invcf:
            Line=line.strip().split()
            if Line[0].startswith('#') or len(Line)==0:
               continue
            else:
                info=Line[7]
                if re.search(r'RNAMES=.*;SUPTYPE',info):
                   name=re.search(r'RNAMES=(.*);SUPTYPE',info)
                   rd_names=name.group(1).split(',')
                   for i in rd_names:
                       out_line=i+'\n'
                       file_rdlist.write(out_line)
if __name__=='__main__':
    main()


    
