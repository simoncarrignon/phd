#!/bin/bash
echo "" > $2; for i in `cat $1` ; do echo $i >> $2; cat ngram/data/$i >>$2; wc -w ngram/data/$i ; done
