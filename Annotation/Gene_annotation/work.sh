AUGUSTUS(version 2.5.5)
glimmerHMM(veriosn 3.0.3)
GENSCAN(version 1.0)
SNAP(version 2006-07-28)
TBLASTN
GeneWise(version 2.2.0)
EVidenceModeler(EVM version 1.1.1)

##De novo gene prediction

##This step run the de novo gene prediction by augustus;Input file is the repeatmasked genome;Output file is the result file;
augustus --species=human --AUGUSTUS_CONFIG_PATH=augustus.2.5.5/config/ --uniqueGeneId=true --noInFrameStop=true --gff3=on --strand=both 1.masked.fasta > 1.augustus

##This step convert the Augustus prediction result to gff format;Input file is the augustus file prodeced by last step;Output file is the gff file;
perl ./script/Convert_Augustus.pl 1.augustus > 1.augustus.gff

##This step run the de novo gene prediction by genscan;Input file is the repeatmasked genome and HumanIso.smat;Output file is the result file;
genscan genscan/HumanIso.smat 1.masked.fasta > 1.genscan

##This step convert genscan result to gff format;Input file is the genscan result file;Output file is the gff file;
perl ./script/predict_convert_new.pl --predict genscan --backcoor --final G -outdir ./ 1.genscan

##This step filter and check the gff file;Input file is the gff file and repeatmasked fasta file;Output file is the checked gff file;
perl ./script/Check_GFF.pl -check_cds -mini_cds 150 -cds_ns 10 -outdir ./ 1.result.gff 1.masked.fasta

##This step run the de novo gene prediction by glimmerhmm;Input file is the repeatmasked genome and human trained dataset;Output file is the gff file;
glimmerhmm 1.masked.fasta -d GlimmerHMM/trained_dir/human -f -g > 1.gff

##This step change the glimmerHMM result to normal gff format;Input file is the result file produced by last step;Output file is the normal gff file;
perl ./script/glimmerHMM_change.pl 1.gff > 1.glimmer.gff

##This step run the de novo gene prediction by snap;Input file is the repeatmasked genome and mammal trained dataset;Output file is the snap file;
snap -gff snap/HMM/mam54.hmm 1.masked.fasta > 1.snap

##This step change the snap result to normal gff format;Input file is the result file produced by last step;Output file is the normal gff file;
perl ./script/SNAP_change.pl 1.snap > 1.snap.gff


##Homology-based gene prediction

##This step aligned protein sequences of the reference gene set to genome;Input file is the genome fasta and ref protein sequences file;Output file is the aligned file;
blastall -F F -m 8 -p tblastn -e 1e-05 -d 1.fasta -i ref.pep -o 1.blast;

##This step run the solar for the aligned result;Input file is the blast file produced by last step;Output file is the solar file;
perl ./script/solar.pl -a prot2genome2 -z -f m8 1.blast > 1.blast.solar

##This step subject retrieved sequences to perform more precise alignment;Input file is the protein sequences and aligned genome sequences;Output file is the genewise file;
genewise -trev -sum -genesf -gff ref.gene.pep genome.gene.fasta > 1.blast.solar.genewise

##This step convert genewise result to gff format;Input file is the genewise file produced by last step,length information file;Output file is the gff format result;
perl ./script/gw2gff.pl 1.blast.solar.genewise 1.len > 1.blast.solar.genewise.gff


##Integrate the genes predicted by De novo and homology approaches;

##cat De novo result
cat augustus.gff.check.gff genscan.gff.check.gff glimmerHMM.change.gff snap.gff > denovo_all_prediction.gff

##convert de novo result to gff3 format
perl ./script/denovo_change_2_gff3.pl denovo_all_prediction.gff > denovo_all_prediction.gff3

##convert homology result to gff3 format
perl ./script/homolog_change_2_gff3.pl homolog.genewise.gff > homolog.genewise.gff3(protein_alignment_change.gff3)

##This step partition the Input file for EVM
perl EVidenceModeler-1.1.1/EvmUtils/partition_EVM_inputs.pl --genome genome.fasta --gene_predictions denovo_prediction_change.gff3 --protein_alignments protein_alignment_change.gff3 --segmentSize 5000000 --overlapSize 10000 --partition_listing  partitions_list.out

##This step create the commands then run these commands
perl EVidenceModeler-1.1.1/EvmUtils/write_EVM_commands.pl --genome genome.fasta --weights weights --gene_predictions denovo_prediction_change.gff3 --protein_alignments protein_alignment_change.gff3 --output_file_name evm.out --partitions partition/partitions_list.out >commands.list

##This step combine result produced by last step;
perl EVidenceModeler-1.1.1/EvmUtils/recombine_EVM_partial_outputs.pl --partition partitions_list.out --output_file_name evm.out

##This step convert result produced by last step to gff3 format;
perl EVidenceModeler-1.1.1/EvmUtils/convert_EVM_outputs_to_GFF3.pl --partition partitions_list.out --output_file_name evm.out --genome genome.fasta

##This step Get the cds sequence by gff file;Input file is the gff3 file and genome fasta;Output file is the cds file;
perl ./script/getGene.pl --posformat gff EVM.out.gff3 genome.fasta > EVM.out.cds

##This step translate the cds to protein sequnence;Input file is the cds file produced by last step;Output file is the protein sequence file;
perl ./script/cds2aa.pl EVM.out.cds > EVM.out.pep
