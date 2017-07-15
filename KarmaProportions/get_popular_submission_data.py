import praw
import csv
import os

def get_karma_from_redditor(redditor):
    link_karma = int(redditor.link_karma)
    comment_karma = int(redditor.comment_karma)
    total_karma = link_karma + comment_karma
    link_karma_percent = link_karma*100.0/total_karma
    comment_karma_percent = comment_karma*100.0/total_karma
    
    karma = {}
    karma['total'] = total_karma
    karma['link'] = link_karma
    karma['comment'] = comment_karma
    karma['link_percent'] = link_karma_percent
    karma['comment_percent'] = comment_karma_percent

    return karma

def is_submission_new(id):
    return not (os.path.isfile('submission-data/' + id + '.txt'))


def write_new_submission(id, subreddit, score, num_comments, redditor, karma):
    file = open('submission-data/' + id + '.txt', 'w')
    file.write(id + '\n')
    file.write()
    file.close()
    return

def main():
    # using praw.ini file
    reddit = praw.Reddit()

    popular_subreddit = reddit.subreddit('popular')

    for submission in popular_subreddit.hot(limit=2):
        id = submission.id
        print(id)

        if is_submission_new(id):

            subreddit = submission.subreddit.display_name
            print(subreddit)

            score = int(submission.score)
            print(score)

            redditor = submission.author
            redditor_name = redditor.name
            print(redditor_name)

            karma = get_karma_from_redditor(redditor)
            print(karma)

            write_new_submission(id, subreddit, redditor_name, score, karma)
            

main()
