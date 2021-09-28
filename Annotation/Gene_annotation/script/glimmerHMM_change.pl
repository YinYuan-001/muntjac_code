#!/usr/bin/perl
use strict;
use warnings;

my $file=shift;

print "\#\#gff\-version\ 3\n";
open IN,$file || die "$!";
my $id;
while(<IN>){
	chomp;
#	next if($_=~/\#\#gff\-version\ 3/);
	next if($_=~/^#/);
	my @c=split(/\t/,$_);
#	if(exists $c[2] && $c[2]=~/CDS/){
	if( $c[2]=~/CDS/){
		$id=$2 if($c[8]=~/ID=(\S+);Parent=(\S+);Name=(\S+);Note=(\S+)/);
		$c[8]= "Parent=$id;";
		print join("\t",@c).";"."\n";
#	}elsif{exists $c[2] && $c[2]=~/mRNA/){
	}
	elsif($c[2]=~/mRNA/){
		$id=$1 if($c[8]=~/ID=(\S+?);Name/);
		$c[8]= "ID=$id;";
		print join("\t",@c).";"."\n";
	}
}
close IN;
	
