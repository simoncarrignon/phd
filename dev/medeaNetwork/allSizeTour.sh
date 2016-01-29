

for ts in `seq 1 1 10`;
do
	sed -i "s/gTournamentSize = [0-9][0-9]*/gTournamentSize = $ts/" prj/mEDEA-sp/propertieFiles/sparsity.properties
	echo "-- t_size at $ts%"
	perso/simon/sparsity/testAllSparsity.sh 200 6 900 980 1 
done
	
