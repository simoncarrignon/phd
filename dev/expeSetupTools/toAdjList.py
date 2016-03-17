#!/usr/bin/python
##python code to generate netwokr given a pandora config file. 
#Maybe we should integrate it to the C++ code in the Network Class
#But maybe not

import networkx as nx
from numpy import logspace
from xml.etree import ElementTree as et
import glob

def adj_list_to_file(G,file_name):
    f = open(file_name, "w")
    for n in G.nodes():
        f.write(str(n) + ' ')
        for neighbor in G.neighbors(n):
            f.write(str(neighbor) + ' ')
        f.write('\n')

allNet = glob.glob("G*.txt")

for j in allNet:
    inname= j
    onname= j.lower()
    G=nx.read_adjlist(inname)
    adj_list_to_file(G.to_undirected(),onname)
