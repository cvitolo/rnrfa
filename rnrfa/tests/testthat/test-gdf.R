context("Test GDF function")

test_that("Output of GDF function for id 18019", {

  expect_that(dim(GDF(18019))[1] >= 729, equals(TRUE))

  closeAllConnections()

})
