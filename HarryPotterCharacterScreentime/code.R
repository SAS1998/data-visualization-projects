library(ggplot2)
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
k = 20

agg_time = aggregate(data$time, by=list(data$character), FUN=sum)
character_order = agg_time[order(agg_time$x), ]$Group.1
character_order = character_order[(97-k+1):97] # only top 50 characters

data$character = factor(data$character, levels=character_order)
data$movie = factor(data$movie, levels=movie_order)

data = data[complete.cases(data), ]
# data$time_percent = (data$time/movie_minutes[data$movie])*100

plot = ggplot(data=data, aes(x=character, y=time, fill=movie)) +
  geom_col(position = position_stack(reverse = TRUE)) + 
  ggtitle("Screen Time of Harry Potter Characters") +
  xlab("Character") + ylab("Screen Time (minutes)") +
  guides(colour = guide_legend(reverse=T)) + 
  scale_fill_discrete(name="Movie") +
  scale_y_continuous(breaks=seq(0,500,by=100), labels=seq(0,500,by=100)) +
  theme(
    panel.grid.minor.x=element_blank()
  ) +
  coord_flip()
plot

png(paste("plot_", k, ".png", sep=""), width=1000, height=1000, units="px") 



