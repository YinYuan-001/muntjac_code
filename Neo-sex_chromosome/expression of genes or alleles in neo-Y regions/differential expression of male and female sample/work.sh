hisat2 (2.1.0)
DESeq2

#### step 1：We aligned the RNA-seq reads from BMF4 and BMM4 to the BMF reference genome,respectively using hisat2. The input files are BMF.fa and fastq files. The output file are bam files.
hisat2-build -f  BMF.fa BMF
hisat2 -x BMF --new-summary -p 5 --dta -1 BMF4.R1.fq -2 BMF4.R2.fq -S BMF4toBMF.sam
samtools sort -o BMF4toBMF.bam  -T BMF4  --threads 5 -O bam BMF4toBMF.sam  ##Using the same method, we also obtained the "BMM4toBMF.bam".  

#### step 2: We counted the reads  mapped on each gene using featureCounts. The input files are BMF gene annotations gffs file and the bam files obtained at the last step. The output file is the featureCounts results.
featureCounts -p -a BMF.gff3 -t gene -g ID -o BMF4toBMF.counts.txt BMF4toBMF.bam  ##Using the same method, we also obtained the "BMM4toBMF.counts.txt"

#### step 3: We calculated the difference of BMF gene expression between BMF4 (female) and BMM4 (male) samples. The input files are the featureCounts results obtained at the last step. The output file is the gene expression and expression difference in BMF4  and BMM4  samples.
Rscript DESEQ.R