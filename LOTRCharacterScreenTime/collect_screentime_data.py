import os
import csv

movie_titles = [
	"The Fellowship of the Ring", 
	"The Two Towers",
	"The Return of the King"
]

def get_html():
	print "\nGetting html for movies table..."	
	url_string = "http://www.imdb.com/list/ls036259945/"
	os.system("curl " + url_string + " > lotr_onscreen_time.txt")

def parse_time(string_split):
	time_string = string_split.split(" &lt;")[1].split("&gt")[0]

	movie_time_split = time_string.split(":")
	movie_time_min = 0

	if ("x" not in movie_time_split):
		if len(movie_time_split) == 1:
			movie_time_min = int(movie_time_split[0])
		elif len(movie_time_split) == 2:
			if (movie_time_split[0] == ""):
				movie_time_min = int(movie_time_split[1]) / 60.0
			else:
				movie_time_min += int(movie_time_split[0])
				movie_time_min += int(movie_time_split[1]) / 60.0

	return movie_time_min

def get_data_from_html():
	print "\nParsing html file..."

	file = open("lotr_onscreen_time.txt")
	content = file.readlines()
	content = [x.strip() for x in content]
	
	CHAR_NAME_LINE_START = "<b><a     href=\"/character/ch"
	SCREENTIME_INFO_LINE_START = "<div class=\"description\">"

	character_desc_map = {}
	character = ""
	for line in content:
		if line.startswith(CHAR_NAME_LINE_START):
			character = line.split(CHAR_NAME_LINE_START)[1].split(">")[1].split("</a></b>")[0]
			character = character.replace("</a", "")
			character = character.replace("&#x27;", "")
		elif line.startswith(SCREENTIME_INFO_LINE_START):
			character_desc_map[character] = line

	# print character_desc_map

	data = []
	for character in character_desc_map.keys():
		desc = character_desc_map[character]
		# print desc
		for movie in movie_titles:
			# print movie
			theatrical_time_min = 0
			extended_time_min = 0

			if movie in desc:
				split_by_movie = desc.split(movie)[1]
				# print split_by_movie

				theatrical_split = split_by_movie.split("--- Theatrical")
				if (len(theatrical_split) > 1):
					theatrical_time_min = parse_time(theatrical_split[1])

				extended_split = split_by_movie.split("--- Extended")
				if (len(extended_split) > 1):
					extended_time_min = parse_time(extended_split[1])
				
			datum = {}
			datum["character"] = character
			datum["movie"] = movie
			datum["the_time"] = theatrical_time_min
			datum["ext_time"] = extended_time_min
			data.append(datum)

	file.close()
	return data

def write_to_csv(data):
	print "\nWriting to csv file..."
	csv_file = open('screentime.csv', 'w')
	csv_writer = csv.writer(csv_file, delimiter=',')
	csv_writer.writerow(['character', 'movie', 'the_time', 'ext_time'])
	
	for datum in data:
		csv_writer.writerow([datum['character'], datum['movie'], datum['the_time'], datum['ext_time']])

	csv_file.close()

def main():
	get_html()
	data = get_data_from_html()
	write_to_csv(data)
	print "\nDone!"

main()