library(scales)
require(maps)

cols=c(rgb(114,159,207,maxColorValue=255),rgb(102,153,0,maxColorValue=255))
names(cols)=c("conso","prod")
    coor=read.csv("test-loc.csv",sep=",")
for(i in 1:4){
    coo=coor[1:i,]
    svg(paste("images/map",i,".svg",sep=""),width=10,height=4,res=300,units="in")
    par(mar=rep(0,4))
    plot(coo$lat,coo$lon,col="red",pch=20,axes=T,ylab="",xlab="",ylim=c(25,50),xlim=c(-125,5))
    rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = alpha("light blue",.7))
    world=map("world",add=T,fill=T,col="white")
    points(coo$lat,coo$lon,bg=cols[coo$Type],col="black",pch=21,cex=3)
    dev.off()
}

coo=coor[coor$Type=="prod",]
    tiff("images/mapProd.tiff",width=10,height=4,res=300,units="in")
    par(mar=rep(0,4))
    plot(coo$lat,coo$lon,col="red",pch=20,axes=T,ylab="",xlab="",ylim=c(25,50),xlim=c(-125,5))
    rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = alpha("light blue",.7))
    world=map("world",add=T,fill=T,col="white")
    points(coo$lat,coo$lon,bg=cols[coo$Type],col="black",pch=21,cex=3)
    dev.off()

coo=coor[coor$Type=="prod",]
    svg("images/mapProd.svg",width=10,height=4)
    par(mar=rep(0,4))
    plot(coo$lat,coo$lon,col="red",pch=20,axes=T,ylab="",xlab="",ylim=c(25,50),xlim=c(-125,5))
    rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = alpha("light blue",.7))
    world=map("world",add=T,fill=T,col="white")
    points(coo$lat,coo$lon,bg=cols[coo$Type],col="black",pch=21,cex=3)
    dev.off()
