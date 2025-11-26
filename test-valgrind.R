#!/usr/bin/env Rscript
# Test script for Valgrind memory checking

cat("=== Valgrind Memory Check Test ===\n\n")

cat("Loading hdpx package...\n")
devtools::load_all()

cat("\n=== Running basic hdpx test ===\n")
# Run a simple test that exercises memory allocation
my_hdp <- hdp_init(ppindex=0, cpindex=1, hh=rep(1, 6),
                   alphaa=rep(1, 3), alphab=rep(2, 3))
my_hdp <- hdp_adddp(my_hdp, 2, 1, 2)

cat("\nTest completed. Check valgrind-hdpx.log for results.\n")
cat("To see leak summary, run: grep -A 20 'LEAK SUMMARY' valgrind-hdpx.log\n")
