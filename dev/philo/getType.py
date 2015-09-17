#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
import re
from urllib import urlretrieve



baseurl = "http://archaeologydataservice.ac.uk/archives/view/amphora_ahrb_2005/details.cfm?id="

for i in range(380):
    url = baseurl + str(i)
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response.read(), 'html.parser')

    p=re.compile('\Woil\W',re.IGNORECASE )
    oil=p.findall(soup.prettify())
    p=re.compile('\Wwine\W',re.IGNORECASE )
    wine=p.findall(soup.prettify())
    print str(i)+","+str(len(oil))+","+str(len(wine))
    #oil =soup.body.find_all(string=re.compile('^.*oil.*$'))
    #wine =soup.find_all(text="e")

