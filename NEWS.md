# [ 1.0.5 ]
* Removed deprecated argument x from extract_components; use sample.chains
  instead.
* Created default_merge_raw_cluster_args and simplified associated argument
  lists.

# [ 1.0.3 ]
* Fixed(?) issue with multiple definitions of the "DEBUG" global 
  (renamed to hdpx_debug). Made the declaration in the header "extern" 
  and defined he variable in R-utils.h.

# [ 1.0.1 ]
* Simplified interpret_components and extract_components
* Renamed extract_components_from_clusters to extract_components

# [ 0.3.9 ]
* Removed unused variables from C code

# [ 0.3.8 ]
* Removed cos.merge argument from extract_components_from_clusters.
* Improved documentation.

# [ 0.3.7 ]
* Removed the "moderate" classification of confidence in extracted aggregated clusters.
* Removed default value of hc.cutoff in extract_components_from_clusters, because it 
  is different from the default in mSigHdp.
