import copy
import csv

def parse_stats():
	with open('stats.txt') as f:
		content = f.readlines()
	content = [x.strip() for x in content]

	id_primer = '<td class="r"> <b>'
	name_primer = '<td class="l"> <a href="/wiki/'
	alt_name_primer = '</a> <small>('
	hp_stat_primer = '<td style="background:#FF5959"> '
	attack_stat_primer = '<td style="background:#F5AC78"> '
	defense_stat_primer = '<td style="background:#FAE078"> '
	sp_attack_stat_primer = '<td style="background:#9DB7F5"> '
	sp_defense_stat_primer = '<td style="background:#A7DB8D"> '
	speed_stat_primer = '<td style="background:#FA92B2"> '

	pokemon_list = []
	pokemon = {}
	for line in content:
		if id_primer in line:
			pokemon['id'] = int((line.split(id_primer)[1].split('</b>')[0])[0:4])
			poke_id = pokemon['id']
			if (poke_id >= 1 and poke_id <= 151):
				pokemon['gen'] = 1
			elif (poke_id >= 152 and poke_id <= 251):
				pokemon['gen'] = 2
			elif (poke_id >= 252 and poke_id <= 386):
				pokemon['gen'] = 3
			elif (poke_id >= 387 and poke_id <= 494):
				pokemon['gen'] = 4
			elif (poke_id >= 495 and poke_id <= 649):
				pokemon['gen'] = 5
			elif (poke_id >= 650 and poke_id <= 722):
				pokemon['gen'] = 6
			else:
				pokemon['gen'] = 7
		elif name_primer in line:
			pokemon['name'] = line.split("/wiki/")[1].split('_')[0]
			pokemon['is-alt-form'] = False
			if alt_name_primer in line:
				pokemon['name'] = line.split(alt_name_primer)[1].split(')')[0]
				pokemon['is-alt-form'] = True
		elif hp_stat_primer in line:
			pokemon['hp'] = int(line.split(hp_stat_primer)[1].split('\n')[0])
		elif attack_stat_primer in line:
			pokemon['attack'] = int(line.split(attack_stat_primer)[1].split('\n')[0])
		elif defense_stat_primer in line:
			pokemon['defense'] = int(line.split(defense_stat_primer)[1].split('\n')[0])
		elif sp_attack_stat_primer in line:
			pokemon['sp-attack'] = int(line.split(sp_attack_stat_primer)[1].split('\n')[0])
		elif sp_defense_stat_primer in line:
			pokemon['sp-defense'] = int(line.split(sp_defense_stat_primer)[1].split('\n')[0])
		elif speed_stat_primer in line:
			pokemon['speed'] = int(line.split(speed_stat_primer)[1].split('\n')[0])
			pokemon_list.append(copy.deepcopy(pokemon))
			pokemon.clear()
			pokemon = {}

	file = open('pokemon-stats.csv', 'w')
	writer = csv.DictWriter(file, fieldnames=['name', 'id', 'gen', 'is-alt-form', 'hp', 'attack', 'defense', 'sp-attack', 'sp-defense', 'speed'])
	writer.writeheader()
	for pokemon_row in pokemon_list:
		writer.writerow(pokemon_row)
	file.close()
	print 'Done creating csv!'

parse_stats()
