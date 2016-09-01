context("Test coordinates")

test_that("Test grid references with different length", {

  expect_that(osg_parse("SN9491282412"),
              equals(structure(list(easting = 294912, northing = 282412),
                               .Names = c("easting", "northing"))))

  expect_that(osg_parse("SN94918241"),
              equals(structure(list(easting = 294910, northing = 282410),
                               .Names = c("easting", "northing"))))

  expect_that(osg_parse("SN949824"),
              equals(structure(list(easting = 294900, northing = 282400),
                               .Names = c("easting", "northing"))))

  expect_that(osg_parse("SN9482"),
              equals(structure(list(easting = 294000, northing = 282000),
                               .Names = c("easting", "northing"))))

  closeAllConnections()

})

test_that("Test grid references from various areas", {

  expect_that(osg_parse("TQ722213"),
              equals(structure(list(easting = 572200, northing = 121300),
                               .Names = c("easting", "northing"))))

  expect_that(osg_parse(c("SN831869","SN829838")),
              equals(structure(list(easting = c(283100, 282900),
                                    northing = c(286900, 283800)),
                               .Names = c("easting", "northing"))))

  closeAllConnections()

})
