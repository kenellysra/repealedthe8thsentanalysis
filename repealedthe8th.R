# Sentiment Analysis of #repealed8th - twitter hashtag related to abortion legalization in Ireland

library(devtools)
install_github("geoffjentry/twitteR")

library(twitteR)

api_key <- "xxx"
api_secret <- "xxx"
access_token <-"xxx"
access_tokens_secret <-"xxx"

setup_twitter_oauth(api_key, api_secret, access_token, access_tokens_secret)

keywords <- c("#repealedthe8th")
tweets <-searchTwitter("#repealedthe8th", n = 1e4, lang = "en", since = '2018-05-26', 
                       until = '2018-05-28', retryOnRateLimit = 1e3)
tweetsdf <- twListToDF(tweets)
str(tweetsdf)
head(tweetsdf$text)


setwd("/home/kenelly/workspaces/r/rsentimentanalysis/")
write.csv(tweetsdf, file = "tweetsrepeal.csv")

