#!/bin/bash

#Usage :  ./txtToTex.sh output param
#where output is the output file to parse and param is a file formatted like that:
#   genome size; meanK; list of embryos
#
# list of embryos should be : A,B,C,....


param=$2

gSize=`awk 'BEGIN{FS=";"}{print $1}' "$param"`
meanK=`awk 'BEGIN{FS=";"}{print $2}' "$param"`
listEmb=`awk 'BEGIN{FS=";"}{print $3}' "$param"`
cat $1 | 
sed "s/_\+//g" |  			 #to delete _______ 
sed "s/\s\+$//g" | 			 #to trim ending space
awk '
BEGIN{
	embryo="";
	nrow=0; #to count if we reach the good number of row
	threshold=0; #to check if we reach threshold plcae
	todo=0

}
{ 
	split(listemb,checklist,",")

	if( $1=="EMBRYO")  {
		#this test is to check if the current embryo is in the list
		todo=0
		embryo=$2
		for( i in checklist){
			elt=checklist[i]
			if(elt ==embryo){todo=1}
		}
	}

	if( NF <1 || !todo  ){ next;} #if the line has nothing, or if a line of an output we dont want, we skip


	if( $1=="EMBRYO") 
		{
			print ""
			nrow=0
			threshold=0
			print "\\begin{figure}[!ht]"
			print "	\\begin{center}"
			print "\\includegraphics[width=3cm]{/Users/aina/Dropbox/Tesi/CellLineagesPrograms/no_EA/noEA_parameters_exploration/noEA_parameters_exploration/timesnapshots1_selection/GenomeSize"gsize"meanK"meank"/InterestingLineages/Embryo"embryo"_Pedigree.pdf}"
			print "	\\end{center}"
			print ""
			next;
		}
	if( $1=="Intracellular")
		{
			print "\\caption{\\[A = "
			nrow=1
			next;
		}
	if( $1=="Intercellular")
		{
			print ";"
			print ""
			print "\\caption{\\[B = "
			nrow=1
			next;
		}
	if(nrow>0)
		{

			if(nrow==1){ 
				print "\\begin{pmatrix}"
			}

			gsub(" ","\\&",$0)

			if(nrow < gsize){
				print "\t"$0"\\\\";
				nrow ++;
			}
			else{
				print "\t"$0;
				print "\\end{pmatrix}"
				print ""
				nrow=0;
			}

		}
	if( $1==")Which?")
		{
		pheno= "\\text{; Phenotypes End:"
		for(i=0;i<(NF-1);i++){
			pheno=pheno i
		}
		pheno=pheno "}" 
		print pheno
		print "\\]}"
		print "\\label{embryo1g2k2}"
		print "\\\\end{figure}"
			print ""
		ispheno=0
		next;
	}
	if( $1=="Thresholds")
		{
			threshold=1
			next;

		}
	if(threshold==1)
		{
			print "="
			print "\\begin{pmatrix}"
			gsub(" ","\\&",$0)
			print "\t"$0"\\\\";
			print "\\end{pmatrix}"
			print ""
			threshold=0
			next
		}
	}
		' gsize=$gSize meank=$meanK listemb=$listEmb





