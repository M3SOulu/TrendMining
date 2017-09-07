#install.packages("ggplot2", dependencies = TRUE)
#install.packages("tm", dependencies = TRUE)
#install.packages("magrittr", dependencies = TRUE)
#install.packages("SnowballC", dependencies = TRUE)
library(ggplot2)
library(tm)
library(magrittr)
library(SnowballC)

#Creates a pdf-file
#May take a long time
#May not be human readable (for large files)
my_DtmAndDendogramClusterFile = function(my_file) {
	
  print(paste("Dendogram Cluster, my_file: ", my_file))
  
  my_temp_file = paste(my_data_dir, "/", sep="")
  my_temp_file = paste(my_temp_file, my_file, sep="")
  load(my_temp_file)

	#-----Removing unnecessary words----------------
	my_articles$Abstract_clean = removeWords(my_articles$Abstract_clean, c("software", "testing"))
	my_articles$Title = removeWords(my_articles$Title, c("software", "testing"))

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
	                 "searched","seems","set",
	                 "several","similar","since","small","software",
	                 "softwaredevelopment","step","story","student","students","study","studies",
	                 "system","systems","team","teams","text","tell","type",
	                 "unable","update","updated","updating","usa","use","used","user","users","using",
	                 "versus","visit","vitamin","want","within","without","write","writing",
	                 "year","years","one","two","three","four","five","six","seven","eight")
	
	#A good is to remove more words that we do not care about 
	my_articles$Abstract_clean = removeWords(my_articles$Abstract_clean, my_stopwords)
	#-----/Removing unnecessary words----------------

	# Create corpus by appending title and abstract to character string
	corpus = Corpus(VectorSource(paste(my_articles$Title, my_articles$Abstract_clean)))
                 
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

	#Convert to martix, compute colSums (total word counds), take only words with more thatn 50 occurecents, 
	#and convert to dataframe with two columns: terms and frequencies 
	df <- dtm %>% as.matrix %>% colSums %>% subset (. >= 50) %>% data.frame(term=names(.), freq=.)
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
	my_pdf_file = my_temp_file
	my_pdf_file = gsub("data/my", "data/pdf", my_pdf_file)
	my_pdf_file = gsub(".RData", ".pdf", my_pdf_file)
	
	print(paste("Printing the Cluster Dendogram file:", my_pdf_file))
	print("Finished Dendogram Cluster")
	
	pdf(my_pdf_file, width=40, height=15)
	par(cex=0.7, mar=c(5, 8, 4, 1))
	plot(h, labels = my_articles$Title, sub = "")
	dev.off()
}