#KERAS
#sequeltianl mol
#dense layer/dropout
#batch learning
#gradient descent mse
#fit predict evaluate

import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense,Dropout
import numpy
(xtrain,ytrain),(xtest,ytest)=mnist.load_data()
print xtrain.shape

xtrain=xtrain.reshape(60000,28*28)
xtest=xtest.reshape(10000,28*28)

ytrain=keras.utils.to_categorical(ytrain,10)
ytest=keras.utils.to_categorical(ytest,10)

#Define our model
model=Sequential()
model.add(Dense(1024,activation='relu',input_shape=(28*28,)))
model.add(Dropout(0.2))
model.add(Dense(1024,activation='sigmoid'))
model.add(Dropout(0.2))
model.add(Dense(10,activation='sigmoid'))

#Compile
model.compile(loss='categorical_crossentropy',optimizer='rmsprop')


#fit
model.fit(xtrain,ytrain,batch_size=128,epochs=20)

print model.evaluate(xtest,ytest)
