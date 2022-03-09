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
# 
# SEE FILE: barcodeFD.sh

