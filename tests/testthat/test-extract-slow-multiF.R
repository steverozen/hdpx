test_that("extract_components_from_clusters-slow-multiF", {
  if (Sys.getenv("HDPX_LONG") == "") {
    skip("Sys.setenv(HDPX_LONG=\"Y\") to enable long tests")
  }

  in_env <- new.env()
  load("tdata/big.chlist.from.ParallelGibbsSample.multiF.Rdata",
       envir = in_env)

  reg2 <- new.env()
  load("tdata/output.big.extract.multiF.p1.Rdata",
       envir = reg2)
  load("tdata/output.big.extract.multiF.p2.Rdata",
       envir = reg2)
  load("tdata/output.big.extract.multiF.p3.Rdata",
       envir = reg2)

  ex.com.ret <-
    extract_components_from_clusters(x = hdp_multi_chain(in_env$chlist), hc.cutoff = 0.10)
  ex.com.ret.p1 <- ex.com.ret[c(1:5,7)]
  ex.com.ret.p2 <- ex.com.ret[[6]]@chains[1:10]
  ex.com.ret.p3 <- ex.com.ret[[6]]@chains[11:20]

  if (FALSE) {
   # To re-generate test data:
   save(ex.com.ret.p1, file = "tdata/output.big.extract.multiF.p1.Rdata")
   save(ex.com.ret.p2, file = "tdata/output.big.extract.multiF.p2.Rdata")
   save(ex.com.ret.p3, file = "tdata/output.big.extract.multiF.p3.Rdata")
  }

  expect_equal(ex.com.ret.p1, reg2$ex.com.ret.p1)
  expect_equal(ex.com.ret.p2, reg2$ex.com.ret.p2)
  expect_equal(ex.com.ret.p3, reg2$ex.com.ret.p3)

  reg3 <- new.env()
  load("tdata/output.big.interpret.multiF.Rdata", envir = reg3)

  in.com.ret <- interpret_components(ex.com.ret)

  if (FALSE) { # to regenerate test data
    save(in.com.ret, file = "tdata/output.big.interpret.multiF.Rdata")
  }

  expect_equal(in.com.ret, reg3$in.com.ret)
})

