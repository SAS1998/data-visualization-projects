import json
import re
import csv
import sys

filename = sys.argv[1]

moviename = filename.split("-xray.json")[0]
resultfilename = moviename + "-data.csv"

with open(filename) as data:
    data = json.load(data)

scenes = data['page']['sections']['left']['widgets']['widgetList']
scenes = scenes[0]['widgets']['widgetList'][1]['partitionedChangeList']

with open(resultfilename, 'wb') as out:
    w = csv.writer(out)
    w.writerow(['nconst', 'character', 'start', 'end'])
    for s in scenes:
        start = s['timeRange']['startTime']
        end = s['timeRange']['endTime']
        for init in s['initialItemIds']:
            rd = re.search('/name/(nm.+)/(.+)', init)
            if rd is not None:
                w.writerow([rd.group(1), rd.group(2), start, end])
        for item in s['changesCollection']:
            rd = re.search('/name/(nm.+)/(.+)', item['itemId'])
            if rd is not None:
                iStart = item['timePosition']
                w.writerow([rd.group(1), rd.group(2), iStart, end])