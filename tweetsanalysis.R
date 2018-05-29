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
#remove @ from user names
trim <- function(x) sub('@', '', x)

library(stringr)

#create a field with who a message is to
tweetsdf$to <- sapply(tweetsdf$text, function(tweet) str_extract(tweet, "^(@[[:alnum:]_]*)"))
tweetsdf$to <- sapply(tweetsdf$to, function(name) trim(name))

#Create a fiedl with who has been Rt
tweetsdf$rt <- sapply(tweetsdf$text, function(tweet) trim(str_match(tweet, "^RT (@[[:alnum:]_]*)")[2]))


library(tm)
dtm <- TermDocumentMatrix(Corpus(VectorSource(tweetsdf$rt)))
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing = TRUE)
d <- data.frame(handle = names(v), freq=v)
head(d)

library(wordcloud)
twitterCorpus <-Corpus((VectorSource(tweetsdf$text)))
twitterCorpus <- tm_map(twitterCorpus, content_transformer(tolower))
twitterCorpus <-tm_map(twitterCorpus, removeNumbers)
twitterCorpus <- tm_map(twitterCorpus, removeWords, stopwords("english"))
twitterCorpus <- tm_map(twitterCorpus, removeWords, c("http", "https"))
twitterCorpus <- tm_map(twitterCorpus, removePunctuation)
twitterCorpus <- tm_map(twitterCorpus, stripWhitespace)

dtm <- TermDocumentMatrix(twitterCorpus)
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing = TRUE)
dt <- data.frame(words= names(v), freq=v)

wordcloud(words = dt$words, freq = dt$freq, min.freq = 1,max.words=500, random.order = FALSE,
          rot.per = 0.35, colors = brewer.pal(8, "Dark2"))
