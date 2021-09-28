#!/bin/env python
import click

@click.command()
@click.option('--snp')
@click.option('--sv')
@click.option('--outsv')
@click.option('--stat')
def main(snp,sv,outsv,stat):
    file_outsv=open(outsv,'w')
    file_stat=open(stat,'w')
    POS=[]
    with open(snp,'r') as file_snp:
        for line in file_snp:
            Line=line.strip().split()
            POS.append(int(Line[1]))
    with open(sv,'r') as file_sv:
        for line in file_sv:
            Line=line.strip().split()
            contig=Line[0]
            pos=int(Line[1])
            p_start=pos -1000
            p_end=pos + 1000
            sum=0
            for site in POS:
                if site >=p_start and site <=p_end:
                   sum=sum+1
                   continue
                if site < p_start:
                   continue
                if site > p_end:
                   break
            if sum >=1:
              file_outsv.write(line)
              file_stat.write(contig+'\t'+str(pos)+'\t'+str(sum)+'\n')
                   
if __name__=='__main__':
    main()



