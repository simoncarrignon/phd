import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense,Dropout,Flatten,Conv2D,MaxPooling2D
import numpy
(xtrain,ytrain),(xtest,ytest)=mnist.load_data()
print xtrain.shape

xtrain=xtrain.reshape(60000,28,28,1)
xtest=xtest.reshape(10000,28,28,1)

ytrain=keras.utils.to_categorical(ytrain,10)
ytest=keras.utils.to_categorical(ytest,10)

model=Sequential()
model.add(Conv2D(32,(5,5),input_shape=(28,28,1)))
model.add(MaxPooling2D(pool_size=(2,2)))
model.add(Dropout(.2))
model.add(Flatten())
model.add(Dense(128))
model.add(Dense(10,activation='softmax'))

model.compile(loss='categorical_crossentropy',optimizer='rmsprop')


#fit
model.fit(xtrain,ytrain,batch_size=128,epochs=1,validation_data=(xtest,ytest))

loss_score,accuracy = model.evaluate(xtest,ytest)

print accuracy
print loss_score
