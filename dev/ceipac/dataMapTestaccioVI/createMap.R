 library(rworldmap)
install.packages ("OpenStreetMap" )
install.packages ("rgdal" )
 library(mapdata)
 library(scales)
 #library(map)
# newmap <- getMap(resolution = "low")
# #Meilleur map:
# map("worldHires",".",  col="gray90", fill=TRUE,xlim=c(-16,50),ylim=c(30,60))

mapMtestatccioVI <- function(){

    	d2000=read.csv("../../ceipac/dataMapTestaccioVI/2000.csv")
    	d2005=read.csv("../../ceipac/dataMapTestaccioVI/2005.csv")
	maxx=max(d2000$lat,d2005$lat)
	minx=min(d2000$lat,d2005$lat)
	maxy=max(d2000$long,d2005$long)
	miny=min(d2000$long,d2005$long)
	pdf("testmap2000-2005.pdf",width=21,height=8)
	map("worldHires","spain",  col="gray90", fill=TRUE,xlim=c(minx-.1*abs(maxx-minx),maxx+.1*abs(maxx-minx)),ylim=c(miny-.1*abs(maxy-miny),maxy+.1*abs(maxy-miny)))

#	map = openmap(c(lat= 38.05025395161289,   lon= -123.03314208984375),
		      			c(lat= 36.36822190085111,   lon= -120.69580078125),
								minNumTiles=9,type="maptoolkit-topo")
	points(d2000$lat,d2000$long,pch=20,cex=.1)
	points(d2000$lat,d2000$long,col=alpha("dark orange",.40),pch=20,cex=1*d2000$n_seillos)
	text(d2000$lat,d2000$long,labels=d2000$lugar)
	points(d2005$lat,d2005$long,pch=20,cex=.1)
	points(d2005$lat,d2005$long,col=alpha("dark green",.40),pch=20,cex=1*d2005$n_seillos)
	text(d2005$lat,d2005$long,labels=d2000$lugar)
	#points(coordinate[,2],coordinate[,3],cex=1.5*d[,amphora]/max(d[,amphora]),pch=20,col="red")
	legend("bottomright",legend=c( "2000","2005"),bg="white",pch=c(20,20),col=c(alpha("dark green",.40),alpha("dark orange",.40)))
	dev.off()

	##MERGE both db
	##Map with legend at the bottom and link between legend and point + possibility to put some of the legende coordinate at end

	m=merge(d2000,d2005,by=c("lugar","long","lat"),suffixes=c(".2000",".2005"),all.x=T,all.y=T)
	maxS=apply(rbind(1*m$n_seillos.2000,1*m$n_seillos.2005),2,max,na.rm=T)

	pdf("testmap2000-2005.pdf",width=14,height=7)
	map("worldHires","spain",  col="gray90", fill=TRUE,xlim=c(minx-.05*abs(maxx-minx),maxx+.05*abs(maxx-minx)),ylim=c(miny-.5*abs(maxy-miny),maxy),mar=c(0,0,0,0))
	plot(water,xlim=c(minx+.5*abs(maxx-minx),maxx-.5*abs(maxx-minx)),ylim=c(miny-.5*abs(maxy-miny),maxy),add=TRUE,col=alpha("dark blue",.40))
	points(m$lat,m$long,pch=20,cex=.1)
	points(m$lat,m$long,col=alpha("dark green",.40),pch=20,cex=1*m$n_seillos.2000)
	points(m$lat,m$long,col=alpha("dark orange",.40),pch=20,cex=1*m$n_seillos.2005)
	#text(m$lat,m$long-(maxS*(maxy-miny)/maxy)/3,labels=m$lugar)
	yinf=miny-.1*abs(maxy-miny)
	latLegend=yinf+(exp((m$long-yinf)/2)-1.03)
	names(latLegend)=m$lugar
	latLegend["Malpica"]=latLegend["Malpica"]+.03
	latLegend["Huertas del Río"]=latLegend["Huertas del Río"]+.02
	latLegend["Haza del Olivo"]=latLegend["Haza del Olivo"]+.035
	latLegend["La María"]=latLegend["La María"]-.03
	latLegend["Las Monjas"]=latLegend["Las Monjas"]+.045
	latLegend["La Corregidora"]=latLegend["La Corregidora"]+.035
	latLegend["Villacisneros"]=latLegend["Villacisneros"]+.10
	latLegend["Arva"]=latLegend["Arva"]+.01
	latLegend["Azanaque-Castillejo"]=latLegend["Azanaque-Castillejo"]-.008
	text(m$lat,latLegend,labels=m$lugar,srt=0,cex=.8)
#m$long*maxS
	segments(m$lat,latLegend+.005,m$lat,m$long-.002,lwd=.008,lty=5)
	legend("bottomright",legend=c( "2000","2005"),bg="white",pch=c(20,20),col=c(alpha("dark green",.40),alpha("dark orange",.40)))
	map.scale(relwidth=.10,cex=.9)
	dev.off()

	water=readShapeLines("~/Downloads/waterways.shp")
	

	seilos=as.matrix(rbind(m$n_seillos.2000,m$n_seillos.2005))
	colnames(seilos)=m$lugar
	pdf("barplotSeillosCiudad.pdf")
	par(mar=c(12,4,4,4))
	barplot(seilos,beside=T,las=3,legend.text=T)
	dev.off()

	library(RgoogleMaps)
	center = c(minx, miny)  #tell what point to center on
	zoom <- 5  #zoom: 1 = furthest out (entire globe), larger numbers = closer in

	terrmap <- GetMap(center=center, zoom=zoom, maptype= "terrain", destfile = "terrain.png") #lots of visual options, just like google maps: maptype = c("roadmap", "mobile", "satellite", "terrain", "hybrid", "mapmaker-roadmap", "mapmaker-hybrid")


}

