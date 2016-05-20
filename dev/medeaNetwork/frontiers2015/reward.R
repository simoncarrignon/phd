######
#Colors definitions
if(require("scales")){library(scales)}
red=alpha("#4dd750",.4)
blue=alpha("#e675ba",.4)
myColors=c(red,blue)
names(myColors)=c("1","0")

reward<-function(g_skill,type,n,b,resourceValue=1,dens=0,tanh=TRUE,...){
    if(type == 0)type=-1
    #reward=(g_skill^n*type+b)*resourceValue*(1-dens)

    if(tanh) {
	#reward=(tanh(b*(g_skill-type*n)*type)+1)/(tanh(b))
	reward=((tanh(b*(g_skill-type*n/100)*type)+1)/(tanh(b)))/2
    }
    else{
	C=(b*exp(n)-exp(-n))/(1-b)
	reward=(exp(n*g_skill*type)+C)/(exp(n)+C)
    }
    reward=reward*resourceValue*(1-dens)
    reward [reward < 0.01 ]=0

    reward[reward > resourceValue] =resourceValue

    return(reward)

}




plotReward<-function(n,b,resourceValue,...){
    g_skill=seq(-1,1,.01)
    par(mar=c(4,5,3,0))
    plot(g_skill,reward(g_skill,1,n,b,resourceValue),type="l",col=myColors["1"],ann=F,cex.axis=1.5,...)
    points(g_skill,reward(g_skill,0,n,b,resourceValue),type="l",col=myColors["0"],...)
    title(main= expression(paste("harvesting capability wrt. " ,g[skill]," value")),xlab=expression(paste("value of ", g[skill])),ylab= expression("maximum amount of harvested energy"),font.main=4,font.lab=4,cex.lab=1.8,cex.main=1.8)


}

