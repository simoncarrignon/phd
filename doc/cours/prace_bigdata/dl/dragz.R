sim=read.csv("simoncarrignon_tweets.csv")
mar=read.csv("mcotsar_tweets.csv")
xil=read.csv("Xilrian_tweets.csv")
mil=read.csv("holyhologram_tweets.csv")
simsize=density(sapply(as.character(sim$text),nchar))
mar=density(sapply(as.character(mar$text),nchar))
xilsize=density(sapply(as.character(xil$text),nchar))
milsize=density(sapply(as.character(mil$text),nchar))

ylim=range(0,simsize$y,xilsize$y,milsize$y)
xlim=range(simsize$x,xilsize$x,milsize$x)


simcol=rgb(1,0,0,0.2)
marcol=rgb(0,1,0,0.2)
xilcol=rgb(0,0,1,0.2)

plot(simsize, xlim = xlim, ylim = ylim, xlab = 'num de charac',
     main = 'Lenght of tweet', 
     panel.first = grid())
polygon(simsize, density = -1, col = simcol)
polygon(milsize, density = -1, col = milcol)
polygon(xilsize, density = -1, col = xilcol)
legend("topleft",legend=c("simille","mildrou","xil"),fill = c(simcol,milcol,xilcol))

gethour <- function(d)as.numeric(sub(":.*","",sub(".*.+ ","",as.character(d))))


simsize=density(gethour(sim$created_at))
xilsize=density(gethour(xil$created_at))
milsize=density(gethour(mil$created_at))


ylim=range(0,simsize$y,xilsize$y,milsize$y)
xlim=range(0,simsize$x,xilsize$x,milsize$x,24)


simcol=rgb(1,0,0,0.2)
milcol=rgb(0,1,0,0.2)
xilcol=rgb(0,0,1,0.2)

plot(simsize, xlim = c(0,24), ylim = ylim, xlab = 'heure de la journee',
     main = 'heure de tweetage', 
     panel.first = grid())
polygon(simsize, density = -1, col = simcol)
polygon(milsize, density = -1, col = milcol)
polygon(xilsize, density = -1, col = xilcol)
legend("topleft",legend=c("simille","mildrou","xil"),fill = c(simcol,milcol,xilcol))
