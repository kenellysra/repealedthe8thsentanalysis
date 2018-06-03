# Cleaning and transformation on tweets

setwd("/home/kenelly/workspaces/r/rsentimentanalysis/")

tweetsdf <- read.csv("tweetsrepeal.csv", header = T, na.strings = c(""))

#transformations to factor
tweetsdf$language <- as.factor(tweetsdf$language)
tweetsdf$location <- as.factor(tweetsdf$location)
tweetsdf$screenName <- as.character(tweetsdf$screenName)

#parse
tweetsdf$text = sapply(tweetsdf$text, function(row) iconv(row, to = 'UTF-8'))

library(stringr)

#Cleaning
tweetsdf$text <- gsub("@\\w+", " ",tweetsdf$text)
tweetsdf$text <- gsub("&amp", " ", tweetsdf$text)
tweetsdf$text <- gsub("amp", " ", tweetsdf$text)
tweetsdf$text <- gsub("RT", " ", tweetsdf$text)
tweetsdf$text <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ", tweetsdf$text)
tweetsdf$text <- str_replace_all(tweetsdf$text, "https://t.co/[a-z,A-Z,0-9]*"," ")
tweetsdf$text <- str_replace_all(tweetsdf$text, "http://t.co/[a-z,A-Z,0-9]*"," ")
tweetsdf$text <- gsub("[[:punct:]]", "", tweetsdf$text)
tweetsdf$text <- gsub("http\\w+", " ", tweetsdf$text)
tweetsdf$text <- gsub("[ \t]{2,}", " ", tweetsdf$text)
tweetsdf$text <- gsub("^\\s+|\\s+$", " ", tweetsdf$text)
tweetsdf$text <- str_replace_all(tweetsdf$text,"  "," ")


library(tm)
library(wordcloud)
library(NLP)
library(RColorBrewer)

#More cleaning using tm package
twitterCorpus <- Corpus((VectorSource(tweetsdf$text)))
twitterCorpus <- tm_map(twitterCorpus, content_transformer(tolower))
twitterCorpus <- tm_map(twitterCorpus, removeWords, stopwords("english"))
twitterCorpus <- tm_map(twitterCorpus, removeWords, c("youre", "retweet", "two", "one", "just", "still" ))
twitterCorpus <- tm_map(twitterCorpus, removePunctuation)
twitterCorpus <- tm_map(twitterCorpus, stripWhitespace)


dtm <- TermDocumentMatrix(twitterCorpus)
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing = TRUE)
dt <- data.frame(words= names(v), freq=v)
head(dt,n = 100)

#wordcloud
wordcloud(words = dt$words, freq = dt$freq, min.freq = 1 ,max.words= 180, random.order = FALSE, scale=c(2.8,.7),
          rot.per = 0.35, colors = brewer.pal(8, "Dark2"))

library(httr)
library(RCurl)

#Applying Aylien API to sentiment analysis
key <- "personalkey"
appID <- "personalID"

url <- "https://api.aylien.com/api/v1/sentiment"

headers <- add_headers('X-AYLIEN-TextAPI-Application-Key' = key,
                       'X-AYLIEN-TextAPI-Application-ID' = appID)

#to ensure we only have tweets in english
entweets <- tweetsdf[tweetsdf$language == "en",]
str(entweets)
tweetsanalyse <-entweets$text

#creating a list to receive Aylien API output
responsesT <- list()

#get the sentiment analysis for each tweet
for (i in 1:length(tweetsanalyse)){
    r <- GET(url, headers, query = list(mode = "tweet", text = tweetsanalyse[i]))
    #code 200 means success
    if (r$status_code==200){
    responsesT[[i]] <- httr::content(r)
    }
    #Aylien API allows 120 requests per time, and then needs to wait 1 min to request again
    else{
    Sys.sleep(61)
    r <- GET(url, headers, query = list(mode = "tweet", text = tweetsanalyse[i]))
    responsesT[[i]] <- httr::content(r)
    }
}

#creating a dataframe to sentiment analysis output
sentanalysisdf <- data.frame(polarity=character(),
                 subjectivity=character(),
                 text=character(),
                 polarity_confidence=double(),
                 subjectivity_confidence=double()
)

df$polarity<-as.character(df$polarity)
df$subjectivity<-as.character(df$subjectivity)
df$text<-as.character(df$text)

#converting the list of list to data frame
for (i in 1:length(responsesT) ){
   
    sentanalysisdf[i, "polarity"]<-(unlist(responsesT[[i]][1]))
    sentanalysisdf[i, "subjectivity"] <-(unlist(responsesT[[i]][2]))
    sentanalysisdf[i, "text"] <-(unlist(responsesT[[i]][3]))
    sentanalysisdf[i, "polarity_confidence"] <-unlist(responsesT[[i]][4])
    sentanalysisdf[i, "subjectivity_confidence"] <-unlist(responsesT[[i]][5])
    
}

#some basic plots fromt he sentiment analysis output
barplot(table(df$polarity))
barplot(table(df$subjectivity))

#write sentiment analysis output on csv
write.csv(sentanalysisdf, file = "tweetsrepealsentanalysis.csv")
