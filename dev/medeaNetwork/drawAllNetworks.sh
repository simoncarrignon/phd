#!/bin/bash
#Draw all graph from a log directory and put the result into 
#another folder

if [ "$1" == "" ]
then
	echo -e './drawAllNetworks.sh DIR TOOL TARGET \n\t - DIR the directory where are stored the .dot files \n\t - TOOL the graphViz tool (cf: man graphviz) used to draw the network (ie : neato, circo, ...) \n\t - TARGET a folder where output files will be stored '
	echo ' Draw all graph associated to all run in $DIR used the $TOOL of the graphviz suite. The format of the output (png, eps, pdf, etc...) is hardcoded.'
	echo 'ex : ./drawAllNetworks.sh logs neato networks '
	exit 0
fi

dir=$1
tool=$2
target=$3
cpt=0
if [ "$target" == "" ]
then 
	target="allGraphs"
	if [ ! -d "allGraphs" ]
	then 
		mkdir allGraph
	fi
fi

if [ ! -d $target ] 
then
	mkdir $target
fi 


for i in `ls $dir/graph_*`;
do 
	echo "draw net" $cpt
	$tool -Tdot $i -o $target/$tool"_Network$cpt".png
	cpt=$(($cpt + 1))
done

