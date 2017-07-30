library('lattice')
library('ggplot2')
library('reshape2')
setwd("~/Desktop/Linda's Projects/AppStoreGames")

#######################################
# prepare and set up data
#######################################
data = read.csv("purchases.csv")
data$game = as.character(data$game)
data$date = as.Date(data$date, "%m/%d/%y")
data$yearmon = format(data$date, "%Y-%m")
data = data[order(data$date),]
data$year = year(data$date)
data$month = month(data$date)

data$quarter[data$month==1] = "Q1"
data$quarter[data$month==2] = "Q1"
data$quarter[data$month==3] = "Q1"

data$quarter[data$month==4] = "Q2"
data$quarter[data$month==5] = "Q2"
data$quarter[data$month==6] = "Q2"

data$quarter[data$month==7] = "Q3"
data$quarter[data$month==8] = "Q3"
data$quarter[data$month==9] = "Q3"

data$quarter[data$month==10] = "Q4"
data$quarter[data$month==11] = "Q4"
data$quarter[data$month==12] = "Q4"

data$yearQ = paste(data$year,data$quarter,sep="-")

#######################################
# mark low spending games as other
#######################################
aggregated_game = aggregate(data$price,by=list(data$game),FUN=sum)
colnames(aggregated_game) = c("game", "price")
top_spending_games = aggregated_game[which(aggregated_game$price>50),1]

data$game[!(data$game %in% top_spending_games)] = "Other"

#######################################
# stacked bar chart: money spent per game per month
#######################################
quarterly_aggregated_game = aggregate(data$price,by=list(date=data$yearQ, game=data$game),FUN=sum)
quarterly_aggregated_game = quarterly_aggregated_game[order(quarterly_aggregated_game$date),]
matrix_quarterly_aggregated_game = reshape(quarterly_aggregated_game, timevar='date', idvar='game', direction='wide')
matrix_quarterly_aggregated_game[is.na(matrix_quarterly_aggregated_game)]=0
colnames(matrix_quarterly_aggregated_game) = gsub("x.", "", colnames(matrix_quarterly_aggregated_game))
rownames(matrix_quarterly_aggregated_game) = matrix_quarterly_aggregated_game$game
matrix_quarterly_aggregated_game$game = NULL

barplot(as.matrix(matrix_quarterly_aggregated_game), 
        main="Mobile Game Spending", xlab="Quarter", ylab="Amount Spent ($)", ylim=c(0,450), 
        col=c('gray', 'orange', 'purple', 'blue', 'green', 'yellow', 'red'), 
        legend=rownames(matrix_quarterly_aggregated_game), args.legend=list(x=3,y=400,bty="n"))

#######################################
# ggplot stacked bar chart: money spent per game per month
#######################################
ggplot(quarterly_aggregated_game, aes(x=date, y=x, fill=game)) + 
  geom_bar(stat='identity') + xlab("Quarter") + ylab("Amount Spent ($)") + ggtitle("Quarterly Mobile Game Spending")
