import json
import re
import csv
import sys

import os

for filename in os.listdir(os.getcwd() + "/xray/"):

    print "processing " + filename

    moviename = filename.split("-xray.json")[0]
    resultfilename = moviename + "-data.csv"

    with open("xray/" + filename) as data:
        data = json.load(data)

    scenes = data['page']['sections']['left']['widgets']['widgetList']
    scenes = scenes[0]['widgets']['widgetList'][1]['partitionedChangeList']

    with open("data/" + resultfilename, 'wb') as out:
        w = csv.writer(out)
        w.writerow(['character', 'start', 'end'])
        for s in scenes:
            start = s['timeRange']['startTime']
            end = s['timeRange']['endTime']
            for init in s['initialItemIds']:
                rd = re.search('/name/(nm.+)/(.+)', init)
                if rd is not None:
                    w.writerow([rd.group(2), start, end])
            for item in s['changesCollection']:
                rd = re.search('/name/(nm.+)/(.+)', item['itemId'])
                if rd is not None:
                    iStart = item['timePosition']
                    w.writerow([rd.group(2), iStart, end])
