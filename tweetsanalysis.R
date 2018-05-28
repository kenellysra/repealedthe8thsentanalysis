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

tweetsdf$text = sapply(tweetsdf$text, function(row) iconv(row, to = 'UTF-8'))
trim <- function(x) sub('@', '', x)
