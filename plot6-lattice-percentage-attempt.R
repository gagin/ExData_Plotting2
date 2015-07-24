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
library(lattice)

png("plot6-lattice-relative.png")

vehicles<-subset(SCC,grepl("Vehicle",SCC.Level.Two,ignore.case=TRUE))
places<-c("06037","24510")
names(places)<-c("Los Angeles","Baltimore")
cities<-NEI %>%
  subset(fips %in% places) %>%
  subset(SCC %in% vehicles$SCC) %>%
  select(Emissions,year,fips) %>%
  rename(county=fips) %>%
  group_by(year,county) %>%
  summarize(Mass=sum(Emissions)/100)
cities$county<-factor(cities$county,levels=places,labels=names(places))
cities$year<-factor(cities$year)

# In order to compare change, let's calculate change relative to 1999 data
# for both cities

cities$Relative[cities$county==names(places)[1]]<-
  100*cities$Mass[cities$county==names(places)[1]]/cities$Mass[cities$county==names(places)[1] & cities$year=="1999"]
cities$Relative[cities$county==names(places)[2]]<-
  100*cities$Mass[cities$county==names(places)[2]]/cities$Mass[cities$county==names(places)[2] & cities$year=="1999"]

library(tidyr)
flat<-cities %>% gather(Scale,Value,-year,-county)

p<-barchart(Value ~ year|Scale, data=flat, horizontal = FALSE,
            ylab="PM2.5 emissions, hundred tons - NOT APPLICABLE TO SECOND",
            main="PM2.5 emissions from vehicles comparison",
            #col="steel blue",
            groups=county,
            auto.key=TRUE
            # now, how do we make second y axis?
            # actually, it's stupid to display percentages as barchart
)

print(p)
dev.off()
