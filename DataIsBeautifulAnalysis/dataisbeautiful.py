import csv
import praw
import sys
import requests

column_names = [
    'created_utc',
    'num_comments',
    'domain',
    'score'
]


"""
"""
def use_praw(subreddit):

    # Get data from Reddit
    reddit = praw.Reddit('default', user_agent='Subreddit Data Extraction (by /u/yaylindadev)')

    print('[use_praw] Obtaining submissions from /r/' + subreddit + '...')

    data = []
    for submission in reddit.subreddit(subreddit).hot(limit=100000):
        datum = {}
        datum[column_names[0]] = submission.created_utc
        datum[column_names[1]] = submission.num_comments
        datum[column_names[2]] = submission.domain
        datum[column_names[3]] = submission.score
        data.append(datum)

    print('Obtained ' + str(len(data)) + ' data points.')

    # Write data to CSV
    write_to_csv(subreddit, data)


"""
"""
def use_pushshift(subreddit):

    print('[use_pushshift] Obtaining submissions from /r/' + subreddit + '...')

    url_template = 'https://api.pushshift.io/reddit/search/submission?subreddit=%s&before=%sd&after=%sd&size=1000'
    data = []

    for i in range(0,100):

        url = url_template % (subreddit, str(i), str(i+1))

        r = requests.get(url)
        
        data_per_day = 0
        for submission in r.json()['data']:
            datum = {}
            for col_name in column_names:
                datum[col_name] = submission[col_name]
            data.append(datum)
            data_per_day = data_per_day + 1

        print('Obtained %s data points [before=%sd] [after=%sd]' % (str(data_per_day), str(i), str(i+1)))

    # Write data to CSV
    write_to_csv(subreddit, data)

"""
"""
def write_to_csv(subreddit, data):
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
            datum[column_names[3]]
        ])

    csv_file.close()
    print('Done!')


"""
"""
if __name__ == "__main__":

    if sys.argv[1] == 'praw':
        use_praw(sys.argv[2])
    elif sys.argv[1] == 'push':
        use_pushshift(sys.argv[2])
    else:
        print('Invalid value:', sys.argv[1])















