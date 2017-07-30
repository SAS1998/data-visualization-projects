library(ggplot2)
library(RColorBrewer)
library(plyr)
setwd("~/Developer/data-visualization-projects/GenericCharacterScreenTime")

files = list.files(path = "./")

for (i in 1:length(files)) {
  filename = files[i]
  if (grepl(".csv", filename)) {
    data = read.csv(filename)
    agg_time = aggregate(data$time, by=list(data$character), FUN=sum)
    character_order = agg_time[order(agg_time$x), ]$Group.1
    data$character = factor(data$character, levels=character_order)
    data = data[complete.cases(data), ]
    
    title = data$title[1]
    
    mean(data$time)
    median(data$time)

    plot = ggplot(data=data, aes(x=character, y=time)) +
      geom_col(position = position_stack(reverse = TRUE)) + 
      ggtitle(paste0("Screen Time of ", title, " Characters")) +
      xlab("Character") + ylab("Screen Time (minutes)") +
      guides(colour = guide_legend(reverse=TRUE)) + 
      scale_y_continuous(breaks=seq(0,round_any(max(data$time), 10),by=30), labels=seq(0,round_any(max(data$time), 10),by=30)) +
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
    
    ggsave(paste("plot_", title, ".png", sep=""), dpi=500)

  }

}
