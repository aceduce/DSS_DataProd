#test

setwd("D:/Coursera/DS/Pack/DataProduct/DDS_DataProject_w4")

trend<-read.table("multiTimeline.csv", header=T, sep=",", skip=2, stringsAsFactors = FALSE)

#Names for trend, NBA, NFL, MLB, NHL, CF
trend$date<-as.Date(trend$Week,"%Y-%m-%d")
#extract years
#year<-format(trend$date,"%Y")

