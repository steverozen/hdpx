test_that("extract_components_from_clusters-slow-multiT", {
  if (Sys.getenv("HDPX_LONG") == "") {
    skip("Sys.setenv(HDPX_LONG=\"Y\") to enable long tests")
  }

  in_env <- new.env()
  load("tdata/big.chlist.from.ParallelGibbsSample.multiT.Rdata",
       envir = in_env)

  reg2 <- new.env()
  load("tdata/output.big.extract.multiT.p1.Rdata",
       envir = reg2)
  load("tdata/output.big.extract.multiT.p2.Rdata",
       envir = reg2)
  load("tdata/output.big.extract.multiT.p3.Rdata",
       envir = reg2)
  load("tdata/output.big.extract.multiT.p4.Rdata",
       envir = reg2)

  ex.com.ret <-
    extract_components_from_clusters(x = hdp_multi_chain(in_env$chlist), hc.cutoff = 0.10)
  ex.com.ret.p1 <- ex.com.ret[c(1:5,7)]
  ex.com.ret.p2 <- ex.com.ret[[6]]@chains[1:6]
  ex.com.ret.p3 <- ex.com.ret[[6]]@chains[7:13]
  ex.com.ret.p4 <- ex.com.ret[[6]]@chains[14:20]


  # To re-generate test data
  if (FALSE) {
    save(ex.com.ret.p1, file = "tdata/output.big.extract.multiT.p1.Rdata")
    save(ex.com.ret.p2, file = "tdata/output.big.extract.multiT.p2.Rdata")
    save(ex.com.ret.p3, file = "tdata/output.big.extract.multiT.p3.Rdata")
    save(ex.com.ret.p4, file = "tdata/output.big.extract.multiT.p4.Rdata")
  }

  expect_equal(ex.com.ret.p1, reg2$ex.com.ret.p1)
  expect_equal(ex.com.ret.p2, reg2$ex.com.ret.p2)
  expect_equal(ex.com.ret.p3, reg2$ex.com.ret.p3)
  expect_equal(ex.com.ret.p4, reg2$ex.com.ret.p4)

  reg3 <- new.env()
  load("tdata/output.big.interpret.multiT.Rdata", envir = reg3)

  in.com.ret <- interpret_components(ex.com.ret)

  if (FALSE) { # Regenerate test data
    save(in.com.ret, file = "tdata/output.big.interpret.multiT.Rdata")
  }

  expect_equal(in.com.ret, reg3$in.com.ret)
})

