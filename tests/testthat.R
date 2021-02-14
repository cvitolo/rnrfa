library("testthat")
library("rnrfa")
library("lintr")

if (!curl::has_internet()) {
  message("No internet, cannot run tests")
}else{
  test_check("rnrfa")
}
