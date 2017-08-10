setwd('G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining')

rm(list = ls())
source("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/FunctionsTwitterApi.R")

#this requires a python project, o first download the git project into a local folder
# give its path here
path = "G:/GetOldTweets-python-master"

# python installed on the local machine should be 2.7 version
query_string = "Robot Operating System"
 
my_articles <- get_twitter_data (query_string, path)
# this will take time around 5-10 mins depending on the data


abstract <- my_articles$Abstract
title <- my_articles$Title

abstract <- gsub("#", " ", abstract)
abstract <- gsub("&amp", "", abstract)
abstract <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", abstract)
abstract <- gsub("@\\w+", "", abstract)
abstract <- gsub("[[:punct:]]", " ", abstract)
abstract <- gsub("[[:digit:]]", "", abstract)
abstract <- gsub("http\\w+", "", abstract)


title <- gsub("&amp", "", title)
title <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", title)
title <- gsub("@\\w+", "", title)
title <- gsub("[[:punct:]]", " ", title)
title <- gsub("[[:digit:]]", "", title)
title <- gsub("http\\w+", "", title)
title <- gsub("[ \t]{2,}", "", title)
title <- gsub("^\\s+|\\s+$", "", title) 
title <- gsub("â???~","",title)
title <- gsub("â???","",title)
title <- gsub("T","",title)


#Add cleaned abstracts as a new column. We could also replace the existing but debugging is easier if we keep both. 
my_articles$Abstract_clean <- tolower(abstract)
my_articles$Title_clean <- tolower (title)

#Date is character covert to Date objec
my_articles$Date <- as.Date(my_articles$Date)

save(my_articles, file="twitter_articles_clean.RData")
