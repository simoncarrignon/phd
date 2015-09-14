#Script to move folder given some value of some config variable to sort the output


folder=$1
val=$2



if [ ! -d "$val" ]; then
	mkdir $folder"_"$val
fi

for i in $folder/run_*/ ;
do
	res=`cat $i/config.xml | grep "numAgents value=\"$val\""`
	if [ -n "$res"  ]; then
		mv $i $folder"_"$val
	fi

done
