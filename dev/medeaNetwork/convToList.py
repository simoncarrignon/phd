
import networkx as nx
import sys, getopt

filename=sys.argv[1]
curNet = nx.Graph(nx.read_dot(filename))
nx.write_gexf(curNet,filename+".gexf")
