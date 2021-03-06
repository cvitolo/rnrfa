context("test-seasonal_averages.R")

test_that("seasonal_averages works", {

  x <- seasonal_averages(timeseries = cmr(18019), season = "Spring")
  expect_equal(length(x), 2)
  expect_equal(names(x), c("cmr.Estimate", "cmr.Pr(>|t|)"))

  x <- seasonal_averages(cmr(18019), season = "Summer")
  expect_equal(length(x), 2)

  x <- seasonal_averages(cmr(18019), season = "Autumn")
  expect_equal(length(x), 2)

  x <- seasonal_averages(list(cmr(18019), cmr(18019)), season = "Winter")
  expect_equal(length(x), 2)
  expect_equal(x[1], x[2])

})
