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



