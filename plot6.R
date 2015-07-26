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
  
  # Relative plot
  p1<-qplot(year,Relative,data=cities,color=counties,
            ylab="Same emissions expressed as percentage to 1999 level"
  )         
  p1<-p1+geom_line(size=2)+scale_x_continuous(breaks=years,labels=years)+theme(legend.position = "top")
  
  # Absolute plot
  cities$year<-factor(cities$year)
  p<-ggplot(data=cities,aes(x=year,y=TotalEmissions,fill=counties))
           p<-p+ggtitle("PM2.5 emissions from vehicles comparison")
           p<-p+ylab("PM2.5 emissions, hundred tons")
           p<-p+guides(fill=FALSE)
           p<-p+geom_bar(position="dodge",stat="identity")

  
  # Install package "gridExtra" to make arranging ggplots easier
  
  library(gridExtra)
  png("plot6.png",width=700)
  grid.arrange(p,p1,ncol=2)
  dev.off()
