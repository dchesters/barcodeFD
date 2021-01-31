

# 
# 
# started 2020-09-27
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
# 
# 
# 
# 
# 
# 
# 
# 
########################################################################################################################

$in0 			= $ARGV[0];
$out0 			= $ARGV[1];
$burnin 		= $ARGV[2]; # 500;
$probability_threshold 	= $ARGV[3]; # 0.95


unless($out0 =~ /\w/ && $burnin =~ /\d/ && $probability_threshold =~ /\d/ ){die "\ncommand ERROR.\n"};




# global
@the_columns;



open(IN0, $in0) || die "\nerror 31.\n";
print "openend $in0\n";
$in_chain = 0;
while(my $line = <IN0>)
	{
	$line =~ s/\n//;$line =~ s/\r//;
	if($line =~ /^\d+	\-[\d\.]+	\d+	\d+/ && $in_chain == 1)
		{
		###########################################################################################################
		# In Chain
		$count_iterations++;
		@splitline = split /\t/ , $line;
		for my $i(0 .. $#the_columns)
			{
			my $header = $the_columns[$i]; my $entry =  $splitline[$i];
			if($header =~ /^Est\s(\S+)\s\-\s\d/)
				{
				my $current_OTU = $1; $store_assignments{$current_OTU} .= "\t$entry\t";
				};
			};

		###########################################################################################################
		};
	if($line =~ /^Iteration	Lh	Tree No	Model No/  && $in_chain == 0)
		{
		$in_chain = 1;


		@the_columns = split /\t/ , $line;

	#	if($line =~ /\t(Est\s\S+.+\s\-\s\d+)\tRoot/)
	#		{
	#		my $columns = $1; @the_columns = split /\t/ , $columns; print "columns:$columns\n";
	#		}else{
	#		die "\ncant parse column title list\n";
	#		};


		};
	};

close IN0;


print "
count_iterations:$count_iterations
";




#############################################################################################################################

#############################################################################################################################

open(OUT, ">$out0") || die "\nerror 92.\n";
open(OUT2, ">$out0.out2") || die "\nerror 98.\n";


my @OTU_IDs = keys %store_assignments;@OTU_IDs = sort @OTU_IDs;
$otu_assigned = 0;
$otu_count = 0;
foreach my $OTU(@OTU_IDs)
	{
	my $printstring = "$OTU\t";
	$otu_count++;
	$current_chain = $store_assignments{$OTU};
#	print "\n$OTU:$current_chain\n";
	$current_chain =~ s/^\t+//;$current_chain =~ s/\t+$//;
	my @chain = split /\t+/ , $current_chain;

	my %states;	
	for my $j($burnin .. $#chain)	
		{
		my $current = $chain[$j]; $states{$current}++;	
		};

	my @current_states = keys %states;

	my $maxval = 0; my $maxvalstate; my $sum=0;
	foreach my $k(@current_states)
		{
		my $count = $states{$k};$sum += $count; # print "$k:$count\n";
		if($count >= $maxval){$maxval = $count; $maxvalstate = $k};
		};

	foreach my $k(@current_states)
		{
		my $count = $states{$k};my $prop = $count / $sum; $printstring .= "$k:$prop\t";

		};


	my $prop = $maxval / $sum;

#	print "maxvalstate:$maxvalstate (prob:$prop)\n";

	if($prop >= $probability_threshold)
		{
		print OUT "$OTU\t$maxvalstate\t$prop\n";
		$otu_assigned++;
		$printstring =~ s/\t$//; print OUT2 "$printstring\n";
		};
	};

print "
otu_count:$otu_count
otu_assigned:$otu_assigned
";


close OUT;
close OUT2;

open(LOG, ">>BT_results_LOG.txt");
print LOG "$in0\t$otu_count\t$otu_assigned\n";
close LOG;

#############################################################################################################################

#############################################################################################################################







