source("~/phd/phd/dev/medeaNetwork/plotg2.R")

lastExp=function(){
    ##TOURNAMENT PART
    tsize=c(1,2,3,5,10,50)

    #lastA
    #sapply(
    alld500=c()
    for( i in sapply( list.files("~/deparstaf/PLOSONEMEDEA/P500/",pattern= "D.*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	alld500=rbind(alld500,read.csv(i))
    }

    #100
   alld100=read.csv("~/deparstaf/alld100.csv")
    #write.csv(alld100,"alld100.csv")
    sparsities=c(0,900,940,980)
    sapply(sparsities,function(i){
	   pdf(paste("tmp/100/agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=22)
	   par(mar=c(5,4,2,.5),cex.lab=1.2)
	   t_comp=getLastIt(alld100WOUT[alld100WOUT$Sparsity ==i,])
	   plot(1,1,xlim=c(.5,6.5),ylim=c(35,100),type="n",xaxt="n",yaxt="n",ylab="#Active",xlab="Tournament Size",main=paste("Density=",(1000-i)/1000 ,sep=""))
	   axis(1,at=seq_along(tsize),labels=sort(tsize))
	   axis(2,at=c(40,60,80,100),labels=c(40,60,80,100))
	   sapply(seq_along(tsize),function(k){
		  vioplot(t_comp$alive[t_comp$t_size == sort(tsize)[k]],at=k,add=T,col="white")})
	   dev.off()
	})

    alld100WOUT=alld100[! alld100$Sim %in% c(107,27,98),]
   rep100bWOUT=rep100b[! rep100b$Sim %in% c(107,27,98),]

    #500
    alld500=read.csv("~/deparstaf/alld500.csv")
    #write.csv(alld500100,"alld500500.csv")
    sparsities=c(900,990,996)
    sapply(sparsities,function(i){
	   pdf(paste("tmp/500/agentwrtK_D-",formatC(1000-i,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=22)
	   
	   par(mar=c(5,4,2,.5),cex.lab=1.2)
	   t_comp=getLastIt(alld500[alld500$Sparsity ==i,])
	   plot(1,1,xlim=c(.5,6.5),ylim=c(200,500),type="n",xaxt="n",yaxt="n",ylab="#Active",xlab="Tournament Size",main=paste("Density=",(1000-i)/1000 ,sep=""))
	   axis(1,at=seq_along(tsize),labels=sort(tsize))
	   axis(2,at=c(200,300,400,500),labels=c(200,300,400,500))
	   sapply(seq_along(tsize),function(k){
		  vioplot(t_comp$alive[t_comp$t_size == sort(tsize)[k]],at=k,add=T,col="white")})
	   dev.off()

	})


    ### REPARTITON part

	#100 Agents
    #allT = read.csv("/home/scarrign/projects/PhD/dev/backup_persoRoborobo/simon/lineage/allResult.csv")
    allT = read.csv("~/deparstaf/allT.csv")
    #write.csv(allT,"allT.csv")
    sliceMedea=createHeatMat("Sparsity","alive",allT[ allT$rep < 51,])
    speciation=makeAMAtrix(allT[ allT$rep < 51  ,])

    pdf("tmp/slice_spec_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("tmp/slice_alive_rep-50.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea90=createHeatMat("Sparsity","alive",allT[ allT$rep < 91 & allT$rep > 89,])
    speciation90=makeAMAtrix(allT[ allT$rep < 91 & allT$rep > 89,])

    raptest=allT[ allT$rep < 91 & allT$rep > 89,]
    raptest=raptest[raptest$Sparsity == .02 & raptest$alive == 90,]
    pdf("tmp/slice_spec_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation90[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("tmp/slice_alive_rep-90.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea90[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    sliceMedea75=createHeatMat("Sparsity","alive",allT[ allT$rep < 76 & allT$rep > 74,])
    speciation75=makeAMAtrix(allT[ allT$rep < 76 & allT$rep > 74,])

    pdf("tmp/slice_spec_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation75[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()
    pdf("tmp/slice_alive_rep-75.pdf",pointsize=14);
    par(mar=c(5,5,4,2))
    printASlice(sliceMedea75[ 1:80,],ylab="number of active agents",xlab="density",ylim=c(-2.5,101.5),xlim=c(0.018,0.102),cex.lab=1.8,cex.axis=1.2)
    dev.off()

    pdf("tmp/legNum.pdf",pointsize=14,height=7,width=2)
    par(mar=c(5,0,4,5))
    image(t(as.matrix(2:1000)),col=colorRampPalette(c("white","black"))(1000),axes=F) 
    axis(4,labels=seq(0,100,20),at=seq(0,1,.2),cex=1.4)
    mtext(4,text="Percentage of Simulation",line=3,cex=1.8)
    dev.off()

    pdf("tmp/legLofS.pdf",pointsize=14,height=7,width=2)
    par(mar=c(5,0,4,5))
    image(t(as.matrix(2:1000)),col=colorRampPalette(c("blue","red"))(1000),axes=F) 
    axis(4,labels=seq(0,1,.2),at=seq(0,1,.2),cex=1.4)
    mtext(4,text="Mean level of specialisation",line=3,cex=1.8)
    dev.off()

    rep100=allT

    sapply(c(50,75,90),function(x){
	   repX=makeAMAtrixN(rep100b[ rep100b$rep < x+1 & rep100b$rep > x-1,],maxA=100,stA=5,stR=10)
	   pdf(paste("tmp/100/slice_spec_rep-",x,".pdf",sep= ""),pointsize=20)
	   #par(mar=c(5,5,1,1))
	   par(mar=c(5,5,1,1),cex.axis=1.2)
	   printASlice(repX,ylab="#Active",xlab="Density",ylim=c(35,108.5),yaxt="n",xlim=c(0.010,0.110),cex.lab=1.8,cex.axis=1.2,cols=c( "blue", "red"),zlim=c(0,(100-x)/x))
	   axis(2,at=c(40,60,80,100),labels=c(40,60,80,100))
		  abline(h=100*x/100,col="red")
	   dev.off()
})

    ####
    sapply(c(50,75,90),function(i){
	   pdf(paste("tmp/100/agentwrtD-REP",i,".pdf",sep=""),pointsize=22)
	   #par(mar=c(5,4,1,1))
	   par(mar=c(5,4,2,.5),cex.lab=1.2,cex.axis=1.1)
	   t_comp=getLastIt(rep100[rep100$rep ==i,])
	   plot(1,1,xlim=c(0.5,5.5),ylim=c(35,100),type="n",yaxt="n",xaxt="n",ylab="#Agents",xlab="Density",main="")
	   densities=seq(0.02,0.1,.02)
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   axis(2,at=c(40,60,80,100),labels=c(40,60,80,100))
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")
		  abline(h=100*i/100,col="red")
		  })
	   
	   dev.off()
})



    rep500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/PLOSONEMEDEA/REP/",pattern= "D.*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	rep500=rbind(rep500,read.csv(i))
    }
    ####

    #write.csv(rep500,"rep500.csv")
   rep500=read.csv("~/deparstaf/rep500.csv")
    rep500$Sparsity=spar2Dens(rep500$Sparsity)
    sapply(c(50,75,90),function(i){
	   pdf(paste("tmp/500/agentwrtD-REP",i,".pdf",sep=""),pointsize=22)
	   #par(mar=c(5,4,1,1))
	   par(mar=c(5,4,2,.5),cex.lab=1.2,cex.axis=1.1)
	   t_comp=getLastIt(rep500[rep500$rep ==i,])
	   plot(1,1,xlim=c(0.5,5.5),ylim=c(200,500),type="n",yaxt="n",xaxt="n",ylab="#Agents",xlab="Density",main="")
	   densities=seq(0.02,0.1,.02)
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   axis(2,at=c(200,300,400,500),labels=c(200,300,400,500))
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")
		  abline(h=500*i/100,col="red")
		  })
	   dev.off()
})


    rep500L=getLastIt(rep500)
    #sliceMedea50075=createHeatMat("Sparsity","alive",rep500L[ rep500L$rep < 76 & rep500L$rep > 74,])
    speciation50075=makeAMAtrix(rep500L[ rep500L$rep < 76 & rep500L$rep > 74,],maxA=500,st=25)
    speciation50075=makeColAMAtrix(rep500L[ rep500L$rep < 76 & rep500L$rep > 74,],maxA=500,st=30,cols=c("blue","red"))
    speciation50050=makeAMAtrix(rep500L[ rep500L$rep < 51 & rep500L$rep > 49,],maxA=500,st=25)

    sapply(c(50,75,90),function(x){
	   repX=makeAMAtrix(rep500L[ rep500L$rep < x+1 & rep500L$rep > x-1,],maxA=500,st=25)
	   pdf(paste("tmp/500/slice_spec_rep-",x,".pdf",sep= ""),pointsize=20)
	   par(mar=c(6,5,1,1),cex.axis=1.2)
	   printASlice(cols=c( "blue", "red"),repX,ylab="#Agents",yaxt="n",xlab="Density",ylim=c(200,530.5),xlim=c(0.010,0.110),cex.lab=1.8,cex.axis=1.2,zlim=c(0,(100-x)/x))
		  abline(h=500*x/100,col="red")
	   axis(2,at=c(200,300,400,500),labels=c(200,300,400,500))
	   dev.off()
})


    	 x=90

	   repX=rep500L[ rep500L$rep < x+1 & rep500L$rep > x-1,]
	 min(repX$r0,repX$r1)
	 indata=repX
	 sp=.02
		maxA=apply(indata[round(indata$Sparsity,4) == sp & indata$alive >= 400 & indata$alive < 460 ,c("r1","r0")],1,max)
		minA=apply(indata[round(indata$Sparsity,4) == sp & indata$alive >= 400 & indata$alive < 460,c("r1","r0")],1,min)
		 print(minA)

    #pdf("slice_spec_rep-75.pdf",pointsize=14);
    #par(mar=c(5,5,4,2))
    printASlice(cols=c( "blue", "red"),speciation5005,ylab="number of active agents",xlab="density",ylim=c(-0.5,520.5),xlim=c(0.010,0.110),cex.lab=1.8,cex.axis=1.2)
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


##test stat

##res=c()
##for ( rep in c("50","75","90")){
##       for (den in unique(rep500$Sparsity)){
##	      print(rep)
##	      print(den)
##	      lb=getAlive(getLastIt(rep100),rep,den)
##	      la=getAlive(getLastIt(rep500),rep,den)
##	      t=t.test(la/500,lb/100)
##	      res=rbind(res,c(rep,den,median(la/500),median(lb/100),t[["p.value"]]))
##       }
##}
##
getAlive=function(x,r,d){
	      return(x$alive[x$rep == as.character(r) & x$Sparsity == as.character(d)])
}

supleMat<-function(){
    u=read.csv("~/RoboroMn3Exp/FRONTIERS/FITPROP_P100_D000K1/res/logs_actives.csv")
    b=read.csv("~/RoboroMn3Exp/FRONTIERS/MEDEA_P100_D000K1/res/logs_actives.csv")

    uc=read.csv("~/RoboroMn3Exp/FRONTIERS/FITPROP_P100_D980K1/res/logs_actives.csv")
    bc=read.csv("~/RoboroMn3Exp/FRONTIERS/MEDEA_P500_D000K1/100_D980K1/res/logs_actives.csv")
    FITPROP100=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "FITPROP_P100_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	FITPROP100=rbind(FITPROP100,read.csv(i))
    }
	   t_comp=getLastIt(FITPROP100)
	   t_comp=getLastIt(MEDEA_P100)
	   t_comp$Sparsity=spar2Dens(t_comp$Sparsity)
	   densities=unique(t_comp$Sparsity)
	   #plot(1,1,xlim=c(0.5,5.5),ylim=c(0,100),type="n",xaxt="n",ylab="number of active agents",xlab="density",main=paste("Evolution of #agents for different density"))
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")
		  })

    RANKPROP_P100=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "RANKPROP_P100_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	RANKPROP_P100=rbind(MEDEA_P100,read.csv(i))
    }
    MEDEA_P100=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "MEDEA_P100_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	MEDEA_P100=rbind(MEDEA_P100,read.csv(i))
    }
    FITPROP100=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "FITPROP_P100_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	FITPROP100=rbind(FITPROP100,read.csv(i))
    }
    TOURRANKPROP_P100=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "TOURRANKPROP_P100_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	TOURRANKPROP_P100=rbind(TOURRANKPROP_P100,read.csv(i))
    }
    RANKPROP_P500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "RANKPROP_P500_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	RANKPROP_P500=rbind(RANKPROP_P500,read.csv(i))
    }
    TOURRANKPROP_P500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "TOURRANKPROP_P500_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	TOURRANKPROP_P500=rbind(TOURRANKPROP_P500,read.csv(i))
    }
    MEDEA_P500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "MEDEA_P500_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	MEDEA_P500=rbind(MEDEA_P500,read.csv(i))
    }
    FITPROP500=c()
    for( i in sapply( list.files("~/RoboroMn3Exp/FRONTIERS/",pattern= "FITPROP_P500_*",full.names=T) ,paste,"/res/logs_actives.csv",sep="")){
	FITPROP500=rbind(FITPROP500,read.csv(i))
    }
	   t_comp=getLastIt(FITPROP500)
	   t_comp$Sparsity=spar2Dens(t_comp$Sparsity)
	   densities=unique(t_comp$Sparsity)
	   #plot(1,1,xlim=c(0.5,5.5),ylim=c(0,500),type="n",xaxt="n",ylab="number of active agents",xlab="density",main=paste("Evolution of #agents for different density"))
	   axis(1,at=densities*50,labels=densities,cex=1.7)
	   sapply(densities,function(k){
		  vioplot(t_comp$alive[t_comp$Sparsity > k-.001 & t_comp$Sparsity < k+0.001],at=k*50,add=T,col="white")
		  })

	   dev.off()
	   #par(mfrow=c(2,2))
	   allAlg=list(FITPROP500,RANKPROP_P500,MEDEA_P500,TOURRANKPROP_P500)
	   densities=c(0.004,0.01,0.04,.1)
	   sapply(densities,function(dens){
	   pdf(paste("tmp/500/agentwrtALG-D",dens,".pdf",sep=""),pointsize=14)
	   plot(1,1,xlim=c(0.5,4.5),ylim=c(0,500),type="n",xaxt="n",ylab="#Active",xlab="",main=paste("Density=",dens))
	   axis(1,at=1:4,labels=c("FITPROP","RANKPROP","MEDEA","TOUR-10"),cex=1.7)
	   sapply(1:4,function(k){
		  t_comp=getLastIt(allAlg[[k]])
		  t_comp$Sparsity=spar2Dens(t_comp$Sparsity)
		  vioplot(t_comp$alive[t_comp$Sparsity > dens -.001 & t_comp$Sparsity < dens +0.001],at=k,add=T,col="white")
		  })
	   dev.off()
		  })

	   dev.off()
	   #par(mfrow=c(2,2))

	   allAlg=list(FITPROP100,RANKPROP_P100,MEDEA_P100,TOURRANKPROP_P100)
	   densities=c(0.02,0.04,0.06,.1)
	   sapply(densities,function(dens){
	   pdf(paste("tmp/100/agentwrtALG-D",formatC(1000-dens,width=4,format="d",flag="0"),".pdf",sep=""),pointsize=14)
	   plot(1,1,xlim=c(0.5,4.5),ylim=c(0,100),type="n",xaxt="n",ylab="#Active",main=paste("Density=",dens),xlab="")
	   axis(1,at=1:4,labels=c("FITPROP","RANKPROP","MEDEA","TOUR-10"),cex=1.7)
	   sapply(1:4,function(k){
		  t_comp=getLastIt(allAlg[[k]])
		  t_comp$Sparsity=spar2Dens(t_comp$Sparsity)
		  vioplot(t_comp$alive[t_comp$Sparsity > dens -.001 & t_comp$Sparsity < dens +0.001],at=k,add=T,col="white")
		  })
	   dev.off()
		  })
}

