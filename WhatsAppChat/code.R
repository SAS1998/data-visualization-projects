setwd("~/Developer/data-visualization-projects/WhatsAppChat")

library(ggplot2)
library(tidytext)
library(zoo)
library(dplyr)

data = read.csv("data.csv")
data$text = as.character(data$text)
data$date = as.Date(data$date)

###############################################################################
# Distribution
###############################################################################

#--------------------------------------
# num sent per day
# all categories
# line
#--------------------------------------
# aggregate by day NUM SENT 
agg_sent_by_day = aggregate(x=data$count_sent, by=list(date=data$date, name=data$name), FUN="sum")
sean_dates = agg_sent_by_day[which(agg_sent_by_day$name == "Sean"), 1]
linda_dates = agg_sent_by_day[which(agg_sent_by_day$name == "Linda"), 1]

# fill in missing dates for Linda and Sean
for (date in linda_dates) {
  if (!(date %in% sean_dates)) {
    agg_sent_by_day = rbind(data.frame(date=as.Date(date, origin="1970-01-01"), name="Sean", x=0), agg_sent_by_day)
    sean_dates = c(as.Date(date, origin="1970-01-01"), sean_dates)
  }
}
for (date in sean_dates) {
  if (!(date %in% linda_dates)) {
    agg_sent_by_day = rbind(data.frame(date=as.Date(date, origin="1970-01-01"), name="Linda", x=0), agg_sent_by_day)
    linda_dates = c(as.Date(date, origin="1970-01-01"), linda_dates)
  }
}

agg_sent_by_day = agg_sent_by_day[order(agg_sent_by_day$date),]

linda_subset = agg_sent_by_day[which(agg_sent_by_day$name == "Linda"),]
linda_subset$cumsum = cumsum(linda_subset$x)
sean_subset = agg_sent_by_day[which(agg_sent_by_day$name == "Sean"),]
sean_subset$cumsum = cumsum(sean_subset$x)

# PLOT: line
ggplot() +
  geom_line(data=linda_subset, aes(x=date, y=x), color="pink", size=1.3) +
  geom_line(data=sean_subset, aes(x=date, y=x), color="cyan", size=1.3)

#--------------------------------------
# num words per day
# all categories
# line
#--------------------------------------

# aggregate by day NUM WORDS
agg_words_by_day = aggregate(data$count_words, by=list(data$date, data$name), FUN="sum")

#--------------------------------------
# num sent per hour
# all categories
# line
#--------------------------------------

# aggregate by time of day NUM SENT
agg_sent_by_time = aggregate(data$count_sent, by=list(hour=data$time, name=data$name), FUN="sum")

# PLOT: line
ggplot() +
  geom_line(data=agg_sent_by_time, aes(x=hour, y=x, color=name), size=1.3)

# PLOT: heatmap of time of day

###############################################################################
# Sentiment Analysis
###############################################################################

afinn = get_sentiments("afinn")
bing = get_sentiments("bing")
nrc = get_sentiments("nrc")

#--------------------------------------
# explore nrc rating
#--------------------------------------

# filter out only messages
message_only = data[which(data$category == "MESSAGE"),]
agg_day_text = aggregate(message_only$text, by=list(date=message_only$date, name=message_only$name), FUN=paste)

sentiments = data.frame()
for (i in 1:length(agg_day_text$x)) {
  print(i)
  message_list = as.vector(unlist(agg_day_text$x[i]))
  text_df = data_frame(line=1:length(message_list), text=message_list)
  sentiment_count = text_df %>%
                      unnest_tokens(word, text) %>%
                      inner_join(nrc) %>% 
                      count(sentiment)
  
  date = agg_day_text$date[i]
  name = as.character(agg_day_text$name)[i]
  partial = data.frame(date=rep(date,length(sentiment_count$sentiment)), name=rep(name,length(sentiment_count$sentiment)), sentiment=sentiment_count$sentiment, n=sentiment_count$n)
  sentiments = rbind(sentiments, partial)
}




















