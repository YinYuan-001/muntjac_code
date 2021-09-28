hisat2 （2.1.0）

#### step 1: We aligned the RNA-seq reads of BMM4 to the BMF reference genome using hisat2.
hisat2-build -f  BMF.fa BMF
hisat2 -x BMF --new-summary -p 5 --dta -1 BMM4.R1.fq -2 BMM4.R2.fq -S BMM4toBMF.sam
samtools sort -o BMM4toBMF.bam  -T BMM4  --threads 5 -O bam BMM4toBMF.sam

#### step 2: We counted the reads number supporting diferent alleles based on the male-specific SNPs. The input file including the bam file obtained at the last step and the male-specific SNP vcf file. The output file contains information of the snp site, the reference and alteration and the reads counts supporting them. 
get_allelic_number_based_on_SNP.py -s merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.snp.vcf -b BMM4toBMF.bam  -l 150 -o BMM4toBMF.allelic_readscounts.txt