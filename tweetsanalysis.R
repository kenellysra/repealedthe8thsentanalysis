# Cleaning and transformation on tweets

setwd("/home/kenelly/workspaces/r/rsentimentanalysis/")

tweetsdf <- read.csv("tweetsrepeal.csv", header = T, na.strings = c(""))
str(tweetsdf)

tweetsdf$language <- as.factor(tweetsdf$language)
tweetsdf$location <- as.factor(tweetsdf$location)
tweetsdf$screenName <- as.character(tweetsdf$screenName)
counts = table(tweetsdf$screenName)
head(counts)
barplot(counts)

#parse
tweetsdf$text = sapply(tweetsdf$text, function(row) iconv(row, to = 'UTF-8'))

library(stringr)
head(tweetsdf$text)

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
wordcloud(words = dt$words, freq = dt$freq, min.freq = 2 ,max.words= 150, random.order = FALSE,scale=c(3,.8),
          rot.per = 0.25, colors = brewer.pal(8, "Dark2"))
