###MARIO Idea

y=function(x,m){
	u=x
	u[x<m]=1/m*x
	u[x>=m]=1
	u
}

