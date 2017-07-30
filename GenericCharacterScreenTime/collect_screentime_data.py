import os
import csv

def read_metadata():
	metafile = open("imdb_urls.txt")
	content = metafile.readlines()
	content = [x.strip() for x in content]

	title_line = -1
	url_line = -1

	for i in range(0, len(content)):
		line = content[i]
		if (line.startswith("[Titles]")):
			title_line = i
		elif (line.startswith("[URLS]")):
			url_line = i

	titles = []
	urls = []

	titles = content[title_line+1:url_line]
	urls = content[url_line+1:len(content)]

	print "titles: " + str(titles)
	print "urls: " + str(urls)

	return (titles, urls)

def get_html(url, title):
	print "\nGetting html for [" + title + "]..."	
	os.system("curl " + url + " > temp.txt")

def get_data_from_html(title):
	print "\nParsing html for [" + title + "]..."

	file = open("temp.txt")
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
		elif line.startswith(SCREENTIME_INFO_LINE_START):
			character_desc_map[character] = line

	# print character_desc_map

	data = []
	for character in character_desc_map.keys():
		desc = character_desc_map[character]
		# print desc

		onscreen_time_min = 0

		time_string = desc.split(" minutes<span ")[0]
		time_string = time_string[len(time_string)-6:]
		if (time_string.find(">") > -1):
			time_string = time_string.split(">")[1]
		
		onscreen_time_split = time_string.split(":")
		if ("x" not in onscreen_time_split):
			if len(onscreen_time_split) == 1:
				onscreen_time_min = int(onscreen_time_split[0])
			elif len(onscreen_time_split) == 2:
				if (onscreen_time_split[0] == ""):
					onscreen_time_min = int(onscreen_time_split[1]) / 60.0
				else:
					onscreen_time_min += int(onscreen_time_split[0])
					onscreen_time_min += int(onscreen_time_split[1]) / 60.0

			datum = {}
			datum["character"] = character
			datum["title"] = title
			datum["time"] = onscreen_time_min
			data.append(datum)

	file.close()
	return data

def write_to_csv(data, title):
	print "\nWriting to csv file for [" + title + "]..."
	csv_file = open(title + "_screentime.csv", "w")
	csv_writer = csv.writer(csv_file, delimiter=',')
	csv_writer.writerow(['character', 'title', 'time'])
	
	for datum in data:
		csv_writer.writerow([datum['character'], datum['title'], datum['time']])

	csv_file.close()

def main():
	(titles, urls) = read_metadata()

	for i in range(0, len(titles)):
		title = titles[i]
		url = urls[i]
		get_html(url, title)
		data = get_data_from_html(title)
		write_to_csv(data, title)
		print "\nDone!"

main()