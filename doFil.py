import fileinput
import requests
import time
import sys

__all__ = ['fileDownload','getfilename','Replace_line_in_file']

def fileDownload(url,c):
    filename = str(c)# + '.' + url.split('.')[-1] # + '_' + url.split('/')[-1]
    r = requests.get(url, allow_redirects=True)
    f = open("img/" + filename, 'wb')
    f.write(r.content)
    f.close()

def getfilename(url):
    return time.strftime("%Y%m%d%H%M%S") + '.' + url.split('.')[-1]

def Replace_line_in_file(f,searchExp):
    for line in fileinput.input(f, inplace=1):
        if line.decode('utf-8').startswith(searchExp):
            line = "DONE::"+line
        sys.stdout.write(line)
