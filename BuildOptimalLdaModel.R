#install.packages("tm", dependencies = TRUE)
#install.packages("NLP", dependencies = TRUE)
#install.packages("magrittr", dependencies = TRUE)
#install.packages("slam", dependencies = TRUE)
#install.packages("topicmodels", dependencies = TRUE)
#install.packages("Rmpfr", dependencies = TRUE)
library(tm)
library(NLP)
library(magrittr)
library(slam)
library(topicmodels)
library(Rmpfr)

source ("mclapply.hack.R")

#Set the file to be analyzed, e.g.
my_file = "my_STO_ci_data.RData"

my_temp_file = paste(my_data_dir, "/", sep="")
my_temp_file = paste(my_temp_file, my_file, sep="")
load(my_temp_file)

my_stopwords = c(stopwords("english"),"able","add","also","although","app",
                 "apps","application","applications","apply",
                 "applied","applying","approach","arsenic","author","authors",
                 "best","based","better","brazil","built","business",
                 "can","case","class","classes","computer","could",
                 "company","device","different","doesnt","drug",
                 "early","entire","even","every",
                 "file","find","florida","food","get","getting",
                 "health","height","high","highly","however",
                 "industry","insertion","insertions","introduction","know",
                 "large","level","literature","local","making",
                 "many","may","mice","much","naked","name","needs","new","null",
                 "often","old","open","order","overview","paper","project","projects",
                 "really","reading","river","run","running",
                 "searched","seems","set","several","similar","since","small",
                 "software","softwaredevelopment","step","story","student","students",
                 "study","studies","system","systems","team","teams","text","tell","type",
                 "unable","update","updated","updating","usa","use","used","user","users",
                 "using","versus","visit","vitamin","want","within","without","write",
                 "writing","year","years","one","two","three","four","five","six","seven","eight")

#Articles with NA dates cause false analysis later kick them out
my_articles <- my_articles[which(!is.na(my_articles$Date)),]
my_text <- paste (my_articles$Title, my_articles$Abstract_clean)

removeSpecialChars <- function(x) gsub("[^a-zA-Z ]","",x)
my_text <- removeSpecialChars(my_text)
my_text <- removeWords(my_text, my_stopwords)

#Terms must be more than 2 characters and appear 3 or more times
dtm <- my_text %>% VectorSource %>% Corpus %>% DocumentTermMatrix (.,  control=list(wordLengths = c(2, Inf), bounds=list(global = c(3,Inf)))) 

#Clean up infrequent and meaningless terms TF/IDF------------------------------------
#source: http://cran.r-project.org/web/packages/topicmodels/vignettes/topicmodels.pdf
#Own experience: LDA is much faster 1.3s/iter -> 0.3s/iter or 0.2s/iter
dim(dtm)

#Word frequencies & Text lengths
summary(col_sums(dtm))
summary(row_sums(dtm))

term_tfidf <-tapply(dtm$v/row_sums(dtm)[dtm$i], dtm$j, mean) * log2(nDocs(dtm)/col_sums(dtm > 0))
#Lets kickout half of the terms that are less important, bit less than median
dtm <- dtm[,term_tfidf >= median(term_tfidf)] 

#--Remove documents that no have zero terms, i.e. they are made up of only meaningless general terms------------------------------
zero_term_docs = row_sums(dtm) > 0
dtm <- dtm[zero_term_docs,]

my_articles2 <- my_articles[zero_term_docs,]

my_new_file = getwd()
my_new_file = paste(my_new_file, "/", sep="")
my_new_file = paste(my_new_file, my_data_dir, sep="")
my_new_file = paste(my_new_file, "/", sep="")
my_new_file = paste(my_new_file, "Articles_NoZeroTerms.RData", sep="")

save(my_articles2, file=my_new_file)
  
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

#****************************************************************************
# MODIFY - 
#****************************************************************************
#First run with steps of e.g. 100, 50, 10, 5 one at the time to find general trend
#Then run with more justified sequence to try to find the optimum value
#****************************************************************************
#source ("mclapply.hack.R")
#For example
#sequ <- seq(20, 520, 100)
#sequ <- seq(75, 140, 5)
#sequ <- seq(80, 130, 1)
#sequ = seq(5, 200, 10)
my_from_sequ = 50
my_to_sequ = 150
my_by_sequ = 10
sequ <- seq(my_from_sequ, my_to_sequ, my_by_sequ)

#First line for testing with small data
#system.time(fitted_many <- lapply(sequ, function(k) LDA(dtm[21:200,], k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, thin=thin))))
  
#Use multi-core lapply (mclapply). Might make you machine freeze. 
#system.time(fitted_many <- mclapply(sequ, function(k) LDA(dtm, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, thin=thin))))

system.time(fitted_many <- lapply(sequ, function(k) LDA(dtm, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, thin=thin))))

#hm_many <- lapply(fitted_many, function(L)  L@loglikelihood)
hm_many <- unlist(lapply(fitted_many, function(L)  L@loglikelihood))

#Compute harmonic means
plot(sequ, hm_many, type = "l")

#compute optimum number of topics
opt_topics = sequ[which.max(hm_many)]
sequ[order(hm_many)]
sort(hm_many)

#************************************************
# Return to run another seq with different values 
#************************************************

#Once ready...
#Lets pick the winner
LDAWinner <- fitted_many[[which.max(hm_many)]]

lda_file = getwd()
lda_file = paste(lda_file, "/", sep="")
lda_file = paste(lda_file, my_data_dir, sep="")
lda_file = paste(lda_file, "/", sep="")
lda_file = paste(lda_file, "LDAWinner.RData", sep="")
  
save(LDAWinner, file=lda_file)
