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

png("plot4.png")
# Data review has shown that Coal is marked at Level 3 and Combustion at Level 1
coal<-subset(SCC,grepl("Coal",SCC.Level.Three,ignore.case=TRUE))
combustioncoal<-subset(coal,grepl("Combustion",SCC.Level.One,ignore.case=TRUE))
data<-NEI %>%
  subset(SCC %in% combustioncoal$SCC) %>%
  select(Emissions,year) %>%
  group_by(year) %>%
  summarize(TotalEmissions=sum(Emissions)/1000)
barplot(data$TotalEmissions,
        main="PM2.5 emissions from coal combustion-related sources",
        names.arg=data$year,
        ylab="PM2.5 emissions, thousand tons",
        col="steel blue"
        )
dev.off()