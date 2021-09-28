axtChain(ucsc_tools)
mafToPsl(ucsc_tools)
bedtools(version2.27.1)
liftOver(ucsc_tools)

##This step change maf file to two species mapping bed file.below steps is a demo at 20kb resolution for species maf file change to two species bin-bin mapping file.

##This step change maf file to chain file;Input file is maf_file and two species name in maf file;Output file is two species chain file;
mafToPsl species1 species2 maf_file output.psl;
axtChain -linearGap=medium -psl output.psl -faQ ref2 -faT ref1 spe1'_'spe2.chain;

##This step generate 20kb solution bed file;Input file is genomesize file from faSize software;Output file is species 20kb step window file;
bedtools makewindows -g genomesize -w 20000 -i srcwinnum > spe1.bed;

##This step generate mapping file at 20kb resolution;Input file is 20kb step window file and two species chain file;Output file is mapping bin-bed file and none mapping bed file;
liftOver spe1.bed -s spe1'_'spe2.chain map.loc unmap.bed -minMatch=0.85;

##This step use an Approach to rounding to make mapping bed file from bin-bed to bin-bin.Input file is mapping bed file,Output file is bin2bin file;The test file is in scripts for this step.
python runbedtobin.py -i map.loc -s 20000 -o outputfile;
