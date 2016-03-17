#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
import csv
import re 

with open("amsAllIssues.csv", "r") as myfile:
    for line in myfile:
        request = urllib2.Request(line)
        request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
        request.add_header('Content-Type','application/json')
        response = urllib2.urlopen(request)
        soup = BeautifulSoup(response.read(), 'html.parser') # beautifulsoup is the htmlparser used to dig in the html page.
        a_name=soup.body.find('h2',attrs={'class':'left'})
         
