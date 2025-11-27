test_that("edge_case_only_1_cluster", {
  degenerate_input_catalog =
    read.csv("tdata/ground.truth.syn.catalog.csv")[, c(
      3,
      3
    )]

  options(error = browser)
  options(error = recover)
  retvalx <- RunHdpxParallel(
    input.catalog = degenerate_input_catalog,
    CPU.cores = 1,
    seedNumber = 44,
    K.guess = 5,
    multi.types = FALSE,
    verbose = FALSE,
    num.child.process = 1,
    burnin = 50, # Super low for fast testing
    post.space = 5, # Low for fast testing
    post.cpiter = 1, # Low for fast testing
    overwrite = TRUE,
    checkpoint = FALSE,
    downsample_threshold = 1e6, # Very high; should have no effect
    out.dir = tempfile()
  )

  if (FALSE) {
    # To regenerate test data
    save(
      retvalx,
      file = "RunhdpInternal.testdata/NewRunHdpParallel-fast96-2-cores.Rdata"
    )
  }
  expect_equal(retvalx, reg$retvalx)
})
