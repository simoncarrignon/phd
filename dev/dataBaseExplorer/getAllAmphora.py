import urllib
import requests
import xml.dom.minidom

user_agent = {
'User-Agent': 'Mozilla/5.0',
'Accept':'text/html,application/xml'
}

prefix='PREFIX : <http://www.semanticweb.org/ontologies/2015/1/EPNet-ONTOP_Ontology#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX dcterms: <http://purl.org/dc/terms/>'




#The SPARQL query to request all amphora with coordinate.
sparql = 'select  ?pl_name ?t ?lon ?lat where {?x rdf:type :Amphora . ?x :hasFindingPlace ?y . ?y :fallsWithin ?fw . ?fw dcterms:title "Rome" . ?fw :hasLongitude ?lon . ?fw :hasLatitude ?lat . ?x :carries ?z . ?z :isTranscribedBy ?u . ?u :hasTranscription ?t .  } limit 100'

#the query to be sent to the API
query=urllib.quote(prefix+sparql)

#r will store the XML answer of the query
r=requests.get("http://136.243.8.213:8080/openrdf-sesame/repositories/epnet_pleiades_edh?query="+query,headers=user_agent)



allAmphoras=""
try:
    allAmphoras=xml.dom.minidom.parseString(r.content)
except:
    pass

if allAmphoras != "":
    for result in allAmphoras.getElementsByTagName("result"):
        n=0
        res=""
        for amphora in allAmphoras.getElementsByTagName("literal"):
            amph_style = amphora.childNodes[0].data
            if n <= 1:
                res= res +"\""+urllib.unquote(amph_style).encode('utf-8')+ "\"," 
            else:
                res=res+urllib.unquote(amph_style).encode('utf-8')+","
            if n<3:
                n=n+1
            else : 
                n = 0
                print res
                res=""
    
