library(ggplot2)

Sys.setenv(TZ="America/Chicago")
Sys.setlocale("LC_TIME", "C")

setwd("~/Developer/data-visualization-projects/DataIsBeautifulAnalysis")

generate_plot = function(subreddit, pages) {
  data = read.csv(paste(subreddit, '.csv', sep=''))
  
  data$datetime = as.POSIXct(as.numeric(data$created_utc), tz="America/Chicago", origin="1970-01-01")
  data$hour = format(data$datetime, "%H")
  data$weekday = factor(format(data$datetime, "%a"), levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))
  
  data_aggregate = aggregate(data$score, list(data$weekday, data$hour), mean)
  
  ggplot(data_aggregate, aes(Group.1, Group.2, fill = x)) + 
    geom_tile(colour = "white") + 
    scale_fill_gradient(low="white", high="blue") +
    labs(x="Day of Week",
         y="Hour",
         title = paste("Reddit Submission Scores ", '(/r/', subreddit, ')', sep=''), 
         subtitle=paste("Data for the past ", pages, " days. Times converted to CDT", sep=''), 
         fill="Average Score")
}

generate_plot('dataisbeautiful', 100)
generate_plot('cscareerquestions', 100)
generate_plot('pokemon', 100)


