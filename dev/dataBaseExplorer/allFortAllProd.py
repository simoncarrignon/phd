import urllib
import requests
import xml.dom.minidom

place="Xanten"
user_agent = {
'User-Agent': 'Mozilla/5.0',
'Accept':'text/html,application/xml'
}

prefix='PREFIX : <http://www.semanticweb.org/ontologies/2015/1/EPNet-ONTOP_Ontology#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX dcterms: <http://purl.org/dc/terms/>'



#sparql='select * where { ?pl rdf:type :LegionaryFort } '

#All Legionnary Fort
sparql='select distinct ?pl_name ?lon ?lat where { ?pl rdf:type :Place . ?pl dcterms:title ?pl_name . ?pl :hasLocationType ?loct . ?loct rdf:type :LegionaryFort . ?pl :hasLongitude ?lon . ?pl :hasLatitude ?lat}'


#All amphora de camp militaire avec un lieu de production
#sparql='select ?t_name ?d_name ?fp_name  where { ?x rdf:type :Amphora .  ?x :hasAmphoricType ?t . ?t dcterms:title ?t_name . ?x :hasProductionPlace ?d . ?d dcterms:title ?d_name . ?x :hasFindingPlace ?fp  . ?fp dcterms:title ?fp_name }'


query=urllib.quote(prefix+sparql)


r=requests.get("http://136.243.8.213:8080/openrdf-sesame/repositories/epnet_pleiades_edh?query="+query,headers=user_agent)


#print r.content 

xpars=xml.dom.minidom.parseString(r.content)

for fort in xpars.getElementsByTagName("result"):
    n=0
    res=""
    for lit in fort.getElementsByTagName("literal"):
            place = urllib.unquote(lit.childNodes[0].data).encode('utf-8')
            if n==0 : res= "\""+place+"\""
            else : res = res + "," + place
            n=n+1
            #production site name
            #sparql = 'select ?ps_name where { ?x rdf:type :Amphora . ?x :hasProductionPlace ?ps . ?ps dcterms:title ?ps_name . ?x :hasFindingPlace ?fp . ?fp :fallsWithin ?pl . ?pl dcterms:title "'+place+'"}'
            #Amphoratype
            sparql = 'select ?t_name where { ?x rdf:type :Amphora . ?x :hasAmphoricType ?t . ?t dcterms:title ?t_name . ?x :hasFindingPlace ?fp . ?fp :fallsWithin ?pl . ?pl dcterms:title "'+place+'"}'
            query=urllib.quote(prefix+sparql)
            r=requests.get("http://136.243.8.213:8080/openrdf-sesame/repositories/epnet_pleiades_edh?query="+query,headers=user_agent)
            fort_pars=""
            try:
                fort_pars=xml.dom.minidom.parseString(r.content)
            except:
                pass
            if fort_pars != "":
                for amphora in fort_pars.getElementsByTagName("literal"):
                    amph_style = amphora.childNodes[0].data
                    #res = res + "," +  urllib.unquote(amph_style).encode('utf-8')
                    print "\""+urllib.unquote(amph_style).encode('utf-8')+ "\",\"" +  place+"\""
    
