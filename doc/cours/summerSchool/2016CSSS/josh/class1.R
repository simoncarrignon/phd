
cobweb<-function(x0,r,last=20,...){
	x=seq(0,1,.01)
	par(mfrow=c(2,1))
	plot(x,r*x*(1-x),type="l",col="blue",...)
	points(x,x,type="l",col="red")
	xn=x0
	for( i in 1:last){
		xp=xn
		xn=logistic(xp,r)
		prev=c(xp,xn)
		
		points(xp,xn,col="red")
		segments(prev[1],prev[2],xn,xn,lwd=.1)
		segments(prev[1],prev[1],xp,xn,lwd=.1)
	}
	timeSerieLogistic(x0,r,last)
}


timeSerieLogistic<-function(x0,r,last){
	#par(mfrow=c(2,1)
	plot(1,1,xlim=c(0,last),ylim=c(0,1),type="n")
	xn=x0
	for( i in 1:last){
		xp=xn
		xn=logistic(xp,r)
		points(i,xn)
	}
	
}


logistic<-function(x,r){

return(r*x*(1-x))
}
