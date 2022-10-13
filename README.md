# Estimate Medians --- an R script

This is a simple R script to calculate the median incomes from more or less arbitrary geographies made up of Census tracts.

The cheap way to calculate median incomes for geographies not published by the Census is to take a mean of median incomes of a set of geographies for which you *can* get Census data. However, I called up the Census office, and they very nicely pointed out that a mean of medians --- while roughly accurate for some work --- is not the preferred way, and not empirically accurate. The best way is to use linear interpolation.

In this repository is one version of the script set up to calculate median incomes for Chicago Community areas and accompanying Census data from 2017 to demonstrate how it works.
* [Chicago CCAs estimate-medians.R](./Chicago-neighborhood-areas-medians/estimate-medians.R)

And another version that calculates the medians for a few NYC counties and accompanying data.
* [NYC Counties estimate-medians.R](./NYC-counties/estimate-medians.R)

The script is heavily commented, so look there for more information.

Additional notes on learning R:
* [learning-R.md](learning-R.md)

## License:
* MIT
* See: [LICENSE](./LICENSE)





