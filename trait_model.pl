

# 
# 
# 
# 
# 
# 2022-02-28: 	Prepares state definition table for bayestraits.
# 		Simpler than previous scripts.
# 		Assumes any terminal without state assigned, is to be predicted.
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
###############################################################################################


$in0 = $ARGV[0];
$in1 = $ARGV[1];
$out = $ARGV[2];

unless($in0 =~ /./ && $in1 =~ /./ && $out =~ /./)
	{
	die "\nError. Incorrect invokation, should be:\n\tperl trait_model.pl [species_list] [numeric_records_classed.BT] [outfile_string]\n\n";
	};


################################################################################################
open(IN1, $in1) || die "";
print "opened $in1\n";
while(my $line = <IN1>)
	{
	$line =~ s/\n//;$line =~ s/\r//; # print "$line\n";
	if($line =~ /^(\S+)\t(\S+)/)
		{
		my $sp = $1; my $state = $2;$states{$sp} = "$state";$states_parsed++;
		};
	
	};
close IN1;

print "states_parsed:$states_parsed\n";

################################################################################################




################################################################################################
open(IN0, $in0) || die "";
open(OUT1, ">$out.1") || die "";
open(OUT2, ">$out.2") || die "";
print "opened $in0\n";

while(my $line = <IN0>)
	{
	$line =~ s/\n//;$line =~ s/\r//; # print "$line\n";
	if($line =~ /^(\S+)/)
		{
		my $sp = $1; 
		if($states{$sp} =~ /./)
			{
			print OUT1 "$sp\t$states{$sp}\n";
			print OUT2 "$sp\t$states{$sp}\n";
			}else{
			print OUT1 "$sp\t-\n";
			print OUT2 "$sp\t?\n";
			};
		};
	
	};

close IN0;
close OUT1;
close OUT2;
################################################################################################








