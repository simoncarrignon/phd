import csv
import sys
from bs4 import BeautifulSoup
import urllib,urllib2
import geopy,geopy.distance 
from optparse import OptionParser


#get_html return the html code of a given page with adresse: url 
def get_html(url):
    request = urllib2.Request(url)
    request.add_header('User-Agent','Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)')
    request.add_header('Content-Type','')
    response = urllib2.urlopen(request)
    return(response)

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",
                          help="write report to FILE", metavar="FILE")

(options, args) = parser.parse_args()
filename=options.filename
rootname=filename.split('.')[0]

f = open(filename, 'r')
csvfile=csv.DictReader(f,delimiter=",")
output=",".join(csvfile.fieldnames)+",lon,lat\n"

for row in csvfile:
    place=""
    place=row["Localisation"]
    print(place)
    while True:
        try:
            geolocator = geopy.Nominatim()
            location = geolocator.geocode(place)
            print("here")
            break
        except :
            e = sys.exc_info()[0]
            if e == geopy.exc.GeocoderQueryError:
                break
            print("fail"+str(e))
            pass
    if(location is not None ):
        for i in csvfile.fieldnames:
           output=output+row[i]+","
        output=output+str(location.latitude)+","+str( location.longitude)+"\n"

of = open(""+rootname+"-loc.csv", 'w')
of.write(output)
of.close


