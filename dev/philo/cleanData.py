import csv
import re, string


def splitMesure(dic,name):
    if dic[name]:
        splitH =dic[name].split("-") 
        res=""
        if len(splitH) == 1:
            res= re.sub('[a-zA-Z_]+', '', splitH[0]).strip()+","+re.sub('[a-zA-Z_]+', '', splitH[0]).strip()
        if len(splitH) == 2:
            res= re.sub('[a-zA-Z_]+', '', splitH[0]).strip()+","+re.sub('[a-zA-Z_]+', '', splitH[1]).strip()
        if len(splitH) == 0:
            res= ","
    else:
        res= ","
    
    return res

def main():
    print('height_min,height_max,width_min,width_max,rim_diameter_min,rim_diameter_max,capacity_min,capacity_max')
    with open('adsDb.csv', 'rb') as csvfile:
        lines = csv.DictReader(csvfile, delimiter=',', quotechar='"')
        for l in lines:
            if l:
                height=splitMesure(l,'height')
                width=splitMesure(l,'width')
                rim_diameter=splitMesure(l,'rim_diameter')
                capacity=splitMesure(l,'capacity')
                print(height+","+width+","+rim_diameter+','+capacity)
                #a=(height,width,rim_diameter)
                #','.join(a)
            
if __name__ == "__main__":
    main()
