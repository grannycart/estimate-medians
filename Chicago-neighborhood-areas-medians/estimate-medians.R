# estimate-medians.R
# Mark Torrey - mark@welcometocup.org

########################################################################
# Introduction
# In Chicago the most common way to define neighborhoods in the city is
# by Chicago Community Areas (CCAs). CCAs are an artifact of historical
# processes. Unfortunately they vary widely in population size and other
# characteristics. They are not ideal for doing any kind of analysis,
# but they are the areas that community members who would be doing
# CUP workshops can identify with, so we need to fit any data we want
# to present to them to these areas. Neither the ACS nor Chicago
# calculates the Median Family Income (MFI) for CCAs, so this script does
# that, by estimating the MFI from the American Community Survey (ACS)
# families by income data (ACS table B19101). This data gives you the
# number of families in each income "bin." The bins are ranges of income
# from $0 to $200,000, broken up into varying amounts, usually around
# $10,000, but not always.
# 
# Thankfully CCAs at least have boundaries along Census tract lines and
# B19101 data is available at the tract level, so we can build CCAs by
# selecting the rows with the data for the tracts that make up each CCA
# and then use linear interpolation to estimate the MFI for the CCA. (I
# asked some people at the Census if this is a statistically valid way to
# do this, and they said it is.)
# 
# This script is simplistic, it only does one CCA at a time.
# It's also uneasily pedantic so I can make sure it is doing each thing
# correctly as I learn R.
#
# There's a number of ways it could be improved, and I'll point some of
# those out in the comments. The first thing this
# doesn't do that would be cool is use tidycensus to pull the data you
# want from the ACS directly.
# 
# One other note, for sheer technical accuracy, the literature says you
# are supposed to use Pareto interpolation if the bin containing the
# median is wider than $2500.
# (See: https://s4.ad.brown.edu/Projects/Diversity/SUC/MHHINote.htm)
# Since these medians are just to give community members a quick sense
# of who lives in a given CCA, fine-grained accuracy isn't as important.
# 
# Likewise, best practices would be to include MOEs for the estimated
# medians, which it is possible to calculate from the data I have here.
# But again, for this analysis, MOEs aren't necessary.
# 
# To check that this works, I ran it to calculate MFIs of Census tracts
# in boroughs of NYC (because I can check those against the Census 
# calculation of the MFIs of the boroughs). In all cases the estimate 
# from this script was within $500 of the Census' calculated MFI.
########################################################################

# Setup:
# First, load tidyverse
library(tidyverse)

########################################################################
# File prep:
# This script relies on an input file of data from the ACS B19101 table.
# It would be cool if you could just feed this script a straight csv as it
# comes from the ACS and let the script clean it up. But some things
# are easier to do outside of R, so I did them outside of R.
#
# First, I don't have a list of tract numbers for each CCA, the only thing
# I had access to was the CCA shape file. So I used QGIS to combine the
# B19101 data with Census tract geo data for Chicago. Then I laid the CCA
# boundaries over the Chicago Census tracts, and then visually selected
# the Census tracts that make up each CCA and exported those selected rows
# as a csv. There may be a cooler R way to do this, but with my knowledge
# of QGIS visually selecting them just seemed like the easiest way.
#
# Once you've set up the CCA files, edit the filename here to change your
# input file with your data for each CCA:
raw_CCA_tract_income_data <-
	read_csv("Chicago-neighborhood-areas-medians/raw-data-from-Census_2017/ACS_17_5YR_B19101_with_ann.csv", 
		 skip = 1, na = ".")

# To make life easier for myself, I also created a file that has the
# minimum and maximum dollar values of each of the income bin edges already 
# broken out into individual fields. Yes, it would be way cooler to parse 
# this out of the ACS file headers, but there's a bunch of string->int
# stuff that I would need to figure out that would take a lot longer
# than just typing in the values to a separate file did. You can use the
# same file here for all the CCA median calculations - just make sure
# the columns line up precisely with the columns of your data file.
raw_minmax_bin_values <-
	read_csv("Chicago-neighborhood-areas-medians/Income-bins-minmax-table_ACS_13_5YR_B19101.csv", 
		 skip = 1, na = ".")
########################################################################


########################################################################
# Finding the bin containing the MFI:
# I'm going to use this cheesy way to pull out just the 'Estimate' 
# columns with values, and leave the MOE columns and other junk behind:
CCA_tract_income_data <- select(raw_CCA_tract_income_data, 
				starts_with("Estimate"))

# Select just the estimate columns for the minmax table too: 
# (This is just removing a labels column I have in the csv file)
minmax_bin_values <- select(raw_minmax_bin_values, starts_with("Estimate"))

# In The first column (that begins with the word "Estimate) the ACS
# give us the total families in all the income bins. We're going to add
# that whole column to get the total number of families in our whole data
# frame:
total_fams <- sum(CCA_tract_income_data[1])
# And then take half of those total families:
half_fams <- total_fams / 2

# We need all the columns of family numbers summed up for the next step.
# This sets CCA_income_sums as a named vector value with the sums of all
# the rows for each column, (the -1 drops that first Estimate total
# column):
CCA_family_sums <- colSums(CCA_tract_income_data[,-1])

# Just to be a sure, we haven't screwed something up, check that the names
# for CCA_family_sums and the minmax_bin_values are the same. If
# they aren't this script won't work, so this will throw an error:
stopifnot(all.equal.list(names(CCA_family_sums), 
			 names(minmax_bin_values)))
# You could also run this test, but it's unnecessary because we won't
# use the full CCA_tract_income_data data anymore:
# stopifnot(all.equal.list(names(CCA_tract_income_data[,-1]),
#			 names(minmax_bin_values)))

# We also need the cumulative sums of families per income bin:
cumul_CCA_family_sums <- cumsum(CCA_family_sums)

# With that, we can write a while loop that will figure out which 
# bin contains the median by checking if the number of half the total
# families is greater than the cumulative total of families in each
# income bin:
med_bin_loc <- 1 # This variable will hold the location of our median 
		 # bin at the end of the while loop - so that's it's name
while (cumul_CCA_family_sums[[med_bin_loc]] < half_fams) {
	med_bin_loc <- med_bin_loc + 1 
}

# Note that this while loop probably won't handle edge cases well (If
# the middle family is exactly the same as a bin edge, you might not get
# the one you want.) For this reason you should manually keep an eye 
# on which bin gets selected. We'll print it here for convenience:
print("I think the bin containing the median family income is: ")
print(cumul_CCA_family_sums[med_bin_loc])
print("Half of the total families in this data set is: ")
print(half_fams)
#
########################################################################


########################################################################
# Doing the interpolation:
# At this point, if nothing went wrong, using the med_bin_loc value
# as the column selector on cumul_CCA_family_sums[med_bin_loc],
# CCA_family_sums[med_bin_loc], and minmax_bin_values[med_bin_loc]
# should all give you the same bin that should contain the median
# family income. 

# All that's left to do is in the interpolation, which is just a bit of
# arithmetic using the bin edges and the cumul family numbers The formula for
# linear interpolation is: 
# (((half_fams - (total number of familes up to median bin)) / 
# (number of fams in the median bin)) * $bin_width) 
# + ($value of bottom edge of median bin)

# We need the cumulative families to the bottom edge of the median bin for 
# the interpolation calculation:
cumul_fams_med_bin <- cumul_CCA_family_sums[[med_bin_loc - 1]]

# Then subtract that from half-fams to get the proportion of families 
# in the bin up to the median:
propor_fams_med_bin <- half_fams - cumul_fams_med_bin

# Divide that by the total families in the median bin:
med_bin_perc <- propor_fams_med_bin / CCA_family_sums[[med_bin_loc]]

# Get the width of the median bin (in dollars):
bin_width <- max(minmax_bin_values[[med_bin_loc]]) - 
	min(minmax_bin_values[[med_bin_loc]])

# Multiply the width of the bin times the median percent:
med_value <- bin_width * med_bin_perc

# Add that number to all the value before the bin (bottom edge of median bin)
med_value <- med_value + min(minmax_bin_values[[med_bin_loc]])
#
########################################################################


########################################################################
# Print the finding: 
print("Estimated median income of this data set: ")
print(med_value)
########################################################################



