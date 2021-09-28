Pastis(version 1.01)
HiC-Pro(version 2.11.1)
faSize(ucsc_tools)
python(version 2.7)

##This step convert matrix from HiC-Pro software output to dense format matrix;Input file is 1Mb resolution Hic-pro output format matrix file;Output file is whole genome 1Mb dense format matrix file;
python /HiC-Pro_2.11.1/bin/utils/sparseToDense.py -b hjf_1000000_abs.bed hjf_iced_3d.matrix


##This step is to prepare the configuration file of chromosome length;The input file is chromosome genome fasta;The Output file is configuration genome length file;
faSize -detailed hjf.genome.fa > hjf.genome.fa.length
awk '{print $2/100}' hjf.genome.fa.length > tmp.tmp.test


##This step is to prepare the configuration file of npy format matrix.Input file is whole genome 1Mb dense format matrix file;Output file is npy format matrix;
python runchangematrix23Dmodel.py zz_1000000_dense.matrix zz_1000000_dense.change.matrix.npy


##This step identify 3D structure model;Input file is config.ini file;Outputfile is 3D structure pdb file.The config file is config.ini;below is four model to identify 3D model structure;
pastis-mds .;
pastis-pm1 .;
pastis-nmds .;
pastis-pm2 .;
