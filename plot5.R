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

png("plot5.png")
# TA on forums said we can filter by on-road type, but I already did this, and result
# seems to be the same
vehicles<-subset(SCC,grepl("Vehicle",SCC.Level.Two,ignore.case=TRUE))
data<-NEI %>%
  filter(fips=="24510") %>%
  subset(SCC %in% vehicles$SCC) %>%
  select(Emissions,year) %>%
  group_by(year) %>%
  summarize(TotalEmissions=sum(Emissions)/100)
barplot(data$TotalEmissions,
        main="PM2.5 emissions from vehicles in Baltimore, Maryland",
        ylab="PM2.5 emissions, hundred tons",
        col="steel blue",
        names.arg=data$year
        )

dev.off()