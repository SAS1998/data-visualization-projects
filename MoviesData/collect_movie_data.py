import os
import csv

def get_html(year):

	print "\tgetting html for movies table..."	

	url_string = "http://www.the-numbers.com/market/<YEAR>/top-grossing-movies"
	url_string = url_string.replace("<YEAR>", str(year))

	os.system("curl " + url_string + " > temp_yearly_movie_data.txt")

def get_data_from_html():

	print "\tparsing html file..."

	file = open("temp_yearly_movie_data.txt")
	content = file.readlines()
	content = [x.strip() for x in content]

	data_block_start_template = "<td class=\"data\"><MOVIE_NUM></td>"
	movie_line_start = "<td><b><a href=\"/movie/"
	release_date_line_start = "<td><a href=\"/box-office-chart/daily/"
	distributor_line_start = "<td><a href=\"/market/distributor/"
	genre_line_start = "<td><a href=\"/market/genre/"
	mpaa_rating_line_start = "<td><a href=\"/market/mpaa-rating/"
	dollar_line_start = "<td class=\"data\">$"
	ticket_line_start = "<td class=\"data\">"

	data_obj_list = []
	movie_num = 1
	current_data = {}
	is_ticket_line = False
	
	for line in content:
		data_block_start = data_block_start_template.replace("<MOVIE_NUM>", str(movie_num))
		if movie_num >= 101:
			break;
		elif line.startswith(data_block_start):
			current_data = {}
			current_data["rank"] = movie_num
		elif line.startswith(movie_line_start):
			movie_name = line.split(movie_line_start)[1].split("\">")[1].split("</b></td>")[0]
			current_data["movie_name"] = movie_name
		elif line.startswith(release_date_line_start):
			release_date = line.split(release_date_line_start)[1].split("\">")[0]
			current_data["release_date"] = release_date
		elif line.startswith(distributor_line_start):
			distributor_name = line.split(distributor_line_start)[1].split("\">")[1].split("</a></td>")[0]
			current_data["distributor_name"] = distributor_name
		elif line.startswith(genre_line_start):
			genre = line.split(genre_line_start)[1].split("\">")[1].split("</td>")[0]
			current_data["genre"] = genre
		elif line.startswith(mpaa_rating_line_start):
			mpaa_rating = line.split(mpaa_rating_line_start)[1].split("-(US)")[0]
			current_data["mpaa_rating"] = mpaa_rating
		elif line.startswith(dollar_line_start):
			is_ticket_line = True
		elif is_ticket_line:
			num_tickets_sold = line.split(ticket_line_start)[1].split("</td>")[0]
			num_tickets_sold = num_tickets_sold.replace(",", "")
			current_data["num_tickets_sold"] = int(num_tickets_sold)
			data_obj_list.append(current_data)
			movie_num += 1
			is_ticket_line = False

	file.close()

	return data_obj_list

def write_movie_data_to_csv(movie_data_list, year):
	print "\twriting to csv file..."
	csv_file = open('movies.csv', 'a')
	csv_writer = csv.writer(csv_file, delimiter=',')
	
	for single_movie_data in movie_data_list:
		csv_writer.writerow([year, single_movie_data['rank'], single_movie_data["movie_name"], single_movie_data["release_date"], single_movie_data["distributor_name"], single_movie_data["genre"], single_movie_data["mpaa_rating"], single_movie_data["num_tickets_sold"]])

	csv_file.close()

def main():
	csv_file = open('movies.csv', 'w')
	csv_writer = csv.writer(csv_file, delimiter=',')
	csv_writer.writerow(['year', 'rank', 'movie_name', 'release_date', "distributor_name", "genre", "mpaa_rating", "num_tickets_sold"])
	csv_file.close()

	for i in range(1994, 2017):
		print "year: " + str(i)
		get_html(i)
		movie_data_list = get_data_from_html()
		print "got " + str(len(movie_data_list)) + " movies for year " + str(i)
		write_movie_data_to_csv(movie_data_list, i)

	print "Done!"

main()