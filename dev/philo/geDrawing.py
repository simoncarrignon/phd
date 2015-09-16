#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
from urllib import urlretrieve



baseurl = "http://archaeologydataservice.ac.uk/archives/view/amphora_ahrb_2005/drawings.cfm?id="

for i in range(380):
    url = baseurl + str(i)
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    request.add_header('Content-Type','application/json')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response.read(), 'html.parser')
    imgContainer =soup.body.find("div",attrs={'class':'imgdraw'}) 
    if imgContainer:
        image = imgContainer.findAll("img")[0]
        print("http://archaeologydataservice.ac.uk/"+image["src"])
        print(image["alt"])
        urlretrieve("http://archaeologydataservice.ac.uk/"+image["src"],"img/"+str(i)+".jpg")
