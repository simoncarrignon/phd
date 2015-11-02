for(y=1890; y<=1920;y++){
	a=issueArray[y];
	for (v in a){
		for (j in a[v]){
			console.log("http://www.ams.org/journals/bull/"+y+"-"+v+"-"+0+j+"/home.html")
		}
	}
}

