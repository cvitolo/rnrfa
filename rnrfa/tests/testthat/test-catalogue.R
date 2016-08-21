context("Test catalogue function")

test_that("Output of catalogue function is expected to be at least 1539x20", {

  expect_that(dim(catalogue()), equals(c(1539, 20)))

  closeAllConnections()

})

test_that("Check output of catalogue for minimum records of 100 years", {

  x <- catalogue(minRec=100)

  expect_that(all(c("Lee at Feildes Weir",
                    "Thames at Kingston",
                    "Elan at Caban Dam") %in% x$name), equals(TRUE))

  closeAllConnections()

})
