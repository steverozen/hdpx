# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`hdpx` is an R package implementing hierarchical Dirichlet process (HDP) mixture models for categorical count data. It is primarily used for mutational signature discovery in genomics (via the companion package `mSigHdp`). The package is Linux-only and combines R code with C implementations of core Gibbs sampling algorithms.

**Key features:**
- Model categorical count data with HDP mixture models
- Initialize HDP with custom tree structures
- Perform Gibbs sampling of posterior distributions
- Extract and visualize components (mutation signatures)
- Combine raw clusters from posterior samples into interpretable components

## Package Installation

Users install from GitHub:
```R
remotes::install_github(repo = "steverozen/hdpx")
```

BioConductor repositories must be available (`setRepositories()`).

## Architecture

### Code Organization

**R code** (`R/` directory):
- `aaa-classes-*.R` - S4 class definitions (must load first due to naming)
- `aaa-generics-*.R` - S4 generic method definitions
- `hdp_init.R`, `hdp_adddp.R`, `hdp_addconparam.R` - HDP structure initialization
- `hdp_setdata.R` - Assign data to DP nodes
- `dp_activate.R`, `dp_freeze.R` - Control which DPs are sampled
- `hdp_burnin.R`, `hdp_posterior_sample.R` - Gibbs sampling
- `hdp_multi_chain.R` - Run multiple independent chains
- `extract_components.R` - Combine raw clusters into components (major enhancement over original)
- `plot_*.R` - Visualization functions
- `RcppExports.R` - Auto-generated Rcpp interface (DO NOT EDIT BY HAND)
- `zzz.R` - Package loading hooks (initializes Stirling number closure)

**C/C++ code** (`src/` directory):
- `R-hdp.c` - Main HDP structure and operations (from Yee Whye Teh)
- `R-dp.c` - Individual DP operations
- `R-base.c` - Base distribution handling
- `R-conparam.c` - Concentration parameter sampling
- `R-multinomial.c` - Multinomial distribution operations
- `R-hdpMultinomial_iterate.c` - Core Gibbs iteration (called from R)
- `R-utils.c` - Utility functions, debugging
- `randutils.c` - Random number utilities
- `cosCpp.cpp` - Rcpp/Armadillo cosine similarity (fast matrix operations)
- `RcppExports.cpp` - Auto-generated Rcpp glue (DO NOT EDIT BY HAND)

**Test data** (`tests/testthat/`):
- `.Rdata` files contain expected outputs for regression testing
- Test scripts verify posterior sampling, component extraction

### Key S4 Classes

**Input classes** (defined in `aaa-classes-input.R`):
- `hdpBase` - Base Dirichlet distribution with pseudocounts `hh`
- `hdpConparam` - Concentration parameter with gamma prior (alphaa, alphab)
- `hdpDP` - Individual DP node with data assignments and cluster allocations
- `hdpState` - Complete HDP structure (tree of DPs, data, parameters)

**Output classes** (defined in `aaa-classes-output.R`):
- `hdpSampleChain` - Posterior samples from a single Gibbs chain
- `hdpSampleMulti` - Multiple independent chains for convergence assessment

### Workflow

1. **Initialize HDP structure**: `hdp_init()` or `hdp_prior_init()` or `hdp_quick_init()`
   - Define tree structure via parent indices (`ppindex`)
   - Assign concentration parameters via `cpindex`
   - Set base distribution pseudocounts (`hh`)

2. **Add data**: `hdp_setdata()`
   - Assign categorical count data to DP nodes

3. **Activate DPs**: `dp_activate()`
   - Mark which DPs participate in sampling

4. **Burn-in**: `hdp_burnin()`
   - Run initial Gibbs iterations to reach stationary distribution

5. **Posterior sampling**: `hdp_posterior_sample()` or `hdp_multi_chain()`
   - Collect samples from posterior (with spacing to reduce autocorrelation)
   - Can run multiple independent chains for diagnostics

6. **Extract components**: `extract_components()`
   - Merge nearly-identical raw clusters across posterior samples
   - Hierarchical clustering to identify stable components
   - Major innovation by Rozen/Liu over original Roberts implementation

7. **Visualize**: `plot_*()` functions
   - `plot_lik()` - Likelihood traces
   - `plot_numcluster()` - Number of clusters over iterations
   - `plot_comp_distn()` - Component distributions (signatures)
   - `plot_dp_comp_exposure()` - Component exposures per DP

## Development Commands

### Build and Check
```bash
# Build package
R CMD build .

# Check package (from parent directory)
R CMD check hdpx_*.tar.gz

# Install locally
R CMD INSTALL .
```

### Testing
```bash
# Run all tests
Rscript -e "devtools::test()"

# Run specific test file
Rscript -e "testthat::test_file('tests/testthat/test-extract_components.R')"
```

### Documentation
```bash
# Regenerate documentation from roxygen2 comments
Rscript -e "devtools::document()"
```

### Rcpp
After modifying C++ code with `// [[Rcpp::export]]`:
```R
Rcpp::compileAttributes()  # Regenerates RcppExports.R and RcppExports.cpp
devtools::document()       # Update documentation
```

## Important Implementation Details

### Memory Management in C Code

**Critical**: The C code uses R's memory allocation (`R_alloc`, `Calloc`, `Free`) and must properly manage SEXP objects.

- Original code had garbage collection issues (fixed by Rozen/Liu)
- C functions receive SEXP objects from R and return SEXPs
- Use `PROTECT()`/`UNPROTECT()` for temporary SEXPs
- See `src/R-hdp.c` functions `rReadHDP()` and `rWriteHDP()` for SEXP marshaling

### Debugging

C code uses `rdebug*()` macros controlled by global `hdpx_debug` variable:
- `rdebug0(level, ...)` - Basic debug print
- Set verbosity in R functions (e.g., `post.verbosity` parameter)
- Higher levels = more verbose (0-4 range)

### Stirling Numbers

Package computes unsigned Stirling numbers of the first kind:
- Implemented in `R/xmake.s.R`
- Closure created in `.onLoad()` hook (`R/zzz.R`)
- Stored as `stir.closure` in package namespace

### Component Extraction Algorithm

The `extract_components()` function uses a multi-stage process:

1. **Identical merge** (threshold ~0.99): Merge essentially duplicate raw clusters
2. **Nearly-identical merge** (threshold ~0.97): Merge very similar clusters
3. **Hierarchical clustering** (cutoff ~0.90): Group related clusters
4. **Discard singletons** (optional): Remove isolated clusters

Thresholds controlled via `default_merge_raw_cluster_args()`. These defaults differ from `mSigHdp` defaults - users should check both packages.

### Cosine Similarity

Fast cosine similarity via Rcpp/Armadillo (`src/cosCpp.cpp`):
- Computes pairwise cosine between columns of matrix
- Used extensively in component extraction
- Efficient matrix operations via Armadillo

## Common Development Tasks

### Adding a New R Function

1. Write function in appropriate `R/*.R` file
2. Add roxygen2 documentation (`#'` comments)
3. Export if needed: `#' @export`
4. Run `devtools::document()` to update `NAMESPACE` and `man/`
5. Add tests in `tests/testthat/`

### Modifying C Code

1. Edit `src/R-*.c` or `src/R-*.h` files
2. Maintain existing memory management patterns
3. Use `rdebug*()` macros for debugging output
4. Test thoroughly - C bugs can crash R sessions
5. Run `R CMD check` to verify memory issues (use valgrind if available)

### Adding Rcpp Functions

1. Create `.cpp` file in `src/` or add to existing
2. Add `// [[Rcpp::export]]` above function
3. Run `Rcpp::compileAttributes()` - regenerates exports
4. R function automatically available (same name)
5. Document in R file if needed for user-facing functions

### Updating Tests

- Test data in `tests/testthat/*.Rdata` are expected outputs
- To update: run test interactively, save new expected output
- Always verify changes make sense before committing
- Some tests marked "slow" - can skip for quick checks

## Package Dependencies

**Key dependencies:**
- `Rcpp`, `RcppArmadillo` - C++ integration and linear algebra
- `methods` - S4 object system
- `coda` - MCMC diagnostics
- `cluster`, `dendextend` - Hierarchical clustering
- `ICAMS` - Mutational signature analysis
- `ggplot2`, `beeswarm` - Visualization

## Version History

See `NEWS.md` for detailed changes. Key milestones:
- 1.0.5: Removed deprecated `x` argument, simplified extraction
- 1.0.3: Fixed `DEBUG` global variable conflict
- 0.3.x: Evolved component extraction algorithm

## Related Packages

- `mSigHdp` - User-facing package for mutational signatures (calls hdpx)
- Users should generally use `mSigHdp` rather than `hdpx` directly

## File Naming Conventions

- Files starting with `aaa-` load first (class/generic definitions)
- Files with `utilities` are helper functions
- Files prefixed with `hdp_` are core workflow functions
- Files prefixed with `plot_` are visualization
