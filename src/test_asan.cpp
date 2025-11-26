// Test function to verify AddressSanitizer is working
// This deliberately causes a heap-buffer-overflow
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void test_asan_overflow() {
  int *array = new int[10];
  // Deliberate buffer overflow - accessing element 10 in array of size 10
  array[10] = 42;  // This should trigger ASAN if it's working
  delete[] array;
  Rprintf("If you see this without an ASAN error, ASAN is NOT working\n");
}

// [[Rcpp::export]]
void test_asan_use_after_free() {
  int *ptr = new int(42);
  delete ptr;
  // Deliberate use-after-free
  *ptr = 100;  // This should trigger ASAN if it's working
  Rprintf("If you see this without an ASAN error, ASAN is NOT working\n");
}
