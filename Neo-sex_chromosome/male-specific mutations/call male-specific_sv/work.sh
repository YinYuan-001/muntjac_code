bwa (0.7.17)
sniffles (1.0.11)
samtools (1.6)
vcftools  (v0.1.13)

#### step 1: We aligned the pacbio reads of BMM on the reference genome of BMF using bwa to call structure variations (SVs) using sniffle.
bwa index -a bwtsw BMF.fa 
bwa mem -t 37 -M -x pacbio BMF.fa  BMM.PacBio.fa > tmp.sam
samtools view -@ 37 -bS tmp.sam > tmp.bam
samtools sort -@ 37 tmp.bam > BMM_PacBio.toBMF.bam
samtools index -@ 37 BMM_PacBio.toBMF.bam
sniffles --cluster --cluster_support 3 -l 5 --report_seq -t 88 -m BMM_PacBio.toBMF.bam -v BMM_PacBio.toBMF.vcf

#### step 2: We obtained the heterozygous SVs and the reads name supporting these heterozygous SVs. According to reads name, we extracted the alignment results of these reads from the previous bam file "BMM_PacBio.toBMF.bam". We further extracted the alignment results which matched on the male-specific SNPs/Indels sites. The pipeline generating the male-specific SNPs/Indels (merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf) is in the directory "call male-specific mutations\male-specific_snp_indel\work.sh". 

grep '^#' BMM_PacBio.toBMF.vcf > BMM_PacBio.toBMF.hete.vcf
awk '$10~/0\/1/{print$0}' BMM_PacBio.toBMF.vcf >> BMM_PacBio.toBMF.hete.vcf

python get_sv_reads_name.py --invcf  BMM_PacBio.toBMF.hete.vcf --rdlist BMM_PacBio.toBMF.hete.readname.list
java -jar picard.jar FilterSamReads I=BMM_PacBio.toBMF.bam O=BMM_PacBio.toBMF.hete.readname.bam READ_LIST_FILE=BMM_PacBio.toBMF.hete.readname.list SO=coordinate

grep -v '^#'  merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf | awk '{print$1"\t"$2"\t"$2}'  > merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.bed
samtools view -b --threads 1 -L merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.bed -o BMM_PacBio.toBMF.hete.readname.snpindel.bam BMM_PacBio.toBMF.hete.readname.bam

#### step 3: We called SNPs using the extracted BMM_PacBio.toBMF.hete.readname.snpindel.bam file.
java -jar  picard.jar AddOrReplaceReadGroups INPUT=BMM_PacBio.toBMF.hete.readname.snpindel.bam OUTPUT=BMM_PacBio.toBMF.hete.readname.snpindel.rg.bam RGID=BMM_PB RGLB=BMM_PB RGPL=illumina RGSM=BMM_PB RGPU=H0164ALXX140820.2 SORT_ORDER=coordinate CREATE_INDEX=true    ## add reads group information

samtools mpileup -ugf BMF.fa -t DP -t SP BMM_PacBio.toBMF.hete.readname.snpindel.rg.bam | bcftools call -vmO z -o BMM_PacBio.toBMF.hete.readname.snpindel.rg.vcf   ## call snp/indels using samtools and bcftools. the input file is the BMF reference file "BMF.fa" and the bam file "BMM_PacBio.toBMF.hete.readname.snpindel.rg.bam" obtained above.

#### step 4: We filtered these SNP from PacBio reads according to the DP values and then compared them with the male-specific SNPs from illumina reads. Only the SNPs at the same site with one male-specific SNPs from illumina reads were remained for subsequent analysis.  

vcftools --vcf BMM_PacBio.toBMF.hete.readname.snpindel.rg.vcf --remove-indels --recode --recode-INFO-all --min-meanDP 4.0  --max-meanDP 120.0 --out BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter  ## the output file is BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.vcf
sed -i '1,38d' BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.vcf 
python 07.select_by_dp4.py --vcfin BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.vcf --vcfout BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.bydp4.vcf

python 08.1.select_snp_site.py --refsnp merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf --candsnp BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.bydp4.vcf --outsnp BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.bydp4.overlapsnp.vcf

#### step 5: According to the SNPs from PacBio, we filtered the heterozygous SVs to produce the male-specific SVs. Next we merged the male-specific SNPs/indels from illumina reads and the male-specific SVs from PacBio reads.

python  08.2.select_sv.py --snp BMM_PacBio.toBMF.hete.readname.snpindel.rg.filter.recode.bydp4.overlapsnp.vcf --sv BMM_PacBio.toBMF.hete.vcf --outsv BMM_PacBio.toBMF.hete.malsp.vcf --stat BMM_PacBio.toBMF.hete.malsp.stat

cat  merge.BMF_BMM_GMtoBMF.sort.dedup.malsp.vcf  BMM_PacBio.toBMF.hete.malsp.vcf  > all.male-specific_mutations.vcf







 

