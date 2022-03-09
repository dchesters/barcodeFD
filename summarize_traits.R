
#
#
#
# R < summarize_traits.R --vanilla --slave
#
# 
# input for state assignment script should be named 'listed_records' and have 4 columns, 
# 1st column trait_name, 
# 2nd column species name in format Genus_species
# if the record is numeric, put the value in the 3rd column and NA in the 4th,
# if the record is catagoric, put the value in the 4th column and NA in the 3rd.
#
#
# 
# 
# CHANGE LOG
# 
# 2021-MAR-02: Plots another figure (using R) visualizing the permutation
# 2021-JUN-27: If user inadvertently inputs rows without records, these are detected and removed automatically
# 2021-DEC-27: Outputs table giving classes assigned to all numeric records which were input.
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
############################################################################################################################################

# plot options:
permutation_visualized_labelsize <- 1
permutation_visualized_summary_state_x <- 80	# points to indicate state selected after permutation
permutation_visualised_y1 <- -25 		# left hand side
permutation_visualised_y2 <- 85 		# right hand side
visualization_cex <- 1.2				# point size for states


########################################



print("");print(" r script summarize_traits.R");print("");

t1 <- read.table("listed_records", sep = "\t", row.names = NULL, header = F, colClasses = c( "character","character","numeric","factor" )  )

t1[  1 , ]
#                   V1                  V2               V3    V4
# 1 un_Body_length_.mm. Ceratina_sutepensis 7.62256097560976   NA

# check if user inputted records with nothing in, remove if so:
testlist <- is.na(t1[ , 3])&is.na(t1[ , 4]); rmrows <- (1:length(testlist))[testlist == TRUE]
if(length(rmrows) >= 1)
	{
	t1 <- t1[ -rmrows , ]
	}


traits_names_column <- t1[ , 1]
unique_traits <- as.character(unique(traits_names_column))
print(length(unique_traits))
unique_traits

new_trait_table <- matrix(NA, nrow = length(unique(t1[ , 2])), ncol = length(unique_traits))
row.names(new_trait_table) <- unique(t1[ , 2])
colnames(new_trait_table) <- unique_traits

# some counts, which are reported at the end
instances_multiple_states <- 0; instances_multiple_states_catagoric <- 0; 
species_trait_with_multiple_records <- 0; species_trait_total <- 0
species_trait_significant_states_0 <- 0; species_trait_significant_states_1 <- 0; species_trait_significant_states_2 <- 0; species_trait_significant_states_3 <- 0



jpeg("traits_plotted.jpg"    , width = 1400 , height = 1400, res=200)
par(mfrow=c(2,2));

##################################################################################
plot_y <- 0
printstring <- c( "jpeg(\"permutation_visualised.jpg\" , width = 1000 , height = 15000) " );
write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = F, sep = "")
printstring <- c( "
permutation_visualized_labelsize <- " , permutation_visualized_labelsize,
"
permutation_visualized_summary_state_x <- " , permutation_visualized_summary_state_x,
"
permutation_visualised_y1 <- " , permutation_visualised_y1,
"
permutation_visualised_y2 <- " , permutation_visualised_y2,
"
visualization_cex <- " , visualization_cex, 
"
")
write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")
printstring <- "plot(NULL, xlim = c(permutation_visualised_y1,permutation_visualised_y2) ,ylim = c(0,4000), axes = F, xlab = NA, ylab = NA)"
write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")
##################################################################################

system("rm numeric_records_classed"); # only for numeric traits, gives classes for all input records



# autodetect whether catagorical and numerical traits
for(current_trait_index in 1:length(unique_traits))
	{
	# current_trait_index <- 1
	current_trait <- unique_traits[current_trait_index]; 
	current_rows <-  (1:length(traits_names_column))[traits_names_column == current_trait] 
	values_numeric_column <-  t1[ current_rows , 3] # nb column 3 has numerical assignments
	values_catagoric_column <-  t1[ current_rows , 4] 
	count_states_numeric <- length(unique(values_numeric_column));count_states_catagoric <- length(unique(values_catagoric_column));

	if(count_states_numeric > count_states_catagoric)
		{
		which_type <- "NUMERIC"
		##################################################################################################################################
		##################################################################################################################################

current_trait <- unique_traits[current_trait_index]; print(c("current_trait" , current_trait))
current_rows <-  (1:length(traits_names_column))[traits_names_column == current_trait] 
# t1[ current_rows , ] # simple check
values <-  t1[ current_rows , 3] # nb column 3 has numerical assignments
min(values) # 
max(values) # 
median(values);print(c("values", values))
current_trait_quartiles <- as.numeric(quantile(values, prob=c(.25,.5,.75)))
current_trait_quartiles
# first one, U_BodyLength: 5.582900 7.476250 9.614025


test_matrix <- matrix(NA, ncol=3, nrow=length(values))
test_matrix[  , 1 ] <- t1[ current_rows , 2] # species
test_matrix[  , 2 ] <- t1[ current_rows , 3] # numerical value

  # first quartile
indices1 <- na.omit((1:length(values))[values <= current_trait_quartiles[1] ]); # indices.A <- intersect(current_rows , indices1)
test_matrix[ indices1 , 3 ] <- "A"
  # second 
indices2 <- na.omit((1:length(values))[values > current_trait_quartiles[1] & values <= current_trait_quartiles[2] ])
test_matrix[ indices2 , 3 ] <- "B"
  # third
indices3 <- na.omit((1:length(values))[values > current_trait_quartiles[2] & values <= current_trait_quartiles[3] ])
test_matrix[ indices3 , 3 ] <- "C"
  # fourth
indices4 <- na.omit((1:length(values))[values > current_trait_quartiles[3]  ])
test_matrix[ indices4 , 3 ] <- "D"

# 2021-12-27: for project on state assignment, need to have all trait records along with summarized states.
print_matrix <- cbind(rep(current_trait, length.out=length(test_matrix[ , 1])) , test_matrix)
write.table(print_matrix , file = "numeric_records_classed" ,  quote = F, sep = "\t", append = T, col.names = FALSE, row.names = FALSE )



plot_title <- paste( c( current_trait , " (n = " , length(na.omit(values)) , ")" ) , collapse = "")
boxplot( as.numeric(test_matrix[ , 2]) ~ test_matrix[ , 3], main = plot_title, xlab = "Quartile Label", ylab = "Trait Value")


  # make new table, one line per species,
  # will assign a summary trait class/es for each species.
current_trait_species_column <- t1[ current_rows , 2]
unique_species <- as.character(unique(current_trait_species_column))
current_trait_output <- matrix(NA, ncol=2, nrow=length(unique_species))
# current_trait_output[ , 1] <- unique_species # fill names out in loop, to ensure no naming error



 # also, new table of the states of the current trait permuted over current species.
number_permutations <- 100
current_trait_permutations <- matrix(NA, ncol=number_permutations, nrow=length(values))
for( j in 1:number_permutations )
	{
	current_trait_permutations[ , j] <- sample(test_matrix[  , 3])
	}


for( species_no in 1:length( unique_species ) )
	{
	current_species <- unique_species[species_no]; 

	# rows for current trait/species:
	current_rows2 <- (1:length(current_trait_species_column))[current_trait_species_column == current_species]
	current_trait_output[ species_no , 1] <- current_species;
	trait_species_values <- test_matrix[ current_rows2 , 3]; 
	current_species_states <- unique(trait_species_values)
	if(length(current_rows2) >= 2){species_trait_with_multiple_records <- species_trait_with_multiple_records + 1}
	species_trait_total <- species_trait_total + 1
	

	if( length( current_species_states ) >= 2 )
		{
		######################################################################################################
		# multiple states for current trait/species
		plot_y <- plot_y + 5; plot_x <- 0
		printstring <- c("trait:" , current_trait, "NEW SPECIES with multiple states:" , current_species , "trait states:", trait_species_values)
		print(printstring); write(printstring, file = "trait_Permutation_LOG.txt" , ncolumns = length(printstring),  append = T, sep = "\t")

		
		linetext <- paste(current_trait, current_species, sep = "  ")
		printstring <- c( "text( -15 , " ,  plot_y , ", labels = \"" , linetext , "\" , col=\"black\" , cex= permutation_visualized_labelsize )" );
		write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")

		instances_multiple_states <- instances_multiple_states + 1
		states_remaining <- "NA"; states_remaining_index <- 1;species_trait_significant_states <-0

		for(each_record in trait_species_values)
			{
			each_record2 <- "grey";
			if(each_record == "A"){each_record2 <- "red"}
			if(each_record == "B"){each_record2 <- "blue"}
			if(each_record == "C"){each_record2 <- "green"}
			if(each_record == "D"){each_record2 <- "brown"}

			# print(c("each_record" , each_record2))
			printstring <- c( "points(", plot_x , " , " , plot_y , ", col=\"" , each_record2 , "\", pch=16, cex=" , visualization_cex , ")"  );
			write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")

			plot_x <- plot_x + 1
			}


		

		# for current trait/species, test each state present:
		plot_x2 <- permutation_visualized_summary_state_x
		for (each_state in current_species_states)
			{
			no_current_state <- length( (1:length(trait_species_values))[trait_species_values == each_state] )
			total_measurements_unpermuted <- length(trait_species_values)
			# print (c("state:" , each_state , "count:" , no_current_state, "out of:" , total_measurements_unpermuted))

			# here go through each permutation, see if number of current states is greater than expectd by chance...
			state_greater_than_permuted <-0
			for( j in 1:number_permutations )
				{
				current_species_values_permuted <- current_trait_permutations[ current_rows2 , j] 
				total_measurements_permuted <- length(current_species_values_permuted)
				no_current_state_permuted <- length( (1:length(current_species_values_permuted))[current_species_values_permuted == each_state] )
			#	print (c("permutation:" , j , "total_measurements_permuted:" , total_measurements_permuted, "no_current_state_permuted:", no_current_state_permuted,"states:" , current_species_values_permuted))
				if(no_current_state >= no_current_state_permuted){state_greater_than_permuted <- state_greater_than_permuted + 1}
				}
			permutation_prop <- state_greater_than_permuted / number_permutations
			printstring <- c("state:" , each_state , "state probability:" , permutation_prop)
			print(printstring); write(printstring, file = "trait_Permutation_LOG.txt" , ncolumns = length(printstring),  append = T, sep = "\t")

			each_record2 <- "grey";
			if(each_state == "A"){each_record2 <- "red"}
			if(each_state == "B"){each_record2 <- "blue"}
			if(each_state == "C"){each_record2 <- "green"}
			if(each_state == "D"){each_record2 <- "brown"}

			if(permutation_prop >= 0.95)
				{
				states_remaining[states_remaining_index] <- each_state; states_remaining_index <- states_remaining_index + 1;
				species_trait_significant_states <- species_trait_significant_states + 1

				printstring <- c( "points(", plot_x2 , " , " , plot_y , ", col=\"" , each_record2 , "\", pch=16, cex=" , visualization_cex , ")"  );
				write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")

				plot_x2 <- plot_x2 + 1
				}



			}

		if(species_trait_significant_states == 0){species_trait_significant_states_0 <- species_trait_significant_states_0 + 1};
		if(species_trait_significant_states == 1){species_trait_significant_states_1 <- species_trait_significant_states_1 + 1};
		if(species_trait_significant_states == 2){species_trait_significant_states_2 <- species_trait_significant_states_2 + 1};
		if(species_trait_significant_states == 3){species_trait_significant_states_3 <- species_trait_significant_states_3 + 1};

		stateresults <- paste( states_remaining , collapse = "")

		printstring <- c("Assigning states:" , stateresults)
		print(printstring); write(printstring, file = "trait_Permutation_LOG.txt" , ncolumns = length(printstring),  append = T, sep = "\t")

		current_trait_output[ species_no , 2] <- stateresults
		 new_trait_table[ current_species , current_trait ] <- stateresults
		######################################################################################################
		}else{
		# whether one or multiple records, there is only a single state for this trait/species, so finalize:
		current_trait_output[ species_no , 2] <- current_species_states
		 new_trait_table[ current_species , current_trait ] <- current_species_states
		}

	}; # for each species







		##################################################################################################################################
		##################################################################################################################################
		}else{
		which_type <- "CATAGORIC"
		##################################################################################################################################
		##################################################################################################################################


	current_trait <- unique_traits[current_trait_index]; 
	current_rows <- (1:length(traits_names_column))[traits_names_column == current_trait]
	print(c(current_trait_index ,current_trait , length(current_rows)))


	#####################################################################################
	current_trait_species_column <- t1[ current_rows , 2]
	current_values <- t1[ current_rows , 4] # column 4 for catagorical traits

	unique_species <- as.character(unique(current_trait_species_column))
	for(species_no in 1:length(unique_species))
		{
		current_species <- unique_species[species_no]; 
		current_rows2 <- (1:length(current_trait_species_column))[current_trait_species_column == current_species]

		if(length(current_rows2) >= 2)
			{
			trait_species_value <- as.character(unique(current_values[current_rows2]))
			if(length(trait_species_value) >= 2)
				{
				printstate <- paste (trait_species_value, collapse = "");new_trait_table[ current_species , current_trait ] <- printstate
				instances_multiple_states_catagoric <- instances_multiple_states_catagoric + 1
				}else{
				# although more than one specimen for this speices, they have the same state
				printstate <- trait_species_value;new_trait_table[ current_species , current_trait ] <- printstate
				}

			}else{
			trait_species_value <- as.character(current_values[current_rows2])
			printstate <- trait_species_value; new_trait_table[ current_species , current_trait ] <- printstate
			}
		};
	#####################################################################################

plot_title <- paste( c( current_trait , " (n = " , length(na.omit(current_values)) , ")" ) , collapse = "")
barplot( table( droplevels(t1[ current_rows , 4] )) , main = plot_title, xlab = "Class", ylab = "Count")




		##################################################################################################################################
		##################################################################################################################################
		}


	print(c("current_trait" , current_trait, count_states_numeric, count_states_catagoric, which_type))
	} # for(current_trait_index in 1:length(unique_traits))


dev.off()

printstring <- "dev.off()"
write(printstring, file = "Permutation_figure.txt" , ncolumns = length(printstring),  append = T, sep = "")


write.table(new_trait_table , file = "classed_trait_table" ,  quote = F, sep = "\t", append = F)

print(c("species_trait_total" , species_trait_total ))
print(c("species_trait_with_multiple_records" , species_trait_with_multiple_records))
print(c("instances_multiple_states for numeric traits" , instances_multiple_states))
print(c("instances_multiple_states_catagoric" , instances_multiple_states_catagoric))
print(c("species_trait_significant_states_0" , species_trait_significant_states_0))
print(c("species_trait_significant_states_1" , species_trait_significant_states_1))
print(c("species_trait_significant_states_2" , species_trait_significant_states_2))
print(c("species_trait_significant_states_3" , species_trait_significant_states_3))
print("FIN.")







