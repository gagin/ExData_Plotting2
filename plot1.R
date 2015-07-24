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

png("plot1.png")
data<-NEI %>% 
  select(Emissions,year) %>%
  group_by(year) %>%
  summarize(TotalEmissions=sum(Emissions)/1000000)

# This version does bar version of the chart, as TA suggested on the forum
# Originally I preferred lines, they are at my github, if you like
# In particular, https://github.com/gagin/ExData_Plotting2/commit/2b30598ac533f28c4dda83ad508836eb845c4877

barplot(data$TotalEmissions,main="Overall PM2.5 emissions in the USA",
        names.arg=data$year, col="steel blue",
        ylab="PM2.5 emissions, million tons")
dev.off()