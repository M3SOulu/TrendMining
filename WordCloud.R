rm(list = ls())
#setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
#setwd('D:/Dropbox/Teach/2017_Trends')
load ("my_articles_clean.RData")
load ("twitter_articles_clean.RData")
load ("stackoverflow_articles_clean.RData")


my_text <- paste (my_articles$Title, my_articles$Abstract_clean)

#library(text2vec)
library (tm)
library(magrittr)
#This line could also be part of getting data. 
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
my_text = my_text %>% removeNumbers %>% removeSpecialChars %>% tolower # = tolower(removePunctuation(removeNumbers(my_text)))


#install.packages("wordcloud", dependencies = TRUE)
library(wordcloud)
wordcloud(my_text, max.words = 50, random.order = FALSE)

#Since our data was "TITLE-ABS-KEY(\"agile software development process\")"
#it makes sense to remove the works required in the query and re-plot
my_text = removeWords(my_text, c ("agile", "software", "development", "process", "processes"))

my_text = removeWords(my_text, c ("robot", "framework", "development", "process", "processes"))
my_text = removeWords(my_text, c ("test", "automation", "twitter", "http", "com"))

#A good is to remove more words that we do not care about 
my_text = removeWords(my_text, c ("can", "used", "use", "paper", "approach", "however", "new", "study", "using"))
