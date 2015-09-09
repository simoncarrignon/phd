from bs4 import BeautifulSoup
import urllib2
from HTMLParser import HTMLParser
import csv


class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        print "Encountered a start tag:", 
    def handle_endtag(self, tag):
        print "Encountered an end tag :", tag
    def handle_data(self, data):
        print "Encountered some data  :", data

baseurl = "http://archaeologydataservice.ac.uk/archives/view/amphora_ahrb_2005/character.cfm?id="
parser = MyHTMLParser()

for i in range(10):
    url = baseurl + str(i)
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    request.add_header('Content-Type','application/json')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response.read(), 'html.parser')
    for t in  soup.body.find_all('td', attrs={'class':'dets'}):
        att_name = t.find('a')
        att_type = t.find('span', attrs={'class':'bbi'})
        att_desc = t.text 
        if att_type : print(att_type.text + ':' + att_name.text + att_desc)
    
