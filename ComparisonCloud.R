rm(list = ls())
setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')
load ("my_articles_clean.RData")

#Let view a timeline
summary(my_articles$Date)
#Remove articles with no date
my_articles_2 <- my_articles[which(!is.na(my_articles$Date)),]
#split from the middle NA's couse trouble so we need [which(!is.na(my_articles$Date))]
new_titles <- my_articles$Title[my_articles$Date > median(my_articles_2$Date)]
old_titles <- my_articles$Title[my_articles$Date <= median(my_articles_2$Date)]
#to single 
all_titles <- c(paste(new_titles, collapse=" "), paste(old_titles, collapse=" "))
library(magrittr)
library(tm)
library(wordcloud)

removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
all_titles <- removeSpecialChars(all_titles)
all_titles <- removeWords(all_titles,c(stopwords("english"), "can", "used", "use", "paper", 
                                       "approach", "however", "new", "study", "using", "software",
                                       "introduction"))
tdm <- all_titles %>% VectorSource %>% Corpus %>% TermDocumentMatrix %>% as.matrix

colnames(tdm) <- c (paste (">", as.character(median(my_articles_2$Date))), 
                    paste ("<=", as.character(median(my_articles_2$Date))))
                         
comparison.cloud(tdm, max.words=100, title.size=1.5)
rm(my_articles_2)
#----------------------------------------------
# How about citations?
summary(my_articles$Cites)

#This time we do four way split
q1_t <- my_articles$Title[my_articles$Cites <= quantile(my_articles$Cites, probs = 0.25)]
q2_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.25) &
                          my_articles$Cites <= quantile(my_articles$Cites, probs = 0.5)]
q3_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.5) &
                          my_articles$Cites <= quantile(my_articles$Cites, probs = 0.75)]
q4_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.75)]

all_titles <- c(paste(q1_t, collapse=" "), 
                paste(q2_t, collapse=" "),
                paste(q3_t, collapse=" "), 
                paste(q4_t, collapse=" "))

#Start copy-paste
all_titles <- removeSpecialChars(all_titles)
all_titles <- removeWords(all_titles,c(stopwords("english"), "can", "used", "use", "paper", 
                                       "approach", "however", "new", "study", "using", "software",
                                       "introduction"))
tdm <- all_titles %>% VectorSource %>% Corpus %>% TermDocumentMatrix %>% as.matrix
#End copy-paste
colnames(tdm) <- c ("Q1", "Q2", "Q3", "Q4")
comparison.cloud(tdm, max.words=80, title.size=1.5)

