setwd("~/Developer/data-visualization-projects/mm-colors")

library(ggplot2)
library(reshape2)

# bag 1: n=22
# bag 2: n=22
# bag 3:
data = read.csv("data.csv")

# normalize counts
data$total = apply(data[,2:7], 1, FUN=sum)
data$red_perc = (data$red/data$total)*100
data$orange_perc = (data$orange/data$total)*100
data$yellow_perc = (data$yellow/data$total)*100
data$green_perc = (data$green/data$total)*100
data$blue_perc = (data$blue/data$total)*100
data$brown_perc = (data$brown/data$total)*100

data_count = data[,c(1,2:7)]
data_perc = data[,c(1,9:14)]

#              red,      orange,    yellow,   green,    blue,     brown
mm_colors = c("#EE3932","#FF7509", "#FCBB47","#57CD7F","#0168A3","#614126")

###########################################################
# heatmap
###########################################################

make_heatmap = function(data, title, sub, xlab, ylab, filename) {
  g = ggplot(melt(data, id="X"), aes(x=X, y=variable)) +
    geom_tile(aes(fill=variable, alpha=value), color="white") +
    geom_text(aes(label=round(value)), size=3) +
    scale_fill_manual("Colors", labels=colnames(data_count)[2:7], values=mm_colors) +
    guides(alpha="none", fill="none") +
    scale_x_continuous(breaks=seq(1,nrow(data)), labels=seq(1,nrow(data)))+
    scale_y_discrete(limits=rev(colnames(data)[2:ncol(data)]), labels=rev(colnames(data_count)[2:ncol(data_count)])) +
    labs(
      title=title,
      subtitle=sub,
      x=xlab,
      y=ylab
    ) +
    theme(
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      panel.border=element_rect(color="black", fill=NA)
    )
  ggsave(filename, height=5, width=14, dpi=300)
  g
}

make_heatmap(data_perc, "M&M Color Percentage per \"Fun Size\" Pack", "Normalized Heatmap (n=44)", 
             "Pack Number", "Color", "heatmap_norm.png")

make_heatmap(data_count, "M&M Color Counts per \"Fun Size\" Pack", "Counts Heatmap (n=44)", 
             "Pack Number", "Color", "heatmap.png")

###########################################################
# stacked bar plot
###########################################################

make_stacked_barplot = function(data, isNorm, title, sub, xlab, ylab, filename) {
  
  g = ggplot(data=melt(data,id="X"), aes(x=X,y=value,fill=variable)) +
    geom_col(position = position_stack(reverse = TRUE), alpha=0.8) + 
    scale_fill_manual("Colors", labels=colnames(data_count)[2:7], values=mm_colors) +
    labs(
      title=title,
      subtitle=sub,
      x=xlab, 
      y=ylab
      ) +
    theme(
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      panel.border=element_rect(color="black", fill=NA),
      aspect.ratio=1
    )
  
  if (isNorm) {
    g = g + scale_y_continuous(breaks=seq(0,100,10)) + 
      scale_x_continuous(trans="reverse", breaks=seq(1,nrow(data)), labels=seq(1,nrow(data))) +
      coord_flip()
    
  } else {
    g = g + scale_y_continuous(breaks=seq(0,18,2)) +
      scale_x_continuous(breaks=seq(1,nrow(data)), labels=seq(1,nrow(data)))
  }
  
  ggsave(filename,height=7,width=7,dpi=500)
  g
}

make_stacked_barplot(data_perc, TRUE, "M&M Color Percentage per \"Fun Size\" Pack", "Normalized Stacked Bar Plot (n=44)", 
             "Pack Number", "Color Percentage", "stacked_barplot_norm.png")

make_stacked_barplot(data_count, FALSE, "M&M Color Counts per \"Fun Size\" Pack", "Counts Stacked Bar Plot (n=44)", 
                     "Pack Number", "Color Counts", "stacked_barplot.png")

###########################################################
# boxplots
###########################################################

make_boxplot = function(data, isNorm, title, sub, xlab, ylab, filename) {
  g = ggplot(data=melt(data,id="X"), aes(x=variable,y=value,fill=variable))+
    geom_boxplot(aes(fill=variable),alpha=.5)+
    geom_jitter(aes(color=variable),size=4,alpha=.2)+
    scale_color_manual(labels=colnames(data_count)[2:7], values=mm_colors) +
    scale_fill_manual(labels=colnames(data_count)[2:7], values=mm_colors) +
    scale_x_discrete(labels=colnames(data_count)[2:7]) +
    guides(fill=FALSE,color=FALSE) +
    labs(
      title=title,
      subtitle=sub,
      x=xlab, 
      y=ylab
    ) +
    theme(
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      panel.border=element_rect(color="black", fill=NA),
      aspect.ratio=1
    )
  
  if (isNorm) {
    g = g + scale_y_continuous(breaks=seq(0,70,10))
  } else {
    g = g + scale_y_continuous(breaks=seq(0,12,2))
  }
  
  ggsave(filename,height=7,width=7,dpi=300)
  g
}

make_boxplot(data_perc, TRUE, "M&M Color Percentage per \"Fun Size\" Pack", "Normalized Box Plot (n=44)", 
             "Color", "Color Percentage", "boxplot_norm.png")

make_boxplot(data_count, FALSE, "M&M Color Counts per \"Fun Size\" Pack", "Counts Box Plot (n=44)", 
             "Color", "Color Counts", "boxplot.png")

###########################################################
# summary stats
###########################################################

indices = c(2:7,9:14)
data_sum = data.frame (
  "color" = names(data)[indices],
  "mean" = sapply(data[indices], mean),
  "sd" = sapply(data[indices], sd)
  )
data_sum$upper = data_sum$mean + 1.96*(data_sum$sd/sqrt(nrow(data)))
data_sum$lower = data_sum$mean - 1.96*(data_sum$sd/sqrt(nrow(data)))

data_sum_counts = data_sum[1:6,]
data_sum_perc = data_sum[7:12,]

make_summary_plot = function(data, isNorm, title, sub, xlab, ylab, filename) {
  data$color = factor(colnames(data_count)[2:7], levels=colnames(data_count)[2:7])
  g = ggplot(data=data, aes(x=color, y=mean)) +
    geom_bar(stat="identity",aes(fill=color),alpha=.8,color="black") +
    geom_errorbar(aes(ymax=upper,ymin=lower),width=0.2,size=1,alpha=.5) +
    scale_fill_manual("Color",values=mm_colors) +
    guides(fill="none") +
    labs(
      title=title,
      subtitle=sub,
      x=xlab,
      y=ylab
      ) +
    theme(
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.background=element_blank(),
      panel.border=element_rect(color="black", fill=NA),
      aspect.ratio=1
    )
  
  ggsave(filename,height=7,width=7,dpi=300)
  g
}

make_summary_plot(data_sum_perc, TRUE, "M&M Color Percentage per \"Fun Size\" Pack", "Mean Percentage with 95% CI (n=44)", 
             "Color", "Color Percentage", "summary_plot_norm.png")

make_summary_plot(data_sum_counts, FALSE, "M&M Color Counts per \"Fun Size\" Pack", "Mean Counts with 95% CI (n=44)", 
             "Color", "Color Counts", "summary_plot.png")
