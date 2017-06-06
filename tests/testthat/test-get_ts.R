context("get_ts")

test_that("get_ts cmr single works", {
  
  rain <- rnrfa:::get_ts(id = 18019, type = "cmr")
  expect_equal(as.numeric(rain[1]), 410)
  
})

test_that("get_ts cmr multi works", {
  
  rain <- rnrfa:::get_ts(id = c(54022,54090,54091), type = "cmr")
  expect_equal(as.numeric(rain[[1]][1]), 114)
  expect_equal(as.numeric(rain[[2]][1]), 178)
  expect_equal(as.numeric(rain[[3]][1]), 320)
  
})

test_that("get_ts gdf single works", {
  
  flow <- rnrfa:::get_ts(id = 18019, type = "gdf")
  expect_equal(as.numeric(flow[1]), 0.056)
  
})

test_that("get_ts gdf multi works", {
  
  flow <- rnrfa:::get_ts(id = c(54022,54090,54091), type = "gdf")
  expect_equal(as.numeric(flow[[1]][1]), 0.637)
  expect_equal(as.numeric(flow[[2]][1]), 0.031)
  expect_equal(as.numeric(flow[[3]][1]), 1.262)
  
})
