test_that("extract_components-slow-multiF", {
  if (Sys.getenv("HDPX_LONG") == "") {
    # skip("Sys.setenv(HDPX_LONG=\"Y\") to enable long tests")
    # Sys.setenv(HDPX_LONG="Y")
  }

  in_env <- new.env()
  load("tdata/big.chlist.from.ParallelGibbsSample.multiF.Rdata", envir = in_env)

  reg2 <- new.env()
  load("tdata/output.multiF-1chain.Rdata", envir = reg2)

  ex.com.ret <-
    extract_components(sample.chains = in_env$chlist[[1]]) # Just one element
  if (FALSE) {
    # To re-generate test data:
    save(ex.com.ret, file = "tdata/output.multiF-1chain.Rdata")
  }

  expect_equal(ex.com.ret, reg2$ex.com.ret)

  reg3 <- new.env()
  load("tdata/output.interpret.multiF-1chain.Rdata", envir = reg3)

  in.com.ret <- interpret_components(ex.com.ret)

  if (FALSE) {
    # to regenerate test data
    save(in.com.ret, file = "tdata/output.interpret.multiF-1chain.Rdata")
  }

  expect_equal(in.com.ret, reg3$in.com.ret)
})
