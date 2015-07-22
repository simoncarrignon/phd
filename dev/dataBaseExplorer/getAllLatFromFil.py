import urllib
import requests
import xml.dom.minidom

user_agent = {
'User-Agent': 'Mozilla/5.0',
'Accept':'text/html,application/xml'
}

prefix='PREFIX : <http://www.semanticweb.org/ontologies/2015/1/EPNet-ONTOP_Ontology#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX dcterms: <http://purl.org/dc/terms/>'


filname="places_ML3_dT100.txt"

with open(filname, "r") as myfile:
     for line in myfile:
           place = line.rstrip()
           #SPARQL request to send to guillem API
           sparql = 'select  distinct ?lon ?lat where {?pl rdf:type :Place . ?pl dcterms:title "'+ place +'"  . ?pl :hasLongitude ?lon . ?pl :hasLatitude ?lat  }'

           query=urllib.quote(prefix+sparql)
           r=requests.get("http://136.243.8.213:8080/openrdf-sesame/repositories/epnet_pleiades_edh?query="+query,headers=user_agent)
           latpars=""
           try:
               #xml parsing
               latpars=xml.dom.minidom.parseString(r.content)
           except:
               pass
           if latpars != "":
                #In each result there is on place with the name corresponding 
                for result in latpars.getElementsByTagName("result"):
                    #for each result we look for the coordinate 
                    res=place
                    n=0
                    for coord in result.getElementsByTagName("literal"):
                        n=n+1
                        if n <= 2:
                            res = res+","+urllib.unquote(coord.childNodes[0].data).encode('utf-8')
                        else : 
                            n = 0
                            res=""
                    print res

