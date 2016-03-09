lastExp=function(){
    ##TOURNAMENT PART

    lastA
    alld=c()
     #sapply(
	   for( i in sapply( list.files("~/RoboroMn3Exp/PLOSONEMEDEA2/",pattern= "D.*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	       	alld=rbind(alld,read.csv(i))
	   }

	   table(alld[,c("Sparsity","t_size")])
	    
	    #,function(x) alld=rbind(alld,read.csv(x)))

	interaction.plot(alld$Iteration,alld$t_size,alld$r0,fun=mean,main=paste("Evolution of #agents for different tournament size\n and density of ",sep=""),pch=0:9,,type="b",leg.bty="l",col=colorRampPalette(c("blue","red"))(10),fixed=T,ylim=c(0,500),trace.label="jeanejan")

	alld100
	alld
    sapply(unique(alld$Sparsity),function(i){
	pdf(paste("agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=14)
	t_comp=getLastIt(alld[alld$Sparsity ==i,])
	plot(1,1,xlim=c(.5,7.5),ylim=c(0,500),type="n",xaxt="n",ylab="#active agents",xlab="k",main=paste("Evolution of #agents for different tournament size\n and density of ",(1000-i)/1000 ,sep=""))
	axis(1,at=seq_along(unique(t_comp$t_size)),labels=sort(unique(t_comp$t_size)))
	sapply(seq_along(unique(t_comp$t_size)),function(k){
	       vioplot(t_comp$alive[t_comp$t_size == sort(unique(t_comp$t_size))[k]],at=k,add=T)})
	dev.off()
    })

    sapply(unique(alld100$Sparsity),function(i){
	pdf(paste("agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=14)
	t_comp=getLastIt(alld100[alld100$Sparsity ==i,])
	plot(1,1,xlim=c(.5,7.5),ylim=c(0,100),type="n",xaxt="n",ylab="#active agents",xlab="k",main=paste("Evolution of #agents for different tournament size\n and density of ",(1000-i)/1000 ,sep=""))
	axis(1,at=seq_along(unique(t_comp$t_size)),labels=sort(unique(t_comp$t_size)))
	sapply(seq_along(unique(t_comp$t_size)),function(k){
	       vioplot(t_comp$alive[t_comp$t_size == sort(unique(t_comp$t_size))[k]],at=k,add=T)})
	dev.off()
    })


    ### REPARTITON part
    allT = read.csv("/home/scarrign/projects/PhD/dev/backup_persoRoborobo/simon/lineage/allResult.csv")

    sliceMedea=createHeatMat("Sparsity","alive",allT[ allT$rep < 51,])
    speciation=makeAMAtrix(allT[ allT$rep < 51  ,])
    
    pdf("slice_spec_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea90=createHeatMat("Sparsity","alive",allT[ allT$rep < 91 & allT$rep > 89,])
    speciation90=makeAMAtrix(allT[ allT$rep < 91 & allT$rep > 89,])
    
    raptest=allT[ allT$rep < 91 & allT$rep > 89,]
raptest=raptest[raptest$Sparsity == .02 & raptest$alive == 90,]
    pdf("slice_spec_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation90[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea90[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea75=createHeatMat("Sparsity","alive",allT[ allT$rep < 76 & allT$rep > 74,])
    speciation75=makeAMAtrix(allT[ allT$rep < 76 & allT$rep > 74,])
    
    pdf("slice_spec_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation75[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea75[ 1:80,],ylab="#active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    pdf("legNum.pdf",pointsize=14,height=7,width=2)
    par(mar=c(5,0,4,5))
    image(t(as.matrix(2:1000)),col=colorRampPalette(c("white","black"))(1000),axes=F) 
    axis(4,labels=seq(0,100,20),at=seq(0,1,.2),cex=1.4)
    mtext(4,text="Percentage of Simulation",line=3,cex=1.8)
    dev.off()

    pdf("legLofS.pdf",pointsize=14,height=7,width=2)
    par(mar=c(5,0,4,5))
    image(t(as.matrix(2:1000)),col=colorRampPalette(c("blue","red"))(1000),axes=F) 
    axis(4,labels=seq(0,1,.2),at=seq(0,1,.2),cex=1.4)
    mtext(4,text="Mean Level of specialisation",line=3,cex=1.8)
    dev.off()


    ####
    sapply(c(50,75,90),function(i){
	pdf(paste("agentwrtD-REP",i,".pdf",sep=""),poitnsize=14)
	t_comp=getLastIt(allT[allT$rep ==i,])
	plot(1,1,xlim=c(.015,11),ylim=c(0,100),type="n",xaxt="n",ylab="#active agents",xlab="k",main=paste("Evolution of #agents for different density\n in environement S(",i,",",100-i,")",sep=""))
	densities=seq(0.02,0.1,.02)
	axis(1,at=densities*100,labels=densities)
	sapply(densities,function(k){
	       vioplot(t_comp$alive[t_comp$Sparsity > k+.001 & t_comp$Sparsity < k+0.01],at=k*100,add=T)})
    	#sapply(unique(alld$Sparsity),function(i){
	#interaction.plot(t_comp$Iteration,t_comp$t_size,t_comp$alive,fun=mean,main=paste("Evolution of #agents for different tournament size\n and density of ",(1000-i)/1000 ,sep=""),pch=0:9,,type="b",leg.bty="l",col=colorRampPalette(c("blue","red"))(10),fixed=T,ylim=c(0,500),trace.label="Tournament size")
	dev.off()
    })
}


