context("Test coordinates")

test_that("Test grid references with different length", {

  gridRef <- "SN9491282412"
  # gridRef <- "SN94918241"
  # gridRef <- "SN949824"
  # gridRef <- "SN9482"


  expect_that(OSGparse("SN9491282412"),
              equals(structure(list(easting = 294912, northing = 282412),
                               .Names = c("easting", "northing"))))

  expect_that(OSGparse("SN94918241"),
              equals(structure(list(easting = 294910, northing = 282410),
                               .Names = c("easting", "northing"))))

  expect_that(OSGparse("SN949824"),
              equals(structure(list(easting = 294900, northing = 282400),
                               .Names = c("easting", "northing"))))

  expect_that(OSGparse("SN9482"),
              equals(structure(list(easting = 294000, northing = 282000),
                               .Names = c("easting", "northing"))))

  closeAllConnections()

})

test_that("Test grid references from various areas", {

  expect_that(OSGparse("TQ722213"),
              equals(structure(list(easting = 572200, northing = 121300),
                               .Names = c("easting", "northing"))))

  expect_that(OSGparse(c("SN831869","SN829838")),
              equals(structure(list(easting = c(283100, 282900),
                                    northing = c(286900, 283800)),
                               .Names = c("easting", "northing"))))

  closeAllConnections()

})
