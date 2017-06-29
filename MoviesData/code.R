library(stringr)
library(ggplot2)
library(reshape2)

#################################################
# load and clean-up data
#################################################
movies = read.csv("yearly_top_movie.csv")

movies$total = as.numeric(movies$total)
movies$total_2012_constant = as.numeric(movies$total_2012_constant)
movies$num_tickets = as.numeric(movies$num_tickets)

categoriesUnlisted = str_trim(unlist(strsplit(as.character(movies$other_data), "\n")))

movies$creative_type = as.factor(categoriesUnlisted[seq(1,92,by=4)])
movies$prod_method = as.factor(categoriesUnlisted[seq(2,92,by=4)])
movies$source = as.factor(categoriesUnlisted[seq(3,92,by=4)])
movies$genre = as.factor(categoriesUnlisted[seq(4,92,by=4)])

movies$other_data = NULL

#################################################
# plot movies and tickets/totals
#################################################
movies$movie_year = as.factor(paste(movies$year, "-", movies$movie, sep=" "))

#----------------------------------
# barplot: movie year x num tickets 
#----------------------------------
ggplot(data=movies, aes(x=movie_year, y=num_tickets)) +
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

#----------------------------------
# barplot: movie year x totals
#----------------------------------
ggplot(data=movies, aes(x=movie_year, y=total)) +
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

ggplot(data=movies, aes(x=movie_year, y=total_2012_constant)) +
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

ggplot(data=movies, aes(x=movie_year, y=num_tickets)) +
  geom_bar(stat="identity") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

# combined: tickets sold and dollar sold
ggplot(data=movies, aes(x=movie_year, y=total_2012_constant)) +   
  geom_bar(stat="identity") + 
  geom_line(data=movies, aes(x=movie_year, y=num_tickets*10, group=1), color="blue") + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

#################################################
# aggregate data
#################################################

aggregater = function(toAggregate, byColumn) {
  sumAgg = aggregate(toAggregate, by=list(byColumn), FUN=sum)
  meanAgg = aggregate(toAggregate, by=list(byColumn), FUN=mean)
  medianAgg = aggregate(toAggregate, by=list(byColumn), FUN=median)
  data.frame(x=sumAgg[,1], sum=sumAgg[,2], mean=meanAgg[,2], median=medianAgg[,2])
}

groupedBarPlotter = function(data, xlab) {
  titlePre = "Top Movie of the Year (1995-2017):"
  ylab = "Box Office (2012 Constant Dollars)"
  melted = melt(data, id.var="x")
  plot = ggplot(data=melted, aes(x=x, y=value)) +
    geom_bar(aes(fill=variable), position = "dodge", stat="identity") +
    ggtitle(paste(titlePre, xlab, "Distribution", sep=" ")) + 
    xlab(xlab) + ylab(ylab)
  plot
}

#----------------------------------
# aggregate 2012 constant by rating
#----------------------------------
aggRating = aggregater(movies$total_2012_constant, movies$rating)
groupedBarPlotter(aggRating, "MPAA Rating")

#----------------------------------
# aggregate 2012 constant by distributor
#----------------------------------
aggDistributor = aggregater(movies$total_2012_constant, movies$distributor)
groupedBarPlotter(aggDistributor, "Distributor")

#----------------------------------
# aggregate 2012 constant by create type
#----------------------------------
aggCreateType = aggregater(movies$total_2012_constant, movies$creative_type)
groupedBarPlotter(aggCreateType, "Creative Types")

#----------------------------------
# aggregate 2012 constant by production method
#----------------------------------
aggProdMeth= aggregater(movies$total_2012_constant, movies$prod_method)
groupedBarPlotter(aggProdMeth, "Production Method")

#----------------------------------
# aggregate 2012 constant by source
#----------------------------------
aggSource = aggregater(movies$total_2012_constant, movies$source)
groupedBarPlotter(aggSource, "Source")

#----------------------------------
# aggregate 2012 constant by genre
#----------------------------------
aggGenre = aggregater(movies$total_2012_constant, movies$genre)
groupedBarPlotter(aggGenre, "Genre")
