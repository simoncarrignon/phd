if(require("lattice")){library(lattice)}
if(require("scales")){library(scales)}
if(require("plyr")){library(plyr)}
if(require("ggplot2")){library(ggplot2)}

######
#Colors definitions
red=alpha("#4dd750",.4)
blue=alpha("#e675ba",.4)
myColors=c(red,blue)
names(myColors)=c("1","0")
ramp=colorRampPalette(c(myColors["1"],myColors["0"]))(1000)

#Plot the value of the gene G_skill for all robot each time they finished their lifetime.
# Dataz should have :
#	a column named GValue, and a column named Iteration
plotG<-function(dataz,sun,gTime,box=F,...){
    if(box==T)	{boxplot(dataz$GValue ~ dataz$Iteration,outline=F,...)}
    else{plot(dataz$GValue ~ dataz$Iteration,...)}
    #abline(v=seq(0,300000,sun*gTime),col="red")
}

getGenomes<-function(file){
    return (read.csv(file,header=F,sep=""))
}

plotAllGenomes<-function(dataz){
    par(mar=c(0,0,0,0),oma=c(0,0,0,0),mfrow=c(length(dataz[1,]),1),ann=F)
    for(i in 1:length(dataz[1,])){
	plot(dataz[,i],col=colors()[i])	
    }
    par(mfrow=c(1,1))

}

#Return a matrix where are stored, for all iteration within a range of resolution, the mean of all energies usesd
createEnergyMatrix<-function(dataz,resol){
    seqIter=seq(0,max(dataz$Iteration),resol);
    res=matrix(0,ncol=3,nrow=length(seqIter))
    rownames(res)=seqIter
    colnames(res)=c("r0","r1","r2")
    for (val in seq(0,max(dataz$Iteration),resol)){
	print(val)
	res[as.character(val),"r0"]=mean(dataz$r0[dataz$Iteration>=val & dataz$Iteration <val+resol])
	res[as.character(val),"r1"]=mean(dataz$r1[dataz$Iteration>=val & dataz$Iteration <val+resol])
	res[as.character(val),"r2"]=mean(dataz$r2[dataz$Iteration>=val & dataz$Iteration <val+resol])
    }
    return(t(res))

}

#Create a heatmatrix with the data from dataz, where you can adjuste the resolution of one dimension (the value of G_{skill}) 
createHeatMatrix<-function(dataz,resol){
    res=matrix(0,nrow=length(unique(dataz$Iteration)),ncol=length(seq(-1,1,resol)))

    rownames(res)=sort(unique(dataz$Iteration))
    colnames(res)=seq(-1,1,resol)
    for ( it in unique(dataz$Iteration)){
	for (val in seq(-1,1,resol)){
	    res[as.character(it),as.character(val)]=nrow(dataz[dataz$Iteration==it & dataz$GValue< val & dataz$GValue >= val-resol,])#/nrow(dataz[dataz$Iteration == it,])

	}
	print(it)

    }
    return(res)
}

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


#plot reward depanding on
plotFunctionDens<-function(n,b,alpha,nrobot,res,...){
    plotReward(n,b,alpha,0/nrobot,ylim=c(0,alpha),ann=F);
    par(new=T)
    harvest=seq(0,nrobot-1,res)
    for(h in harvest){
	plotReward(n,b,alpha,h/nrobot,ylim=c(0,alpha),ann=F,xaxt="n",yaxt="n");
	par(new=T)
    }
    title(main=paste("Reward epending on robot density \n  with n=",n,", b=",b," and alpha=",alpha," (",nrobot,"robots)",sep=""),ylab="Reward",xlab="g_s");
    par(new=F)
    text(rep(-1.05,length(harvest)),reward(-1,0,n,b,alpha,harvest/nrobot),label=harvest,cex=.75)
    text(-1.01,alpha+alpha*0.025,"#harvester")

}

# plot the reopartion of a gene during a run(or a set of run), an the population and a reward function
#If hm is true : the graff with gValue is plotted as a matric, else simple plot.
#Right was an old boolean used to suppress legend on the left (allow somoenoe to reduce the left margin) 
# 
plotGandReward<-function(dataz,active,num=0,right=FALSE,hm=FALSE,res=.1,startCol="white",endCol="dark blue",...){
    #n=unique(dataz$n)/100
    #b=unique(dataz$b)
    defmar=c(5,4,4,2)+.1

    par(mar=c(0,4,4,3)+.1)#set some global var for the graf
    #pch=20 : plot point, not circle

    if(hm){
	layout(mat=matrix(c(1,3,2,4),nrow=2,ncol=2),heights=c(.6,.3),widths=c(.85,.15))

	if(is.matrix(dataz))
	    heatmatrix=dataz
	else{
	    heatmatrix=createHeatMatrix(dataz,res=res)
	}
	image(heatmatrix,col=colorRampPalette(c(startCol,endCol))(10000),xaxt="n",yaxt="n")
	points(seq(0,1,1/(length(getNbSupZero(dataz)-getNbInfZero(dataz))-1)),((getNbSupZero(dataz)-getNbInfZero(dataz))/100+1)/2,type="l",col=endCol,lwd=.5)
	axis(2,seq(0,1,1/(length(seq(-1,1,.1))-1)),seq(-1,1,.1))
	axis(4,seq(0,1,1/(length(c(50,25,0,25,50))-1)),c(50,25,0,25,50),col=endCol)
	title(main=paste("Experience #",num))
	if(right == FALSE){
	    title(ylab="value of g_skill")
	}
	par(mar=c(0,0,4,4)+.1)
	image(t(as.matrix(0:1000)),col=colorRampPalette(c(startCol,endCol))(1000),xaxt="n",yaxt="n")
	mtext("#Robots", side=4, line=3, las=3)

	axis(4,seq(0,1,1/length(1:max(heatmatrix))),0:max(heatmatrix),ylab="#Robot")

    }
    else {
	layout(mat=matrix(c(1,2),nrow=2,ncol=1),heights=matrix(c(.7,.3),nrow=2,ncol=1))
	plotGCol(dataz,xaxt="n",ann=F,pch=21,lwd=.1,...)
	if(right == FALSE){
	    title(ylab="value of g_skill")
	}
	#               points(seq(0,1,1/(length(getNbSupZero(dataz)-getNbInfZero(dataz))-1)),((getNbSupZero(dataz)-getNbInfZero(dataz))/100+1)/2,type="l",col="black",lwd=.5)

    }


    #######
    par(mar=c(5,4,1,3)+.1)

    plot(active[active[,2]>0,2]~ active[active[,2]>0,1],type="l",ylim=c(0,100),ann=F,lab=c(5,2,7),xaxt="n")
    #points((getSd(dataz,gTime)*100)~seq(0,max(dataz$Iteration),gTime),col="yellow",type="l")
    seq=seq(0,150000,50000) 
    axis(1,at=seq,labels=FALSE)

    seq=seq(0,150000,50000) 
    text(seq-4000, par("usr")[3] - 30.5, labels =format(seq,scientific=F), srt = 00,  xpd = TRUE)

    title(main="",xlab="generations")
    if(right == FALSE){
	title(ylab="#active")
    }	
    #######



    #	par(mar=c(8,0,8,4)+.1)
    #	plotReward(n,b,alpha,dens,ann=F,yaxt="n",lwd=3)
    #	axis(4)
    #	title(main=paste("Foraging skill function, \n with : n=",n," and b=",b,sep=""),ylab="ratio",xlab="g_skill")
    #	layout(mat=1)
    #title(main=expression("g_skill"))#repartition des allèles de g_fskill en fonction à chaque itération \n ainsi que fonction de reward))
}

plotGFixedPos<-function(dataz,...){

    layout(mat=matrix(c(1,2),nrow=1,ncol=2),widths=c(.80,.20))
    par(mar=c(5,4,4,2)+.1)#set some global var for the graf
    plot( dataz$Iteration~dataz$At,col=ramp[as.integer(500*(dataz$GValue+1))+1],ann=F,xlim=c(100,900))
    title(xlab="x-coordinate",ylab="generations",main="position of agents and g_skill values")

    par(mar=c(5,0,4,5)+.1,cex.lab=1.3)
    image(t(as.matrix(0:1000)),col=colorRampPalette(c(myColors["0"],myColors["1"]))(1000),xaxt="n",yaxt="n")
    mtext("value of g_skill", side=4, line=3, las=3,cex=1.3)
    axis(4,seq(0,1,1/(length(seq(-1,1,.2))-1)),seq(-1,1,.2),ylab="value of g_skill")

}

plotGCol<-function(dataz,sun,gTime,color=TRUE,...){
    if(color){
	ramp=colorRampPalette(c("red","green"))(1000)
	plotG(dataz,sun,gTime,col=ramp[dataz[,3]],...)
    }	
    else plotG(dataz,sun,gTime,col="black",...)
}

plotG3dFixedDist<-function(dataz,...){
    ramp=colorRampPalette(c(myColors["1"],myColors["0"]))(1000)
    plot3d(dataz$GValue,dataz$Iteration,dataz$At,col=ramp[(dataz$GValue+1)*500])

}


getSd<-function(dataz,res){
    allsd=c()
    iteration=seq(res,max(dataz$Iteration),res)
    for ( range in c(0,iteration)){
	allsd=c(allsd,sd(dataz$GValue[dataz$Iteration>range & dataz$Iteration<= (range+res)]))
    }
    return(allsd)
}

rewardFunM<-function(minN,maxN,b){
    plotReward(1,b,1,0,ylim=c(0,1),ann=F,lwd=.2)
    par(new=T)
    for(i in minN+1:maxN)
    {
	plotReward(i/100,b,1,0,ann=F,xaxt="n",yaxt="n",ylim=c(0,1),lwd=.2);par(new=T)
    }

    plotReward(30,b,1,0,ann=F,xaxt="n",yaxt="n",ylim=c(0,1),lwd=3);par(new=T)
    title(main="F_skill function for different values of n",ylab="Foraging ability",xlab="g_s")
    text(-1.35,reward(-1,1,1,b,1,0),paste("b = ",b,sep=""),lwd=2,font=2,xpd=NA)
    text(c(-.6,-.5),c(reward(-0.6,0,1,b,1,0), reward(-0.5,0,2,b,1,0))+.05,c("n=1","n=2"),cex=.75)
    text(-.4,reward(-0.4,0,3,b,1,0)+.05,"n=3",lwd=2,font=2)

    par(new=F)
}
##############################
##############################

##############################
agregateIteration<-function(dataz,res){
    agreg=c()
    iterationscol=c()
    iterations=seq(0,max(dataz$Iteration),res)
    for(it in iterations){
	for(sim in unique(dataz$Sim)){
	    agreg=c(dataz$GValue[dataz$Sim == sim & dataz$Iteration > it & dataz$GValue < it+res ],agreg)
	    iterationscol=c(it,iterationscol)
	}

    }
    return(cbind(iterationscol,agreg))
}
##############################


##############################
#plot Active 2 ?: don't know why n and b so use the other plotActive
plotActive2<-function(dataz,n,b,res,...){
    boxplot(dataz[dataz[,1]%%res ==0  & dataz[,3] == n &  dataz[,2]>0,2]~dataz[dataz[,1]%%res ==0 & dataz[,3] == n & dataz[,2]>0,1],range=0,...)
}
##############################


##############################
#plot Active : plot agent active each "res" iteration
plotActive<-function(dataz,res=400,...){
    boxplot(dataz[dataz[,1]%%res ==0  &  dataz[,2]>0,2]~dataz[dataz[,1]%%res ==0 & dataz[,2]>0,1],outline=F,range=0,...)
    title(xlab="generations",ylab="#active robots")
}
##############################


drawAllFixed<-function(dataz,width=480,height=500,...){

    for(i in unique(dataz[,4]))
    {
	print(paste("Gfixed_sim",i,".png",sep=""))
	png(paste("Gfixed_sim",i,".png",sep=""),height=height,width=width)
	plotGFixedPos(dataz[dataz[,4]==i,],active[active[,3]==i,],xlimc(0,1000),ylim,c(0,100000),...)
	dev.off()
    }

}



drawAllGraph<-function(dataz,active,width=480,height=480,hm=F,...){

    for(i in unique(dataz$Sim))
    {	
	suff=""
	if(hm){suff="_hm"}
	print(paste("Galive_sim",i,suff,".png",sep=""))
	png(paste("Galive_sim",i,suff,".png",sep=""),height=height,width=width)
	plotGandReward(dataz[dataz$Sim==i,],active[active[,3]==i,],hm=hm,...)
	dev.off()
    }

}

getMaxDuration<-function(dataz,col){
    name=c()
    dur=c()	
    for(i in unique(dataz$Sim)){
	dur=c(dur,max(dataz$Iteration[dataz$Sim ==i]))
	name=c(name,unique(dataz[dataz$Sim==i,col]))
    }
    return (cbind(name,dur))


}

barplotEnergy<-function(dataz,resolution=4000){
    barplot(createEnergyMatrix(dataz,resolution),col=c(myColors["0"],myColors["1"],"black"))
}

#supress simulation ending before the "length"th iteration
supprExtinction<-function(dataz,length=max(dataz$Iteration)){
    return ( dataz[is.element(dataz$Sim,unique(dataz$Sim[ dataz$Iteration >= length])),])
}

#Get percent of non extinction
getGoodRuns<-function(dataz,percent=T){
    cat("###!!be sure to use the active log if results look strange!\n")
    if(percent==T){
	return ( length( unique(dataz$Sim[ dataz$Iteration >= max(dataz$Iteration)] ))/length(unique(dataz$Sim)) )
    }
    else
	return(	length( unique(dataz$Sim[ dataz$Iteration >= max(dataz$Iteration)] )))

}


#Count differents behavioral strategies in the population
countDiffStrat<-function(dataz,resolution=4000){
    seqIter=seq(0,max(dataz$Iteration),resolution)
    res=matrix(0,ncol=5,nrow=length(seqIter))
    rownames(res)=seqIter
    colnames(res)=c("mono specialists","bi specialists","generalists","lazharus","total")
    for (val in seq(0,max(dataz$Iteration),resolution)){
	print(val)
	inresolution=dataz$Iteration>=val & dataz$Iteration <val+resolution
	###
	generalists=length(dataz$Iteration[dataz$r0 > 0 & dataz$r1 >0 & inresolution])
	##
	lazharus=length(dataz$Iteration[dataz$r2 >0 & inresolution])
	###
	bi=0
	mono=0
	for(sim in unique(dataz$Sim)){
	    nbR0=length(dataz$GValue[inresolution & dataz$r0 >0 & dataz$r1 <= 0 & dataz$Sim == sim])  
	    nbR1=length(dataz$GValue[inresolution & dataz$r1 >0 & dataz$r0 <= 0 & dataz$Sim == sim])  
	    if(nbR1 > 0 & nbR0 > 0){
		bi= bi + nbR0 + nbR1 
	    }
	    else{
		if(nbR1==0 || nbR0==0)mono= mono + nbR1 + nbR0
	    }
	    print(sim)
	}
	###	
	#mono=length(dataz$GValue[inresolution & (dataz$r0>0 || dataz$r1>0)])-bi 
	res[as.character(val),"mono specialists"]=mono
	res[as.character(val),"bi specialists"]=bi
	res[as.character(val),"generalists"]=generalists
	res[as.character(val),"lazharus"]=lazharus
	res[as.character(val),"total"]=length(dataz$GValue[inresolution])
	print(res)
    }
    return(t(res))


}

discretize<-function(x,alpha){
    return(as.integer(sqrt(x*x*100*100)/(alpha))*alpha/100*sign(x))
}



countType<-function(dataz){
    test=c()
    for (i in unique(dataz$Sim)){
	print(paste(i))
	test=rbind(test,c(length(dataz$GValue[dataz$Sim == i& dataz$GValue>0]),length(dataz$GValue[dataz$Sim == i& dataz$GValue<0]),length(dataz$GValue[dataz$Sim == i])))
    }
    return(test)
}

countTypePerSparsity<-function(dataz){
    test=c()
    for (e in unique(dataz$Sparsity)){
	print(paste(e))
	for (i in unique(dataz$Sim[dataz$Sparsity == e])){
	    print(paste(i))
	    test=rbind(test,c(length(dataz$GValue[dataz$Sim == i& dataz$GValue>0 & dataz$Sparsity == e]),length(dataz$GValue[dataz$Sim == i& dataz$GValue<0 & dataz$Sparsity == e]),length(dataz$GValue[dataz$Sim == i & dataz$Sparsity == e]),e))
	}
    }
    return(test)
}

countTypePerEnv<-function(dataz){
    test=c()
    for (e in unique(dataz$Env)){
	print(paste(e))
	for (i in unique(dataz$Sim)){
	    test=rbind(test,c(length(dataz$GValue[dataz$Sim == i& dataz$GValue>0 & dataz$Env == e]),length(dataz$GValue[dataz$Sim == i& dataz$GValue<0 & dataz$Env == e]),length(dataz$GValue[dataz$Sim == i & dataz$Env == e]),e))
	}
    }
    return(test)
}

getNbSupZero<-function(dataz){
    return( tapply(dataz$GValue[dataz$GValue>0],dataz$Iteration[dataz$GValue>0],length))
}
getNbInfZero<-function(dataz){
    return( tapply(dataz$GValue[dataz$GValue<0],dataz$Iteration[dataz$GValue<0],length))
}
plotNeachTypeForager<-function(dataz){
    plot(getNbSupZero(dataz))
    points(getNbInfZero(dataz),col="light green")
}


####################################################################################
countClusters<-function(dataz,...){
    bef=-1
    cpt=0
    res=0
    for (r in sort(dataz$At)){
	g=dataz$GValue[dataz$At == r]
	if(g<0 && bef==-1){cpt=cpt+1}	
	if(g<0 && bef==1){cpt=0}
	if(g>0 && bef==1){cpt=cpt+1}
	if(g>0 && bef==-1){cpt=0}
	if(cpt==5){res=res+1}
    }
    return(res)

}


plotAllEnvTwoHeat<-function(){
    for(env in 2){
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/medianAliveTwoHM_env",env,".png",sep=""))
	plotTwoHeatMat(counted,env)
	dev.off()
    }
}

plotAllEnvRatioHM<-function(){
    for(env in 0:4){

	png(paste("/home/simon/evorob/Perso/Simon/doc/images/5StaticEnv/medianRatioHM_env",env,".png",sep=""),width=1000,height=900,res=180)
	print(ggplotRatioHeatMap(counted,env))
	dev.off()

    }
}

ggplotRatioHeatMap<-function(dataz,env,...){
    res=dataz[dataz[,5]==env,]
    res[,1]=(res[,1]+1)/(res[,2]+1)
    res[,1]=round(log10(res[,1]),1);
    res[,1]=10^res[,1]
    #res[is.infinite(res)]=0
    #res=round(res,2);
    #dataz[dataz[,5]==env,4],ylab="log((#R1+1)/(#R2+1))",main=paste("R1/R2 depending on resource repartition for ENV",env,sep=""),ylim=c(0,100),...)
    #plot(res[,1]~res[,4],...)
    res=createHeatMat("V4","V1",as.data.frame(res))
    res.m=melt(res)
    #	res.m$value=exp(res.m$value)/1000
    #	res.m$value=round(res.m$value,2)
    #	res.m=ddply(res.m,.(V4),transform,rescale=rescale(value))
    #res.b=ddply(res.m,.(V4),transform,rescale=scale(value))
    #base_size <- 9
    ggplot(res.m,aes(V4,V1)) + geom_tile(aes(fill = value)) +
    scale_fill_gradient(low = "white",high = "blue") +
    scale_y_log10(expression(frac(harvest(Q[R[1]])+1),(harvest(Q[r0])+1)),col="black") +
    scale_x_continuous(expression(available(Q[R[1]]))) +
    opts(
	 panel.grid.major = theme_blank(),
	 panel.grid.minor = theme_blank(),
	 panel.background = theme_rect(),
	 axis.text.x=theme_text(col="black"),
	 axis.text.y=theme_text(col="black"),
	 plot.margin = unit(c(1,0,0,0), "lines"),
	 title=paste("Resources harvested wrt. availability (ENV",env,")",sep="")
	 )

    #res=createHeatMat("V4","V1",as.data.frame(res))
    #image(res,...)
    #	res=round(res*10,2);

    #	printASlice(res,ylab="log((#R1+1)/(#R2+1))",xlab=("available(Q_r1)"))
    #print(res)
    #return(res.m)	
}
plotRatioHeatMap<-function(dataz,env,...){
    res=dataz[dataz[,5]==env,]
    res[,1]=(res[,1]+1)/(res[,2]+1)
    #	res=round(res,2);
    #dataz[dataz[,5]==env,4],ylab="log((#R1+1)/(#R2+1))",main=paste("R1/R2 depending on resource repartition for ENV",env,sep=""),ylim=c(0,100),...)
    #plot(res[,1]~res[,4],...)
    res=createHeatMat("V4","V1",as.data.frame(res))
    image(res,...)
    #	res=round(res*10,2);

    #	printASlice(res,ylab="log((#R1+1)/(#R2+1))",xlab=("available(Q_r1)"))
    #print(res)

}
expression(available(Q[R[1]]))
plotTwoHeatMat<-function(data,env){
    layout(mat=matrix(c(1,2),nrow=2,ncol=1),heights=matrix(c(.5,.5),nrow=1,ncol=2))

    par(mar=c(0.2,4.1,4.1,2))
    resul=createHeatMat("V4","V1",as.data.frame(data[data[,5]==env,]))
    #	resul=round(resul,2);
    xlab="available(Q_r1)"
    ylab="#active agents"
    cols=c("white",blue)
    yaxs=seq(0,100,20)
    printASlice(resul,"available(Q_r1)","harvest(Q_r1)",c(0.45,1.0),c(-5.50,100.5),cols=c("white","blue"),axes=FALSE)
    axis(2,yaxs)
    box()
    #image(resul,c(0.45,1.0),c(-0.50,100.5),xaxt="n")
    par(mar=c(5.1,4.1,0,2))
    resul=createHeatMat("V4","V2",as.data.frame(data[data[,5]==env,]))
    #	resul=round(resul,2);
    #yaxs=colnames(resul)
    #resul=resul[,sort(colnames(resul),decreasing=T)]
    #colnames(resul)=yaxs
    printASlice(resul,"available(Q_r1)","harvest(Q_r0)",c(0.45,1.0),c(-5.50,100.5),cols=c("white","red"))
    #printASlice(resul,"available(Q_r1)","harvest(Q_r0)",c(0.45,1.0),c(-50.5,55.5),cols=c("white",red),axes=FALSE)
    #axis(2,seq(100,0,-20),at=seq(-50,50,20))
    #axis(1,seq(.5,.95,.1))
    #box()

}

printSomeExemplAllEnv<-function(){

    plotSomeExemple(data3,data3_active,c(5,8,51,99),3)
    plotSomeExemple(data2,data2_active,c(22,66,5,92),2)
    plotSomeExemple(data1,data1_active,c(47,66,29,9),1)
    plotSomeExemple(data0,data0_active,c(59,47,62,58),0)
    plotSomeExemple(data4,data4_active,c(17,40,62,58),4)
}
# data3=read.csv("env3_50_results.csv");data3_active=read.csv("env3_50_logs_active.csv");
# data2=read.csv("env2_50_results.csv");data2_active=read.csv("env2_50_logs_active.csv");
# data1=read.csv("env1_50_results.csv");data1_active=read.csv("env1_50_logs_active.csv");
# data0=read.csv("env0_50_results.csv");data0_active=read.csv("env0_50_logs_active.csv");
# data4=read.csv("env4_50_results.csv");data4_active=read.csv("env4_50_logs_active.csv");

plotQualitative<-function(){
    #LEs data de la bonne forme (en partant du csv fait le 7 octobre 2011:
    dat=t(as.matrix(read.csv("qualitative.csv")))
    res=dat
    res[2,]=dat[2,]/(dat[2,]+dat[3,]+dat[4,])
    res[4,]=dat[4,]/(dat[2,]+dat[3,]+dat[4,])
    res[3,]=dat[3,]/(dat[2,]+dat[3,]+dat[4,])
    res=res[2:4,1:5]
    colnames(res)=paste("ENV",dat[1,],sep="")
    png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/qualitative_distribution.png",height=900,width=900,pointsize=20)
    par(cex.lab=1.7,cex.main=1.8)
    barplot(res,ylab="% of runs",legend=T)
    dev.off()

}


plotSomeExemple<-function(dataz,dataz_active,number,env){

    for (i in number){
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/Gplot",i,"Static_staticEnv",env,".png",sep=""),height=900,width=900,pointsize=20)
	par(cex.lab=1.7,cex.main=1.8)
	plotGFixedPos(dataz[dataz$Sim == i,],lwd=2)
	dev.off()
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/Gplot",i,"_staticEnv",env,".png",sep=""),height=900,width=900,pointsize=20)
	par(cex.lab=1.7,cex.main=1.8)
	plotGandReward(dataz[dataz$Sim == i,],dataz_active[dataz_active$Sim == i,],col=F)
	dev.off()
    }
}


#Return a normalized matrix
createHeatMat<-function(x,y,data){
    res=daply(.variables=c(x,y),.data=data,.fun=function(x)length(x[,1]))
    res[is.na(res)]<-0
    #	res=melt(res)
    #	print(res)
    #	res=ddply(res,.(V4),transform,rescale=rescale(value))
    #	print(res)
    #	res=res
    res=res#/apply(res,1,sum)*100
    return(res)	
}


modMatrix<-function(dataz,mod,l){
    if(l==1)
	return(dataz[as.numeric(rownames(dataz)) %% mod == 0,])
    if(l==2)
	return(dataz[,as.numeric(colnames(dataz)) %% mod == 0])
    else
	print("Dimension incorrect (1 = row, 2 == col)")

}

meanOn2 <- function(dataz,mod,l){


    if(l==1){ 
	eltnames=rownames
	nelt=nrow
	ebind=rbind
    }
    else{ 
	eltnames=colnames
	nelt=ncol
	ebind=cbind
    }

    bmin=min(as.numeric(colnames(dataz)))
    bmax=max(as.numeric(colnames(dataz)))
    len=(bmax-bmin)/mod
    res=c()
    newElt=seq(bmin,bmax,mod)
    for( i in 1:(length(newElt)-1)){
	print(paste(i,newElt[i],newElt[i+1]))
	subd=dataz[,as.numeric(colnames(dataz)) >= newElt[i] & as.numeric(colnames(dataz)) < newElt[i+1] ]
	if(is.null(dim(subd)[2]) )
	    res=cbind(res,rep(0,nrow(dataz)))
	#if(dim(subd) == 1 )
	#    res=cbind(res,subd)
	else
	    res=cbind(res,apply(subd,1,sum))
    }
    subd=dataz[,as.numeric(colnames(dataz)) >= newElt[i+1] ]
    res=cbind(res,subd)
    colnames(res)=newElt[1:(length(newElt))]
    return(res)
}

meanOn<-function(dataz,mod,l){
    if(l==1){
	res =modMatrix(dataz,mod,l)
	n=rep(0,ncol(dataz))
	for ( r in as.numeric(rownames(dataz)) ){
	    print(r)
	    if(r %% mod == 0){
		n=n+dataz[as.numeric(rownames(dataz))==r,]
		res[as.numeric(rownames(res))==r,]=n/mod
		n=rep(0,ncol(dataz))
	    }
	    else n=n+dataz[as.numeric(rownames(dataz))==r,]
	}
    }
    if(l==2){
	res =modMatrix(dataz,mod,l)
	n=rep(0,nrow(dataz))
	for ( r in as.numeric(colnames(dataz)) ){
	    print(r)
	    if(r %% mod == 0){
		n=n+dataz[,as.numeric(colnames(dataz))==r]
		res[,as.numeric(colnames(res))==r]=n/mod
		n=rep(0,nrow(dataz))
	    }
	    else{
		n=n+dataz[,as.numeric(colnames(dataz))==r]
	    }

	}
    }
    return(res)


}

printASlice=function(heatmap,xlab,ylab,xlim,ylim,cols=c("white","black"),...){

    #yscale=as.numeric(colnames(heatmap))
    #xscale=as.numeric(rownames(heatmap))
    #ymin=min(yscale) - (max(yscale)-min(yscale))/length(yscale)*1/2
    #xmin=min(xscale) - (max(xscale)-min(xscale))/length(xscale)*1/2
    #ymax=max(yscale) + (max(yscale)-min(yscale))/length(yscale)*1/2
    #xmax=max(xscale) + (max(xscale)-min(xscale))/length(xscale)*1/2
    #ramp=colorRampPalette(cols)(length(unique(as.vector(heatmap))))
    ramp=colorRampPalette(cols)(10000)
    image(x=sort(as.numeric(rownames(heatmap))),y=sort(as.numeric(colnames(heatmap))),z=heatmap,ylim=ylim,xlim=xlim,col=ramp,xlab=xlab,ylab=ylab,...)
}

printAllSlicesHeatmap<-function(){
    mypar=par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    #alive wrt. density
    for( repa in c(.90,.70,.50)){
	heatMat=createHeatMat("Sparsity","alive",data[data$rep == repa,])
	png(paste("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_density_r1-",repa*100,".png",sep=""),width=900,height=900,pointsize=20);
	par(mypar) 
	printASlice(heatMat,ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0,1))

	dev.off() 
    }	


    #alive wrt available(r1)
    for( spars in c(.60,.080,.02)){
	png(paste("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_r1_density-",spars*100,".png",sep=""),width=900,height=900,pointsize=20);
	heatMat=createHeatMat("rep","alive",data[data$Sparsity >= spars & data$Sparsity < spars+.005,])
	par(mypar) 
	printASlice(heatMat,ylab="#active agents",xlab="available(Q_r1)",ylim=c(-2.5,101.5),xlim=c(0.45,1.05))
	dev.off() 
    }	


    ### 
    #harvest(r1) wrt available(r1)
    for( spars in c(.60,.080,.02)){
	heatMat=data[data$Sparsity >= spars & data$Sparsity < spars+.005,]
	heatMat$r1=heatMat$r1/heatMat$alive
	heatMat$r1=round(heatMat$r1,2)
	heatMat=createHeatMat("rep","r1",heatMat)
	heatMat=round(heatMat,2)
	png(paste("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_r1_density-",spars*100,".png",sep=""),width=900,height=900,pointsize=20);
	par(mypar) 
	printASlice(heatMat,ylab="harvest(Q_r1)",xlab="available(Q_r1)",ylim=c(-.05,01.05),xlim=c(0.45,1.05))
	dev.off() 
    }	

    #harvestr1 wrt. density
    for( repa in c(.90,.70,.50)){
	heatMat=data[data$rep == repa,]
	heatMat$r1=heatMat$r1/heatMat$alive
	heatMat$r1=round(heatMat$r1,2)
	heatMat=createHeatMat("Sparsity","r1",heatMat)
	heatMat=round(heatMat,2)
	png(paste("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-",repa*100,".png",sep=""),width=900,height=900,pointsize=20);
	par(mypar) 
	printASlice(heatMat,ylab="harvest(Q_r1)",xlab="density",ylim=c(-.05,1.05),xlim=c(0,1.))
	dev.off() 
    }	
    #
    ###harvestr1 density
    # png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-90.png",width=900,height=900,pointsize=20);
    #par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    # boxplot(data$r1[ data$rep == .90 & data$Sparsity < .95]/data$alive[ data$rep == .90 & data$Sparsity < .95] ~ data$Sparsity[ data$rep ==.90& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    #dev.off() 
    # png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-70.png",width=900,height=900,pointsize=20);
    #par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    # boxplot(data$r1[ data$rep == .70& data$Sparsity < .95]/data$alive[ data$rep == .70& data$Sparsity < .95] ~ data$Sparsity[ data$rep == .70& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    #dev.off()
    # png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-50.png",width=900,height=900,pointsize=20);
    #par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    # boxplot(data$r1[ data$rep == .50& data$Sparsity < .95]/data$alive[ data$rep == .50& data$Sparsity < .95] ~ data$Sparsity[ data$rep == .50& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    #dev.off()
}
printAllSlices<-function(){
    #alive density
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_density_r1-90.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$rep == .90 & data$Sparsity < .95] ~ data$Sparsity[ data$rep == .90& data$Sparsity < .95],outline=F,xlab="density",ylab="#active agents",ylim=c(0,100) );
    dev.off() 
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_density_r1-70.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$rep == .70& data$Sparsity < .95] ~ data$Sparsity[ data$rep ==.70& data$Sparsity < .95],outline=F,xlab="density",ylab="#active agents",ylim=c(0,100) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_density_r1-50.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$rep == .50& data$Sparsity < .95] ~ data$Sparsity[ data$rep == .50& data$Sparsity < .95],outline=F,xlab="density",ylab="#active agents",ylim=c(0,100) );
    dev.off()

    #alive r1
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_r1_density-60.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$Sparsity >= .6 & data$Sparsity <0.65] ~ data$rep[ data$Sparsity >= .6 & data$Sparsity <0.65],outline=F,,ylab="#active agents",xlab="available(Q_r1)",ylim=c(0,100) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_r1_density-8.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$Sparsity >= .08 & data$Sparsity <0.085] ~ data$rep[ data$Sparsity >= .08 & data$Sparsity <0.085],outline=F,,ylab="#active agents",xlab="available(Q_r1)",ylim=c(0,100) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/alive_r1_density-2.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$alive[ data$Sparsity >= .02 & data$Sparsity <0.025] ~ data$rep[ data$Sparsity >= .02 & data$Sparsity <0.025],outline=F,,ylab="#active agents",xlab="available(Q_r1)",ylim=c(0,100) );
    dev.off()

    #
    ### harvestr1 r1
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_r1_density-60.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$Sparsity >= .6 & data$Sparsity <0.65]/data$alive[ data$Sparsity >= .6 & data$Sparsity <0.65] ~ data$rep[ data$Sparsity >= .6 & data$Sparsity <0.65],outline=F,,ylab="harvest(Q_r1)",xlab="available(Q_r1)",ylim=c(0,1) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_r1_density-8.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$Sparsity >= .08 & data$Sparsity <0.085]/data$alive[ data$Sparsity >= .08 & data$Sparsity <0.085] ~ data$rep[ data$Sparsity >= .08 & data$Sparsity <0.085],outline=F,,ylab="harvest(Q_r1)",xlab="available(Q_r1)",ylim=c(0,1) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_r1_density-2.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$Sparsity >= .02 & data$Sparsity <0.025]/data$alive[ data$Sparsity >= .02 & data$Sparsity <0.025] ~ data$rep[ data$Sparsity >= .02 & data$Sparsity <0.025],outline=F,,ylab="harvest(Q_r1)",xlab="available(Q_r1)",ylim=c(0,1) );
    dev.off()

    ##harvestr1 density
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-90.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$rep == .90 & data$Sparsity < .95]/data$alive[ data$rep == .90 & data$Sparsity < .95] ~ data$Sparsity[ data$rep ==.90& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    dev.off() 
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-70.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$rep == .70& data$Sparsity < .95]/data$alive[ data$rep == .70& data$Sparsity < .95] ~ data$Sparsity[ data$rep == .70& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    dev.off()
    png("~/evorob/Perso/Simon/doc/20111122-Specialisation-Density-Heatmap/images/harvestr1_density_r1-50.png",width=900,height=900,pointsize=20);
    par(cex.axis=1.5,cex.lab=1.7,cex.main=1.7);
    boxplot(data$r1[ data$rep == .50& data$Sparsity < .95]/data$alive[ data$rep == .50& data$Sparsity < .95] ~ data$Sparsity[ data$rep == .50& data$Sparsity < .95],outline=F,,ylab="harvest(Q_r1)",xlab="density",ylim=c(0,1) );
    dev.off()
}

####################################################################################
###############################################################
# Function wich take data frome multi env/multi repartition
#####################
#Conmpte type and return a table you can use with plotMean
countTypePerEnvAndRep<-function(dataz){
    test=c()
    for( env in unique(dataz$Env)){
	for( rep in unique(dataz$Rep)){
	    for (i in unique(dataz$Sim[ dataz$Env == env & dataz$Rep == rep])){
		print(paste(rep,env,i))
		test=rbind(test,c(length(dataz$GValue[dataz$Sim == i& dataz$GValue>0 & dataz$Env == env & dataz$Rep == rep]),length(dataz$GValue[dataz$Sim == i& dataz$GValue<0& dataz$Env == env & dataz$Rep == rep]),length(dataz$GValue[dataz$Sim == i& dataz$Env == env & dataz$Rep == rep]),rep,env))
	    }
	}
    }
    return(test)
}


#plot the mean for all sim depending on the repartion of the resources
# Need a table like #Gvalue>1,#Gvalue<1,#Active,env,rep
plotMeanTotInfSup<-function(dataz,mean=F,box=F){
    plot(dataz[,1]~dataz[,5],ylim=c(0,100),col="red")
    points(dataz[,2]~dataz[,5],ylim=c(0,100),col="blue") 
    points(dataz[,3]~dataz[,5],ylim=c(0,100),col="black")
    if(mean){
	plot(1,mean(dataz[,1]),ylim=c(0,100),col="red")
	points(1,mean(dataz[,2]),ylim=c(0,100),col="blue")
	points(1,mean(dataz[,3]),ylim=c(0,100),col="black")
    }
    if(box){
	boxplot(dataz[,1]~dataz[,5],ylim=c(0,100),col="red",range=0,border="red")
	par(new=T)
	boxplot(dataz[,2]~dataz[,5],ylim=c(0,100),col="blue",range=0,border="blue") 
	par(new=T)
	boxplot(dataz[,3]~dataz[,5],ylim=c(0,100),col="black",range=0,border="black")
	par(new=F)
    }

}
boxplotRapportR1R2forOneEnv<-function(dataz,env,inbox=T,...){
    amx=(100+1)/(0+1)
    amn=(0+1)/(100+1)
    options(scipen=1)
    layout(mat=matrix(c(1,2),nrow=2,ncol=1),heights=matrix(c(.6,.4),nrow=2,ncol=1))

    par(mar=c(0,4,4,3)+.1,cex=1.7)#set some global var for the graf
    if(inbox!=F) 
	boxplot(((dataz[dataz[,5]==env,1]+1)/(dataz[dataz[,5]==env,2]+1))~dataz[dataz[,5]==env,4],range=0,ylab="(#r1+1)/(#r0+1)",main=paste("Resources harvested wrt. availability (ENV",env,")",sep=""),xaxt="n",xlab="",ylim=c(amn,amx),...)
    else 
	plot(((dataz[dataz[,5]==env,1]+1)/(dataz[dataz[,5]==env,2]+1))~dataz[dataz[,5]==env,4],ylab="(#r1+1)/(#r0+1)",main=paste("Resources harvested wrt. availability (ENV",env,")",sep=""),xaxt="n",xlab="",ylim=c(amn,amx),...)


    par(mar=c(5,4,1,3)+.1)
    if(inbox!=F)
	boxplot(dataz[dataz[,5]==env,3]~dataz[dataz[,5]==env,4],range=0,ylim=c(0,100))
    else 
	plot(dataz[dataz[,5]==env,3]~dataz[dataz[,5]==env,4],ylim=c(0,100),xlab="",ylab="")
    title(ylab="#active",xlab="available(Q_r1)")
}

plotAllEnv<-function(dataz,inbox=T,...){
    par(mfrow=c(2,3))
    for (env in 0:4 ){boxplotRapportR1R2forOneEnv(dataz,env,inbox=inbox,...)}
    par(mfrow=c(1,1))
}


plotRatio<-function(dataz,env,...){
    plot(((dataz[dataz[,5]==env,1]+1)/(dataz[dataz[,5]==env,2]+1))~dataz[dataz[,5]==env,4],ylab="log((#R1+1)/(#R2+1))",main=paste("R1/R2 depending on resource repartition for ENV",env,sep=""),ylim=c(0,100),...)
}


####################################################################################
printRatioAllEnv<-function(){
    #counted=countTypePerEnvAndRep(read.csv("allEnv.csv"))
    for (env in c(0:4)){
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/ratioAndRep_staticEnv",env,"LogY.png",sep=""),width=1000,height=1200,pointsize=22)
	boxplotRapportR1R2forOneEnv(counted,env,inbox=T,log="y")
	dev.off()
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/ratioAndRep_staticEnvPlot",env,"LogY.png",sep=""),width=1000,height=1200,pointsize=22)
	boxplotRapportR1R2forOneEnv(counted,env,inbox=F,log="y")
	dev.off()

    }
}
#
printAliveAllEnv<-function(){
    for (env in c(0:4)){
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/alive_staticEnv",env,".png",sep=""),height=1100,width=1100,pointsize=20)
	par(cex=1.8,lwd=2)
	plotActive(get(paste("data",env,"_active",sep="")),res=1000,lwd=1,ylim=c(0,100))
	dev.off()
    }
}

printRatioR1R0forEachEnv<-function(){
    png("~/evorob/Perso/Simon/doc/images/5StaticEnv/ratioR1R2foreachEnv.png",height=900,width=1150,pointsize=20)
    par(cex=1.7,lwd=2)
    interaction.plot(counted[,4],counted[,5],(counted[,1]+1)/(counted[,2]+1),fixed=T,trace.label="ENV",ylab="(#r1+1)/(#r0+1)",xlab="available(Q_r1)",log="y",lwd=2)
    dev.off()
}
theoritical<-function(){
    x=seq(50,95,5)
    png("~/evorob/Perso/Simon/doc/images/5StaticEnv/theroticalRatios.png",width=900,height=900,pointsize=20)
    par(cex=1.7,lwd=2)
    plot(x,(x+1)/(100-x+1),log="y",ylab="(#r1+1)/(#r0+1)",xlab="available(Q_r1)",main="Theoritical ratios",type="b")
    dev.off()
}
#for env in `seq 0 4`; do cd env$env"_50"; echo $env;R --vanilla CMD BATCH /home/simon/evorob/Dev/Roborobo/perso/simon/lineage/autoR.R ; mv alive_static.png ~/evorob/Perso/Simon/doc/images/alive_staticEnv$env.png;cd ..;done


# errBarPlot<-function(dataz,fun=sd){
# plot.new()
# plot(100,100,type="n",ylim=c(0,100),xlim=c(45,100))
# 
# for(env in unique(dataz[,5])){
# 	dataz.mean<-tapply((dataz[dataz[, 5] == env, 1] + 1)/(dataz[dataz[, 5] == env,2]+1),dataz[dataz[, 5] == env,4],mean)
# 	dataz.err<-tapply((dataz[dataz[, 5] == env, 1] + 1)/(dataz[dataz[, 5] == env,2]+1),dataz[dataz[, 5] == env,4],fun)
# 	points(dataz.mean~names(dataz.mean),type="b")
# 	arrows(as.numeric(names(dataz.err)),dataz.mean-dataz.err,as.numeric(names(dataz.err)),dataz.mean+dataz.err,angle=90,code=3,length=.2)
# }
# }

#Return a matrice with, for one env, the 'fun' value of number of individus for eachs trat
#Used with countTypePerEnv, but not usefull with the new datalog_file and with analyse outside the 5statics env class of experiments
myApply<-function(dataz,env,fun=mean,normalized=TRUE){
    if(!normalized)	
	return( rbind(tapply(dataz[dataz[,5]==env,1],dataz[dataz[,5]==env,4],fun),tapply(dataz[dataz[,5]==env,2],dataz[dataz[,5]==env,4],fun)))
    else 
	return( rbind(tapply(dataz[dataz[,5]==env,1]/dataz[dataz[,5]==env,3],dataz[dataz[,5]==env,4],fun),tapply(dataz[dataz[,5]==env,2]/dataz[dataz[,5]==env,3],dataz[dataz[,5]==env,4],fun)))
}

#return an array where the strategies are counted at each iterations
stratCount<-function(alive,fun,res,...){
    return(rbind(tapply(alive$r1[alive$Iteration %% res == 0],alive$Iteration[alive$Iteration %% res == 0],fun),tapply(alive$both[alive$Iteration %% res == 0],alive$Iteration[alive$Iteration %% res == 0],fun),tapply(alive$r0[alive$Iteration %% res == 0],alive$Iteration[alive$Iteration %% res == 0],fun)))
}

#Draw a barplot with two default colors and a default title
barplotStrat<-function(dataz,normalized=TRUE){
    if(normalized){
	barplot(dataz,col=c(myColors["0"],myColors["1"]),xlab="available(Q_r1)",ylab="distribution of active agents (%)",main="Distribution of Robots on Resources (r0 & r1)")
    }
    else{
	barplot(dataz,col=c(myColors["0"],myColors["1"]),xlab="available(Q_r1)",ylab="#Active agents",main="Distribution of Robots on Resources")
    }
}


aBarPlot<-function(dataz,r){barplot(rbind(tapply(dataz$r0[ dataz$Iteration == 1496 & dataz$rep == r  ] ,dataz$Sparsity[dataz$Iteration == 1496 & dataz$rep == r ],mean),tapply(dataz$r1[ dataz$Iteration == 1496& dataz$rep == r ] ,dataz$Sparsity[dataz$Iteration == 1496& dataz$rep == r ],median)))}

#build a n_sparsity * n_repartition matrix, with a[i,j] = fun(a[i],a[j],resource)
#where a[i] and a[j] are one combinaison Sparsity,Repartition, and fun retourn for exemple the mean of individu alive in resource "r1" (if resource ="r1") for that particular combinaison
#Used with my3dwire
makeGrid<-function(dataz,resource,fun,normalized=TRUE){
    a=expand.grid(Sparsity=unique(dataz$Sparsity),Repartition=unique(dataz$rep))

    if(!normalized)
	for (i in 0:length(a[,1])){a[i,3]=fun(dataz[,resource][ dataz$Iteration == 1496 & dataz$Sparsity == a[i,1] & dataz$rep == a[i,2]])}
    else
	for (i in 0:length(a[,1])){a[i,3]=fun(dataz[,resource][ dataz$Iteration == 1496 & dataz$Sparsity == a[i,1] & dataz$rep == a[i,2]]/dataz$alive[ dataz$Iteration == 1496 & dataz$Sparsity == a[i,1] & dataz$rep == a[i,2]])}
    names(a[,3])=resource
    return(a)
}

#same before except that you can choose the used factor
makeGrid2<-function(dataz,fac1,fac2,resource,fun,normalized=TRUE){
    a=expand.grid(Factor1=unique(dataz[,fac1]),Factor2=unique(dataz[,fac2]))

    if(!normalized)
	for (i in 0:length(a[,1])){a[i,3]=fun(dataz[,resource][ dataz$Iteration == 1496 & dataz[,fac1] == a[i,1] & dataz[,fac2] == a[i,2]])}
    else
	for (i in 0:length(a[,1])){
	    a[i,3]=fun(dataz[,resource][ dataz$Iteration == 1496 & dataz[,fac1] == a[i,1] & dataz[,fac2] == a[i,2]]/dataz$alive[ dataz$Iteration == 1496 & dataz[,fac1] == a[i,1] & dataz[,fac2] == a[i,2]])
	}
    names(a)=c(fac1,fac2,resource)
    return(a)
}


# png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/R0_median.png",height=900,width=900)
#my3dwire(data[ data$Sparsity <.25,],"r0",median,drap=T,zoom=0.8,screen=list(x=-90,y=45,z=0),par.settings = list(axis.line = list(col = "transparent")))
# dev.off()
# png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/R0_mean.png",height=900,width=900)
#my3dwire(data[ data$Sparsity <.25,],"r0",mean,drap=T,zoom=0.8,screen=list(x=-90,y=45,z=0),par.settings = list(axis.line = list(col = "transparent")))
# dev.off()
# png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/R1_mean.png",height=900,width=900)
#my3dwire(data[ data$Sparsity <.25,],"r1",mean,drap=T,zoom=0.8,screen=list(x=-90,y=45,z=0),par.settings = list(axis.line = list(col = "transparent")))
# dev.off()
# png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/R1_median.png",height=900,width=900)
#my3dwire(data[ data$Sparsity <.25,],"r1",median,drap=T,zoom=0.8,screen=list(x=-90,y=45,z=0),par.settings = list(axis.line = list(col = "transparent")))
# dev.off()
# png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/R1_mean.png",height=900,width=900)
#my3dwire(data[ data$Sparsity <.25,],"r1",mean,drap=T,zoom=0.8,screen=list(x=-90,y=45,z=0),par.settings = list(axis.line = list(col = "transparent")))
# dev.off()
#png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/active_median.png",width=900,height=900);
#my3dwire(data[data$Sparsity<.250,],"alive",median,normalized=F,drap=T,zoom=0.8,screen=list(x=-90,y=35,z=0),par.settings = list(axis.line = list(col = "transparent")))
#dev.off()
#png("~/evorob/Perso/Simon/doc/20110914-Specialisation-FirstNote/images/active_mean.png",width=900,height=900);
#my3dwire(data[data$Sparsity<.250,],"alive",mean,normalized=F,drap=T,zoom=0.8,screen=list(x=-90,y=35,z=0),par.settings = list(axis.line = list(col = "transparent")))
#dev.off()





plot3dHm<-function(dataz,x=-90,y=35,z=0,zlim=c(0,100),ylab=list(expression(available(Q[R[1]])),rot=-10,cex=2.8),xlab=list("density",cex=2.8,rot=2),zlab=list(paste("#active agents",sep=""),rot=90,cex=2.8),...){

    wireframe(dataz$V3~dataz$Sparsity * (dataz$Repartition ),zlim=zlim,scales=list(arrows=F,distance=c(1,1,1),cex=2, col="black", font= 1, tck=1),,colorkey=F,rap=T,zoom=0.8,screen=list(x=x,y=y,z=z),par.settings = list(axis.line = list(col = "transparent")),drap=T,xlab=xlab,ylab=ylab,zlab=zlab,...)


}


plot3dHm2<-function(dataz,x=-90,y=35,z=0,zlim=c(0,100),ylab=list("tournament size",rot=-10,cex=2.8),xlab=list("density",cex=2.8,rot=2),zlab=list(paste("#active agents",sep=""),rot=90,cex=2.8),...){

    wireframe(dataz[,3]~dataz[,1] * (dataz[,2]),zlim=zlim,scales=list(arrows=F,distance=c(1,1,1),cex=2, col="black", font= 1, tck=1),,colorkey=F,rap=T,zoom=0.8,screen=list(x=x,y=y,z=z),par.settings = list(axis.line = list(col = "transparent")),drap=T,xlab=xlab,ylab=ylab,zlab=zlab,...)
}

my3dwire<-function(dataz,resource,fun,...){
    if(resource=="alive"){
	myMatrix =makeGrid(dataz,resource,fun=fun,normalized=FALSE) 
	wireframe(myMatrix$V3~myMatrix$Sparsity * (myMatrix$Repartition ),zlim=c(0,100),scales=list(arrows=F,distance=c(1,1,1),cex=2, col="black", font= 1, tck=1),zlab=list(paste("#active agents",sep=""),rot=90,cex=2.8),,ylab=list(paste("available(Q_r1)",sep=""),rot=-10,cex=2.8),xlab=list("density",cex=2.8,rot=2),colorkey=F,...)
    }
    else
    {
	myMatrix =makeGrid(dataz,resource,fun=fun,normalized=T) 
	wireframe(myMatrix$V3~myMatrix$Sparsity * (myMatrix$Repartition ),zlim=c(0,1),scales=list(arrows=F,distance=c(1,1,1),cex=2, col="black", font= 1, tck=1),zlab=list(paste("harvest(Q_",resource,")",sep=""),rot=90,cex=2.8),,ylab=list(paste("available(Q_r1)",sep=""),rot=-10,cex=2.8),xlab=list("density",cex=2.8,rot=2),colorkey=F,...)}
}	

printSlideThroughRep<-function(repartition){

}


normalizeData<-function(dataz){
    dataz[dataz>100 & dataz <=1000]=dataz[dataz>100 & dataz <=1000]/1000
    dataz[dataz>1 & dataz<=100]=dataz[dataz>1 & dataz<=100]/100
    return(dataz)

}


printDistributionOnRessourceAllEnv<-function(){
    mypar=par(cex=1.8,cex.main=1)

    for (env in c(0:4)){
	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/barplotAliveR1AndR2_mean_env",env,".png",sep=""),height=970,width=900,pointsize=20)
	par=mypar	
	barplotStrat(myApply(counted,env,mean,normalized=F),normalized=F)
	dev.off()

	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/barplotAliveR1AndR2_median_env",env,".png",sep=""),height=970,width=900,pointsize=20)
	par=mypar	
	barplotStrat(myApply(counted,env,median,normalized=F),normalized=F)
	dev.off()

	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/barplotAliveR1AndR2_mean_env",env,"_normalized.png",sep=""),height=970,width=900,pointsize=20)
	par=mypar	
	barplotStrat(myApply(counted,env,mean))
	dev.off()

	png(paste("~/evorob/Perso/Simon/doc/images/5StaticEnv/barplotAliveR1AndR2_median_env",env,"_normalized.png",sep=""),height=970,width=900,pointsize=20)
	par=mypar	
	barplotStrat(myApply(counted,env,median))
	dev.off()
    }
}

plotTrajectore8like<-function(){
    #copy the three following file into a file 8like-coordinates.csv and read it in R
    #	"","V1","V2","V3","V4","V5","V6","V7","V8","V9","V10","V11","V12","V13","V14"
    #	"1",20,152.28,352.28,500,300.5633,699.4367,648,848,980,848,648,500,352.28,152.28
    #	"2",250,400,400,265.18,250,250,400,400,250,100,100,235.61,100,100


    read.csv("8like-coordinates.csv")
    #png("~/evorob/Perso/Simon/doc/images/traj8like.png")
    plot(as.numeric(coor[1,]),as.numeric(coor[2,]),lwd=4,ann=F,xaxt="n",yaxt="n",ylim=c(0,500),xlim=c(0,1000))
    text(as.numeric(coor[1,]),as.numeric(coor[2,])+15,0:13)
    #title(main="Points drawing the 8-like trajectories")
}



#for all sparsity of the active given matrice, draw its associated alivePlot
writeAliveGraphForAllSpars<-function(active){

    for (spars in unique(active$Sparsity)){
	png(paste("alive_spars",spars,"rep",unique(active$rep),".png",sep=""),width=800)
	plotActive(active[active$Sparsity == spars,],res=4,lwd=1,ylim=c(0,100),xlim=c(0,120))
	dev.off()
    }
}


####################################################################################


#layout(mat=matrix(c(1,2),nrow=2,ncol=1),heights=matrix(c(.7,.3),nrow=2,ncol=1))
#try to have something that update all. Not very good
updt<-function(){
    source("~/evorob/Dev/Roborobo/perso/simon/lineage/Rscript/plotg.R")
}


getSummary<-function(rep,spars,r,all,fun){ return(fun(r[all$Rep ==rep && all$Sparsity == spars]))}




#######################################################
#######################################################
#######################################################
#######################################################
#2015, Reboot

void<-function(){

    #To create a matrix used to plot a Slice :
    hmAllSpars=createHeatMat("Sparsity","alive",rep50)
    splitd=createHeatMat("t_size","alive",last)
    #To make the slice :

    u=read.csv("../resultTournament1230/logs_actives.csv")
    b=read.csv("../500B/logs_actives.csv")
    bt=read.csv("../test//logs_actives.csv")
    all=read.csv("../resultTounrment800-980/logs_actives.csv")
    mn3res=read.csv("~/RoboroMn3Exp/roboExp/perso/simon/lineage/res/logs_actives.csv")
    mn3res=read.csv("~/projects/PhD/dev/Roborobo/perso/simon/lineage/verb/logs_actives.csv")
    test=read.csv("~/projects/PhD/dev/Roborobo/fixTime/logs_actives.csv")
    dev.off()
   boxplot(test$alive ~ test$Iteration,ylim=c(0,max(test$alive)),col="red")
    points(test$r0 ~ test$Iteration,type="l",col="green")
    points(test$r1 ~ test$Iteration,type="l",col="blue")

    

smallbc=lastAll[ lastAll$maxbc>.2,]
    plot(smallbc$alive ~ smallbc$maxbc)
    plot(smallbc$maxbc ~ smallbc$Sparsity)
    plot(smallbc$estrada_index ~ smallbc$Sparsity)
    plot(smallbc$alive ~ smallbc$estrada_index)




    mn3res=rbind(read.csv("~/RoboroMn3Exp/SigmaHigh/500/roboExp/res/logs_actives.csv"),read.csv("~/RoboroMn3Exp/SigmaHigh/500/roboExp1/res/logs_actives.csv"),read.csv("~/RoboroMn3Exp/SigmaHigh/500/roboExp2/res/logs_actives.csv"),read.csv("~/RoboroMn3Exp/SigmaHigh/500/roboExp3/res/logs_actives.csv"))
    lastAll=getLastIt(mn3res)
    table(lastAll$Sparsity)
    plot(lastAll$alive ~ lastAll$maxbc)
    plot(lastAll$estrada_inde ~ lastAll$Sparsity,col="red",log="y")
    points(resHighSigh100Agents$estrada_inde ~ resHighSigh100Agents$Sparsity,log= "y")
    plot(lastAll$av_short_path ~ lastAll$Sparsity)
    plot(lastAll$estrada_index ~ lastAll$Sparsity)
    plot(lastAll$alive ~ lastAll$Sparsity)
    cor(lastAll$alive,lastAll$Sparsity)
    cor(lastAll$alive,lastAll$estrada_index)
    var(lastAll$maxbc,lastAll$alive)
    var(lastAll$Sparsity,lastAll$alive)
    splitd=createHeatMat("Sparsity","alive",lastAll)
    meanspli=meanOn(splitd,mod=.1,l=2)

    splitb=createHeatMat("t_size","alive",b)
    lsp= b[b$Sparsity %% 100==80,]
    lsp=mn3res[mn3res$Sparsity==980,]
    boxplot(lsp$alive ~ lsp$Iteration)
    interaction.plot(lsp$Iteration,lsp$t_size,lsp$alive,fun=mean)
    printASlice(splitd,ylab="#active agents",xlab="rep",ylim=c(0,501.05),xlim=c(550,999))

    ##a ne pas toucher
    resHighSigh100Agents
    plitHighSigma
    dev.off()
    printASlice(plitHighSigma,ylab="#active agents",xlab="rep",ylim=c(0,101.05),xlim=c(620,990))
    resNormSigma500Agentdensity560980 #BCP DE TROU AU NIVEAU DES DENSITE DANS CE SETUP 


    #To create a matrix used to plot a 3D plot :
    hm3dgridEllitist=makeGrid(ellitiste,"alive",median,normalize=F)
    tournament3dGrid=makeGrid2(last,"av_short_path", "rep", "alive",median,normalize=F)

    #To plot the 3D:
    for(yu in -120:-20){
	tournament3dGrid$Sparsity=spar2Dens(tournament3dGrid$Sparsity)
	pdf("active_median-tournament.pdf",width=12,height=12,pointsize=17)
	plot3dHm2(tournament3dGrid,y=-140,x=-100,scpos=list(x=9,y=5,z=2),zlab=list(paste("#active agents",sep=""),rot=86,cex=2.8),ylab=list("tournament size",rot=-30,cex=2.8))
	dev.off()
    }



    #Get All Data :

    ellitiste = read.csv("/home/scarrign/projects/PhD/dev/Roborobo/perso/simon/lineage/vanilla-eeDens002to004LastIt.csv",header=T)
    ellitiste = read.csv("/home/scarrign/projects/PhD/dev/Roborobo/perso/simon/lineage/vanilla-eeDens002to004LastIt.csv002to004LastIt.csv",header=T)
    test = read.csv("/home/scarrign/projects/PhD/dev/RoboroboPure/Roborobo/perso/simon/lineage/largeGde/logs_actives.csv")
    #ellitiste = read.csv("/home/scarrign/projects/PhD/dev/Roborobo/perso/simon/lineage/vanilla-eeDens002to004LastIt.csv",header=F)
    ellitiste$Sparsity = 1 - ellitiste$Sparsity/1000

    ####Print the graph in files :

    ##Figure 7 (4 
    pdf("active_median-vanillaee.pdf",width=12,height=12,pointsize=17)
    hm3dgridEllitist=makeGrid(ellitiste,"alive",median,normalize=F)
    plot3dHm(hm3dgridEllitist[hm3dgridEllitist$Repartition %% 10 ==0 ,],y=35,z=0,x=-90,zlim=c(0,100),lwd=.2)
    dev.off()


    pdf("active_R1-vanillaee.pdf",width=12,height=12);
    #ellitiste=cbind(ellitiste,ellitiste$r1/ellitiste$alive)
    #colnames(ellitiste)[10]="rap"
    #hm3dgridEllitistRp=makeGrid(ellitiste,"rap",median,normalize=F)
    plot3dHm(hm3dgridEllitistRp,y=35,z=0,x=-90,zlim=c(0,1.01),zlab=list("H(q_R1)/alive",rot=90,cex=2.8),lwd=.2)
    dev.off()

    pdf("active_median.pdf",width=12,height=12,pointsize=17);
    par(mar=c(6,6,10,10))
    #hm3dgrid=makeGrid(allT,"alive",median,normalize=F)
    plot3dHm(hm3dgrid[hm3dgrid$Repartition %% 5 ==0 ,],y=35,z=0,x=-90,zlim=c(0,100),lwd=.2)
    dev.off()

    pdf("active_R1.pdf",width=12,height=12,pointsize=14);
    #all=cbind(all,all$r1/all$alive)
    #colnames(all)[10]="rap"
    #hm3dgridRp=makeGrid(allT,"rap",median,normalize=F)
    plot3dHm(hm3dgridRp[hm3dgrid$Repartition %% 5 ==0 ,],y=35,z=0,x=-90,zlim=c(0,1.01),lwd=.2)
    #y=65,z=0,x=-90,zlim=c(0,1.01),zlab=list("H(q_r1)/alive",rot=90,cex=2.8),lwd=.2)
    dev.off()

    table(allT[,c("Sparsity","rep")])

    ##Slice through Qr1 availability (Sparsity == .02):
    #sliceEll=createHeatMat("rep","alive",ellitiste[ ellitiste$Sparsity < .021,])
    pdf("slice_density_02-vanillaEE.pdf",pointsize=14)
    par(mar=c(5,5,4,2))
    printASlice(sliceEll,ylab="#active agents",xlab=expression(available(Q[R[1]])),ylim=c(-2.5,101.5),xlim=c(102,49),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea=createHeatMat("rep","alive",allT[ allT$Sparsity < .021,])
    pdf("slice_density_02.pdf",pointsize=14)
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea,ylab="#active agents",xlab=expression(available(Q[R[1]])),ylim=c(-2.5,101.5),xlim=c(102,49),cex.lab=1.8,cex.axis=1.2)
    dev.off()



    #Slice rep=50
    sliceMedea=createHeatMat("Sparsity","alive",allT[ allT$rep < 51,])
    pdf("slice_alive_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea,ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.198),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedeaRp50=createHeatMat("Sparsity","rap",allT[ allT$rep < 51,])
    pdf("slice_R1_rep-50.pdf",pointsize=14);
    par(mar=c(5,6.5,4,2))
    test=meanOn2(sliceMedeaRp50,.05,2)
    printASlice(test)
    utest=test/apply(test,1,sum)
    printASlice(utest[as.numeric(rownames(utest))<.10,],xlab="density",ylab=expression(frac(Q[R[1]],alive)),ylim=c(-0.15,1.15),xlim=c(0.018,.101),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea90=createHeatMat("Sparsity","alive",allT[ allT$rep < 91 & allT$rep > 89,])
    par(mar=c(5,5,4,2))
    pdf("slice_alive_rep-90.pdf",pointsize=14);
    printASlice(sliceMedea90,ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedeaRp90=createHeatMat("Sparsity","rap",allT[ allT$rep < 91 & allT$rep > 89,])
    pdf("slice_R1_rep-90.pdf",pointsize=14);
    par(mar=c(5,6.5,4,2))
    test=meanOn2(sliceMedeaRp90,.05,2)
    printASlice(test)
    utest=test/apply(test,1,sum)
    printASlice(utest[as.numeric(rownames(utest))<.10,],xlab="density",ylab=expression(frac(Q[R[1]],alive)),ylim=c(-0.15,1.15),xlim=c(0.018,.101),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    #####GRAPH data apres 15000 iterations
    longersim=read.csv("dens002-01_15000it.csv")
    hm15000=createHeatMat("Sparsity","alive",longersim)
    par(mar=c(5,5,4,2))
    pdf("slice_alive_rep-50-15000it.pdf",pointsize=14);
    printASlice(hm15000,ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    
    ############################Data turnament
    d800900=read.csv("../resultTounrment800-980/logs_actives.csv")
    d900980=read.csv("../resultTournament900980d/logs_actives.csv")
    d500800=read.csv("../resultTounrment500-800/logs_actives.csv")
    d500980=rbind(d800900,d500800)
    lastAll=getLastIt(d900980)

    tournament3dGrid=makeGrid2(lastAll,"Sparsity", "t_size", "alive",median,normalize=F)
    tournament3dGrid$Sparsity=spar2Dens(tournament3dGrid$Sparsity)
    #To create a matrix used to plot a 3D plot :
    tournament3dGrid=makeGrid2(lastAll,"Sparsity", "t_size", "alive",median,normalize=F)
    tournament3dGrid$Sparsity=spar2Dens(tournament3dGrid$Sparsity)

    #To plot the 3D:
    pdf("active_median-tournament.pdf",width=12,height=12,pointsize=17)
    plot3dHm2(tournament3dGrid,,y=35,z=0,x=-80,zlim=c(0,100),lwd=.2,zlab=list(paste("#active agents",sep=""),rot=86,cex=2.8),ylab=list("tournament size",rot=-30,cex=2.8))
    dev.off()
    lsp= b[b$Sparsity %% 100==80,]
    lsp=b[b$Sparsity==945,]

    interaction.plot(t_comp$Iteration,t_comp$t_size,t_comp$alive,fun=mean)

    ######les differents plot itereaction en fonction de la taille du tournoi
    for(i in seq(100,500,100)){
	print(i)
	t_comp=d500980[d500980$Sparsity == 1000 - i & d500980$Iteration %% 10 == 0,]
	png(paste("agentwrttimeD-0",i/10,".png",sep=""),width=800,height=800)
	interaction.plot(t_comp$Iteration,t_comp$t_size,t_comp$alive,fun=mean,main=paste("Evolution of #agents for different tournament size\n and density of .0",i/10,sep=""),pch=0:9,,type="b",leg.bty="l",col=colorRampPalette(c("blue","red"))(10),fixed=T,ylim=c(0,100))
	dev.off()
    }
    #####print of slice
    lastAll$Sparsity=spar2Dens(lastAll$Sparsity)

    table(lastAll$Sparsity,lastAll$t_size)

    for(i in 1:4){
	print(i)
	splitAll=createHeatMat("Sparsity","alive",lastAll[lastAll$t_size == i & lastAll$Sparsity <= .1,])
	pdf(paste("DagentWRTdensityT-",i,".pdf",sep=""))
	printASlice(splitAll,ylab="#active agents",xlab="density",ylim=c(0,101.05),xlim=c(.017,0.103))
	dev.off()
    }
    splitAll=createHeatMat("t_size","alive",lastAll[lastAll$Sparsity < .1,])
    printASlice(splitAll,ylab="#active agents",xlab="tournament size",ylim=c(0,101.05),xlim=c(895,985))
    dev.off()



}

spar2Dens<-function(d){return ( 1 - d/1000)} 


bindNewData<-function(old,neu){
    neu$Sparsity = 1 - neu$Sparsity/1000
    neu=cbind(neu,neu$r1/neu$alive)
    colnames(neu)=colnames(old)
    return(rbind(old,neu))
}

getLastIt <- function(d){
    return( d[d$Iteration == max(d$Iteration),])
}

