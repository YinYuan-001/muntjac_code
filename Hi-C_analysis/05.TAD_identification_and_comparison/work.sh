cworld-dekker-master(version 1.00)
python(version 2.7)


##This step convert matrix from HiC-Pro software output to insulation format matrix;Input file is each chromosome 40kb resolution dense format matrix file,species name,chromosome number , output prefix and resolution;Output file is each chromosome 40kb insulation format matrix file;
python runchangematrix.insulation.py -i hjf_40000_iced_hjf_chr1_dense.matrix -g hjf -c chr1 -o hjftohjf -s 40000


##This step calculate insulation score to identify TAD boundry;Input file is each chromosome 40kb insulation format matrix file;Output file is TAD information;
perl -I /project/software/cworld-dekker-master/lib/ matrix2insulation.pl -i hjm_chr5_40000.insulation.matrix --is 1000000 --ids 240000
