context("Test catalogue function")

test_that("Output of catalogue function is expected to be at least 1539x20", {

  catalogueall <- catalogue()
  expect_that(dim(catalogueall) >= c(1539, 23), equals(c(TRUE, TRUE)))

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
