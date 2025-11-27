test_that("degenerate_extract_components", {
  testthat::local_edition(3)
  # usethis::use_testthat(edition = 3)
  args = readRDS("tdata/degenerate_input_for_extract_components.rds")

  retvalx <- extract_components(
    sample.chains = args$multi.chains,
    args$merge.raw.cluster.args
  )
  options(digits = 7)
  expect_snapshot(retvalx)
})
