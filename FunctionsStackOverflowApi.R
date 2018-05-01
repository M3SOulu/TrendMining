#install.packages("httr", dependencies = TRUE)
#install.packages("xml2", dependencies = TRUE)
#install.packages("urltools", dependencies = TRUE)
#install.packages("jsonlite", dependencies = TRUE)
#install.packages("anytime", dependencies = TRUE)
library(httr)
library(xml2)
library(urltools)
library(jsonlite)
library(anytime)

create_so_req_url <- function (filter_text)
{
  #Search for items matching the query string from StackOverflow
  api_url = 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=activity&q='
  api_url = paste(api_url, query_string, sep = '', collapse = '')
  api_url = paste(api_url, '&filter=', sep = '', collapse = '')
  api_url = paste(api_url, filter_text, sep = '', collapse = '')
  api_url = paste(api_url, '&site=stackoverflow',sep = '', collapse = '')
  api_url = paste(api_url, '&key=', sep = '', collapse = '')
  api_url = paste(api_url, so_api_key, sep = '', collapse = '')
  
}


get_stackoverflow_data = function (query_string){
  #get total
  api_url_total <- create_so_req_url("total")
  sample_total <- GET(URLencode(api_url_total))
  content_total <- content(sample_total)
  
  #get data
  api_url <- create_so_req_url("withbody")
  #Prepare the url and fetch the data
  api_url = URLencode(api_url)

  sample2 = GET(api_url)
  my_data = content(sample2)

  return_data_frame = data.frame()

  has_more_pages = my_data$has_more
  page_number = 1
  tag_number = 0

  #while (length(my_data$items) > 0) {
  repeat {
    
    print(paste("page number: ", page_number, " items: ", page_number*30, " out of ", content_total$total, sep = '', collapse = ''))

    for (outerloop in 1:(length(my_data$items))) {

      for (tagloop in 1: (length(my_data$items[[outerloop]]$tags)))
      {
        if (tag_number == 0)
        {
          tags = my_data$items[[outerloop]]$tags[[tagloop]]
          tag_number = 1
        }
        else
        {
          tags = paste(tags, my_data$items[[outerloop]]$tags[[tagloop]], sep = ';', collapse = '')
          tag_number = tag_number + 1
        }
      }
      date_cr = anydate(my_data$items[[outerloop]]$creation_date)
      date_la = anydate(my_data$items[[outerloop]]$last_activity_date)
    
      temp <- data.frame(
          AuthorId = ifelse(is.null(my_data$items[[outerloop]]$owner$user_id),0,my_data$items[[outerloop]]$owner$user_id),
          Q_id = ifelse(is.null(my_data$items[[outerloop]]$question_id), '', my_data$items[[outerloop]]$question_id),
          Title = ifelse(is.null(my_data$items[[outerloop]]$title),'',my_data$items[[outerloop]]$title),
          Abstract = ifelse(is.null(my_data$items[[outerloop]]$body),'',my_data$items[[outerloop]]$body),
          Views = ifelse(is.null(my_data$items[[outerloop]]$view_count),0,my_data$items[[outerloop]]$view_count),
          Answers = ifelse(is.null(my_data$items[[outerloop]]$answer_count),0,my_data$items[[outerloop]]$answer_count),
          Cites = ifelse(is.null(my_data$items[[outerloop]]$answer_count),0,my_data$items[[outerloop]]$answer_count),
          Tags_n = tag_number,
          Tags = ifelse(is.null(tags),'',tags),
          Date = ifelse(is.null(date_cr), 0, as.character(date_cr)),
          CR_Date = ifelse(is.null(date_cr), 0, as.character(date_cr)),
          LA_Date = ifelse(is.null(date_la), 0, as.character(date_la)),
          stringsAsFactors=F)

      tag_number = 0
      tags = NULL
      
      return_data_frame <- rbind(return_data_frame, temp)
    
    }    
    
    if (!has_more_pages)
      break
    else
    {
      page_number = page_number + 1

      api_url = 'https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=activity&q='
      api_url = paste(api_url, query_string, sep = '', collapse = '')
      api_url = paste(api_url, '&filter=', sep = '', collapse = '')
      api_url = paste(api_url, filter_text, sep = '', collapse = '')
      api_url = paste(api_url, '&site=stackoverflow',sep = '', collapse = '')
      api_url = paste(api_url, '&key=', sep = '', collapse = '')
      api_url = paste(api_url, so_api_key, sep = '', collapse = '')
      api_url = paste(api_url, '&page=', sep = '', collapse = '')
      api_url = paste(api_url, page_number, sep = '', collapse = '')
      
      api_url = URLencode(api_url)
      sample2 = GET(api_url)
      my_data = content(sample2)
      has_more_pages = my_data$has_more
    }
  }
  return_data_frame
}
