#install.packages("text2vec", dependencies = TRUE)
library("text2vec")


source("FunctionsScopusApi.R")

#Fetch scopus articles and a get a dataframe
#Please see restrictions: #https://dev.elsevier.com/api_key_settings.html
#Trying the query first via Scopus web-interface is recommended

#query_string = string to be searched
#my_filename = string to be used as a part of the filename

#Another example. This is ISSN number of IEEE Transactions on Software Engineering (=TSE)
#This example  returns over 3,000 articles. Will take some time. Speed varies. typical 250 articles per minute
#query_string = "ISSN(0098-5589)"
#my_filename = "TSE_All"

#For example
#Finds 321 papers (29 April 2018). Suitable for classroom demo
query_string = "Continuous Integration"
my_filename = "ci"



#later you may want to make this function. 
#for learning it is better to excute in line by line fashion
#get_ScopusData = function(query_string, my_filename){

  my_query_string = "TITLE-ABS-KEY(\""
  my_query_string = paste(my_query_string, query_string, sep="")
  #EDIT this line
  my_query_string = paste(my_query_string, "\") AND ALL('software testing')", sep="")
  
  #Get articles and save those - we do not want to re-run the query
  my_articles = get_scopus_papers(my_query_string)
  #Another example. This is ISSN number of IEEE Transactions on Software Engineering (=TSE)
  #This example  returns over 3,000 articles. Will take some time. Speed varies. typical 250 articles per minute
  #my_articles = get_scopus_papers("ISSN(0098-5589)")
  #save(my_articles, file="data/my_TSE_articles_dirty2.RData")#my_TSE_articles_dirty
  #For classroom demo load data instead of fetching. This is a larger file better for demoing text mining 
  #load ("data/my_TSE_articles_dirty.RData")

  #Remove copyright sign.
  abstract = my_articles$Abstract
  abstract = gsub("Copyright ©+[^.]*[.]","",abstract)
  abstract = gsub("©+[^.]*[.]","",abstract) # Depdenging on the enviroment or data you might need something different* 
  abstract = gsub("All rights reserved[.]","",abstract)
  abstract = gsub("All right reserved[.]","",abstract)
  abstract = gsub("No abstract available[.]","",abstract)
  abstract = gsub("[0-9]", "", abstract)

  #It is easy to accidentally too much or too little. 
  #Check length of abstracts -> ratio of new vs origal
  nchar(abstract)/nchar(my_articles$Abstract)
  mean (nchar(abstract)/nchar(my_articles$Abstract), na.rm=TRUE)
  abstract[nchar(abstract)/nchar(my_articles$Abstract)<0.5]
  
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
  
  #Fixed filename: /data/my_scopus_<my_filename>_data.RData
  my_file = my_work_dir
  my_file = paste(my_file, "/data/my_Scopus_", sep="", collapse=" ")
  my_file = paste(my_file, my_filename, sep="", collapse=" ")
  my_file = paste(my_file, "_data.RData", sep="", collapse=" ")

  save(my_articles, file=my_file)
    
#  return(my_file)
#}