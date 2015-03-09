library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr)

# Install the following packages:

# All babynames (with n >= 5) from Social Security Administration from 1880 to
# 2013: https://github.com/hadley/babynames
library(babynames)

# Needed for test data sets: cases, storms, pollution
devtools::install_github("rstudio/EDAWR")
library(EDAWR)





#-------------------------------------------------------------------------------
# Tutorial
#-------------------------------------------------------------------------------
#---------------------------------------------------------------
# Going from tidy (AKA narrow AKA tall) format to wide format and vice versa
# using gather() and separate()
#---------------------------------------------------------------
# Convert to tidy format. All three of the following do the same:  "year" is the
# new "key" variable and n is the "value" variable
cases
gather(data=cases, key="year", value=n, 2:4)
gather(cases, "year", n, `2011`, `2012`, `2013`)
gather(cases, "year", n, -country)


# Convert to wide format. The "key" variable is size and the "value" variable is
# amount
pollution
spread(pollution, size, amount)


# Note: gather() and spread() are opposites of each other
cases
gather(cases, "year", n, -country) %>% spread(year, n)



#---------------------------------------------------------------
# separate() and unite() columns
#---------------------------------------------------------------
# Separate the year, month, day from the date variable":
storms
storms2 <- separate(storms, date, c("year", "month", "day"), sep = "-")
storms2

# Undo the last change using unite()
unite(storms2, "date", year, month, day, sep = "-")





#-------------------------------------------------------------------------------
# EXERCISES
#-------------------------------------------------------------------------------
# We're using two sets of data:

# From Eleanor: Census data with total population, land area, and population
# density in wide format
census <- read.csv("popdensity1990_00_10.csv", header=TRUE) %>% tbl_df()
View(census)

# Babyname data in tidy format.  For example, consider the top male names from
# the 1880's:
babynames
filter(babynames, year >=1880 & year <= 1889, sex=="M") %>%
  group_by(name) %>%
  summarize(n=sum(n)) %>%
  ungroup() %>%
  arrange(desc(n))



# EXERCISE: To the census data, add varibles "county_name" and "state_name", which
# are derived from the variable "QName".  Do this in a manner that keeps the variable
# "QName" in the data frame.

# SOLUTION:
census <- separate(census, QName, c("county_name", "state_name"), sep=", ",
                   remove=FALSE)



# EXERCISE: Create a new variable FIPS_code that follows the federal standard:
# http://www.policymap.com/blog/wp-content/uploads/2012/08/FIPSCode_Part4.png
# As a sanity check, ensure that the county with FIPS code 08031 is Denver
# County, Colorado.

# SOLUTION: We can't treat STATE and COUNTY as numerical variables, b/c we need
# the single digit ID's, like Alabama having STATE code 1.  Rather we treat them
# as character strings "padded with 0's".  Then we use the unite() command.
census <-
  mutate(census,
         state_code = str_pad(STATE, 2, pad="0"),
         county_code = str_pad(COUNTY, 3, pad="0")
  ) %>%
  unite("FIPS_code", state_code, county_code, sep = "")

# Denver county has STATE code 8 and COUNTY code 31, but we see we've correctly
# padded them with 0's.
filter(census, FIPS_code=="08031")



# EXERCISE: Plot histograms of the population per county, where we have the
# histograms facetted by year.

# SOLUTION: For ggplot to work cleanly, we need to first convert the data into
# tidy format.  We create a new data frame consisting of county_name,
# state_name, FIPS_code, and total population and gather() it in long format
# "keyed" by year.
totalpop <-
  select(census, county_name, state_name, contains("totalpop")) %>%
  gather("year", totalpop, contains("totalpop")) %>%
  mutate(
    year=factor(year, labels=c("1990", "2000", "2010"))
    )

# Now that we have a keying variable "year", we can easily facet this plot
ggplot(totalpop, aes(x=totalpop, y=)) +
  geom_histogram() +
  facet_wrap(~year) +
  scale_x_log10() +
  xlab("County population (log-scale)") +
  ggtitle("County populations for different years")



# EXERCISE: Now consider the babynames data set. The most popular male and
# female names between 1880 and 1889 inclusively were John and Mary exclusively.
# Present proportions data for all males named John and all females named Mary
# (some males were recorded as females, for example) born between 1880-1889 in
# wide format

# SOLUTION: We remove the "n" variable to keep the table looking clean.
filter(babynames,
       (name=="Mary" & sex=="F") | (name=="John" & sex=="M"),
       year >=1880 & year < 1889
) %>%
  select(-n) %>%
  spread(year, prop)

