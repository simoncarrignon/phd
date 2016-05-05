
#mework session 1.8, fixed point and stability:
#Advenced

#Question 2 (with correction)


fq2<-function(x){
return(2^x-x)
}
x=seq(-2,2,.01)
plot(x,fq2(x),type="l")
#equation 2 is givent by 2^x-x=0 which mean if x=2^x (ie x=f(x)) 2-x should cross axis x. Is not the case. So : no fix point.


#Question 3/
f<-function(x){2.5*x*(1-x)}





seed=seq(0,1.5,.05)
mycol=heat.colors(length(seed))
plot(1:10,type="n",ylim=c(-1.5,1.5))
sapply(1:length(seed),function(x){lines(orb(seed[x],10),col=mycol[x])}) 


#Question quizz
quizz1<-function(x){1/4*x+12}
plot(1:100,quizz1(1:100))
