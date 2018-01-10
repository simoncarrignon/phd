import json 
import networkx as nx
from collections import Counter
import numpy as np
import matplotlib.pyplot as pl

files=["dataset_1515514854.3.json","dataset_1515515595.14.json","dataset_1515515224.56.json"]

G=nx.Graph()

def CreateGraph():
	G=nx.Graph()
	
	for fnames in files:
	    f=open("tweetdata/"+fnames,"r")
	    tweets=json.load(f)
	    for tweet in tweets:
	        source= tweet['user']['screen_name']
	        for mention in  tweet['entities']['user_mentions']:
	            target=mention['screen_name']
	            if not G.has_edge(source,target):
	                G.add_edge(source,target,weight=0)
	            G[source][target]['weight']+=1
	
	nx.write_gml(G,"graph.gml")
	


def UserActivity():
    user_activity=Counter()
    user_mentions=Counter()
    for fnames in files:
        f=open("tweetdata/"+fnames,"r")
        tweets=json.load(f)
        for tweet in tweets:
            source= tweet['user']['screen_name']
            user_activity.update([source])
            print(tweet['text'])
            for mention in tweet['entities']['user_mentions']:
                target=mention['screen_name']
                user_mentions.update([target])

    users,counts=zip(*user_mentions.most_common())
    hist,bins=np.histogram(counts,bins=10)
    hist=1.*hist/sum(hist)
    bins=bins[:-1]
    pl.loglog(bins,hist,'o-',lw=2)
    pl.xlabel=("tweets_per_person")
    pl.ylabel=("freq")
    #pl.show()

if __name__ == "__main__":
    UserActivity()
