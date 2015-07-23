#!/usr/bin/python

path = 'exp1'
numRuns = 800
base = '/gpfs/projects/bsc21/WORK-SIMON/expDesigns/'
for i in range(0, numRuns):
	print('cd ',base,'/',path,'/run_',str(i).zfill(4),' && ./province && ./analysis && rm ./data/*', sep='')


