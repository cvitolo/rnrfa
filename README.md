RNRFA: an R package to interact with the UK National River Flow Archive
=======

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.14722.svg)](http://dx.doi.org/10.5281/zenodo.14722)

The UK National River Flow Archive serves daily streamflow data, spatial rainfall averages and information regarding elevation, geology, land cover and FEH related catchment descriptors.

There is currently an API under development that in future should provide access to the following services: metadata catalogue, catalogue filters based on a geographical bounding-box, catalogue filters based on metadata entries, gauged daily data for about 400 stations available in WaterML2 format, the OGC standard used to describe hydrological time series.  

The information returned by the first three services is in JSON format, while the last one is an XML variant.

The RNRFA package aims to achieve a simpler and more efficient access to data by providing wrapper functions to send HTTP requests and interpret XML/JSON responses. 

**To cite this software:**  
Vitolo C. and Fry M., R interface for the National River Flow Archive (rnrfa, R package), (2014), GitHub repository, https://github.com/cvitolo/r_rnrfa, doi: http://dx.doi.org/10.5281/zenodo.14722


# Dependencies
The rnrfa package is dependent on a number of CRAN packages. Install them first:

```R
install.packages(c("XML2R", "RCurl", "zoo", "rjson", "rgdal", "sp", "stringr"))
```

This demo makes also use of external libraries. To install and load them run the following commands:

```R
packs <- c("devtools", "parallel", "ggplot2", "DT", "leaflet", "dygraphs")
install.packages(packs)
lapply(packs, require, character.only = TRUE)
```


# Installation
The stable version (preferred option) of rnrfa is available from CRAN using `install.packages("rnrfa")`, while the development version is available on github via devtools:

```R
install_github("cvitolo/r_rnrfa", subdir = "rnrfa")
```

Now, load the rnrfa package:

```R
library(rnrfa)
```

# Functions

## List of monitoring stations
The R function that deals with the NRFA catalogue to retrieve the full list of monitoring stations is called catalogue(). The function, used with no inputs, requests the full list of gauging stations with associated metadata. The output is a dataframe containing one record for each station and as many columns as the number of metadata entries available. 

```R
# Retrieve information for all the stations in the catalogue:
allStations <- catalogue()
```

Those entries are briefly described as follows:
* "id" = Station identification number
* "name" = Name of the station
* "location" = Area in which the station is located
* "river" = River catchment
* "stationDescription" = General station description, containing information on weirs, ratings, etc.
* "catchmentDescription" = Information on topography, geology, land cover, etc.
* "hydrometricArea" = UK hydrometric area identification number
* "operator" = UK measuring authorities
* "haName" = Hydrometric Area name
* "gridReference" = OS Grid Reference number
* "stationType" = Type of station (e.g. flume, weir, etc.)
* "catchmentArea" = Catchment area in (Km^2)
* "gdfStart" = Year in which recordings started
* "gdfEnd" = Year in which recordings ended
* "farText" = Information on the regime (e.g. natural, regulated, etc.)
* "categories" = various tags (e.g. FEH\_POOLING, FEH\_QMED, HIFLOWS\_INCLUDED)
* "altitude" = Altitude measured in metres above Ordnance Datum or, in Northern Ireland, Malin Head.
* "sensitivity" = Sensitivity index calculated as the percentage change in flow associated with a 10 mm increase in stage at the $Q_{95}$ flow.
* "lat" = a numeric vector of latitude coordinates.
* "lon" = a numeric vector of longitude coordinates.

## Station filtering
The same function catalogue() can be used to filter stations based on a bounding box or any of the metadata entries. 

```R
# Define a bounding box:
bbox <- list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52)

# Filter stations based on bounding box
someStations <- catalogue(bbox)
                                  
# Filter stations belonging to a certain hydrometric area
someStations <- catalogue(metadataColumn="haName", entryValue="Wye (Hereford)")

# Filter based on bounding box & metadata strings
someStations <- catalogue(bbox,
                          metadataColumn="haName",
                          entryValue="Wye (Hereford)")

# Filter stations based on threshold
someStations <- catalogue(bbox,
                          metadataColumn="catchmentArea",
                          entryValue=">1")

# Filter based on minimum recording years
someStations <- catalogue(bbox,
                          metadataColumn="catchmentArea",
                          entryValue=">1",
                          minRec=30)
                                  
# Filter stations based on identification number
someStations <- catalogue(metadataColumn="id",
                          entryValue=c(3001,3002,3003))
                               
# Other combined filtering
someStations <- catalogue(bbox,
                          metadataColumn="id",
                          entryValue=c(54022,54090,54091,54092,54097),
                          minRec=35)
```

## Conversions
The only geospatial information contained in the list of station in the catalogue is the OS grid reference (column "gridRef"). The RNRFA package allows convenient conversion to more standard coordinate systems. The function "OSGParse()", for example, converts the string to easting and northing in the BNG coordinate system (EPSG code: 27700), as in the example below:

```R
# Where is the first catchment located?
someStations$gridReference[[1]]

# Convert OS Grid reference to BNG
OSGparse("SN853872")
```

The same function can also convert from BNG to latitude and longitude in the WSGS84 coordinate system (EPSG code: 4326) as in the example below.

```R
# Convert BNG to WSGS84
OSGparse("SN853872", CoordSystem = "WGS84")
```

## Get station time series data and metadata 
The station's id number can be used to retrieve the streamflow time series converting the waterml2 file to a time series object (zoo).

```R
# Choose a station by its id number
stationID <- 3001
 
# Get time series data from the waterml2 service (flow)
data <- GDF(stationID)

# Get time series data from the waterml2 service (rainfall)
dataR <- CMR(stationID)

# Get time series metadata from the waterml2 service
metadata <- GDFmeta(stationID)
```

The time series can be plotted as shown below.

```R
# Plot streamflow timeseries data
library(zoo)
plot(data, main = metadata$stationName)
```

## Multiple sites
Retrieving information for multiple sites becomes trivial:

```R 
# Search data/metadata in the waterml2 service
s <- GDF(c(3001,3002,3003))

# s is a list of 3 object (one object for each site)
firstSite  <- s[[1]]  # s$ID3001
secondSite <- s[[2]]  # s$ID3002
thirdSite  <- s[[3]]  # s$ID3003

plot(secondSite,col="blue")
lines(thirdSite,col="green")
```

# INTEROPERABILITY

## Create interactive maps using leaflet:

```R 
library(leaflet)

leaflet(data = someStations) %>% addTiles() %>%
  addMarkers(~lon, ~lat, popup = ~paste(id,name))
```

## Interactive plots using dygraphs:

```R 
library(dygraphs)
dygraph(data) %>% dyRangeSelector()
```

## Parallel processing:

A simple benchmark test
```R 
library(parallel)
detectCores()   #             How many cores are available on the local machine?
# 8

system.time( s1 <- GDF(someStations$id) )
#   user  system elapsed 
# 46.368   0.080  48.240

system.time( s2 <- mclapply(someStations$id, GDF, mc.cores = detectCores()) )
#   user  system elapsed 
# 24.976   0.192  26.272
```

Make time consuming tasks faster
```R
# Use all the stations operated by the Natural Resources Wales
stations <- catalogue(metadataColumn="operator", 
                          entryValue="Natural Resources Wales")

# Get the time series (TS)
TS <- mclapply(stations$id, GDF, mc.cores = detectCores())    # parallel package
stations$meanGDF <- unlist( lapply(TS, mean) )   

# Linear model
library(ggplot2)
ggplot(stations, aes(x = as.numeric(catchmentArea), y = meanGDF)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red") +
  xlab(expression(paste("Catchment area [Km^2]",sep=""))) + 
  ylab(expression(paste("Mean flow [m^3/s]",sep="")))
```

# Terms and Conditions
Please refer to the following Terms and Conditions for use of NRFA Data and disclaimer: http://nrfa.ceh.ac.uk/costs-terms-and-conditions

This package uses a non-public API which is likely to change. Package and functions herein are provided as is, without any guarantee.

# Leave your feedback
I would greatly appreciate if you could leave your feedbacks either via email (cvitolodev@gmail.com) or taking a short survey (https://www.surveymonkey.com/s/GTGH8RX).
