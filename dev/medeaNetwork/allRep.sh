for rep in `seq 50 5 100`; do
	echo "nb robot $rep"
	sed -i "s/gNbAllowedRobotsBySun = [0-9][0-9]*/gNbAllowedRobotsBySun = $rep/" prj/mEDEA-sp/propertieFiles/sparsity.properties ;
	perso/simon/sparsity/testAllSparsity.sh 100 6 400 799 50;
done


