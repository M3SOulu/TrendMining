library(rscopus)

get_scopus_papers_per_year = function (search_string, domain="software testing", years=(2000:2017)){
  
  papers_per_year = 0 
  print(search_string)
  
  for (year in years) {
    query_string = paste (search_string, "AND ALL(",domain,") AND YEAR (",year, ")")
    resp = generic_elsevier_api(query=query_string, type="search", search_type="scopus", verbose=FALSE)
    if (resp$get_statement$status_code != 200) {
      stop(paste(resp))
    }
    papers_per_year = append (papers_per_year, as.numeric(resp$content$`search-results`$`opensearch:totalResults`))
    print (year)
  } 
  papers_per_year
}

#For example
#query_string = "TITLE-ABS-KEY(\"Continuous Integration\"
  #query_string = paste(query_string, "AND ALL('software testing') AND YEAR (",year, ")")
  #query_string = paste(query_string, "AND ALL('software testing')")
#query_string = "TITLE-ABS-KEY(\"Continuous Integration\" AND ALL('software testing')"

get_scopus_papers = function (query_string){
  
  first_round = TRUE
  found_items_num = 1
  start_item = 0
  items_per_query = 25
  max_items = 20000
  return_data_frame = data.frame()
  
  while(found_items_num > 0){
    #http://api.elsevier.com/documentation/search/SCOPUSSearchViews.htm
    #https://api.elsevier.com/documentation/SCOPUSSearchAPI.wadl
    resp = generic_elsevier_api(query=query_string, type="search", search_type="scopus", start=start_item, view="COMPLETE")
    
    if (resp$get_statement$status_code != 200) {
      stop(paste(resp))
    }
    
    if (first_round){
      found_items_num = as.numeric(
        resp$content$`search-results`$`opensearch:totalResults`)
      first_round=FALSE
      return_data_frame = data.frame(Id = character(found_items_num),
                                      Title = character(found_items_num), 
                                      Creator = character(found_items_num), 
                                      PubName = character(found_items_num), 
                                      Date = character(found_items_num),
                                      Abstract = character(found_items_num),
                                      AuthorKeyWords = character(found_items_num),
                                      Cites = numeric(found_items_num),
                                      stringsAsFactors=F)
    }
    #could be moved inside else
    if (found_items_num > max_items) {
      stop('WARNING: too many result')
      #found_items_num = max_items
    }
    
    if (found_items_num == 0) {
      stop("Found nothing")
    } 
    else
    {
      #resp$content$`search-results`$entry[[25]]$`dc:identifier`
      entries = resp$content$`search-results`$entry
      i=1;
      for(entry in entries){
        if (is.character(entry$`dc:identifier`)){return_data_frame$Id[start_item+i] <- entry$`dc:identifier`}
        if (is.character(entry$`dc:title`)){return_data_frame$Title[start_item+i] <- entry$`dc:title`}
        if (is.character(entry$`dc:creator`)){return_data_frame$Creator[start_item+i] <- entry$`dc:creator`}
        if (is.character(entry$`prism:publicationName`)){return_data_frame$PubName[start_item+i] <- entry$`prism:publicationName`}
        if (is.character(entry$`prism:coverDate`)){return_data_frame$Date[start_item+i] <- entry$`prism:coverDate`}
        if (is.character(entry$`dc:description`)){return_data_frame$Abstract[start_item+i] <- entry$`dc:description`}
        if (is.character(entry$`authkeywords`)){return_data_frame$AuthorKeyWords[start_item+i] <- entry$`authkeywords`}
        if (is.character(entry$`citedby-count`)){return_data_frame$Cites[start_item+i] <- as.numeric(entry$`citedby-count`)}
        i = i +1
      }
    }
    found_items_num = found_items_num - items_per_query
    start_item = start_item + items_per_query
    print (paste("start",start_item," found ",found_items_num))
  }
  return_data_frame
}