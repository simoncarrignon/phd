#!/bin/bash

jtype=$1
num=0
for i in `cat all$jtype.html` 
do
	dir=`dirname $i`


	wget $i -O $jtype/`basename $dir` -o log
done
