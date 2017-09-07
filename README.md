# TrendMining
Scripts

1) Edit Initialize.R 
- Set-up environment variables => work directory, path to GetOldTweets-java-master folder, StackOverflow API key & Scopus API key
- Run the initialize script and you should see your data and functions as environment variables
- source("Initialize.R")


2) Input - Pull out data from different sources
Current support
- Scopus: GetScopusData.R and FunctionsScopusApi.R
- StackOverflow: GetStackOverflowData.R and FunctionsStackOverflowApi.R
- Twitter: GetTwitterData.R and FunctionsTwitterApi.R

For example...
- get_ScopusData("jira", "jira") => file: data/my_scopus_jira_data.RData
- get_stackOverFlowData("exploratory testing", "et") => file: data/my_STO_et_data.RData
- get_TwitterData("#pairwisetesting","pwt") => file: data/my_twitter_pwt_data.RData


3) Output
Word clouds (Wordcloud.R)
Text mining basics (DtmAndDendogramClustering.R)
Document Clustering (DtmAndDendogramClustering.R)
Dissimilarity Clouds (ComparisonCloud.R)
LDA clustering for exploring (InteractiveLdaCluster.R)
LDA clustering for trend mining (BuildOptimalLdaModel.R + AnalyzeOptimalLdaModel.R)

Maybe later: Trends Over Years (requires input and normalization)
