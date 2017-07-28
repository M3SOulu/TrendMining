# devtool required for manual install
# rpython package for windows not available on cran download
#install.packages("devtools")
#library(devtools)

# Download zip file and uncompress, detailed instructions available in the text file
#Add the path for rpyhton folder here
#install("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/rPython")
#library(rPython)

# Example code to test rpython 
#python.call( "len", 1:3 )
#a <- 1:4
#b <- 5:8
#python.exec( "import got" )
#python.call( "concat", a, b)
#python.assign( "a",  "hola hola" )
#python.method.call( "a", "split", " " )

get_twitter_data <- function (query_string, path){
  #twitter data extraction code
  system("python --version") #it should be 2.7

  command_var = paste('python ',path, sep = '', collapse = '')
  command_var = paste(command_var,'/Exporter.py --querysearch "', sep = '', collapse = '')
  command_var = paste(command_var,query_string, sep = '', collapse = '')
  command_var = paste(command_var,'" -- output "', sep = '', collapse = '')
  command_var = paste(command_var, path, sep = '', collapse = '')
  command_var = paste(command_var,'/output_got.csv"', sep = '', collapse = '')
  
  #system('python G:/GetOldTweets-python-master/Exporter.py --querysearch "Robot Operating System" --output "G:/GetOldTweets-python-master/output_got.csv"')
  system(command_var)
  csv_var = paste(path,'/output_got.csv', sep = '', collapse = '')
  data <- read.csv(csv_var, sep=";", header=T)

  return_data_frame  = data.frame()

  for(outerloop in 1:nrow(data)){
    temp <- data.frame(AuthorName = data$username[outerloop],
                    Title = data$text[outerloop],
                    Date = data$date[outerloop],
                    Cites = data$retweets[outerloop],
                    Abstract = data$hashtags[outerloop],
                    Id = data$id[outerloop]
                    )
  
    return_data_frame <- rbind(return_data_frame, temp)
  }     
  return_data_frame
}
                               
