library(ggplot2)
library(RColorBrewer)
setwd("~/Developer/data-visualization-projects/LOTRCharacterScreenTime")

movie_order = as.factor(c("The Fellowship of the Ring", 
                          "The Two Towers",
                          "The Return of the King"))

data = read.csv("screentime.csv")

num_movies = length(unique(data$movie))
set1_cols = brewer.pal(num_movies, "Set1")
set2_cols = brewer.pal(num_movies, "Set2")
set3_cols = brewer.pal(num_movies, "Set3")
pastel1_cols = brewer.pal(num_movies, "Pastel1")
pastel2_cols = brewer.pal(num_movies, "Pastel2")
dark_cols = brewer.pal(num_movies, "Dark2")
accent_cols = brewer.pal(num_movies, "Accent")

colors = c(set1_cols, set2_cols, set3_cols, pastel1_cols, pastel2_cols, dark_cols, accent_cols)
colorsString = c("set1", "set2", "set3", "pastel1", "pastel2", "dark", "accent")

# loop for each type (theatrical, extended)
for (t in 1:2) {
  type = ""
  if (t == 1) {
    data$time = data$the_time
    type = "theatrical"
  } else {
    data$time = data$ext_time
    type = "extended"
  }
  
  agg_time = aggregate(data$time, by=list(data$character), FUN=sum)
  character_order = agg_time[order(agg_time$x), ]$Group.1
  
  # limit num characters to top k
  k = 30
  num_char = length(character_order)
  character_order = character_order[(num_char-k+1):num_char]
  
  data$character = factor(data$character, levels=character_order)
  data$movie = factor(data$movie, levels=movie_order)
  
  data = data[complete.cases(data), ]
  
  mean(data$time)
  median(data$time)
  
  for (i in 1:(length(colors)/num_movies)) {
    color = colors[((i-1)*num_movies+1):(i*num_movies)]
    plot = ggplot(data=data, aes(x=character, y=time, fill=movie)) +
      geom_col(position = position_stack(reverse = TRUE)) + 
      ggtitle("Screen Time of LOTR Characters") +
      xlab("Character") + ylab("Screen Time (minutes)") +
      guides(colour = guide_legend(reverse=TRUE)) + 
      scale_y_continuous(breaks=seq(0,150,by=50), labels=seq(0,150,by=50)) +
      scale_fill_manual(name="Movie", values=color) +
      theme(
        panel.grid.minor.x=element_blank(),
        aspect.ratio=1,
        text=element_text(size=8), 
        plot.title=element_text(size=12),
        legend.text=element_text(size=8),
        legend.key.size = unit(1, "lines"),
        axis.text=element_text(size=8)
      ) +
      coord_flip()
    plot
    
    ggsave(paste("plot_", colorsString[i], "_", type, ".png", sep=""), dpi=750)
  }
}
###########################################################
# Grouped Bar Plot
###########################################################
ggplot(data, aes(x=movie, y=time)) +   
  geom_bar(aes(fill=character), position = "dodge", stat="identity")


