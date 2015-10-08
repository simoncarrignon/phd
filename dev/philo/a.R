a=function(){
nex=cbind.data.frame(dress$id,
dress$a_name,
as.numeric(dress$shoulder_type),
as.numeric(dress$handle_section),
as.numeric(dress$body_type),
as.numeric(dress$rim_type),
as.numeric(dress$handles_profile),
as.numeric(dress$neck_type),
as.numeric(dress$base_type),
dress$rim_diameter_max,
dress$rim_diameter_min,
dress$width_min,
dress$width_max,
dress$height_min,
dress$height_max,
dress$height_mean,
dress$fabric,
dress$capacity)

cx=
c(
"id",
"a_name",
"shoulder_type",
"handle_section",
"body_type",
"rim_type",
"handles_profile",
"neck_type",
"base_type",
"rim_diameter_min",
"rim_diameter_max",
"width_min",
"width_max",
"height_min",
"height_max",
"height_mean",
"fabric",
"capacity")
}


#nex should be a dataframe with rowname as taxa id and colname as character idea
toNexus<-function(nex,f){
	#case of char problem
	rownames(nex)=gsub("[^[:alnum:]]","",rownames(nex))

	write(file=f,"begin taxa;")
	t=c(
	    paste("\t dimensions ntax=",nrow(nex),";",sep=""),
	    "\t taxlabels",
	    rownames(nex),
	    ";",
	    "end;"
	    )
	write(file=f,t,append=T)
	t=c(
	    "begin characters;",
	    paste("\t dimensions nchar=",ncol(nex)-1,";",sep=""),
	    paste("\t CharLabels",colnames(nex)[2:ncol(nex)],";"),
	    "\t charstatelabel"
	    )
	u=1
	for( i in colnames(nex)[2:ncol(nex)] ){
		t=c(t,paste("\t\t",u,paste(i,"/",sep=""),paste(sort(unique(nex[,i])),collapse=" "),sep=" "))
		u=u+1
	}
	write(file=f,t,append=T)
	write(t(nex),file=f,ncolumns=ncol(nex),sep="\t",append=T)
	t=c(
	    ";",
	    "end;"
	    )
	write(file=f,t,append=T)
}

writeLAbel<-function(d,f="charac.txt"){
	write(file=f,"")
	for( co in colnames(d)){
		write(file=f,"\n",append=T)
		write(file=f,co,append=T)
		n=cbind.data.frame(
				   as.numeric(sort(unique(d[,co]))),
				   sort(unique(d[,co]))    
				   )
		print(n)
		write(file=f,t(n),2,sep="\t",append=T)
	}

}
