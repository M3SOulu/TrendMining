rm(list = ls())
setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')
#library(text2vec)
#install.packages("rscopus", dependencies = TRUE)


source("FunctionsScopusApi.R")
#Replace the next line with set_api_key("YOUR_SCOPUS_KEY_HERE")
source("C:/Users/mmantyla/Dropbox/Research - Publications/201x Agile Book Chapter/Scripts/SetScopusApiKey.R") 

#Fetch scopus articles and a get a dataframe
#Please see restrictions
#https://dev.elsevier.com/api_key_settings.html
#Trying the query first via Scopus web interface is recommended
#Example that returns roughly 115
#query_string = "TITLE-ABS-KEY(\"agile software development process\")"
#my_articles <- get_scopus_papers (query_string)
#save(my_articles, file="my_articles_dirty.RData")
#Another example. This is ISSN number of IEEE Transactions on Software Engineering
#This example  returns over 3,000 articles. Will take some time. Speed varies. typical 250 articles per minute
query_string = "ISSN(0098-5589)"
my_articles <- get_scopus_papers (query_string)
#SAVE here. We do not want to re run the query
#save(my_articles, file="my_TSE_articles_dirty.RData")
load ("my_TSE_articles_dirty.RData")

#We need to remove copyright sign. 
abstract <- my_articles$Abstract
abstract <- gsub("Copyright ©+[^.]*[.]","",abstract)
abstract <- gsub("©+[^.]*[.]","",abstract) # Depdenging on the enviroment or data you might need something different* 
abstract <- gsub("All rights reserved[.]","",abstract)
abstract <- gsub("All right reserved[.]","",abstract)
abstract <- gsub("No abstract available[.]","",abstract)



#Add cleaned abstracts as a new column. We could also replace the existing but debugging is easier if we keep both. 
my_articles$Abstract_clean <- tolower(abstract)
my_articles$Title <- tolower (my_articles$Title)

#Remove papers that are summaries of conference proceedings. If check needed otherwise 0 would remove all papers
if (length(grep("proceedings contain", my_articles$Abstract_clean, ignore.case = TRUE)) > 0){
  my_articles <- my_articles[-grep("proceedings contain", my_articles$Abstract_clean, ignore.case = TRUE),]
}

#Date is character covert to Date objec
my_articles$Date <- as.Date(my_articles$Date)

save(my_articles, file="my_articles_clean.RData")
#load ("my_articles_dirty.RData")




*--------------------------------------------------
#Depending on the enviroment and data you might need various copyright removal statements as in below. 
# Remove stuff after copyright, i.e. copyright by ACM 
#this copyright in the end end remove. 
# abstract <- gsub("\\.\\s*A\\(C\\).*","",abstract) # Sometimes A(C)
# abstract <- gsub("\\.\\s*\\(C\\).*","",abstract) # This is Copy right sign -> (C) after conversion to latic-ascii  
# abstract <- gsub("Copyright.*","",abstract) # THis is copyright text 
# abstract <- gsub("Â©.*","",abstract)
# #abstract <- gsub("?.*","",abstract)
# #Some quatation marks cause problems. 
# abstract <- gsub("\U2019","'",abstract)#
# abstract <- gsub("\\.\\s*©.*","",abstract) # Sometimes A(C)©
#This is copyright removal everything after copyright sign until . is removed

