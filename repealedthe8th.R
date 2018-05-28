# Sentiment Analysis of #repealed8th - twitter hashtag related to abortion legalization in Ireland

library(devtools)
install_github("geoffjentry/twitteR")

library(twitteR)

api_key <- "xxx"
api_secret <- "xxx"
access_token <-"xxx"
access_tokens_secret <-"xxx"

setup_twitter_oauth(api_key, api_secret, access_token, access_tokens_secret)

keywords <- c("#repealedthe8th", "#repealThe8th")
tweets <-searchTwitter(keywords[1], n =1500)
tweets <-rbind(tweets, searchTwitter(keywords[2], n=1500))
tweetsdf <- do.call("rbind", lapply(tweets, as.data.frame))
head(tweetsdf$id)


setwd("/home/kenelly/workspaces/r/rsentimentanalysis/")
write.csv(tweetsdf, file = "tweetsrepeal.csv")

