context("Test cmr function")

test_that("Output of cmr function for single station", {

  x <- cmr(id = 18019, metadata = FALSE, cl = NULL)

  expect_that(length(x) >= 660, equals(TRUE))

  x <- cmr(id = 18019, metadata = TRUE, cl = NULL)

  expect_that(length(x) == 2, equals(TRUE))
  expect_that(x$meta$station.name == "Comer Burn at Comer", equals(TRUE))

  closeAllConnections()

})

test_that("Output of cmr function for multiple stations", {

  ids <- c(54022, 54090, 54091)

  x <- cmr(id = ids, metadata = FALSE, cl = NULL)

  expect_that(length(x) == 3, equals(TRUE))

  x <- cmr(id = ids, metadata = TRUE, cl = NULL)

  expect_that(length(x) == 3, equals(TRUE))
  expect_that(length(x[[1]]) == 2, equals(TRUE))

  y <- x[[1]]

  expect_that(all(names(y) == c("data", "meta")), equals(TRUE))

  closeAllConnections()

})
