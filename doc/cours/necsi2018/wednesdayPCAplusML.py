from sklearn import datasets 
from sklearn import model_selection 
#from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report,confusion_matrix
from sklearn.manifold import TSNE
import matplotlib.pyplot as pl
import numpy as np

digits=datasets.load_digits()
X=digits.data
y=digits.target

validation_size=.20
seed=7

X_train,X_test,y_train,y_test = model_selection.train_test_split(X,y,test_size=validation_size,random_state=seed)

clf=RandomForestClassifier(10)

clf.fit(X_train,y_train)

y_hat=clf.predict(X_test)
print confusion_matrix(y_test,y_hat)

tsne=TSNE()
X_tsne=tsne.fit_transform(X)
pl.scatter(X_tsne[:,0],X_tsne[:,1],c=y)
pl.show()


#print boston.data,boston.target
#
#X=boston.data
#for i in range(X.shape[1]):
#    X[:,i]=(X[:,i]-np.mean(X[:,i]))/np.std(X[:,i])
#
#X=np.hstack((boston.data,np.log(boston.target.reshape(len(boston.target),1))))
#
#print(X.shape)
#
#pca=PCA(n_components=10)
#
#fitting=pca.fit_transform(X)
#print(fitting.shape)
#pl.scatter(fitting[:,0],fitting[:,1],c=X[:,13])
#pl.show()
