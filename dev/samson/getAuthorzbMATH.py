#!/usr/bin/python
import webbrowser
import urllib
import urllib2
import cookielib


cookiejar = cookielib.CookieJar()
urlOpener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookiejar))
urlOpener.addheaders=[('User-agent', 'Mozilla/5.0')]

#ck = cookielib.Cookie(version=0, name='ezproxy', value='RzrXGf4iwcY6Kft', port=None, port_specified=False, domain='.math-info-paris.cnrs.fr', domain_specified=False, domain_initial_dot=False, path='/', path_specified=True, secure=False, expires="Session", discard=True, comment=None, comment_url=None, rest={'HttpOnly': None}, rfc2109=False)
#cookiejar.set_cookie(ck)

print "cookieeeees"
for cookie in cookiejar:
    print cookie.name

#Fonction pour se logger
def zbMathLogin():
    webIdDef="scarri26"
    passwordDef="sy66ka"
    loginURL=zbMath+"login.php?WAYF=p7"


    req=urllib2.Request(loginURL)
    res=urlOpener.open(req)
    page=res.read()
    print page
    print "cookieeeees"
    for cookie in cookiejar:
        print cookie.name


    webId=raw_input("identifiant P7 (default:"+webIdDef+", blank to keep default value) :\n")
    password=raw_input('Password (blank to keep default value):\n')
    if webId == "" : webId = webIdDef
    if password == "" : password = passwordDef
    values = {
             'user':webId,
             'pass':password
             }
    data = urllib.urlencode(values)
    req=urllib2.Request(loginURL,data)
    res=urlOpener.open(req)
    
    page=res.read()
    print page
    print "cookieeeees"
    for cookie in cookiejar:
        print cookie.name
    


###########Programme principal

zbMath="https://ezpauth.math-info-paris.cnrs.fr/"

defaultJournal="american+journal+of+mathematics"
defaultPubYears="1878-1920"
page=0

param='?page='+str(page)+'&q=so:"'+defaultJournal+'"+py:"'+defaultPubYears+'"'
print param
req=urllib2.Request(zbMath+param)
print zbMath+param

try:
    res=urlOpener.open(req)
    data=res.read()
    print data
except urllib2.HTTPError,e :
    if e.code == 403 :
        print "Il faut se logger:"
        zbMathLogin()
    else :
        "bug dans la matrix"

for cookie in cookiejar:
    print "aprescookie"
    print cookie.name
res=urlOpener.open(req)
data=res.read()
print data





