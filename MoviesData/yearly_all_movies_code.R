library(ggplot2)
library(grid)
library(gridExtra)

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
  plot = ggplot(data=data, aes(x=year, y=tickets)) +
    geom_bar(aes(fill=group), stat="identity") +
    ggtitle(paste("Yearly Movie Tickets Distribution by ", grouping, " - ", aggType, sep="")) + 
    xlab("Year") + ylab(paste(aggType, " Tickets Sold (M)", sep="")) + 
    scale_fill_discrete(name=grouping) + 
    scale_x_continuous(breaks=seq(1994,2016), labels=seq(1994,2016)) + 
    theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5), panel.grid.major.x=element_blank())
  plot
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
movies$num_tickets_sold = movies$num_tickets_sold / 1000000
movies$distributor_name = as.character(movies$distributor_name)
top_dist = c("Warner Bros.", "Sony Pictures", "Walt Disney", "Universal", "Paramount Pictures", "20th Century Fox", "New Line", "Lionsgate", "Miramax", "MGM")
movies$distributor_name[which(!(movies$distributor_name %in% top_dist))] = "Other"

#################################################
# aggregated stacked bar plots
#################################################

#----------------------------------
# agg tickets by mpaa rating stacked by year
#----------------------------------
sumAgg_MpaaRating = sumAggregater(movies$num_tickets_sold, list(movies$year, movies$mpaa_rating))
sumAgg_MpaaRating_plot = groupedBarPlotter(sumAggMpaaRating, "MPAA Ratings", "Total")
sumAgg_MpaaRating_plot

meanAgg_MpaaRating = meanAggregater(movies$num_tickets_sold, list(movies$year, movies$mpaa_rating))
meanAgg_MpaaRating_plot = groupedBarPlotter(meanAggMpaaRating, "MPAA Ratings", "Mean")
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

#################################################
# combine all ggplots
#################################################

plots = list(sumAgg_MpaaRating_plot, sumAgg_genre_plot, sumAgg_dow_plot, sumAgg_distributor_plot, 
             meanAgg_MpaaRating_plot, meanAgg_genre_plot, meanAgg_dow_plot, meanAgg_distributor_plot)

do.call(grid.arrange, list(grobs=plots, ncol=4, top=textGrob("Top 100 Movies (1994-2016)", gp=gpar(fontface="bold", fontsize=16))))








