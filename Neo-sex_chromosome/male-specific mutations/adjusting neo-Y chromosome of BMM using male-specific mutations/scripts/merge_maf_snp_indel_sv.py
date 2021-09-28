#!/bin/env python
import click


def read_snp(snp):
    SNP={'hjf_chr1':{},'hjf_chr4+x':{}}
    with open(snp,'r') as file_snp:
        for line in file_snp:
            Line=line.strip().split()
            chr=Line[0]
            pos=int(Line[1])
            alt=Line[4]
            SNP[chr][pos]=alt
    return SNP

def read_indel(indel):
    INDEL={'hjf_chr1':{},'hjf_chr4+x':{}}
    with open(indel,'r') as file_indel:
        for line in file_indel:
            Line=line.strip().split()
            chr=Line[0]
            pos=int(Line[1])
            alt=Line[4]
            ref=Line[3]
            length=len(ref)
            if length == 1:
               INDEL[chr][pos]=alt
            else:
               for i in range(1,length):
                   Pos=pos+i
                   INDEL[chr][Pos]='DEL'
    return INDEL
def read_sv(sv):
    SV={'hjf_chr1':{},'hjf_chr4+x':{}}
    with open(sv,'r') as file_sv:
        for line in file_sv:
            Line=line.strip().split()
            chr=Line[0]
            start=int(Line[1])
            ref=Line[3]
            alt=Line[4]
            end=int(Line[7].split(';')[3].split('=')[1])
            type=Line[7].split(';')[9].split('=')[1]
            if type=='DEL':
               for i in range(start,end+1):
                   SV[chr][i]=type
            if type=='INS':
               SV[chr][start]=alt
    return SV
    

@click.command()
@click.option('--lst')
@click.option('--snp')
@click.option('--indel')
@click.option('--sv')
@click.option('--out')

def main(lst,snp,indel,sv,out):
    file_out=open(out,'w')
    SNP=read_snp(snp)
    INDEL=read_indel(indel)
    SV=read_sv(sv)
    with open(lst,'r') as file_lst:
        for line in file_lst:
           Line=line.strip().split()
           chr=Line[0]
           if Line[1] !='-':
            pos=int(Line[1])
            snp_site=SNP[chr]
            if pos in snp_site:
               snp_alt=snp_site[pos]
            else:
                snp_alt='-'
            indel_site=INDEL[chr]
            if pos in indel_site:
               indel_alt=indel_site[pos]
            else:
                indel_alt='-'
            sv_site=SV[chr]
            if pos in sv_site:
               sv_alt=sv_site[pos]
            else:
                sv_alt='-'
           else:
               pos=Line[1]
               snp_alt='-'
               indel_alt='-'
               sv_alt='-'
           out_line=line.strip()+'\t'+snp_alt+'\t'+indel_alt+'\t'+sv_alt+'\n'
           file_out.write(out_line)

if __name__=='__main__':
    main()
