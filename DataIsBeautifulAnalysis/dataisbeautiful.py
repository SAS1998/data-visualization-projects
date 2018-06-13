import csv
import praw
import sys

column_names = [
    'created_utc',
    'created',
    'upvotes',
    'num_comments',
    'domain',
    'score'
]

def main(subreddit, plimit=100000):

    # Get data from Reddit
    reddit = praw.Reddit('default', user_agent='Subreddit Data Extraction (by /u/yaylindadev)')

    print('Obtaining top submissions from /r/' + subreddit + '... limit=' + str(plimit))

    data = []
    for submission in reddit.subreddit(subreddit).hot(limit=plimit):
        datum = {}
        datum[column_names[0]] = submission.created_utc
        datum[column_names[1]] = submission.created
        datum[column_names[2]] = submission.ups
        datum[column_names[3]] = submission.num_comments
        datum[column_names[4]] = submission.domain
        datum[column_names[5]] = submission.score
        data.append(datum)

    print('Obtained ' + str(len(data)) + ' data points.')

    # Write data to CSV

    filename = subreddit + '.csv'
    print('Writing data to ' + filename)

    csv_file = open(filename, 'w')
    csv_writer = csv.writer(csv_file, delimiter=',')
    csv_writer.writerow(column_names)
    
    for datum in data:
        csv_writer.writerow([
            datum[column_names[0]], 
            datum[column_names[1]], 
            datum[column_names[2]], 
            datum[column_names[3]], 
            datum[column_names[4]], 
            datum[column_names[5]]
        ])

    csv_file.close()

    print('Done!')


if __name__ == "__main__":

    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        main(sys.argv[1], int(sys.argv[2]))
















