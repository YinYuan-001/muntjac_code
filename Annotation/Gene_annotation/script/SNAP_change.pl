#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $file=shift;

my %gene;

open (IN,$file) || die "$!";
while(<IN>){
	chomp;
	my @c=split/\t/,$_;
	my $id=$c[8];
	push @{$gene{$id}},[@c];
}
close IN;

#print Dumper %gene;

foreach my $title(keys %gene){
	@{$gene{$title}}=sort {$a->[3]<=>$b->[3]}@{$gene{$title}};
	my $number=@{$gene{$title}};
	#print "$number\n";
	my $start=$gene{$title}[0][3];
	my $end=$gene{$title}[-1][4];
	
	print "$gene{$title}[0][0]\t$gene{$title}[0][1]\tmRNA\t$start\t$end\t\.\t$gene{$title}[0][6]\t\.\tID=$title;\n";
	if($gene{$title}[0][6] eq '+'){
		print "$gene{$title}[0][0]\t$gene{$title}[0][1]\tCDS\t$gene{$title}[0][3]\t$gene{$title}[0][4]\t$gene{$title}[0][5]\t$gene{$title}[0][6]\t0\tParent=$title;\n";
		if($number>1){
			my $total_CDS=$gene{$title}[0][4]-$gene{$title}[0][3]+1;
			for(my $i=1;$i<$number;$i++){
				my $phase=3-$total_CDS%3;
				$phase=0 if($phase == 3);
				print "$gene{$title}[$i][0]\t$gene{$title}[$i][1]\tCDS\t$gene{$title}[$i][3]\t$gene{$title}[$i][4]\t$gene{$title}[$i][5]\t$gene{$title}[$i][6]\t$phase\tParent=$title;\n";
				my $CDS_length=$gene{$title}[$i][4]-$gene{$title}[$i][3]+1;
				$total_CDS=$total_CDS+$CDS_length;
				#print " $total_CDS\n";
			}
		}
	}elsif($gene{$title}[0][6] eq '-'){
		$gene{$title}[-1][7]=0;
		if($number>1){
			my $total_CDS=$gene{$title}[-1][4]-$gene{$title}[-1][3]+1;
			my $end_number=$number-2;
			for(my $i=$end_number;$i>=0;$i--){
				my $phase=3-$total_CDS%3;
				$phase=0 if($phase == 3);
				$gene{$title}[$i][7]=$phase;
				my $CDS_length=$gene{$title}[$i][4]-$gene{$title}[$i][3]+1;
				$total_CDS=$total_CDS+$CDS_length;
			}
		}
		for(my $j=0;$j<$number;$j++){
			print "$gene{$title}[$j][0]\t$gene{$title}[$j][1]\tCDS\t$gene{$title}[$j][3]\t$gene{$title}[$j][4]\t$gene{$title}[$j][5]\t$gene{$title}[$j][6]\t$gene{$title}[$j][7]\tParent=$title;\n";
		}
	}
}
		
		
		
					

