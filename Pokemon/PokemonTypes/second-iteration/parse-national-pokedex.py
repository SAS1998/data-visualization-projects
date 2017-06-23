import csv

def parse_pokemon_info(line):
	poke_id = int(line.split('></a><br><small>#')[1].split('</small><br><a')[0])
	pokemon_entry = {}
	pokemon_entry['name'] = line.split('href="/pokedex/')[1].split('"')[0]
	pokemon_entry['type1'] = line.split('href="/type/')[1].split('"')[0]
	if (len(line.split('href="/type/')) > 2):
		pokemon_entry['type2'] = line.split('href="/type/')[2].split('"')[0]
	else:
		pokemon_entry['type2'] = 'none'

	if (1 <= poke_id <= 151):
		pokemon_entry['gen'] = 1
	elif (152 <= poke_id <= 251):
		pokemon_entry['gen'] = 2
	elif (252 <= poke_id <= 386):
		pokemon_entry['gen'] = 3
	elif (387 <= poke_id <= 494):
		pokemon_entry['gen'] = 4
	elif (495 <= poke_id <= 649):
		pokemon_entry['gen'] = 5
	elif (650 <= poke_id <= 722):
		pokemon_entry['gen'] = 6
	else:
		pokemon_entry['gen'] = 7

	return pokemon_entry


def create_pokemon_data():
	file = open('national-pokedex.html', 'r')
	lines = file.readlines()

	pokemon_data = []
	for line in lines:
		if (line.startswith('<span class="infocard-tall "><a class="pkg')):
			pokemon_data.append(parse_pokemon_info(line))

	file.close()

	return pokemon_data

def write_csv(pokemon_data):
	file = open('national-pokedex.csv', 'w')
	writer = csv.DictWriter(file, fieldnames=['name', 'type1', 'type2', 'gen'])
	writer.writeheader()
	for pokemon_row in pokemon_data:
		writer.writerow(pokemon_row)
	file.close()
	print 'Done writing to csv!'

def main():
	pokemon_data = create_pokemon_data()
	write_csv(pokemon_data)
	

if __name__ == "__main__":
	main()