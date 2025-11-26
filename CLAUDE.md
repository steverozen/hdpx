# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

hdpx is an R package implementing hierarchical Dirichlet process (HDP) mixture models for categorical count data. Linux-only support. Primary use case is mutational signature discovery (via the mSigHdp wrapper package). The codebase combines R with C code from Yee Whye Teh's original implementation.

## Building and Testing

### Standard R Package Commands
```r
# Install dependencies (requires BioConductor repositories)
setRepositories()  # Choose BioC items
remotes::install_github(repo = "steverozen/hdpx")

# Development workflow
devtools::document()        # Update documentation via roxygen2
devtools::load_all()        # Load package for testing
devtools::test()            # Run all tests
devtools::check()           # Full R CMD check
devtools::build()           # Build source package
devtools::install()         # Install locally

# Run specific test file
testthat::test_file("tests/testthat/test-extract_components.R")
```

### Rcpp/C Code
- Run `Rcpp::compileAttributes()` after modifying C++ functions exported to R
- C code in `src/R-*.c` files is from Teh's original implementation
- Custom C++ is in `src/cosCpp.cpp` (cosine similarity calculation)
- Main C interface: `src/R-hdpMultinomial_iterate.c` registered in NAMESPACE via `useDynLib(hdpx, hdpMultinomial_iterate)`

## Key Architecture

### HDP Tree Structure and S4 Classes

The package uses S4 classes extensively. All class definitions are in `R/aaa-classes-*.R` (loaded first per COLLATE order):

- **hdpState**: Container for the entire HDP model configuration before sampling
- **hdpSampleChain**: Results from one posterior sampling chain
- **hdpSampleMulti**: Collection of multiple independent chains
- **hdpBase**: Base Dirichlet distribution parameters (`hh` pseudocounts)
- **hdpConparam**: Concentration parameters with gamma priors (`alphaa`, `alphab`)
- **hdpDP**: Individual DP node (contains data assignments, cluster allocations)

### Typical HDP Workflow

1. **Initialization** (`hdp_init`, `hdp_quick_init`, or `hdp_prior_init`):
   - Define tree structure via `ppindex` (parent indices, 0 = base distribution)
   - Assign concentration parameters via `cpindex`
   - Set base Dirichlet parameters `hh` (like pseudocounts across categories)

2. **Setup** (`hdp_adddp`, `hdp_addconparam`, `hdp_setdata`):
   - Add more DP nodes to the tree
   - Optionally add concentration parameters
   - Assign data to DP nodes

3. **Activation** (`dp_activate`):
   - Mark which DPs participate in posterior sampling (vs held-out)

4. **Sampling** (`hdp_posterior`):
   - Run Gibbs sampler: burnin iterations + collect `n` samples with `space` between
   - Returns hdpSampleChain object
   - Calls C code via `.Call('hdpMultinomial_iterate')`

5. **Multi-chain** (`hdp_multi_chain`):
   - Combine independent chains (different seeds) into hdpSampleMulti

6. **Component Extraction** (`extract_components`):
   - Merges "raw clusters" from posterior samples into interpretable "components"
   - Three-stage process: merge nearly identical → hierarchical clustering → aggregate
   - Key parameters: `identical.cutoff`, `nearly.identical.cutoff`, `clustering.cutoff`
   - Returns updated hdpSampleMulti with component information

7. **Visualization** (plot_* functions):
   - `plot_lik`, `plot_numcluster`, `plot_data_assigned`: Chain diagnostics
   - `plot_comp_distn`, `plot_dp_comp_exposure`: Component results

### Critical Implementation Details

**Stirling Numbers**: Custom implementation in `R/xmake.s.R`, initialized in `.onLoad()` (`R/zzz.R`). This table is used by C code and must be pre-computed at package load.

**Component Extraction Algorithm** (`R/extract_components.R`):
- Most complex part of the package (complete rewrite from original hdp)
- Stage 1: Merge nearly identical raw clusters within each chain (cosine similarity)
- Stage 2: Hierarchical clustering across chains
- Stage 3: Aggregate into final components
- Performance-critical functions: `first_merge()` (optimized), `cosCpp()` (C++)

**C Code Interface** (`src/R-hdp.c` and related files):
- Original Teh code with minimal modifications
- Key structure: `HDP` (in C) maps to hdpState (in R)
- Garbage collection fixes were made to prevent memory leaks in R-C interface
- Do not modify C code unless absolutely necessary; it's stable and validated

**Memory Management**:
- S4 objects use validation functions (see `validity=` in class definitions)
- Protect/unprotect pattern in original code (not visible in modern Rcpp parts)

## File Organization

- `R/aaa-*.R`: Class definitions, generics (load first due to COLLATE)
- `R/hdp_*.R`: Main API functions (init, posterior, setdata, etc.)
- `R/extract_*.R`: Component extraction logic
- `R/plot_*.R`: Visualization functions
- `R/utilities*.R`: Helper functions (`utilities_nr3.R` is from Nicola Roberts)
- `R/RcppExports.R`: Auto-generated Rcpp bindings (do not edit)
- `src/R-*.c`: Original Teh C code for HDP sampling
- `src/cosCpp.cpp`: C++ cosine similarity (performance optimization)

## Branch Strategy

- Main development: `v1.0.5-branch`
- Current working branch: `v1.0.6-branch`
- Use `v1.0.5-branch` as base for PRs

## Key Gotchas

- **Linux only**: Package will not build on Windows/Mac (C code dependencies)
- **Rcpp + old C code**: Mix of modern Rcpp (cosCpp) and legacy C (.Call interface)
- **COLLATE order matters**: Class definitions must load before methods
- **Stirling table**: Must be initialized before any C calls (happens in .onLoad)
- **Long vector support**: Code handles R_xlen_t for large datasets
- **Seed management**: hdp_posterior takes explicit seed parameter for reproducibility

## Testing Notes

- Tests use example datasets: `example_data_hdp`, `example_data_hdp_prior`, `example_known_priors`
- Component extraction tests are slow (marked in filenames: `test-extract_slow-*.R`)
- Stirling number calculation has dedicated test: `test_stirling.R`
