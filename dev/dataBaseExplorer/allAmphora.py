import urllib
import requests
import xml.dom.minidom

user_agent = {
'User-Agent': 'Mozilla/5.0',
'Accept':'text/html,application/xml'
}

prefix='PREFIX : <http://www.semanticweb.org/ontologies/2015/1/EPNet-ONTOP_Ontology#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX dcterms: <http://purl.org/dc/terms/>'



#sparql = 'select ?t_name ?pl_name ?lon ?lat where { ?x rdf:type :Amphora . ?x :hasAmphoricType ?t . ?t dcterms:title ?t_name . ?x :hasFindingPlace ?fp . ?fp :fallsWithin ?pl . ?pl dcterms:title ?pl_name. ?pl :hasLongitude ?lon . ?pl :hasLatitude ?lat}'

for i in range(0,10000):
    sparql= 'select  distinct ?t_name ?pl_name ?t ?lon ?lat where {?x rdf:type :Amphora . ?x :hasFindingPlace ?y . ?y :fallsWithin ?fw . ?fw dcterms:title ?pl_name . ?fw :hasLongitude ?lon . ?fw :hasLatitude ?lat . ?x :carries ?z . ?z :isTranscribedBy ?u . ?u :hasTranscription ?t . ?x :hasAmphoricType ?ty . ?ty dcterms:title ?t_name } limit 100 offset ' + str(i*100)
    #  
    query=urllib.quote(prefix+sparql)
    
    r=requests.get("http://136.243.8.213:8080/openrdf-sesame/repositories/epnet_pleiades_edh?query="+query,headers=user_agent)
    fort_pars=""
    try:
        fort_pars=xml.dom.minidom.parseString(r.content)
    except:
        pass
    
    if fort_pars != "":
        for result in fort_pars.getElementsByTagName("result"):
            n=0
            res=""
            for amphora in fort_pars.getElementsByTagName("literal"):
                if amphora.childNodes[0]:
                    amph_style = amphora.childNodes[0].data
                else:
                    print "error"
                    print amphora
                if n <= 2:
                    res= res +"\""+urllib.unquote(amph_style).encode('utf-8')+ "\"," 
                else:
                    res=res+urllib.unquote(amph_style).encode('utf-8')+","
                if n<4:
                    n=n+1
                else : 
                    n = 0
                    print res
                    res=""
         
