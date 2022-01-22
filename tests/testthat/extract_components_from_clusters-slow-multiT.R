test_that("extract_components_from_clusters-slow-multiF", {
  if (Sys.getenv("HDPX_LONG") == "") {
    skip("Sys.setenv(HDPX_LONG=\"Y\") to enable long tests")
  }

  in_env <- new.env()
  load("tdata/big.chlist.from.ParallelGibbsSample.multiT.Rdata",
       envir = in_env)

  reg2 <- new.env()
  load("tdata/output.big.extract.multiT.Rdata", envir = reg2)

  ex.com.ret <-
    extract_components_from_clusters(x = in_env$chlist, hc.cutoff = 0.10)

  # To re-generate test data:
  # save(ex.com.ret, file = "tdata/output.big.extract.multiT.Rdata")

  expect_equal(ex.com.ret, reg2$ex.com.ret)

  reg3 <- new.env()
  load("tdata/output.big.interpret.multiT.Rdata", envir = reg3)

  in.com.ret <- interpret_components(ex.com.ret)

  # save(in.com.ret, file = "tdata/output.big.interpret.multiT.Rdata")
  expect_equal(in.com.ret, reg3$in.com.ret)
})

