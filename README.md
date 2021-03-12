# rnrfa
> An R package to Retrieve, Filter and Visualize Data from the UK National River Flow Archive

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.593201.svg)](https://doi.org/10.5281/zenodo.593201)

[![CRAN Status Badge](http://www.r-pkg.org/badges/version/rnrfa)](https://cran.r-project.org/package=rnrfa)
[![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rnrfa)](https://cran.r-project.org/package=rnrfa)
[![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/rnrfa)](https://cran.r-project.org/package=rnrfa)

[![R-CMD-check](https://github.com/ilapros/rnrfa/workflows/R-CMD-check/badge.svg)](https://github.com/ilapros/rnrfa/actions)
[![Coverage Status](https://codecov.io/gh/ilapros/rnrfa/master.svg)](https://codecov.io/github/ilapros/rnrfa?branch=master)

**This is the new page of rnrfa - past versions (and the first version) can be seen at https://github.com/cvitolo/rnrfa**

The UK National River Flow Archive serves daily streamflow data, spatial rainfall averages and information regarding elevation, geology, land cover and FEH related catchment descriptors.

There is currently an API under development that in future should provide access to the following services: metadata catalogue, catalogue filters based on a geographical bounding-box, catalogue filters based on metadata entries, gauged daily data for about 400 stations available in WaterML2 format, the OGC standard used to describe hydrological time series.

The information returned by the first three services is in JSON format, while the last one is an XML variant.

The RNRFA package aims to achieve a simpler and more efficient access to data by providing wrapper functions to send HTTP requests and interpret XML/JSON responses.

## Installation

The stable version of the **rnrfa** package is available from CRAN:

``` r
install.packages("rnrfa")
```

Or the development version from GitHub using the package `remotes`:

``` r
install.packages("remotes")
remotes::install_github("ilapros/rnrfa")
```

Now, load the rnrfa package:

``` r
library(rnrfa)
```

## Examples

### Retrieve information for all the stations in the catalogue

The R function that deals with the NRFA catalogue to retrieve the full list of monitoring stations is called catalogue(). The function, used with no inputs, requests the full list of gauging stations with associated metadata. The output is a dataframe containing one record for each station and as many columns as the number of metadata entries available.

``` r
allStations <- catalogue()
```

The same function catalogue() can be used to filter stations based on a bounding box or any of the metadata entries.

``` r
# Define a bounding box:
bbox <- list(lon_min=-3.82, lon_max=-3.63, lat_min=52.43, lat_max=52.52)

# Filter stations based on bounding box
someStations <- catalogue(bbox)
```

### Conversions of OS grid references

The only geospatial information contained in the list of station in the catalogue is the OS grid reference (column "gridRef"). The RNRFA package allows convenient conversion to more standard coordinate systems. The function "osg\_parse()", for example, converts the string to easting and northing in the BNG coordinate system (EPSG code: 27700), as in the example below:

``` r
# Where is the first catchment located?
someStations$`grid-reference`$ngr[1]

# Convert OS Grid reference to BNG
osg_parse(grid_refs = "SN853872")
```

The same function can also convert from BNG to latitude and longitude in the WSGS84 coordinate system (EPSG code: 4326) as in the example below.

``` r
# Convert BNG to WSGS84
osg_parse(grid_refs = "SN853872", coord_system = "WGS84")
```

osg\_parse() also works with multiple references:

``` r
osg_parse(someStations$`grid-reference`$ngr)
```

### Time series data

The first column of the table "someStations" contains the id number. This can be used to retrieve time series data and convert waterml2 files to time series object (of class zoo).

The National River Flow Archive serves two types of time series data: gauged daily flow and catchment mean rainfall.

Catchment mean rainfall:

``` r
info <- cmr(id = "3001")
plot(info)
```

Gauged daily flow:

``` r
info <- gdf(id = "3001")
plot(info)
```

For more examples and details, please see the [vignette](https://github.com/ilapros/rnrfa/blob/master/vignettes/rnrfa-vignette.Rmd).

### Terms and Conditions

Please refer to the following Terms and Conditions for use of NRFA Data and disclaimer: <https://nrfa.ceh.ac.uk/costs-terms-and-conditions>

This package uses a non-public API which is likely to change. Package and functions herein are provided as is, without any guarantee.

### Meta

-   Please [report any issues or bugs](https://github.com/ilapros/rnrfa/issues).
-   License: [GPL-3](https://opensource.org/licenses/GPL-3.0)
-   Get citation information for `rnrfa` in R doing `citation(package = 'rnrfa')`
