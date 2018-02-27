df=read.csv("city-of-chicago-salaries.csv")

res=tapply(df$Name,df$Department,length)
barplot(sort(log(res)))
