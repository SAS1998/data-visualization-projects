library(ggplot2)
library(grid)
library(gridExtra)
library(cowplot)

#################################################
# functions
#################################################

season = function(dates) {
  WS = as.Date("2012-12-15", format = "%Y-%m-%d") # Winter Solstice
  SE = as.Date("2012-3-15",  format = "%Y-%m-%d") # Spring Equinox
  SS = as.Date("2012-6-15",  format = "%Y-%m-%d") # Summer Solstice
  FE = as.Date("2012-9-15",  format = "%Y-%m-%d") # Fall Equinox
  
  # Convert dates from any year to 2012 dates
  d = as.Date(strftime(dates, format="2012-%m-%d"))
  
  ifelse (d >= WS | d < SE, "Winter",
          ifelse (d >= SE & d < SS, "Spring",
                  ifelse (d >= SS & d < FE, "Summer", "Fall")))
}

sumAggregater = function(toAggregate, byColumns) {
  sumAgg = aggregate(toAggregate, by=byColumns, FUN=sum)
  colnames(sumAgg) = c("year", "group", "tickets")
  sumAgg
}

meanAggregater = function(toAggregate, byColumns) {
  meanAgg = aggregate(toAggregate, by=byColumns, FUN=mean)
  colnames(meanAgg) = c("year", "group", "tickets")
  meanAgg
}

groupedBarPlotter = function(data, grouping, aggType) {
  min_y = 0
  max_y = 0
  interval = 0
  if (aggType == "Total") {
    max_y = 1250
    interval = 250
  } else if (aggType == "Mean") {
    max_y = 125
    interval = 25
  }
  
  resultPlot = ggplot(data=data, aes(x=year, y=tickets)) +
    geom_bar(aes(fill=group), stat="identity") +
    ggtitle(paste("Movie Tickets Sold by ", grouping, " - ", aggType, sep="")) + 
    xlab("Year") + ylab(paste(aggType, " Tickets Sold (M)", sep="")) + 
    scale_fill_discrete(name=grouping) + 
    scale_x_continuous(breaks=seq(1994,2016,by=1), labels=seq(1994,2016,by=1)) + 
    scale_y_continuous(breaks=seq(min_y,max_y,by=interval), labels=seq(min_y,max_y,by=interval)) +
    theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5), panel.grid.minor.x=element_blank())
  
  resultPlot
}

percentGroupedBarPlotter = function(data, grouping) {
  data <- data[order(data$tickets), ]
  resultPlot = ggplot(data=data, aes(x=year, y=tickets, order=group)) +
    geom_col(aes(fill=group), position = position_stack(reverse = TRUE)) +
    ggtitle(paste("Movie Tickets Sold by ", grouping, sep="")) + 
    xlab("Year") + ylab(paste("Percentage of Tickets Sold", sep="")) + 
    scale_fill_discrete(name=grouping) + 
    scale_x_continuous(breaks=seq(1994,2016,by=2), labels=seq(1994,2016,by=2)) + 
    scale_y_continuous(breaks=seq(0,100,by=100), labels=seq(0,100,by=100)) +
    theme(
      panel.grid.minor.x=element_blank(), 
      panel.grid.minor.y=element_blank(), 
      plot.margin = unit(c(4,4,4,4), "lines"),
      aspect.ratio=1, 
      text=element_text(size=36), 
      plot.title=element_text(size=38),
      legend.text=element_text(size=30),
      legend.key.size = unit(2.8, "lines"),
      axis.text=element_text(size=26)
    ) +
    guides(colour = guide_legend(reverse=T)) +
    coord_flip()
  
  resultPlot
}

#################################################
# load and clean-up data
#################################################
movies = read.csv("movies.csv")

movies$mpaa_rating = factor(movies$mpaa_rating, levels=c("G", "PG", "PG-13", "R", "NC-17", "Not-Rated"))
movies$release_date = as.Date(movies$release_date, format="%Y/%m/%d")
movies$release_dow = factor(weekdays(movies$release_date), levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
movies$release_season = factor(season(movies$release_date), levels=c("Spring", "Summer", "Fall", "Winter"))
movies$release_yearmon = paste(movies$year, "-", format(movies$release_date,"%m"), sep="")
movies$num_tickets_sold = movies$num_tickets_sold / 100

months = format(seq(as.Date("2012/03/01", format="%Y/%m/%d"), as.Date("2013/2/01", format="%Y/%m/%d"), by="month"), format="%B")
movies$release_month = format(movies$release_date, format="%B")
movies$release_month = factor(movies$release_month, levels=months)

top_dist = c("Walt Disney", "Warner Bros.", "Sony Pictures", "20th Century Fox", "Universal", "Paramount Pictures", "Lionsgate", "New Line", "Dreamworks SKG", "Miramax", "Other")
movies$distributor_name = as.character(movies$distributor_name)
movies$distributor_name[which(!(movies$distributor_name %in% top_dist))] = "Other"
movies$distributor_name = factor(movies$distributor_name, levels=top_dist)

yearly_ticket_sum = aggregate(movies$num_tickets_sold, by=list(year=as.numeric(movies$year)), FUN=sum)
movies$year_ticket_total = unlist(lapply(yearly_ticket_sum$x, function(i) {rep(i, 100)}))
movies$ticket_percent_of_year = (movies$num_tickets_sold / movies$year_ticket_total) * 100

top_genre = c("Adventure", "Comedy", "Action", "Drama", "Thriller/Suspense", "Horror", "Romantic Comedy", "Musical", "Documentary", "Black Comedy", "Other")
movies$genre = as.character(movies$genre)
movies$genre[which(!(movies$genre %in% top_genre))] = "Other"
movies$genre = factor(movies$genre, levels=top_genre)

#################################################
# aggregated stacked bar plots
#################################################
#----------------------------------
# agg tickets by mpaa rating stacked by year
#----------------------------------
sumAgg_MpaaRating = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$mpaa_rating))
sumAgg_MpaaRating_plot = groupedBarPlotter(sumAgg_MpaaRating, "MPAA Ratings", "Total")
sumAgg_MpaaRating_plot

meanAgg_MpaaRating = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$mpaa_rating))
meanAgg_MpaaRating_plot = groupedBarPlotter(meanAgg_MpaaRating, "MPAA Ratings", "Mean")
meanAgg_MpaaRating_plot

#----------------------------------
# agg tickets by genre stacked by year
#----------------------------------
sumAgg_genre = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$genre))
sumAgg_genre_plot = groupedBarPlotter(sumAgg_genre, "Genre", "Total")
sumAgg_genre_plot

meanAgg_genre = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$genre))
meanAgg_genre_plot = groupedBarPlotter(meanAgg_genre, "Genre", "Mean")
meanAgg_genre_plot

#----------------------------------
# agg tickets by season stacked by year
#----------------------------------
sumAgg_season = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$release_season))
sumAgg_season_plot = groupedBarPlotter(sumAgg_season, "Season", "Total")
sumAgg_season_plot

meanAgg_season = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$release_season))
meanAgg_season_plot = groupedBarPlotter(meanAgg_season, "Season", "Mean")
meanAgg_season_plot

#----------------------------------
# agg tickets by dow stacked by year
#----------------------------------
sumAgg_dow = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$release_dow))
sumAgg_dow_plot = groupedBarPlotter(sumAgg_dow, "Day of Week", "Total")
sumAgg_dow_plot

meanAgg_dow = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$release_dow))
meanAgg_dow_plot = groupedBarPlotter(meanAgg_dow, "Day of Week", "Mean")
meanAgg_dow_plot

#----------------------------------
# agg tickets by distributor stacked by year
#----------------------------------
sumAgg_distributor = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$distributor))
sumAgg_distributor_plot = groupedBarPlotter(sumAgg_distributor, "Distributor", "Total")
sumAgg_distributor_plot

meanAgg_distributor = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$distributor))
meanAgg_distributor_plot = groupedBarPlotter(meanAgg_distributor, "Distributor", "Mean")
meanAgg_distributor_plot

#----------------------------------
# combine all ggplots
#----------------------------------

plots = list(sumAgg_MpaaRating_plot, sumAgg_genre_plot, sumAgg_distributor_plot, 
             meanAgg_MpaaRating_plot, meanAgg_genre_plot, meanAgg_distributor_plot)

do.call(grid.arrange, list(grobs=plots, ncol=3, top=textGrob("Top 100 Movies (1994-2016)", gp=gpar(fontface="bold", fontsize=16))))


#################################################
# REPEAT ABOVE STEPS WITH PERCENTAGES
#################################################
generateAllPlots = function() {
  # agg tickets by genre stacked by year
  sumAgg_genre_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$genre))
  sumAgg_genre_percent_plot = percentGroupedBarPlotter(sumAgg_genre_percent, "Genre")
  sumAgg_genre_percent_plot
  
  # agg tickets by mpaa rating stacked by year
  sumAgg_MpaaRating_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$mpaa_rating))
  sumAgg_MpaaRating_percent_plot = percentGroupedBarPlotter(sumAgg_MpaaRating_percent, "MPAA Ratings")
  sumAgg_MpaaRating_percent_plot

  # agg tickets by distributor stacked by year
  sumAgg_distributor_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$distributor))
  sumAgg_distributor_percent_plot = percentGroupedBarPlotter(sumAgg_distributor_percent, "Distributor")
  sumAgg_distributor_percent_plot
  
  # agg tickets by dow stacked by year
  sumAgg_dow_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$release_dow))
  sumAgg_dow_percent_plot = percentGroupedBarPlotter(sumAgg_dow_percent, "Release DoW")
  sumAgg_dow_percent_plot
  
  # agg tickets by month stacked by year
  sumAgg_month_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$release_month))
  sumAgg_month_percent_plot = percentGroupedBarPlotter(sumAgg_month_percent, "Release Month")
  sumAgg_month_percent_plot
  
  # agg tickets by season stacked by year
  sumAgg_season_percent = sumAggregater(movies$ticket_percent_of_year, list(movies$year, movies$release_season))
  sumAgg_season_percent_plot = percentGroupedBarPlotter(sumAgg_season_percent, "Release Season")
  sumAgg_season_percent_plot
  
  rbind(
    cbind(ggplotGrob(sumAgg_genre_percent_plot), ggplotGrob(sumAgg_MpaaRating_percent_plot)), 
    cbind(ggplotGrob(sumAgg_distributor_percent_plot), ggplotGrob(sumAgg_dow_percent_plot)), 
    cbind(ggplotGrob(sumAgg_season_percent_plot),ggplotGrob(sumAgg_month_percent_plot))
  )
}

#----------------------------------
# combine all ggplots
#----------------------------------
plot_2x3 = generateAllPlots()
png("comboPercent3200x3600.png", width=3200, height=3600, units="px") 
grid.draw(plot_2x3)
dev.off()

#----------------------------------
# combine genre/distributor plots
#----------------------------------
grobs = list(
  ggplotGrob(sumAgg_genre_percent_plot), 
  ggplotGrob(sumAgg_distributor_percent_plot)
)

png("2comboPercent3000x1500.png", width=3000, height=1500, units="px") 
do.call(grid.arrange, list(grobs=grobs, ncol=2, top=textGrob("100 Top-Grossing Movies of 1994-2016", y=-1, gp=gpar(fontface="bold", fontsize=48))))
dev.off()

