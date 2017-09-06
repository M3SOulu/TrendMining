#install.packages("rJava", dependencies = TRUE)
library(rJava)

source("FunctionsTwitterApi.R")

#SET CORRECT path to the folder "GetOldTweets-java-master/", e.g. in my case that is...
getoldtweets_path = "K:/My Documents/Projects/TrendMining_2017/GetOldTweets-java-master/"

#Have a sub-folder "data" to your project folder (where the project scripts are)
#For example
#app_path => set path to your project folder (e.g. use getwd()) - if null, the current work directory will be used
#query_string = "#jenkins"
#my_filename = "jenkins"

get_MyTwitterData = function (app_path, query_string, my_filename) {

  #Save working directory, in case tat is not provided
  if (is.null(app_path))
    original_app_path = getwd()
  
  #This may take quite a long time, depending on the data 
  my_articles = get_twitter_data(query_string, getoldtweets_path)

  #save(my_articles, file="data/my_Twitter_articles_dirty.RData")
  if (is.factor(my_articles$Abstract))
    my_articles$Abstract = levels(my_articles$Abstract)[my_articles$Abstract]
  
  abstract = my_articles$Abstract
  title <- my_articles$Title

  #Hashtags
  abstract = gsub("#", " ", abstract)
  abstract = gsub("(http|https)[://][^ ]*", " ", abstract)
  abstract = gsub("@.*? ", " ", abstract)
  abstract = gsub("@.*", " ", abstract)
  abstract = gsub("[[:punct:]]", " ", abstract)
  abstract = gsub("[\'\"/.,-:;!=%~*]", " ", abstract)
  abstract = gsub("[.]", " ", abstract)
  abstract = gsub("[ \t]{2,}", " ", abstract)
  chartr("åäáàâãöóòôõúùûüéèíìïëêñý", "aaaaaaooooouuuueeiiieeny", abstract)
 
  #Text
  title = gsub("#", " ", title)
  title = gsub("(http|https)[://][^ ]*"," ",title)
  title = gsub("@.*? ", " ", title)
  title = gsub("@.*", " ", title)
  title = gsub("[[:punct:]]", " ", title)
  title = gsub("[\'\"/.,-:;!=%~*]", " ", title)
  title = gsub("[.]", " ", title)
  title = gsub("[ \t]{2,}", " ", title)
  chartr("åäáàâãöóòôõúùûüéèíìïëêñý", "aaaaaaooooouuuueeiiieeny", title)
  
  if (is.factor(my_articles$AuthorName))
    my_articles$AuthorName = levels(my_articles$AuthorName)[my_articles$AuthorName]
  
  if (is.factor(my_articles$Cites)) {
    my_articles$Cites = levels(my_articles$Cites)[my_articles$Cites]
    my_articles$Cites = as.numeric(my_articles$Cites)
    my_articles$Cites[is.na(my_articles$Cites)] = 0
  }
  
  if (is.factor(my_articles$Id)){
    my_articles$Id = levels(my_articles$Id)[my_articles$Id]
    my_articles$Id = as.numeric(my_articles$Id)
    my_articles$Id[is.na(my_articles$Id)] = 0
  }  
  
  #Add cleaned abstracts as a new column. 
  #We could also replace the existing but debugging is easier if we keep both. 
  my_articles$Abstract_clean = tolower(abstract)
  my_articles$Title = tolower(title)

  #Date is character covert to Date objec
  my_articles$Date = as.Date(my_articles$Date)
  
  #Change back to original working directory
  ifelse(is.null(app_path), setwd(original_app_path), setwd(app_path))

  #Fixed filename: /data/my_twitter_<xxx>_data.RData
  my_file = ifelse(!is.null(app_path), app_path, original_app_path)
  my_file = paste(my_file, "/data/my_twitter_", sep="", collapse=" ")
  my_file = paste(my_file, my_filename, sep="", collapse=" ")
  my_file = paste(my_file, "_data.RData", sep="", collapse=" ")
  
  save(my_articles, file=my_file)
 
  return(my_file)
}