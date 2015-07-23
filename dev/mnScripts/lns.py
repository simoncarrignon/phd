#!/usr/bin/python2.6
from __future__ import print_function

path = 'exp1'
numRuns = 800
base = '/gpfs/projects/bsc21/WORK-SIMON/expDesigns/exp1/'
for i in range(0, numRuns):
	print('ln -s /home/bsc21/bsc21130/simon/141110-TradeAndCulture/province ',base,'/',path,'/run_',str(i).zfill(4), sep='')
