
test_that("extract_components_from_clusters", {

  reg <- new.env()
  load("test.MultipleSetupAndPosterior.Rdata", envir = reg)##This input is taken from mSigHdp

  reg2 <- new.env()
  load("extract_components_from_clusters.expected.Rdata", envir = reg2)

  x <- hdpx::hdp_multi_chain(reg$retvalx)
  retvalx <- extract_components_from_clusters(x = x, hc.cutoff = 0.10)

  # save(retvalx, file = "extract_components_from_clusters.expected.Rdata")

  expect_equal(retvalx, reg2$retvalx)

  reg3 <- new.env()
  load("interpret_components_retval2.Rdata", envir = reg3)

  retval2 <- interpret_components(retvalx)

  # save(retval2, file = "interpret_components_retval2.Rdata")
  expect_equal(retval2, reg3$retval2)
})
