TRF(version 4.07b)
RepeatProteinMask(version open-4.0.6)
RepeatMasker(version 4.0.5)
LTR_FINDER
RepeatModeller(version 1.0.4)

##This step predict the LTR;Input file is fasta file;Output file is the ltr_finder file;
ltr_finder -w 2 -s LTR_FINDER.x86_64-1.0.5/tRNAdb/Bos_taurus.tRNA.fa fasta.1 1>fasta.1ltr_finder

##This step convert result to gff format;Input file is the ltr_finder file produced by last step;Out put file is the gff file;
perl Ltr2GFF.pl fasta.1ltr_finder > fasta.1.ltr.gff

##This step get the repeat seq;Input file is the fasta file and gff file;Output file is the LTR seq file;
perl getTE.pl fasta.1.ltr.gff fasta.1> fasta.1.LTR.fa

##This step annotate the tandem repeats of genome sequence;Input file is the fasta file;Output file is the dat file;
trf fasta.1 7 7 80 10 50 2000 -d -h

##This step annotate the TE-relevant protein;Input file is the fasta file;Output file is the annot file;
RepeatProteinMask -noLowSimple -pvalue 0.0001 fasta.1

##This step build the database for RepeatModeler;Input file is the genome sequence file;Output file is the database file;
RepeatModeler/BuildDatabase -name mydb genome.fasta

##This step run the RepeatModeler;Input file is the mydb file produced by last step;Output file is the repeat seq lib file;
RepeatModeler/RepeatModeler -pa 40 -database mydb > run.out

##This step search the knonw and novel transposable elements(TE);Input file is the repeat library produced by RepeatModeler or download from database(Repbase TE library version 16.02);Output file is the out file;
RepeatMasker -nolow -no_is -norna -parallel 1 -lib lib.file fasta.1 

##This step convert annotation result into gff format;Input file is result file produced by trf/RepeeatPorteinMask/RepeatMasker;Output file is the gff file;
perl ./script/repeat_to_gff.pl OUT_Prefix 1.file(dat/annot/out)

##This step statistic the repeat region in genome;Input file is the gff annotation result produced by above software;Output file is the stat result;
perl ./script/stat.pl -denovo -trf -repeatmasker -proteinmask genome.fasta;

##This step mask the repeat region in genome(convert the nucleotide to N);Input file is the genome fasta and merged repeat annotation gff file;Output file is the masked genome fasta;
perl ./script/remask.pl genome.fa all.repeat.gff
