
adressbase="http://www.ams.org/journals/bull/"
for years in {1900..1920}
do
	for volume in $(seq -w 00 26)
	do
		for issue in $(seq -w 00 15)
		do
			wget $adressbase$years-$volume-$issue"/home.html" -O allPub/$years-$volume-$issue.html
		done
	done
done
