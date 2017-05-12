rm(list = ls())
setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')
load ("my_articles_clean.RData")

#install.packages("text2vec", dependencies=TRUE)
library("text2vec")

my_text <- paste (my_articles$Title, my_articles$Abstract_clean)
#library(text2vec)
library (tm)
library(magrittr)
#This line could also be part of getting data. 
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
#Here we use text2vec package as it contains very fast LDA clustering implementation
#Note there is some overlap with between text2vec, tm, and topicmodels pacakges
library(text2vec)
my_tokens = my_text %>% removeNumbers %>% removeSpecialChars %>% tolower %>% word_tokenizer # = tolower(removePunctuation(removeNumbers(my_text)))
it = itoken(my_tokens)
sw = c ("we", "by", "it", "from", "their", "based", "our", "can", "be", "have", "will", "which", "into", "at", "study", "studies"
        ,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","r","q","s","t","u","v","w","x","y","z",
        "just", "ll", "see", "many", "never", "get", "way", "also", "new", "end", "one", "two", "three", "four", "five")

#Remove stopwords
vocab <- create_vocabulary(it, stopwords = c (stopwords("english"), sw))

#Limit vocabulary to 40000 terms. Each word is only allowed to appear in 50% of the documents
vocab <- prune_vocabulary(vocab, max_number_of_terms = 40000, doc_proportion_max = 0.5)

#Create DTM
dtm = create_dtm(it, vocab_vectorizer(vocab),'lda_c')
#LDA model with 20 topics to provide an overview
lda_model = LatentDirichletAllocation$new(n_topics = 20, vocabulary = vocab)
#We run 200 iteration
doc_topic_distr = lda_model$fit_transform(dtm, n_iter =200, check_convergence_every_n = 5)
# save for fater access later. 
save (lda_model, file="lda_model_TSE")
#load("lda_model_TSE")
#install.packages("LDAvis", dependencies=TRUE)
# run LDAvis visualisation if needed (make sure LDAvis package installed)
#Be patient this might take while before anything is plotted. See viewer tap on the right
lda_model$plot()
