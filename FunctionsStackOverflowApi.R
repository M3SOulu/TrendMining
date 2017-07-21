install.packages("httr")
library(httr)

install.packages("xml2")
library(xml2)

install.packages("urltools")
library(urltools)

api_key = '9raZ36FkYGFHDSNrW)gdsw(('
search_string = 'Robot Operating System'
api_url = 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=activity&q='

api_url = paste(api_url, search_string, sep = '', collapse = '')
api_url = paste(api_url, '&site=stackoverflow&key=',sep = '', collapse = '')
api_url = paste(api_url, api_key,sep = '', collapse = '')

api_url = URLencode(api_url)

sample2 <- GET(api_url)
data = content(sample2)

