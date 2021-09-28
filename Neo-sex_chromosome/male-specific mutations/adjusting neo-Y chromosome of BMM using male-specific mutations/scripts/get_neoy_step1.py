#!/bin/env python
import click
from string import maketrans

def get_changed_base(ref_base,alt_snp,alt_indel,alt_sv):
    snp=alt_snp.split(',')[0]
    indel=alt_indel.split(',')[0]
    sv=alt_sv.split(',')[0]
    if snp !='-':
       if snp.upper()!=ref_base.upper():
          ref_base=snp
    if sv =='DEL':
       ref_base=''
    elif len(sv) >1:
       ref_base=ref_base+sv
    if indel=='DEL':
       ref_base=''
    elif len(indel)>1:
       ref_base=indel
    return ref_base

def write_fasta(alig_reg_start,alig_reg_end,SEQ,last_strand,file_outfa):
    if last_strand=='-':
       SEQ=complement(SEQ)
    file_outfa.write('>'+str(alig_reg_start)+'_'+str(alig_reg_end)+'\n'+SEQ+'\n')
    return SEQ

def complement(seq):
    return seq.translate(maketrans('ACGTacgtRYMKrymkVBHDvbhd', 'TGCAtgcaYRKMyrkmBVDHbvdh'))

def read_fa(neoy):
    with open(neoy,'r') as file_neoy:
        seq=''
        for line in file_neoy:
            line=line.strip()
            seq=seq+line
    file_neoy.close()
    return seq

def write_fa(faseq,fa_length,outfile):
    outfile.write('>new_chr4\n')
    line_len=100
    line_num=fa_length/line_len
    for i in range(line_num):
        start=i*line_len
        end=(i+1)*line_len
        if end <= fa_length:
           line_seq=faseq[start:end]+'\n'
           outfile.write(line_seq)
        else:
           line_seq=faseq[start:fa_length]
           outfile.write(line_seq)




@click.command()
@click.option('--site')
@click.option('--neoy')
@click.option('--outneoy')
@click.option('--outfa')
@click.option('--outreg')

def main(site,neoy,outneoy,outfa,outreg):
    ### file handle
    file_outneoy=open(outneoy,'w')
    file_outfa=open(outfa,'w')
    file_outreg=open(outreg,'w')
    ### default value
    null_reg_start=0
    null_reg_end=0
    alig_reg_start=0
    alig_reg_end=0
    last_strand='0'
    SEQ=''
    neoy_newseq=''
    ### get old neoy seq
    neoy_oldfa=read_fa(neoy)
    neoy_oldfa_length=len(neoy_oldfa)
    print('get old neo seq done!')
    ### read site/lst file
    with open(site,'r') as file_site:
        for line in file_site:
            Line=line.strip().split()
            pos=int(Line[5])
            ref_base=Line[6]
            strand=Line[7]
            alt_snp=Line[8]
            alt_indel=Line[9]
            alt_sv=Line[10]
            new_base=get_changed_base(ref_base,alt_snp,alt_indel,alt_sv)
            ### new aligned block
            if pos > alig_reg_end+1:
               ### print out last sequence and create new sequence
               if SEQ:
                  new_SEQ=write_fasta(alig_reg_start,alig_reg_end,SEQ,last_strand,file_outfa)
                  neoy_newseq=neoy_newseq+new_SEQ
               SEQ=''
               SEQ=SEQ+new_base
               ### cordination of unaligned region 
               null_reg_start=alig_reg_end+1
               null_reg_end=pos-1
               out_reg_line=str(null_reg_start)+'\t'+str(null_reg_end)+'\n'
               file_outreg.write(out_reg_line)
               neoy_newseq=neoy_newseq+neoy_oldfa[null_reg_start-1:null_reg_end]
               ### cordination of aligned region
               alig_reg_start=pos
               alig_reg_end=pos
               ### new strand
               last_strand=strand
            ### may continue aligned block
            if pos==alig_reg_end+1:
               ### true continue aligned block
               if strand==last_strand:
                  alig_reg_end=pos
                  SEQ=SEQ+new_base
               ### new aligned block
               else:
                   if SEQ:
                      new_SEQ=write_fasta(alig_reg_start,alig_reg_end,SEQ,last_strand,file_outfa)
                      neoy_newseq=neoy_newseq+new_SEQ
                   SEQ=''
                   SEQ=SEQ+new_base
                   alig_reg_start=pos
                   alig_reg_end=pos
                   last_strand=strand
    new_SEQ=write_fasta(alig_reg_start,alig_reg_end,SEQ,last_strand,file_outfa)
    neoy_newseq=neoy_newseq+new_SEQ
    if alig_reg_end+1 <= neoy_oldfa_length:
        neoy_newseq=neoy_newseq+neoy_oldfa[alig_reg_end:]
    write_fa(neoy_newseq,neoy_oldfa_length,file_outneoy)
    file_outneoy.close()
    file_outfa.close()
    file_outreg.close()
    file_site.close()
if __name__=='__main__':
    main()


