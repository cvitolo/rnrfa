context("Test CMR function")

test_that("Output of CMR function for id 18019", {

  expect_that(dim(CMR(18019))[1] >= 346, equals(TRUE))

  closeAllConnections()

})
