setwd('G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining')
rm(list = ls())
source("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/FunctionsStackOverflowApi.R")

query_string = "Robot Framework"
#query_string = "Test Automation"
#query_string = "Selenium"

my_articles <- get_stackoverflow_data (query_string)

abstract <- my_articles$Abstract
abstract <- gsub("<.*?>", "", abstract)
abstract <- gsub("[\r\n]", " ", abstract)
abstract <- gsub("\"", "", abstract)

#Add cleaned abstracts as a new column. We could also replace the existing but debugging is easier if we keep both. 
my_articles$Abstract_clean <- tolower(abstract)
my_articles$Title <- tolower (my_articles$Title)

#Date is character covert to Date objec
my_articles$Date <- as.Date(my_articles$Date)

save(my_articles, file="stackoverflow_articles_clean.RData")




