<html>

<head>
<title>Title</title>
</head>

<body>

<p>1. import dataset, check for the data structures, filter duplicated date</p>
<!--begin.rcode
df<- read.csv("F:\\gradSchool\\Pred_Model\\proj\\1\\module\\Metro_Interstate_Traffic_Volume.csv")
str(df)
head(df,4)
df_filt_dup <- df[!duplicated(df$date_time),]
end.rcode-->

<p>2. go to column 'date_time' and separate them in 'year', 'month', 'day', and 'hour'</p>
<!--begin.rcode
library(lubridate)
df.new <- data.frame(df_filt_dup, year = year(df_filt_dup$date_time), month = month(df_filt_dup$date_time), 
                     day = wday(df_filt_dup$date_time), hour = hour(df_filt_dup$date_time))
df.new <- subset(df.new, select = -date_time)
head(df.new,4)
end.rcode-->
u
<p>3. filter out near-zero variance, check numerical and categorical correlations</p>
<!--begin.rcode
library(caret)
nearZeroVar(df.new)
barplot(table(df.new$holiday), main = "Frequency Plot of holiday (degenerate)",
        xlab = "Holiday", ylab = "Frequency", cex.names = 0.8)
hist(df.new[df.new$rain_1h < 1000,3],  main = "Histogram of rain_1h (degenerate)",
       xlab="Bin", ylab="Frequency")
hist(df.new[,4],  main = "Histogram of snow_1h (degenerate)" ,
       xlab="Bin", ylab="Frequency")
boxplot(df.new[df.new$rain_1h < 1000,3],  main = "Boxplot of rain_1h (degenerate)",
       ylab="", xlab="Value", horizontal = T)
boxplot(df.new[,4],  main = "Boxplot of snow_1h (degenerate)",
       ylab="", xlab="Value", horizontal = T)

length(unique(df[-24873,3]))/length(df[-24873,3]) #Rain
length(unique(df[-24873,4]))/length(df[-24873,4]) #snow
length(unique(df[-24873,1]))/length(df[-24873,1]) #holiday
df.new <- subset(df.new, select = -c(holiday, rain_1h, snow_1h))
#library(ggcorrplot)
#ggcorrplot(cor(df.new[1:2],), method="square", lab=TRUE, title = 'Correlation plot on numerical predictors')
end.rcode-->

<p>6. check missing values</p>
<!--begin.rcode
library(naniar)
gg_miss_case(df.new)
end.rcode-->

<p>7. check the skewness</p>
<!--begin.rcode
library(e1071) #install for skewness
library(gridExtra)
library(grid)
frame()
summarystats <- rbind(mean = apply(df.new[,c(1:2,5)], 2, mean),
                      median = apply(df.new[,c(1:2,5)], 2, median),
                      sd = apply(df.new[,c(1:2,5)], 2, sd), 
                      apply(df.new[,c(1:2,5)], 2, quantile),
                      IQR = apply(df.new[,c(1:2,5)], 2, IQR),
                      skewness = apply(df.new[,c(1:2,5)], 2, skewness))
tt=ttheme_default()
grid.table(round(summarystats,digits = 4), theme=tt)
end.rcode-->

<p>8. Numerical Histograms and Boxplots</p>
<!--begin.rcode
hist(df.new[,1],  main = "Histogram of temp",
       xlab="Bin", ylab="Frequency")
hist(df.new[,2],  main = "Histogram of clouds_all" ,
       xlab="Bin", ylab="Frequency")
hist(df.new[,5],  main = "Histogram of traffic_volume",
       xlab="Bin", ylab="Frequency")

boxplot(df.new[,1],  main = "Boxplot of temp",
       ylab="", xlab="Value", horizontal = T)
boxplot(df.new[,2],  main = "Boxplot of clouds_all" ,
       ylab="", xlab="Value", horizontal = T)
boxplot(df.new[,5],  main = "Boxplot of traffic_volume" ,
       ylab="", xlab="Value", horizontal = T)
end.rcode-->

<p>9. remove and impute unresonable columns</p>
<!--begin.rcode
library(RANN)
df.new$temp[df.new$temp==0]<-NA
gg_miss_case(df.new)
df.newnew <- df.new[,-c(5)]
df.response <- df.new[,5]
facts <- c('year', 'month', 'day', 'hour')
df.newnew[facts] <- lapply(df.newnew[facts], factor)
Im <- preProcess(df.newnew,method=c("knnImpute"))
df.newnew <- predict(Im ,df.newnew)
gg_miss_case(df.newnew)
end.rcode-->

<p>10. Numerical Histograms and Boxplots again</p>
<!--begin.rcode
hist(df.newnew[,1],  main = "Histogram of temp",
       xlab="Bin", ylab="Frequency")
hist(df.newnew[,2],  main = "Histogram of clouds_all" ,
       xlab="Bin", ylab="Frequency")

boxplot(df.newnew[,1],  main = "Boxplot of temp",
       ylab="", xlab="Value", horizontal = T)
boxplot(df.newnew[,2],  main = "Boxplot of clouds_all" ,
       ylab="", xlab="Value", horizontal = T)
end.rcode-->

<p>11. check the skewness again</p>
<!--begin.rcode
library(e1071) #install for skewness
library(gridExtra)
library(grid)
frame()
summarystats <- rbind(mean = apply(df.newnew[,1:2], 2, mean),
                      median = apply(df.newnew[,1:2], 2, median),
                      sd = apply(df.newnew[,1:2], 2, sd), 
                      apply(df.newnew[,1:2], 2, quantile),
                      IQR = apply(df.newnew[,1:2], 2, IQR),
                      skewness = apply(df.newnew[,1:2], 2, skewness))
tt=ttheme_default()
grid.table(round(summarystats,digits = 4), theme=tt)
end.rcode-->

<p>5.Correlation between predictors</p>
<!--begin.rcode
library(ggcorrplot)
ggcorrplot(cor(df.newnew[,1:2]), method="square", lab=TRUE, title = 'Correlation plot on numerical predictors')
#df.final <- df.dummy[,-c(23:82, 85, 87:88, 90:99, 101:103, 105, 107:110, 113:123)] 

#library(corrplot)
#corrplot(cor(df.dummy), order = "hclust", )
end.rcode-->

<p>6. Categorical Data Summaries </p>
<!--begin.rcode
frame()
sbplts = length(3:ncol(df.newnew))
clplts = 3
rwplts = ceiling(sbplts/clplts)
par(mfrow=c(rwplts,clplts))
for (col in 3:ncol(df.newnew)) {
  barplot(table(df.newnew[,col]),  main = paste("Frequency Plot of" , colnames(df.newnew)[col]),
          xlab="Level", ylab="Frequency")
  #Sys.sleep(1) #Pause between plots
}
#dev.off() #reset plots

end.rcode-->

<p>6. Categorical Data Summaries </p>
<!--begin.rcode
## 3.1 Boxplots for each Predictor ##
frame()
sbplts = length(3:ncol(df.newnew))
clplts = 3
rwplts = ceiling(sbplts/clplts)
par(mfrow=c(rwplts,clplts))
for (col in 3:ncol(df.newnew)) {
  boxplot(df.new[,5] ~ df.newnew[,col],  main = paste("Boxplot of traffic_volume by" , colnames(df.newnew)[col]),
          xlab="Category", ylab="Traffic Volume")
  #Sys.sleep(1) #Pause between plots
}
#dev.off() #reset plots


end.rcode-->


<p>4. bining dummy variables</p>
<!--begin.rcode
library(dummies)
df.dummy <- cbind(df.newnew, dummy(df.newnew$year, sep='_year_'),
                 dummy(df.newnew$month, sep='_month_'),
                 dummy(df.newnew$day, sep='_day_'),
                 dummy(df.newnew$hour, sep='_hour_'),
                 dummy(df.newnew$weather_main, sep='_'),
                 dummy(df.newnew$weather_description, sep='_'))
                 

df.dummy <- subset(df.dummy, select = -c(year, month, day, hour, weather_main, weather_description))
end.rcode-->

<p>6. Near Zero Variance  </p>
<!--begin.rcode
nzColumns=nearZeroVar(df.dummy)
df.dummy_nzv = df.dummy[,-nzColumns]
df.dummy_nzv_hrs = cbind(df.dummy_nzv,df.dummy[,29:52])
names(df.dummy_nzv)
names(df.dummy_nzv_hrs)
names(df.dummy)
end.rcode-->


<p>6. Near Zero Variance  </p>
<!--begin.rcode
nzColumns=nearZeroVar(df.dummy)
df.dummy_nzv = df.dummy[,-nzColumns]
# Add back hours
df.dummy_nzv_hrs = cbind(df.dummy_nzv,df.dummy[,29:52])
names(df.dummy_nzv) #1
names(df.dummy_nzv_hrs) #2
names(df.dummy) #3
end.rcode-->

<p> fit the model </p>
<!--begin.rcode
write.csv(df.dummy_nzv, "preProcessed_nzv.csv")
write.csv(df.dummy_nzv_hrs, "preProcessed_nzv_hrs.csv")
write.csv(df.dummy, "preProcessed_origin.csv")
end.rcode-->














</body>
</html>