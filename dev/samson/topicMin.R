
subsec=allBinded[allBinded$Auteur == "G. A. Miller", 17 : 116]
subsec=allBinded[allBinded$Auteur == "F. N. Cole", 17 : 116]
cole=allBinded[grep("F.*Cole",allBinded$Auteur), 17 : 116]
miller=allBinded[grep("G.*Miller",allBinded$Auteur), ]
wilson=allBinded[grep("E.*Wilson",allBinded$Auteur), ]

nrow(cole)
plot(c(1,100),c(0,1),type="n")

for( i in 1:nrow(subsec)){
	
    points(1:100,subsec[i,])
}

mwil=apply(wilson,2,mean)
mmil=apply(miller,2,mean)
plot(mwil-mmil,type="l")


abline(v=74,col="red")
points(rep(82,nrow(subsec)),subsec[,82]) 
sort(table(allBinded$Auteur),decreasing=T)[1:20]

head$V3[74]

write.csv(head$V3[c(19,22,13,40)],"wilson")
write.csv(head$V3[c(36,47,72)],"miller")

