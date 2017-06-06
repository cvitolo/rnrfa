context("get_ts")

test_that("get_ts cmr single works", {
  
  rain <- rnrfa:::get_ts(id = 18019, type = "cmr")
  test <- structure(410, class = c("xts", "zoo"), 
                    .indexCLASS = c("POSIXlt", "POSIXt"), 
                    tclass = c("POSIXlt", "POSIXt"), 
                    .indexTZ = "", 
                    tzone = "", 
                    index = structure(504921600, tzone = "", 
                                      tclass = c("POSIXlt", "POSIXt")), 
                    .Dim = c(1L, 1L))
  
  expect_equal(rain[1,], test)
  
})

test_that("get_ts cmr multi works", {
  
  rain <- rnrfa:::get_ts(id = c(54022,54090,54091), type = "cmr")
  test <- structure(c(114, 249, 76, 246, 213, 180), 
                    class = c("xts", "zoo"), 
                    .indexCLASS = c("POSIXlt", "POSIXt"),
                    tclass = c("POSIXlt", "POSIXt"), 
                    .indexTZ = "", 
                    tzone = "", 
                    index = structure(c(-512874000, -510192000, -507600000, 
                                        -504921600, -502243200, -499824000), 
                                      tzone = "", 
                                      tclass = c("POSIXlt", "POSIXt")), 
                    .Dim = c(6L, 1L))
  
  expect_equal(head(rain[[1]]), test)
  
})

test_that("get_ts gdf single works", {
  
  flow <- rnrfa:::get_ts(id = 18019, type = "gdf")
  test <- structure(0.056, 
                    class = c("xts", "zoo"), 
                    .indexCLASS = c("POSIXlt", "POSIXt"), 
                    tclass = c("POSIXlt", "POSIXt"), 
                    .indexTZ = "", 
                    tzone = "", 
                    index = structure(536457600, 
                                      tzone = "", 
                                      tclass = c("POSIXlt", "POSIXt")), 
                    .Dim = c(1L, 1L))
  
  expect_equal(flow[1,], test)
  
})

test_that("get_ts gdf multi works", {
  
  flow <- rnrfa:::get_ts(id = c(54022,54090,54091), type = "gdf")
  test <- structure(c(0.637, 0.413, 0.286, 0.238, 0.193, 0.15), 
                    class = c("xts", "zoo"), 
                    .indexCLASS = c("POSIXlt", "POSIXt"), 
                    tclass = c("POSIXlt", "POSIXt"), 
                    .indexTZ = "", 
                    tzone = "", 
                    index = structure(c(-512874000, -512787600, -512701200, 
                                        -512614800, -512524800, -512438400), 
                                      tzone = "", 
                                      tclass = c("POSIXlt", "POSIXt")), 
                    .Dim = c(6L, 1L))
  
  expect_equal(head(flow[[1]]), test)
  
})
