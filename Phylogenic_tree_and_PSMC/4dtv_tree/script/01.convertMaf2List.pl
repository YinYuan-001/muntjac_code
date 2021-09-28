#! /usr/env perl
use strict;
use warnings;

my $maf=$ARGV[0];
my $output=$ARGV[1].".maf.lst";
my $ref="Cattle";
my @species=("goat","Cattle",$ARGV[1]);
#my @species=("goat","Ibex","BlueSheep","BarbarySheep","Sheep","Argali","TibetanAntelope","Gemsbok","BlueWildebeest","Topi","Hartebeest","RoyalAntelope","Klipspringer","MaxwellsDuiker","CommonDuiker","HarveysDuiker","Steenbok","GyrantGazelle","ThomsonGazelle","Springbuck","Gerenuk","Oribi","GazellaPrzewalskyi","DefassaWaterbuck","BohorReedbuck","Impala","Suni","AfricanBuffalo","Yak","Cattle","GreaterKudu","CommonEland","MountainNyala","Bongo","Sitatunga","Bushbuck","LesserKudu","MuntiacusMuntjak","MuntiacusReevesi","Daviddeer","WhiteLippedDeer","RoeDeer","WhiteTailedDeer","Reindeer","Giraffe","Okapi","Pronghorn","LesserMouseDeer");

open O,">$output";
open E,">no_ref.maf";
#open O,"| gzip - > $output";
my @head=("chr","pos",@species);
my $head=join "\t",@head;
print O "$head\n";

my $control=0;
my $content="";
open I,"cat $maf |";
while(<I>){
    next if(/^#/);
    if(/^a\s+score=/){
        $content=$_;
        while(<I>){
            if(/^s\s+/){
	$content.=$_;
            }
            else{
	last;
            }
        }
        &analysis($content);
    }
    # last if($control++>=0);
}
close I;
close O;

sub analysis{
    my $content=shift;
    my @line=split(/\n/,$content);
    my $head=shift @line;
    $head=~/score=([\d\.]+)/;
    my $score=$1;my $all_strand;
    # print "$score\n";
    my %pos;
    my $isRefFound=0;
    my $ref_chr="NA";
    foreach my $line(@line){
        my @a=split(/\s+/,$line);
        my ($s,$chr,$start,$alignment_length,$strand,$sequence_length,$sequence)=@a;my $all_strand = $strand;
        $chr=~/^([^\.]+)\.(.*)/;
        my $species=$1;
        $chr=$2;
        if($species eq $ref){
            $ref_chr=$chr;
            $isRefFound=1;
            my @base=split(//,$sequence);
            if($strand eq "+"){
	my $pos=$start;
	for(my $i=0;$i<@base;$i++){
	    if($base[$i] ne "-"){
	        $pos++;
	        $pos{$i}=$pos;
	    }
	}
            }
            if($strand eq "-"){
	my $pos=$start;
	for(my $i=0;$i<@base;$i++){
	    if($base[$i] ne "-"){
	        $pos++;
	        my $real_pos = $sequence_length-1-($pos-1)+1;
	        $pos{$i}=$real_pos;
	    }
	}
            }
        }
    }
    if($isRefFound == 0){
		print E $content;
		next;	
#        die "$ref not found!\nspecies name should be added before chr such as chr01 should be cattle.chr01\n";
    }
    my %data;
    foreach my $line(@line){
        my @a=split(/\s+/,$line);
        my ($s,$chr,$start,$alignment_length,$strand,$sequence_length,$sequence)=@a;
        $chr=~/^([^\.]+)\.(.*)/;
        my $species=$1;
        $chr=$2;
        my @base=split(//,$sequence);
		$sequence =~ tr/ATCGRYMK/TAGCYRKM/ if $all_strand eq "-";
        for(my $i=0;$i<@base;$i++){
            next if(!exists $pos{$i});
            my $pos=$pos{$i};
            $data{$pos}{$species}=$base[$i];
        }
    }
    my @output_line;
    foreach my $pos(sort {$a<=>$b} keys %data){
        @output_line=($ref_chr,$pos);
        foreach my $species(@species){
	my $base="-";
	if(exists $data{$pos}{$species}){
	    $base = $data{$pos}{$species};
	}
	push @output_line,$base;
            }
        my $output_line=join "\t",@output_line;
        print O "$output_line\n";
    }
}
