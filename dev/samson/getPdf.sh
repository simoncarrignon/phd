#!/bin/bash

jtype=$1
for i in `cat pdf$jtype.txt` 
do

	dir=`dirname $i`
	dir=`dirname $dir`
	dir=`basename $dir`
	if [ ! -d "pdf/$jtype/$dir" ]; then
		mkdir "pdf/$jtype/$dir"
	fi
	if [ ! -f pdf/$jtype/$dir/`basename $i` ]; then

		wget $i -O pdf/$jtype/$dir/`basename $i` -o log$jtype
	fi
done
