library(ggplot2)
library(RColorBrewer)
setwd("~/Developer/data-visualization-projects/HarryPotterCharacterScreentime")

movie_order = as.factor(c("Philosopher's/Sorcerer's Stone", 
                          "Chamber of Secrets", 
                          "Prisoner of Azkaban", 
                          "Goblet of Fire", 
                          "Order of the Phoenix",
                          "Half-Blood Prince",
                          "Deathly Hallows, Part I",
                          "Deathly Hallows, Part II"))

movie_minutes = c(152, 161, 142, 157, 138, 153, 146, 130)

data = read.csv("screentime.csv")
k = 3

agg_time = aggregate(data$time, by=list(data$character), FUN=sum)
character_order = agg_time[order(agg_time$x), ]$Group.1
character_order = character_order[(97-k+1):97] # only top 50 characters

data$character = factor(data$character, levels=character_order)
data$movie = factor(data$movie, levels=movie_order)

data = data[complete.cases(data), ]
# data$time_percent = (data$time/movie_minutes[data$movie])*100

mean(data$time)
median(data$time)

set1_cols = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF")
set2_cols = c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3")
dark_cols = c("#1B9E77", "#D95F02", "#E7298A", "#66A61E", "#E6AB02", "#A6761D", "#666666", "#666666")
accent_cols = c("#7FC97F", "#BEAED4", "#FDC086", "#FFFF99", "#386CB0", "#F0027F", "#BF5B17", "#666666")

plot = ggplot(data=data, aes(x=character, y=time, fill=movie)) +
  geom_col(position = position_stack(reverse = TRUE)) + 
  ggtitle("Screen Time of Harry Potter Characters") +
  xlab("Character") + ylab("Screen Time (minutes)") +
  guides(colour = guide_legend(reverse=TRUE)) + 
  scale_y_continuous(breaks=seq(0,500,by=100), labels=seq(0,500,by=100)) +
  scale_fill_manual(name="Movie", values=set1_cols) +
  theme(
    panel.grid.minor.x=element_blank(),
    aspect.ratio=1,
    text=element_text(size=12), 
    plot.title=element_text(size=18),
    legend.text=element_text(size=12),
    legend.key.size = unit(1, "lines"),
    axis.text=element_text(size=12)
  ) +
  coord_flip()
plot

ggsave(paste("plot_", k, "_set1.png", sep=""), dpi=500)


display.brewer.all()
brewer.pal(8, "Set1")


ggplot(data, aes(x=movie, y=time)) +   
  geom_bar(aes(fill=character), position = "dodge", stat="identity")


