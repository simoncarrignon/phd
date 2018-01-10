from sklearn.datasets import load_boston
from sklearn.decomposition import PCA
import matplotlib.pyplot as pl
import numpy as np

boston = load_boston()
print boston.data,boston.target

X=boston.data
for i in range(X.shape[1]):
    X[:,i]=(X[:,i]-np.mean(X[:,i]))/np.std(X[:,i])

X=np.hstack((boston.data,np.log(boston.target.reshape(len(boston.target),1))))

print(X.shape)

pca=PCA(n_components=10)

fitting=pca.fit_transform(X)
print(fitting.shape)
pl.scatter(fitting[:,0],fitting[:,1],c=X[:,13])
pl.show()
