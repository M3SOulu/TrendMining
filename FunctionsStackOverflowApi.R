#install.packages("httr", dependencies = TRUE)
library(httr)

#install.packages("xml2", dependencies = TRUE)
library(xml2)

#install.packages("urltools", dependencies = TRUE)
library(urltools)

#install.packages("anytime", dependencies = TRUE)
library(anytime)

get_stackoverflow_data <- function (query_string){
api_key = '9raZ36FkYGFHDSNrW)gdsw(('
search_string = query_string
api_url = 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=activity&q='

api_url = paste(api_url, search_string, sep = '', collapse = '')
api_url = paste(api_url, '&site=stackoverflow&filter=!9YdnSIN18&key=',sep = '', collapse = '')
api_url = paste(api_url, api_key,sep = '', collapse = '')

api_url = URLencode(api_url)

sample2 <- GET(api_url)
data = content(sample2)

return_data_frame  = data.frame()
has_more_pages = data$has_more
page_number = 1

repeat{
  print('page number')
  print(page_number)
  
  for (outerloop in 1:(length(data$items))) {

     for(tagloop in 1: (length(data$items[[outerloop]]$tags)))
      {
        #print(data$items[[outerloop]]$tags[[tagloop]])
      }

     #print(data$items[[outerloop]]$owner$reputation)
    #print(data$items[[outerloop]]$owner$user_id)
    #print(data$items[[outerloop]]$owner$display_name)
  
    #print(data$items[[outerloop]]$view_count)
    #print(data$items[[outerloop]]$answer_count)
    #print(data$items[[outerloop]]$score)
    #print(data$items[[outerloop]]$last_activity_date)
  
    print(data$items[[outerloop]]$creation_date)
    #print(data$items[[outerloop]]$question_id)
    #print(data$items[[outerloop]]$title)
    #print(data$items[[outerloop]]$body)
  
      date <- anydate(data$items[[outerloop]]$creation_date)
      #print(date)
      
      temp <- data.frame(Title= ifelse(is.null(data$items[[outerloop]]$title),'',data$items[[outerloop]]$title), 
                       AuthorId= ifelse(is.null(data$items[[outerloop]]$owner$user_id),0,data$items[[outerloop]]$owner$user_id), 
                       Date= ifelse(is.null(date),0,as.character(date)),
                       AuthorName= ifelse(is.null(data$items[[outerloop]]$owner$display_name),'',data$items[[outerloop]]$owner$display_name),
                       Views = ifelse(is.null(data$items[[outerloop]]$view_count),0,data$items[[outerloop]]$view_count),
                       Abstract= ifelse(is.null(data$items[[outerloop]]$body),'',data$items[[outerloop]]$body),
                       stringsAsFactors=F)
      
      return_data_frame <- rbind(return_data_frame, temp)
    
  }    
  if(!has_more_pages)
    break
  else
    {
      page_number = page_number + 1
      api_url = 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=activity&q='
    
      api_url = paste(api_url, search_string, sep = '', collapse = '')
      api_url = paste(api_url, '&site=stackoverflow&filter=!9YdnSIN18&key=',sep = '', collapse = '')
      api_url = paste(api_url, api_key,sep = '', collapse = '')
      api_url = paste(api_url, '&page=',sep = '', collapse = '')
      api_url = paste(api_url, page_number,sep = '', collapse = '')
      api_url = URLencode(api_url)
      api_url
      sample2 <- GET(api_url)
      data = content(sample2)
      has_more_pages = data$has_more
    }
  }
return_data_frame
}