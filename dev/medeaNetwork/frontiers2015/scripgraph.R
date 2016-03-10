lastExp=function(){
    ##TOURNAMENT PART
    tsize=c(1,2,3,5,10,50)

    lastA
    #sapply(
    alld=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/PLOSONEMEDEA2/",pattern= "D.*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	alld=rbind(alld,read.csv(i))
    }

    #100
    #alld100=read.csv("alld100.csv")
    #write.csv(alld100,"alld100.csv")
    sparsities=c(0,900,940,980)
    sapply(sparsities,function(i){
	   pdf(paste("100/agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=14)
	   t_comp=getLastIt(alld100[alld100$Sparsity ==i,])
	   plot(1,1,xlim=c(.5,6.5),ylim=c(0,100),type="n",xaxt="n",ylab="number of active agents",xlab="tournament size",main=paste("Evolution of #agents for different tournament size\n and density of ",(1000-i)/1000 ,sep=""))
	   axis(1,at=seq_along(tsize),labels=sort(tsize))
	   sapply(seq_along(tsize),function(k){
		  vioplot(t_comp$alive[t_comp$t_size == sort(tsize)[k]],at=k,add=T,col="white")})
	   dev.off()
	})


    #500
    #alld500=read.csv("alld500.csv")
    #write.csv(alld500100,"alld500500.csv")
    sparsities=c(0,900,990,996)
    sapply(sparsities,function(i){
	   pdf(paste("500/agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=14)
	   t_comp=getLastIt(alld500[alld500$Sparsity ==i,])
	   plot(1,1,xlim=c(.5,6.5),ylim=c(0,500),type="n",xaxt="n",ylab="number of active agents",xlab="tournament size",main=paste("Evolution of #agents for different tournament size\n and density of ",(1000-i)/1000 ,sep=""))
	   axis(1,at=seq_along(tsize),labels=sort(tsize))
	   sapply(seq_along(tsize),function(k){
		  vioplot(t_comp$alive[t_comp$t_size == sort(tsize)[k]],at=k,add=T,col="white")})
	   dev.off()
	})


    ### REPARTITON part

	#100 Agents
    #allT = read.csv("/home/scarrign/projects/PhD/dev/backup_persoRoborobo/simon/lineage/allResult.csv")
    #allT = read.csv("allT.csv")
    #write.csv(allT,"allT.csv")
    sliceMedea=createHeatMat("Sparsity","alive",allT[ allT$rep < 51,])
    speciation=makeAMAtrix(allT[ allT$rep < 51  ,])

    pdf("slice_spec_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea90=createHeatMat("Sparsity","alive",allT[ allT$rep < 91 & allT$rep > 89,])
    speciation90=makeAMAtrix(allT[ allT$rep < 91 & allT$rep > 89,])

    raptest=allT[ allT$rep < 91 & allT$rep > 89,]
    raptest=raptest[raptest$Sparsity == .02 & raptest$alive == 90,]
    pdf("slice_spec_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation90[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea90[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea75=createHeatMat("Sparsity","alive",allT[ allT$rep < 76 & allT$rep > 74,])
    speciation75=makeAMAtrix(allT[ allT$rep < 76 & allT$rep > 74,])

    pdf("slice_spec_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation75[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("slice_alive_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea75[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
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
    mtext(4,text="Mean level of specialisation",line=3,cex=1.8)
    dev.off()

    rep100=allT

    ####
    sapply(c(50,75,90),function(i){
	   pdf(paste("100/agentwrtD-REP",i,".pdf",sep=""),pointsize=14)
	   t_comp=getLastIt(rep100[rep100$rep ==i,])
	   plot(1,1,xlim=c(0.5,5.5),ylim=c(0,100),type="n",xaxt="n",ylab="number of active agents",xlab="density",main=paste("Evolution of #agents for different density\n in environement S(",i,",",100-i,")",sep=""))
	   densities=seq(0.02,0.1,.02)
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")})
	   dev.off()
})



    rep500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/PLOSONEMEDEA/REP/",pattern= "D.*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	rep500=rbind(rep500,read.csv(i))
    }
    ####
    #rep500$Sparsity=spar2Dens(rep500$Sparsity)
    sapply(c(50,75,90),function(i){
	   pdf(paste("500/agentwrtD-REP",i,".pdf",sep=""),pointsize=14)
	   t_comp=getLastIt(rep500[rep500$rep ==i,])
	   plot(1,1,xlim=c(0.5,5.5),ylim=c(0,500),type="n",xaxt="n",ylab="number of active agents",xlab="density",main=paste("Evolution of #agents for different density\n in environement S(",i,",",100-i,")",sep=""))
	   densities=seq(0.02,0.1,.02)
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")})
	   dev.off()
})


    #rep500L=getLastIt(rep500)
    #sliceMedea50075=createHeatMat("Sparsity","alive",rep500L[ rep500L$rep < 76 & rep500L$rep > 74,])
    #speciation50075=makeAMAtrix(rep500L[ rep500L$rep < 76 & rep500L$rep > 74,],maxA=500)

    #pdf("slice_spec_rep-75.pdf",pointsize=14);
    #par(mar=c(5,5,4,2))
    #printASlice(cols=c( "blue", "red"),speciation50075,ylab="number of active agents",xlab="density",ylim=c(-2.5,501.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    #dev.off()
    #pdf("slice_alive_rep-75.pdf",pointsize=14);
    #par(mar=c(5,5,4,2))
    #printASlice(sliceMedea50075,ylab="number of active agents",xlab="density",ylim=c(-2.5,501.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    #dev.off()

    #pdf("legNum.pdf",pointsize=14,height=7,width=2)
    #par(mar=c(5,0,4,5))
    #image(t(as.matrix(2:1000)),col=colorRampPalette(c("white","black"))(1000),axes=F) 
    #axis(4,labels=seq(0,100,20),at=seq(0,1,.2),cex=1.4)
    #mtext(4,text="Percentage of Simulation",line=3,cex=1.8)
    #dev.off()

    #pdf("legLofS.pdf",pointsize=14,height=7,width=2)
    #par(mar=c(5,0,4,5))
    #image(t(as.matrix(2:1000)),col=colorRampPalette(c("blue","red"))(1000),axes=F) 
    #axis(4,labels=seq(0,1,.2),at=seq(0,1,.2),cex=1.4)
    #mtext(4,text="Mean level of specialisation",line=3,cex=1.8)
    #dev.off()

}


