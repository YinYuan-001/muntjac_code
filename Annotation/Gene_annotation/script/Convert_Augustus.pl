#!/usr/bin/perl

=head1 Name

  convert_augustus.pl --convert augustus result to gff3 format.

=head1 Usage
  
  perl convert_augustus.pl *.augustus  prefix

=head1 Version
 
  Author:Quanfei Huang,huangqf@genomics.org.cn
  Version:2.0
  Date:2008-12-24

=cut

use strict;

die `pod2text $0` if (@ARGV==0);
my $infile=shift;
my $prefix=shift;
$prefix ||='A';
my %Gene;
read_augustus($infile,\%Gene);
my $Num=scalar(keys %Gene);
$Num=~tr/[0-9]/0/;
foreach my $id(sort keys %Gene){
	$Num++;
	$Gene{$id}{mRNA}[8]="ID=$prefix$Num;";
	@{$Gene{$id}{CDS}}=sort {$a->[3]<=>$b->[3]} @{$Gene{$id}{CDS}};
	if($Gene{$id}{mRNA}[6] eq '-'){
		$Gene{$id}{CDS}[-1][4]-=$Gene{$id}{CDS}[-1][7];
		if (defined $Gene{$id}{stop} && $Gene{$id}{stop}[3]!=$Gene{$id}{CDS}[0][3]){

			if($Gene{$id}{stop}[4]==$Gene{$id}{CDS}[0][3]-1){
				$Gene{$id}{CDS}[0][3]-=3;
			}else{
				@{$Gene{$id}{stop}}[2,8]=('CDS',"Parent=$prefix$Num;");
				push @{$Gene{$id}{CDS}},[@{$Gene{$id}{stop}}];
			}

		}
	}else{
		$Gene{$id}{CDS}[0][3]+=$Gene{$id}{CDS}[0][7];
		if (defined $Gene{$id}{stop} && $Gene{$id}{stop}[4]!=$Gene{$id}{CDS}[-1][4]){

			if($Gene{$id}{stop}[3]==$Gene{$id}{CDS}[-1][4]+1){
				$Gene{$id}{CDS}[-1][4]+=3;
			}else{
				@{$Gene{$id}{stop}}[2,8]=('CDS',"Parent=$prefix$Num;");
				push @{$Gene{$id}{CDS}},[@{$Gene{$id}{stop}}];
			}

		}
	}
	@{$Gene{$id}{CDS}}=sort {$a->[3]<=>$b->[3]} @{$Gene{$id}{CDS}};
	$Gene{$id}{mRNA}[2]='mRNA';
	@{$Gene{$id}{mRNA}}[3,4]=($Gene{$id}{CDS}[0][3],$Gene{$id}{CDS}[-1][4]);
	print join("\t",@{$Gene{$id}{mRNA}})."\n";
	foreach my $cds (@{$Gene{$id}{CDS}}){
		$cds->[8]="Parent=$prefix$Num;";
		print join("\t",@$cds)."\n";
	}
}


sub read_augustus{
	my ($file,$p)=@_;
	open IN,$file or die "Fail $file:$!";
	while(<IN>){
		next if /^#/;
		chomp;
		my @c=split(/\s+/);
		@c[3,4]=@c[4,3] if ($c[3]>$c[4]);
		if ($c[2] eq 'transcript' && $c[8]=~/ID=([^;\s]+)/){
			@{$p->{$c[0].$1}{mRNA}}=@c;
		}elsif($c[2] eq 'CDS' && $c[8]=~/Parent=([^;\s]+)/){
			push @{$p->{$c[0].$1}{CDS}},[@c];	
		}elsif($c[2] eq 'stop_codon' && $c[8]=~/Parent=([^;\s]+)/ ){
			@{$p->{$c[0].$1}{stop}}=@c;
		}
	}
	close IN;

}

