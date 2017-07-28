rm(list = ls())
source("G:/EMSE-Masters/Oulu University - Finland/Internship/project/TrendMining/FunctionsStackOverflowApi.R")

query_string = "Robot Operating System"
my_articles <- get_stackoverflow_data (query_string)
