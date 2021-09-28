#!/usr/bin/env perl
use strict;
use warnings;
die "Usage: perl $0 <maf> <replace name> <output maf>\n" unless @ARGV == 4;
open (MAF, "$ARGV[0]") or die "maf file missing!\n";
my $name1=$ARGV[1];
my $name2=$ARGV[2];
open (OUT,">$ARGV[3]") or die "Can't open OUT!\n";

my $Sum_len;
my $species_name;
my $chr_name;
my $chr_len;
print OUT "##maf version=1 scoring=last\n";
while(my $line=<MAF>){
    if($line=~/^#/){
        next;
    }
    elsif($line=~/^p/){
        next;
    }
    else{
        print OUT "$line";
    }
    if($line=~/^a score/){
        my $first = <MAF>;
        my $second = <MAF>;
        $first=~s/^s\s/s $name1./;
        $second=~s/^s\s/s $name2./;
	my $len=(split /\s+/,$first)[3];
	$chr_name=(split /\s+/,$first)[1];
        $chr_len=(split /\s+/,$first)[5];
	$Sum_len+=$len;
	$species_name=(split /\s+/,$second)[1];
        print OUT "${first}${second}";
    }
}

print "$chr_name\t$species_name\t$Sum_len\t$chr_len\n";
