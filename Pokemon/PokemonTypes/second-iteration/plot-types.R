library(ggplot2)

setwd("~/Desktop/Linda's Projects/Pokemon/PokemonTypes/second-iteration")

#######################################
# set up global data
#######################################
data = read.csv('national-pokedex.csv')
data$type1 = as.character(data$type1)
data$type2 = as.character(data$type2)

typesColors = c('#A8B820','#705848', '#7038F8', '#F8D030', '#EE99AC', '#C03028', '#F08030', '#A890F0', '#705898', '#78C850', '#E0C068', '#98D8D8', '#A8A878', '#A040A0', '#F85888', '#B8A038', '#B8B8D0', '#6890F0')

#######################################
# overall type distribution
#######################################
# plot bar chart by region with overall average


#######################################
# overall type distribution
#######################################
# plot frequency of types as primary, secondary