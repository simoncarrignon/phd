
cobweb<-function(r,first=1,last=20,...){
x=seq(0,1,.01)
plot(x,r*x*(1-x),type="l",col="blue",...)
points(x,x,type="l",col="red")
#for(i in first:last){
#}
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
