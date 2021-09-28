bowtie2 (2.2.9)
samtools (1.3.1)
bcftools (1.3.1)
PSMC (0.6.5-r67)  The scripts vcfutils.pl and psmc_plot.pl are attached by the PSMC software.

#### step 1: We aligned the illumina reads of whole genome resequencing from the BMF2 individual to the BMF reference genome using bowtie2. 
bowtie2-build BMF.fa BMF
bowtie2 -x BMF -1 BMF2.R1.fq -2 BMF2.R2.fq -S BMF2toBMF.sam -p 20

#### step 2: We called the SNPs using samtools and bcftools. The input file is the bam file containing the illumina reads alignment results. The output file is the vcf file containing the SNP information.

samtools view -bS  BMF2toBMF.sam > BMF2toBMF.bam 
samtools sort BMF2toBMF.bam > BMF2toBMF.sort.bam
samtools index BMF2toBMF.sort.bam
samtools mpileup -C50 -uf BMF.fa BMF2toBMF.sort.bam > BMF2toBMF.sort.bcf
bcftools call -c BMF2toBMF.sort.bcf > BMF2toBMF.sort.vcf

#### step 3: We calculated the population history of BMF using PSMC. The input file is the vcf file obtained at the last step. The output file is the psmc file.
perl vcfutils.pl vcf2fq -d 16 -D 100 BMF2toBMF.sort.vcf | gzip > BMF2toBMF.sort.fq.gz
fq2psmcfa -q20 BMF2toBMF.sort.fq.gz > BMF2toBMF.sort.psmcfa
psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o  BMF2toBMF.sort.psmc BMF2toBMF.sort.psmcfa

#### step 4: We plot the population history of BMF.
perl psmc_plot.pl -u 0.927e-8 -g 3 -Y 30 -p -M BMF BMF.plot BMF2toBMF.sort.psmc


#### Note: Population history of other species were also restructed using the same methods.