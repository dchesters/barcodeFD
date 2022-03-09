###################################################################################################################################
#
#
# 	barcodeFD
#		Functional Diversity from DNA Barcodes
#
#    	Copyright (C) 2021-2022 Douglas Chesters
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
#	Citation:
# 	Chesters, D. (2021). barcodeFD: Functional Diversity from DNA barcodes. Computer software available at github.com/dchesters/barcodeFD.
#
# 
###################################################################################################################################
#
#
# barcodeFD; Functional Diversity from DNA Barcodes
#
#  v 1.01 (2021-01-31): First release.
#  v 1.02 (2022-03-09): Simplified, particularly, loop are removed by running on a single trait 
#	(user is free to run on additional traits, but not neccessary to have this built in as default)
#	new version of summarize_traits.R, new script trait_model.pl, process_bayestraits_input.pl no longer needed
#
# Dependencies:
#  summarize_traits.R
#  trait_model.pl
#  bayestraitswrap.pl
#  parse_bayestraits_tip_estimates.pl
#  BayesTraitsV3
#  File of listed trait records
#  File listing all species/OTU IDs
#  Phylogeny comprising both references and subjects

# Input for state assignment script should be named 'listed_records' and have 4 columns, 
#  1st column trait_name, 
#  2nd column species name in format Genus_species
#  If the record is numeric, put the value in the 3rd column and NA in the 4th,
#  If the record is catagoric, put the value in the 4th column and NA in the 3rd.
rm numeric_records_classed trait_Permutation_LOG.txt traits_plotted.jpg
R < summarize_traits.R --vanilla --slave
# Outputs 
#  1) main output:	'numeric_records_classed',
#  2) table: 	'classed_trait_table', 
#  3) figure: 	'traits_plotted.jpg'
#  4) Log file:	'trait_Permutation_LOG.txt'

# Reformat file of classed states, ready for bayestraits (just need 2 columns, species and state class):
sed -n "s/^\S*\t\(\S*\)\t\S*\(\t\S*\)$/\1\2/p" numeric_records_classed > numeric_records_classed.BT

# Next define subjects, these are species/otu for which missing traits will be predicted.
#  Create two Bayestraits input files, one where all missing data assigned missing, other where subset of species to be predicted are labelled.
#  Note trait database might have lots of species not in the phylogeny, should not be included or bayestraits crashes.
#  Make two data tables for Bayestraits, assuming all missing states are to be predicted.
#  (user might opt to provide different subject set, for instance OTU list)
#  3 arguments to Perl script are: 
#   species_list, these should exactly match terminals of the phylogeny,
#   numeric_records_classed.BT, formatted output of summarize_traits.R
#   string for naming output files
rm BTinput.*
perl trait_model.pl Syrphidae_Sp_List numeric_records_classed.BT BTinput

# Make Bayestraits command files.
# Gives chain length below,
# If you have a longer chain, some traits will have a minor increase in state predictions,
#   though might also be one or two with less. Presumably more accurate anyway.
rm BTcommands.1 BTcommands.2
BTiterations=500000
BTsample=500
(echo "1"; echo "2"; echo "iterations $BTiterations"; echo "sample $BTsample"; echo "burnin 500"; echo "SaveModels testModels.bin"; echo "run") > BTcommands.1
(echo "1"; echo "2"; echo "iterations $BTiterations"; echo "sample $BTsample"; echo "burnin 500"; echo "LoadModels testModels.bin"; echo "run") > BTcommands.2

# Prepare correct format phylogeny (Nexus) for Bayestraits.
# Input is Phylip format as produced by Raxml, fully bifurcating, rooted.
cp RAxML_bestTree.Syrphidae_specieslevel.202202 raxml_tree
rm bayestraits_tree_input
perl bayestraitswrap.pl raxml_tree
# Ouptut is named bayestraits_tree_input

# Run Bayestraits:
rm testModels.bin BayesTraits.RESULTS
BayesTraitsV3 bayestraits_tree_input BTinput.1  < BTcommands.1
BayesTraitsV3 bayestraits_tree_input BTinput.2 < BTcommands.2 > BayesTraits.RESULTS

# Parse results, which are predictions for tips where missing in input
# Set chain burnin and probability threshold as arguments.
rm BT.tip_predictions*
#							    IN			OUT 	   Burnin Pr
perl parse_bayestraits_tip_estimates.pl BayesTraits.RESULTS BT.tip_predictions 500 0.50

###########################################################################################################################
