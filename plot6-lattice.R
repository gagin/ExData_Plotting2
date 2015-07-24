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

png("plot6.png")

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

# Just for training purposes, let's use lattice's barchart() for this
# Although originally I did line charts in ggplot, and they look awkward,
# but have advantage of showing compared percentage change
# https://github.com/gagin/ExData_Plotting2/blob/2b30598ac533f28c4dda83ad508836eb845c4877/plot6.png


p<-barchart(Mass ~ year| county, data=cities, horizontal = FALSE,
            ylab="PM2.5 emissions, hundred tons",
            main="PM2.5 emissions from vehicles comparison",
            col="steel blue"
)
# other way to go is to have "groups=counties" instead of "|counties"
# then bars will be side-by-side in one panel, but this way Baltimore
# dynamics is not as visible, as it's dwarved by LA


print(p)
dev.off()
