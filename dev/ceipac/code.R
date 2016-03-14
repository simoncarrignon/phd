library(scales)
library(ggplot2)
library(gridExtra)    
library(plyr)
library(MASS)
library(caret)
library(OpenStreetMap)



myData <- read.csv('all.csv', header=T, sep=";")
# only type 2
myData <- subset(myData, TYPE=="2")
# keep just 8 measures and site
myData <- myData[,5:13]


######### EDA #####################
#ggplot(myData, aes(x=exterior_diam, y=rim_w, colour=site)) + geom_point()
# ggplot(myData, aes(x=exterior_diam, fill=site)) + geom_bar() + facet_wrap(~site, ncol=1)
# ggplot(myData, aes(x=rim_w_2, y=protruding_rim, colour=site)) + geom_point() + facet_wrap(~site)

########## PCA #####################

# compute PCA with data transformed to logarithmic to get rid of orders of magnitude
logData <- log(myData[,1:8])
pcaResults <- princomp(logData, center=T, scale=T)

# plot to check the relevance of the first 2 PC'S
plot(pcaResults)

# get the scores of the data
pcaValues <- as.data.frame(pcaResults$scores)
# put type in pcaValues
pcaValues$site <- myData$site

a=ggplot(pcaValues, aes(x=Comp.1, y=Comp.2, col=site)) + geom_point()

# K-means con PCA Values
measures <- pcaValues[,1:2]
# 3 sites
numGroups = 3
myKMeans <- kmeans(measures,numGroups)

amphKMean <- pcaValues
amphKMean$cluster <- myKMeans$cluster
ggplot(amphKMean, aes(x=Comp.1, y=Comp.2, colour=factor(cluster))) + geom_point() + facet_grid(~site) + ggtitle("pca1_2")

amphKMeanCountPCA <- count(amphKMean, vars=c('site','cluster'))

g1 <- ggplot(amphKMeanCountPCA, aes(y=factor(site), x=factor(cluster), label=freq)) + geom_text() + ggtitle("pca1_2")

# K-means con datos originales
measures2 <- myData[,1:8]
numGroups = 3
myKMeans <- kmeans(measures2,numGroups)

amphKMean <- myData 
amphKMean$cluster <- myKMeans$cluster
amphKMeanCountStd <- count(amphKMean, vars=c('site','cluster'))

g2 <- ggplot(amphKMeanCountStd, aes(y=factor(site), x=factor(cluster), label=freq)) + geom_text() + ggtitle("datos originales")
grid.arrange(g1,g2)

############ Discriminant Analysis  ############################

sampleSize = min(count(myData,'site')$freq)

amph1 <- subset(myData, site=="Las Delicias")
sample1 <- amph1[sample(nrow(amph1), sampleSize),]
amph2 <- subset(myData, site=="Malpica")
sample2 <- amph2[sample(nrow(amph2), sampleSize),]
amph3 <- subset(myData, site=="belén")
sample3 <- amph3[sample(nrow(amph3), sampleSize),]

sample <- rbind(sample1,sample2)
sample <- rbind(sample, sample3)

logDataSample <- log(sample[,1:8])
pcaResultsSample <- princomp(logDataSample, center=T, scale=T)

# plot to check the relevance of the first 2 PC'S
#plot(pcaResultsSample)

# get the scores of the data
pcaValuesSample <- as.data.frame(pcaResultsSample$scores)
# put type in pcaValues
pcaValuesSample$site <- sample$site

amphDA <- qda(site~Comp.1+Comp.2, data=pcaValuesSample, prior=c(1,1,1)/3)
predQda <- predict(amphDA, pcaValuesSample)
    
sample$probDelicias<- predQda$posterior[,"Las Delicias"]
sample$probMalpica <- predQda$posterior[,"Malpica"]
sample$probBelen <- predQda$posterior[,"Belén"]
pcaValuesSample$class <- predQda$class

g1 <- ggplot(pcaValuesSample, aes(x=Comp.1, y=Comp.2, colour=factor(class))) + geom_point() + facet_grid(~site) + ggtitle("pca1_2")

ggplot(pcaValuesSample, aes(x=Comp.1, y=Comp.2, col=interaction(site,class), label=site)) + geom_text(size=5) + theme_bw() + theme(legend.position="top")
confusionMatrix(pcaValuesSample$class, pcaValuesSample$site)

correct <- subset(pcaValuesSample, site==class)
incorrect <- subset(pcaValuesSample, site!=class)
correct$predict <- "pred. correcta"
incorrect$predict <- "pred. incorrecta"

result <- rbind(correct, incorrect)
result <- subset(result, Comp.1>-1.2)
result <- subset(result, Comp.2>-2.1)


svg('puntitos.svg', width=15, height=8)    
ggplot(result, aes(x=Comp.1, y=Comp.2, col=site)) + geom_point(size=3) + facet_wrap(~predict, ncol=2) + ggtitle('resultado PCA+DA')
        
dev.off()


svg('fig_dist.svg', width=10, height=10)    
ggplot(result, aes(x=Comp.1, y=Comp.2)) + geom_density2d(aes(col=site), alpha=0.3) + geom_point(aes(col=site), size=2) + facet_wrap(~site, ncol=1) + theme(legend.position='none')
dev.off()


dend=as.dendrogram(hclust(dist(myData[,1:8])))
labels_colors(dend)=colorCode[myData[order.dendrogram(dend),9]]
colorCode=gg_color_hue(3)
gg_color_hue <- function(n) {
      hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
names(colorCode)=levels(result$site)
plot(dend)

    	cities=read.csv("coor.cs")
	maxx=max(cities$lat)
	minx=min(cities$lat)
	maxy=max(cities$long)
	miny=min(cities$long)

	
	meanC1=tapply(result$Comp.1,result$site,mean)
	meanC2=tapply(result$Comp.2,result$site,mean)

	dev.off()
	pdf("map.pdf",width=7,height=7)
	
	library(OpenStreetMap)
	#Random point to plot in the graph
	fdata=cbind.data.frame(runif(12),runif(12),c(rep("A",4),rep("B",4),rep("C",4)))
	colnames(fdata)=c("x","y","city")

	#random coordinate to plot in the map
	cities=cbind.data.frame(runif(3,4.8,5),runif(3,50.95,51),c("A","B","C"))
	colnames(cities)=c("long","lat","name")

	#city to color correspondance
	color=1:length(cities$name)
	names(color)=cities$name


	maxlat=max(cities$lat)
	maxlong=max(cities$long)
	minlat=min(cities$lat)
	minlong=min(cities$long)

	#get some open street map
	map = openmap(c(lat=maxlat+0.02,long=minlong-0.04 ) ,
			c(lat=minlat-0.02,long=maxlong+.04) ,
								minNumTiles=9,type="osm")
	longlat=openproj(map) #Change coordinate projection


	par(mfrow=c(2,1),mar=c(0,5,4,6))
	
	plot( fdata$y ~ fdata$x ,xaxt="n",ylab="Comp.2",xlab="",col=color[fdata$city],pch=20)
	axis(3)
	mtext(side=3,"-Comp.1",line=3)
	par(mar=rep(1,4))

	#plot the map
	plot(longlat,removeMargin=F)
	points(cities$lat ~ cities$long, col= color[cities$name],cex=1,pch=20)
	text(cities$long,cities$lat-0.005,labels=cities$name)

	#sapply(levels(result$site),function(i){points(result$Comp.2[result$site == i] ~ result$Comp.1[result$site == i],pch=20,col=colorCode[i])}) #PAS BESOIN DU sapply!
	#points(meanC2 ~ meanC1 ,col=colorCode[names(meanC2)],cex=5,lwd=2)
#	clusplot(myKMeans$cluster)

	map("worldHires","spain",  col="gray90", fill=TRUE,xlim=c(minx-.1*abs(maxx-minx),maxx+.1*abs(maxx-minx)),ylim=c(miny-.1*abs(maxy-miny),maxy+.1*abs(maxy-miny)),mar=c(0,0,1,0))

	plot(water,xlim=c(minx+.5*abs(maxx-minx),maxx-.5*abs(maxx-minx)),ylim=c(miny-.5*abs(maxy-miny),maxy),add=TRUE,col="dark blue")
	points(cities$lat,cities$long,pch=20,cex=1.2,col=colorCode[cities$name])
	text(cities$lat,cities$long-.005,labels=cities$name)

	map.scale(relwidth=.15,cex=.5)
	dev.off()
#
#	##MERGE both db
#	##Map with legend at the bottom and link between legend and point + possibility to put some of the legende coordinate at end
#
#	m=merge(cities,d2005,by=c("lugar","long","lat"),suffixes=c(".2000",".2005"),all.x=T,all.y=T)
#	maxS=apply(rbind(1*m$n_seillos.2000,1*m$n_seillos.2005),2,max,na.rm=T)
#
#	pdf("testmap2000-2005.pdf",width=14,height=7)
#	map("worldHires","spain",  col="gray90", fill=TRUE,xlim=c(minx-.05*abs(maxx-minx),maxx+.05*abs(maxx-minx)),ylim=c(miny-.5*abs(maxy-miny),maxy),mar=c(0,0,0,0))
#	plot(water,xlim=c(minx+.5*abs(maxx-minx),maxx-.5*abs(maxx-minx)),ylim=c(miny-.5*abs(maxy-miny),maxy),add=TRUE,col="dark blue")
#	points(m$lat,m$long,pch=20,cex=.1)
#	points(m$lat,m$long,col=alpha("dark green",.40),pch=20,cex=1*m$n_seillos.2000)
#	points(m$lat,m$long,col=alpha("dark orange",.40),pch=20,cex=1*m$n_seillos.2005)
#	#text(m$lat,m$long-(maxS*(maxy-miny)/maxy)/3,labels=m$lugar)
#	yinf=miny-.1*abs(maxy-miny)
#	latLegend=yinf+(exp((cities$name-yinf)/2)-1.03)
#	names(latLegend)=m$lugar
#	latLegend["Malpica"]=latLegend["Malpica"]+.03
#	latLegend["Huertas del Río"]=latLegend["Huertas del Río"]+.02
#	latLegend["Haza del Olivo"]=latLegend["Haza del Olivo"]+.035
#	latLegend["La María"]=latLegend["La María"]-.03
#	latLegend["Las Monjas"]=latLegend["Las Monjas"]+.045
#	latLegend["La Corregidora"]=latLegend["La Corregidora"]+.035
#	latLegend["Villacisneros"]=latLegend["Villacisneros"]+.10
#	latLegend["Arva"]=latLegend["Arva"]+.01
#	latLegend["Azanaque-Castillejo"]=latLegend["Azanaque-Castillejo"]-.008
#	text(cities$lat,latLegend,labels=cities$,srt=-1,cex=.8)
##m$long*maxS
#	segments(m$lat,latLegend+.005,m$lat,m$long-.002,lwd=.008,lty=5)
#	legend("bottomright",legend=c( "2000","2005"),bg="white",pch=c(20,20),col=c(alpha("dark green",.40),alpha("dark orange",.40)))
#	dev.off()
#
	water=readShapeLines("~/Downloads/waterways.shp")
#	
#
#	seilos=as.matrix(rbind(m$n_seillos.2000,m$n_seillos.2005))
#	colnames(seilos)=m$lugar
#	pdf("barplotSeillosCiudad.pdf")
#	par(mar=c(12,4,4,4))
#	barplot(seilos,beside=T,las=3,legend.text=T)
#	dev.off()
#
##	library(RgoogleMaps)
##	center = c(minx, miny)  #tell what point to center on
##	zoom <- 5  #zoom: 1 = furthest out (entire globe), larger numbers = closer in
##
#	terrmap <- GetMap(center=center, zoom=zoom, maptype= "terrain", destfile = "terrain.png") #lots of visual options, just like google maps: maptype = c("roadmap", "mobile", "satellite", "terrain", "hybrid", "mapmaker-roadmap", "mapmaker-hybrid")

jordiMars2015<-function(){
	dat=read.csv("DATOS SIMON.csv",sep= ";")
	maxlat=max(dat$lat)
	maxlong=max(dat$long)
	minlat=min(dat$lat)
	minlong=min(dat$long)
	#get some open street map
	map = openmap(c(lat=maxlat+0.02,long=minlong-0.04 ) ,
			c(lat=minlat-0.02,long=maxlong+.04) ,
								minNumTiles=8,type="osm")

dat$citie=sapply(dat$citie,function(x)sub(",.*", "",x))
num=tapply(dat$num,dat$citie,sum)
dat=dat[order(dat$long),]
latO=order(dat$lat)
long=dat$long
lat=dat$lat
names(long)=dat$citie
names(lat)=dat$citie
names(latO)=dat$citie
dat$long[num]
dat$lat[num]

u=unique(dat[,c("lat","long","citie")])

num

	longlat=openproj(map) #Change coordinate projection
	plot(longlat)

	pdf("mapJ2.pdf",width=14,height=7)
	map("worldHires","spain",col="white",fill=TRUE,xlim=c(minlong-0.02,maxlong+.04),ylim=c(minlat-0.02,maxlat+0.04),mar=c(0,0,0,0))
	plot(water,xlim=c(minlong-0.02,maxlong+.04),ylim=c(minlat-0.02,maxlat+0.04),col=alpha("dark blue",.40),lwd=.9,add=T)
	points(long[names(num)],lat[names(num)],cex=1+log(num),col=alpha("dark green",.40),pch=20)
	#xL=eqspace(minlong+.20,maxlong-.20,num)
	#yL=minlat+.03
	#text(xL,yL,seq_along(num),cex=.6)

	#segments(x1=sort(long[names(num)]),y1=lat[names(sort(long[names(num)]))],
	#x0=xL,y0=rep(yL+0.05,length(seq_along(num))),lwd=.3)
	map.scale(y=maxlat-.1,relwidth=.10,cex=.9)

	#segments(x1=xL,y1=yL+.005,
	#x0=xL,y0=rep(yL+0.05,length(seq_along(num))),lwd=.3)
	#legend("bottomright",legend=names(sort(long[names(num)])),pch=as.character(1:49),cex=.5)
	dev.off()

	 write.csv(cbind(seq_along(names(sort(long[names(num)]))),names(sort(long[names(num)]))),"leyenda.csv",row.names=F)



	segments(x1=sort(long[names(num)]),y1=lat[names(sort(long[names(num)]))],
	x0=eqspace(minlong,maxlong,num),y0=rep(minlat,length(seq_along(num))),lwd=.3)

	segments(y1=sort(lat[names(num)]),x1=long[names(sort(lat[names(num)]))],
	y0=eqspace(37.5,37.7,num),x0=rep(maxlong+.01,length(seq_along(num))),lwd=.3)

	
}

eqspace=function(mn,mx,d)seq(mn,mx,(mx-mn)/(length(d)-1))

simpleCode<-function(){
    dat=read.csv("DATOS SIMON.csv",sep= ";")
    maxlat=max(dat$lat)
    maxlong=max(dat$long)
    minlat=min(dat$lat)
    minlong=min(dat$long)
    long=dat$long
    lat=dat$lat
    names(long)=dat$citie
    names(lat)=dat$citie
    num=tapply(dat$num,dat$citie,sum)
    #get some open street map
    map = openmap(c(lat=maxlat+0.02,long=minlong-0.04 ) ,
		  c(lat=minlat-0.02,long=maxlong+.04) ,
		  minNumTiles=8,type="osm")
    longlat=openproj(map) #Change coordinate projection
    plot(longlat)
    points(long[names(num)],lat[names(num)],cex=1+log(num),col=alpha("dark green",.40),pch=20)
    long=dat$long
    lat=dat$lat
    names(long)=dat$citie
    names(lat)=dat$citie
}
