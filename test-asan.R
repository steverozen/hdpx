#!/usr/bin/env Rscript
# Test script to verify AddressSanitizer is working

cat("=== AddressSanitizer Verification Test ===\n\n")

# Check if ASAN library is preloaded
ld_preload <- Sys.getenv("LD_PRELOAD")
if (ld_preload != "") {
  cat("✓ LD_PRELOAD is set to:", ld_preload, "\n")
} else {
  cat("✗ WARNING: LD_PRELOAD is not set!\n")
  cat("  ASAN may not be properly loaded.\n")
}

# Check if libasan is actually loaded
cat("\nChecking loaded libraries for libasan...\n")
system("cat /proc/$PPID/maps | grep libasan || echo '✗ libasan NOT found in process memory'")

cat("\n=== Loading hdpx package ===\n")
devtools::load_all()

cat("\n=== Running ASAN test (heap-buffer-overflow) ===\n")
cat("This should trigger an AddressSanitizer error if it's working:\n\n")

# This will cause a crash with ASAN enabled
test_asan_overflow()

cat("\n✗ If you see this message, ASAN is NOT working properly!\n")
cat("   (The program should have crashed with an ASAN error report)\n")
