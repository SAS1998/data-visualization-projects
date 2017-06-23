setwd("~/Desktop/Linda's Projects/Pokemon/PokemonStats")

data = read.csv("pokemon-stats.csv")

data$total = sum(data$hp, )
data$average = mean()
sorted_hp = data[order(-data$hp),] 
sorted_attack = data[order(-data$attack),] 
sorted_defense = data[order(-data$defense),] 
sorted_sp_attack = data[order(-data$sp.attack),] 
sorted_sp_defense = data[order(-data$sp.defense),] 
sorted_speed= data[order(-data$speed),] 