from tweepy import Stream, OAuthHandler, StreamListener
import json
import time

class listener(StreamListener):
        def on_data(self,data):
            try:
                tweet=json.loads(data)
                #print tweet['text']
                if len(tweets)<N:
                    tweets.append(tweet)
                    print('\t new tweet '+str(len(tweets))+tweet['text'])
                else:
                    print('new file')
                    f=open("tweetdata/dataset_%s.json"%(str(time.time()).replace('.','')),'w')
                    json.dump(tweets,f)
                    f.close()
                    tweets[:]=[]
            except Exception as inst : 
                print inst

        def on_error(self,status):
            print status

tweets=[]
N=200

accesToken='1171319695-ntdK7rjngFan1d1NFd1LMD3BEKEEDfWyG1d9fPu'
secretToken='HFmL5ovFvLjsdcT1BvYLdpkHwYdJCVfCHbBDovvI146C4'
ConsumerKey='sHpzxLvtUar6TiQ4kBVsOnFFg'
ConsumerSecret='Rf6uBiU9KAdGy6i1Vq9J52aCsDvQbb7IheL13MZMqDr7EI2lWL'

auth=OAuthHandler(ConsumerKey,ConsumerSecret)
auth.set_access_token(accesToken,secretToken)

twitterStream=Stream(auth,listener())

track=['necsi']
twitterStream.filter(track=track)
