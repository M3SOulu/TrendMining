#install.packages("ggplot2", dependencies = TRUE)
#install.packages("tm", dependencies = TRUE)
#install.packages("magrittr", dependencies = TRUE)
#install.packages("stopwords", dependencies = TRUE)
library("tm")
library("stopwords")
library("magrittr")
library("ggplot2")

#library(SnowballC)

#Creates a pdf-file
#May take a long time
#May not be human readable (for large files)
#EDIT this row
my_file <- "my_Scopus_TSE_articles_clean_data.RData"
#my_DtmAndDendogramClusterFile = function(my_file) {
	
  print(paste("Dendogram Cluster, my_file: ", my_file))
  
  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)

	#-----Removing unnecessary words----------------
  #various stopword lists can be used https://cran.r-project.org/web/packages/stopwords/stopwords.pdf
  #stopword list is also context specific. Here you can do manual removals
	#also automated methods tf/idf exist. EDIT
	my_stopwords = c(stopwords::stopwords(language = "en", source = "snowball"),"myStopword1", "myStopword2")
	
	#A good is to remove more words that we do not care about 
	Abstract_clean = removeWords(my_articles$Abstract_clean, my_stopwords)
	Title = removeWords(my_articles$Title, my_stopwords)
	#-----/Removing unnecessary words----------------

	# Create corpus by appending title and abstract to character string
	corpus = Corpus(VectorSource(paste(Title, Abstract_clean)))
                 
	dtm = DocumentTermMatrix(corpus, control=list(tolower=TRUE, stemming=FALSE, 
	  stopwords=FALSE, wordLengths=c(3, Inf), removeNumbers=TRUE, 
		removePunctuation=TRUE, bounds=list(global=c(5,Inf))))
	freq.terms = findFreqTerms(dtm, lowfreq=50)

	#Is "and" or "are" meaningfull words? Lets get rid of them by setting stopwords=TRUE
	dtm = DocumentTermMatrix(corpus, control=list(tolower=TRUE, stemming=FALSE, 
		stopwords=TRUE, wordLengths=c(3, Inf), removeNumbers=TRUE, 
		removePunctuation=TRUE, bounds=list(global=c(5,Inf))))

	#Stemming can also be used but the results might not be any better. 
	dtm_stem = DocumentTermMatrix(corpus, control=list(tolower=TRUE, stemming=TRUE, 
		stopwords = c (stopwords("english"), my_stopwords), 
		wordLengths=c(3, Inf), removeNumbers=TRUE, removePunctuation=TRUE,
        bounds=list(global=c(5,Inf)) ))
	freq.terms = findFreqTerms(dtm_stem, lowfreq=50)

	#Lets plot

	#Convert to martix, compute colSums (total word counds), take only words with more than 500 occurecents, 
	#and convert to dataframe with two columns: terms and frequencies 
	#if too many or too little words showup EDIT number 500 accordingly
	df <- dtm %>% as.matrix %>% colSums %>% subset (. >= 500) %>% data.frame(term=names(.), freq=.)
	#do you see any new stopwords that could be added to the list
	ggplot(df, aes(x = term, y = freq)) + geom_bar(stat = "identity") +xlab("Terms") + ylab("Count") + coord_flip()

	#--------------------Cluster and and Plot dendogram ---------------------------------------

	#We can subset to  200 papers if we have thounsands
	#dtm <- dtm[1:200,]

	# Compute distance matrix https://stat.ethz.ch/R-manual/R-devel/library/stats/html/dist.html
	#https://en.wikipedia.org/wiki/Distance_matrix
	#will be slow with thousands
	dist.mat <- dist(as.matrix(dtm))

	#Hirarcical clustering http://www.r-tutor.com/gpu-computing/clustering/hierarchical-cluster-analysis
	h <- hclust(dist.mat, method = "ward.D")

	#Finally,  we plot to file. R-studio plotting view is not large enough.
	my_pdf_file = my_temp_file
	my_pdf_file = gsub("data/my", "data/pdf", my_pdf_file)
	my_pdf_file = gsub(".RData", ".pdf", my_pdf_file)
	
	print(paste("Printing the Cluster Dendogram file:", my_pdf_file))
	print("Finished Dendogram Cluster")
	
	pdf(my_pdf_file, width=40, height=15)
	par(cex=0.7, mar=c(5, 8, 4, 1))
	#Remember we removed stopwords from title so the variable Title no longer make sense
	plot(h, labels = my_articles$Title, sub = "")
	#when using smaller set e.g. 200 articles only
	#plot(h, labels = my_articles$Title[1:200], sub = "")
	dev.off()
#}