RNRFA: an R package to interact with the UK National River Flow Archive
=======

The UK National River Flow Archive serves daily streamflow data, spatial rainfall averages and information regarding elevation, geology, land cover and FEH related catchment descriptors.

There is currently an API under development that in future should provide access to the following services: metadata catalogue, catalogue filters based on a geographical bounding-box, catalogue filters based on metadata entries, gauged daily data for about 400 stations available in WaterML2 format, the OGC standard used to describe hydrological time series.  

The information returned by the first three services is in JSON format, while the last one is an XML variant.

The RNRFA package aims to acheive a simpler and more efficient access to data by providing wrapper functions to send HTTP requests and interpret XML/JSON responses. 

### Basics
The package rnrfa can be installed via devtools:

```R
library(devtools)
install_github("r_rnrfa", username = "cvitolo", subdir = "rnrfa")
library(rnrfa)
```

# Functions

## List of monitoring stations
The R function that deals with the NRFA catalogue to retrieve the full list of monitoring stations is called GetStationSummary(). The function, used with no inputs, requests the full list of gauging stations with associated metadata. The output is a dataframe containing one record for each station and as many columns as the number of metadata entries available. 

Those entries are briefly described as follows:
* "id" = Station identification number
* "name" = Name of the station
* "location" = Area in which the station is located
* "river" = River catchment
* "stationDescription" = General station description, containing information on weirs, ratings, etc.
* "catchmentDescription" = Information on topography, geology, land cover, etc.
* "hydrometricArea" = UK hydrometric area identification number, see figure \ref{fig:hydrometricAreas}
* "operator" = UK measuring authorities, see figure \ref{fig:operators}
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

## Station filtering
The same function GetStationSummary() can be used to filter stations based on a bounding box or any of the metadata entries. 

```R
# Filter stations based on bounding box
someStations <- GetStationSummary(lonMin=-3.82, 
                                  lonMax=-3.63, 
                                  latMin=52.43, 
                                  latMax=52.52)
                                  
# Filter stations belonging to a certain hydrometric area
someStations <- GetStationSummary(metadataColumn="haName",
                                  entryValue="Wye (Hereford)")

# Filter based on bounding box & metadata strings
someStations <- GetStationSummary(lonMin=-3.82, lonMax=-3.63, 
                                  latMin=52.43, latMax=52.52,
                                  metadataColumn="haName",
                                  entryValue="Wye (Hereford)")

# Filter stations based on threshold
someStations <- GetStationSummary(lonMin=-3.82, lonMax=-3.63, 
                                  latMin=52.43, latMax=52.52,
                                  metadataColumn="catchmentArea",
                                  entryValue=">1")

# Filter based on minimum reconding years
someStations <- GetStationSummary(lonMin=-3.82, lonMax=-3.63, 
                                  latMin=52.43, latMax=52.52,
                                  metadataColumn="catchmentArea",
                                  entryValue=">1",
                                  minRec=30)
```

## Conversions
The only geospatial information contained in the list of station in the catalogue is the OS grid reference (column "gridRef"). The RNRFA package allows convenient conversion to more standard coordinate systems. The function "OSGParse()", for example, converts the string to easting and northing in the BNG coordinate system (EPSG code: 27700), as in the example below:

```R
# Convert OS Grid reference to BNG
OSGParse("SN853872")
```

The function "OSG2LatLon()", instead, converts from BNG to latitude and longitude in the WSGS84 coordinate system (EPSG code: 4326) and requires an input vector containing latitude and longitude.

```R
# Convert BNG to WSGS84
OSG2LatLon(c(285300,287200))
```

Nesting the previous two functions allows to convert OS grid reference to a WGS84 system. 
```R
# Convert OS Grid reference to WGS84 
OSG2LatLon(OSGParse("SN853872"))

# multiple entries 
OSG2LatLon(OSGParse(c("SN831869","SN829838","SN824853","SN824842","SN826854")))
```

## Interactive map and station details
An interactive map of selected stations can be generated with the following commands:

```R
# Generate a map to show the location of selected stations
myStations <- GetStationSummary(lonMin = 0.5,
                                lonMax = 1.0, 
                                latMin = 50, 
                                latMax = 51)

GenerateMap( myStations )
```

The generated map contains interactive markers. When users click on one of them, a pop-up message is visualised showing name of a selected station and related id. The id number can be used to retrieve the full recorded streamflow time series converting the waterml2 file to a time series object.

```R
# Choose a station by its id number
stationID <- 54022
 
# Search data/metadata in the waterml2 service
s <- SearchNRFA(stationID)
```

Once stations information is fetched, metadata is returned as follows:

```R
# extract only important info 
s$Metadata
```

The time series can be plotted as shown below.

```R
# Extract last year of recordings from timeseries data
library(zoo)
library(ggplot2)
ts <- s$TS[16490:16855] 
myTS <- data.frame("Date"=index(ts),
                   "Value"=coredata(ts) )
 
# plot the time series
ggplot(myTS, aes(Date, Value)) + 
       geom_line(size=0.2) + 
       xlab("") + ylab("Daily discharge [m3/s]") +
       ggtitle(paste(s$Metadata$stationName,
                     " (Station ID: ",stationID,")\n",
                     sep=""))
```

### Terms and Conditions
Please refer to the following Terms and Conditions for use of NRFA Data and disclaimer: http://www.ceh.ac.uk/data/nrfa/data/data_terms.html 

This package uses a non-public API which is likely to change. Package and functions herein are provided as is, without any guarantee.

# Leave your feedback
I would greatly appreciate if you could leave your feedbacks either via email (cvitolodev@gmail.com) or taking a short survey (https://www.surveymonkey.com/s/GTGH8RX).
