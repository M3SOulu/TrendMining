# TrendMining
Scripts

1. Edit and execute Initialize.R 
- Set-up environment variables => work directory, path to GetOldTweets-java-master folder, StackOverflow API key & Scopus API key
- Execute the file line by line (shortcut CTRL+Enter)

2. Input - Pull out data from different sources
   
   2.1. Open file GetScopusData.R and execute line by line fashion. Note in first run you need to uncomment early lines and install packages
Observe different variables in the environment. There is also commented out skeleton for turning this into function. After successful execution you  a data file. 
Please verify that the data file exists. 

   2.2 Do the same for GetStackOverflowData.R and GetTwitterData.R
Function files that fetch the data should not need editing (FunctionsScopusApi.R, FunctionsStackOverflowApi.R, FunctionsTwitterApi.R)
#TODO remove existing data files from root. Make data folder empty as well. Keep only "my_TSE_articles_dirty". 

3. Output

   3.1. Start with text mining basics. File DtmAndDendogramClustering.R contains functionality for document clustering.  Execute it line by line fashion for all of your data sets. 
  
   3.2. Investigate Word clouds (Wordcloud.R) and Dissimilarity Clouds (ComparisonCloud.R)
  
   3.3 Plot timelines (Timelines.R) to see how your data behaves over time. You may also do additional statistical plots and test, e.g. does question/title length affect upvotes/retweets/cites
  
   3.4. Search for optimal LDA model (BuildOptimalLdaModel.R)

   3.5. Investigate the trends in the optimal LDA model (AnalyzeOptimalLdaModel.R)

   3.6. Do interactive LDA cluster exploration. Note: you might want to have less clusters (smaller k) than what is mathematically optimal (InteractiveLdaCluster.R). As exploring hundreds of clusters in screen is not very easy. 
