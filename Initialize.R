#**************************
#** CLEAN YOUR ENVIRONMENT
#** You may want to clear your environment variables
#**************************
#rm(list=ls())

#**************************
#** WORK DIRECTORY
#** Set your work directory to the TrendMining project directory (where the script file are)
#** A folder "data" will be created for saving files (if such folder does not exist)
#** EDIT THE FOLLOWING LINE, set your own work directory
#**************************
setwd("K:/My Documents/Projects/TrendMining_2017/TrendMining")

my_work_dir = getwd()
my_data_dir = "data"

if (!file.exists(my_data_dir)) {
  dir.create(file.path(my_work_dir, my_data_dir))
}

#**************************
#** SOURCES - in TrendMining project directory
#**************************
source("GetScopusData.R")
source("GetStackOverflowData.R")
source("GetTwitterData.R")

#**************************
#** STACKOVERFLOW API KEY
#** Set your own StackOverflow API key here (or use the default below)
#** EDIT THE FOLLOWING LINE for your own API key
#**************************
api_key = "9raZ36FkYGFHDSNrW)gdsw(("

#**************************
#** GETOLDTWEETS-JAVA PATH
#** Set path to the directory for "GetOldTweets-java-master"
#** EDIT THE FOLLOWING LINE to point to the correct path 
#**************************
getoldtweets_path = "K:/My Documents/Projects/TrendMining_2017/GetOldTweets-java-master"

#**************************
#** SCOPUS API KEY
#** Set your own Scopus API key here
#** Create an account & create your API key => <your-own-scopus-api-key>
#** https://dev.elsevier.com/user/login
#** Replace the next line with set_api_key("YOUR_SCOPUS_KEY_HERE")
#** EDIT THE FOLLOWING LINE with YOUR OWN Scopus API key
#**************************
#set_api_key("<your-own-scopus-api-key>")

#**************************
#** FETCHING DATA - At this point you may fetch data using the functions
#**
#** FOR EXAMPLE
#**
#** > get_ScopusData("jira", "jira")
#** HTTP specified is:http://api.elsevier.com/content/search/scopus
#** [1] "start 25  found  -15"
#** [1] "K:/My Documents/Projects/TrendMining_2017/TrendMining/data/my_scopus_jira_data.RData"
#** >
#**
#** > get_stackOverFlowData("exploratory testing", "et")
#** [1] "page number: 1"
#** [1] "page number: 2"
#** [1] "page number: 3"
#** [1] "K:/My Documents/Projects/TrendMining_2017/TrendMining/data/my_STO_et_data.RData"
#** >
#**
#** > get_TwitterData("#pairwisetesting","pwt")
#** Searching... 
#** Done. Output file generated "output_got.csv".
#** [1] "K:/My Documents/Projects/TrendMining_2017/TrendMining/data/my_twitter_sbt_data.RData"
#** >
#**
#** Please note that fetching the data may take a long time!
#**
#**************************