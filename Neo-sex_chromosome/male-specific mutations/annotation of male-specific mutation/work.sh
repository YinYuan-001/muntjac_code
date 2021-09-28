snpEff  (4.1)


####step 1:  We annotated male-specific mutations using snpEff. The input files include BMF reference genome fasta file, BMF gene annotation gff file and the male-specific mutations vcf file. The output file is a vcf file containing the annotation information of each mutation. 
java -Xmx30g -jar snpEff.jar build -gff3 -v BMF -c snpEff.config

## the content of the snpEff.config
# BMF genome, version 1.0
BMF.genome : BMF
data.dir=./data


java -Xmx30g -jar snpEff.jar -c snpEff.config BMF all.male-specific_mutations.vcf > all.male-specific_mutations.annotation.vcf




