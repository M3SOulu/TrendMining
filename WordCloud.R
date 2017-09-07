#install.packages("text2vec")
#install.packages("tm")
#install.packages("magrittr")
#install.packages("wordcloud")
library(text2vec)
library(tm)
library(magrittr)
library(wordcloud)

draw_myWordCloud = function(my_file){
  
  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)
  
  print(paste("Creating Word cloud, my_file: ", my_file))
  
  my_text <- paste(my_articles$Title, my_articles$Abstract_clean)
  my_text = tolower(my_text)
  
  #A good is to remove more words that we do not care about 
  my_stopwords = c(stopwords("english"),"able","add","also","although","apply",
                   "app","apps","application","applications","applied","applying",
                   "approach","author","authors","based","best","business",
                   "can","case","class","classes","computer","could",
                   "company","device","different","doesnt","early","entire","every",
                   "find","file","fine","first","found","following","getting","get",
                   "health","height","high","higher","highly","however",
                   "industry","info","insertion","insertions","introduction","just",
                   "know","large","level","like","literature","local",
                   "making","many","naked","name","need","needs","new","now","null",
                   "may","much","often","old","overview","paper","please","project","projects",
                   "really","run","searched","see","seems","select","set","several",
                   "similar","since","small","showed","software","softwaredevelopment",
                   "something","still","story","student","students","study","studies",
                   "system","systems",
                   "team","teams","testing","text","tell","thanks","tried","try","trying",
                   "update","updated","updating","unable","use","used","user","users","using",
                   "various","versus","want","way","well","will","within",
                   "write","writing","without",
                   "year","years","one","two","three","four",
                   "horses","polo","animals","toxic","henan","keshan",
                   "toxicosis","high","clinical","province","signs","
                   disease","death")
  
  my_text = removeWords(my_text, my_stopwords)
  
  wordcloud(my_text, max.words=50, min.freq=5, random.order=FALSE, rot.per=0)
  
  rm(my_text)
  print("Finished Word cloud")
}