from sklearn.datasets import load_boston
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error,r2_score
import numpy as np
import matplotlib.pyplot as pl

boston=load_boston()

X=boston.data
y=boston.target

X_train=X[:3*len(X)/4]
X_test=X[3*len(X)/4:]
y_train=y[:3*len(X)/4]
y_test=y[3*len(X)/4:]

regr=LinearRegression()

regr.fit(X_train,y_train)
y_hat=regr.predict(X_test)
mse=mean_squared_error(y_test,y_hat)
r2=r2_score(y_test,y_hat)

pl.scatter(y_test,y_hat)
pl.plot([0,40],[0,40])
pl.xlabel("Real value")
pl.ylabel("Predicted value")
pl.annotate(" mse=%.1f\nr2=%.1f"%(mse,r2),xy=(0.1,0.8),xycoords='axes fraction',size=20)
pl.show()

