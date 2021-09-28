lastal  (version802)

#### step 1: We aligned the neo-Y chromosomes of BMM genome to its homologues in BMF genome. The input files include fasta file containg neo-Y chromosome sequence and fasta file containing neo-X chromosome and short arm of 1 chromosome (1p) sequence. The output file is the alignment results in maf format. 
lastdb -uNEAR -cR11 -P5 neoY.db neoY.fa
lastal  -P2 -m100 -E0.05 neoY.db neoX_and_1p.fa | last-split -m1 > neoY.neoX_and_1p.maf
maf-swap neoY.neoX_and_1p.maf | last-split > neoY.neoX_and_1p.swap.maf

#### step 2: We converted the maf file into lst format and incorporated male-specific mutations. The input files include the maf file obtained in the last step, male-specific SNP, indel and SV vcf files.
python convertMaf2List.py --maf neoY.neoX_and_1p.swap.maf --lst neoY.neoX_and_1p.swap.lst
python  merge_maf_snp_indel_sv.py --lst neoY.neoX_and_1p.swap.lst --snp merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.snp.vcf  --indel merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.indel.vcf  --sv BMM_PacBio.toBMF.hete.malsp.vcf  --out  neoY.neoX_and_1p.swap.snp_indel_sv.lst
awk '\$6!="-"{print\$0}'  neoY.neoX_and_1p.swap.snp_indel_sv.lst > neoY.neoX_and_1p.swap.snp_indel_sv.lst.tmp
sort -n -k 6,6 neoY.neoX_and_1p.swap.snp_indel_sv.lst.tmp > neoY.neoX_and_1p.swap.snp_indel_sv.lst

#### step 3: We replaced the sequence in old neo-Y using male-specific mutations. The input files include the lst file obtained in the last step, the fasta file of old neo-Y. The output files include the fasta file of new neo-Y sequence and other two files for checking.
python get_neoy_step1.py --site neoY.neoX_and_1p.swap.snp_indel_sv.lst --neoy neoY.fa --outneoy new_neoY.fa --outfa neoY.neoX_and_1p.matched.fa --outreg neoY.neoX_and_1p.unmatched.region