lastal  (version802)
mcscan   (https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))

## abbreviation of species
CWD: Chinese water deer
CM: Chinese muntjac
BMF: female black muntjac
BMM: male black muntjac

#### step 1: We did pair-wised alignment between cattle and CWD, CWD and CM, CM and BMF, BMF and BMM using lastal and obtained the output maf files and transformed record files.  
lastdb -uNEAR -cR11 -P5 cattle.db cattle.fa
lastal  -P2 -m100 -E0.05 cattle.db CWD.fa | last-split -m1 > cattle.CWD.maf
maf-swap cattle.CWD.maf | last-split > cattle.CWD.swap.maf
perl maf.rename.species.S.pl cattle.CWD.swap.maf cattle CWD cattle.CWD.swap.name.maf
maf2region_lzs.pl cattle.CWD.swap.name.maf cattle.CWD  ## one of the output files "cattle.CWD.record" was used to subsequent analysis. Using the same pipeline, we also obtained the "CWD.CM.record", "CM.BMF.record" and "BMF.BMM.record" 

#### step 2: We filtered small alignments using  different cutoffs for different genome pairs. Then we obtained the *.simple and *.bed files for mcscan plot
## cattle vs CWD
grep -v 'sv' cattle.CWD.record  | sed '/^\s*$/d;/\*/d' | awk '$3-$2>=8000{print$0}'| sed 's/CWD.chrX/CWD.chr35/g;s/cattle.chrX/cattle.chr30/g' > cattle.CWD.filter.record

## CWD vs CM
grep -v 'sv' CWD.CM.record | sed '/^\s*$/d;/\*/d' |awk '$3-$2>=14000{print$0}' | sed 's/CWD.chrX/CWD.chr35/g;s/CM.chrX/CM.23/g' > CWD.CM.filter.record 

## CM vs BMF
grep -v 'sv' CM.BMF.record | sed '/^\s*$/d;/\*/d' |awk '$3-$2>=35000{print$0}' | sed 's/CM.chrX/CM.chr23/g;s/BMF.chrX+4/BMF.chr4/g'  > CM.BMF.filter.record 

## BMF vs BMM
grep -v 'sv' BMF.BMM.record | sed '/^\s*$/d;/\*/d' |awk '$3-$2>=55000{print$0}'  | sed 's/BMF.chrX+4/BMF.chr4/g;s/BMM.chrX/BMM.chr5/g' > BMF.BMM.filter.record
 
awk '{print $1"_"$2"\t"$1"_"$3"\t"$6"_"$7"\t"$6"_"$8"\t500\t"$9}' cattle.CWD.filter.record> cattle.CWD.simple   ## Using the same method, we also obtained the "CWD.CM.simple", "CM.BMF.simple" and "BMF.BMM.simple".
awk '{print $1"\t"$2-1"\t"$2+1"\t"$1"_"$2"\t0\t"$4"\n"$1"\t"$3-1"\t"$3+1"\t"$1"_"$3"\t0\t"$4}' cattle.CWD.filter.record> cattle.CWD.CWD.bed  ##Using the same method ,we alsome obtained the "CWD.CM.CM.bed", "CM.BMF.BMF.bed" and "BMF.BMM.BMM.bed"
awk '{print $6"\t"$7-1"\t"$7+1"\t"$6"_"$7"\t0\t"$9"\n"$6"\t"$8-1"\t"$8+1"\t"$6"_"$8"\t0\t"$9}' cattle.CWD.filter.record> cattle.CWD.cattle.bed  ## Using the same method, we also obtained the  "CWD.CM.CWD.bed", "CM.BMF.CM.bed" and "BMF.BMM.BMF.bed"

#### step 3: We plot the chromosome synteny between the cattle, CWD, CM, BMF and BMM using mcscan.
cat cattle.CWD.CWD.bed CWD.CM.CWD.bed > merged.CWD.bed
cat CWD.CM.CM.bed CM.BMF.CM.bed > merged.CM.bed
cat CM.BMF.BMF.bed BMF.BMM.BMF.bed > merged.BMF.bed

python -m jcvi.graphics.karyotype seqids.sort layout

## the content of file seqids.sort
chr19,chr10,chr1,chr29,chr16,chr8,chr12,chr6,chr4,chr13,chr26,chr28,chr25,chr18,chr9,chr20,chr21,chr27,chr15,chr17,chr5,chr22,chr24,chr7,chr3,chr11,chr2,chr14,chr23,chr30
chr18,chr5,chr27,chr29,chr12,chr17,chr8,chr19,chr30,chr2,chr9,chr7,chr33,chr20,chr22,chr15,chr16,chr32,chr31,chr11,chr6,chr14,chr26,chr21,chr23,chr3,chr1,chr24,chr4,chr25,chr34,chr13,chr10,chr28,chr35
chr17,chr8,chr18,chr5,chr19,chr9,chr16,chr21,chr6,chr2,chr14,chr13,chr15,chr11,chr10,chr7,chr20,chr4,chr1,chr3,chr12,chr22,chr23
chr1,chr2,chr3,chr4
chr1,chr2,chr3,chr4,chr5

## the content of layout
# y, xstart, xend, rotation, color, label, va,  bed
 .9,     .1,    .8,       0,      , Cattle, top, cattle.CWD.cattle.bed
 .7,     .1,    .8,       0,      , CWD, top, merge.CWD.bed
 .5,     .1,    .8,       0,      ,CM,   top, merge.CM.bed
 .3,     .1,    .8,       0,      ,BMF,  top, merge.BMF.bed
 .1,     .1,    .8,       0,      ,BMM,  top, BMF.BMM.BMM.bed
# edges
e, 0, 1, cattle.CWD.simple
e, 1, 2, CWD.CM.simple
e, 2, 3, CM.BMF.simple
e, 3, 4, BMF.BMM.simple








