#This script retur the property of a given .dot file
import networkx as nx
import sys, getopt

filename=sys.argv[1]
curNet = nx.Graph(nx.read_dot(filename))

bc=nx.betweenness_centrality(curNet)
spl=nx.average_shortest_path_length(curNet)
maxbc=bc[max(bc,key=bc.get)]
minbc=bc[min(bc,key=bc.get)]
meanbc=sum(bc.values())/len(bc)
estrada_i=nx.estrada_index(curNet)
print( str(spl) + ',' + str(maxbc) + ',' + str(minbc)  + ','+ str(meanbc) + ',' + str(estrada_i))

