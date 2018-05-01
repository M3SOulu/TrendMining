#install.packages("magrittr", dependencies = TRUE)
#install.packages("tm", dependencies = TRUE)
#install.packages("wordcloud", dependencies = TRUE)
library(magrittr)
library(tm)
library(wordcloud)

my_stopwords = c(stopwords::stopwords(language = "en", source = "snowball"),"myStopword1", "myStopword2")
#EDIT this row
my_file <- "my_Scopus_TSE_articles_clean_data.RData"
#draw_ComparisonCloud = function(my_file){

  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)

  print(paste("Creating comparison cloud, my_file:", my_temp_file))
  
  #Remove articles with no date
  my_articles_2 <- my_articles[which(!is.na(my_articles$Date)),]

  #Split from the middle 
  #(NA's couse trouble so we need [which(!is.na(my_articles$Date))])
  new_titles <- my_articles$Title[my_articles$Date > median(my_articles_2$Date)]
  old_titles <- my_articles$Title[my_articles$Date <= median(my_articles_2$Date)]

  #To single 
  all_titles <- c(paste(new_titles, collapse=" "), paste(old_titles, collapse=" "))

  removeSpecialChars <- function(x) gsub("[^a-zA-Z ]","",x)
  all_titles <- removeSpecialChars(all_titles)
  all_titles = removeWords(all_titles, my_stopwords)

  tdm <- all_titles %>% VectorSource %>% Corpus %>% TermDocumentMatrix %>% as.matrix
  #Here we split from the middle. We get two group one older and newer
  colnames(tdm) <- c (paste (">", as.character(median(my_articles_2$Date))), 
                  paste ("<=", as.character(median(my_articles_2$Date))))
                         
  comparison.cloud(tdm, max.words=50, rot.per=0, 
                   colors=brewer.pal(3,"Set1"),
                   title.size=1.5)

  rm(my_articles_2)
  print("Finished comparison cloud")
#}

#draw_FourWayComparisonCloud = function(my_file){

  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)

  print(paste("Creating 4-Way Comparison cloud, my_file:", my_temp_file))
    
  #This time we do four way split
  q1_t <- my_articles$Title[my_articles$Cites <= quantile(my_articles$Cites, probs = 0.25)]
  q2_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.25) &
              my_articles$Cites <= quantile(my_articles$Cites, probs = 0.5)]
  q3_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.5) &
              my_articles$Cites <= quantile(my_articles$Cites, probs = 0.75)]
  q4_t <- my_articles$Title[my_articles$Cites > quantile(my_articles$Cites, probs = 0.75)]

  if(length(q1_t) == 0)
    q1_t = "no_data"
  if(length(q2_t) == 0)
    q2_t = "no_data"
  if(length(q3_t) == 0)
    q3_t = "no_data"
  if(length(q4_t) == 0)
    q4_t = "no_data"
  
  all_titles <- c(paste(q1_t, collapse=" "), 
          paste(q2_t, collapse=" "),
          paste(q3_t, collapse=" "), 
          paste(q4_t, collapse=" "))

  removeSpecialChars <- function(x) gsub("[^a-zA-Z ]","",x)
  all_titles <- removeSpecialChars(all_titles)
  all_titles = removeWords(all_titles, my_stopwords)
  
  tdm <- all_titles %>% VectorSource %>% Corpus %>% TermDocumentMatrix %>% as.matrix

  colnames(tdm) <- c ("Q1 <= 0.25", "0.25 < Q2 <= 0.5", 
                      "0.5 < Q3 <= 0.75", "Q4 > 0.75")
  comparison.cloud(tdm, max.words=50, rot.per=0, title.size=1.5, colors=brewer.pal(4,"Set1"))
  
  rm(my_articles)
  
  print("FInished 4-Way Comparison cloud")
  
#}
