#!/bin/bash
#Script qui recuperer toutes les pages html de ams

for i in `cat amsAllIssues.csv` 
do
    echo $i
    dir=`dirname $i`
    wget $i -O html/`basename $dir` -o log
done
