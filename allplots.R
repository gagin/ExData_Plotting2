setwd("C:/Users/alexg2/SkyDrive/Documents")
if(!exists("NEI")) NEI <- readRDS("summarySCC_PM25.rds")
if(!exists("SCC")) SCC <- readRDS("Source_Classification_Code.rds")
library(dplyr)

years<-unique(NEI$year)

# 1. Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?
# Using the base plotting system, make a plot showing the total PM2.5 emission from all
# sources for each of the years 1999, 2002, 2005, and 2008
if(!file.exists("plot1.png"))
{
  png("plot1.png")
  NEI %>% 
    select(Emissions,year) %>%
      group_by(year) %>%
        summarize(TotalEmissions=sum(Emissions)) %>%
          plot(main="Overall emissions in USA",xaxt="n",type="l")
  axis(1,years)
  dev.off()
}

# Have total emissions from PM2.5 decreased in the Baltimore City, Maryland (fips == "24510")
# from 1999 to 2008? Use the base plotting system to make a plot answering this question.
if(!file.exists("plot2.png"))
{
  png("plot2.png")
  NEI %>% 
    select(Emissions,fips,year) %>%
      filter(fips=="24510") %>%
        group_by(year) %>%
          summarize(TotalEmissions=sum(Emissions)) %>%
            plot(main="Emissions in Baltimore,Maryland",xaxt="n",type="l")
  axis(1,years)
  dev.off()
}

# 3. Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable,
# which of these four sources have seen decreases in emissions from 1999â2008 for Baltimore City?
# Which have seen increases in emissions from 1999â2008?
# Use the ggplot2 plotting system to make a plot answer this question.
library(ggplot2)
if(!file.exists("plot3.png"))
{
  png("plot3.png")
  bmore<- NEI %>% filter(fips=="24510") %>%
    select(Emissions,type,year) %>%
      group_by(type,year) %>%
        summarize(total=sum(Emissions))
  p<-qplot(year,total,data=bmore,color=type,main="Baltimore emissions by type")
  print(p+geom_line()+scale_x_continuous(breaks=years,labels=years))
  dev.off()
}

# 4. Across the United States, how have emissions from coal combustion-related sources changed from 1999â2008?
if(!file.exists("plot4.png"))
{
  png("plot4.png")
  coal<-subset(SCC,grepl("Coal",SCC.Level.Three,ignore.case=TRUE))
  combustioncoal<-subset(coal,grepl("Combustion",SCC.Level.One,ignore.case=TRUE))
  NEI %>%
    subset(SCC %in% combustioncoal$SCC) %>%
      select(Emissions,year) %>%
        group_by(year) %>%
          summarize(TotalEmissions=sum(Emissions)) %>%
            plot(main="Emissions from coal combustion-related sources",xaxt="n",type="l")
  axis(1,years)
  dev.off()
}

# 5. How have emissions from motor vehicle sources changed from 1999â2008 in Baltimore City?

if(!file.exists("plot5.png"))
{
  png("plot5.png")
  vehicles<-subset(SCC,grepl("Vehicle",SCC.Level.Two,ignore.case=TRUE))
  NEI %>%
    filter(fips=="24510") %>%
      subset(SCC %in% vehicles$SCC) %>%
        select(Emissions,year) %>%
        group_by(year) %>%
          summarize(TotalEmissions=sum(Emissions)) %>%
            plot(main="Vehicle emissions in Baltimore",xaxt="n",type="l")
  axis(1,years)
  dev.off()
}

# 6. Compare emissions from motor vehicle sources in Baltimore City with emissions
# from motor vehicle sources in Los Angeles County, California (fips == "06037").
# Which city has seen greater changes over time in motor vehicle emissions?
if(!file.exists("plot6.png"))
{
  png("plot6.png")
  vehicles<-subset(SCC,grepl("Vehicle",SCC.Level.Two))
  places<-c("06037","24510")
  names(places)<-c("Los Angeles","Baltimore")
  cities<-NEI %>%
    subset(fips %in% places) %>%
      subset(SCC %in% vehicles$SCC) %>%
        select(Emissions,year,fips) %>%
          rename(Places=fips) %>%
            group_by(year,Places) %>%
              summarize(TotalEmissions=sum(Emissions))
  cities$Places<-factor(cities$Places,levels=places,labels=names(places))
  p<-qplot(year,TotalEmissions,data=cities,color=Places,main="Vehicle Emissions")
  print(p+geom_line()+scale_x_continuous(breaks=years,labels=years))
  dev.off()
}
