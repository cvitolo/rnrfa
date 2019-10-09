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

    expect_that(osg_parse(c("SN831869", "SN829838")),
                equals(structure(list(easting = c(283100, 282900),
                                      northing = c(286900, 283800)),
                                 .Names = c("easting", "northing"))))

    closeAllConnections()

})



# crs 4326
wgs <- matrix(c(18.5, 54.2,
                113.4, 46.78,
                16.9, 67.8),
              byrow = TRUE, ncol = 2, dimnames = list(NULL, c("x", "y")))

# correct values from https://mygeodata.cloud/cs2cs/
# crs 3034
lcceu <- matrix(c(4535410.16093, 3067447.25856,
                  9382256.98256, 6769270.46095,
                  4295683.24203, 4544089.18176),
                byrow = TRUE, ncol = 2, dimnames = list(NULL, c("x", "y")))

# crs 3416
lccat <- matrix(c(739233.098505, 1158123.41459,
                  6096512.30717, 4595909.41132,
                  562300.406341, 2719066.06187),
                byrow = TRUE, ncol = 2, dimnames = list(NULL, c("x", "y")))


test_that("conversion works for single crs", {
    tr <- .transform_crs(x = wgs[, "x"], y = wgs[, "y"], from = 4326, to = 3034)
    rownames(tr) <- NULL
    expect_equal(round(tr, 4), round(as.data.frame(lcceu), 4))
})


test_that("conversion works for multiple crs", {
    input <- data.frame(rbind(wgs, wgs),
                        crs = c(rep(3034, times = nrow(lcceu)),
                                rep(3416, times = nrow(lccat))))
    idx <- sample(nrow(input))
    input <- input[idx, ]

    tr <- .transform_crs(x = input$x, y = input$y, from = 4326, to = input$crs)
    rownames(tr) <- NULL
    expect_equal(round(tr, 4),
                 as.data.frame(round(rbind(lcceu, lccat)[idx, ], 4)))
})
