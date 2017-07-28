setwd("~/Developer/data-visualization-projects/MoviesXray")

library(ggplot2)

files = list.files(path = "data/")

for (i in 1:length(files)) {
  filename = files[i]
  movie_name = unlist(strsplit(filename, "-data.csv")[1])
  movie_name_title
  
  data = read.csv(paste0("data/", files[i]))
  
  # clean up data
  data$start = data$start/1000
  data$end = data$end/1000
  charactersOrder = as.character(unique(data[with(data, order(start)), 2]))
  data$character = factor(data$character, levels=rev(charactersOrder))
  
  max_time = max(data$end)
  
  # plot
  g1 = ggplot(data=data) +
    geom_segment(aes(x=character, xend=character, y=start, yend=end, colour=character, size=5)) +
    scale_y_discrete(limits=seq(0,max_time,600), labels=seq(0,max_time,600)) + 
    labs(
      title=paste0(movie_name_title, " Characters On-Screen Time"),
      y="Time (s)", 
      x="Characters (in order of appearance)"
    ) +
    theme(legend.position="none") +
    coord_flip()
  g1
  ggsave(paste0("plots/", movie_name, "-characters.png"), height=5, width=7, dpi=500)
}

############################################################

ggplot(data=timeCharacterCount) + 
  geom_histogram(aes(timeCharacterCount), bins=max(timeCharacterCount)) +
  scale_y_discrete(limits=seq(0,7766,600), labels=seq(0,7766,600))


# create dataframe for on-screen characters / second
start = data$start
end = data$end
# timeCharacterCount = rep(0, max(end))
timeCharacterCount = c()

for (i in 1:length(start)) {
  for (s in start[i]:end[i]) {
    # timeCharacterCount[s] = timeCharacterCount[s] + 1
    timeCharacterCount = c(timeCharacterCount, s)
  }
}

# timeCharacterCount = data.frame(sec=seq(1,max(end),1), num=timeCharacterCount)
timeCharacterCount = data.frame(timeCharacterCount)






