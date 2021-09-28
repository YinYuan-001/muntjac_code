my $dir = "genes";
my @sample = glob "$dir/*";

open OUT,">rename.cds" or die $!;
foreach my $sa (@sample){
	open IN,$sa or die $!;
	$sa =~ s/genes\///g;$sa =~ s/\.fa//g;
	while(<IN>){
		my $word = $_;
		if($_ =~ /^>/){
			chomp $word;
			$word .= ".".$sa."\n";
		}
		print OUT $word;
	}
}

#print @sample;
