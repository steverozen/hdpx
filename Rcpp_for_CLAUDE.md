# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This directory contains the R C API header files (version 4.5.2) used for developing R packages that interface with C/C++ code. These headers define the internal structures, types, and functions that comprise the R programming language's C-level interface.

## Directory Structure

- `/usr/share/R/include/` - Main include directory
  - `R.h` - Primary header that should be included in most C code interfacing with R
  - `Rinternals.h` - Core internal structures and API functions (SEXP types, memory management, etc.)
  - `Rdefines.h` - Legacy S-like macros (no longer maintained)
  - `Rembedded.h` - Functions for embedding R in other applications
  - `Rmath.h` - Mathematical functions from R's math library
  - `Rconfig.h` - Configuration settings for this R installation
  - `Rversion.h` - Version information
- `/usr/share/R/include/R_ext/` - Extension headers for specific functionality
  - `Rdynload.h` - Dynamic loading and routine registration for packages
  - `GraphicsDevice.h` - Device driver structures and API
  - `GraphicsEngine.h` - Graphics engine API (includes GraphicsDevice.h)
  - `BLAS.h` / `Lapack.h` - Linear algebra routines
  - `Arith.h` - Arithmetic operations and special values (NA, NaN, Inf)
  - `Error.h` - Error handling and warnings
  - `Memory.h` - Memory allocation functions
  - `Print.h` - Printing functions (Rprintf, etc.)
  - `Random.h` - Random number generation
  - `Utils.h` - Utility functions (sorting, etc.)
  - `Altrep.h` - Alternative representation framework for vectors
  - `Callbacks.h` - Callback mechanisms
  - `Connections.h` - Connection objects for I/O

## Key Architecture Concepts

### SEXP Types
The fundamental data structure in R's C API is SEXP (S-expression). All R objects are represented as SEXPs at the C level. Key types defined in Rinternals.h include:
- `NILSXP` - NULL
- `SYMSXP` - symbols
- `LISTSXP` - pairlists
- `CLOSXP` - closures (functions)
- `ENVSXP` - environments
- `PROMSXP` - promises (lazy evaluation)
- `LGLSXP` - logical vectors
- `INTSXP` - integer vectors
- `REALSXP` - numeric vectors
- `CPLXSXP` - complex vectors
- `STRSXP` - character vectors
- `VECSXP` - lists
- `EXPRSXP` - expressions

### Vector Length Types
- `R_len_t` - Standard vector length type (int, max 2^31-1)
- `R_xlen_t` - Extended length type for long vectors (ptrdiff_t on 64-bit systems)
- Long vector support is enabled when `SIZEOF_SIZE_T > 4`

### Memory Management
R uses a garbage collector. Key principles:
- Use `PROTECT()`/`UNPROTECT()` to prevent collection of newly created objects
- Alternative: use `R_PreserveObject()`/`R_ReleaseObject()` for persistent objects
- Memory allocation: use `R_alloc()` or `Calloc()`/`Free()` macros from R_ext/RS.h

### Package Registration
When creating R packages with C code, register native routines using `R_registerRoutines()` defined in R_ext/Rdynload.h. This involves creating tables of:
- `R_CMethodDef` - C functions called via `.C()`
- `R_CallMethodDef` - C functions called via `.Call()`
- `R_FortranMethodDef` - Fortran routines called via `.Fortran()`
- `R_ExternalMethodDef` - C functions called via `.External()`

### Graphics System
The graphics system has two layers:
1. **GraphicsDevice.h** - Defines `DevDesc` structure for implementing graphics devices
2. **GraphicsEngine.h** - Defines `GEDevDesc` and the graphics engine API (must be included before GraphicsDevice.h)

## Important Header Inclusion Rules

1. **For most R package C code**: Include `<R.h>` first, which pulls in necessary standard headers and R basics
2. **For internal API access**: Include `<Rinternals.h>` (this includes R.h)
3. **Graphics devices**: Include `<R_ext/GraphicsEngine.h>` (not GraphicsDevice.h directly)
4. **Never include both**: R.h and S.h (these are mutually exclusive)
5. **C++ code**: Headers are compatible with C++ and use `extern "C"` blocks appropriately

## Common Usage Patterns

### Basic R Package C Code Structure
```c
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

// Your C function callable from R via .Call()
SEXP my_function(SEXP arg1, SEXP arg2) {
    // Protect objects you create
    SEXP result = PROTECT(allocVector(REALSXP, n));
    // ... do work ...
    UNPROTECT(1);
    return result;
}

// Registration
static const R_CallMethodDef CallEntries[] = {
    {"my_function", (DL_FUNC) &my_function, 2},
    {NULL, NULL, 0}
};

void R_init_mypackage(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
```

### Working with Vectors
```c
// Access numeric vector data
double *ptr = REAL(vec);
// Access integer vector data
int *iptr = INTEGER(vec);
// Get length
R_xlen_t len = XLENGTH(vec);
```

## API Stability

- Functions and macros documented in "Writing R Extensions" are part of the official API
- Many definitions in these headers are internal and not guaranteed stable
- The `Rdefines.h` header is no longer maintained; use Rinternals.h instead
- Check R_ext/Visibility.h for controlling symbol visibility in packages

## Documentation References

- Official documentation: "Writing R Extensions" manual (Chapter 6 covers the R API)
- R Internals manual for deeper implementation details
- API functions are those explicitly documented as part of the API
- Headers contain both API and internal definitions
