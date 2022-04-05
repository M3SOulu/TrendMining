
#** CLEAN YOUR ENVIRONMENT
#** You may want to clear your environment variables when starting a session. Saves from plenty of headache. 
rm(list=ls())


#** Set your work directory to the TrendMining project directory (where the script file are)
#** A folder "data" will be created for saving files (if such folder does not exist)
#** EDIT THE FOLLOWING LINE, set your own work directory
#setwd("K:/My Documents/Projects/TrendMining_2017/TrendMining")
setwd("C:/Users/mmantyla/Dropbox/Teach/2018_Trends_update_git/TrendMining")
my_work_dir = getwd()
my_data_dir = "data"
if (!file.exists(my_data_dir)) {
  dir.create(file.path(my_work_dir, my_data_dir))
}

#** STACKOVERFLOW API KEY
#** Set your own StackOverflow API key here (or use the default below)
#** EDIT THE FOLLOWING LINE for your own API key
#api_key = "9raZ36FkYGFHDSNrW)gdsw((" TODO old file name edit out
so_api_key = "9raZ36FkYGFHDSNrW)gdsw(("



#** GETOLDTWEETS-JAVA PATH
#** Set path to the directory for "GetOldTweets-java-master"
getoldtweets_path = paste(getwd(),"/GetOldTweets-java-master", sep="")


#** SCOPUS API KEY
#** Set your own Scopus API key here
#** Create an account & create your API key => <your-own-scopus-api-key>
#** https://dev.elsevier.com/ Click on " Attain API Key"
#** Replace the next line with set_api_key("YOUR_SCOPUS_KEY_HERE")
#** EDIT THE FOLLOWING LINE with YOUR OWN Scopus API key
#install.packages("rscopus", dependencies = TRUE)
library("rscopus")
#set_api_key("<your-own-scopus-api-key>")
#alternatively you may store it a personal file somewhere else. 
source("C:/Users/mmantyla/Dropbox/Research - Publications/2017 Agile Book Chapter/Scripts/SetScopusApiKey.R") 

