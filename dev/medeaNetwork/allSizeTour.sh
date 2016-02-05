
confFile=$1

for ts in `seq 2 1 8`;
do
	sed -i "s/gTournamentSize = [0-9][0-9]*/gTournamentSize = $ts/" $confFile
	echo "-- t_size at $ts%"
	perso/simon/sparsity/testAllSparsity.sh $confFile 200 6 900 980 1 
done
	
