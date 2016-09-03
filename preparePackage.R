setwd("~/Dropbox/Repos/r_rnrfa")
save(stationSummary, file="rnrfa/data/stationSummary.rda", compress='xz')

# Before deploying a shiny/Rmd app, install the package from GitHub (for consistency!), otherwise the deploy is going to fail.

# TEST DEMOS
setwd("~/Dropbox/Repos/r_rnrfa/demos/NUTS1regions")
save(stationSummary, file="rnrfa/data/stationSummary.rda", compress='xz')

setwd("~/Dropbox/Repos/r_rnrfa")

devtools::install_github("cvitolo/r_rnrfa", subdir = "rnrfa")

library(rnrfa)

# Check package dependencies
tools::package_dependencies('rnrfa')

# killall R

# Generate a template for a README.Rmd
devtools::use_readme_rmd('rnrfa')

# Generate a template for a Code of Conduct
devtools::use_code_of_conduct('rnrfa')

# Check spelling mistakes
devtools::spell_check('rnrfa')

# Run unit tests using testthat
devtools::test('rnrfa')

# Run R CMD check or devtools::check()
devtools::check('rnrfa')

# Create the Appveyor config file for continuous integration on Windows
devtools::use_appveyor(pkg = "rnrfa")
# move the newly created appveyor.yml to the root directory and modify it
