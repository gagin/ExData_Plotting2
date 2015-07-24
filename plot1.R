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

png("plot1.png")
data<-NEI %>% 
  select(Emissions,year) %>%
  group_by(year) %>%
  summarize(TotalEmissions=sum(Emissions)/1000000)

# TA on forums said it should be histogram, but I believe this works better
# Emissions measured every three years, but the nature of the change is continuous

plot(data,main="Overall PM2.5 emissions in the USA",xaxt="n",type="b",
     
     # Let's make y start from zero to show the scale,
     # and add a bit at top for readability
     
     ylab="PM2.5 emissions, million tons",ylim=c(0,1.05*max(data$TotalEmissions))
)
axis(1,years)
dev.off()