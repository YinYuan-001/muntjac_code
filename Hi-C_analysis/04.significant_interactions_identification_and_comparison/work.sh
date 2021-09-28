HiC-Pro(version 2.11.1)
python(version 2.7)
fithic(version 1.13)

##This step change format to fithic input format from HiC-Pro software output;Input file is 20kb resolution Hic-pro output format matrix file;Output file is 20kb resolution fithic input format file;
python hicpro2fithic.py -i hjf_20000.matrix -b hjf_20000_abs.bed -s hjf_20000_iced.matrix.biases;


##This step calculate significant_interactions by fithic software;Input file is fithic input format file species name and resolution;Output file is significant interactions;
fithic -f fithic.fragmentMappability.gz -i fithic.interactionCounts.gz -t fithic.biases.gz -o fithic -l hjf -v -x All -r 20000;


##This step filter significant interactions by pvalue,qvalue and count number;Input file is significant interactions;Output file is filtered significant interactions;
python runfilterpvalue.qvalue.count.py hjf.spline_pass1.res20000.significances.txt.gz hjf.spline_pass1.res20000.significances.txt.bed
