#!/bin/bash
#Script to cehck if theyre are classified as geom and move the file
cat $1  | awk 'BEGIN{FS=";"}{if($5>1904) print $14}'  | grep pdf | sed 's/pdf/txt/' > unlab #tex newer than 1904
cat $1  | awk 'BEGIN{FS=";"}{if($15!="" && $5<=1904) print $14}'  | grep pdf | sed 's/pdf/txt/'  > geom
cat $1  | awk 'BEGIN{FS=";"}{if($15=="" && $5<=1904) print $14}'  | grep pdf | sed 's/pdf/txt/'  > nongeom


for i in `cat unlab` ; do cp allFile/$i unlabdir/ ; done
for i in `cat geom` ; do cp allFile/$i labdir/geom/ ; done
for i in `cat nongeom` ; do cp allFile/$i labdir/nongeom/ ; done


