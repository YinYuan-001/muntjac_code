#!/usr/bin/perl
use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename);

die "Usage:perl $0  -predict genscan -backcoor -final G  predict_file sequence\n" if (@ARGV<2);
my ($Predict_prog,$Back_coor,$Final_name,$Perfect_gene);
my ($Verbose,$Help);
my $Outdir;
GetOptions(
	"predict:s" => \$Predict_prog,
	"backcoor" => \$Back_coor,
	"finalname:s"=>\$Final_name,
	"outdir:s"=>\$Outdir,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);

die `pod2text $0` if (@ARGV <1  || !$Predict_prog || $Help);

my $predict_file = shift;
my $sequence_file = shift;

$Outdir ||=".";
$Outdir=~s/\/$//;

my $predict_file_name=basename($predict_file);

my $gff_file = $Outdir."/".$predict_file_name.".gff";


my %all; ##store the main data
my %seq_len; ##store sequence length
my ($num_multi,$num_single,$num_part) = (0,0,0);#Globe para

##reading and parsing the prediction file
read_fgenesh() if($Predict_prog eq "fgenesh");
read_bgf() if($Predict_prog eq "bgf");
read_genescan() if($Predict_prog eq "genscan");
read_glean() if($Predict_prog eq "glean");

#trace coordinate back to original sequence
back_coor() if($Back_coor);

#make genome wide gene ID
final_name() if($Final_name);

## output statistic numbers
print STDERR "\n\nStatistic of gene numbers:\n" if($Verbose);
print STDERR "\nNote that the genes marked by checkcds are assigned to parital genes \n" if($Verbose);
print STDERR "\n  [total genes] = [multi-exon genes] + [singl-exon genes] + [partial genes]\n" if($Verbose);
print STDERR "  [perfect genes] = [multi-exon genes] + [singl-exon genes]\n" if($Verbose);
print STDERR "\n  total genes:      ".($num_multi+$num_single+$num_part)."\n" if($Verbose);
print STDERR "  multi-exon genes: $num_multi\n" if($Verbose);
print STDERR "  singl-exon genes: $num_single\n" if($Verbose);
print STDERR "  partial genes:    $num_part\n" if($Verbose);
print STDERR "  perfect genes:    ".($num_multi+$num_single)."\n" if($Verbose);

creat_gff();
#print Dumper %all;


##creat *.gff file, support gff3
sub creat_gff{
	my $output = "##gff-version 3\n";
	open(OUT,">".$gff_file) || die("fail to open $gff_file\n");
	foreach my $seq_name (sort keys %all) {
		my $seq_p = $all{$seq_name};
		$output .= "##sequence-region $seq_name 1 $seq_len{$seq_name}\n";
		foreach my $gene_name (sort keys %$seq_p) {
			
			my $gene_p = $seq_p->{$gene_name};
			my $strand = $gene_p->{strand};
			my (@exon,@orf,@score);
			foreach my $p (@{$gene_p->{exon}}) {
				push @exon,[$p->[0],$p->[1]];
			}
			foreach my $p (@{$gene_p->{orf}}) {
				push @orf,[$p->[0],$p->[1]];
			}
			@score = @{$gene_p->{score}};
			
			my ($gene_start,$gene_end) = ($exon[0][0] < $exon[-1][1]) ? ($exon[0][0], $exon[-1][1]) : ($exon[-1][1], $exon[0][0]);
			
			my $gene_score = (exists $gene_p->{genescore}) ? $gene_p->{genescore} : '.';
			my $type=$gene_p->{type};
			$output .= "$seq_name\t$Predict_prog\tmRNA\t$gene_start\t$gene_end\t$gene_score\t$strand\t.\tID=$gene_name;Type=$type;\n";
			for (my $i=0; $i<@exon; $i++) {
				my $phase = ($exon[$i][0] - $orf[$i][0]) % 3;
				my ($exon_start,$exon_end) = ($exon[$i][0] < $exon[$i][1]) ? ($exon[$i][0] , $exon[$i][1]) : ($exon[$i][1] , $exon[$i][0]);
				$output .= "$seq_name\t$Predict_prog\tCDS\t$exon_start\t$exon_end\t$score[$i]\t$strand\t$phase\tParent=$gene_name;\n";
			}
		
		}
	}
	print OUT $output;
	close OUT;
}

sub read_fgenesh{
	$/=" FGENESH 1.1"; 
	my $loop;
	open(PRE,$predict_file) || die("fail to open $predict_file\n");
	<PRE>;
	while (<PRE>) {
		$loop++;
		my $unit = $_;
		chomp $unit;	
		parse_fgenesh(\$unit,\%all) ;
	}
	close(PRE);
	$/="\n";
}

sub read_bgf{
	$/="Program    : BGF";  ##Program    : bgf for old version
	my $loop;
	open(PRE,$predict_file) || die("fail to open $predict_file\n");
	<PRE>;
	while (<PRE>) {
		$loop++;
		my $unit = $_;
		chomp $unit;
		parse_BGF(\$unit,\%all);	
	}
	close(PRE);
	$/="\n";
}

sub read_genescan{
	$/="GENSCAN 1.0"; 
	my $loop;
	open(PRE,$predict_file) || die("fail to open $predict_file\n");
	<PRE>;
	while (<PRE>) {
		$loop++;
		my $unit = $_;
		chomp $unit;
		parse_GeneScan(\$unit,\%all);	
	}
	close(PRE);
	$/="\n";
}



sub read_glean{
	$/="\n";
	open(PRE,$predict_file) || die("fail to open $predict_file\n");
	while (<PRE>) {
		s/^\s+//;
		my @t = split(/\t/);
		my $seq_name = $t[0];
		my $gene_name = $seq_name."_".$1 if($t[8] =~ /GenePrediction\s(\S+)$/);
		my $strand = $t[6];
		my $score = $t[5];
		my $phase = $t[7];

		if ($t[2] eq 'mRNA') {
			$all{$seq_name}{$gene_name}{genescore}=$score;
			$all{$seq_name}{$gene_name}{strand}=$strand;
			$all{$seq_name}{$gene_name}{promoter}="none";
			$all{$seq_name}{$gene_name}{polyA}="none";
		}
		if ($t[2] eq 'CDS') {
			my ($exon_start,$exon_end) = ($strand eq '+') ? ($t[3],$t[4]) : ($t[4],$t[3]);
			push @{$all{$seq_name}{$gene_name}{tempexon}}, [$exon_start,$exon_end,$phase,$score];
		}
	}
	close(PRE);

	foreach my $seq_name (sort keys %all) {
		my $seq_p = $all{$seq_name};
		foreach my $gene_name (sort keys %$seq_p) {
			my $gene_p = $seq_p->{$gene_name};
			my $strand = $gene_p->{strand};
			my (@exon,@orf,@score);
			my $gene_type;

			foreach my $p (@{$gene_p->{tempexon}}) {
				push @exon,[$p->[0],$p->[1]];
				push @score,$p->[3];
				my $exon_len = abs($p->[0]-$p->[1])+1;
				my $phase = $p->[2];
				my ($orf_start,$orf_end);
				$orf_start = ($strand eq '+') ? ($p->[0] + $phase) : ($p->[0] - $phase);
				$orf_end = ($strand eq '+') ? ($p->[1] - ($exon_len-$phase)%3 ) : ($p->[1] + ($exon_len-$phase)%3 );
				push @orf,[$orf_start,$orf_end];
			}
			
			delete $gene_p->{tempexon};

			if (@exon > 1) {
				$gene_type = "multi-exon";
				$num_multi++;

			}elsif(@exon == 1){
				$gene_type = "sigle-exon";
				$num_single++;
			}
			
			$all{$seq_name}{$gene_name}{type}=$gene_type;
			$all{$seq_name}{$gene_name}{exon}=\@exon;
			$all{$seq_name}{$gene_name}{orf}=\@orf;
			$all{$seq_name}{$gene_name}{score}=\@score;
			

		}

	}	
}


##backing coordinate onto origianal sequence
##use all global variables in this part
sub back_coor{
	
	get_seq_len();

	my $gene_frag_num = 0;
	foreach my $seq_name (sort keys %all) {
		
		next if($seq_name !~ /(\w+)_(\d+)_\d+$/); ## 
		
		my $seq_p = $all{$seq_name};
		my ($ori_seq_name,$ori_seq_start) =  ($1, $2) if($seq_name =~ /(\S+)_(\d+)_\d+$/);
		
		foreach my $gene_name (sort keys %$seq_p) {
			$gene_frag_num++;
			my $gene_p = $seq_p->{$gene_name};
			my $strand = $gene_p->{strand};
			my $type = $gene_p->{type};
			my $promoter = ($gene_p->{promoter} ne 'none') ? ($gene_p->{promoter} + $ori_seq_start -1) : $gene_p->{promoter};
			my @exon;
			foreach my $p (@{$gene_p->{exon}}) {
				push @exon,[$p->[0]+ $ori_seq_start -1, $p->[1] + $ori_seq_start -1];
			}
			my @orf;
			foreach my $p (@{$gene_p->{orf}}) {
				if ($p->[0] ne 'none') {
					push @orf,[$p->[0]+ $ori_seq_start -1, $p->[1] + $ori_seq_start -1];
				}else{
					push @orf,[$p->[0], $p->[1]];
				}
				
			}
			my @score = @{$gene_p->{score}};
			my $polyA = ($gene_p->{polyA} ne 'none') ? ($gene_p->{polyA} + $ori_seq_start -1) : $gene_p->{polyA};

			delete $all{$seq_name}{$gene_name};
			$all{$ori_seq_name}{$gene_name}{strand}=$strand;    
			$all{$ori_seq_name}{$gene_name}{type}=$type;        
			$all{$ori_seq_name}{$gene_name}{promoter}=$promoter;
			$all{$ori_seq_name}{$gene_name}{exon}=\@exon;       
			$all{$ori_seq_name}{$gene_name}{orf}=\@orf;         
			$all{$ori_seq_name}{$gene_name}{score}=\@score;     
			$all{$ori_seq_name}{$gene_name}{polyA}=$polyA;      
		}
		delete $all{$seq_name};
	}

	print STDERR "Trace back coordinate to original sequence\n"   if($Verbose);
	print STDERR "Remove redundence on the overlapped fragments:\n"   if($Verbose);
	
	
	##remove redundant genes predicted in the overlapped fragments
	##when two genes overlapped, remove the smaller one
	my $redunt_num = 0;
	foreach my $seq_name (sort keys %all) {
		
		##next if($seq_name !~ /([^_]+)_(\d+)_\d+$/); ## this is a bug line

		my $seq_p = $all{$seq_name};
		my (@pos1,@pos2);
		foreach my $gene_name (sort keys %$seq_p) {
			my $gene_p = $seq_p->{$gene_name};
			my $strand = $gene_p->{strand};
			my $gene_start = $gene_p->{exon}[0][0];
			my $gene_end = $gene_p->{exon}[-1][1];
			my $gene_len = abs($gene_end-$gene_start) + 1;
			push @pos1, [$gene_start,$gene_end,$gene_name,$seq_name] if($strand eq '+');
			push @pos2, [$gene_end,$gene_start,$gene_name,$seq_name] if($strand eq '-');
			
		}

		$redunt_num += purify_fragment(\@pos1);
		$redunt_num += purify_fragment(\@pos2);
		
	}
	my $total_gene_num = $gene_frag_num - $redunt_num;
	print STDERR "  [all the genes] - [redundant genes] = [total genes]\n" if($Verbose);
	print STDERR "  all the genes:    $gene_frag_num\n" if($Verbose);
	print STDERR "  redundant genes:  $redunt_num\n" if($Verbose);
	print STDERR "  total genes:      $total_gene_num\n" if($Verbose);
	
	
	##rename genes by sorted mark, and re-count gene numbers
	($num_multi,$num_single,$num_part) = (0,0,0);
	foreach my $seq_name (sort keys %all) {
		
		my $seq_p = $all{$seq_name};
		my $mark = keys %$seq_p;
		$mark=~tr/[0-9]/0/;
		$mark++;
		
		my %name_sort;
		foreach my $gene_name (sort keys %$seq_p) {
			if ($gene_name =~ /_(\d+)_\d+_(\d+)$/) {
				$name_sort{$1}{$2} = $gene_name;
			}
			my $type = $seq_p->{$gene_name}{type};
			if ($type eq 'multi-exon') {
				$num_multi++;
			}elsif ($type eq 'sigle-exon') {
				$num_single++;
			}else{
				$num_part++;
			}
		}

		foreach my $frag_start (sort {$a<=>$b} keys %name_sort) {
			foreach my $frag_id (sort keys %{$name_sort{$frag_start}}) {
				my $gene_name = $name_sort{$frag_start}{$frag_id};
				my $hash_p = $seq_p->{$gene_name};
				my $new_gene_name = $Predict_prog."_".$seq_name."_".($mark++);
				delete $all{$seq_name}{$gene_name};
				$all{$seq_name}{$new_gene_name} = $hash_p;
			}
		}

	}

	#print Dumper \%all;
}

##make genome wide gene ID
sub final_name {
	my $mark = "000001";
	foreach my $seq_name (sort keys %all) {
		my $seq_p = $all{$seq_name};
		foreach my $gene_name (sort keys %$seq_p) {
			my $final_name = $Final_name.$mark;
			$seq_p->{$final_name} = $seq_p->{$gene_name};
			delete $seq_p->{$gene_name};
			$mark++;
		}
	}
}



##parse the fgenesh result file, generate data structure,
##and output the protein sequences
####################################################
sub parse_GeneScan{
	my $str_p=shift;
	my $all_hp=shift;
	
	return if($$str_p =~ /NO EXONS\/GENES PREDICTED IN SEQUENCE/);

	my $cut_pos1 = index($$str_p,"\n\n 1.");
	my $cut_pos2 = index($$str_p,"Predicted peptide sequence(s):");
	my $head_part = substr($$str_p,0,$cut_pos1);
	my $gene_part = substr($$str_p,$cut_pos1,$cut_pos2-$cut_pos1);
	#my $prot_part = substr($$str_p,$cut_pos2);
	$$str_p="";

	my ($seq_name,$seq_leng) = ($1,$2) if($head_part=~/Sequence (\S+) : (\d+) bp/);
	$head_part = "";
	

	$seq_len{$seq_name} = $seq_leng;

	$gene_part=~s/^\s+//g;
	$gene_part=~s/\s+$//g;
	my @genes=split(/\n\n/,$gene_part);
	$gene_part = "";

	my $mark=@genes;
	$mark=~tr/[0-9]/0/;
	$mark++;

	foreach (@genes) {
		my ($gene_name, $strand, $type, @exon, @orf, @score, $promoter, $polyA);
		
		if (/^\s*(\d+)\.\d+\s+\w+\s+([+-])\s+/) {
			$gene_name = $Predict_prog."_".$seq_name."_".($mark++);
			$strand = $2;
		}
		if (/Init/ && /Term/) {
			$type = "multi-exon";
			$num_multi++;
		}elsif(/Sngl/){
			$type = "sigle-exon";
			$num_single++;
		}elsif(!/Init/ && /Term/){
			$type = "no-first";
			$num_part++;
		}elsif(/Init/ && !/Term/){
			$type = "no-last";
			$num_part++;
		}elsif(!/Init/ && !/Term/){
			$type = "no-first-last";
			$num_part++;
		}
		
		while (/(Init|Intr|Term|Sngl)\s+[+-]\s+(\d+)\s+(\d+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\S+/g) {
			if ($strand eq '+') {
				push @exon,[$2,$3];
			}else{
				push @exon,[$3,$2];
			}
			
			push @score,$4;
		}
		


		##caculate orf
		my $leave = 0;
		foreach my $p (@exon) {
			my $fdel = (3-$leave)%3;
			my $start = $p->[0] + $fdel;
			$leave = ( $p->[1] - $p->[0] + 1 - $fdel ) % 3;
			my $end = $p->[1] - $leave;
			if ($end - $start + 1 >= 3 ) { ##at least one codon
				push @orf,[$start,$end];
			}else{
				push @orf, ["none","none"];
			}
			
		}

		if ($strand eq '-') {
			@exon = reverse @exon;
			@orf = reverse @orf;
			@score = reverse @score;
			foreach my $p (@exon) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
			foreach my $p (@orf) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
		}
		
		if (/Prom\s+[+-]\s+(\d+)/){
			$promoter = $1;
		}else{
			$promoter = "none";
		}

		if (/PlyA\s+[+-]\s+(\d+)/) {
			$polyA = $1;
		}else{
			$polyA = "none";
		}
		
		
		$all_hp->{$seq_name}{$gene_name}{strand}=$strand;
		$all_hp->{$seq_name}{$gene_name}{type}=$type;
		$all_hp->{$seq_name}{$gene_name}{promoter}=$promoter;
		$all_hp->{$seq_name}{$gene_name}{exon}=\@exon;
		$all_hp->{$seq_name}{$gene_name}{orf}=\@orf;
		$all_hp->{$seq_name}{$gene_name}{score}=\@score;
		$all_hp->{$seq_name}{$gene_name}{polyA}=$polyA;
		

	}

}
####################################################



##parse the fgenesh result file, generate data structure,
##and output the protein sequences
####################################################
sub parse_fgenesh{
	my $str_p=shift;
	my $all_hp=shift;
	
	return if($$str_p =~ /no reliable predictions/);

	my $cut_pos1 = index($$str_p,"\n\n   1 ");
	my $cut_pos2 = index($$str_p,"Predicted protein(s):");
	my $head_part = substr($$str_p,0,$cut_pos1);
	my $gene_part = substr($$str_p,$cut_pos1,$cut_pos2-$cut_pos1);
	#my $prot_part = substr($$str_p,$cut_pos2);
	$$str_p="";

	
	my $seq_name = $1 if($head_part=~/Seq name:\s+(\S+)\s+/);
	my $seq_leng = $1 if($head_part=~/Length of sequence:\s+(\d+)\s+/);
	$head_part = "";
	

	$seq_len{$seq_name} = $seq_leng;

	$gene_part=~s/^\s+//g;
	$gene_part=~s/\s+$//g;
	my @genes=split(/\n\n/,$gene_part);
	$gene_part = "";

	my $mark=@genes;
	$mark=~tr/[0-9]/0/;
	$mark++;

	foreach (@genes) {
		my ($gene_name, $strand, $type, @exon, @orf, @score, $promoter, $polyA);
		
		if (/^\s*(\d+)\s+([+-])\s+/) {
			$gene_name = $Predict_prog."_".$seq_name."_".($mark++);
			$strand = $2;
		}
		if (/CDSf/ && /CDSl/) {
			$type = "multi-exon";
			$num_multi++;
		}elsif(/CDSo/){
			$type = "sigle-exon";
			$num_single++;
		}elsif(!/CDSf/ && /CDSl/){
			$type = "no-first";
			$num_part++;
		}elsif(/CDSf/ && !/CDSl/){
			$type = "no-last";
			$num_part++;
		}elsif(!/CDSf/ && !/CDSl/){
			$type = "no-first-last";
			$num_part++;
		}

		while (/CDS\w\s+(\d+)\s+-\s+(\d+)\s+(\S+)\s+(\d+)\s+-\s+(\d+)/g) {
			push @exon,[$1,$2];
			push @score,$3;
			if ($5-$4+1 >= 3) { ##at least one codon
				push @orf,[$4,$5];
			}else{
				push @orf,['none','none'];
			}
			
		}
		if ($strand eq '-') {
			@exon = reverse @exon;
			@orf = reverse @orf;
			@score = reverse @score;
			foreach my $p (@exon) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
			foreach my $p (@orf) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
		}
		
		if (/TSS\s+(\d+)/){
			$promoter = $1;
		}else{
			$promoter = "none";
		}

		if (/PolA\s+(\d+)/) {
			$polyA = $1;
		}else{
			$polyA = "none";
		}
		
		
		$all_hp->{$seq_name}{$gene_name}{strand}=$strand;
		$all_hp->{$seq_name}{$gene_name}{type}=$type;
		$all_hp->{$seq_name}{$gene_name}{promoter}=$promoter;
		$all_hp->{$seq_name}{$gene_name}{exon}=\@exon;
		$all_hp->{$seq_name}{$gene_name}{orf}=\@orf;
		$all_hp->{$seq_name}{$gene_name}{score}=\@score;
		$all_hp->{$seq_name}{$gene_name}{polyA}=$polyA;

	}

}
####################################################


##parse the BGF result file, generate data structure,
##and output the protein sequences
####################################################
sub parse_BGF{
	my $str_p=shift;
	my $all_hp=shift;
	
	return if($$str_p =~ /no reliable gene/);

	$$str_p=~s/The input sequence has unknown character or format error!//g;
	$$str_p=~s/\s+$//;

	my $cut_pos1 = index($$str_p,"\n\n    1 ");
	my $cut_pos2 = index($$str_p,"Predicted protein(s):");
	my $head_part = substr($$str_p,0,$cut_pos1);
	my $gene_part = substr($$str_p,$cut_pos1,$cut_pos2-$cut_pos1);
	#my $prot_part = substr($$str_p,$cut_pos2);
	$$str_p="";

	my $seq_name = $1 if($head_part=~/Sequence\s+:\s+(\S+)\s+/);
	my $seq_leng = $1 if($head_part=~/Length\s+:\s+(\d+)\s+/);
	$head_part = "";
	

	$seq_len{$seq_name} = $seq_leng;

	$gene_part=~s/^\s+//g;
	$gene_part=~s/\s+$//g;
	my @genes=split(/\n\n/,$gene_part);
	$gene_part = "";

	my $mark=@genes;
	$mark=~tr/[0-9]/0/;
	$mark++;

	foreach (@genes) {
		my ($gene_name, $strand, $type, @exon,  @orf, @score, $promoter, $polyA);
		
		if (/^\s*(\d+)\s+([+-])\s+/) {
			$gene_name = $Predict_prog."_".$seq_name."_".($mark++);
			$strand = $2;
		}
		
		if (/Init/ && /Term/) {
			$type = "multi-exon";
			$num_multi++;
		}elsif(/Sngl/){
			$type = "sigle-exon";
			$num_single++;
		}elsif(!/Init/ && /Term/){
			$type = "no-first";
			$num_part++;
		}elsif(/Init/ && !/Term/){
			$type = "no-last";
			$num_part++;
		}elsif(!/Init/ && !/Term/){
			$type = "no-first-last";
			$num_part++;
		}

		while (/(Init|Intr|Term|Sngl)\s+(\d+)\s+-\s+(\d+)\s+(\d+)\s+-\s+(\d+)\s+(\S+)/g) {
			push @exon,[$2,$3];
			push @score,$6;
			if ($5-$4+1 >= 3) { ##at least one codon
				push @orf,[$4,$5];
			}else{
				push @orf,['none','none'];
			}
		}
		
		if ($strand eq '-') {
			@exon = reverse @exon;
			@orf = reverse @orf;
			@score = reverse @score;
			foreach my $p (@exon) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
			foreach my $p (@orf) {
				( $p->[0],$p->[1] ) = ( $p->[1],$p->[0] ) ;
			}
		}
		
		if (/Prom\s+(\d+)/){
			$promoter = $1;
		}else{
			$promoter = "none";
		}

		if (/PolA\s+(\d+)/) {
			$polyA = $1;
		}else{
			$polyA = "none";
		}

		$all_hp->{$seq_name}{$gene_name}{strand}=$strand;
		$all_hp->{$seq_name}{$gene_name}{type}=$type;
		$all_hp->{$seq_name}{$gene_name}{promoter}=$promoter;
		$all_hp->{$seq_name}{$gene_name}{exon}=\@exon;
		$all_hp->{$seq_name}{$gene_name}{orf}=\@orf;
		$all_hp->{$seq_name}{$gene_name}{score}=\@score;
		$all_hp->{$seq_name}{$gene_name}{polyA}=$polyA;
	}

}
####################################################


#usage: disp_seq(\$string,$num_line);
#############################################
sub Disp_seq{
	my $seq_pp=shift;
	my $disp_pp=shift;
	my $num_line=(@_) ? shift : 50;
	
	my $len=length($$seq_pp);
	for (my $i=0; $i<$len; $i+=$num_line) {
		my $sub=substr($$seq_pp,$i,$num_line);
		$$disp_pp .= $sub."\n";
	}
	$$disp_pp = "\n" if(! $$disp_pp);

}
#############################################


#############################################
sub Complement_Reverse{
	my $seq=shift;
	$seq=~tr/AGCTagct/TCGAtcga/;
	$seq=reverse($seq);
	return $seq;

}
#############################################


##remove redundant genes, keep the larger one when two gene overlapped.
sub purify_fragment{
	my $pos_p = shift; ##point to the two dimension input array
	my $new_p = ();         ##point to the two demension result array
	
	my ($all_size, $pure_size, $redunt_size,$redunt_num) = (0,0,0,0); 
	
	return 0 unless(@$pos_p);

	foreach my $p (@$pos_p) {
		($p->[0],$p->[1]) = ($p->[0] <= $p->[1]) ? ($p->[0],$p->[1]) : ($p->[1],$p->[0]);
		$all_size += abs($p->[0] - $p->[1]) + 1;
	}
	@$pos_p = sort {$a->[0] <=> $b->[0]} @$pos_p;
	push @$new_p, (shift @$pos_p);
	
	foreach my $p (@$pos_p) {
		if ( ($p->[0] - $new_p->[-1][1]) <= 0 ) { # remove
			if ( ($new_p->[-1][1] - $new_p->[-1][0]) < ($p->[1]-$p->[0]) ) {
				delete $all{$new_p->[-1][3]}{$new_p->[-1][2]};
				pop  @$new_p;
				push @$new_p,$p;
			}else{
				delete $all{$p->[3]}{$p->[2]};
			}
			$redunt_num++;
		}else{  ## not remove
			push @$new_p,$p;
		}
	}
	@$pos_p = @$new_p;

	foreach my $p (@$pos_p) {
		$pure_size += abs($p->[0] - $p->[1]) + 1;
	}
	
	$redunt_size = $all_size - $pure_size;
	return $redunt_num;
}

sub get_seq_len {
        ##get original sequence length
        %seq_len = ();
        open(IN, $sequence_file) || die ("original sequence as second input file is needed for option --backcoor\n");   
        $/=">"; <IN>; $/="\n";
        while (<IN>) {
                my $chr=$1 if(/^(\S+)/);
                $/=">"; 
                my $seq=<IN>;
                chomp $seq;
                $seq=~s/\s//g;
                $/="\n";
                $seq_len{$chr}=length($seq);
        }
        close(IN);
}   
