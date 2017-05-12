
install.packages('ggplot2', dependencies = TRUE)
rm(list = ls())

setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')
load ("my_articles_clean.RData")

# Create corpus by appending title and abstract to character string
library(tm)
corpus <- Corpus(VectorSource(paste (my_articles$Title, my_articles$Abstract_clean)))
                 
# In the past terms "author" and "authors" were used instead of we and I. This can creates a unncessary topics based on the word "author". THus we remove them
# Standard copyright stuff sometimes found in the abstract fields
# not used when only titles as analyzed. 

dtm = DocumentTermMatrix(corpus, control = list(tolower=TRUE, stemming = FALSE, stopwords = FALSE, 
                                                wordLengths = c(3, Inf), removeNumbers = TRUE, removePunctuation = TRUE,
                                                bounds = list(global = c(5,Inf)) ))
(freq.terms <- findFreqTerms(dtm, lowfreq = 50))
#Is "and" or "are" meaningfull words. Lets get rid of them by setting stopwords=TRUE
dtm = DocumentTermMatrix(corpus, control = list(tolower=TRUE, stemming = FALSE, stopwords = TRUE, 
                                                wordLengths = c(3, Inf), removeNumbers = TRUE, removePunctuation = TRUE,
                                                bounds = list(global = c(5,Inf)) ))
#still words that are not so good remove them as 
mystopwords <- c ("can", "used", "use", "paper", "approach", "however", "new", "study", "using");
dtm = DocumentTermMatrix(corpus, control = list(tolower=TRUE, stemming = FALSE, stopwords = c (stopwords("english"), mystopwords), 
                                                wordLengths = c(3, Inf), removeNumbers = TRUE, removePunctuation = TRUE,
                                                bounds = list(global = c(5,Inf)) ))

#Stemming can also be used but the results might not be any better. 
dtm_stem = DocumentTermMatrix(corpus, control = list(tolower=TRUE, stemming = TRUE, stopwords = c (stopwords("english"), mystopwords), 
                                                 wordLengths = c(3, Inf), removeNumbers = TRUE, removePunctuation = TRUE,
                                                 bounds = list(global = c(5,Inf)) ))
(freq.terms <- findFreqTerms(dtm_stem, lowfreq = 50))


#Lets plot

library(magrittr)

#convert to martix, compute colSums (total word counds), take only words with more thatn 50 occurecents, 
#and convert to dataframe with two columns: terms and frequencies 
df <- dtm %>% as.matrix %>% colSums %>% subset (. >= 50) %>% data.frame(term=names(.), freq=.)
library(ggplot2)
ggplot(df, aes(x = term, y = freq)) + geom_bar(stat = "identity") +xlab("Terms") + ylab("Count") + coord_flip()


#--------------------Cluster and and Plot dendogram ---------------------------------------

#We can subset to  200 papers if we have thounsands
#dtm <- dtm[1:200,]

# Compute distance matrix https://stat.ethz.ch/R-manual/R-devel/library/stats/html/dist.html
#https://en.wikipedia.org/wiki/Distance_matrix
dist.mat <- dist(as.matrix(dtm))

#Hirarcical clustering http://www.r-tutor.com/gpu-computing/clustering/hierarchical-cluster-analysis
h <- hclust(dist.mat, method = "ward.D")

#Finally,  we plot to file. R-studio plotting view is not large enough.
pdf("Large.pdf", width=40, height=15)
par(cex=0.7, mar=c(5, 8, 4, 1))
plot(h, labels = my_articles$Title, sub = "")
dev.off()




