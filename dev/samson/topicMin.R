library(streamgraph)
library(dplyr)

orig=read.csv("alltableur_resNovembre2015.csv") 
#cnpage=read.csv("newcol.csv")
#tabltxt=cbind(orig,cnpage)   

head=read.csv("Mallet/tutorial_keys.txt",sep="\t",header=F)

comp=readCompFile("Mallet/tutorial_compostion.txt")

allBinded=merge(orig,comp,by="Fichier")


allBinded=allBinded[allBinded$Type == "Article",]

stg=prepareFileForStream(allBinded,head,type="Auteur")

streamgraph(stg,"i","V3","j",interpolate="cardinal") %>% sg_axis_x(1, "j", "%Y") %>%
sg_legend(show=TRUE ) 

subsec=allBinded[allBinded$Auteur == "G. A. Miller", 18 : 116]
subsec=allBinded[allBinded$Auteur == "F. N. Cole", 17 : 116]
cole=allBinded[grep("F.*Cole",allBinded$Auteur), 17 : 116]
miller=allBinded[grep("G.*Miller",allBinded$Auteur), ]
wilson=allBinded[grep("E.*Wilson",allBinded$Auteur), ]


nres=c()
for( a  in allBinded$Auteur){
    u=allBinded[allBinded$Auteur == a,18:ncol(allBinded)]
    u=apply(u,1,mean)
    nres=rbind(nres,cbind(a,u))
}

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


readCompFile<-function(comp_file){
    comp=read.csv(comp_file,sep="\t",header=F)
    colnames(comp)[2]="Fichier" 
    colnames(comp)[3:(length(as.character(head$V3))+2)]= as.character(head$V3)
    comp$Fichier=sub("file.*/sansAmsPropre/","",comp$Fichier)
    comp$Fichier=sub("txt","pdf",comp$Fichier)
    return(comp)
}

prepareFileForStream <- function(data,head,type="Année"){

    res=data.frame()
    for(i in head$V3){
	for(j in unique(data[,type])){
	    print(c(i,j))
	    res=rbind(res,cbind(i,j,mean(data[data[,type] == j,i] )))
	}
    }
if(type=="Année")    res$j=as.Date(res$j,format="%Y")
    res$V3=as.numeric(as.character(res$V3))
    return(res)
}

getAuthors <- function(data,head,type="Année"){
    res=data.frame()
	for(j in unique(data$Auteur)){
	    res=rbind(res,t(apply(data[data$Auteur == j,18:ncol(data)],2,mean)))
	}
    rownames(res)=unique(data$Auteur)
    return(res)
}

autMat=getAuthors(allBinded)
distAut=dist(autMat)
ncol(autMat)
	pdf("bigTreeAutheur.pdf",20,20)
	circlize_dendrogram(as.dendrogram(hclust(distAut)))

	dev.off()
	u<-kmeans(autMat,20)
	clusplot(autMat, f$cluster, color=TRUE, shade=TRUE,
		    labels=2, lines=0)
