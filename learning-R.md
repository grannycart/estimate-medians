estimate-medians/learning-R.md
Last modified: Fri Oct 14, 2022  01:02PM

# Additional personal notes on learning R


## Installing
1. apt install r-base package (on .deb based systems)
2. apt install r-cran-tidyverse (on .deb based systems)
	* On non-deb systems you can try compiling in R with: run install.packages("tidyverse")
		* But, as usual with compiling, it's finicky. Better to just use the deb packages 
4. As a regular user, run "R" on the command line to start R environment:
	2. Run library(tidyverse)
		* You have to do this at the start of every R session to load the tidyvers packages
* This is just the base R environment on the command line. Most people prefer R Studio which gives you a whole IDE.
* For now, I like working in vim and on the command line.


## Where to learn:
* [R For Data Science website version](https://r4ds.had.co.nz/)
	* Start with [data wrangling](https://r4ds.had.co.nz/wrangle-intro.html)
	* Then look at [data exploration and visualization](https://r4ds.had.co.nz/explore-intro.html)
* See [R Studio Cheatsheets](https://www.rstudio.com/resources/cheatsheets/)


## Random things to remember
* To run the script:
	* In the R environment, use source(filename.R)
	* From the command line use Rscript filename.R
* Most of R uses a data frames to hold data. If you want to use tidyverse packages, you need to make data frames a tibble, which you can do with: as_tibble()
* view() -- will show you a data frame as a flat file layout; glimpse() -- shows an abbreviated table version
	* tab-complete will work on a variable name 
* quitting R:
	* at > prompt use q()
	* at + prompt use CTRL-C
* setwd(dir) sets the working directory; getwd() prints it.
* (with tidyverse readr package) Read in csv with: 
	* tibble_name <- read_csv("filename.csv")
	* problems(tibble_name) will show you problems with the read
	* You will probably have to/probably should specify all the column types
	* Or you could read everything in as a character:
		* tibble2_name <- read_csv("challenge.csv", col_types = cols(.default = col_character()))
		* And then you can use type_convert(tibble2_name) to run the type parser on it
* (with tidyverse readr package) write out csv with: 
	* write_csv(tibble2_name, "filename.csv")
	* Or: write_excel_csv(tibble2_name, "filename.csv") which saves a special csv that tells excel the encoding is UTF-8
	* These both write UTF-8 by default
	* BUT type info is lost in csv. For interim work, save in special R binary with: write_rds() and read_rds()



