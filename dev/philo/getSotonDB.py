#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
import csv
import re 



baseurl = "http://archaeologydataservice.ac.uk/archives/view/amphora_ahrb_2005/character.cfm?id="

print("id,a_name,rim_type,rt_comment,shoulder_type,st_comment,handles_profile,hp_comment,handle_section,hs_comment,neck_type,nt_comment,body_type,bdt_comment,base_type,bst_comment,capacity,height_min,height_max,width_min,width_max,rim_diameter_min,rim_diameter_max,fabric")
for i in range(380):
    url = baseurl + str(i)
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    request.add_header('Content-Type','application/json')
    response = urllib2.urlopen(request)
    soup = BeautifulSoup(response.read(), 'html.parser')
    a_name=soup.body.find('h2',attrs={'class':'left'})
    if(a_name):
        elt=[str(i)]
        elt.append('"'+a_name.string.encode("utf-8").strip()+'"')
        for t in  soup.body.find_all('td', attrs={'class':'dets'}):
            if(len(t.contents) == 4):
                elt.append('"'+t.contents[3].string.encode("utf-8").strip()+'"')
            if(len(t.contents) == 2):
                elt.append("")
                elt.append("")
            if(len(t.contents) == 6):
                if(t.contents[0].string.encode("utf-8").strip() == "Fabric"): 
                    elt.append('"'+t.contents[3].string.encode("utf-8").strip()+'"')
                else:
                    elt.append('"'+t.contents[2].string.encode("utf-8").strip()+'"')
                    elt.append('"'+t.contents[5].string.encode("utf-8").strip()+'"')
            if(len(t.contents) == 3):
                v=t.contents[2].string.encode("utf-8").strip()
                n=[re.search("[\d.]+",i).group() for i in v.split("-")]
                if(len(n) == 1):
                    elt.extend([n[0],n[0]])
                else:
                    elt.extend(n)
        if(len(elt)>2):print(','.join(elt))
        #for e in t.contents:
        #    if e.string and len(e.string) > 3 and e.name != "span" : 
        #        if e.string.encode("utf-8").strip() == "- To be advised": #Test to verify if the characteristic is not given
        #            elt=elt+",,"
        #        else:
        #            elt=elt+",\""+e.string.encode("utf-8").strip()+"\""
    #if(len(elt.strip())>4):print(elt)
        #print(str(len(t.contents)))
        #att_name = t.find('a')
        #att_type = t.find('span', attrs={'class':'bbi'})
        #if att_name : print(att_type.text + ':' + att_name.text)
    
