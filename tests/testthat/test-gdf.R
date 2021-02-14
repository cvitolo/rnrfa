context("Test gdf function")

test_that("Output of gdf function for id 18019", {

  # All defaults
  x1 <- gdf(id = 18019, metadata = FALSE, cl = NULL, verbose = FALSE)
  expect_true("zoo" %in% class(x1))
  expect_true(all(dim(x1) >= c(731, 1)))

  x2 <- gdf(id = 18019, metadata = TRUE, cl = NULL, verbose = FALSE)
  expect_true("list" %in% class(x2))
  expect_equal(length(x2), 2)

})

test_that("get_ts gdf works in parallel", {

  skip_on_os("windows")

  s <- try(gdf(id = c(54022, 54090, 54091), cl = 3), silent = TRUE)
  expect_equal(class(s), "try-error")

  cl <- parallel::makeCluster(getOption("cl.cores", 1))
  s <- gdf(id = c(54022, 54090, 54091), cl = cl)
  parallel::stopCluster(cl)
  expect_equal(length(s), 3)

})
