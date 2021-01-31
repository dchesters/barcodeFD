#!/usr/bin/perl



################################################################################
#
#
#
# 	bayestraitswrap.pl, Perl wrapper for BayesTraits (Pagel and Meade)
#
#    	Copyright (C) 2013-2017  Douglas Chesters
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#	contact address dc0357548934@live.co.uk
#
#	v1.01 (2013): 		first version on sourceforge
#	v1.02 (29Aug2017): tested on very large tree (~100,000 terminals)
#			also makes bayestraits (nexus) format tree from the user supplied (newick) tree
#
#
#
#
#
#
#
#
################################################################################




################################################################################
#
#
#
#	input is a fully bifurcating, rooted tree, in newick format. 
#	branchlengths and node support values are ignored, if present.
#	do not use only numbers for terminals id's,
#	 should contain other characters.
#
#	to run:
#	perl bayestraitswrap.pl [input_tree]
#
#	e.g.
#	perl bayestraitswrap.pl my_tree.nwk
#
#	output is a table of BayesTraits format node definitions 
#		for each node found in your input tree.
#	the output file is called scriptOUT, and each row has a single node, e.g
#	AddNode NODE_3	348PLATYCIS 578LOPHEROS
# 	'AddNode' is the appropriate command for BayesTraits to analyse a 
#	node only where it is present, this is followed by the name 
#	of the node (which is arbitrary), 
#	and then the terminals that belong to that node.
# 	also printed is newick_nodekey.nwk, you can read this with
#	any tree viewing software and observe the node labels.
#	the node labels (numbers) correspond to the node definitions in scriptOUT.
#	so the user can find the nodes of interest by viewing the tree 
#	in newick_nodekey.nwk, the get the corresponding command to analyse 
#	that node, from within the scriptOUT file. 
#	this is illustrated in example.pdf, which shows the newick tree
#	as viewed in a tree viewer, and the scriptOUT file.
#
#
# 	Citation: 
#	Sklenarova K, Chesters D, Bocak L (2013) 
#	Phylogeography of Poorly Dispersing Net-Winged Beetles: 
#	A Role of Drifting India in the Origin of Afrotropical and Oriental Fauna. 
# 	PLoS ONE 8(6): e67957
#
#
#	script available at:
#	https://sourceforge.net/projects/bayestraitswrap/
#
#
#
#
#
#
#
################################################################################



my $treefile 		= $ARGV[0];






$max_clade_size_for_reconstruction = 10;




my %terminals = ();
my $root_identity = "";
my $date = localtime time;


# read tree ($treefile) into hash. node identities for hash key, then parent/child identities as hash entry

#########################
record_tree2($treefile);#
#########################


print "root_identity:$root_identity\n";
$terminals_belonging_to_current_node;
$newick_string = "($root_identity);";

open(OUTPUT, ">scriptOUT") || die "";
print OUTPUT "1
1
";
##############################
count_groups($root_identity);#		print node definitions
##########################################

print OUTPUT "run
";
close(OUTPUT);




open(OUT3 , ">newick_nodekey.nwk") || die "";

print OUT3 $newick_string;
close(OUT3);


print "\n\n\nend of script\n";
exit;





####################################################################################
#
#
#
#
#
####################################################################################




sub record_tree2
{


my $tree1= "";
open(IN, $treefile) || die "\n\nerror 1408 cant open file $treefile\n\n";
while (my $line = <IN>)
	{
	if($line =~ /(.+\(.+)/){$tree1 = $1}
	}
close(IN);

print "\nlooking at tree:$treefile\n";

$tree1 =~ s/ //g;
my $tree2 = $tree1;


# remove support values. can be whole number or proportion:
$tree1 =~ s/\)\d+\.*\d*/\)/g;

# remove branchlengths, scientific notation, incl negative values for distance trees. example: -8.906e-05
$tree1 =~ s/\:\-*\d+\.\d+[eE]\-\d+([\(\)\,])/$1/g; 

# remove regular branchlengths: 0.02048
$tree1 =~ s/\:\-*\d+\.\d+//g; 

# remove 0 length branchlengths
$tree1 =~ s/\:\d+//g;



###open(OUT, ">$taxon_table_file");


my $count_terminals = 0;
my @list_of_taxa;

# while ($tree2 =~ s/([\,\(])([^\(\)\,]+)([\,\)])/$1$3/)
# 	{
# 	my $terminal = $2;$count_terminals++;#push(@list_of_taxa , $terminal);
# 	if($count_terminals =~ /0000$/)
# 		{
# 		print "count_terminals:$count_terminals, $terminal\n";
# 		};
# 	$terminals{$terminal} = 1;
#	if($terminal =~ /[^_]+_[^_]+_([^_]+)/){my $gen = $1}
# 	};



my $count=0;
while($tree2 =~ /[\(\)\,][a-z][^\(\)\,\:]{2,}[\:\;]/i)
	{
	$tree2 =~ s/([\(\)\,])([a-z][^\(\)\,\:]{2,})([\:\;])/$1$count$3/i;
	my $terminal = $2;#	print "tha_taxon:$tha_taxon\n";
#	push(@list_of_taxa , $tha_taxon);
	$list{$count} = $terminal;
	$terminals{$terminal} = 1;
	$count++;$count_terminals++;
 	if($count_terminals =~ /0000$/)
 		{print "count_terminals:$count_terminals, $terminal\n"};
	};

if($tree2 =~ /(.{1,40}[a-z]{2}.{1,40})/i)
	{my $test = $1; die "\nerror, seems ids not parsed from tree:$test\n"};

my @keys = keys %list;@keys = sort {$a <=> $b} @keys;
open(OUT9, ">bayestraits_tree_input");
print OUT9 "\#NEXUS\nbegin trees\;\n	translate\n";
for my $i(0 .. $#keys)
	{
	$key = $keys[$i];
	if($i == $#keys)
		{
		print OUT9 "\t\t$key " , $list{$key} , "\;\n";
		}else{
		print OUT9 "\t\t$key " , $list{$key} , "\n";
		}
	}
print OUT9 "tree tree1 = $tree2\nend\;\n";
close(OUT9);




my $current_taxon_set = "";
my $clade_size = 0;



my $count_tips_complted = 0;
my $node_counter = 0;
my %tree_structure = ();



# RECORD TREE STRUCTURE:
# find each bifurcation ( seq_id , seq_id )
# record child nodes
# then remove bifurcation from string,
# replace with new node id (a whole number, which is incremented for each node)


while($tree1 =~ /\(([^\,\(\)]+)\,([^\(\)]+)\)/)
	{
	my $child1 = $1;my $child2 = $2;

	$nodes{$node_counter}{child1} = $child1;$nodes{$node_counter}{child2} = $child2;
	$nodes{$child1}{parent} = $node_counter;$nodes{$child2}{parent} = $node_counter;
	$nodes{$child1}{which_child} = 1;$nodes{$child2}{which_child} = 2;

	$tree1 =~ s/\(([^\,\(\)]+)\,([^\(\)]+)\)/$node_counter/;

	if($node_counter =~ /000$/){print "node:$node_counter child1:$child1 child2:$child2\n"};
#	print "$tree1\n";
	
	$node_counter++;
	}

#print "$tree1\n";
#die;


print "nodes in tree:$node_counter\ntree1:$tree1\n";

$root_identity = $node_counter-1;


}



####################################################################################
#
#
#
#
#
####################################################################################



sub count_groups
{
# starts with root

 my $next = shift;

my @next1 = ();$next1[0] = $nodes{$next}{child1};$next1[1] = $nodes{$next}{child2};


if($next =~ /^\d+$/)
{
$newick_string =~ s/([\(\)\,])$next([\(\)\,])/$1($next1[0],$next1[1])$next$2/;
}

for my $index(0 .. $#next1)
	{

	$test = @next1[$index];


		my $parentnode;
		if(exists($nodes{$next}{parent}))
			{
			$parentnode = $nodes{$next}{parent};
			}else{
		#	print "\nno parent for $next :" , $nodes{$next}{parent} , ":\n";
		#	print "root_identity:$root_identity next1:@next1\n";

			if($next == $root_identity)
				{
				}else{
				die "error. no assignment. quitting\n";
				};
			};
			

			$number_of_tips_belonging_to_current_subfam_derived_from_this_node = 0;

		#	print "test:$test\n";
			$terminals_belonging_to_current_node = "";
			
			###########################################################################################################
			count_number_of_tips_belonging_to_current_subfam_derived_from_this_node($test);#
			###########################################################################################################
				

			$terminals_belonging_to_current_node =~ s/\s+$//;
			my @count9 = split / /, $terminals_belonging_to_current_node;

			my $number_terminals = scalar @count9;

		#	print "\tnumber of tips:$number_of_tips_belonging_to_current_subfam_derived_from_this_node $number_terminals\n";

			if($number_terminals >=2 && $number_terminals <= $max_clade_size_for_reconstruction)
				{


#AddNode NODE_lower 0 1 2 3 4 38 39 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37

#				print OUTPUT "$test\t$terminals_belonging_to_current_node\n";
				print OUTPUT "AddNode NODE_$test	$terminals_belonging_to_current_node\n";

				}
			# subtending branch of current subfam
	#		push( @current_subtending_branch_array , $number_of_tips_belonging_to_current_subfam_derived_from_this_node );
			



	if($test =~ /^\d+$/){count_groups($test)}

	}
return();

}



####################################################################################
#
#
#
#
#
####################################################################################




sub count_number_of_tips_belonging_to_current_subfam_derived_from_this_node
{
my $next = shift;
#my $next = $_[0];my $current_taxonomic_group = $_[1];
my @next1 = ();$next1[0] = $nodes{$next}{child1};$next1[1] = $nodes{$next}{child2};

for my $index(0 .. $#next1)
	{
	my $test = @next1[$index];

	if($test =~ /^\d+$/)
		{

		count_number_of_tips_belonging_to_current_subfam_derived_from_this_node($test );
		}else{

		$terminals_belonging_to_current_node .= $test . " ";


		$number_of_tips_belonging_to_current_subfam_derived_from_this_node++;
		}
	}

return();

}



####################################################################################
#
#
#
#
#
####################################################################################



