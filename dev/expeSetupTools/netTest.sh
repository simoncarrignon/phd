#Create 100 fodler with expe for testing the same network 

for o in $1/g?.txt ; do 
    fn=`basename "$o"` ; 
    g="${fn%.*}" ; 
    mkdir  $g
    for t in {0000..0099} ; do
	cp -r ../smallworld/run_0000/ "$g"/run_"$t"
	cp $o "$g"/run_"$t"/networks/g0.txt
	cp $o "$g"/run_"$t"/networks/g1.txt
	cp $o "$g"/run_"$t"/networks/g2.txt
    done
done
