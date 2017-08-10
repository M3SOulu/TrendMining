rm(list = ls())
setwd('C:/Users/mmantyla/Dropbox/Teach/2017_Trends')
setwd('D:/Dropbox/Teach/2017_Trends')

load ("my_articles_clean2.RData")

load(paste("LDAWinner", ".RData", sep=""))

#Create important arrays with descriptive names
library("tm")

Topics <- topics(LDAWinner, 1)
Terms <- terms(LDAWinner, 50)
#Titles <- AllData2[,2]

#Years = my_articles2[,3] 
#Cites = AllData2[, 11]
#Abstracts = AllData2[,16]
my_articles2$Years <- as.numeric(format(my_articles2$Date, "%Y"))

#**************************************************************************
# Change the number '49' to match the optimum topic number in your data set
#**************************************************************************

#List top ten terms for all topics
Terms[1:10,]
#Study one topic (23)
Terms[1:10,23]

#List all papers for topic 1
my_articles2$Title[Topics==23]
my_articles2$Abstract[Topics==82]
my_articles2$Abstract_clean[Topics==82]

Years <- my_articles2$Years
Titles <- my_articles2$Title
Abstracts <- my_articles2$Abstract
Cites <- my_articles2$Cites

#Search for hot topic
medians <- lapply(1:length(Terms[1,]), function(i) median(as.numeric(Years[Topics==i])))
#The "Hottest topic"
Terms[1:10,which.max(medians)]
Titles[Topics==which.max(medians)]
#The coldest topic
Terms[1:10,which.min(medians)]
Titles[Topics==which.min(medians)]
#abstract[Topics==which.min(medians)]

#Density plots 
#Test Plot all. Note: Unreadable for humans
#install.packages("ggplot2")
install.packages('rlang', dependencies = TRUE)
install.packages('Rcpp', dependencies = TRUE)
install.packages('ggplot2', dependencies = TRUE)
library(rlang)
library(Rcpp)
library(ggplot2)


qplot(as.numeric(Years), colour=factor(Topics),  geom="density")

# Test Plot hot vs. cold
qplot(as.numeric(subset(Years , Topics==which.max(medians) |  Topics==which.min(medians))), colour=factor(subset(Topics , Topics==which.max(medians) |  Topics==which.min(medians))),  geom="density")

#------top-cited topics----------------------------------------
Cite_sum <- lapply(1:length(Terms[1,]), function(i) sum(as.numeric(Cites[Topics==i])))
Topic_age <- lapply(1:length(Terms[1,]), function(i) sum(2015 - as.numeric(Years[Topics==i])))
Paper_counts <- lapply(1:length(Terms[1,]), function(i) length(Titles[Topics==i]))
Cite_per_year <- unlist(Cite_sum)/unlist(Topic_age)
Cite_per_paper <- unlist(Cite_sum)/unlist(Paper_counts)
Topic_sum <- lapply(1:length(Terms[1,]), function(i) length(Terms[Topics==i]))
Cite_per_topic <- unlist(Cite_sum)/unlist(Topic_sum)

Terms[1:10,which.max(Cite_per_year)] #most cited normalized for time 
Terms[1:10,which.max(Cite_sum)] #most cited total. Ignores paper count
Terms[1:10,which.max(Topic_age)] #Oldest
Terms[1:10,which.max(Paper_counts)] #Most popular



cited_per_year_per_topic <-  unlist(as.matrix(sort.int(Cite_per_year, index.return=TRUE, decreasing=TRUE))[2])
Topic_age_per_topic <- unlist(as.matrix(sort.int(unlist(Topic_age), index.return=TRUE, decreasing=TRUE))[2])
Paper_count_per_topic <- unlist(as.matrix(sort.int(unlist(Paper_counts), index.return=TRUE, decreasing=TRUE))[2])
Cite_per_paper_per_topic <- unlist(as.matrix(sort.int(Cite_per_paper, index.return=TRUE, decreasing=TRUE))[2])

Terms[1:10, cited_per_year_per_topic[1:5]]#Five top cited normalized for time 
Terms[1:10, Cite_per_paper_per_topic[1:5]]#Five top cited normalized per paper
Terms[1:10, Topic_age_per_topic[1:5]]#Five oldest
Terms[1:10, Paper_count_per_topic[1:5]] #5 most popular
unlist(Paper_counts)[Paper_count_per_topic[1:5]]# with paper counts


# Trend analysis hot and cold (From master's thesis--Page 54)-----------------------------------------
years <- levels(factor(unlist(Years)))
topics_n <- LDAWinner@k
theta <- posterior(LDAWinner)$topics

#Alternative settings-----------------------------------------
#Years = AllData2[,2] 

#**************************************************************
# Change the years IF some years are exlcuded from the analysis
# (In the example the years were limited to 2007 and after)
#**************************************************************
#year_limiter = (Years > 1978 & Years < 2015)
#year_limiter = (Years > 1980 & Years < 1990)
#year_limiter = Years >= 2007
#Years = Years[year_limiter]
#years <- levels(factor(unlist(Years)))

topics_n <- LDAWinner@k
theta <- posterior(LDAWinner)$topics
#theta = theta[year_limiter,]
getwd()
library("xtable")
source ("thesis_R/C13_trends-table-year-frequencies.R")

  theta_mean_by_year_by <- by(theta, (unlist(Years)), colMeans)
  theta_mean_by_year <- do.call("rbind",theta_mean_by_year_by)
  colnames(theta_mean_by_year) = paste(1:topics_n)
  theta_mean_by_year_ts <- ts(theta_mean_by_year, start = as.integer(years[1]))
  theta_mean_by_year_time <- time(theta_mean_by_year)
  
  theta_mean_lm <- apply(theta_mean_by_year, 2,function(x) lm(x ~ theta_mean_by_year_time))
  theta_mean_lm_coef <- lapply(theta_mean_lm, function(x) coef(summary(x)))
  theta_mean_lm_coef_sign <- sapply(theta_mean_lm_coef,'[',"theta_mean_by_year_time","Pr(>|t|)")
  theta_mean_lm_coef_slope <- sapply(theta_mean_lm_coef,'[',"theta_mean_by_year_time","Estimate")
  
  theta_mean_lm_coef_slope_pos <- theta_mean_lm_coef_slope[theta_mean_lm_coef_slope >= 0]
  theta_mean_lm_coef_slope_neg <- theta_mean_lm_coef_slope[theta_mean_lm_coef_slope < 0]
  
  
  p_level <- c(0.05, 0.01, 0.001, 0.0001) 
  significance_total <- sapply(p_level,function(x) (theta_mean_lm_coef_sign[theta_mean_lm_coef_sign < x]))
  significance_neg <- sapply(1:length(p_level), function(x) intersect(names(theta_mean_lm_coef_slope_neg),names(significance_total[[x]])))
  significance_pos <- sapply(1:length(p_level),function(x) intersect(names(theta_mean_lm_coef_slope_pos),names(significance_total[[x]])))
  
  source ("thesis_R/C14_trends-table-significance.R")

topics_hot <- as.numeric(names(sort(theta_mean_lm_coef_slope[ significance_pos[[1]]], decreasing=TRUE)))
topics_cold <- as.numeric(names(sort(theta_mean_lm_coef_slope[ significance_neg[[1]]], decreasing=FALSE)))

source ("thesis_R/C16_trends-fig-five-hot-and-cold.R")
source ("thesis_R/C16_trends-fig-five-hot-and-cold-Adjusted.R")
Terms[1:10,topics_hot [1:5]]
Terms[1:10,topics_cold [1:5]]

#Terms[1:10,topics_cold [5]]
Terms[1:10,topics_cold [1]]

#Titles[Topics==topics_hot[3]]
Titles[Topics==topics_hot[1]]
