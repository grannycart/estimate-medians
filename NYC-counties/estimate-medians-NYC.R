# estimate-medians-NYC.R
# Last modified: Thu Oct 13, 2022  03:36PM

# Introduction
# This script calculates median incomes of NYC counties.
# Median incomes ARE available at the county level from the Census.
# I just used to this to check if my script calculated the median income as the Census.
#
# The comments in this file have been revised for legibility from the Chicago version.
# 
# This script is simplistic, it only does one county at a time.
# It's also unnecessarily pedantic so I can make sure it is doing each thing
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
# 
# Likewise, best practices would be to include MOEs for the estimated
# medians, which it is possible to calculate from the data I have here.
# But again, for this analysis, MOEs aren't necessary.
# 

# First, set working directory and load tidyverse
setwd("estimate-medians/NYC-counties/")
library(tidyverse)

# File prep:
# This script relies on an input file of data from the ACS B19101 table.
# It would be cool if you could just feed this script a straight csv as it
# comes from the ACS and let the script clean it up. But some things
# are easier to do outside of R, so I did them outside of R.
#
# Once you've set up the file, edit this filename here to change your
# input file with your data for each county:
raw_CCA_tract_income_data <-
	read_csv("Kings-county/ACS_17_5YR_B19101_with_ann.csv", skip = 1, na = ".")
#	read_csv("NY-county/ACS_17_5YR_B19101_with_ann.csv", skip = 1, na = ".")
#	read_csv("Bronx-county/ACS_17_5YR_B19101_with_ann.csv", skip = 1, na = ".")

# To make life easier for myself, I also created a file that has the
# minimum and maxiumum values of each of the income bins already broken
# out into individual fields. Yes, it would be way cooler to parse this
# out of the ACS file headers, but there's a bunch of string->int
# stuff that I would need to figure out that would take a lot longer
# than just typing in the values to a separate file did. You can use the
# same file here for all the county median calculations - just make sure
# the columns line up precisely with the columns of your data file.
raw_minmax_bin_values <-
	read_csv("Income-bins-minmax-table_ACS_13_5YR_B19101.csv", 
		 skip = 1, na = ".")

# I'm going to use this cheesy way to pull out just the 'Estimate' 
# columns with values, and leave the MOE columns behind:
CCA_tract_income_data <- select(raw_CCA_tract_income_data, 
				starts_with("Estimate"))

# Select just the estimate columns for the minmax table too: 
# (This is just removing a labels column I have in the file)
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
# the rows for each column, (the -1 drops the first total column)
CCA_family_sums <- colSums(CCA_tract_income_data[,-1])

# Just to be a sure, we haven't screwed something up, check that the names
# for CCA_family_sums and the minmax_bin_values are the same. If
# they aren't this script won't work, so throw an error:
stopifnot(all.equal.list(names(CCA_family_sums), 
			 names(minmax_bin_values)))
# You could also run this test, but it's unnecessary:
# stopifnot(all.equal.list(names(CCA_tract_income_data[,-1]),
#			 names(minmax_bin_values)))

# We also need the cumulative sums of families per income bin:
cumul_CCA_family_sums <- cumsum(CCA_family_sums)

# With that, we can write our while loop that will figure out which 
# bin contains the median:
med_bin_loc <- 1 # This variable will hold the location of our median 
		 # bin at the end of the while loop - so that's it's name
while (cumul_CCA_family_sums[med_bin_loc] < half_fams) {
	med_bin_loc <- med_bin_loc + 1 
}
# Note that this while loop probably won't handle edge cases well (If
# the middle family is exactly the same as a bin, you'll get the next
# bin up - but that's probably not the one you want.) For this reason
# you should manually keep an eye on which bin gets selected.

# At this point, if nothing went wrong, using the med_bin_loc value
# as the column selector on cumul_CCA_family_sums[med_bin_loc],
# CCA_family_sums[med_bin_loc], and minmax_bin_values[med_bin_loc]
# should all give you the same bin that should contain the median
# family income. 

# All that's left to do is in the interpolation, which is
# just a bit of arithmetic using the bin edges and the cumul numbers
# The formula for linear interpolation is: 
# (((half_fams - (total number of familes up to median bin)) / 
# (number of fams in the median bin)) This gives you the % multiplier
# * $bin_width) + ($value of bottom edge of median bin)

# We need the cumulative families to the bottom edge of the bin for 
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


print("Estimated median value of this data set: ")
print(med_value)



