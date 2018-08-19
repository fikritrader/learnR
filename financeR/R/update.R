#' @title Update the package contents without updating the package
#'
#' @description
#' \code{update} updates the current list of tutorials without requiring
#' to update the package.
#'
#' @author Ronald Hochreiter, \email{ronald@@algorithmic.finance}
#'
#' @export
update <- function() {
  status <- FALSE

  # list of packages
  url <- paste0("https://s3.amazonaws.com/finance-r.com/packages.rda")
  destfile <- paste0(tempdir(), "/packages.rda")
  filename <- paste0(path.package("financeR"), "/packages.rda")
  download.file(url, destfile, quiet=TRUE)
  status1 <- file.copy(destfile, filename, overwrite=TRUE)
  
  # tutorial list
  url <- paste0("https://s3.amazonaws.com/finance-r.com/tutorials.csv")
  destfile <- paste0(tempdir(), "/tutorials.csv")
  filename <- paste0(path.package("financeR"), "/tutorials.csv")
  download.file(url, destfile, quiet=TRUE)
  status2 <- file.copy(destfile, filename, overwrite=TRUE)

  # tutorials
  # ...
  
  status3 <- list(FALSE)
  
  # return all stati
  return(list(status1, status2, status3))
}
