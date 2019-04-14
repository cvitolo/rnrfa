context("test-internals.R")

test_that("internal fails when it should", {
  parameters <- list(format = "json-object", station = "*", fields = "all")
  response <- try(nrfa_api(webservice = "stations-info", parameters),
                  silent = TRUE)
  expect_equal(class(response), "try-error")
})
