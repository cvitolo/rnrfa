v2.0.5.
--------------------------------------
Minor change:

- To further ensure that the package fails gracefully when the NRFA api is interrogated about stations which do not exist an informative message is printed and the function(s) return a NULL object.  


v2.0.4 and submitted to CRAN.
--------------------------------------
Minor change:

- Ensure that the package fails gracefully with an informative message if the resource is not available or has changed (and not give a check warning nor error). This is a CRAN policy. 


v2.0.2 and submitted to CRAN.
--------------------------------------

Major changes:

1. Fixed issue #19 whereby rejected/missing data in peak flows are flagged as such in output. Added full_info to input parameters to retrieve data quality flags.
2. timeseries are now classed as zoo object, not xts.
3. startseason and endseason in seasonal_averages() are now deprecated, seasons are labelled by the calendar quarter in which the season ends.

Minor changes:

- Added more tests


v2.0.1 and submitted to CRAN.
--------------------------------------

Major changes:

1. Removed obsolete tests that were checking against proj4-based pre-calculated values. This is to overcome issue with use of proj6.


Updated to v2.0 and submitted to CRAN.
--------------------------------------

Major changes:

1. Developed new function to interface new API 
2. Updated existing functions to work with the new API

Minor changes:
1. Fixed broken URL in README file


Updated to v1.5 and submitted to CRAN.
--------------------------------------

Major changes:

1. osg_parse now does not fail when gridRefs is a mixture of upper and lower cases, thanks to Christoph Kratz (@bogsnork on GitHub, see https://github.com/cvitolo/rnrfa/issues/12)!
2. fixed tests for get_ts
3. automatic deployment of website for documentation on github


Updated to v1.4 and submitted to CRAN.
--------------------------------------

Major changes:

1. osg_parse now is vectorised, thanks to Tobias Gauster! 


Updated to v1.3 and submitted to CRAN.
--------------------------------------

Major changes:

1. Removed dependency from cowplot package


Updated to v1.2 and submitted paper to the R Journal
----------------------------------------------------

Major changes:

1. Added some utility functions (e.g. plot_trend) to generate plots in the paper


Updated to v1.1 and submitted to CRAN.
----------------------------------------

Major changes:

1. testthat framework for unit tests
2. travis for continuous integration on linux
3. appveyors for continuous integration on windows
4. added code of conduct
5. renamed functions to follow best practice
6. moved package to root directory to follow best practice


Updated to v0.5.4 and submitted to CRAN.
----------------------------------------

Major changes:

1. Michael Spencer (contributor) updated the function OSGparse to work with grid references of different lengths.

2. Added testthat framework for unit tests
