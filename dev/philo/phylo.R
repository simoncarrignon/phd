require(circlize)
require(jpeg)
require(dendextend)

############################################
############################################
###Some test to recreate the phylo tree of poterry with maximum of likeklyhood

fun <- function(){
    library(ape)
    library(phangorn)
    MPR
    letters
    tr <- read.tree(text = "(((i,j)c,(k,l)b)a,(h,g)e,f)d;")
    x <- c(1, 3, 0, 6, 5, 2, 4)
    names(x) <- letters[6:12]
    o <- MPR(x, tr, "f")
    dev.off()
    plot(tr)



    nodelabels(paste("[", o[, 1], ",", o[, 2], "]", sep = ""))
    tiplabels(x[tr$tip.label], adj = -2)
    ## some random data:
    x <- rpois(30, 1)
    tr <- rtree(30, rooted = FALSE)
    MPR(x, tr, "t1")
}

phangorntest <- function(){
    typeof(Laurasiatherian)
    lillios=read.phyDat("Lillios_plantilla_Ap1_S1.txt",format="nexus")
    lillios=read.nexus.data("Lillios_plantilla_Ap1_S1.txt")

    con=matrix(nrow=9,data=c(1,0,0,0,0,0,0,0,0,
			     0,1,0,0,0,0,0,0,0,
			     0,0,1,0,0,0,0,0,0,
			     0,0,0,1,0,0,0,0,0,
			     0,0,0,0,1,0,0,0,0,
			     0,0,0,0,0,1,0,0,0,
			     0,0,0,0,0,0,1,0,0,
			     0,0,0,0,0,0,0,1,0,
			     0,0,0,0,0,0,0,0,1))
    dimnames(con)=list(0:8,0:8)
    lil=phyDat(lillios,type="USER",contrast=con)
    dm = dist.logDet(lillios)


    tree = NJ(dm)
    parsimony(tree, Laurasiatherian)
    treeRA <- random.addition(Laurasiatherian)
    treeNNI <- optim.parsimony(tree, Laurasiatherian)
    treeRatchet <- pratchet(Laurasiatherian, start=tree)
    # assign edge length
    treeRatchet <- acctran(treeRatchet, Laurasiatherian)

    plot(midpoint(treeRatchet))
    add.scale.bar(0,0, length=100)

    parsimony(c(tree,treeNNI, treeRatchet), Laurasiatherian)
}
############################################
#initialize transition matric given the data set 
#TODO create a real function to do that knowing that A should be
#	the maximum dataset available

a$ri

rim_type=matrix(nrow=length(unique(a$rim_type)),data=c(0,1,1,1,1,1,1,1,1,1,
						       1,0,1,1,1,1,1,1,1,1,
						       1,1,0,1,1,1,1,1,1,1,
						       1,1,1,0,1,1,1,1,1,1,
						       1,1,1,1,0,1,1,1,1,1,
						       1,1,1,1,1,0,1,1,1,1,
						       1,1,1,1,1,1,0,1,1,1,
						       1,1,1,1,1,1,1,0,1,1,
						       1,1,1,1,1,1,1,1,0,1,
						       1,1,1,1,1,1,1,1,1,0))


colnames(rim_type)=unique(a$rim_type)
rownames(rim_type)=unique(a$rim_type)

shoulder_type=matrix(nrow=length(unique(a$shoulder_type)),data=c(0,1,1,1,
								 1,0,1,1,
								 1,1,0,1,
								 1,1,1,0))
colnames(shoulder_type)=unique(a$shoulder_type)
rownames(shoulder_type)=unique(a$shoulder_type)

handle_section=matrix(nrow=length(unique(a$handle_section)),data=c(0,1,1,1,1,1,1,
								   1,0,1,1,1,1,1,
								   1,1,0,1,1,1,1,
								   1,1,1,0,1,1,1,
								   1,1,1,1,0,1,1,
								   1,1,1,1,1,0,1,
								   1,1,1,1,1,1,0))


colnames(handle_section)=unique(a$handle_section)
rownames(handle_section)=unique(a$handle_section)

handles_profile=matrix(nrow=length(unique(a$handles_profile)),data=c(0,1,1,1,1,1,1,1,1,
								     1,0,1,1,1,1,1,1,1,
								     1,1,0,1,1,1,1,1,1,
								     1,1,1,0,1,1,1,1,1,
								     1,1,1,1,0,1,1,1,1,
								     1,1,1,1,1,0,1,1,1,
								     1,1,1,1,1,1,0,1,1,
								     1,1,1,1,1,1,1,0,1,
								     1,1,1,1,1,1,1,1,0))


colnames(handles_profile)=unique(a$handles_profile)
rownames(handles_profile)=unique(a$handles_profile)

body_type=matrix(nrow=length(unique(a$body_type)),data=c(0,1,1,1,1,1,1,
							 1,0,1,1,1,1,1,
							 1,1,0,1,1,1,1,
							 1,1,1,0,1,1,1,
							 1,1,1,1,0,1,1,
							 1,1,1,1,1,0,1,
							 1,1,1,1,1,1,0))
colnames(body_type)=unique(a$body_type)
rownames(body_type)=unique(a$body_type)

neck_type=matrix(nrow=length(unique(a$neck_type)),data=c(0,1,1,1,1,1,1,
							 1,0,1,1,1,1,1,
							 1,1,0,1,1,1,1,
							 1,1,1,0,1,1,1,
							 1,1,1,1,0,1,1,
							 1,1,1,1,1,0,1,
							 1,1,1,1,1,1,0))
colnames(neck_type)=unique(a$neck_type)
rownames(neck_type)=unique(a$neck_type)

base_type=matrix(nrow=length(unique(a$base_type)),data=c(0,1,1,1,1,1,1,1,1,1,1,1,1,
							 1,0,1,1,1,1,1,1,1,1,1,1,1,
							 1,1,0,1,1,1,1,1,1,1,1,1,1,
							 1,1,1,0,1,1,1,1,1,1,1,1,1,
							 1,1,1,1,0,1,1,1,1,1,1,1,1,
							 1,1,1,1,1,0,1,1,1,1,1,1,1,
							 1,1,1,1,1,1,0,1,1,1,1,1,1,
							 1,1,1,1,1,1,1,0,1,1,1,1,1,
							 1,1,1,1,1,1,1,1,0,1,1,1,1,
							 1,1,1,1,1,1,1,1,1,0,1,1,1,
							 1,1,1,1,1,1,1,1,1,1,0,1,1,
							 1,1,1,1,1,1,1,1,1,1,1,0,1,
							 1,1,1,1,1,1,1,1,1,1,1,1,0))
colnames(base_type)=unique(a$base_type)
rownames(base_type)=unique(a$base_type)
#End matrix intiialization
#####################################################################################################



#computeDist compute a matrix distance between two amphora type
computeDist <- function(data){
    res=matrix(0,length(data$id),length(data$id))
    colnames(res)=data$a_name
    rownames(res)=data$a_name

    for( i in data$a_name){
	for( j in data$a_name){
	    ei=data[data$a_name == i,]
	    ej=data[data$a_name == j,]
	    res[i,j]= phylDist(i,j,data)
	}
    }
    return(res)

}

##Given two amphora name, phylDist compute the distance using the matrix distance previously
#initialized
phylDist <- function(a,b,data){
    ei=data[data$a_name == a,]
    ej=data[data$a_name == b,]
    res =
    (base_type[ei$base_type,ej$base_type]+
     shoulder_type[ei$shoulder_type,ej$shoulder_type]+
     rim_type[ei$rim_type,ej$rim_type]+
     neck_type[ei$neck_type,ej$neck_type]+
     handle_section[ei$handle_section,ej$handle_section]+
     handles_profile[ei$handles_profile,ej$handles_profile]+
     body_type[ei$body_type,ej$body_type])
    #abs(ei$height_mean-ej$height_mean)
    #max(ei$height_mean,ej$height_mean)/min(ei$height_mean,ej$height_mean)
    #   print((ei$height_mean-ej$height_mean))
    return(res)
}

##Colab is used to add colors to label given the body type. Not sure it works, nto sure at all..
##Should see taht again and use the match function maybe
colLab <- function(n){

    labelColors=rainbow(length(unique(allData$body_type)))
    if(is.leaf(n)) {
	a <- attributes(n)
	labCol <- labelColors[allData$body_type[allData$a_name == a$label]]
	print(a$label)
	attr(n, "nodePar") <- c(a$nodePar, lab.col = labCol)

    }
    n
}

#div variable intialisation
div=function(){
clusDendro=as.dendrogram(hclust(as.dist(rese)))
clusDendro<-dendrapply(clusDendro, colLab)


resWithRap = computeDist(allData[allData$height_mean > 0,])
resWithMul = computeDist(allData[allData$height_mean > 0,])


resWithMul2=resWithMul
writeCircleTree(resWithMul,2)
}


##Tentative of function to write a PDF from a matrix distance
#problem : time of computation, and clearly not the best way to do
writeCircleTree <- function(matDist,n=0){
    filname=paste(deparse(substitute(matDist)),".pdf",sep="")
    if(class(matDist) != "dendrogram")
	matDist = as.dendrogram(hclust(as.dist(matDist)))
    pdf(filname,height=20,width=20)
    par(mar=rep(0,4))
    if(n>0)
	circlize_dendrogram(matDist[[n]],labels_track_height=.4  )
    else
	circlize_dendrogram(matDist,labels_track_height=.4  )
    dev.off()
    print(paste("Dendrogram written in:",filname))

}



imageTrain-function(){
    #some training on raster
    pdf("circle.pdf",height=20,width=20)
    u=circlize_dendrogram(mymat,labels_track_height=.4)
    scale=4000
    rasterImage(jpg,0,.8,res[2]/scale,.8+res[1]/scale)

    dev.off()
}



#My circle use circlized and dendextend
#a lot of things to optimize in it but already not so bad
#(one should be able to chooze what kind of visual stuff to add : oil, wine, other things..
myCircle <- function(dend,datas){
    nlab=nleaves(dend)
    rownames(datas)=datas$a_name
    rownames(type)=type$id
    labelToId=as.character(datas[labels(dend),]$id)
    oilCol=type[labelToId,"oil"]
    oilCol[oilCol>0]="#00FF0020"
    oilCol[oilCol==0]="white"
    wineCol=type[labelToId,"wine"]
    wineCol[wineCol>0]="#FF000020"
    wineCol[wineCol==0]="white"

    circos.initialize("dendrogram", xlim = c(0,nlab ))
    max_h=attr(dend,'height')
    circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
		 circos.text(1:nlab-.5, rep(0.2, nlab), labels(dend),facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
     }, bg.border = NA, track.height = .3,track.margin=c(0,0.2),track.index=1)#,bg.col="white")
    circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
		 circos.rect(1:nlab, rep(0, nlab), 1:nlab-1, rep(1,nlab), col = oilCol, border = NA)
     }, bg.border = NA,cell.padding=c(0,0),track.margin=c(0,0),track.height=.02)

    circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
		 circos.rect(1:nlab, rep(0, nlab), 1:nlab-1, rep(1,nlab), col = wineCol, border = NA)
     }, bg.border = NA,track.margin=c(0,0),cell.padding=c(0,0),track.height=.02)
    circos.track(ylim = c(0, max_h), panel.fun = function(x, y) {
		 circos.dendrogram(dend, facing="outside",max_height=max_h) 
     }, bg.border = NA,track.margin=c(0,0),cell.padding=c(0,0))


    scales=6000

    coordinates=polar2Cartesian(circlize(1:(length(labelToId))-.5,rep(0.05,length(labelToId)),track.index=1))

    for( i in 1:length(labelToId)){
	jfile=readJPEG(paste("img/",labelToId[i],".jpg",sep=""))
	res=attr(jfile,'dim')
	coor=coordinates[i,]
	xmin=coor[1]-(res[2]/scales)/2
	ymin=coor[2]-(res[1]/scales)/2
	xmax=coor[1]+(res[2]/scales)/2
	ymax=coor[2]+(res[1]/scales)/2
	strait=polar2Cartesian(circlize(rep(i-.5,2),c(-.2,.5),track.index=1))
	#	points(strait,type="l",lty=2,col="#EEEEEE",lwd=2)
	rasterImage(jfile,xmin,ymin,xmax,ymax)
    }



}

p=" "
myCircle(mymat[[2]][[1]],datatest)




plotImage <- function(){


    p=""


}


###initialise the variable contenaing the presence or not of the word oil or wine in ADS corresponding to the id
type=read.csv("typeId.csv",header=F)
colnames(type)=c("id","oil","wine")
rownames(type)=type$id

##Function copied from source code of cicrlized, useful to transform coordiantes
polar2Cartesian = function(d) {
    theta = as.radian(d[, 1])
    rou = d[, 2]
    x = rou * cos(theta)
    y = rou * sin(theta)
    return(cbind(x, y))
}

as.radian = function(degree) {
    return(degree/180*pi)
}

as.degree = function(radian) {
    return(radian/pi*180)
}
##############



#####
#Some print of some tree
graphPrinting<-function(){
    datatest=allData[allData$height_mean>0,]
    mymatNoDist = as.dendrogram(hclust(as.dist(computeDist(allData))))


    mymatDistance=mymatSin
    pdf("circle-img-h-WithoutG.pdf",height=20,width=20)
    myCircle(mymatDistance[[2]],datatest)
    dev.off()
    pdf("circle-all.pdf",height=20,width=20)
    myCircle(mymatNoDist,allData)
    dev.off()

    dress=allData[grep( "[Dd]ressel", allData$a_name),]
    dresselDist = as.dendrogram(hclust(as.dist(computeDist(dress[dress$height_mean>0,]))))
    pdf("dressel-allSize.pdf",height=7,width=7)
    myCircle(dresselDist,dress[dress$height_mean>0,])
    dev.off()
    oilI=match(type$id[type$oil > 0], allData$id)
    oilI=oilI[!is.na(oilI)]
    oil= allData[oilI,]
    oilDist = as.dendrogram(hclust(as.dist(computeDist(oil[]))))
    pdf("oilAmphora.pdf",height=7,width=7)
    myCircle(oilDist,oil[])
    dev.off()
    wineI=match(type$id[type$wine > 0], allData$id)
    wineI=wineI[!is.na(wineI)]
    wine= allData[wineI,]
    wineDist = as.dendrogram(hclust(as.dist(computeDist(wine[]))))
    pdf("wineAmphora.pdf",height=10,width=10)
    myCircle(wineDist,wine[])
    dev.off()

}
