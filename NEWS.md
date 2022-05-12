# [ 1.0.2 ]
* Fixed a bug in function `extract_components` when there is only one cluster

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
