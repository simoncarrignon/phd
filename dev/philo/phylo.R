fun <- function(){
library(ape)
library(phangorn)
MPR
letters
tr <- read.tree(text = "(((i,j)c,(k,l)b)a,(h,g)e,f)d;")
x <- c(1, 3, 0, 6, 5, 2, 4)
names(x) <- letters[6:12]
o <- MPR(x, tr, "f"))
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

phylDist <- function(a,b,data){
    ei=data[data$a_name == a,]
    ej=data[data$a_name == b,]
    res =
    base_type[ei$base_type,ej$base_type]+
    shoulder_type[ei$shoulder_type,ej$shoulder_type]+
    rim_type[ei$rim_type,ej$rim_type]+
    neck_type[ei$neck_type,ej$neck_type]+
    handle_section[ei$handle_section,ej$handle_section]+
    handles_profile[ei$handles_profile,ej$handles_profile]+
    body_type[ei$body_type,ej$body_type] +
    abs(ei$height_mean-ej$height_mean)
#    print((ei$height_mean-ej$height_mean))
    return(res)
}

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
clusDendro=as.dendrogram(hclust(as.dist(rese)))
clusDendro<-dendrapply(clusDendro, colLab)


plot(1,1,ylim=c(1,res[1]),xlim=c(1,res[2]),asp=1,type='n',xaxs='i',yaxs='i',xaxt='n',yaxt='n',xlab='',ylab='',bty='n')


pdf("circle.pdf",height=20,width=20)
u=circlize_dendrogram(mymat,labels_track_height=.4)
scale=2000
rasterImage(jpg,0,.8,res[2]/scale,.8+res[1]/scale)


dev.off()

u
