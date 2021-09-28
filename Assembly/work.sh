python(version 2.7)
wtdbg2(version 2.4)
smartdenovo(version 1.0)
pilon(version 1.23)
racon(version 1.21)
Nextpolish(version 1.0.1)
juicer(version 1.5)
3D-DNA(version 1.5)

##The pipeline including contig assembly , genome polish and chromosome assembly.Below are the demos for each software used in this project.

##wtdbg2:rawgenome assembly;Inputfile is raw Nanopore reads;Outputfile is raw contig assembly;
wtdbg2 -x rs -g 4.6m -i reads.fa.gz -t 16 -fo dbg
wtpoa-cns -t 16 -i dbg.ctg.lay.gz -fo dbg.raw.fa


##smartdenovo:rawgenome assembly;Inputfile is raw nanopore reads;Outputfile is raw contig assembly;
smartdenovo/smartdenovo.pl -c 1 reads.fa > wtasm.mak
make -f wtasm.mak


##racon:genome polish;Inputfile is raw contig assembly and raw nanopore reads;Outputfile is corrected contig assembly;
racon raw_nanopore.fa.gz map.bam dbg.raw.fa


##pilon:genome polish;Inputfile is raw contig assembly and Illumina reads;Outputfile is corrected contig assembly;
java -Xmx16G -jar pilon.jar --genome genome.fasta --frags frags.bam --output pilon.out


##Nextpolish:genome polish;Inputfile is raw contig assembly,Illumina reads and raw nanopore reads;Outputfile is corrected contig assembly;
nextPolish run.cfg


##juicer and 3D-DNA software:chromosome assembly;Inputfile is Hi-C data , restriction site and corrected contig assembly;Outputfile is raw chromosome assembly;
perl restriction MboI genome workdir
bash scripts/juicer.sh -d workdir -D workdir -g hjf -z hjf.fa -s MboI -y hjf_MboI.txt -p hjf.len -q high1 -l high1
bash run-asm-pipeline.sh \
-m haploid \
-i 15000 \
-r 3 \
hjf.fa \
aligned/merged_nodups.txt;
bash run-asm-pipeline-post-review.sh --sort-output -g 200 -r hjf.review.assembly hjf.fa aligned/merged_nodups.txt
