#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
import csv


baseurl = "http://archaeologydataservice.ac.uk/archives/view/amphora_ahrb_2005/character.cfm?id="

print("id,rim_type,rt_comment,shoulder_type,st_comment,handles_profile,hp_comment,handle_section,hs_comment,neck_type,nt_comment,body_type,bdt_comment,base_type,bst_comment,capacity,height,width,rim_diameter,fabric")
for i in range(500):
    url = baseurl + str(i)
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    request.add_header('Content-Type','application/json')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response.read(), 'html.parser')
    elt=str(i)
    for t in  soup.body.find_all('td', attrs={'class':'dets'}):
        for e in t.contents:
            if e.string and len(e.string) > 3 and e.name != "span" : 
                elt=elt+",\""+e.string.encode("utf-8").strip()+"\""
    if(len(elt.strip())>4):print(elt)
        #print(str(len(t.contents)))
        #att_name = t.find('a')
        #att_type = t.find('span', attrs={'class':'bbi'})
        #if att_name : print(att_type.text + ':' + att_name.text)
    
