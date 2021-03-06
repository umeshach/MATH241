library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr)

# Install the babynames package first: All babynames (with n >= 5) from Social
# Security Administration from 1880 to 2013: https://github.com/hadley/babynames
library(babynames)

# Run the following line to load necessary example data: cases, storms, pollution
source("http://people.reed.edu/~albkim/MATH241/Lec19_examples.R")





#-------------------------------------------------------------------------------
# EXERCISES
#-------------------------------------------------------------------------------
# From Eleanor: Census data with total population, land area, and population
# density in wide format
census <- read.csv("popdensity1990_00_10.csv", header=TRUE) %>% tbl_df()


# EXERCISE: Add varibles "county_name" and "state_name" to the census data
# frame, which are derived from the variable "QName".  Do this in a manner that
# keeps the variable "QName" in the data frame.

# SOLUTION:
census <- separate(census, QName, c("county_name", "state_name"), sep=", ",
                   remove=FALSE)
select(census, county_name, state_name) %>% View()


# EXERCISE: Create a new variable FIPS_code that follows the federal standard:
# http://www.policymap.com/blog/wp-content/uploads/2012/08/FIPSCode_Part4.png
# As a sanity check, ensure that the county with FIPS code "08031" is Denver
# County, Colorado.  Hint: str_pad() command in stringr

# SOLUTION: We can't treat STATE and COUNTY as numerical variables, b/c we need
# the single digit ID's, like Alabama having STATE code 1.  Rather we treat them
# as character strings "padded with 0's".  Then we use the unite() command.
census <-
  mutate(census,
         state_code = str_pad(STATE, 2, pad="0"),
         county_code = str_pad(COUNTY, 3, pad="0")
  )

census <- unite(census, "FIPS_code", state_code, county_code, sep = "")

# Denver county has STATE code 8 and COUNTY code 31, but we see we've correctly
# padded them with 0's.
filter(census, FIPS_code=="08031")



# EXERCISE: Plot histograms of the population per county, where we have the
# histograms facetted by year.

# SOLUTION: For ggplot to work cleanly, we need to first convert the data into
# tidy format.  We create a new data frame consisting of county_name,
# state_name, FIPS_code, and total population and gather() it in long format
# "keyed" by year.
totalpop <- select(census, county_name, state_name, contains("totalpop"))

totalpop <- gather(totalpop, "year", totalpop, contains("totalpop")) %>%
  mutate(year=factor(year, labels=c("1990", "2000", "2010")))

# Now that we have a keying variable "year", we can easily facet this plot
ggplot(totalpop, aes(x=totalpop, y=)) +
  geom_histogram() +
  facet_wrap(~year) +
  scale_x_log10() +
  xlab("County population (log-scale)") +
  ggtitle("County populations for different years")



# EXERCISE: Now consider the babynames data set which is in tidy format.  For
# example, consider the top male names from the 1880's:
babynames
filter(babynames, year >=1880 & year <= 1889, sex=="M") %>%
  group_by(name) %>%
  summarize(n=sum(n)) %>%
  ungroup() %>%
  arrange(desc(n))


# The most popular male and female names in the 1890's were John and Mary.
# Present the proportion for all males named John and all females named Mary
# (some males were recorded as females, for example) for each of the 10 years in
# the  1890's in wide format.  i.e. your table should have two rows, and 11
# columns: name and the one for each year

# SOLUTION: We remove the "n" and "sex" variable to keep the table looking clean.
filter(babynames,
       (name=="Mary" & sex=="F") | (name=="John" & sex=="M"),
       year >=1880 & year <= 1889
) %>%
  select(-n, -sex) %>%
  spread(year, prop)


