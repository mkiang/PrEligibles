##  Side project name: Prevalence of Eligibles
##  Author: Mathew Kiang
##  Based on: http://www.businessinsider.com/highly-eligible-singles-2015-2
##  Data from: usa.ipums.org -- Minnesota Pop Center at Univ of Minnesota
##  Citation: Steven Ruggles, J. Trent Alexander, Katie Genadek, Ronald Goeken, 
##      Matthew B. Schroeder, and Matthew Sobek. Integrated Public Use 
##      Microdata Series: Version 5.0 [Machine-readable database]. Minneapolis: 
##      University of Minnesota, 2010.
##  Code for waterfall.r comes from: 
##      http://www.jameskeirstead.ca/blog/waterfall-plots-in-r/

library(dplyr)
##  Import raw data. Note: from bash, know that we can skip 15 million lines --
##  full file has data back to 2000, but for performance, we'll just use 2013.
full_data <- read.fwf("./data/usa_00001.dat", 
                      widths = c(4, 2, 8, 10, 1, 4, 10, 1, 3, 1, 
                                 1, 1, 3, 2, 3, 1, 2, 7),
                      col.names = c("year", "datanum", "serial", "hhwt", "gq", 
                                    "pernum", "perwt", "sex", "age", "marst", 
                                    "marrno", "race", "raced", "educ", "educd", 
                                    "empstat", "empstatd", "inctot"), 
                      colClasses = rep("integer", 18), 
                      skip = 15000000)
full_data <- full_data[full_data$year == 2013, -c(13, 14, 17)]
save(full_data, file = "./data/2013data.RData")

totalpop <- sum(full_data$perwt / 100)
##  316128839
under18 <- sum(full_data$perwt[full_data$age < 18] / 100)
##  73501617

##  Collapse some race categories
full_data$racecat <- full_data$race
full_data$racecat[full_data$race > 6] <- 7

##  Collapse education
full_data$educat <- full_data$educd
full_data$educat[full_data$educd < 62] <- 1 # no HS diploma or GED
full_data$educat[full_data$educd == 62 | 
                     full_data$educd == 63 | 
                     full_data$educd == 64] <- 2 # HS diploma or GED
full_data$educat[full_data$educd == 65 | 
                     full_data$educd == 70 | 
                     full_data$educd == 71 | 
                     full_data$educd == 80 | 
                     full_data$educd == 90 | 
                     full_data$educd == 100 | 
                     full_data$educd == 110 | 
                     full_data$educd == 111 | 
                     full_data$educd == 112 | 
                     full_data$educd == 113] <- 3 # some college no degree
full_data$educat[full_data$educd == 81 | 
                     full_data$educd == 82 | 
                     full_data$educd == 83] <- 4 # associates degree
full_data$educat[full_data$educd == 101] <- 5 # bachelors degree
full_data$educat[full_data$educd == 114] <- 6 # masters degree
full_data$educat[full_data$educd == 115] <- 7 # professional beyond bachelors degree
full_data$educat[full_data$educd == 116] <- 8 # doctorate degree

##  Collapse marital status
full_data$marstcat <- full_data$marst
full_data$marstcat[full_data$marst == 2] <- 1 # married, spouse absent

subdata <- full_data %>%
    filter(age > 17) %>% 
    mutate(agecat = cut(age, breaks = c(17, 20, 25, 30, 35, 40, 45, 50, 
                                        55, 60, 65, 200), labels = FALSE), 
           incomecat = cut(inctot, breaks = c(-1000000, -1, 25000, 50000, 
                                              75000, 100000, 150000, 
                                              200000, 250000, 300000, 
                                              500000, 1000000, 50000000), 
                           labels = FALSE)) %>%
    group_by(sex, agecat, incomecat, empstat, educat, racecat, marstcat) %>%
    summarize(perwt = sum(perwt / 100))

save(subdata, file = "./data/subdata.RData")
##  The analytic dataset now looks like this:
# > head(subdata)
# Source: local data frame [6 x 9]
# Groups: sex, agecat, incomecat, empstat, educat, racecat, marrno
# 
#   sex agecat incomecat empstat educat racecat marrno marst perwt
# 1   1      1         1       1      1       1      0     6   137
# 2   1      1         1       1      3       1      0     6   105
# 3   1      1         1       1      3       7      0     6   207
# 4   1      1         1       2      2       1      0     6   134
# 5   1      1         1       2      3       1      0     6   103
# 6   1      1         1       3      1       1      0     6   116
