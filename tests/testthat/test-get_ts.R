context("get_ts")

test_that("Check get_ts fails (gracefully) when it should", {

  rain <- get_ts(id = NULL, type = "cmr")
  expect_true(is.null(rain))

  rain <- get_ts(id = 0, type = "cmr")
  expect_true(is.null(rain))

  rain <- get_ts(id = 18019, type = "ndf")
  expect_true(is.null(rain))

})

test_that("get_ts cmr single works", {

  rain <- get_ts(id = 18019, type = "cmr")
  expect_true(class(rain) == "zoo")
  expect_true(length(rain) >= 660)

})

test_that("get_ts cmr multi works", {

  rain <- get_ts(id = c(54022, 54090, 54091), type = "cmr")
  expect_true(class(rain) == "list")
  expect_true(class(rain[[1]]) == "zoo")
  expect_true(length(rain[[1]]) >= 756)
  expect_true(length(rain[[2]]) >= 660)
  expect_true(length(rain[[3]]) >= 660)

})

test_that("get_ts gdf single works", {

  flow <- get_ts(id = 18019, type = "gdf")
  expect_true(class(flow) == "zoo")
  expect_equal(as.numeric(flow[1]), 0.056)
  expect_true(length(flow) >= 731)

})

test_that("get_ts gdf multi works", {

  flow <- get_ts(id = c(54022, 54090, 54091), type = "gdf")
  expect_true(class(flow) == "list")
  expect_true(class(flow[[1]]) == "zoo")
  expect_equal(as.numeric(flow[[1]][1]), 0.637)
  expect_true(length(flow[[1]]) >= 16855)
  expect_equal(as.numeric(flow[[2]][1]), 0.031)
  expect_true(length(flow[[2]]) >= 13159)
  expect_equal(as.numeric(flow[[3]][1]), 1.262)
  expect_true(length(flow[[3]]) >= 12416)

})

test_that("Check get_ts works with other types", {

  x1 <- get_ts(id = 43010, type = "amax-flow")
  expect_true(class(x1) == "zoo")
  x1 <- get_ts(id = 43010, type = "amax-flow", full_info = TRUE)
  expect_true(class(x1) == "zoo")
  expect_true(all(dim(x1) >= c(37, 2)))
  expect_equal(table(x1$rejected[1:37]),
               structure(c(25L, 12L), .Dim = 2L,
                         .Dimnames = structure(list(c("0", "1")), .Names = ""),
                         class = "table"))

  x2 <- get_ts(id = 43010, type = "pot-flow", full_info = TRUE)
  expect_true(class(x2) == "zoo")
  expect_equal(table(x2$rejected[1:11]),
               structure(c(1L, 10L), .Dim = 2L,
                         .Dimnames = structure(list(c("0", "1")), .Names = ""),
                         class = "table"))
  x3 <- get_ts(id = 72014, type = "pot-flow", full_info = TRUE)
  expect_equal(table(x3$rejected[1:176]),
               structure(c(`0` = 176L), .Dim = 1L,
                         .Dimnames = structure(list("0"), .Names = ""),
                         class = "table"))
})
