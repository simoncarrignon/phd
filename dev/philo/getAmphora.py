import urllib
import requests
import xml.dom.minidom

user_agent = {
'User-Agent': 'Mozilla/5.0',
'Accept':'text/html,application/xml'
}

prefix='PREFIX : <http://www.semanticweb.org/ontologies/2015/1/EPNet-ONTOP_Ontology#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX dcterms: <http://purl.org/dc/terms/>'


filname="lpname.txt"

with open(filname, "r") as myfile:
     for line in myfile:
           place = line.rstrip()
           #SPARQL request to send to guillem API
           sparql = 'select ?t_name where { ?x rdf:type :Amphora . ?x :hasAmphoricType ?t . ?t dcterms:title ?t_name . ?x :hasFindingPlace ?fp . ?fp :fallsWithin ?pl . ?pl dcterms:title '+place+'}'
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
                for amphora in latpars.getElementsByTagName("literal"):
                    amph_style = amphora.childNodes[0].data
                    #res = res + "," +  urllib.unquote(amph_style).encode('utf-8')
                    print "\""+urllib.unquote(amph_style).encode('utf-8')+ "\"," +  place

