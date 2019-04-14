context("test-station_ids.R")

test_that("station_ids works", {
  x <- station_ids()
  expect_equal(length(x) >= 1580, TRUE)
})
