library(readr)
library(dplyr)
library(tidyr)
daily_spec <- read_csv("data/daily_SPEC_2014.csv.bz2")


add_col_underscores <- function(df) {
    # replaces all spaces with underscores in all column names
    cnames <- c()
    for (col in names(df)) {
        new_col_name <- gsub(" ", "_", col)
        cnames <- c(cnames, new_col_name)
    }
    return(cnames)
}

names(daily_spec) <- add_col_underscores(daily_spec)


filter(daily_spec,
       State_Name == 'Wisconsin',
       Parameter_Name == 'Bromine PM2.5 LC') %>%
    select(Arithmetic_Mean) %>%
    summarize(mean = mean(Arithmetic_Mean, na.rm = TRUE))

daily_spec %>%
    group_by(Parameter_Name) %>%
    summarize(mean = mean(Arithmetic_Mean, na.rm = TRUE)) %>%
    arrange(mean) %>%
    tail(5)

daily_spec %>%
    group_by(State_Code, County_Code, Site_Num) %>%
    filter(Parameter_Name == 'Sulfate PM2.5 LC') %>%
    select(State_Code, County_Code, Site_Num, Arithmetic_Mean) %>%
    summarize(mean = mean(Arithmetic_Mean, na.rm = TRUE)) %>%
    arrange(mean) %>%
    tail(5)

x <- daily_spec %>%
    filter(Parameter_Name == 'EC PM2.5 LC TOR',
           State_Name %in% c('Arizona','California')) %>%
    group_by(State_Name) %>%
    summarize(mean = mean(Arithmetic_Mean, na.rm = TRUE)) %>%
    select(mean)
    
abs(x[1,] - x[2,])

daily_spec %>%
    filter(Parameter_Name == 'OC PM2.5 LC TOR',
           Longitude < -100) %>%
    summarize(median = median(Arithmetic_Mean, na.rm = TRUE))

library(readxl)
df <- readxl::read_excel("R_Programming_Environment/data/aqs_sites.xlsx")

#names(df) <- add_col_underscores(df)

df %>%
    group_by(`Location Setting`, `Land Use`) %>%
    summarise(n = n()) %>%
    filter(`Land Use` == 'RESIDENTIAL',
           `Location Setting` == 'SUBURBAN')

daily_spec$Site_Num <- as.numeric(daily_spec$Site_Num)
tmp <- full_join(x=df,
                 y=daily_spec,
                 by=c('Longitude','Latitude','Site Number'='Site_Num'))

tmp %>%
    filter(Parameter_Name == 'EC PM2.5 LC TOR',
           Longitude >= -100,
           `Land Use` == 'RESIDENTIAL',
           `Location Setting` == 'SUBURBAN') %>%
    select(Arithmetic_Mean) %>%
    summarize(median = median(Arithmetic_Mean, na.rm = TRUE))

library(lubridate)
tmp %>%
    filter(Parameter_Name == 'Sulfate PM2.5 LC',
           `Land Use` == 'COMMERCIAL') %>%
    group_by(months(Date_Local)) %>%
    summarize(mean = mean(Arithmetic_Mean, na.rm = T)) %>%
    arrange(mean) %>%
    tail(5)

mask <- tmp$`State Code` == 6
mask2 <- tmp$`County Code` == 65
mask3 <- tmp$`Site Number` == 8001

subset_x <- tmp[mask & mask2 & mask3, ]

bing <- subset_x %>%
    filter(Parameter_Name %in% c('Sulfate PM2.5 LC','Total Nitrate PM2.5 LC')) %>%
    group_by(Date_Local, Parameter_Name) %>%
    summarize(mean = mean(Arithmetic_Mean),
              n = n()) %>%
    group_by(Date_Local) %>%
    summarize(sum = sum(mean))

dim(bing[bing$sum > 10, "sum"])[1]


tmp %>%
    select(`State Code`, `County Code`, `Site Number`, Parameter_Name, Arithmetic_Mean, Date_Local) %>%
    filter(Parameter_Name %in% c('Sulfate PM2.5 LC','Total Nitrate PM2.5 LC')) %>%
    group_by(Date_Local, Parameter_Name, `State Code`, `County Code`, `Site Number`) %>%
    summarize(mean = mean(Arithmetic_Mean),
              n = n()) %>%
    spread(key=Parameter_Name, value=mean) %>%
    group_by(`State Code`, `County Code`, `Site Number`) %>%
    summarise(correlation = cor(`Sulfate PM2.5 LC`, `Total Nitrate PM2.5 LC`)) %>%
    arrange(desc(correlation))
