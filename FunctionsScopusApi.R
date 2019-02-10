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

#For example (case 1, 1a, 1b or 2)
#query_string = "TITLE-ABS-KEY(\"Continuous Integration\")"
  #query_string = paste(query_string, "AND ALL('software testing') AND YEAR (",year, ")")
  #query_string = paste(query_string, "AND ALL('software testing')")
#query_string = "TITLE-ABS-KEY(\"Continuous Integration\") AND ALL('software testing')"
#TITLE-ABS-KEY(\"What types of defects are really discovered in code reviews\")

get_scopus_papers = function (query_string){
  
  first_round = TRUE
  found_items_num = 1
  start_item = 0
  items_per_query = 25
  max_items = 5000 #Implement cursor to fix this
  return_data_frame = data.frame()
  
  while(found_items_num > 0){
    #http://api.elsevier.com/documentation/search/SCOPUSSearchViews.htm
    #https://api.elsevier.com/documentation/SCOPUSSearchAPI.wadl
    #https://dev.elsevier.com/guides/ScopusSearchViews.htm
    #https://dev.elsevier.com/payloads/search/scopusSearchResp.json
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
                                      PageRange = character(found_items_num),
                                      PubType1 =  character(found_items_num),
                                      PubType2 = character(found_items_num),
                                      AuthorCount = numeric(found_items_num),
                                      Authors = character(found_items_num),
                                      AffiliationCount = numeric(found_items_num),
                                      Affiliations = character(found_items_num),
                                      AffiliationCountries= character(found_items_num),
                                      stringsAsFactors=F)
    }
    #could be moved inside else
    if (found_items_num > max_items) {
      stop(paste ('WARNING: too many results found',found_items_num, "when max is ", max_items))
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
        #Pick single fields 
        if (is.character(entry$`dc:identifier`)){return_data_frame$Id[start_item+i] <- entry$`dc:identifier`}
        if (is.character(entry$`dc:title`)){return_data_frame$Title[start_item+i] <- entry$`dc:title`}
        if (is.character(entry$`dc:creator`)){return_data_frame$Creator[start_item+i] <- entry$`dc:creator`}
        if (is.character(entry$`prism:publicationName`)){return_data_frame$PubName[start_item+i] <- entry$`prism:publicationName`}
        if (is.character(entry$`prism:coverDate`)){return_data_frame$Date[start_item+i] <- entry$`prism:coverDate`}
        if (is.character(entry$`dc:description`)){return_data_frame$Abstract[start_item+i] <- entry$`dc:description`}
        if (is.character(entry$`authkeywords`)){return_data_frame$AuthorKeyWords[start_item+i] <- entry$`authkeywords`}
        if (is.character(entry$`citedby-count`)){return_data_frame$Cites[start_item+i] <- as.numeric(entry$`citedby-count`)}
        if (is.character(entry$`prism:pageRange`)){return_data_frame$PageRange[start_item+i] <- entry$`prism:pageRange`}
        if (is.character(entry$`prism:aggregationType`)){return_data_frame$PubType1[start_item+i] <- entry$`prism:aggregationType`}
        if (is.character(entry$`subtypeDescription`)){return_data_frame$PubType2[start_item+i] <- entry$`subtypeDescription`}
        #Pick author field contains multiple fields. 
        if (is.vector(entry$`author`)){
          return_data_frame$AuthorCount[start_item+i] <- length(entry$`author`)
          str_authors <- NULL
          for (author in entry$`author`){
            if (is.character(author$`authname`)){str_authors <- paste (str_authors, author$`authname`, sep="|")}
          }
          if (is.character(str_authors)){return_data_frame$Authors[start_item+i] <- str_authors}
        }
        #Pick affiliation field contains multiple fields. 
        if (is.vector(entry$`affiliation`)){
          return_data_frame$AffiliationCount[start_item+i] <- length(entry$`affiliation`)
          str_affiliations <- NULL
          str_affi_country <- NULL
          for (affiliation in entry$`affiliation`){
            if (is.character(affiliation$`affilname`)){str_affiliations <- paste (str_affiliations, affiliation$`affilname`, sep="|")}
            if (is.character(affiliation$`affiliation-country`)){str_affi_country <- paste (str_affi_country, affiliation$`affiliation-country`, sep="|")}
          }
          if (is.character(str_affiliations)){return_data_frame$Affiliations[start_item+i] <- str_affiliations}
          if (is.character(str_affi_country)){return_data_frame$AffiliationCountries[start_item+i] <- str_affi_country}
        
          
        }
        i = i +1
      }
    }
    found_items_num = found_items_num - items_per_query
    start_item = start_item + items_per_query
    print (paste("fetched: ",start_item," remaining: ",found_items_num))
  }
  return_data_frame
}