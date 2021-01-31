

# barcodeFD; Functional Diversity from DNA Barcodes; beta version, minimal instructions ...

 # input for state assignment script should be named 'listed_records' and have 4 columns, 
 # 1st column trait_name, 
 # 2nd column species name in format Genus_species
 # if the record is numeric, put the value in the 3rd column and NA in the 4th,
 # if the record is catagoric, put the value in the 4th column and NA in the 3rd.

rm trait_Permutation_LOG.txt
R < summarize_traits.R --vanilla --slave
 # outputs 
 #	1) table: 	'classed_trait_table.2021', 
 #	2) figure: 	'traits_plotted.jpg'
 # 	3) Log file:	'trait_Permutation_LOG.txt'

# reformat newick tree to that used by bayestraits
perl bayestraitswrap.pl raxml_tree
# ouptut is named bayestraits_tree_input

# Next define subjects, these are species/otu for which missing traits will be predicted.
# Create two Bayestraits input files, one where all missing data assigned missing, other where subset of species to be predicted are labelled.
# Also the trait DBs will have lots of species not in the phylogeny, remove these or bayestraits crashes.

rm BOLD_speciestraits*

# input arguments: 
#  1) classed trait table (output by summarize_traits.R), 
#  2) OTU_assignments; has OTU ID in first column, tab, then whitespace seperated list of all members (each of which may or may not have trait records) 
#  3) fasta file of your barcodes, filtered version used to make phylogeny
#  4) string NULL (currently unused)
perl process_bayestraits_input.pl classed_trait_table.20201231 OTU_assignments phylogeny_species bee_traits.bayestraits_input

# Bayestraits will not run on all columns as there are to many paramters
# Linux cut command to split individual columns

# list your trait names
loci=(NULL NULL U_BodyLength M_BodyLength Parasitism)

BTiterations=5000000
BTsample=5000

rm BTcommands.*
for i in ${!loci[*]}
do
  locus=${loci[$i]}; 
  printf "\nno:$i locus:$locus\n"
  cut -f 1,$i BOLD_speciestraits > BOLD_speciestraits.$locus
  cut -f 1,$i BOLD_speciestraits2 > BOLD_speciestraits2.$locus
  (echo "1"; echo "2"; echo "iterations $BTiterations"; echo "sample $BTsample"; echo "burnin 500"; echo "SaveModels testModels.$locus.bin"; echo "run") > BTcommands.$locus.1
  (echo "1"; echo "2"; echo "iterations $BTiterations"; echo "sample $BTsample"; echo "burnin 500"; echo "LoadModels testModels.$locus.bin"; echo "run") > BTcommands.$locus.2
done

# BT_commands gives chain length,
# If you have a longer chain, will probably have several traits with a minor increase in state predictions,
#   though might also be one or two with less.... Presumably more accurate anyway.

rm BayesTraits.RESULTS.* testModels.*.bin

for i in ${!loci[*]}
do
  locus=${loci[$i]}; 
  printf "\nno:$i locus:$locus\n"
  BayesTraitsV3 bayestraits_tree_input BOLD_speciestraits.$locus  < BTcommands.$locus.1
  BayesTraitsV3 bayestraits_tree_input BOLD_speciestraits2.$locus < BTcommands.$locus.2 > BayesTraits.RESULTS.$locus
done

# Parse results, which are predictions for tips where missing in input
# Set chain burnin and probability threshold in script.
rm BT_results_LOG.txt BayesTraits.tip_predictions.*
for i in ${!loci[*]}
do
  locus=${loci[$i]}; 
  printf "\nno:$i locus:$locus\n"
  perl parse_bayestraits_tip_estimates.pl BayesTraits.RESULTS.$locus BayesTraits.tip_predictions.$locus 500 0.95
done

# FIN.


