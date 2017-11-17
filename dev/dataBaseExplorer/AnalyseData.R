 library(rworldmap)
 library(mapdata)
 library(scales)
 install.packages("mapdata")
 #library(map)
# newmap <- getMap(resolution = "low")
# #Meilleur map:
# map("worldHires",".",  col="gray90", fill=TRUE,xlim=c(-16,50),ylim=c(30,60))

plotMapAmphora<-function(amphora,d){
	plot(newmap, xlim = c(-10, 60), ylim = c(26, 60), asp = 1)#,main=paste("Military Camp where at least \n one \"",amphora,"\" was found"))
	color=d[]
	#color[color>0] = 1
	points(coordinate[,2],coordinate[,3],cex=1.5*d[,amphora]/max(d[,amphora]),pch=20,col="red")
	#points(coordinate[,2],coordinate[,3],col=colorRampPalette(c("white","red"),alpha=.8)(max(color[,amphora]))[(color[,amphora]-max(color[,amphora]))*-1])
}


addAllLink<-function(prodCoord,fortCoord,connexion){

	for( i in 1:nrow(connexion)){
		p_name=as.character(connexion[i,1])
		f_name=as.character(connexion[i,2])
		print (i)
		print (p_name)
		xp=prodCoord[ prodCoord$Lugar == p_name,2]
		yp=prodCoord[ prodCoord$Lugar == p_name,3]
		print(xp)
		print(yp)
		print (f_name)
		xf=fortCoord[ fortCoord$Lugar == f_name,2]
		yf=fortCoord[ fortCoord$Lugar == f_name,3]
		print(xf)
		print(yf)
		if(length(xp) > 0 &&length(yp) > 0 &&length(xf) > 0 &&length(yf) > 0 )
		   segments(x0=yp,y0=xp,x1=yf,y1=xf,col=alpha("grey30",.1))
	}
}


plotall=function(){
	plot(newmap, xlim = c(-10, 35), ylim = c(28, 50), asp = 1,main=paste("Amphora Across Europe"))
	points(ps[,2],ps[,3],col="coral")
	addAllLink(ps,coordinate,connex)
	points(coordinate[,2],coordinate[,3],col="gold")
	legend("topleft",legend=c("Production Site", "Military Camp") ,pch=c(1,1),col=c("coral","gold"))
}


affichage=function(){

	 png("LegionaryFort.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),myborder=0,mar=c(0,0,2,0)) 
 points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
title("Legionnary Fort")
 dev.off()
 png("LegionaryFortAndAmphoras.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
 points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
 points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
title("Legionnary Fort + Amphora")
 dev.off()

 png("LegionaryFortAndProductionSite.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
 points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
 points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
title("Legionnary Fort + Production Place")
 dev.off()

 png("LegionaryFortAndProductionSiteZoom1.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
 points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
 points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
points(mean(ps[,2]),mean(ps[,3]),cex=10,col="red")
title("Legionnary Fort + Production Place")
 dev.off()

 png("LegionaryFortAndProductionSiteZoom2.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
 points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
 points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
points(mean(ps[,2]),mean(ps[,3]),cex=10,col="red")
 points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
title("Legionnary Fort + Production Place + Amphora")
 dev.off()

 png("LegionaryFortAndProductionSiteZoom3.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(min(ps[,2])-1,max(ps[,2])+1),ylim=c(min(ps[,3])-.5,max(ps[,3])+.5),mar=c(0,0,2,0))
  points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
  title("Legionnary Fort + Production Place + Amphora")
   dev.off()

 png("LegionaryFortAndProductionSiteZoom4.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(min(ps[,2])-1,max(ps[,2])+1),ylim=c(min(ps[,3])-.5,max(ps[,3])+.5),mar=c(0,0,2,0))
  points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
   addAllLink(ps,coordinate,connex)
  title("Legionnary Fort + Production Place + Amphora + Network")
   dev.off()

 png("LegionaryFortAndProductionSiteZoom5.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
  points(coordinateB[,2],coordinateB[,3],pch=20,cex=2,col=alpha("orange", 0.3))
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
   addAllLink(ps,coordinate,connex)
  title("Legionnary Fort + Production Place + Amphora + Network")
   dev.off()

 png("LegionaryFortAndProductionOxford1.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
  title("Production Place + Amphora ")
   dev.off()

 png("LegionaryFortAndProductionOxford2.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,2,0)) 
 points(oxolivewine$loclong,oxolivewine$loclat,pch=20,cex=2,col=alpha("green", 0.3))
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
  title("Production Place + Amphora + Oxford Oil-Wine Presses Database")

   dev.off()
 png("LegionaryFortAndProductionOxford3.png",height=800,width=800)
 map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(min(ps[,2])-1,max(ps[,2])+1),ylim=c(min(ps[,3])-.5,max(ps[,3])+.5),mar=c(0,0,2,0))
   points(ps[,2],ps[,3],pch=20,cex=2,col=alpha("red", 0.3))
   points(alladb[,3],alladb[,4],pch=20,cex=.5,col=alpha("black", 0.5))
 points(oxolivewine$loclong,oxolivewine$loclat,pch=20,cex=2,col=alpha("green", 0.3))
  title("Production Place + Amphora + Oxford Oil-Wine Presses Database")
   dev.off()
}

plotNetwork<-function(connexion,city=""){
	inp=connexion[,1]
	out=connexion[,2]
	outWeigth = table(out)
	outWeigth = outWeigth[outWeigth>0]
	inWeigth = table(inp)
	inWeigth = inWeigth[inWeigth>0]
	inPoints=1:length(inWeigth)
	outPoints=1:length(outWeigth)
	input=cbind(inPoints+sort(inWeigth)/2.5,names(inWeigth[order(inWeigth)]))
	output=cbind(outPoints+sort(outWeigth),names(outWeigth[order(outWeigth)]))


	plot(input[,1],rep(1,length(inPoints)),cex=sort(inWeigth)/max(inWeigth)*40,bty="n",ylim=c(-2.2,2),col=alpha("dark green",0.5),pch=20,xaxt="n",xlab="",yaxt="n", ylab="")
	text(input[,1],rep(1.03,length(inPoints))+(sort(inWeigth)/max(inWeigth))/1.4,label=names(inWeigth[order(inWeigth)]),cex=.4,srt=300,c(1,1))
	points(output[,1],rep(-1,length(outPoints)),cex=sort(outWeigth)/max(outWeigth)*40,col=alpha("dark orange",0.5),pch=20)
	text(output[,1],(rep(-1.01,length(outPoints))-(sort(outWeigth)/max(outWeigth))/1.4),label=names(outWeigth[order(outWeigth)]),cex=.4,srt=60,adj=c(1,1))
	text(-10,1,"LH")
	text(-10,-1,"LP")

	cx0=c()
	cy0=c()
	cx1=c()
	cy1=c()

	for( i in 1:nrow(connexion)){
		p_name=as.character(connexion[i,1])
		f_name=as.character(connexion[i,2])
		xp=as.numeric(input[input[,2]==p_name,1])
		yp=1
		xf=as.numeric(output[output[,2]==f_name,1])
		yf=-1
		if(f_name == city){
			cx0=c(cx0,xp)
			cy0=c(cy0,yp)
			cx1=c(cx1,xf)
			cy1=c(cy1,yf)
		}
		else
			segments(x0=xp,y0=yp,x1=xf,y1=yf,col=alpha("black",.1))
	}
	segments(x0=cx0,y0=cy0,x1=cx1,y1=cy1,col=alpha("red",.3),lwd=2)
}


#Les coordonnés doivent etr trié dans l'ordre alphabetique :
plotMapLhLp<-function(lp,lh,lplh){
	map("worldHires",".",  col="gray90", fill=TRUE,xlim=c(-6.5,7.1),ylim=c(37,48))
	tlp=table(lplh$LP)
	for( j in 1:nrow(lp)){
		i = lp[j,]
		points(i$lon,i$lat,col=alpha("dark orange",.40),pch=20,cex=tlp[as.character(i$Lugar)]/max(tlp)*10)
	}
	tlh=table(lplh$LH)
	for( j in 1:nrow(lh)){
		i = lh[j,]
		points(i$lon,i$lat,col=alpha("dark green",.40),pch=20,cex=tlh[as.character(i$Lugar)]/max(tlh)*10)
	}
	legend(-6,44,legend=c( "Lugar de Hallazgo","Lugar de Producción"),bg="white",pch=c(20,20),col=c(alpha("dark green",.40),alpha("dark orange",.40)))

}

plotMapLhLpConLink<-function(lp,lh,lplh){
	map("worldHires",".",  col="gray90", fill=TRUE,xlim=c(-6.5,7.1),ylim=c(37,48))
	tlp=table(lplh$LP)
	for( j in 1:nrow(lp)){
		i = lp[j,]
		points(i$lon,i$lat,col=alpha("dark orange",.40),pch=20,cex=1)
	}
	tlh=table(lplh$LH)
	for( j in 1:nrow(lh)){
		i = lh[j,]
		points(i$lon,i$lat,col=alpha("dark green",.40),pch=20,cex=1)
	}
	legend(-6,44,legend=c( "Lugar de Hallazgo","Lugar de Producción"),bg="white",pch=c(20,20),col=c(alpha("dark green",.40),alpha("dark orange",.40)))

}


cleanLhLp<-function(lhlp){
	lhlp=lhlp[,c(1,2)]
	lhlp=lhlp[lhlp$LH != "",]
	lhlp=lhlp[lhlp$LP != "",]
	lhlp=lhlp[lhlp$LP != "Sevilla",]
	lhlp=lhlp[lhlp$LP != "Itálica",]
	return(lhlp)
}



printRedCity<-function(cities,lhlp){
	for( ciu in cities){
		print(ciu)
		pdf(paste("networkBicouche",ciu,"Red.pdf",sep=""),width=12)
		par(mar=c(0,0,0,0))
		plotNetwork(lhlp,city=ciu)
		dev.off()
	}


}

nobvember2017 <- function(){
		    alladb=unique(read.csv("allAmphoraDBstr.csv"))[,]
		    coordinateB=read.csv("allFortFl.csv")[,]
		    creteCoor=read.csv("placesWithCoordinates.csv")[,]

 png("fortOnly.png",height=630,width=920)
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(coordinateB[,2],coordinateB[,3],pch=20,cex=4,col=alpha("orange", 0.3))
		    	legend("topright",legend=c("legionary fort"),col=c(alpha("orange", 0.3)),bty="o",bg="white",pch=20,pt.cex=c(4))
   dev.off()

 png("stampsOnly.png",height=630,width=920)
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(alladb[,3],alladb[,4],pch=20,cex=2,col=alpha("green",.1))
		    	legend("topright",legend=c("amphora in CEIPAC"),col=c(alpha("green",.3)),bty="o",bg="white",pch=20,pt.cex=c(2))
			dev.off()

 png("fortAndStamps.png",height=630,width=920)
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(coordinateB[,2],coordinateB[,3],pch=20,cex=4,col=alpha("orange", 0.3))
		    	points(alladb[,3],alladb[,4],pch=20,cex=2,col=alpha("green",.1))
		    	legend("topright",legend=c("legionary fort","amphora in CEIPAC"),col=c(alpha("orange", 0.3),alpha("green",.3)),bty="o",bg="white",pch=20,pt.cex=c(4,2,2))
			dev.off()
 pdf("fortOnly.pdf")
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(coordinateB[,2],coordinateB[,3],pch=20,cex=4,col=alpha("orange", 0.3))
		    	legend("topright",legend=c("legionary fort"),col=c(alpha("orange", 0.3)),bty="o",bg="white",pch=20,pt.cex=c(4))
   dev.off()

 pdf("stampsOnly.pdf")
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(alladb[,3],alladb[,4],pch=20,cex=2,col=alpha("green",.1))
		    	legend("topright",legend=c("amphora in CEIPAC"),col=c(alpha("green",.3)),bty="o",bg="white",pch=20,pt.cex=c(2))
			dev.off()

 pdf("fortAndStamps.pdf")
		    	map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))
		    	points(coordinateB[,2],coordinateB[,3],pch=20,cex=4,col=alpha("orange", 0.3))
		    	points(alladb[,3],alladb[,4],pch=20,cex=2,col=alpha("green",.1))
		    	legend("topright",legend=c("legionary fort","amphora in CEIPAC"),col=c(alpha("orange", 0.3),alpha("green",.3)),bty="o",bg="white",pch=20,pt.cex=c(4,2,2))
			dev.off()
}


plot(1:100,1:100,type="l")
