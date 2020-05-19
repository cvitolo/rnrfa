context("Test catalogue function")

test_that("Output of catalogue function is expected to be at least 1539x20", {

  catalogueall <- catalogue()
  expect_that(dim(catalogueall) >= c(1580, 99), equals(c(TRUE, TRUE)))

})

test_that("Check output of catalogue for Plynlimon area", {

  expect_that(dim(catalogue(bbox = list(lon_min = -3.82, lon_max = -3.63,
                                        lat_min = 52.43, lat_max = 52.52)))[1],
              equals(9))

})

test_that("Check output of catalogue for minimum records of 100 years", {

  x <- catalogue(min_rec = 100)

  expect_that(all(c("Lee at Feildes Weir",
                    "Thames at Kingston",
                    "Elan at Caban Dam") %in% x$name), equals(TRUE))

})

test_that("Check the catalogue function fails when it should", {

  x <- try(catalogue(column_name = "river"), silent = TRUE)
  expect_equal(class(x), "try-error")

  x <- try(catalogue(column_value = "Wye"), silent = TRUE)
  expect_equal(class(x), "try-error")

})

test_that("Check the catalogue function filters based on column values", {

  x <- catalogue(column_name = "river", column_value = "Wye")
  expect_true(dim(x)[1] >= 12)

  x <- catalogue(column_name = "catchment-area", column_value = "<1000")
  expect_true(dim(x)[1] >= 114)

  x <- catalogue(column_name = "catchment-area", column_value = ">=1000")
  expect_true(dim(x)[1] >= 114)

})
