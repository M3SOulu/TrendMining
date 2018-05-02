#install.packages("text2vec", dependencies=TRUE)
#install.packages("tm", dependencies=TRUE)
#install.packages("magrittr", dependencies=TRUE)
#install.packages("LDAvis")
library(text2vec)
library(tm)
library(magrittr)
library(LDAvis)

#May take a while - wait patiently
my_file = "my_Scopus_TSE_articles_clean_data.RData"
#draw_my_IAMap = function(my_file) {
  
  print(paste("Interactive LDA Cluster, my_file: ", my_file))
  
  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)

  my_text <- paste (my_articles$Title, my_articles$Abstract_clean)

  #Here we use text2vec package as it contains very fast LDA clustering implementation
  #Note there is some overlap with between text2vec, tm, and topicmodels pacakges
  my_tokens = my_text %>% tolower %>% word_tokenizer
  
  it = itoken(my_tokens)
  
  my_stopwords = c(stopwords::stopwords(language = "en", source = "snowball"),"myStopword1", "myStopword2")
  
  
  #Remove stopwords
  my_vocab <- create_vocabulary(it, stopwords=my_stopwords)

  #Limit vocabulary to 40000 terms. 
  #Each word is only allowed to appear in 50% of the documents
  #vocab <- prune_vocabulary(vocab, max_number_of_terms=40000, doc_proportion_max=0.5)
  my_vocab <- prune_vocabulary(my_vocab,
                               term_count_min=10,
                               vocab_term_max=40000, 
                               doc_proportion_max=0.5)

  #Create DTM
  #dtm = create_dtm(it, vocab_vectorizer(vocab),'lda_c')
  vectorizer=vocab_vectorizer(my_vocab)
  dtm = create_dtm(it, vectorizer,'dgCMatrix')
  
  #LDA model with 20 topics to provide an overview
  #lda_model = LatentDirichletAllocation$new(n_topics=20, vocabulary=my_vocab)
  lda_model = LatentDirichletAllocation$new(n_topics=20)

  #We run 200 iterations
  doc_topic_distr = lda_model$fit_transform(dtm, n_iter=200, check_convergence_every_n=5)

  #Run LDAvis visualisation if needed (make sure LDAvis package installed)
  #Be patient this might take while before anything is plotted. See viewer tap on the right
  if (!all(lda_model$topic_word_distribution == 0)) {
    lda_model$plot()
  } else {
    print("No Data!")
  }
  
  print("Finished Interactive LDA Cluster")
#}