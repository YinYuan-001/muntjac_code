MUSCLE 3.8.31
RAxML 8.2.10

#### step 1: We did multiple sequence alignment using muscle. The input file contains mitochondrial genome sequence of nine species including cattle, reindeer, milu deer, white lipped deer, Indian muntjac, Chinese water deer, Chinese muntjac, black muntjac and Gongshan muntjac. The alignment output file was converted into phy format.

muscle -in all.fa -out all.afa
python afa2phy.py all.afa all.phy

#### step 2: We reconstructed the phylogenetic tree using RAxML. 

/raxmlHPC-PTHREADS-AVX -M -m GTRGAMMA -p 12345 -o NC_006853.1 -s all.phy -n T31
/public/home/chenlei/software/standard-RAxML-8.2.10/raxmlHPC-PTHREADS-AVX -m GTRGAMMA -p 12345 -b 12345 -# 100 -s all.phy -n T14
/public/home/chenlei/software/standard-RAxML-8.2.10/raxmlHPC-PTHREADS-AVX -m GTRCAT -p 12345 -f b -t RAxML_bestTree.T31 -z RAxML_bootstrap.T14 -n T15
