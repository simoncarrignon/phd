#! /bin/bash


usage()
{
	echo "USAGE: ./runParallal.sh [OPTIONS] NB_OF_EXP CONFIG_FILE NB_OF_INSTANCE "
	echo ""
	echo "OPTIONS"
	echo "	-p, --postExperiemtScript=SCRIPT_AND_PARAMETERS"
	echo "		Use the SCRIPT_AND_PARAMETERS after an experiment has been completed"
}

oneRun()
{
	#init variables
	config=$1
	mainTimeStamp=$2
	postExperimentScript=$3

	isSuccess=0
	timeStamp=`date +%H%M%S%N`	

	#launch experiment
	./roborobo -l $config >"temp$timeStamp" 2>/dev/null

	#apply post-experiment processing if the last experiment isn't already done
	if [ ! -e "./lastRunDone" ]
	then
		#standard post-experiment processing
		if [ "$postExperimentScript" = "" ]
		then
			#wait until can update the results
			while [ -e "take$mainTimeStamp" ]
			do
				sleep 1
			done
			#update results
			touch "take$mainTimeStamp" 
			count=$(cat	"complete$mainTimeStamp")
			count=$((count+1))
			echo $count > "complete$mainTimeStamp"
			rm "take$mainTimeStamp" 
			rm "temp$timeStamp"

			echo "Done : $count/$nbExp"

		#user specified post-experiment processing
		else
			. $postExperimentScript
		fi
	else
		rm "take$mainTimeStamp" 
		rm "temp$timeStamp"
	fi
}

if [ $# -lt 3 ]
then
	usage
else

	nbInst=""
	nbExp=""
	config=""
	postExperimentScript=""

	while [ "$1" != "" ]; do
			case $1 in
					-p | --postExperimentScript )	shift
																				postExperimentScript=$1
																				;;
					-h | --help )           			usage
																				exit
																				;;
					*) break
			esac
			shift
	done

	nbExp=$1
	config=$2
	nbInst=$3

	mainTimeStamp=`date +%H%M%S%N`	
	completeCnt=0
	totCnt=0
	lastRunDone=0


	echo "0" > "complete$mainTimeStamp"

	while [ $completeCnt -lt $nbExp ]
	do
		while [ `jobs | wc -l` -ge $nbInst ] # check the number of instance currently running
		do
			jobs >/dev/null
			sleep 5
		done

		while [ -e "take$mainTimeStamp" ]
		do
			sleep 1
		done
		touch "take$mainTimeStamp" 
		completeCnt=$(cat "complete$mainTimeStamp")
		rm "take$mainTimeStamp" 

		if [ $completeCnt -lt $nbExp ]
		then
			oneRun $config $mainTimeStamp "$postExperimentScript" &
			totCnt=$((totCnt+1))
		fi
		sleep 1
	done
	touch "./lastRunDone"
	killall -9 roborobo
fi

