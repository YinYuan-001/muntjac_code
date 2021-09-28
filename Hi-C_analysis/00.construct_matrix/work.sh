HiC-Pro(version 2.11.1)
python(version 2.7)

##This step convert matrix from HiC-Pro software output to dense format matrix;Input file is Hic-pro output format matrix file;Output file is each chromosome 100kb,40kb and 20kb dense format matrix file;
for i in {100000,40000,20000};
do
python sparseToDense.py -b zz_'$i'_abs.bed  zz_'$i'_iced.matrix --perchr
done
