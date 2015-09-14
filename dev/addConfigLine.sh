#Script used to add a column with some values that are in the config file of the experiment but that was not in the output


folder=$1
val=$2



for i in $folder/run_*/ ;
do
	nag=`cat $i/config.xml | grep "numAgents value=" | awk 'BEGIN{FS="\""}{print $2}'`
	nst=`cat $i/config.xml | grep "goods num=" | awk 'BEGIN{FS="\""}{print $2}'`
	echo $nag " and "$nst
	sed -i "s/^/$nag;$nst;/g" $i/agents.csv
done
