last(version 867)
clustalw-2.1
RAxML-8.2.10

### step 1: We aligned the genomes of eight query species to the cattle reference genome using last. The query species include reindeer, milu deer, white lipped deer, Indian muntjac, Chinese water deer, Chinese muntjac, black muntjac and Gongshan muntjac. The input file is the reference genome sequence file and the query genome sequence file. The output file is the alignment results in maf file.

lastdb -uNEAR -cR11 cattle.db cattle.fa
lastal -P20 -m100 -E0.05 cattle.db query.fa |last-split -m1 > query.cattle.maf    
maf-swap query.cattle.maf  | last-split  |maf-sort > query.cattle.swap.maf  
perl  perl maf.rename.species.S.pl query.cattle.swap.maf  cattle query query.cattle.swap.name.maf  

### step 2: This step merges many pairwied maf files into one. Input file is the genomes of cattle and query species alignment result file(maf format) ;Output file is the maf file with cattle and all query genome alingment result; 
multiz M=1 query1.cattle.swap.name.maf query2.cattle.swap.name.maf 0 all > tmp1.maf;
multiz M=1 tmp1.maf query3.cattle.swap.name.maf 0 all > tmp2.maf   ## Successively, we obtained the last multi-alignment maf file (all.merged.maf) which contains all query and cattle geome sequence. 

### step 3: This step extract the 4DTV sites of cattle genome (ARS-UCD1.2) into a gff file. the Input files include the filtered gene annotation gff file in which only the coding gene and its longest transcript is retained and the genome fasta file.
perl get_4Dsite.pl cattle_ARS-UCD1.2.chrnum.fa GCF_002263795.1_ARS-UCD1.2_genomic.check.filter.gff GCF_002263795.1_ARS-UCD1.2_genomic.check.filter.4Dsites.gff


####step 4: This step catches the 4DTV sequence in gene region according to cattle 4DTV position information gff file;Input file are the lst file transformed from the merged maf file and cattle 4DTV position information file;Output file is the sequence of each gene that in the gff file(fasta format); This step also merges 4DTV sequence files to one fasta file.

perl 01.convertMaf2List.pl all.merged.maf cattle
perl 02.lst2gene.pl cattle  GCF_002263795.1_ARS-UCD1.2_genomic.check.filter.4Dsites.gff
perl cat_genes.pl;    ## the output file is named as "all.merged.maf.lst.4Dsites.fa"

####step 5: We reconstructed the phylogeny tree. The input file is the 4Dsites sequence and the output file is the  RAxML_bestTree.all.merged.maf.lst.4Dsites.phb
clustalw2 -INFILE=all.merged.maf.lst.4Dsites.fa -CONVERT -OUTFILE=all.merged.maf.lst.4Dsites.phy -OUTPUT=PHYLIP 
raxmlHPC-PTHREADS-AVX -T 10 -f a -k -s all.merged.maf.lst.4Dsites.phy -n all.merged.maf.lst.4Dsites.phb -m GTRGAMMAI -x 271828 -N 200 -p 31415 -o Cattle

