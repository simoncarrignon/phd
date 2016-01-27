#!/bin/bash
#use : ./followaGene.sh START LASTIT DIR DESTDIR
#Where GENNUM is the place of the gene in the genome list, LASTIT the last generation you want to print, DIR, the directory where you are stored datalog files
column=1 #it was initially used when all gene was print. The probleme is that in logging all gene the size of the logFile is really to big
start=$1
end=$2
dir=$3
destdir=$4
sim=0
tot=`ls -1 $dir/ |grep data | wc -l` 

pref=`basename $dir`
if [ "$1" == "" ] 
	then 
	echo 'use : ./followaGene.sh START LASTIT DIR DESTDIR'
	echo -e 'Where : \n\t - START is the first Iteration you want to print, \n\t - LASTIT the last iteration you want to print,\n\t - DIR, the directory where are stored datalog files, \n\t - DESTDIR the directory where you want the output files writted.'
	echo '--output--'
	echo -e ' writes three outputs file : \n\t - $DIR_genometracking.csv : stores the value of g_skill each time a robot use a new one, \n\t - $DIR_actives.csv : stores number of active robots at each gLifeTime iterations,\n\t - $DIR_ancestors : stores the parental link between two robots. '
	
	exit 0
fi

if [ ! -f ../getProp ] 
then
	echo "the script have to be run in its original folder : Roborobo/perso/simon/lineage/ !"
	exit 0;
fi	

if [ ! -d $destdir ] 
then
	mkdir $destdir
fi

echo "Iteration,alive,both,r0,r1,Sim,Sparsity,rep,fitness,t_size" > $destdir/$pref'_actives.csv'
#echo "Iteration,GValue,At,Sim,rID,Sparsity,rep" > $destdir/$pref"_genometracking.csv"
#echo "Iteration,Father,Son,Sim" > $destdir/$pref"_ancestors.csv"



for i in $( ls $dir/ | grep datalog ); do
	gSpars=`../getProp $dir/$i gSparsity`
	gRep=`../getProp $dir/$i gNbAllow`
	gTsize=`../getProp $dir/$i gTournamentSize`
#	cat $i | grep "use" | awk -v start=$start -v sp=$gSpars -v rep=$gRep -v s=$sim -v col=$(($column + 4)) -v e=$end '
#		{
#			if($1 < e && $1 > start && $col != "")
#			{	
#				print $1","$col","$NF","s","$3","sp","rep
#			}
#		}
#		 ' >> $destdir/$pref"_genometracking.csv"
	cat $dir/$i | grep active | awk  -v start=$start -v e=$end -v s=$sim  -v sp=$gSpars -v rep=$gRep -v ts=$gTsize '
	{
		if($1 < e && $1 > start )
		{
			print $1","$4","$5","$6","$7","s","sp","rep","$8","ts
		}
	}' >> $destdir/$pref'_actives.csv'
	
#	cat $i | grep take | awk -v s=$sim 'BEGIN{FS=" "}{print $1","$3","$5","s}' >> $destdir/$pref'_ancestors.csv'
	sim=$(($sim + 1))
	echo    $sim  / $tot 
done




