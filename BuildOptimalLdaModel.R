#install.packages("tm", dependencies = TRUE)
#install.packages("NLP", dependencies = TRUE)
#install.packages("magrittr", dependencies = TRUE)
#install.packages("slam", dependencies = TRUE)
#install.packages("Rmpfr", dependencies = TRUE)
library(tm)
#library(NLP)
#library(magrittr)
#library(slam)
#library(Rmpfr)

library("magrittr")
library("text2vec")
library("tokenizers")
#
#source ("mclapply.hack.R")

#Set the file to be analyzed, e.g.
my_file = "my_Scopus_TSE_articles_clean_data.RData"

my_temp_file = paste(my_data_dir, "/", sep="")
my_temp_file = paste(my_temp_file, my_file, sep="")
load(my_temp_file)

my_stopwords = c(stopwords::stopwords(language = "en", source = "snowball"),"myStopword1", "myStopword2")

#Articles with NA dates cause false analysis later kick them out
my_articles <- my_articles[which(!is.na(my_articles$Date)),]
my_text <- paste (my_articles$Title, my_articles$Abstract_clean)

removeSpecialChars <- function(x) gsub("[^a-zA-Z ]","",x)
my_text <- removeSpecialChars(my_text)
my_text <- removeWords(my_text, my_stopwords)
my_articles$Clean_Text <- my_text
#-----------------------------------------------------------------------------------
#Create first LDA model. We select 80% for model creation remaining is for testing
#See tutorial for more details http://text2vec.org/topic_modeling.html#latent_dirichlet_allocation
#model goodness
sample <- sample.int(n = nrow(my_articles), size = floor(.80*nrow(my_articles)), replace = F)
#create tokens
tokens = my_articles$Clean_Text [sample] %>%  tokenize_words (strip_numeric = TRUE)
it <- itoken(tokens, progressbar = FALSE)
#Here we create the vocabulary. Term must appear in min 10 documents (you might want to edit this)
#If term appears in more than 30% documents we remove because it is too frequent (you might want to edit this as well)
v = create_vocabulary(it) %>% prune_vocabulary(term_count_min = 10, doc_proportion_max = 0.3)
vectorizer = vocab_vectorizer(v)
#create document-term matrix
dtm = create_dtm(it, vectorizer, type = "dgTMatrix")

# we create 10 topics 
lda_model = LDA$new(n_topics = 10, doc_topic_prior = 0.1, topic_word_prior = 0.01)
doc_topic_distr = lda_model$fit_transform(x = dtm, n_iter = 1000, 
                          convergence_tol = 0.001, n_check_convergence = 25, 
                          #convergence_tol = 0.01, n_check_convergence = 25, 
                          progressbar = FALSE, verbose=FALSE)

#apply to training set
new_dtm = itoken(my_articles$Clean_Text[-sample], tolower, word_tokenizer) %>% 
  create_dtm(vectorizer, type = "dgTMatrix")
new_doc_topic_distr = lda_model$transform(new_dtm)
perpperplexity_score <- perplexity(new_dtm, topic_word_distribution = lda_model$topic_word_distribution, doc_topic_distribution = new_doc_topic_distr)
#how good is our model
#Try playin with n_topics, doc_topic_prior, topic_word_prior to see how to get better
perpperplexity_score
#Lets investigate our topics
lda_model$get_top_words(n = 7, topic_number = c(1:10), lambda = 1)
#Lambda setting highlight more topic specific but less probable words over all. Observe the difference
lda_model$get_top_words(n = 7, topic_number = c(1:10), lambda = 0.3)
#-----------------------------------------------------------------------------------
#Finding optimal number of topics and hyperparameters can be done with genetic algorithm that performs meta-heuristic search (= not guaranteed
# to find the best but relatively good). See for more detailshttps://cran.r-project.org/web/packages/DEoptim/index.html
#Evaluate function optimalLda at the end of this file. Then 



library(DEoptim)
#Search space needs to be defined topics are between 10-500 and hyberparameters are between 0 and 1
lower <- c(10, 0, 0)
higher <- c(500, 1, 0.3)

#here we start the search with 30 item population
#reduce / increase itermax and NP if too slow or fast
##The Deoptim package is really picky and may require R-studio restart to work correcly. If you see no print then it is not working
#NP should be 30 3 parameter ten times for each (3x10)
DEoptim(optimalLda, lower, higher, DEoptim.control(strategy = 2, itermax = 10, NP = 10, CR = 0.5, F = 0.8))

#lets apply the best input parameter and genera a model based on it. Then save it for further analysis (Analyze optimal model)--------------------

#297.9555 0.2518732 0.005613016

tokens = my_articles$Clean_Text %>%  tokenize_words (strip_numeric = TRUE)
it <- itoken(tokens, progressbar = FALSE)
v = create_vocabulary(it) %>% prune_vocabulary(term_count_min = 10, doc_proportion_max = 0.3)
vectorizer = vocab_vectorizer(v)
dtm = create_dtm(it, vectorizer, type = "dgTMatrix")
lda_model = LDA$new(n_topics = 298, doc_topic_prior = 0.2518732, topic_word_prior = 0.005613016)
doc_topic_distr = lda_model$fit_transform(x = dtm, n_iter = 1000, 
                                          convergence_tol = 0.001, n_check_convergence = 25, 
                                          #convergence_tol = 0.01, n_check_convergence = 25, 
                                          progressbar = FALSE, verbose=FALSE)
#Save model for further analysis
lda_file = getwd()
lda_file = paste(lda_file, "/", sep="")
lda_file = paste(lda_file, my_data_dir, sep="")
lda_file = paste(lda_file, "/", sep="")
lda_file_doc_topic_dist = paste(lda_file, "LDADocTopicDist.RData", sep="")
lda_file = paste(lda_file, "LDAModel.RData", sep="")


save(lda_model, file=lda_file)
save(doc_topic_distr, file=lda_file_doc_topic_dist)
#sanasto?
lda_model

#function------------------------------------------------------------
optimalLda <- function (x){
  sink("NUL")
  m_k <- round (x[1])
  m_alpha <- x[2]
  m_beta <- x[3]
  
  sample <- sample.int(n = nrow(my_articles), size = floor(.80*nrow(my_articles)), replace = F)
  
  tokens = my_articles$Clean_Text [sample] %>%  tokenize_words (strip_numeric = TRUE)
  it <- itoken(tokens, progressbar = FALSE)
  
  v = create_vocabulary(it) %>% 
    prune_vocabulary(term_count_min = 10, doc_proportion_max = 0.1)
  vectorizer = vocab_vectorizer(v)
  
  dtm = create_dtm(it, vectorizer, type = "dgTMatrix")
  
  #Find correct hyper parameters. 
  lda_model = LDA$new(n_topics = m_k, doc_topic_prior = m_alpha, topic_word_prior = m_beta)
  #lda_model = LDA$new(n_topics = 100, doc_topic_prior = 0.1, topic_word_prior = 0.1)

  doc_topic_distr = 
    lda_model$fit_transform(x = dtm, n_iter = 1000, 
                            #convergence_tol = 0.001, n_check_convergence = 25, 
                            convergence_tol = 0.01, n_check_convergence = 25, 
                            progressbar = FALSE, verbose=FALSE)
  
  #apply to training set
  new_dtm = itoken(my_articles$Clean_Text[-sample], tolower, word_tokenizer) %>% 
    create_dtm(vectorizer, type = "dgTMatrix")
  new_doc_topic_distr = lda_model$transform(new_dtm)
  sink()
  perp <- perplexity(new_dtm, topic_word_distribution = lda_model$topic_word_distribution, doc_topic_distribution = new_doc_topic_distr)
  m_k <- round (x[1])
  m_alpha <- x[2]
  m_beta <- x[3]
  print(paste("k:", m_k, "alpha:", m_alpha, "beta", m_beta, "perp:", perp))
  perp
}
