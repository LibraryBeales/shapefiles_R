library("proj4", lib.loc="~/R/win-library/3.3")
library("rgdal", lib.loc="~/R/win-library/3.3")
library("dplyr", lib.loc="~/R/win-library/3.3")
library("ggplot", lib.loc="~/R/win-library/3.3")

higeo= readOGR(dsn=".", layer="FILENAME HERE") #Read in shape file
higeo@data$id = rownames(higeo@data) #add row numbers as a column
higeo.points = fortify(higeo, region="id") #pull point data from each “region”
higeo.df = inner_join(higeo.points, higeo@data, by="id") #join individual points back to data via id field
colnames(higeo.df)[1:2] <- c("easting","northing")
higeo.df$rowid = rownames(higeo.df) #begin again, add “rowid”  this time.
hicoords <- data.frame(x=higeo.df$easting, y=higeo.df$northing) #create xy values in new df, because proj4 only handles 2 columns
proj4string <- "+proj=utm +zone=4 +north +ellps=WGS84 +datum=WGS84 +units=m +no_defs"#define proj4string to contain constants
hiconv <- project(hicoords, proj4string, inv=TRUE)#converts to lat long
hiconv.df <- data.frame(hiconv)
hiconv.df$rowid = rownames(hiconv.df)# add rownames as column
newhi.df <- inner_join(hiconv.df, higeo.df, by="rowid") #rejoin dfs by rowid
colnames(newhi.df)[1:2] <- c("lon","lat") #rename x and y columns
View(newhi.df)  #join to original data.frame
default = ggplot(newhi.df) +
+     aes(lon,lat,group=group) +
+     geom_polygon() + 
+     ggtitle("Default Projection")
default