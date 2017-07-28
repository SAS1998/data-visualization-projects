setwd("~/Developer/data-visualization-projects/MoviesXray")

library(ggplot2)
library(ggExtra)

# clean up data
data = read.csv("xray.csv")
data$start = data$start/1000
data$end = data$end/1000
charactersOrder = as.character(unique(data[with(data, order(start)), 2]))
data$character = factor(data$character, levels=rev(charactersOrder))

# plots
g1 = ggplot(data=data) +
  geom_segment(aes(x=character, xend=character, y=start, yend=end, colour=character, size=5)) +
  scale_y_discrete(limits=seq(0,7766,600), labels=seq(0,7766,600)) + 
  labs(
    title="The Matrix Characters On-Screen Time",
    y="Time (s)", 
    x="Characters (in order of appearance)"
  ) +
  theme(legend.position="none") +
  coord_flip()
g1
ggsave("plots/thematrixcharacters.png",height=5,width=7,dpi=500)


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






