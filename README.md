# hdpx

This package does mutational signature extraction. This branch of
of hdpx that was forked from Nicola Roberts's hdp package, and still implements the algorithm from
Section 4.2.2, "Extracting Consensus Signatures" from

Roberts, N. D. (2018). Patterns of somatic genome rearrangement in human cancer. (PhD Thesis). Cambridge University, Cambridge, England, United Kingdom. Retrieved from https://www.repository.cam.ac.uk/bitstream/handle/1810/275454/Roberts-2018-PhD.pdf

We do not recommend using this version.

## Installation

``` r
hdpx.version <- "0.1.5.0099"
if (system.file(package = "hdpx") != "") {
  if (packageVersion("hdpx") != hdpx.version) {
    remove.packages("hdpx")
    remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
  }
} else {
  remotes::install_github("steverozen/hdpx", ref = "NR-version-plus-fixes")
}
message("hdpx version ", packageVersion("hdpx"))
stopifnot(packageVersion("hdpx") == hdpx.version)


```

## Information from the original hdp package

R package to model categorical count data with a hierarchical Dirichlet Process. Includes functions to initialise a HDP of any shape, perform Gibbs sampling of the posterior distribution, and analyse the output. The underlying theory is described by Teh et al. (Hierarchical Dirichlet Processes, Journal of the American Statistical Association, 2006, 101:476). This R package was adapted from open source MATLAB and C code written by Yee Whye Teh and available here http://www.stats.ox.ac.uk/~teh/research/npbayes/npbayes-r21.tgz

```
Copyright (c) 2015 Genome Research Ltd. 
Author: Nicola Roberts <nr3@sanger.ac.uk> 
 
This program is free software: you can redistribute it and/or 
modify it under the terms of the GNU General Public License version 3 
as published by the Free Software Foundation. 

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
General Public License for more details <http://www.gnu.org/licenses/>. 
```

Copyright statement on original MATLAC and C code written by Yee Whye Teh, downloaded from 
http://www.stats.ox.ac.uk/~teh/research/npbayes/npbayes-r21.tgz

```
(C) Copyright 2004, Yee Whye Teh (ywteh -at- eecs -dot- berkeley -dot- edu)
http://www.cs.berkeley.edu/~ywteh

Permission is granted for anyone to copy, use, or modify these
programs and accompanying documents for purposes of research or
education, provided this copyright notice is retained, and note is
made of any changes that have been made.
 
These programs and documents are distributed without any warranty,
express or implied.  As the programs were written for research
purposes only, they have not been tested to the degree that would be
advisable in any important application.  All use of these programs is
```
