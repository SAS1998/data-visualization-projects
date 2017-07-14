import os
import csv

movie_titles = [
		"Philosopher's/Sorcerer's Stone", 
		"Chamber of Secrets", 
		"Prisoner of Azkaban", 
		"Goblet of Fire", 
		"Order of the Phoenix",
		"Half-Blood Prince",
		"Deathly Hallows, Part I",
		"Deathly Hallows, Part II"
]

def get_html():
	print "\tgetting html for movies table..."	
	url_string = "http://www.imdb.com/list/ls031310246/"
	os.system("curl " + url_string + " > hp_onscreen_time.txt")

def get_data_from_html():
	print "\tparsing html file..."

	file = open("hp_onscreen_time.txt")
	content = file.readlines()
	content = [x.strip() for x in content]
	
	CHAR_NAME_LINE_START = "<b><a     href=\"/character/ch"
	SCREENTIME_INFO_LINE_START = "<div class=\"description\">"

	character_desc_map = {}
	character = ""
	for line in content:
		if line.startswith(CHAR_NAME_LINE_START):
			character = line.split(CHAR_NAME_LINE_START)[1].split(">")[1].split("</a></b>")[0]
		elif line.startswith(SCREENTIME_INFO_LINE_START):
			character_desc_map[character] = line

	data = []
	for character in character_desc_map.keys():
		desc = character_desc_map[character]
		# print desc
		for movie in movie_titles:
			movie_time_min = 0
			# print movie
			if movie in desc:
				time_string = desc.split(movie)[1].split(" &lt;")[1].split("&gt")[0]
				movie_time_split = time_string.split(":")
				if ("x" not in movie_time_split and "15<br/>* ...Deathly Hallows, Part I" not in movie_time_split):
					if len(movie_time_split) == 1:
						movie_time_min = int(movie_time_split[0]) * 60
					elif len(movie_time_split) == 2:
						if (movie_time_split[0] == ""):
							movie_time_min = int(movie_time_split[1])
						else:
							movie_time_min += int(movie_time_split[0]) * 60
							movie_time_min += int(movie_time_split[1])

			datum = {}
			datum["character"] = character
			datum["movie"] = movie
			datum["time"] = movie_time_min
			data.append(datum)

	file.close()
	return data

def write_to_csv(data):
	print "writing to csv file..."
	csv_file = open('screentime.csv', 'w')
	csv_writer = csv.writer(csv_file, delimiter=',')
	csv_writer.writerow(['character', 'movie', 'time'])
	
	for datum in data:
		csv_writer.writerow([datum['character'], datum['movie'], datum['time']])

	csv_file.close()

def main():
	get_html()
	data = get_data_from_html()
	write_to_csv(data)
	print "Done!"

main()