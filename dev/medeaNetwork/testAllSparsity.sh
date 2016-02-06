#!/bin/bash
# usage : perso/simon/sparsity/testAllSparsity.sh NEXP NCORE START END STEP
# test all sparsity between START and STEP at each STEP. For each sparsity NEXP are done, using NCORE core of the node 
# The number of core (ncore) could be changed by `cat /proc/cpuinfo | grep processor | wc -l, But it's sometime usefull interressant to keep some core unused

if [ "$1" == "" ]
then
	echo 'usage : perso/simon/sparsity/testAllSparsity.sh CONF NEXP NCORE START END STEP'
	echo -e './testAllSparsisty CONF NEXP NCORE START END STEP \n\t - NEXP the number of experiences you want to do for each sparsity \n\t - NCORE the computer s number of core \n\t - START the first sparsity tested\n\t - END the last sparsity tested \n\t - STEP the size of a step beetwen START end END \n\t - CONF the name of confile used'
	echo 'test all sparsities between START and STEP at each STEP. For each sparsity NEXP are done, using NCORE core of the node '
	echo 'ex : ./testAllSparsity.sh 200 8 1 96 5  #a good config to test all sparsities in a node of grid500 grenoble' 
	exit 0
fi

confFile=$1
nExp=$2
ncore=$3
start=$4
end=$5
step=$6

for spars in `seq $start $step $end`;
do
	sed -i "s/gSparsity = [0-9][0-9]*/gSparsity = $spars/" $confFile
	echo "-- sparsity at $spars%"
	perso/simon//runParallal.sh $nExp $confFile $ncore>sparsity$spars"Log.log";
	sleep 5
	rm complete* lastRunDone
	
done
	
