library(mapdata)
library(scales) #package for easy "alpha" color

allS=read.csv("../allStamps.csv",header=F)

map("worldHires",".",  col="gray95", fill=TRUE,xlim=c(-16,50),ylim=c(20,60),mar=c(0,0,0,0))#Map background

points(allS[,4],allS[,5],pch=20,cex=1,col=alpha("black", 1)) #add all point we have in light gray (the second argument in alpha() is used to adjust transparency of the color)


qcr=allS[grep("Q.{0,1}C.{0,1}R",allS$V3),] #select some particular inscription 
pnn=allS[grep("P.{0,1}N.{0,1}N",allS$V3),]
points(qcr[,4],qcr[,5],pch=20,cex=1,col=alpha("yellow", 0.3)) #plot the selected inscription in the map
points(pnn[,4],pnn[,5],pch=20,cex=1,col=alpha("red", 0.3))

#Transform une table() en data fram fait automatiquement lse ocuples ce qui est pas mal non? pour le topic model
j=i
i=j[j$Freq == 664,]
points( as.numeric(as.character(i$V4)), as.numeric(as.character((i$V5))),pch=20,cex=i$Freq/500,col=alpha("red",.4))

dev.off()

