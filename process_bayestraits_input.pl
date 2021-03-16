



# 
# 
# 
#                                                                         0                   1                2                  3
# perl ~/scripted_analyses/tingting/scripts/process_bayestraits_input.pl classed_trait_table OTU_assignments $phylogeny_species bee_traits.bayestraits_input
# 
# 
# 
# 
# 
# 
# 
# 


$in    		= $ARGV[0];
$subjects  	= $ARGV[1];
$tree_input	= $ARGV[2];
$out  		= $ARGV[3];

unless($in =~ /\w/ || $out =~ /\w/ || $tree_input =~ /\w/ || $subjects =~ /\w/){die "\nerror with file names\n"};

print "
in:$in
out:$out
";


open(IN2, $subjects) || die "\nerror 14, cant open file ($subjects)\n";
while(my $line = <IN2>)
	{
	$line =~ s/\n//;$line =~ s/\r//; # print "line:$line\n";
	if($line =~ /^(\S+)\t/)
		{
		$subject{$1} = 1;$count_subjects++
		}elsif($line =~ /^(\S\S+)/)
		{
		$subject{$1} = 1;$count_subjects++
		};
	};
close IN2;

print "
count_subjects:$count_subjects
";

open(IN, $in) || die "";
open(OUT1, ">BOLD_speciestraits2") || die "\nerror 27\n";
open(OUT2, ">BOLD_speciestraits") || die "\nerror 28\n";

my $linecount = 0;
while(my $line = <IN>)	# classed_trait_table
	{

# U_BodyLength	M_BodyLength	F_BodyLength	U_ITD	M_ITD	F_ITD	U_HeadWidth	M_HeadWidth	F_HeadWidth	U_HairLength	M_HairLength	F_HairLength	U_WingLength	M_WingLength	F_WingLength	U_HLL	M_HLL	F_HLL	U_TibeaLength	M_TibeaLength	F_TibeaLength	U_BodyWeight	M_BodyWeight	F_BodyWeight	U_TongueLength	M_TongueLength	F_TongueLength	Sociality	Nest_location	Nest_behavior	Parasitism	Lecty
# Xylocopa_tranquabarorum	A	NA	A	D	NA	D	D	NA	D	A	NA	A	D	NA	D	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA


	if( $linecount == 0)
	{
	print "trait table header:$line\n";
	$line =~ s/\n//;$line =~ s/\r//;
	$all_missing_line = $line;	$all_subject_line = $line;
	$all_missing_line =~ s/\w+/-/g;	$all_subject_line =~ s/\w+/?/g;

	}else{
	$line =~ s/\n//;$line =~ s/\r//; # print "line:$line\n";
	if($line =~ /^(\S+)\t/)
		{
		my $species = $1;
		$line =~ s/^\S+\t/\t/;		
		$traits_for_species{$species} = $line;
	#	if($subject{$species} == 1)
	#		{
	#		$line =~ s/	NA/	?/g;
	#		print OUT1 "$line\n";
	#		$line =~ s/	\?/	-/g;
	#		print OUT2 "$line\n";
	#		}else{
	#		$line =~ s/	NA/	-/g;
	#		print OUT1 "$line\n";
	#		print OUT2 "$line\n";
	#		};

		};
	};
$linecount++;	
	};
close IN;




open(IN2, $tree_input) || die "\nerror 15.\n";
while(my $line = <IN2>)
	{
	$line =~ s/\n//;$line =~ s/\r//; # print "line:$line\n";
	if($line =~ /^>(.+)/)
		{
		my $species = $1;#	$tree_species{$1} = 1;
		$tree_IDs_read++;
		if($traits_for_species{$species} =~ /./)	
			{
			$line = $traits_for_species{$species};
			if($subject{$species} == 1)
				{
				$line =~ s/	NA/	?/g;
				print OUT1 "$species$line\n";
				$line =~ s/	\?/	-/g;
				print OUT2 "$species$line\n";
				$tree_subjects++;
				}else{
				$line =~ s/	NA/	-/g;
				print OUT1 "$species$line\n";
				print OUT2 "$species$line\n";
				};


			}else{
		#	print OUT1 "$species\t-\t-\t-\t-\t-\t-\t-\n";
		#	print OUT2 "$species\t-\t-\t-\t-\t-\t-\t-\n"; 


			if($subject{$species} == 1)
				{

			#	print OUT1 "$species	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?	?\n";
			#	print OUT2 "$species	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-\n";

				print OUT1 "$species	$all_subject_line\n";
				print OUT2 "$species	$all_missing_line\n";

				$tree_subjects++;$subjects_with_no_records++;
				}else{
			#	print OUT1 "$species	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-\n";
			#	print OUT2 "$species	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-\n";

				print OUT1 "$species	$all_missing_line\n";
				print OUT2 "$species	$all_missing_line\n";

				};


			};
	
		};
	};

print "
tree_IDs_read:$tree_IDs_read
 tree_subjects:$tree_subjects
 subjects_with_no_records:$subjects_with_no_records



FIN.
";










#close OUT1;
#close OUT2;









