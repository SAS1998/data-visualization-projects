import sys
import mailbox
import datetime
import pytz
from pytz import timezone
import csv
import re

mbox = mailbox.mbox('gmail.mbox')

for i in range(0, 1):
	print mbox[i]