#install.packages("devtools", dependencies = TRUE)
#install.packages("rJava", depdendencies = TRUE)
library(devtools)
library(rJava)

get_twitter_data <- function (query_string){
  
  #Start the JVM
  .jinit('.')
  .jaddClassPath(getoldtweets_path)
  
  #For selecting a date range
  #from_date = "2010-01-01"
  #to_date = "2017-07-31"
  
  #Set the directory for creating the output file
  setwd(getoldtweets_path)

  command = "java -jar got.jar querysearch="
  command = paste(command, query_string, sep = "", collapse = '')

  #For a date range
  #command = paste(command, " since=", sep = "", collapse = '')
  #command = paste(command, from_date, sep = "", collapse = '')
  #command = paste(command, " until=", sep = "", collapse = '')
  #command = paste(command, to_date, sep = "", collapse = '')
  
  #For testing purposes, only
  #command = paste(command, "maxtweets=10", sep = " ", collapse = '')

  system(command)
           
  #Get the data    
  csv_file = paste(getoldtweets_path, "/output_got.csv", sep = '', collapse = '')
  my_data = read.csv(csv_file, sep=";", header=TRUE, quote="")
  
  return_data_frame  = data.frame()
  
  for (tweet in 1:nrow(my_data)){
    temp <- data.frame(
              AuthorName = my_data$username[tweet],
              Title = my_data$text[tweet],
              Date = my_data$date[tweet],
              Cites = my_data$retweets[tweet],
              Abstract = my_data$hashtags[tweet],
              Id = my_data$id[tweet]
    )
    
    return_data_frame <- rbind(return_data_frame, temp)
  }     
  return_data_frame
}
