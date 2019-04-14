context("get_ts")

test_that("Check get_ts fails when it should", {
  
  rain <- try(get_ts(id = NULL, type = "cmr"), silent = TRUE)
  expect_true(class(rain) == "try-error")
  
  rain <- try(get_ts(id = 0, type = "cmr"), silent = TRUE)
  expect_true(class(rain) == "try-error")
  
  rain <- try(get_ts(id = 18019, type = "ndf"), silent = TRUE)
  expect_true(class(rain) == "try-error")
  
})

test_that("get_ts cmr single works", {

  rain <- get_ts(id = 18019, type = "cmr")
  expect_true(length(rain) >= 660)

})

test_that("get_ts cmr multi works", {

  rain <- get_ts(id = c(54022, 54090, 54091), type = "cmr")
  expect_true(length(rain[[1]]) >= 756)
  expect_true(length(rain[[2]]) >= 660)
  expect_true(length(rain[[3]]) >= 660)

})

test_that("get_ts gdf single works", {

  flow <- get_ts(id = 18019, type = "gdf")
  expect_equal(as.numeric(flow[1]), 0.056)
  expect_true(length(flow) >= 731)

})

test_that("get_ts gdf multi works", {

  flow <- get_ts(id = c(54022, 54090, 54091), type = "gdf")
  expect_equal(as.numeric(flow[[1]][1]), 0.637)
  expect_true(length(flow[[1]]) >= 16855)
  expect_equal(as.numeric(flow[[2]][1]), 0.031)
  expect_true(length(flow[[2]]) >= 13159)
  expect_equal(as.numeric(flow[[3]][1]), 1.262)
  expect_true(length(flow[[3]]) >= 12416)

})

test_that("get_ts gdf works in parallel", {
  
  s <- try(gdf(id = c(54022, 54090, 54091), cl = 3), silent = TRUE)
  expect_equal(class(s), "try-error")
  
  cl <- parallel::makeCluster(getOption("cl.cores", 1))
  s <- gdf(id = c(54022, 54090, 54091), cl = cl)
  parallel::stopCluster(cl)
  expect_equal(length(s), 3)
  
})
