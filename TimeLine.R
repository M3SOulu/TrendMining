my_file <- "my_Scopus_TSE_articles_clean_data.RData"

#draw_myWordCloud = function(my_file){

my_temp_file = paste(my_data_dir, "/", sep="")
my_temp_file = paste(my_temp_file, my_file, sep="")
load(my_temp_file)
#Data from IEEE Transaction on Software Engineering 
#(Top Software Engineering scientific journal)

#----------------------------------------------------------------------
#
#How many documents per year / month / day

#Take years from date 
#(Hint lot of online help for various conversions availabe )
years <- lubridate::year(my_articles$Date)
class(years)
class(my_articles)
class(my_articles$Date)

#Make a table
yearly <- table (years)
class(yearly)
plot (yearly, type ="l", xaxt="n", xlab="", ylab="")
axis(1, at = seq(1975, 2018, by = 1), las=2)

#use pure date
date <- table (my_articles$Date)
plot (date, type ="l", xaxt="n", xlab="", ylab="")
#What is the problem?
#------------
#Early years utilized only one date

#-----------------------------------------------------------------------
#Distribution of citations. Same techniques work for upvotes and retweets
#Typically scientific articles show box-plots
#Remove articles with no date 
my_articles2 <- my_articles[which(!is.na(my_articles$Date)),]

boxplot(my_articles$Cites)
#Summary offers more usefull view
summary(my_articles$Cites)


#What does the result mean? 
#Compare to fuel consumptio
class(mtcars)
#Convert mpg to liters per 100km
mtcars$l100km <- (100*3.785411784)/(1.609344*mtcars$mpg)
boxplot(l100km~cyl,data=mtcars, main="Car Milage Data",
        xlab="Number of Cylinders", ylab="liters per 100km") 


library(vioplot)
#Same info as in box plot but more illustrative
vioplot(my_articles$Cites)

my_articles2 <- my_articles[which(!is.na(my_articles$Date)),]
#Split from middle. Are old articles more cited than new?

boxplot(my_articles2$Cites[my_articles2$Date > median(my_articles2$Date)],
        my_articles2$Cites[my_articles2$Date <= median(my_articles2$Date)], names=c("newer", "older"))


vioplot(my_articles2$Cites[my_articles2$Date > median(my_articles2$Date)],
        my_articles2$Cites[my_articles2$Date <= median(my_articles2$Date)], names=c("newer", "older"))
#na.omit and na.rm needed to remove missing data 
#R does not remove them automatically
#and gives errors
#Figure is not very illustrative. Lets look at the number
mean(my_articles2$Cites[my_articles2$Date > median(my_articles2$Date)])
mean(my_articles2$Cites[my_articles2$Date <= median(my_articles2$Date)])
median(my_articles2$Cites[my_articles2$Date > median(my_articles2$Date)])
median(my_articles2$Cites[my_articles2$Date <= median(my_articles2$Date)])


#List top 5 articles for further analysis. 
#Qualitative analysis 
#(=read abstracts and figure out what is the paper about) 
#Notice the minus sign descending order
head(my_articles$Cites[order(-my_articles$Cites)], n=5)
head(my_articles$Title[order(-my_articles$Cites)], n=5)

#This is optional just for kick analysis. Feel free to added to your report if you like. 
#We can test more more things. Recently it was claimed that in econometrics that shorter articles get more citations. Lets see
#https://www.sciencedirect.com/science/article/pii/S0167268118300143
#We change the splitting variable
median (nchar(my_articles2$Title))

boxplot(my_articles2$Cites[nchar(my_articles2$Title) > median (nchar(my_articles2$Title))],
        my_articles2$Cites[nchar(my_articles2$Title) <= median (nchar(my_articles2$Title))], names=c("longer", "shorter"), main="IEEE Transaction on Software Engineering")

wilcox.test(my_articles2$Cites[nchar(my_articles2$Title) > median (nchar(my_articles2$Title))],
       my_articles2$Cites[nchar(my_articles2$Title) <= median (nchar(my_articles2$Title))])
summary(my_articles2$Cites[nchar(my_articles2$Title) > median (nchar(my_articles2$Title))])
summary(my_articles2$Cites[nchar(my_articles2$Title) <= median (nchar(my_articles2$Title))])

#Lets split four ways

q1_t <- my_articles$Cites[nchar(my_articles2$Title) <= quantile(nchar(my_articles2$Title), probs = 0.25)]
q2_t <- my_articles$Cites[nchar(my_articles2$Title)> quantile(nchar(my_articles2$Title), probs = 0.25) &
                            nchar(my_articles2$Title) <= quantile(nchar(my_articles2$Title), probs = 0.5)]
q3_t <- my_articles$Cites[nchar(my_articles2$Title) > quantile(nchar(my_articles2$Title), probs = 0.5) &
                            nchar(my_articles2$Title) <= quantile(nchar(my_articles2$Title), probs = 0.75)]
q4_t <- my_articles$Cites[nchar(my_articles2$Title) > quantile(nchar(my_articles2$Title), probs = 0.75)]

boxplot(q1_t,q2_t, q3_t, q4_t, names=c("shorter", "short", "long", "longer"), main="Title Length(x) & Citations(y)\nIEEE Transaction on Software Engineering")
summary(q1_t)
summary(q2_t)
summary(q3_t)
summary(q4_t)

#Lets try log scale. We need to add +1 since log(0) is undefined and log(1) is zero
boxplot(q1_t+1,q2_t+1, q3_t+1, q4_t+1,log="y", names=c("shorter", "short", "long", "longer"), main="Title length(x) & Citations(y)\nIEEE Transaction on Software Engineering\n")

