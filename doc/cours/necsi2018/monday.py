#Copy of previous 
import numpy as np
import pandas as pd
import scipy as sp
import matplotlib.pyplot as pl
from collections import Counter

a=[1,2,3]
b=[4,5,6]


print(np.mean(a))
print(np.max(a))
aprim=np.array(a)
bprim=np.array(b)

#NP aka comment faire du R en python ...
print(bprim)

print(aprim[np.logical_and(aprim>1,bprim > 2)])

z=np.zeros((4,9))
print(z)
print(z.T)
z[2,5]=10
z[3,5]=10
z[2,7]=9
z[1,5]=10

print(z[z>0])
print(np.where(z>0))
nzero=np.where(z>0)
(i,j)=np.where(z>0)
print(nzero[1])
print(zip(nzero))

print(range(50))
print(np.arange(50)) #range

print(np.linspace(1,10,12)) #generate list from min to max with n element
print(np.logspace(1,3,4)) 


print(z.reshape(9,4))

df=pd.read_csv("city-of-chicago-salaries.csv")
print(df.head())
print(df['Name'])
print(df['Name'][2])
print(set(df['Department']))
print(Counter(df['Department'])) #using Counter from collections
print(df.groupby('Department').count()) ##pandas way (akak R way)

c=Counter(df['Department'])

print(c.values())
print(c.most_common())
dept,count=zip(*c.items())
print(dept)
pl.bar(range(len(count)),count)
pl.ylabel(dept)
pl.show()
