#' @title Return a data.frame with all currently available tutorials
#'
#' @description
#' \code{tutorials} returns a data.frame with all currently 
#' available tutorials.
#'
#' @author Ronald Hochreiter, \email{ronald@@algorithmic.finance}
#'
#' @export
tutorials <- function() {
  df.tutorials <- read.csv(paste0(path.package("optimizationR"), "/tutorials.csv"), sep=";", header=FALSE)
  names(df.tutorials) <- c("id", "order", "short", "updated", "version", "title", "description", "status")
  sorted.order <- sort(df.tutorials$order, index.return = TRUE)$ix
  active.tutorials <- which(df.tutorials$status == 1)
  tutorial.list <- intersect(sorted.order, active.tutorials)
  return(df.tutorials[tutorial.list,c(3,6,4,5)])
}
