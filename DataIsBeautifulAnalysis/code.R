library(ggplot2)

Sys.setenv(TZ="America/Chicago")
Sys.setlocale("LC_TIME", "C")

setwd("~/Developer/data-visualization-projects/DataIsBeautifulAnalysis")

data = read.csv('dataisbeautiful.csv')

data$datetime = as.POSIXct(as.numeric(data$created_utc), tz="America/Chicago", origin="1970-01-01")
data$hour = format(data$datetime, "%H")
data$weekday = factor(format(data$datetime, "%a"), levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))

data_aggregate = aggregate(data$score, list(data$weekday, data$hour), mean)

ggplot(data_aggregate, aes(Group.1, Group.2, fill = x)) + 
  geom_tile(colour = "white") + 
  scale_fill_gradient(low="white", high="green") +
  labs(x="Day of Week",
       y="Hour",
       title = "Reddit Submission Scores Heatmap", 
       subtitle="", 
       fill="Average Score")
