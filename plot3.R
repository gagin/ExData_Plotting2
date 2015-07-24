## Common code for all plots starts

# Get the data files, if they are not in the current folder yet
fnei<-"summarySCC_PM25.rds"
fscc<-"Source_Classification_Code.rds"
remote<-"https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
local<-"tmp.zip"
if (!file.exists(fnei) || !file.exists(fscc))
{
  print("Data file is not found, downloading")
  download.file(remote,local)
  print("Unzipping")
  files<-unzip(local)
  file.remove(local)
}

# To speed up further plots, load data only if it's not loaded yet
if(!exists("NEI") || dim(NEI)[1] != 6497651) NEI <- readRDS("summarySCC_PM25.rds")
if(!exists("SCC") || dim(SCC)[1] != 11717) SCC <- readRDS("Source_Classification_Code.rds")
library(dplyr)

# We need list of year data points for every kind of plot
years<-unique(NEI$year)

## Common code for all plots ended

library(ggplot2)
png("plot3.png")
bmore<- NEI %>%
  filter(fips=="24510") %>%
  select(Emissions,type,year) %>%
  group_by(type,year) %>%
  summarize(total=sum(Emissions)/100)
p<-qplot(year,total,data=bmore,color=type,
         main="Baltimore PM2.5 emissions by type",
         ylab="PM2.5 emissions, hundred tons"
)
# I use print() to make code useable from a function or if()
# I made line thicker for us partially colorblind people
# to make legend match easier
print(p
      +geom_line(size=2)
      +scale_x_continuous(breaks=years,labels=years)

      # Add horizontal line to show starting value of "POINT" to see if it decreased
      
      +geom_abline(intercept = bmore$total[bmore$year==1999 & bmore$type=="POINT"],
                   slope=0, size=1)
)
dev.off()
