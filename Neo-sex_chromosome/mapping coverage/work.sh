bwa  (0.7.17)
samtools (1.6)
igvtools  (2.3.63)
UCSC tools (http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/)
#### step 1: We mapped the illumina reads from individual BMF2 and BMM2  on the BMF reference genome using bwa.
bwa index  -a bwtsw BMF.fa
bwa mem -t 20 -M -R "@RG\tID:hj\tLB:hj\tPL:ILLUMINA\tSM:BMF2" BMF.fa BMF2.R1.fq.gz BMF2.R2.fq.gz | samtools sort -o BMF2toBMF.sort.bam -T tmpdir1 --threads 20 -O bam -   ## Using the same method, we also obtained the "BMM2toBMF.sort.bam"

#### step 2: We calculated the mapping coverage using igvtools
samtools faidx BMF.fa
samtools index -@ 27 BMF2toBMF.sort.bam
igvtools count -w 500000  BMF2toBMF.sort.bam BMF2toBMF.sort.cov.wig BMF.fa  
wigToBigWig BMF2toBMF.sort.cov.wig BMF.size BMF2toBMF.sort.cov.BigWig 
bigWigToBedGraph BMF2toBMF.sort.cov.BigWig BMF2toBMF.sort.cov.BedGraph ## Using the same method, we also obtained the "BMM2toBMF.sort.cov.BedGraph"

#### step 3: We normalized the mapping coverage.
python log_maxmin_normalization.py --filein BMF2toBMF.sort.cov.BedGraph --fileout BMF2toBMF.sort.cov.nor.txt --cutoff 55
python log_maxmin_normalization.py --filein BMM2toBMF.sort.cov.BedGraph --fileout BMM2toBMF.sort.cov.nor.txt --cutoff 63