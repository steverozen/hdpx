#' Extract components (aggregated clusters) and exposures from multiple posterior sample chains.
#'
#' @param multi.chains.retval A list that contains all the
#'  elements returned by \code{\link{extract_components_from_clusters}}.
#'
#' @param high.confidence.prop Components found in
#'   \eqn{>=} \code{high.confidence.prop} proportion of
#'   posterior samples are high confidence components.
#'
#' @param verbose if TRUE, generate progress messages.
#'
#' @return In the information that follows, a "component" is
#'  the union of multiple raw clusters of mutations (in the
#'  case of mutational signature analysis).
#'  Invisibly, a list with the following elements: \describe{
#'
#' \item{high_confidence_components}{A data frame containing the
#'    components found in >= \code{high.confidence.prop} of posterior samples. Each column is
#'    a component; in the case of mutational signatures the rows are mutation types.}
#'
#' \item{high_confidence_components_post_number}{A data frame
#'   in which the first column contains the index of a column in
#'   \code{high_confidence_components}
#'   and the second column contains the number of posterior samples that
#'   contributed to that component.}
#'
#' \item{high_confidence_components_cdc}{A matrix in which each row
#'  corresponds to one of the Dirichlet processes, and each column
#'  corresponds to one component in \code{high_confidence_components}.
#'  In the case of mutational signature analysis, most of the columns
#'  correspond to an input biological sample (e.g. individual tumor).}
#'
#' \item{low_confidence_components}{Analogous to \code{high_confidence_compents} except for
#'  components with constituent raw clusters found in
#'  < \code{high.confidence.prop} posterior samples.}
#'
#' \item{low_confidence_components_post_number}{Analogous
#'   to \code{high_confidence_components_post_number}.}
#'
#' \item{low_confidence_components_cdc}{Analogous
#'   to \code{high_confidence_components_cdc}.}
#'
#' }
#'
#' @export

interpret_components <- function(multi.chains.retval,
                                 high.confidence.prop = 0.90,
                                 verbose              = TRUE) {
  if (verbose) message("extracting components ", Sys.time())

  components_category_counts <- multi.chains.retval$components

  components_post_number <- multi.chains.retval$components.post.samples

  nsamp <-  multi.chains.retval$nsamp
  components_cdc <- multi.chains.retval$components.cdc

  new.order <- order(components_post_number[ ,2], decreasing=TRUE)
  components_category_counts <-
    components_category_counts[ , new.order, drop=FALSE]

  components_cdc <- components_cdc[ , new.order, drop=FALSE]

  components_post_number <- components_post_number[new.order, ]

  #the components with more than high.confidence.prop nsamples are
  #selected as components with high confidence

  high.conf.TF <-
    components_post_number[,2]>=(high.confidence.prop*nsamp)

  high_confidence_components <-
    components_category_counts[ , high.conf.TF, drop = FALSE]

  high_confidence_components_post_number <-
    components_post_number[high.conf.TF,]

  high_confidence_components_cdc <-
    components_cdc[ , high.conf.TF, drop = FALSE]

  #the components with less than high.confidence.prop nsamples
  #are selected as low confidence components
  low_confidence_components <-
    components_category_counts[, !high.conf.TF, drop = FALSE]

  low_confidence_components_post_number <-
    components_post_number[!high.conf.TF, ]

  low_confidence_components_cdc <-
    components_cdc[, !high.conf.TF, drop = FALSE]

  #noise components also include components that only occur in one posterior
  #sample of each chain
  low_confidence_components <-
    cbind(low_confidence_components,
          multi.chains.retval$each.chain.noise.components)

  low_confidence_components_cdc <-
    cbind(low_confidence_components_cdc,
          multi.chains.retval$each.chain.noise.cdc)

  return(invisible(list(
    high_confidence_components             = high_confidence_components,
    high_confidence_components_post_number = high_confidence_components_post_number,
    high_confidence_components_cdc         = high_confidence_components_cdc,
    low_confidence_components              = low_confidence_components,
    low_confidence_components_post_number  = low_confidence_components_post_number,
    low_confidence_components_cdc          = low_confidence_components_cdc
  )))

}

