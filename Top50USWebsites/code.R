library(ggplot2)
library(lubridate)

data = read.csv("data.csv")
data$X = NULL
data$X.1 = NULL
data$avg_min_spent_per_day = minute(round(strptime(data$daily_time, format="%M:%S"), units="mins"))
data$daily_time = NULL

#################################################
# barplot of variables for each site
#################################################

# daily average pageview per visitor
ggplot(data=data, aes(x=site, y=daily_pageviews_per_visitor)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

# % traffic from search 
ggplot(data=data, aes(x=site, y=traffic_from_search)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

# total sites linking in
ggplot(data=data, aes(x=site, y=total_sites_linking_in)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

# avg time spent per day (visit?)
ggplot(data=data, aes(x=site, y=avg_min_spent_per_day)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

#################################################
# ggplots of vars against vars
#################################################

# daily pageview vs total sites linking in
ggplot(data=data, aes(x=total_sites_linking_in, y=daily_pageviews_per_visitor)) + geom_point()

# daily pageview vs daily time spent
ggplot(data=data, aes(x=avg_min_spent_per_day, y=daily_pageviews_per_visitor)) + geom_point()

# daily pageview vs % search traffic
ggplot(data=data, aes(x=traffic_from_search, y=daily_pageviews_per_visitor)) + geom_point()

#################################################
# convert vars to percentages 
#################################################
data_percent = data
data_percent$daily_pageviews_per_visitor = data$daily_pageviews_per_visitor / sum(data$daily_pageviews_per_visitor)
data_percent$avg_min_spent_per_day = data$avg_min_spent_per_day / sum(data$avg_min_spent_per_day)
temp = as.numeric(gsub("%", "", as.character(data_percent$traffic_from_search)))
data_percent$traffic_from_search = temp / sum(temp)
data_percent$total_sites_linking_in = data$total_sites_linking_in / sum(data$total_sites_linking_in)

# daily pageview vs total sites linking in
ggplot(data=data_percent, aes(x=total_sites_linking_in, y=daily_pageviews_per_visitor)) + geom_point()

# daily pageview vs daily time spent
ggplot(data=data_percent, aes(x=avg_min_spent_per_day, y=daily_pageviews_per_visitor)) + geom_point()

# daily pageview vs % search traffic
ggplot(data=data_percent, aes(x=traffic_from_search, y=daily_pageviews_per_visitor)) + geom_point()















