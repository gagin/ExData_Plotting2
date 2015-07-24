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


library(ggplot2)
png("plot3.png")
bmore<- NEI %>%
  filter(fips=="24510") %>%
  select(Emissions,type,year) %>%
  group_by(type,year) %>%
  summarize(total=sum(Emissions)/100)

# ggplot considers it continuous and misplaces x scale unless years are factors
bmore$year<-as.factor(bmore$year)

p<-ggplot(data=bmore, aes(x=year,y=total))
p<-p+geom_bar(stat='identity',aes(fill=type))
p<-p+facet_wrap(~type, nrow=2)
p<-p+ggtitle("Baltimore PM2.5 emissions by type")
p<-p+ylab("PM2.5 emissions, hundred tons")
print(p)

dev.off()
