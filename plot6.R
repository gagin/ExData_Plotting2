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
  
  #png("plot6.png")
  vehicles<-subset(SCC,grepl("Vehicle",SCC.Level.Two,ignore.case=TRUE))
  places<-c("06037","24510")
  names(places)<-c("Los Angeles","Baltimore")
  cities<-NEI %>%
    subset(fips %in% places) %>%
    subset(SCC %in% vehicles$SCC) %>%
    select(Emissions,year,fips) %>%
    rename(counties=fips) %>%
    group_by(year,counties) %>%
    summarize(TotalEmissions=sum(Emissions)/100)
  
  # Replace fips numbers with actual names
  
  cities$counties<-factor(cities$counties,levels=places,labels=names(places))
  
  # In order to compare change, let's calculate change relative to 1999 data
  # for both cities
  
  cities$Relative[cities$counties==names(places)[1]]<-
    100*cities$TotalEmissions[cities$counties==names(places)[1]]/cities$TotalEmissions[cities$counties==names(places)[1] & cities$year=="1999"]
  cities$Relative[cities$counties==names(places)[2]]<-
    100*cities$TotalEmissions[cities$counties==names(places)[2]]/cities$TotalEmissions[cities$counties==names(places)[2] & cities$year=="1999"]
  
  # Absolute plot
  
  p<-qplot(year,TotalEmissions,data=cities,color=counties,
           main="PM2.5 emissions from vehicles comparison",
           ylab="PM2.5 emissions, hundred tons"
           )
  # Again, let's make line thicker for the benefit of us partially colorblind people
  # to make it easier to match lines to the legend
  p<-p+geom_line(size=2)+scale_x_continuous(breaks=years,labels=years)+guides(colour=FALSE)
  
  # Relative plot
  
  p1<-qplot(year,Relative,data=cities,color=counties,
            ylab="Same emissions expressed as percentage to 1999 level"
            )         
  p1<-p1+geom_line(size=2)+scale_x_continuous(breaks=years,labels=years)+ theme(legend.position = "top")
  
  # Install package "gridExtra" to make arranging ggplots easier
  
  library(gridExtra)
  
  grid.arrange(p,p1,ncol=2)
  
  # Well, it's a bit awkward to have one chart bear title and other one - legend, and perhaps I could have faceted it,
  # but to me both lines on one chart look prettier, and the example on placing common legend didn't work in my setup
  # This one - https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
  # What I have still works well, I believe.
  
  
  dev.copy(png,"plot6.png",width=700)
  dev.off()
