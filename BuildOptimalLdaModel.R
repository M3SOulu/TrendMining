rm(list = ls())
setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')
load ("my_articles_clean.RData")

#Articles with NA dates cause false analysis later kick them out
my_articles <- my_articles[which(!is.na(my_articles$Date)),]
my_text <- paste (my_articles$Title, my_articles$Abstract_clean)
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
my_text <- removeSpecialChars(my_text)
my_text <- removeWords(my_text,c(stopwords("english")))
library("tm")
library("magrittr")
#Terms must be more than 2 characters and appear 3 or more times
dtm <- my_text %>% VectorSource %>% Corpus %>% DocumentTermMatrix (.,  control = list(wordLengths = c(2, Inf), bounds = list(global = c(3,Inf)))) 


#Clean up infrequent and meaningless terms TF/IDF------------------------------------
#source: http://cran.r-project.org/web/packages/topicmodels/vignettes/topicmodels.pdf
#Own experience: LDA is much faster 1.3s/iter -> 0.3s/iter or 0.2s/iter
dim(dtm)
library("slam")
summary(col_sums(dtm))#Word frequencies
summary(row_sums(dtm))#Text lenghts

term_tfidf <-tapply(dtm$v/row_sums(dtm)[dtm$i], dtm$j, mean) * log2(nDocs(dtm)/col_sums(dtm > 0))
#Lets kickout half of the terms that are less important, bit less than median
dtm <- dtm[,term_tfidf >= median(term_tfidf)] 

#--Remove documents that no have zero terms, i.e. they are made up of only meaningless general terms------------------------------
zero_term_docs = row_sums(dtm) > 0
dtm <- dtm[zero_term_docs,]

my_articles2 <- my_articles[zero_term_docs,]
save(my_articles2, file="my_articles_clean2.RData")
summary(col_sums(dtm))
dim(dtm)
#Correct number of topics---------------------------------------------------------
#http://stackoverflow.com/questions/21355156/topic-models-cross-validation-with-loglikelihood-or-perplexity/21394092#21394092
#http://epub.wu.ac.at/3558/1/main.pdf
#------------How many topics are we going to need

# this is as in many LDA examples
burnin = 100 #GS04 uses 800 or 1100 depdending on number of topics
#burnin=1000
iter = 100 #defaults to 2000. 1000 to make it go faster
#iter=1000
thin = 10 # As with other MCMC algorithms, Gibbs sampling generates a Markov chain of samples, each of which is correlated with nearby samples. As a result, care must be taken if independent samples are desired (typically by thinning the resulting chain of samples by only taking every nth value, e.g. every 100th value). https://en.wikipedia.org/wiki/Gibbs_sampling
#thin=100
library("topicmodels")

#****************************************************************************
# MODIFY - 
#****************************************************************************
#First run with steps of e.g. 100, 50, 10, 5 one at the time to find general trend
#Then run with more justified sequence to try to find the optimum value
#****************************************************************************

source ("mclapply.hack.R")
#sequ <- seq(20, 520, 100)    #
sequ <- seq(50, 150, 25)    #
#sequ <- seq(50, 250, 25)    #
#sequ <- seq(75, 140, 5)    #
#sequ <- seq(80, 130, 1)    #


#First line for testing with small data
#system.time(fitted_many <- lapply(sequ, function(k) LDA(dtm[21:200,], k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, thin=thin))))

#Use multi-core lapply (mclapply). Might make you machine freeze. 
system.time(fitted_many <- mclapply(sequ, function(k) LDA(dtm, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, thin=thin))))

hm_many <- lapply(fitted_many, function(L)  L@loglikelihood)
hm_many <- unlist(lapply(fitted_many, function(L)  L@loglikelihood))

# compute harmonic means
library("Rmpfr")
plot(sequ, hm_many, type = "l")

# compute optimum number of topics
sequ[which.max(hm_many)]

sequ[order(hm_many)]
sort(hm_many)
#************************************************
# Return to run another seq with different values 
#************************************************

#Lets pick the winner
LDAWinner <- fitted_many[[which.max(hm_many)]]
#LDAWinner <- fitted_many[[16]]
save(LDAWinner, file=paste("LDAWinner", ".RData", sep=""))
