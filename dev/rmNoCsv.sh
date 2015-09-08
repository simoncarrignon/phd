#!/bin/bash
fold=$1


for i in $fold/run_0* ; do if [ ! -f $i/agents.csv ] ; then rm -rf $i ;  fi done 
