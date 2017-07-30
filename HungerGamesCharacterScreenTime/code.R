library(ggplot2)
library(RColorBrewer)
setwd("~/Developer/data-visualization-projects/HungerGamesCharacterScreenTime")

movie_order = as.factor(c("THE HUNGER GAMES", 
                          "CATCHING FIRE",
                          "MOCKINGJAY PART 1", 
                          "MOCKINGJAY PART 2"))

data = read.csv("screentime.csv")

agg_time = aggregate(data$time, by=list(data$character), FUN=sum)
character_order = agg_time[order(agg_time$x), ]$Group.1

data$character = factor(data$character, levels=character_order)
data$movie = factor(data$movie, levels=movie_order)

data = data[complete.cases(data), ]

mean(data$time)
median(data$time)

num_movies = length(unique(data$movie))
set1_cols = brewer.pal(num_movies, "Set1")
set2_cols = brewer.pal(num_movies, "Set2")
set3_cols = brewer.pal(num_movies, "Set3")
pastel1_cols = brewer.pal(num_movies, "Pastel1")
pastel2_cols = brewer.pal(num_movies, "Pastel2")
dark_cols = brewer.pal(num_movies, "Dark2")
accent_cols = brewer.pal(num_movies, "Accent")

colors = c(set1_cols, set2_cols, set3_cols, pastel1_cols, pastel2_cols, dark_cols, accent_cols)

for (i in 1:(length(colors)/num_movies)) {
  color = colors[((i-1)*4+1):(i*4)]
  plot = ggplot(data=data, aes(x=character, y=time, fill=movie)) +
    geom_col(position = position_stack(reverse = TRUE)) + 
    ggtitle("Screen Time of The Hunger Game Characters") +
    xlab("Character") + ylab("Screen Time (minutes)") +
    guides(colour = guide_legend(reverse=TRUE)) + 
    scale_y_continuous(breaks=seq(0,500,by=100), labels=seq(0,500,by=100)) +
    scale_fill_manual(name="Movie", values=color) +
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
  
  ggsave(paste("plot_", i, ".png", sep=""), dpi=500)
}

###########################################################
# Grouped Bar Plot
###########################################################
ggplot(data, aes(x=movie, y=time)) +   
  geom_bar(aes(fill=character), position = "dodge", stat="identity")


