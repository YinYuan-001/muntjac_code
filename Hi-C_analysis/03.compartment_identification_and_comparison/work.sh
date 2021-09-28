cworld-dekker-master(version 1.00)
python(version 2.7)


##This step convert matrix from HiC-Pro software output to insulation format matrix;Input file is -i with each chromosome 100kb resolution dense format matrix file,-g with species name,-c with chromosome number and -o with output prefix and -s with resolution;Output file is each chromosome 100kb insulation format matrix file;
python runchangematrix.insulation.py -i hjf_100000_iced_hjf_chr1_dense.matrix -g hjf -c chr1 -o hjftohjf -s 100000


##This step performs a PCA analysis on the input matrix;Input file is each chromosome 100kb insulation format matrix file and gene annoation file;Output file is compartment A and B region with;
perl matrix2compartment.pl -i hjf_100000_iced_hjf_chr1_dense.matrix.insulation.matrix -o 1 --et;
python matrix2EigenVectors.py -i 4.zScore.matrix.gz -r EVM.out.cor.gff3.bed -v;
