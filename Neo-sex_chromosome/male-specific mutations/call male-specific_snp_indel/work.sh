bwa  (0.7.17)
samtools (1.6)
gatk (4.1.2.0)
vcftools  (v0.1.13)
UCSC tools (http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/)

#### step 1: We mapped the illumina reads from individual BMF2, BMM2, BMF3, BMM3, GM1 and GM2 on the BMF reference genome using bwa.
bwa index  -a bwtsw BMF.fa
bwa mem -t 20 -M -R "@RG\tID:hj\tLB:hj\tPL:ILLUMINA\tSM:BMF2" BMF.fa BMF2.R1.fq.gz BMF2.R2.fq.gz | samtools sort -o BMF2toBMF.sort.bam -T tmpdir1 --threads 20 -O bam -   ## Using the same method, we also obtained the "BMM2toBMF.sort.bam", "BMF3toBMF.sort.bam","BMM3toBMF.sort.bam","GM1toBMF.sort.bam" and "GM2toBMF.sort.bam"

#### step 2: We called snps and indels using GATK. We then filtered the vcf files.
java -jar picard.jar CreateSequenceDictionary R=BMF.fa O=BMF.dict
gatk MarkDuplicates -I BMF2toBMF.sort.bam -O BMF2toBMF.sort.dedup.bam -M BMF2toBMF.metrix --REMOVE_DUPLICATES
samtools index BMF2toBMF.sort.bam
samtools index BMF2toBMF.sort.dedup.bam

gatk HaplotypeCaller  --emit-ref-confidence GVCF  -R BMF.fa -I BMF2toBMF.sort.dedup.bam -O BMF2toBMF.sort.dedup.gvcf
gatk GenotypeGVCFs -R BMF.fa -V BMF2toBMF.sort.dedup.gvcf -O BMF2toBMF.sort.dedup.vcf    ## Using the same method, we also obtained the "BMM2toBMF.sort.dedup.vcf", "BMF3toBMF.sort.dedup.vcf", "BMM3toBMF.sort.dedup.vcf", "GM1toBMF.sort.dedup.vcf" and "GM2toBMF.sort.dedup.vcf".

python filter.py --invcf BMF2toBMF.sort.dedup.vcf --outvcf BMF2toBMF.sort.dedup.filter.vcf  ## Using the same method, we also obtained the "BMM2toBMF.sort.dedup.filter.vcf", "BMF3toBMF.sort.dedup.filter.vcf", "BMM3toBMF.sort.dedup.filter.vcf", "GM1toBMF.sort.dedup.filter.vcf" and "GM2toBMF.sort.dedup.filter.vcf".

#### step 3 : We calculated the SNP/indels density of a female (BMF2) and a male (BMM2) black muntjac individuals. We merged the density files into one for displaying in circos.
vcftools --vcf BMF2toBMF.sort.dedup.filter.vcf   --SNPdensity 500000 --out BMF2toBMF.sort.dedup.filter
vcftools --vcf BMM2toBMF.sort.dedup.filter.vcf   --SNPdensity 500000 --out BMM2toBMF.sort.dedup.filter
sed '1,1d' BMF2toBMF.sort.dedup.filter.snpden | awk 'a=$2+499999{print$1"\t"$2"\t"a"\t"$4"\tfill_color=red"}' > BMF2toBMF.sort.dedup.filter.snpden.name
sed '1,1d' BMM2toBMF.sort.dedup.filter.snpden | awk 'a=$2+499999{print$1"\t"$2"\t"a"\t"$4"\tfill_color=blue"}' > BMM2toBMF.sort.dedup.filter.snpden.name
cat BMF2toBMF.sort.dedup.filter.snpden.name BMM2toBMF.sort.dedup.filter.snpden.name > twoBMinds.toBMF.sort.dedup.filter.snpden.name

#### step 4: We merged the six vcf files and obtained the male-sepcific snp/indels.
for sp in BMF2 BMM2 BMF3 BMM3 GM1 GM2
do
bgzip -c ${sp}toBMF.sort.dedup.vcf > ${sp}toBMF.sort.dedup.vcf.gz
tabix ${sp}toBMF.sort.dedup.vcf.gz
done
vcf-merge -d BMF2toBMF.sort.dedup.vcf.gz BMM2toBMF.sort.dedup.vcf.gz BMF3toBMF.sort.dedup.vcf.gz BMM3toBMF.sort.dedup.vcf.gz GM1toBMF.sort.dedup.vcf.gz GM2toBMF.sort.dedup.vcf.gz > merge.BMF_BMM_GMtoBMF.sort.dedup.vcf

#### step 5: We extracted the male-specific snp/indels from the merged vcf file.  Then we calculated the density of snp and indel respectively.
python get.hjm_specific_hete_site.py --invcf merge.BMF_BMM_GMtoBMF.sort.dedup.vcf  --outvcf merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf

vcftools --vcf merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf --remove-indels --recode --recode-INFO-all --out merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.snp
vcftools --vcf merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.snp.vcf --SNPdensity 500000 --out merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.snp.recode

vcftools --vcf merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf --keep-only-indels --recode --recode-INFO-all --out merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.indel
vcftools --vcf merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.indel.vcf --SNPdensity 500000 --out merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.indel.recode



