## testing measurements

setwd("~/Documents/GitHub/Trident/results_organoids/")
setwd("/Volumes/FateTrack_2021/FateTrack_v2/select_data/LailaTests/data_0527_5dil/")

library(ggplot2)

fillist = list.files(path = "./",recursive = T, pattern = "yfp_measurements.csv")
measures_yfp = data.frame()
for (i in fillist){
  temp = read.csv(i )
  temp$yfpfile = i
  measures_yfp = rbind(measures_yfp,temp)
  
}
measures_yfp$X = 1:nrow(measures_yfp)
measures_yfp = measures_yfp[!(colnames(measures_yfp)%in%(c("label","centroid.0","centroid.1")))]


fillist = list.files(path = "./",recursive = T,  pattern = "cy5_measurements.csv")
measures_cy5 = data.frame()
for (i in fillist){
  temp = read.csv(i )
  temp$cy5file = i
  measures_cy5 = rbind(measures_cy5,temp)
  
}
measures_cy5$X = 1:nrow(measures_cy5)
measures_cy5 = measures_cy5[!(colnames(measures_cy5)%in%(c("label","centroid.0","centroid.1")))]

fillist = list.files(path = "./",recursive = T,  pattern = "cy3_measurements.csv")
measures_cy3 = data.frame()
for (i in fillist){
  temp = read.csv(i )
  temp$cy5file = i
  measures_cy3 = rbind(measures_cy3,temp)
  
}
measures_cy3$X = 1:nrow(measures_cy3)
measures_cy3 = measures_cy3[!(colnames(measures_cy3)%in%(c("label","centroid.0","centroid.1")))]

mergeMeasure = merge(merge(measures_cy5, measures_yfp,by="X"),measures_cy3,by="X")

changeBounds=function(vec,log2_transform = T){
  if(log2_transform ){
    vec = log2(vec)
  }
  maxV = max(vec)
  minV = min(vec)
  slope = 1/(maxV-minV)
  yInt = -1*slope*minV
  return(slope*vec+yInt)
}

pol = log2(mergeMeasure$yfp_mean_intensity)
plot(changeBounds(mergeMeasure$cy3_mean_intensity,T),changeBounds(mergeMeasure$cy3_mean_intensity,T))

quantile(changeBounds(mergeMeasure$cy3_mean_intensity,T),probs = seq(0,1,1/5))

mergeMeasure$cy5_scale = changeBounds(mergeMeasure$cy5_mean_intensity,T)
mergeMeasure$cy3_scale = changeBounds(mergeMeasure$cy3_mean_intensity,T)
mergeMeasure$yfp_scale = changeBounds(mergeMeasure$yfp_mean_intensity,T)
mergeMeasure$rad = sqrt((mergeMeasure$yfp_scale)**2+(mergeMeasure$cy3_scale)**2+(mergeMeasure$cy5_scale)**2)
q <- quantile(mergeMeasure$rad,probs = seq(0,1,(10)**-1))

mergeMeasure$group <- cut(mergeMeasure$rad, q, include.lowest=TRUE,
                    labels=1:(length(q)-1))
samplingDensity = round(sqrt(diff(q))/max(sqrt(diff(q)))*75)
samplingNum = table(mergeMeasure$group)
library(dplyr)

superSelect = c()

for (i in 1:10){
  tmp = mergeMeasure[mergeMeasure$group == i,]
  tmpSize = round(as.numeric(samplingDensity)[i]/100*as.numeric(table(mergeMeasure$group)[i]))
  rowSelect = sample(1:nrow(tmp),tmpSize,replace = F)
  tmp$trainingInclude = (1:nrow(tmp))%in%rowSelect
  superSelect = rbind(superSelect,tmp)
}

ggplot(superSelect[!superSelect$trainingInclude,])+geom_hex(aes(cy3_scale,yfp_scale))+scale_x_continuous(limits = c(0,1.1))+scale_y_continuous(limits = c(0,1.1))+scale_fill_gradient(low = "darkgrey",high = "orange")+theme_dark()
ggplot(superSelect)+geom_hex(aes(cy3_scale,yfp_scale))+scale_x_continuous(limits = c(0,1.1))+scale_y_continuous(limits = c(0,1.1))+scale_color_continuous()+scale_fill_gradient(low = "darkgrey",high = "orange")+theme_dark()

sample(mergeMeasure[mergeMeasure$group == 1,],replace = F,
       as.numeric(samplingDensity)[1]/100*as.numeric(table(mergeMeasure$group)[1]))


mergeMeasure$cy3_scale = scale(log2(mergeMeasure$cy3_mean_intensity))
(abs(min(mergeMeasure$cy3_scale)/max(mergeMeasure$cy3_scale))*mergeMeasure$cy3_scale)-1

ggplot(mergeMeasure, aes(log2(cy3_mean_intensity), log2(cy5_mean_intensity)))+
  geom_point(alpha = 0.5,col="white")+
  #scale_x_log10()+ scale_y_log10()+
  theme_dark()

ggplot(mergeMeasure, aes(cy3_scale))+
  geom_histogram(alpha = 0.5,col="white",binwidth  =.1)


newFile = mergeMeasure[mergeMeasure$cy5file == unique(mergeMeasure$cy5file)[4],]
ggplot(newFile,aes(centroid.1,-centroid.0))+
  geom_point(aes(col=cy5_mean_intensity))+
  scale_color_gradient(low = "blue",high = "yellow")+
  theme_dark()+theme(legend.position = "none")
  
