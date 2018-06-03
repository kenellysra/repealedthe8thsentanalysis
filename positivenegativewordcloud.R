#positive and negative wordclouds

setwd("/home/kenelly/workspaces/r/rsentimentanalysis/")

tweetsoutputdf <- read.csv("tweetsrepealsentanalysis.csv", header = T, na.strings = c(""))

positivetweets <- tweetsoutputdf[tweetsoutputdf$polarity == "positive",]
negativetweets <- tweetsoutputdf[tweetsoutputdf$polarity == "negative",]
str(negativetweets)

#wordcloud for positive tweets
positiveCorpus <- Corpus((VectorSource(positivetweets$text)))
dtm <- TermDocumentMatrix(positiveCorpus)
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing = TRUE)
dt <- data.frame(words= names(v), freq=v)


#wordcloud
wordcloud(words = dt$words, freq = dt$freq, min.freq = 1 ,max.words= 180, random.order = FALSE, scale=c(2.8,.7),
          rot.per = 0.35, colors = brewer.pal(8, "Dark2"))


#wordcloud for negative tweets
negativeCorpus <- Corpus((VectorSource(negativetweets$text)))
dtm <- TermDocumentMatrix(positiveCorpus)
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing = TRUE)
dt <- data.frame(words= names(v), freq=v)


#wordcloud
wordcloud(words = dt$words, freq = dt$freq, min.freq = 1 ,max.words= 180, random.order = FALSE, scale=c(2.8,.7),
          rot.per = 0.35, colors = brewer.pal(8, "Dark2"))
