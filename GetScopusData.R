#install.packages("text2vec", dependencies = TRUE)
#install.packages("rscopus", dependencies = TRUE)
library(text2vec)
library(rscopus)

#Replace Scopus key-line with your OWN Scopus key: set_api_key("YOUR_SCOPUS_KEY_HERE")
source("FunctionsScopusApi.R")
source("Set_MyScopus_APIKey.R")

#Fetch scopus articles and a get a dataframe
#Please see restrictions: #https://dev.elsevier.com/api_key_settings.html
#Trying the query first via Scopus web-interface is recommended

#CREATE a sub-folder "data" to your project folder (where the project scripts are)
#For example
#app_path => set path to your project folder (e.g. use getwd()) - if null, the current work directory will be used
#query_string = "Continuous Integration"
#my_filename = "ci"

get_ScopusData = function(app_path, query_string, my_filename){

  my_query_string = "TITLE-ABS-KEY(\""
  my_query_string = paste(my_query_string, query_string, sep="")
  my_query_string = paste(my_query_string, "\") AND ALL('software testing')", sep="")
  
  #Get articles and save those - we do not want to re-run the query
  my_articles = get_scopus_papers(my_query_string)
  #save(my_articles, file="data/my_SCOPUS_articles_dirty.RData")
  #load ("data/my_SCOPUS_articles_dirty.RData")

  #Remove copyright sign.
  abstract = my_articles$Abstract
  abstract = gsub("Copyright ©+[^.]*[.]","",abstract)
  abstract = gsub("©+[^.]*[.]","",abstract) # Depdenging on the enviroment or data you might need something different* 
  abstract = gsub("All rights reserved[.]","",abstract)
  abstract = gsub("All right reserved[.]","",abstract)
  abstract = gsub("No abstract available[.]","",abstract)
  abstract = gsub("[0-9]", "", abstract)

  #Add cleaned abstracts as a NEW column. 
  #We could also replace the existing but debugging is easier if we keep both. 
  my_articles$Abstract_clean = tolower(abstract)
  my_articles$Title = tolower(my_articles$Title)

  #Remove papers that are summaries of conference proceedings. 
  #If check needed otherwise 0 would remove all papers.
  if (length(grep("proceedings contain", my_articles$Abstract_clean, ignore.case = TRUE)) > 0){
    my_articles = my_articles[-grep("proceedings contain", my_articles$Abstract_clean, ignore.case = TRUE),]
  }

  #Date is character convert to Date object
  my_articles$Date = as.Date(my_articles$Date)
  
  #Fixed filename: /data/my_scopus_<xxx>_data.RData
  my_file = ifelse(!is.null(app_path), app_path, getwd())
  my_file = paste(my_file, "/data/my_scopus_", sep="", collapse=" ")
  my_file = paste(my_file, my_filename, sep="", collapse=" ")
  my_file = paste(my_file, "_data.RData", sep="", collapse=" ")

  save(my_articles, file=my_file)
    
  return(my_file)
}