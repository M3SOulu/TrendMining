# TrendMining
Scripts


1) Input - Pull out data from different sources
- Current support 
	Scopus (GetScopusData.R and FunctionsScopusApi.R)
	StackOverflow (GetStackOverflowData.R and FunctionsStackOverflowApi.R)
	Twitter (GetTwitterData.R and FunctionsTwitterApi.R)	

When using function interfaces to fetch the data (get_ScopusData, get_stackOverFlowData & get_MyTwitterData)
- Have a sub-directory "data"
- For Twitter data - download GetOldTweets-java project & set the variable "getoldtweets_path" in GetTwitterData.R to point to that folder (getoldtweets_path = "path-to-folder-GetOldTweets-java")


2) Output
Word clouds (Wordcloud.R)
Text mining basics (DtmAndDendogramClustering.R)
Document Clustering (DtmAndDendogramClustering.R)
Dissimilarity Clouds (ComparisonCloud.R)
LDA clustering for exploring (InteractiveLdaCluster.R)
LDA clustering for trend mining (BuildOptimalLdaModel.R + AnalyzeOptimalLdaModel.R)

Maybe later: Trends Over Years (requires input and normalization)
