estimate-medians/learning-R.md
Last modified: Sun Oct 16, 2022  04:46PM

# Additional personal notes on learning R


## Installing
1. apt install r-base package (on .deb based systems)
2. apt install r-cran-tidyverse (on .deb based systems)
	* On non-deb systems you can try compiling in R by running in the R environment: install.packages("tidyverse")
		* But, as usual with compiling, it's finicky. Better to just use the deb packages 
		* This does seem the preferred way on Arch systems.
		* This takes a while, it's a bunch of packages to compile
4. As a regular user, run "R" on the command line to start R environment:
	2. Run library(tidyverse)
		* You have to do this at the start of every R session to load the tidyvers packages
* This is just the base R environment on the command line. Most people prefer R Studio which gives you a whole IDE.
* For now, I like working in vim and on the command line.
* check out radian: https://github.com/randy3k/radian 


## Where to learn:
* [R For Data Science website version](https://r4ds.had.co.nz/)
	* Start with [data wrangling](https://r4ds.had.co.nz/wrangle-intro.html)
	* Then look at [data exploration and visualization](https://r4ds.had.co.nz/explore-intro.html)
* See [R Studio Cheatsheets](https://www.rstudio.com/resources/cheatsheets/)


## Random things to remember
* To run the script:
	* In the R environment, use source("filename.R")
	* From the command line use Rscript filename.R
* quitting R:
	* at > prompt use q()
	* at + prompt use CTRL-C
* Most of R uses a data frames to hold data. If you want to use tidyverse packages, you need to make data frames a tibble, which you can do with: as_tibble()
* print(variable-name) will show the tibble in R
	* you can give this an argument to just show a certain number of rows
	* view() -- will show you a data frame as a flat file layout; 
	* glimpse() -- shows an abbreviated table version
	* tab-complete will work on a variable name 
* list variables:
	* ls()
	* Note: variables can't start with a number or have dashes (-) in them
* setwd(dir) sets the working directory; getwd() prints it.
* (with tidyverse readr package) Read in csv with: 
	* tibble_name <- read_csv("filename.csv")
	* problems(tibble_name) will show you problems with the read
	* pass it na = "" for handling blanks (or "." or whatever)
	* You will probably have to/probably should specify all the column types:
		* to do this, pass as an option: col_types = cols( COLUMNNAME = col_character())
			* Obviously, there are other types than character
	* Or you could read everything in as a character:
		* tibble2_name <- read_csv("challenge.csv", col_types = cols(.default = col_character()))
		* And then you can use type_convert(tibble2_name) to run the type parser on it
* (with tidyverse readr package) write out csv with: 
	* write_csv(tibble2_name, "filename.csv")
	* Or: write_excel_csv(tibble2_name, "filename.csv") which saves a special csv that tells excel the encoding is UTF-8
	* These both write UTF-8 by default
	* BUT type info is lost in csv. For interim work, save in special R binary with: write_rds() and read_rds()
* Select a column from a table with:
	* new_tibble <- (select(flat_file_table, matches("column_header"))
	* Can also use starts_with() instead of matches. Other options too in documentation.
* Add a column with a value with:
	* new_tibble <- add_column(old_tibble, NEWCOLUMNNAME = Value)
* Add rows from one tibble to the bottom of another with:
	* new_tibble <- bind_rows(old_tibble_1, old_tibble_2)
	* There's a bind_column() function too
* Get a count of occurences in a column:
	* new_tibble <- old_tibble %>% count(COLUMNNAMETOCOUNT)
	


