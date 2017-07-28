rm(list = ls())
source("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/FunctionsTwitterApi.R")

#this requires a python project, o first download the git project into a local folder
# give its path here
path = "G:/GetOldTweets-python-master"

# python installed on the local machine should be 2.7 version
query_string = "Robot Operating System"
 
my_articles <- get_twitter_data (query_string, path)
# this will take time around 5-10 mins depending on the data