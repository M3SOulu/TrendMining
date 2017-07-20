# devtool required for manual install
# rpython package for windows not available on cran download
install.packages("devtools")
library(devtools)

# Download zip file and uncompress, detailed instructions available in the text file
#Add the path for rpyhton folder here
install("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/rPython")
library(rPython)

# Example code to test rpython 
python.call( "len", 1:3 )
a <- 1:4
b <- 5:8
python.exec( "import got" )
python.call( "concat", a, b)
python.assign( "a",  "hola hola" )
python.method.call( "a", "split", " " )

#twitter data extraction code
system("python --version") #it should be 2.7
system('python G:/GetOldTweets-python-master/Exporter.py --querysearch "Robot Operating System" --maxtweets 3 --output "G:/GetOldTweets-python-master/output_got.csv"')
data <- read.csv("G:/GetOldTweets-python-master/output_got.csv", sep=";", header=T)

